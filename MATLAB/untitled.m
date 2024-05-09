for i = 1:size(truncated_seizures, 1)
    truncated_seizures.id{i} = i;
end


id = cell2mat(truncated_seizures.id);
id = num2cell(id);
truncation_point = truncated_seizures.truncation_point;
patient_id = truncated_seizures.patient_ID;
channel_ROI_labels = truncated_seizures.channel_ROI_labels;
truncated_seizure = truncated_seizures.truncated_seizure;
continuing_seizure = truncated_seizures.continuing_seizure;


data = table(id, patient_id, truncation_point, channel_ROI_labels,...
    truncated_seizure, continuing_seizure);
jsonStr = jsonencode(data);

fid = fopen('truncated_seizures.json', 'w', 'n', 'UTF-8');
if fid == -1
    error('File cannot be opened');
end

fprintf(fid, '%s', jsonStr);

fclose(fid);
