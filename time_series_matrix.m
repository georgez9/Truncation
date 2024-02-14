%% load data
load('data\truncation_points_v2.mat');
load('data\matter_connections.mat');

%% decide which kind of matter to analyse
matter_type = 0; % 0 - all matters, 1 - grey matters, 2 - white matters
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

%% display the connnection map
show_connection_map = 'off'; % 'on', 'off'
figure;
set(gcf,'Visible', show_connection_map);
imagesc(connections_map);
axis equal;
xticks(1:length(connections_map_labels));
yticks(1:length(connections_map_labels));
xticklabels(connections_map_labels);
yticklabels(connections_map_labels);
title('Connection map');

%% handle with the channels
generate_and_save_the_graph = false; % true, false
number_of_patients = size(truncated_seizures, 1);
channel_truns = {};
for id = 1:number_of_patients
% for id = 1
    channel_sequences = truncated_seizures.continuing_seizure{id};
    channel_labels = truncated_seizures.channel_ROI_labels{id};
    truncation_point = int8(truncated_seizures.truncation_point{id});
    [region_sequences, region_labels] = channels_to_regions(channel_sequences, channel_labels, truncation_point);
    display_the_sequences(id, region_sequences, region_labels, truncation_point, truncated_seizures.patient_ID{id}, generate_and_save_the_graph);
    
    % count the number of activiated regions
    count_beforetp = length(find(region_sequences(:, truncation_point) >= 1));
    count_aftertp = length(find(region_sequences(:, size(region_sequences, 2)) >= 1));
    
    % find the regions
    truncated_seizures.before_tp{id} = region_labels(1:count_beforetp, 1);
    truncated_seizures.after_tp{id} = region_labels(count_beforetp+1:count_aftertp, 1);

    % find the connection matrix
    rowIndices_before = find(ismember(connections_map_labels, truncated_seizures.before_tp{id}));
    colIndices_after = find(ismember(connections_map_labels, truncated_seizures.after_tp{id}));
    a2a_subMatrix = connections_map(rowIndices_before, rowIndices_before);
    b2b_subMatrix = connections_map(colIndices_after, colIndices_after);
    a2b_subMatrix = connections_map(rowIndices_before, colIndices_after);
    
    % delete self connection
    for i = 1:length(rowIndices_before)
        a2a_subMatrix(i, i) = 0;
    end
    for i = 1:length(colIndices_after)
        b2b_subMatrix(i, i) = 0;
    end

    % calculate the connection percentage of each seizure
    truncated_seizures.before_tp_contiguous{id} = calculate_percentage_of_connectivity(a2a_subMatrix);
    truncated_seizures.after_tp_contiguous{id} = calculate_percentage_of_connectivity(b2b_subMatrix);
    truncated_seizures.truncation_tp_contiguous{id} = calculate_percentage_of_connectivity(a2b_subMatrix);
    
    % calculate CDP and CDN
    if ~isnan(truncated_seizures.truncation_tp_contiguous{id})
        if ~isnan(truncated_seizures.before_tp_contiguous{id})
            truncated_seizures.CDP{id} = truncated_seizures.before_tp_contiguous{id} - truncated_seizures.truncation_tp_contiguous{id};
        else
            truncated_seizures.CDP{id} = NaN; 
        end
        if ~isnan(truncated_seizures.after_tp_contiguous{id})
            truncated_seizures.CDN{id} = truncated_seizures.after_tp_contiguous{id} - truncated_seizures.truncation_tp_contiguous{id};
        else
            truncated_seizures.CDN{id} = NaN;
        end
    else
       truncated_seizures.CDN{id} = NaN; 
       truncated_seizures.CDP{id} = NaN; 
    end
    
    if generate_and_save_the_graph
        create_and_save_matter_connection_map(a2b_subMatrix, rowIndices_before, colIndices_after, truncated_seizures.before_tp{id}, truncated_seizures.after_tp{id}, truncated_seizures.patient_ID{id}, id, 'a2a', 'pictures_for_sorted_sequences');
        create_and_save_matter_connection_map(a2b_subMatrix, rowIndices_before, colIndices_after, truncated_seizures.before_tp{id}, truncated_seizures.after_tp{id}, truncated_seizures.patient_ID{id}, id, 'b2b', 'pictures_for_sorted_sequences');
        create_and_save_matter_connection_map(a2b_subMatrix, rowIndices_before, colIndices_after, truncated_seizures.before_tp{id}, truncated_seizures.after_tp{id}, truncated_seizures.patient_ID{id}, id, 'a2b', 'pictures_for_sorted_sequences');
        fprintf('Seizure%d is handled.\n', id);
    end

    %% permutation
    permutation_times = 1000;
    permutatioin_results = zeros(permutation_times, 3);
    for j = 1:permutation_times
        random_regions_bf = randperm(128, count_beforetp);
        random_regions_af = randperm(128, count_aftertp-count_beforetp);
        a2a_subMatrix_permutation = connections_map(random_regions_bf, random_regions_bf);
        b2b_subMatrix_permutation = connections_map(random_regions_af, random_regions_af);
        a2b_subMatrix_permutation = connections_map(random_regions_bf, random_regions_af);
        for i = 1:length(rowIndices_before)
            a2a_subMatrix_permutation(i, i) = 0;
        end
        for i = 1:length(colIndices_after)
            b2b_subMatrix_permutation(i, i) = 0;
        end
        permutatioin_results(j, 1) = calculate_percentage_of_connectivity(a2a_subMatrix_permutation);
        permutatioin_results(j, 2) = calculate_percentage_of_connectivity(b2b_subMatrix_permutation);
        permutatioin_results(j, 3) = calculate_percentage_of_connectivity(a2b_subMatrix_permutation);
    end
    truncated_seizures.permutation_before_tp_contiguous{id} = mean(permutatioin_results(:, 1));
    truncated_seizures.permutation_after_tp_contiguous{id} = mean(permutatioin_results(:, 2));
    truncated_seizures.permutation_truncation_tp_contiguous{id} = mean(permutatioin_results(:, 3));
    
    if ~isnan(truncated_seizures.permutation_truncation_tp_contiguous{id})
        if ~isnan(truncated_seizures.permutation_before_tp_contiguous{id})
            truncated_seizures.permutation_CDP{id} = truncated_seizures.permutation_before_tp_contiguous{id} - truncated_seizures.permutation_truncation_tp_contiguous{id};
        else
            truncated_seizures.permutation_CDP{id} = NaN; 
        end
        if ~isnan(truncated_seizures.permutation_after_tp_contiguous{id})
            truncated_seizures.permutation_CDN{id} = truncated_seizures.permutation_after_tp_contiguous{id} - truncated_seizures.permutation_truncation_tp_contiguous{id};
        else
            truncated_seizures.permutation_CDN{id} = NaN;
        end
    else
       truncated_seizures.permutation_CDN{id} = NaN; 
       truncated_seizures.permutation_CDP{id} = NaN; 
    end
end

% The contiguous percentage of all seizures
print_contiguous_percentage(truncated_seizures, 'before_tp_contiguous', 'before');
print_contiguous_percentage(truncated_seizures, 'after_tp_contiguous', 'after');
print_contiguous_percentage(truncated_seizures, 'truncation_tp_contiguous', 'across');

% for the seizures
plot_connectivity_differences(truncated_seizures.CDP, truncated_seizures.CDN, 'Connectivity Differences in Seizures');
plot_connectivity_differences(truncated_seizures.permutation_CDP, truncated_seizures.permutation_CDN, 'Permutation Connectivity Differences in Seizures');

% for each patient
unique_patient = unique(truncated_seizures.patient_ID);
patient_table = table(cell(length(unique_patient), 1), zeros(length(unique_patient), 1), zeros(length(unique_patient), 1), 'VariableNames', {'patient_id', 'CDP', 'CDN'});
for i = 1:length(unique_patient)
    name = unique_patient{i};
    cdp_values = truncated_seizures.CDP(strcmp(truncated_seizures.patient_ID, name));
    isNum = cellfun(@isnumeric, cdp_values);
    cdp_values = cdp_values(isNum);
    if isempty(cdp_values)
        avg_cdp_value = NaN;
    else
        avg_cdp_value = mean(cell2mat(cdp_values));
    end
    
    cdn_values = truncated_seizures.CDN(strcmp(truncated_seizures.patient_ID, name));
    isNum = cellfun(@isnumeric, cdn_values);
    cdn_values = cdn_values(isNum);
    if isempty(cdn_values)
        avg_cdn_value = NaN;
    else
        avg_cdn_value = mean(cell2mat(cdn_values));
    end

    patient_table.patient_id{i} = name;
    patient_table.CDP(i) = avg_cdp_value;
    patient_table.CDN(i) = avg_cdn_value;
end
plot_connectivity_differences(patient_table.CDP, patient_table.CDN, 'Connectivity Differences in Patients');


