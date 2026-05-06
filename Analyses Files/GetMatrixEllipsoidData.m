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
    fprintf('   Red (Activated Axons): %d points\n', size(RedPoints, 1));
    
    close(fig);

%% --- User input for center ---
center = [200 200 200]
% center = input('Enter the [x, y, z] center for the ellipsoid as a 3-element vector: ');
capperc = 80; 
if isempty(RedPoints)
    disp('No red points found. Skipping ellipsoid calculation...');
    continue;
end

% Find radius for each axis that captures W% of points initially
half_width = capperc / 2;
bottomrange = 50 - half_width;
toprange = 50 + half_width;
x_range = prctile(RedPoints(:,1), [bottomrange, toprange]);
y_range = prctile(RedPoints(:,2), [bottomrange, toprange]);
z_range = prctile(RedPoints(:,3), [bottomrange, toprange]);

xspread = (x_range(2) - x_range(1)) / 2;
yspread = (y_range(2) - y_range(1)) / 2;
zspread = (z_range(2) - z_range(1)) / 2;

% Initial check for % capture
inside = checkEllipsoid(xspread, yspread, zspread, center, RedPoints);
captured_percent = 100 * nnz(inside) / size(RedPoints, 1);

maxIter = 10000;
iter = 0;

while captured_percent < capperc && iter < maxIter
    iter = iter + 1;
    %improved = false;
    axgrowth = 3;

    % --- Try increasing zspread ---
    temp_inside = checkEllipsoid(xspread, yspread, zspread + axgrowth, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        zspread = zspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current zspread:", num2str(zspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end

        % --- Try increasing yspread ---
    temp_inside = checkEllipsoid(xspread, yspread + axgrowth, zspread, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        yspread = yspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current yspread:", num2str(yspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end

    % --- Try increasing xspread ---
    temp_inside = checkEllipsoid(xspread + axgrowth, yspread, zspread, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        xspread = xspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current xspread:", num2str(xspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end

    %disp(["Number of iterations:", num2str(iter)]);
    %if ~improved
        %warning('Unable to reach 95%% capture. Stopping with %.2f%% captured.', captured_percent);
        %break;
    %end
end

iter = 0;
while captured_percent < capperc && iter < maxIter
    iter = iter + 1;
    %improved = false;
    axgrowth = 6;

    % --- Try increasing zspread 2nd try ---
    temp_inside = checkEllipsoid(xspread, yspread, zspread + axgrowth, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        zspread = zspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current zspread:", num2str(zspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end

        % --- Try increasing yspread 2nd try ---
    temp_inside = checkEllipsoid(xspread, yspread + axgrowth, zspread, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        yspread = yspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current yspread:", num2str(yspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end

    % --- Try increasing xspread 2nd try ---
    temp_inside = checkEllipsoid(xspread + axgrowth, yspread, zspread, center, RedPoints);
    new_percent = 100 * nnz(temp_inside) / size(RedPoints, 1);
    
    if new_percent > captured_percent
        xspread = xspread + axgrowth;
        captured_percent = new_percent;
        inside = temp_inside;
        disp(["Current xspread:", num2str(xspread)]);
        %improved = true;
    end

    if captured_percent >= capperc
        break;
    end
end

% After we reach capture percent inside the ellipsoid, we compute the clipped volume
% Define voxel size for the volume calculation
dx = 1; dy = 1; dz = 5;
[X, Y, Z] = ndgrid(0:dx:400, 0:dy:400, 0:dz:2000);

ellipsoidMask = ((X - center(1)).^2 / xspread^2 + ...
                 (Y - center(2)).^2 / yspread^2 + ...
                 (Z - center(3)).^2 / zspread^2) <= 1;

voxelVolume = dx * dy * dz;
clippedVolume = nnz(ellipsoidMask) * voxelVolume;

% Save results
EllipsoidInfo.center = center;
EllipsoidInfo.axes = [xspread yspread zspread];
EllipsoidInfo.totalRed = size(RedPoints, 1);
EllipsoidInfo.numCaptured = nnz(inside);
EllipsoidInfo.capturedPercent = captured_percent;
EllipsoidInfo.clippedVolume_mm3 = clippedVolume;
save(saveName, 'EllipsoidInfo', '-append');

% Display results
fprintf('\nEllipsoid Fit Results:\n');
fprintf('   Center:     [%.2f, %.2f, %.2f]\n', center(1), center(2), center(3));
fprintf('   Axes (x, y, z): %.2f, %.2f, %.2f um\n', xspread, yspread, zspread);
fprintf('   Total Red Points: %d\n', size(RedPoints,1));
fprintf('   Red Points Inside Ellipsoid: %d (%.2f%%)\n', nnz(inside), captured_percent);
fprintf('   Ellipsoid Volume (within bounds): %.2f um³\n', clippedVolume);

    %% --- Visualization ---
    figure('Name', ['Ellipsoid Fit - ', fileBase], 'NumberTitle', 'off');
    hold on;
    grid on;
    axis equal;
    view(3);
    xlim([0 400]); ylim([0 400]); zlim([0 2000]);
    set(gca, 'XTick', 0:200:400, 'YTick', 0:200:400, 'ZTick', 0:500:2000);
    set(gcf, 'color', 'w');

    % Plot red points (red if inside, black if outside)
    if ~isempty(RedPoints)
        scatter3(RedPoints(inside,1), RedPoints(inside,2), RedPoints(inside,3), 6, 'r', 'filled');
        scatter3(RedPoints(~inside,1), RedPoints(~inside,2), RedPoints(~inside,3), 6, 'k', 'filled');
    end
    if ~isempty(MagentaPoints)
        scatter3(MagentaPoints(:,1), MagentaPoints(:,2), MagentaPoints(:,3), 1, 'magenta', 'filled');
        numMagenta = size(MagentaPoints, 1);
        text(0, 0, 0, ['Magenta: ', num2str(numMagenta)], 'Color', 'magenta', 'FontSize', 12);
    end
    if ~isempty(YellowPoints)
        scatter3(YellowPoints(:,1), YellowPoints(:,2), YellowPoints(:,3), 1, [251 177 23]/255, 'filled');
    end
    if ~isempty(GreenPoints)
        scatter3(GreenPoints(:,1), GreenPoints(:,2), GreenPoints(:,3), 1, [0 100 0]/255, 'filled');
    end
    if ~isempty(BluePoints)
        scatter3(BluePoints(:,1), BluePoints(:,2), BluePoints(:,3), 1, 'b', 'filled');
    end
    if ~isempty(GrayPoints)
        scatter3(GrayPoints(:,1), GrayPoints(:,2), GrayPoints(:,3), 1, [169 169 169]/255, 'filled');
    end

    % Ellipsoid surface
    [xe, ye, ze] = ellipsoid(center(1), center(2), center(3), xspread, yspread, zspread, 30);
    surf(xe, ye, ze, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'FaceColor', 'cyan');

    title(['Ellipsoid Fit - ', fileBase], 'Interpreter', 'none');
    legend({'Red-In', 'Red-Out', 'Magenta', 'Yellow', 'Green', 'Blue', 'Gray'}, 'Location', 'bestoutside');

    saveas(gcf, fullfile('Extracted Matrices', [fileBase, '_ellipsoid.png']));
    %close(gcf);
end

disp('Processing complete. All results saved.');

%% --- Function to check if the points are inside the ellipsoid ---
function inside = checkEllipsoid(xspread, yspread, zspread, center, RedPoints)
    x_shifted = (RedPoints(:,1) - center(1)).^2 / xspread^2;
    y_shifted = (RedPoints(:,2) - center(2)).^2 / yspread^2;
    z_shifted = (RedPoints(:,3) - center(3)).^2 / zspread^2;
    inside = (x_shifted + y_shifted + z_shifted) <= 1;
end

