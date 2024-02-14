function print_contiguous_percentage(truncated_seizures, field, name)
    valid_seizure_count_1 = 0;
    valid_seizure_count_0 = 0;
    for i = 1:height(truncated_seizures)
        if truncated_seizures.(field){i} == 1
            valid_seizure_count_1 = valid_seizure_count_1 + 1;
        elseif truncated_seizures.(field){i} < 1
            valid_seizure_count_0 = valid_seizure_count_0 + 1;
        end
    end
    percentage = valid_seizure_count_1 / (valid_seizure_count_1 + valid_seizure_count_0) * 100;
    fprintf('%.2f%% of onset regions %s truncation point are contiguous.\n', percentage, name);
end