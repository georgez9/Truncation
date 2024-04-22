load(fullfile('..', 'data', 'seizure_results.mat'), 'result_table');
addpath(fullfile('functions'));
%% 
path = fullfile('pictures','simple_brain_plot_figures');
disp(path);
tp_table = table();

% there is a bug while looping ,so I specify the id directly
% so there can only be one "plot_pretruncated_regions" functions in the progarm
seizure_id = 1;

for i = 1:size(result_table, 1)
    bf_labels = result_table.before_pt_labels{i};
    bf_labels = change_region_names(bf_labels);
    af_labels = result_table.after_pt_labels{i};
    af_labels = change_region_names(af_labels);
    all_labels = [bf_labels; af_labels];
    tp_table.id{i} = i;
    tp_table.bf_tp{i} = bf_labels;
    tp_table.af_tp{i} = af_labels;
    tp_table.all_tp{i} = all_labels;
end

% plot_pretruncated_regions(tp_table.all_tp{seizure_id}, [ones(size(tp_table.bf_tp{seizure_id}, 1), 1); ones(size(tp_table.af_tp{seizure_id}, 1), 1)*2]);

%% count frequency
% regions_list = [];
% for i = 1:size(tp_table, 1)
%     regions_list = [regions_list; tp_table.bf_tp{i}];
% end
% [uniqueStr, ~, idx] = unique(regions_list);
% counts = histcounts(idx, 1:numel(uniqueStr)+1)';
% plot_pretruncated_regions(uniqueStr, counts);
% plot_bar(uniqueStr, counts, 'frequency_rank');

%% count nearest tp regions
% nearest_tp_region = [];
% for i = 1:size(tp_table, 1)
%     nearest_tp_region = [nearest_tp_region; tp_table.bf_tp{i}(end)];
% end
% [uniqueStr, ~, idx] = unique(nearest_tp_region);
% counts = histcounts(idx, 1:numel(uniqueStr)+1)';
% plot_pretruncated_regions(uniqueStr, counts);
% plot_bar(uniqueStr, counts, 'nearest_frequency_rank');

%% weigh the distance for every pre_tp regions to the tp
% 1 - close, 0 - far
weights = [];
labels_array = [];
for i = 1:size(tp_table, 1)
    seizure_size = size(tp_table.bf_tp{i}, 1);
    weight_array = linspace(0.1, 1, seizure_size)';
    labels_array = [labels_array; tp_table.bf_tp{i}];
    weights = [weights; weight_array];
end
[uniqueStr, ~, idx] = unique(labels_array);
totalWeights = zeros(length(uniqueStr), 1);

for i = 1:length(labels_array)
    totalWeights(idx(i)) = totalWeights(idx(i)) + weights(i);
end
totalWeights = totalWeights/max(totalWeights);
plot_pretruncated_regions(uniqueStr, totalWeights);
plot_bar(uniqueStr, totalWeights, 'weighed_frequency_rank');


function labels = change_region_names(labels)
    for j = 1:size(labels, 1)
        labels(j) = regexprep(labels(j), 'l\.', 'ctx-lh-');
        labels(j) = regexprep(labels(j), 'r\.', 'ctx-rh-');
    end
end

function plot_bar(strArray, counts, path)
    rh_mask = startsWith(strArray, "ctx-rh") | startsWith(strArray, "Right");
    lh_mask = startsWith(strArray, "ctx-lh") | startsWith(strArray, "Left");
    
    rh_strArray = strArray(rh_mask);
    rh_counts = counts(rh_mask);
    
    lh_strArray = strArray(lh_mask);
    lh_counts = counts(lh_mask);
    
    [rh_sortedCounts, rh_idx] = sort(rh_counts, 'descend');
    rh_topStrArray = rh_strArray(rh_idx(1:min(10, length(rh_idx))));
    rh_topCounts = rh_sortedCounts(1:min(10, length(rh_sortedCounts)));
    
    [lh_sortedCounts, lh_idx] = sort(lh_counts, 'descend');
    lh_topStrArray = lh_strArray(lh_idx(1:min(10, length(lh_idx))));
    lh_topCounts = lh_sortedCounts(1:min(10, length(lh_sortedCounts)));

    rh_topStrArray = replace(rh_topStrArray, "ctx-rh-", "Right-");
    lh_topStrArray = replace(lh_topStrArray, "ctx-lh-", "Left-");
    rh_topStrArray = replace(rh_topStrArray, "_", "\_");
    lh_topStrArray = replace(lh_topStrArray, "_", "\_");
        
    fig = figure('Position', [100, 100, 1000, 400]);
    subplot(1,2,1);
    bar(rh_topCounts);
    xticks(1:length(rh_topCounts));
    xticklabels(rh_topStrArray);
    xtickangle(45);
    title('Top 10 Frequent Elements: ctx-rh');
    xlabel('Elements');
    ylabel('Frequency');
    
    subplot(1,2,2);
    bar(lh_topCounts);
    xticks(1:length(lh_topCounts));
    xticklabels(lh_topStrArray);
    xtickangle(45);
    title('Top 10 Frequent Elements: ctx-lh');
    xlabel('Elements');
    ylabel('Frequency');
    ylim([0 max(counts)])
    path = fullfile('pictures', 'simple_brain_plot_figures', [path, '.svg']);
    saveas(fig, path, 'svg');
end