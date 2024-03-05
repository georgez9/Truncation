load('data\matter_connections.mat');
matter_type = 1;
hemisphere_type = 0;
switch matter_type
    case 0
        labels = matter_connections_with_labels.grey_matter_connections{:, 1}';
        maps = matter_connections_with_labels.grey_matter_connections{:, 2:129} +...
            2*matter_connections_with_labels.white_matter_connections{:, 2:129};
    case 1
        labels = matter_connections_with_labels.white_matter_connections{:, 1}';
        maps = matter_connections_with_labels.white_matter_connections{:, 2:129};
    case 2
        labels = matter_connections_with_labels.grey_matter_connections{:, 1}';
        maps = matter_connections_with_labels.grey_matter_connections{:, 2:129};
end

labels = replace(labels, '_', '\_');

% Extract regions by different hemispheres
sublabel_left = {};
sublabel_left_index = [];
for i = 1:length(labels)
    label = labels{i};
    if startsWith(label, 'l.') || startsWith(label, "Left")
        sublabel_left{end+1} = label;
        sublabel_left_index(end+1) = i;
    end
end
[sublabel_left, sort1] = sort(sublabel_left);
sublabel_left_index = sublabel_left_index(sort1);
submap1 = maps(sublabel_left_index, sublabel_left_index);

sublabel_right = {};
sublabel_right_index = [];
for i = 1:length(labels)
    label = labels{i};
    if startsWith(label, 'r.') || startsWith(label, "Right")
        sublabel_right{end+1} = label;
        sublabel_right_index(end+1) = i;
    end
end
[sublabel_right, sort2] = sort(sublabel_right);
sublabel_right_index = sublabel_right_index(sort2);
submap2 = maps(sublabel_right_index, sublabel_right_index);

switch hemisphere_type
    case 0
        submap = submap1;
        sublabel = sublabel_left;
    case 1
        submap = submap2;
        sublabel = sublabel_right;
end

% Show the first matrix
figure;
myColormap = [1 1 1; 0 1 1; 0 0 0; 0.4 0.4 1];
imagesc(submap);
title("Left cerebral hemisphere");
colormap(myColormap);
axis equal;
axis tight;
yticks(1:length(sublabel));
yticklabels(sublabel);
xticks(1:length(sublabel));
xticklabels(sublabel);
xtickangle(45);
set(gca, 'TickLength', [0 0]);

hold on; % Draw grid
% for k = 0.5:1:length(sublabel)+0.5
%     line(xlim, [k, k], 'Color', [0.9 0.9 0.9]);
% end
% for k = 0.5:1:length(sublabel)+0.5
%     line([k, k], ylim, 'Color', [0.9 0.9 0.9]);
% end

% Matrix mask
x = [0.5, length(sublabel)+0.5, length(sublabel)+0.5];
y = [0.5, length(sublabel)+0.5, 0.5];
fill(x, y, 'w', 'EdgeColor', 'none', 'FaceAlpha', 0.8);

% Divide the matrix based on regions
grid_region_name = {};
grid_region_index = [];
for i = 1:length(sublabel)-1
    str1 = string(sublabel(i));
    str2 = string(sublabel(i+1));
    value = strncmp(str1, str2, min(strlength(str1), strlength(str2)-2));
    if value == 0
        line(xlim, [i+0.5, i+0.5], 'Color', [0 0 0], 'LineWidth', 0.3);
        line([i+0.5, i+0.5], ylim, 'Color', [0 0 0], 'LineWidth', 0.3);
        grid_region_name{end+1} = str1;
        grid_region_index(end+1) = i;
    end
end
hold off;

% Extract the actual names -> grid_region_name
grid_region_name{end+1} = str2;
grid_region_name = grid_region_name';
grid_region_index(end+1) = i+1;
grid_region_index = grid_region_index';
for i = 1:length(grid_region_name)
    if startsWith(grid_region_name{i}, 'Left')
        grid_region_name{i} = extractAfter(grid_region_name{i}, 5);
    end
    if startsWith(grid_region_name{i}, 'l.')
        grid_region_name{i} = extractAfter(grid_region_name{i}, 2);
    end
    if endsWith(grid_region_name{i}, '1') || endsWith(grid_region_name{i}, '2') ||...
            endsWith(grid_region_name{i}, '3') || endsWith(grid_region_name{i}, '4')
        grid_region_name{i} = extractBefore(grid_region_name{i}, strlength(grid_region_name{i})-2);
    end
end

% Define the new matrix
region_connection_matrix = zeros(length(grid_region_index), length(grid_region_index));
for i = 1:length(grid_region_index)
    for j = 1:length(grid_region_index)
        if i == 1 && j == 1
            submatrix = submap(1:grid_region_index(i),...
                1:grid_region_index(j));
        elseif i == 1
            submatrix = submap(1:grid_region_index(i),...
                grid_region_index(j-1)+1:grid_region_index(j));
        elseif j == 1
            submatrix = submap(grid_region_index(i-1)+1:grid_region_index(i),...
                1:grid_region_index(j));
        else
            submatrix = submap(grid_region_index(i-1)+1:grid_region_index(i),...
                grid_region_index(j-1)+1:grid_region_index(j));
        end
        
        avg_submatrix = sum(submatrix(:))/numel(submatrix);
        region_connection_matrix(i, j) = avg_submatrix;
    end
end

% Show the merged matrix
figure;
imagesc(region_connection_matrix);
% myColormap = [1 1 1; 0 1 1; 0 0 0; 0.4 0.4 1];
title("Left cerebral hemisphere");
colorbar;
colormap sky;
axis equal;
axis tight;
yticks(1:length(grid_region_index));
yticklabels(grid_region_name);
set(gca, 'TickLength', [0 0]);
hold on;
x = [0.5, length(grid_region_name)+0.5, length(grid_region_name)+0.5];
y = [0.5, length(grid_region_name)+0.5, 0.5];
fill(x, y, 'w', 'EdgeColor', 'none', 'FaceAlpha', 0.8);

for k = 0.5:1:length(grid_region_index)+0.5
    line(xlim, [k, k], 'Color', [0.7 0.7 0.7]);
end
for k = 0.5:1:length(grid_region_index)+0.5
    line([k, k], ylim, 'Color', [0.7 0.7 0.7]);
end
hold off;

[table_left, table_right] = seizure_frequency();

[~, loc] = ismember(cellstr(table_left.LeftName), cellstr(grid_region_name));
frequency_display = zeros(1, length(grid_region_name));
table_left.LeftFrequency(1)
for i = 1:length(loc)
    frequency_display(loc(i)) = table_left.LeftFrequency(i);
end
figure;
sum_connection = sum(region_connection_matrix);

x = sum_connection;
y = frequency_display;
scatter(x, y);
xlabel('X array');
ylabel('Y array');
title('Scatter plot of X and Y');

% 计算相关系数
R = corrcoef(x, y);

% 显示相关系数
disp('Correlation coefficient between X and Y:');
disp(R(1,2)); % R返回一个矩阵，相关系数在非对角线上

