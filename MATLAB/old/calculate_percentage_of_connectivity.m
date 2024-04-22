function result = calculate_percentage_of_connectivity(matrix)
    if length(matrix) == 1 || isempty(matrix)
        result = NaN;
    else
        count = 0;
        for j = 1:size(matrix, 2)
            if all(matrix(:, j) == 0)
                count = count + 1;
            end
        end
        result = 1 - count/size(matrix, 2);
    end
end