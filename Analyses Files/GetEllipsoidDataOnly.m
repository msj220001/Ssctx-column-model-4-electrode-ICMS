clear all; clc; close all;

% Create "Extracted Matrices" folder if it doesn't exist
if ~exist('Extracted Matrices', 'dir')
    mkdir('Extracted Matrices');
end

% Select .fig files
[fileNames, path1] = uigetfile('*.fig', 'Select Figure Files', 'MultiSelect', 'on');
if isequal(fileNames, 0)
    disp('No files selected. Exiting...');
    return;
end
if ischar(fileNames)
    fileNames = {fileNames};
end

for f = 1:length(fileNames)
    file = fileNames{f};
    fprintf('\nProcessing %s...\n', file);
    
    fig = openfig(fullfile(path1, file), 'invisible');
    ax = findobj(fig, 'Type', 'axes');
    scatterData = findobj(ax, 'Type', 'Line');

    % Initialize storage
    RedPoints = []; MagentaPoints = []; YellowPoints = [];
    GreenPoints = []; BluePoints = []; GrayPoints = [];

    for i = 1:length(scatterData)
        xData = get(scatterData(i), 'XData');
        yData = get(scatterData(i), 'YData');
        zData = get(scatterData(i), 'ZData');
        cData = get(scatterData(i), 'Color');

        if isequal(cData, [1, 0, 0])
            RedPoints = [RedPoints; xData', yData', zData'];
        elseif isequal(cData, [1, 0, 1])
            MagentaPoints = [MagentaPoints; xData', yData', zData'];
        elseif isequal(cData, [251 177 23]/255)
            YellowPoints = [YellowPoints; xData', yData', zData'];
        elseif isequal(cData, [0 100 0]/255)
            GreenPoints = [GreenPoints; xData', yData', zData'];
        elseif isequal(cData, [0, 0, 1])
            BluePoints = [BluePoints; xData', yData', zData'];
        elseif isequal(cData, [169 169 169]/255)
            GrayPoints = [GrayPoints; xData', yData', zData'];
        end
    end

    fileBase = file(1:end-4);
    saveName = fullfile('Extracted Matrices', [fileBase, '.mat']);
    save(saveName, 'RedPoints', 'MagentaPoints', 'YellowPoints', ...
         'GreenPoints', 'BluePoints', 'GrayPoints');

    fprintf('\nExtracted Data Summary for: %s\n', file);
    fprintf('   Red (Activated Neurons): %d points\n', size(RedPoints, 1));
    
    close(fig);

%% --- User input for center and capture percentages ---
center = [200 200 200];  % Fixed user-defined center
capturePercentages = [100];

if isempty(RedPoints)
    disp('No red points found. Skipping ellipsoid calculation...');
    return;
end

% Preallocate results structure
EllipsoidFits = struct([]);

% Loop through each capture percentage
for c = 1:numel(capturePercentages)
    capperc = capturePercentages(c);
    fprintf('\n--- Running capture percentage: %.1f%% ---\n', capperc);

    % Find initial spreads using percentile ranges
    half_width = capperc / 2;
    bottomrange = 50 - half_width;
    toprange = 50 + half_width;
    x_range = prctile(RedPoints(:,1), [bottomrange, toprange]);
    y_range = prctile(RedPoints(:,2), [bottomrange, toprange]);
    z_range = prctile(RedPoints(:,3), [bottomrange, toprange]);

    xspread = (x_range(2) - x_range(1)) / 2;
    yspread = (y_range(2) - y_range(1)) / 2;
    zspread = (z_range(2) - z_range(1)) / 2;

    % Initial check for capture
    inside = checkEllipsoid(xspread, yspread, zspread, center, RedPoints);
    captured_percent = 100 * nnz(inside) / size(RedPoints, 1);

    % Growth loop
    axgrowths = [1 10];  % Two passes with different growth steps
    maxIter = 10000;

    for g = 1:numel(axgrowths)
        if captured_percent >= capperc
            disp("Already captured enough in first trial. Skipping rescue capture.")
           break;  % Already captured enough — skip the next growth phase
        end
        axgrowth = axgrowths(g);
        iter = 0;

        while captured_percent < capperc && iter < maxIter
            iter = iter + 1;

            % Try growing each axis
            spreads = [xspread, yspread, zspread];
            labels = {'xspread', 'yspread', 'zspread'};
            axesIdx = [1, 2, 3];

            for i = axesIdx
                test_spreads = spreads;
                test_spreads(i) = test_spreads(i) + axgrowth;
                temp_inside = checkEllipsoid(test_spreads(1), test_spreads(2), test_spreads(3), center, RedPoints);
                new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
                if new_percent > captured_percent
                    spreads(i) = test_spreads(i);
                    inside = temp_inside;
                    captured_percent = new_percent;
                end
            end

            xspread = spreads(1);
            yspread = spreads(2);
            zspread = spreads(3);

            if captured_percent >= capperc
                break;
            end
        end
    end

    % Compute volume of the ellipsoid within voxel grid
    dx = 1; dy = 1; dz = 5;
    [X, Y, Z] = ndgrid(0:dx:400, 0:dy:400, 0:dz:2000);
    ellipsoidMask = ((X - center(1)).^2 / xspread^2 + ...
                     (Y - center(2)).^2 / yspread^2 + ...
                     (Z - center(3)).^2 / zspread^2) <= 1;

    voxelVolume = dx * dy * dz;  % in um³
    clippedVolume = nnz(ellipsoidMask) * voxelVolume;

    % Store and display results
    EllipsoidFits(c).capturePercent = capperc;
    EllipsoidFits(c).center = center;
    EllipsoidFits(c).axes_um = [xspread yspread zspread];
    EllipsoidFits(c).totalRed = size(RedPoints, 1);
    EllipsoidFits(c).numCaptured = nnz(inside);
    EllipsoidFits(c).capturedPercent = captured_percent;
    EllipsoidFits(c).clippedVolume_um3 = clippedVolume;

    fprintf('   Center: [%.2f, %.2f, %.2f] um\n', center);
    fprintf('   Axes (x, y, z): %.2f, %.2f, %.2f um\n', xspread, yspread, zspread);
    fprintf('   Red Points: %d\n', size(RedPoints, 1));
    fprintf('   Captured: %d (%.2f%%)\n', nnz(inside), captured_percent);
    fprintf('   Volume: %.2f um³\n', clippedVolume);
end
end
% Optional: Save the results
save(saveName, 'EllipsoidFits', '-append');

%% --- Function to check if the points are inside the ellipsoid ---
function inside = checkEllipsoid(xspread, yspread, zspread, center, RedPoints)
    x_shifted = (RedPoints(:,1) - center(1)).^2 / xspread^2;
    y_shifted = (RedPoints(:,2) - center(2)).^2 / yspread^2;
    z_shifted = (RedPoints(:,3) - center(3)).^2 / zspread^2;
    inside = (x_shifted + y_shifted + z_shifted) <= 1;
end