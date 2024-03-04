function [combined_matrix, combined_labels] = combine_left_right(matrix,labels,show_fig)
%COMBINE_LEFT_RIGHT combines left and right regions
%   returns a combined left right matrix, which will be the number of
%   regions by number of regions *2 representing same side connections and
%   opposite side connection 
%   |--------|--------|
%   |        |        |
%   |  same  |opposite|
%   |        |        |
%   |--------|--------|

    arguments
            matrix(:,:) {mustBeNumericOrLogical};
            labels(1,:) string;
            show_fig(1,1) logical =false;
    end

    if length(labels) ~= size(matrix,1) | length(labels) ~= size(matrix,2)
        throw 
    end
    n_regions = length(labels);
    % turn every value in matrix into row in a table
    connections_table = table('size',[n_regions*n_regions,3],...
        'VariableTypes',{'string','string','double'},...
        'VariableNames',{'from_name','to_name','value'});
    for i = 1:128
        for j = 1:128
            connections_table(i+128*(j-1),:) = {labels{i},labels{j},matrix(i,j)};
        end
    end
    % for every row get if it is going to and from the same hemisphere
    connections_table.from_right = contains(connections_table.from_name,"Right") | contains(connections_table.from_name,"r.");
    connections_table.to_right = contains(connections_table.to_name,"Right") | contains(connections_table.to_name,"r.");
    connections_table.same_side = connections_table.from_right == connections_table.to_right;
    % store the region without the hemisphere information
    connections_table.stripped_from = regexprep(connections_table.from_name,"Right-|r\.|Left-|l\.","");
    connections_table.stripped_to = regexprep(connections_table.to_name,"Right-|r\.|Left-|l\.","");
    % group the table by from to and whether it's the same side
    
    combined_table = groupsummary(connections_table,["stripped_from","stripped_to","same_side"],"sum","value");
    combined_labels = unique(connections_table.stripped_from,'stable');

    combined_matrix = NaN(length(combined_labels),length(combined_labels)*2);
    for from = 1:length(combined_labels)
        for to = 1:length(combined_labels)
            from_to =   strcmp(combined_table.stripped_from,combined_labels{from}) &...
                        strcmp(combined_table.stripped_to,combined_labels{to});
            if any(from_to & combined_table.same_side)
                combined_matrix(from,to) = combined_table.sum_value(from_to & combined_table.same_side);
            end
            if any(from_to & ~combined_table.same_side)
                combined_matrix(from,to+length(combined_labels)) = ...
                    combined_table.sum_value(from_to & ~combined_table.same_side);
            end
        end
    end
    if show_fig
        figure();imagesc(combined_matrix)
        yticks(1:length(combined_labels));
        yticklabels(combined_labels);
        xticks(1:length(combined_labels)*2)
        xticklabels(["same side " + combined_labels,"opposite side" + combined_labels])
    end
end

