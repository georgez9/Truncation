%% save seizure regions to .csv files for Python analysis
warning('off', 'MATLAB:table:RowsAddedExistingVars');
addpath('..\data\');
write_filename = '..\data\seizure_regions.csv';
load('seizure_results.mat');
%% 
varNames = {'PatientID','TP','Labels', 'LabelsBeforeTP', 'LabelsAfterTP'};
regions_table = table('Size', [0, 5],...
    'VariableTypes',{'string','int8','string', 'string','string'}, 'VariableNames',varNames);
for i  = 1:height(result_table)
    per_seizure_region_number = length(result_table.region_labels{i});
    regions_table_end = height(regions_table)+1;
    regions_table.ID(regions_table_end: regions_table_end+per_seizure_region_number-1) = repmat(result_table.id{i}, per_seizure_region_number, 1);
    regions_table.PatientID(regions_table_end: regions_table_end+per_seizure_region_number-1) = repmat(result_table.patient_ID{i}, per_seizure_region_number, 1);
    regions_table.Hemisphere(regions_table_end: regions_table_end+per_seizure_region_number-1) = repmat(result_table.hemisphere{i}, per_seizure_region_number, 1);
    regions_table.Labels(regions_table_end: regions_table_end+per_seizure_region_number-1) = result_table.region_labels{i};
    regions_table.LabelsBeforeTP(regions_table_end:regions_table_end+length(result_table.before_pt_labels{i})-1) = result_table.before_pt_labels{i};
    regions_table.LabelsAfterTP(regions_table_end:regions_table_end+length(result_table.after_pt_labels{i})-1) = result_table.after_pt_labels{i};
end


writetable(regions_table, write_filename);
