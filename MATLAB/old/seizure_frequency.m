function [frequency_table_left, frequency_table_right] = seizure_frequency()
    % Work with hemisphere_comparing_connection_map.m
    load('data\seizures_with_maps.mat');
    pre_trucated = new_table.region_labels_before_tp;
    pre_trucated_1 = {};
    for i = 1:size(pre_trucated, 1)
        for j = 1:size(pre_trucated{i}, 1)
            pre_trucated_1{end+1} = pre_trucated{i}{j};
        end
    end
    pre_trucated_1 = pre_trucated_1';
    
    pre_trucated_left = {};
    pre_trucated_right = {};
    
    for i = 1:length(pre_trucated_1)
        if startsWith(pre_trucated_1{i}, "l.") || startsWith(pre_trucated_1{i}, "Left")
            pre_trucated_left{end+1} = pre_trucated_1{i};
        elseif startsWith(pre_trucated_1{i}, "r.") || startsWith(pre_trucated_1{i}, "Right")
            pre_trucated_right{end+1} = pre_trucated_1{i};
        end
    end
    pre_trucated_left = pre_trucated_left';
    pre_trucated_right = pre_trucated_right';
    
    for i = 1:length(pre_trucated_left)
        if startsWith(pre_trucated_left{i}, 'Left')
            pre_trucated_left{i} = extractAfter(pre_trucated_left{i}, 5);
        end
        if startsWith(pre_trucated_left{i}, 'l.')
            pre_trucated_left{i} = extractAfter(pre_trucated_left{i}, 2);
        end
        if endsWith(pre_trucated_left{i}, '1') || endsWith(pre_trucated_left{i}, '2') ||...
                endsWith(pre_trucated_left{i}, '3') || endsWith(pre_trucated_left{i}, '4')
            pre_trucated_left{i} = extractBefore(pre_trucated_left{i}, strlength(pre_trucated_left{i})-1);
        end
    end
    
    for i = 1:length(pre_trucated_right)
        if startsWith(pre_trucated_right{i}, 'Right')
            pre_trucated_right{i} = extractAfter(pre_trucated_right{i}, 6);
        end
        if startsWith(pre_trucated_right{i}, 'r.')
            pre_trucated_right{i} = extractAfter(pre_trucated_right{i}, 2);
        end
        if endsWith(pre_trucated_right{i}, '1') || endsWith(pre_trucated_right{i}, '2') ||...
                endsWith(pre_trucated_right{i}, '3') || endsWith(pre_trucated_right{i}, '4')
            pre_trucated_right{i} = extractBefore(pre_trucated_right{i}, strlength(pre_trucated_right{i})-1);
        end
    end
    
    frequency_table_left = table();
    frequency_table_right = table();
    
    
    pre_trucated_right = sort(pre_trucated_right);
    [frequency_table_right.RightName, ~, ic] = unique(pre_trucated_right);
    frequency_table_right.RightFrequency = accumarray(ic, 1);
    pre_trucated_left = sort(pre_trucated_left);
    [frequency_table_left.LeftName, ~, ic] = unique(pre_trucated_left);
    frequency_table_left.LeftFrequency = accumarray(ic, 1);
end



