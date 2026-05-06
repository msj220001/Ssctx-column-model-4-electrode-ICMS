clear all;

% Create the "Result Figures" directory if it doesn't exist
if ~exist('Result Figures', 'dir')
    mkdir('Result Figures');
end

% Choose first .mat file
[file1, path1] = uigetfile('Extracted Matrices/*.mat', 'Select the first .mat file');
data1_struct = load(fullfile(path1, file1));  % Load as struct
field1 = fieldnames(data1_struct);            % Extract field names
data1a = data1_struct.(field1{1});            % Access data dynamically
data1b = data1_struct.(field1{2});
data1c = data1_struct.(field1{3});
data1d = data1_struct.(field1{4});
data1e = data1_struct.(field1{5});
data1f = data1_struct.(field1{6});

% Choose second .mat file
[file2, path2] = uigetfile('Extracted Matrices/*.mat', 'Select the second .mat file');
data2_struct = load(fullfile(path2, file2));  % Load as struct
field2 = fieldnames(data2_struct);            % Extract field names
data2a = data2_struct.(field2{1});            % Access data dynamically
data2b = data2_struct.(field2{2});
data2c = data2_struct.(field2{3});
data2d = data2_struct.(field2{4});
data2e = data2_struct.(field2{5});
data2f = data2_struct.(field2{6});

% Extract x,y,z coordiantes for Stimulus #1
x1a = data1a(:, 1); y1a = data1a(:, 3); z1a = data1a(:, 2);
x1b = data1b(:, 1); y1b = data1b(:, 3); z1b = data1b(:, 2);
x1c = data1c(:, 1); y1c = data1c(:, 3); z1c = data1c(:, 2);
x1d = data1d(:, 1); y1d = data1d(:, 3); z1d = data1d(:, 2);
x1e = data1e(:, 1); y1e = data1e(:, 3); z1e = data1e(:, 2); % Activated
x1f = data1f(:, 1); y1f = data1f(:, 3); z1f = data1f(:, 2);

% Extract x,y,z coordinates for Stimulus #2
x2a = data2a(:, 1); y2a = data2a(:, 3); z2a = data2a(:, 2);
x2b = data2b(:, 1); y2b = data2b(:, 3); z2b = data2b(:, 2);
x2c = data2c(:, 1); y2c = data2c(:, 3); z2c = data2c(:, 2);
x2d = data2d(:, 1); y2d = data2d(:, 3); z2d = data2d(:, 2);
x2e = data2e(:, 1); y2e = data2e(:, 3); z2e = data2e(:, 2); % Activated
x2f = data2f(:, 1); y2f = data2f(:, 3); z2f = data2f(:, 2);

% Find overlapping coordinates
[overlap, idx1, idx2] = intersect([x1e, y1e, z1e], [x2e, y2e, z2e], 'rows');

% Create filenames based on the original .mat filenames
file1_base = file1(1:end-4);  % Remove .mat extension
file2_base = file2(1:end-4);  % Remove .mat extension

% Replace unsupported characters for filenames
file1_base = strrep(file1_base, '.', '_');
file2_base = strrep(file2_base, '.', '_');

% Colors for non-activated cells
colorArray = [
    0, 0, 255;      % Blue
    169, 169, 169;  % Grey
    0, 100, 0;      % Green
    255, 0, 255;    % Magenta
    251, 177, 23    % Yellow
];

% Save first stimulus figure
figure(1);
hold on
scatter3(x1e, z1e, y1e, 6, 'r', 'filled');  % Stim 1 dots for first file
scatter3(x1a, z1a, y1a, 1, colorArray(1,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x1b, z1b, y1b, 1, colorArray(2,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x1c, z1c, y1c, 1, colorArray(3,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x1d, z1d, y1d, 1, colorArray(4,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); 
scatter3(x1f, z1f, y1f, 1, colorArray(5,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
%title('Stimulus #1');
axis equal;
set(gca, 'XTick', 0:200:400, 'YTick', 0:200:400, 'ZTick', 0:200:2000);
% Flip only the Z-axis labels while keeping the data unchanged
zticks = get(gca, 'ZTick');  
set(gca, 'ZTickLabel', flip(zticks));  
xlim([0 400]); ylim([0 400]); zlim([0 2000]);
grid("on");
view(3);
set(gcf, 'color', 'w');
hold off
savefig(fullfile('Result Figures', [file1_base, '.fig']));
%exportgraphics(gcf, fullfile('Result PNGs', [file1_base, '.png']), 'Resolution', 600);

% Save second stimulus figure
figure(2);
hold on
scatter3(x2e, z2e, y2e, 6, [0.5, 0, 0], 'filled');  % Stim 2 dots for second file
scatter3(x2a, z2a, y2a, 1, colorArray(1,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x2b, z2b, y2b, 1, colorArray(2,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x2c, z2c, y2c, 1, colorArray(3,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x2d, z2d, y2d, 1, colorArray(4,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x2f, z2f, y2f, 1, colorArray(5,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
%title('Stimulus #2');
axis equal;
set(gca, 'XTick', 0:200:400, 'YTick', 0:200:400, 'ZTick', 0:200:2000);
% Flip only the Z-axis labels while keeping the data unchanged
zticks = get(gca, 'ZTick');  
set(gca, 'ZTickLabel', flip(zticks));  
xlim([0 400]); ylim([0 400]); zlim([0 2000]);
grid("on");
view(3);
set(gcf, 'color', 'w');
hold off
savefig(fullfile('Result Figures', [file2_base, '.fig']));
%exportgraphics(gcf, fullfile('Result PNGs', [file2_base, '.png']), 'Resolution', 600);

% Save overlap figure
figure(3);
if ~isempty(overlap)
    hold on
    scatter3(overlap(:, 1), overlap(:, 3), overlap(:, 2), 6, 'g', 'filled');  % Overlap dots for overlap
    scatter3(x1a, z1a, y1a, 1, colorArray(1,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
    scatter3(x1b, z1b, y1b, 1, colorArray(2,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
    scatter3(x1c, z1c, y1c, 1, colorArray(3,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
    scatter3(x1d, z1d, y1d, 1, colorArray(4,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
    scatter3(x1f, z1f, y1f, 1, colorArray(5,:)/255, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
    %title('Overlap');
    axis equal;
    set(gca, 'XTick', 0:200:400, 'YTick', 0:200:400, 'ZTick', 0:200:2000);
    % Flip only the Z-axis labels while keeping the data unchanged
    %zticks = get(gca, 'ZTick');  
    %set(gca, 'ZTickLabel', flip(zticks));  
    xlim([0 400]); ylim([0 400]); zlim([0 2000]);
    grid("on");
    view(3);
    set(gcf, 'color', 'w');
    hold off
    savefig(fullfile('Result Figures', [file1_base, '_intersecting_', file2_base, '.fig']));
    %exportgraphics(gcf, fullfile('Result PNGs', [file1_base, '_intersecting_', file2_base, '.png']), 'Resolution', 600);
else
    disp('No overlapping points found.');
end

% Save combined figure
figure(4);
hold on;
scatter3(x1e, z1e, y1e, 10, [0, 0, 0.75], 'filled', 'SizeData', 10);  % Stim 1 dots
%scatter3(x2e, z2e, y2e, 6, [0.3, 0.3, 0.3], 'filled', 'MarkerFaceAlpha',
%0.2, 'MarkerEdgeAlpha', 0.5); % Stim 2 dots in dark grey
scatter3(x2e, z2e, y2e, 10, [0.75, 0, 0], 'filled', 'SizeData', 10, 'MarkerFaceAlpha', 0.7);  % Stim 2 dots
scatter3(x1a, z1a, y1a, 1, colorArray(1,:)/255, 'filled', 'SizeData', 3,  'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); 
scatter3(x1b, z1b, y1b, 1, colorArray(2,:)/255, 'filled', 'SizeData', 3, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); 
scatter3(x1c, z1c, y1c, 1, colorArray(3,:)/255, 'filled', 'SizeData', 3, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x1d, z1d, y1d, 1, colorArray(4,:)/255, 'filled', 'SizeData', 3, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
scatter3(x1f, z1f, y1f, 1, colorArray(5,:)/255, 'filled', 'SizeData', 3, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  
if ~isempty(overlap)
    %scatter3(overlap(:, 1), overlap(:, 3), overlap(:, 2), 6, 'r', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha',0.5);  % Overlap dots for overlap
end

% === Ellipsoid Input & Visualization ===

% Get ellipsoid parameters from user
prompt = {'Enter center1 [x y z]:', 'Enter axes_set1 [x y z]:', ...
          'Enter center2 [x y z]:', 'Enter axes_set2 [x y z]:'};
dlgtitle = 'Ellipsoid Parameters';
dims = [1 50];
definput = {'200 200 1000', '100 100 500', '200 200 1000', '100 100 500'};
answer = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(answer)
    return;  % User cancelled
end

% Parse inputs
center1 = str2num(answer{1}); %#ok<ST2NM>
axes1   = str2num(answer{2}); %#ok<ST2NM>
center2 = str2num(answer{3}); %#ok<ST2NM>
axes2   = str2num(answer{4}); %#ok<ST2NM>

% Generate voxel grid within model bounds
[xg, yg, zg] = ndgrid(0:1:400, 0:1:400, 0:5:2000);  % Use z-step=5 for speed

% Normalize coordinates for both ellipsoids
ellip1_mask = (((xg - center1(1)).^2) / axes1(1)^2 + ...
               ((yg - center1(2)).^2) / axes1(2)^2 + ...
               ((zg - center1(3)).^2) / axes1(3)^2) <= 1;

ellip2_mask = (((xg - center2(1)).^2) / axes2(1)^2 + ...
               ((yg - center2(2)).^2) / axes2(2)^2 + ...
               ((zg - center2(3)).^2) / axes2(3)^2) <= 1;

% Overlap mask
overlap_mask = ellip1_mask & ellip2_mask;

% Compute volume in µm^3 (each voxel is 1×1×5 µm³ = 5 µm³)
voxel_volume = 1 * 1 * 5;  % µm³
overlap_voxels = sum(overlap_mask(:));
overlap_volume = overlap_voxels * voxel_volume;

% Print volume result
fprintf('Volume of ellipsoid overlap (within bounds): %.2f µm³\n', overlap_volume);

% === Plot ellipsoids on combined figure ===
figure(4); hold on;

% Create and plot ellipsoid 1
[x1, y1, z1] = ellipsoid(center1(1), center1(2), center1(3), ...
                         axes1(1), axes1(2), axes1(3), 30);
h1 = surf(x1, y1, z1);  
set(h1, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', 'cyan');

% Create and plot ellipsoid 2
[x2, y2, z2] = ellipsoid(center2(1), center2(2), center2(3), ...
                         axes2(1), axes2(2), axes2(3), 30);
h2 = surf(x2, y2, z2);  
set(h2, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', [0.8, 0, 0]);



%title('Combined Plot');
axis equal;
set(gca, 'XTick', 0:200:400, 'YTick', 0:200:400, 'ZTick', 0:200:2000);
% Flip only the Z-axis labels while keeping the data unchanged
%zticks = get(gca, 'ZTick');  
%set(gca, 'ZTickLabel', flip(zticks));  
xlim([0 400]); ylim([0 400]); zlim([0 2000]);
grid("on");
view(3);
set(gcf, 'color', 'w');
hold off;
savefig(fullfile('Result Figures', [file1_base, '_and_', file2_base, '.fig']));
%exportgraphics(gcf, fullfile('Result PNGs', [file1_base, '_and_', file2_base, '.png']), 'Resolution', 600);

% Display counts
fprintf('Number of Stim 1 dots in %s: %d\n', file1, size(x1e, 1));
fprintf('Number of Stim 2 dots in %s: %d\n', file2, size(x2e, 1));
fprintf('Number of overlapping dots: %d\n', size(overlap, 1));
