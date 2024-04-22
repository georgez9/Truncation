function [merged_sequences, merged_labels] = channels_to_regions(sequences, labels, truncation_point)
% This function maps channels to actual regions for better analysis
    unique_labels = unique(labels);
    numCols = size(sequences, 2);
    merged_sequences = zeros(length(unique_labels), numCols);

    for i = 1:length(unique_labels)
        label = unique_labels(i);
        idx = labels == label;
        merged_sequences(i, :) = any(sequences(idx, :), 1);
    end
    merged_labels = unique_labels;
    % sort by onset time
    onset_time = zeros(size(unique_labels));

    for i = 1:length(unique_labels)
        onset_time(i) = size(merged_sequences, 2) + 1;
        set_flag = false;
        for j = 1:size(merged_sequences, 2)
            if merged_sequences(i, j) == 1
                if set_flag == false
                onset_time(i) = j;
                merged_sequences(i, j:size(merged_sequences, 2)) = 1;
                set_flag = true;
                end
                if j <= truncation_point
                    merged_sequences(i, j) = 2;
                else
                    break
                end
            end
        end
    end
    
    [~, sort_order] = sort(onset_time, 'descend');

    merged_sequences = merged_sequences(sort_order, :);
    merged_labels = merged_labels(sort_order);
    merged_sequences = flipud(merged_sequences);
    merged_labels = flipud(merged_labels);
end