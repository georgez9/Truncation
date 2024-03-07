%% Load data
load('data\truncation_points_v2.mat');
load('data\matter_connections.mat');

warning('off', 'MATLAB:table:RowsAddedExistingVars');

%% Decide which kind of matter to analyse
matter_type = 0; % 0 - all matters, 1 - grey matters, 2 - white matters
permutation_type = 0; % 1 - permute channels, 0 - permute truncation points
permuted_times = 100;

table_for_plot = table();
table_for_plot.Value{1} = 0;
table_for_plot.Region{1} = "";
table_for_plot.Type{1} = "";

connections_map_labels = matter_connections_with_labels.grey_matter_connections{:, 1};
switch matter_type
    case 0
        connections_map = matter_connections_with_labels.grey_matter_connections{:, 2:129} + 2*matter_connections_with_labels.white_matter_connections{:, 2:129};
    case 1
        connections_map = matter_connections_with_labels.grey_matter_connections{:, 2:129};
    case 2
        connections_map = matter_connections_with_labels.white_matter_connections{:, 2:129};
    otherwise
        error("Wrong matter tpye");
end

%% Handle with the channels
generate_and_save_the_graph = false; % true, false
number_of_patients = size(truncated_seizures, 1);
channel_truns = {};
connectivity_table = table();
for id = 1:number_of_patients
% for id = 2
    connectivity_table.id{id} = id;
    connectivity_table.patient_ID{id} = truncated_seizures.patient_ID{id};

    channel_sequences = truncated_seizures.continuing_seizure{id};
    channel_labels = truncated_seizures.channel_ROI_labels{id};
    
    % This step shuffles the channels
    permuted_bf_rate = zeros(permuted_times, 1);
    permuted_af_rate = zeros(permuted_times, 1);
    permuted_ac_rate = zeros(permuted_times, 1);
    permuted_bfaf_difference = zeros(permuted_times, 1);

    for j = 1:permuted_times
        if permutation_type == 1 && j > 1
            channel_labels = channel_labels(randperm(length(channel_labels)));
        end
        
        truncation_point = int8(truncated_seizures.truncation_point{id});

        if permutation_type == 0 && j > 1
            length_of_the_time_series = size(channel_sequences, 2);
            truncation_point = randi([1, length_of_the_time_series-1], 1, 1);
        end
        
        [region_sequences, region_labels] = channels_to_regions(channel_sequences, channel_labels, truncation_point);
        % region_labels = region_labels(randperm(length(region_labels)));
        % Display_the_sequences(id, region_sequences, region_labels, truncation_point, truncated_seizures.patient_ID{id}, generate_and_save_the_graph);
        
        connectivity_table.tp{id} = int8(truncated_seizures.truncation_point{id});
        connectivity_table.region_sequences{id} = region_sequences;
        connectivity_table.region_labels{id} = region_labels;
    
        % Count the number of activiated regions
        count_beforetp = length(find(region_sequences(:, truncation_point) >= 1));
        count_aftertp = length(find(region_sequences(:, size(region_sequences, 2)) >= 1)) - count_beforetp;
        text1 = sprintf("There are %d implanted regions in seizure %d, %d before tp, %d after tp", ...
            size(region_sequences, 1), id, count_beforetp, count_aftertp);
        %disp(text1);
        
        % Find the regions
        truncated_seizures.before_tp{id} = region_labels(1:count_beforetp, 1);
        connectivity_table.region_labels_before_tp{id} = truncated_seizures.before_tp{id};
        [~, region_id_in_the_map_1] = ismember(truncated_seizures.before_tp{id}, connections_map_labels);
    
        truncated_seizures.after_tp{id} = region_labels(count_beforetp+1:count_beforetp+count_aftertp, 1);
        connectivity_table.region_labels_after_tp{id} = truncated_seizures.after_tp{id};
        [~, region_id_in_the_map_2] = ismember(truncated_seizures.after_tp{id}, connections_map_labels);
    
        region_id_in_the_map_all = [region_id_in_the_map_1; region_id_in_the_map_2];
        [~, region_id_new_table] = ismember(region_labels, connections_map_labels);
    
        % Find the connection matrix
        indices_before = find(ismember(connections_map_labels, truncated_seizures.before_tp{id}));
        indices_after = find(ismember(connections_map_labels, truncated_seizures.after_tp{id}));
        indices_all = [indices_before; indices_after];
    
        a2a_subMatrix = connections_map(indices_before, indices_before);
        b2b_subMatrix = connections_map(indices_after, indices_after);
        a2b_subMatrix = connections_map(indices_before, indices_after);
        all_subMatrix = connections_map(indices_all, indices_all);
    
        % Delete self connection
        for i = 1:length(indices_before)
            a2a_subMatrix(i, i) = 0;
        end
        for i = 1:length(indices_after)
            b2b_subMatrix(i, i) = 0;
        end
        for i = 1:length(indices_all)
            all_subMatrix(i, i) = 0;
        end
    
        connectivity_table.region_connections_before_tp{id} = a2a_subMatrix;
        connectivity_table.region_connections_after_tp{id} = b2b_subMatrix;
        connectivity_table.region_connections_all{id} = all_subMatrix;
    
        % Calculate the connectivity of each seizure
        connectivity_table = connection_ratio(connectivity_table, id);
        permuted_bf_rate(j) = connectivity_table.connection_rate_before_tp{id};
        permuted_af_rate(j) = connectivity_table.connection_rate_after_tp{id};
        permuted_ac_rate(j) = connectivity_table.connectivity_across_tp{id};
        permuted_bfaf_difference(j) = connectivity_table.connection_rate_before_tp{id} - connectivity_table.connection_rate_after_tp{id};

    end
    connectivity_table.connection_rate_before_tp{id} = mean(permuted_bf_rate, 'omitnan');
    connectivity_table.connection_rate_after_tp{id} = mean(permuted_af_rate, 'omitnan');
    connectivity_table.connectivity_across_tp{id} = mean(permuted_ac_rate, 'omitnan');
    connectivity_table.connection_difference{id} = mean(permuted_bfaf_difference, 'omitnan');
    
    table_for_plot.Value{end+1} = permuted_bf_rate(1);
    table_for_plot.Region{end} = "before_TP";
    table_for_plot.Type{end} = "Actual";
    table_for_plot.Value{end+1} = permuted_af_rate(1);
    table_for_plot.Region{end} = "after_TP";
    table_for_plot.Type{end} = "Actual";
    table_for_plot.Value{end+1} = permuted_ac_rate(1);
    table_for_plot.Region{end} = "across_TP";
    table_for_plot.Type{end} = "Actual";

    table_for_plot.Value{end+1} = connectivity_table.connection_rate_before_tp{id};
    table_for_plot.Region{end} = "before_TP";
    table_for_plot.Type{end} = "Permuted";
    table_for_plot.Value{end+1} = connectivity_table.connection_rate_after_tp{id};
    table_for_plot.Region{end} = "after_TP";
    table_for_plot.Type{end} = "Permuted";
    table_for_plot.Value{end+1} = connectivity_table.connectivity_across_tp{id};
    table_for_plot.Region{end} = "across_TP";
    table_for_plot.Type{end} = "Permuted";
end
table_for_plot(1, :) = [];
writetable(table_for_plot, "Python\permutation.csv");


