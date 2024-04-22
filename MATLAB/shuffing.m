%% Load data
load('..\data\truncation_points_v2.mat');
load('..\data\matter_connections.mat');
addpath("functions\");
dba_daa_csvFilename = '..\data\dba_daa.csv';
conncetivity_csvFilename = '..\data\actual_connectivity.csv';
results_matFilename = '..\data\seizure_results.mat';
warning('off', 'MATLAB:table:RowsAddedExistingVars');

%% Can be changed as needed
cal_conncectivity_type = 'lcc';
permutation_type = 'pt'; % pr - permute regions(actually channels), pt - permute truncation points
permuted_times = 1; % if set 1, that means its actual conditions

%% Main function
matter_type_list = {'all', 'white', 'grey'};
if permuted_times == 1
    permutation_type = 'ac';
end

for select_matter_type = 1:3
    matter_type = matter_type_list{select_matter_type};
    connections_map_labels = matter_connections_with_labels.grey_matter_connections{:, 1};
    switch matter_type
        case 'all'
            connections_map = matter_connections_with_labels.grey_matter_connections{:, 2:129} + 2*matter_connections_with_labels.white_matter_connections{:, 2:129};
            connections_map(connections_map>0) = 1;
        case 'grey'
            connections_map = matter_connections_with_labels.grey_matter_connections{:, 2:129};
        case 'white'
            connections_map = matter_connections_with_labels.white_matter_connections{:, 2:129};
        otherwise
            error("Wrong matter tpye");
    end
    
    for i = 1:length(connections_map)
        connections_map(i, i) = 0;
    end
    
    % Handle with the channels
    n_seizures = size(truncated_seizures, 1);
    result_table = table();
    for id = 1:n_seizures
        result_table.id{id} = id;
        result_table.patient_ID{id} = truncated_seizures.patient_ID{id};
    
        channel_sequences = truncated_seizures.continuing_seizure{id};
        channel_labels = truncated_seizures.channel_ROI_labels{id};
        
        % shuffled list
        permuted_bf_list = zeros(permuted_times, 1);
        permuted_af_list = zeros(permuted_times, 1);
        permuted_ac_list = zeros(permuted_times, 1);
        permuted_dba_list = zeros(permuted_times, 1);
        permuted_daa_list = zeros(permuted_times, 1);
        permuted_bfaf_difference = zeros(permuted_times, 1);
    
        for j = 1:permuted_times
            % the first round of the loop don't permute
            % shuffle the channels
            if strcmp(permutation_type, 'pr') && j > 1
                channel_labels = channel_labels(randperm(length(channel_labels)));
            end
            
            truncation_point = int32(truncated_seizures.truncation_point{id});
            
            % This convert the eeg channels to the regions in the brain
            [region_sequences, region_labels] = channels_to_regions(channel_sequences, channel_labels, truncation_point);
            % display_the_sequences(id, region_sequences, region_labels, truncation_point, truncated_seizures.patient_ID{id}, generate_and_save_the_graph);
            
            result_table.region_sequences{id} = region_sequences;
            if strcmp(permutation_type, 'pr') && j > 1
                result_table.tp{id} = nan;
            else
                result_table.tp{id} = int32(truncated_seizures.truncation_point{id});
            end
            
            if strcmp(permutation_type, 'pt') && j > 1
                result_table.region_labels{id} = nan;
            else
                result_table.region_labels{id} = region_labels;
            end
            % Count the number of imprinted regions
            count_beforetp = length(find(region_sequences(:, truncation_point) > 0));
            count_aftertp = length(find(region_sequences(:, size(region_sequences, 2)) > 0)) - count_beforetp;
            
            % Find the regions
            before_pt_labels = region_labels(1:count_beforetp, 1);
            result_table.before_pt_labels{id} = before_pt_labels;
            [~, before_pt_idx] = ismember(before_pt_labels, connections_map_labels);
        
            after_pt_labels = region_labels(count_beforetp + 1:count_beforetp + count_aftertp, 1);
            result_table.after_pt_labels{id} = after_pt_labels;
            [~, after_pt_idx] = ismember(after_pt_labels, connections_map_labels);
            
            % shuffle the TP
            all_labels = [before_pt_labels; after_pt_labels];
            if strcmp(permutation_type, 'pt') && j > 1
                cut = randi([1, length(all_labels)], 1, 1);
                before_pt_labels = all_labels(1:cut, :);
                after_pt_labels = all_labels(cut+1:length(all_labels), :);
            end
            subclinical_labels = region_labels(count_beforetp + count_aftertp + 1:end, 1);
            
            % Find the connection matrix
            indices_before = find(ismember(connections_map_labels, before_pt_labels));
            indices_after = find(ismember(connections_map_labels, after_pt_labels));
            indices_others = find(ismember(connections_map_labels, subclinical_labels));
            indices_all = [indices_before; indices_after; indices_others];
        
            result_table.matrix{id} = connections_map(indices_all, indices_all);
            result_table.before_pt_matrix{id} = connections_map(indices_before, indices_before);
            result_table.after_pt_matrix{id} = connections_map(indices_after, indices_after);
            result_table.across_pt_matrix{id} = connections_map(indices_before, indices_after);
        
            % Calculate the connectivity of each seizure
            result_table = cal_connectivity(result_table, id, cal_conncectivity_type);
            permuted_bf_list(j) = result_table.connectivity_before_pt{id};
            permuted_af_list(j) = result_table.connectivity_after_pt{id};
            permuted_ac_list(j) = result_table.connectivity_across_pt{id};
            permuted_dba_list(j) = result_table.connectivity_before_pt{id} - result_table.connectivity_across_pt{id};
            permuted_daa_list(j) = result_table.connectivity_after_pt{id} - result_table.connectivity_across_pt{id};
    
        end
        result_table.connectivity_before_pt{id} = mean(permuted_bf_list, 'omitnan');
        result_table.connectivity_after_pt{id} = mean(permuted_af_list, 'omitnan');
        result_table.connectivity_across_pt{id} = mean(permuted_ac_list, 'omitnan');
        result_table.DBA{id} = mean(permuted_dba_list, 'omitnan');
        result_table.DAA{id} = mean(permuted_daa_list, 'omitnan');
        result_table.hemisphere{id} = decide_hemisphere_type(before_pt_labels, after_pt_labels);
        
    end


    % save conncetivity to .csv
    if strcmp(permutation_type, 'ac')
        conncectivity_csvTable = readtable(conncetivity_csvFilename);
        BTP_Data = result_table.connectivity_before_pt;
        ATP_Data = result_table.connectivity_after_pt;
        ACTP_Data = result_table.connectivity_across_pt;
        a = ['BTP_' matter_type];
        b = ['ATP_' matter_type];
        c = ['ACTP_' matter_type];
        conncectivity_csvTable.Id = result_table.id;
        conncectivity_csvTable.Patient = result_table.patient_ID;
        conncectivity_csvTable.Hemisphere = result_table.hemisphere;
        conncectivity_csvTable.(a) = result_table.connectivity_before_pt;
        conncectivity_csvTable.(b) = result_table.connectivity_after_pt;
        conncectivity_csvTable.(c) = result_table.connectivity_across_pt;
        writetable(conncectivity_csvTable, conncetivity_csvFilename);
    end
    
    % save DBA DAA to .csv
    dba_daa_csvTable = readtable(dba_daa_csvFilename);
    a = ['DBA_' matter_type '_' permutation_type];
    b = ['DAA_' matter_type '_' permutation_type];
    dba_daa_csvTable.(a) = result_table.DBA;
    dba_daa_csvTable.(b) = result_table.DAA;
    dba_daa_csvTable.hemisphere = result_table.hemisphere;
    writetable(dba_daa_csvTable, dba_daa_csvFilename);
    
    dba_daa_csvTable = readtable(dba_daa_csvFilename);

end

% save results to .mat
if strcmp(permutation_type, 'ac')
    save(results_matFilename, "result_table");
end

% plot dba daa
plot_dba_daa(dba_daa_csvTable);
