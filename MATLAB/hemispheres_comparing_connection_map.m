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
submap3 = maps(sublabel_left_index, sublabel_right_index);
submap4 = maps(sublabel_right_index, sublabel_left_index);

switch hemisphere_type
    case 0
        submap = submap1;
        sublabel_x = sublabel_left;
        sublabel_y = sublabel_left;
    case 1
        submap = submap2;
        sublabel_x = sublabel_right;
        sublabel_y = sublabel_right;
    case 2
        submap = submap3;
        sublabel_x = sublabel_right;
        sublabel_y = sublabel_left;
    case 3
        submap = submap4;
        sublabel_x = sublabel_left;
        sublabel_y = sublabel_right;
end
% Show the first matrix
figure;
myColormap = [1 1 1; 0 1 1; 0 0 0; 0.4 0.4 1];
imagesc(submap);
if hemisphere_type == 0
    title("Left cerebral hemisphere");
elseif hemisphere_type == 1
    title("Right cerebral hemisphere");
elseif hemisphere_type == 2
    title("Across cerebral hemisphere");
elseif hemisphere_type == 3
    title("Across cerebral hemisphere");
end
colormap(myColormap);
axis equal;
axis tight;
yticks(1:length(sublabel_y));
yticklabels(sublabel_y);
xticks(1:length(sublabel_x));
xticklabels(sublabel_x);
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
% x = [0.5, length(sublabel_x)+0.5, length(sublabel_x)+0.5];
% y = [0.5, length(sublabel_y)+0.5, 0.5];
% fill(x, y, 'w', 'EdgeColor', 'none', 'FaceAlpha', 0.8);

% Divide the matrix based on regions
grid_region_name_x = {};
grid_region_index_x = [];
grid_region_name_y = {};
grid_region_index_y = [];
for i = 1:length(sublabel_x)-1
    str1_x = string(sublabel_x(i));
    str2_x = string(sublabel_x(i+1));
    value = strncmp(str1_x, str2_x, min(strlength(str1_x), strlength(str2_x)-2));
    if value == 0
        % line(xlim, [i+0.5, i+0.5], 'Color', [0 0 0], 'LineWidth', 0.3);
        line([i+0.5, i+0.5], ylim, 'Color', [0 0 0], 'LineWidth', 0.3);
        grid_region_name_x{end+1} = str1_x;
        grid_region_index_x(end+1) = i;
    end
end
for j = 1:length(sublabel_y)-1
    str1_y = string(sublabel_y(j));
    str2_y = string(sublabel_y(j+1));
    value = strncmp(str1_y, str2_y, min(strlength(str1_y), strlength(str2_y)-2));
    if value == 0
        line(xlim, [j+0.5, j+0.5], 'Color', [0 0 0], 'LineWidth', 0.3);
        % line([i+0.5, i+0.5], ylim, 'Color', [0 0 0], 'LineWidth', 0.3);
        grid_region_name_y{end+1} = str1_y;
        grid_region_index_y(end+1) = j;
    end
end
hold off;

% Extract the actual names -> grid_region_name
grid_region_name_x{end+1} = str2_x;
grid_region_name_x = grid_region_name_x';
grid_region_index_x(end+1) = i+1;
grid_region_index_x = grid_region_index_x';
for i = 1:length(grid_region_name_x)
    if startsWith(grid_region_name_x{i}, 'Left')
        grid_region_name_x{i} = extractAfter(grid_region_name_x{i}, 5);
    end
    if startsWith(grid_region_name_x{i}, 'Right')
        grid_region_name_x{i} = extractAfter(grid_region_name_x{i}, 6);
    end
    if startsWith(grid_region_name_x{i}, 'l.') || startsWith(grid_region_name_x{i}, 'r.')
        grid_region_name_x{i} = extractAfter(grid_region_name_x{i}, 2);
    end
    if endsWith(grid_region_name_x{i}, '1') || endsWith(grid_region_name_x{i}, '2') ||...
            endsWith(grid_region_name_x{i}, '3') || endsWith(grid_region_name_x{i}, '4')
        grid_region_name_x{i} = extractBefore(grid_region_name_x{i}, strlength(grid_region_name_x{i})-2);
    end
end
grid_region_name_y{end+1} = str2_x;
grid_region_name_y = grid_region_name_y';
grid_region_index_y(end+1) = i+1;
grid_region_index_y = grid_region_index_y';
for i = 1:length(grid_region_name_y)
    if startsWith(grid_region_name_y{i}, 'Left')
        grid_region_name_y{i} = extractAfter(grid_region_name_y{i}, 5);
    end
    if startsWith(grid_region_name_y{i}, 'Right')
        grid_region_name_y{i} = extractAfter(grid_region_name_y{i}, 6);
    end
    if startsWith(grid_region_name_y{i}, 'l.') || startsWith(grid_region_name_y{i}, 'r.')
        grid_region_name_y{i} = extractAfter(grid_region_name_y{i}, 2);
    end
    if endsWith(grid_region_name_y{i}, '1') || endsWith(grid_region_name_y{i}, '2') ||...
            endsWith(grid_region_name_y{i}, '3') || endsWith(grid_region_name_y{i}, '4')
        grid_region_name_y{i} = extractBefore(grid_region_name_y{i}, strlength(grid_region_name_y{i})-2);
    end
end

% Define the new matrix
region_connection_matrix = zeros(length(grid_region_index_x), length(grid_region_index_y));
for i = 1:length(grid_region_index_x)
    for j = 1:length(grid_region_index_y)
        if i == 1 && j == 1
            submatrix = submap(1:grid_region_index_x(i),...
                1:grid_region_index_y(j));
        elseif i == 1
            submatrix = submap(1:grid_region_index_x(i),...
                grid_region_index_y(j-1)+1:grid_region_index_y(j));
        elseif j == 1
            submatrix = submap(grid_region_index_x(i-1)+1:grid_region_index_x(i),...
                1:grid_region_index_y(j));
        else
            submatrix = submap(grid_region_index_x(i-1)+1:grid_region_index_x(i),...
                grid_region_index_y(j-1)+1:grid_region_index_y(j));
        end
        
        avg_submatrix = sum(submatrix(:))/numel(submatrix);
        region_connection_matrix(i, j) = avg_submatrix;
    end
end

% Show the merged matrix
figure;
imagesc(region_connection_matrix');
% myColormap = [1 1 1; 0 1 1; 0 0 0; 0.4 0.4 1];
if hemisphere_type == 0
    title("Left cerebral hemisphere");
else
    title("Right cerebral hemisphere");
end
colorbar;
colormap sky;
axis equal;
axis tight;
yticks(1:length(grid_region_index_y));
yticklabels(grid_region_name_y);
xticks(1:length(grid_region_index_x));
xticklabels(grid_region_name_x);
set(gca, 'TickLength', [0 0]);
hold on;
% x = [0.5, length(grid_region_name_x)+0.5, length(grid_region_name_x)+0.5];
% y = [0.5, length(grid_region_name_y)+0.5, 0.5];
% fill(x, y, 'w', 'EdgeColor', 'none', 'FaceAlpha', 0.8);

for k = 0.5:1:length(grid_region_index_y)+0.5
    line(xlim, [k, k], 'Color', [0.7 0.7 0.7]);
end
for k = 0.5:1:length(grid_region_index_x)+0.5
    line([k, k], ylim, 'Color', [0.7 0.7 0.7]);
end
hold off;

% [table_left, table_right] = seizure_frequency();
% 
% [~, loc] = ismember(cellstr(table_left.LeftName), cellstr(grid_region_name));
% frequency_display = zeros(1, length(grid_region_name));
% table_left.LeftFrequency(1)
% for i = 1:length(loc)
%     frequency_display(loc(i)) = table_left.LeftFrequency(i);
% end
% figure;
% sum_connection = sum(region_connection_matrix);
% 
% x = sum_connection;
% y = frequency_display;
% scatter(x, y);
% xlabel('X array');
% ylabel('Y array');
% title('Scatter plot of X and Y');
% 
% R = corrcoef(x, y);
% 
% disp('Correlation coefficient between X and Y:');
% disp(R(1,2));
% 
% %% 
% load("data\left_lobe_truncations.mat");
% leftlobetruncation.Identifier = strcat(string(leftlobetruncation.before_tp), "_", string(leftlobetruncation.after_tp));
% [G, groups] = findgroups(leftlobetruncation.Identifier);
% sumValues = splitapply(@sum, leftlobetruncation.frequency, G);
% newT = table(groups, sumValues, 'VariableNames', {'Identifier', 'frequency'});
% for i = 1:height(newT)
%     idx = leftlobetruncation.Identifier == newT.Identifier(i);
%     leftlobetruncation.frequency(idx) = newT.frequency(i);
% end
% leftlobetruncation.Identifier = [];
