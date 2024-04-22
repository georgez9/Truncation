% load("data\seizures_with_maps.mat");
%% main function
function new_table = cal_connectivity(new_table, i, type)
    if type == "lcc"
        new_table.connectivity_before_pt{i} = inner_connectivity(new_table.before_pt_matrix{i});
        new_table.connectivity_after_pt{i} = inner_connectivity(new_table.after_pt_matrix{i});
        new_table.connectivity_across_pt{i} = inter_connectivity(new_table.across_pt_matrix{i});
    elseif type == "gd"
        new_table.connectivity_before_pt{i} = inner_density(new_table.before_pt_matrix{i});
        new_table.connectivity_after_pt{i} = inner_density(new_table.after_pt_matrix{i});
        new_table.connectivity_across_pt{i} = inter_density(new_table.across_pt_matrix{i});
    end
end


%% connectivity in one map
function connectivity = inner_connectivity(matrix)
    if size(matrix, 1) <= 1
        connectivity = nan;
        return;
    end
    n = size(matrix, 1); 
    visited = false(1, n); 
    connectivity = 0;

    for i = 1:n
        if ~visited(i)
            component_size = dfs(i);
            if component_size > connectivity
                connectivity = component_size;
            end
        end
    end

    connectivity = connectivity / n;

    function size = dfs(node)
        visited(node) = true; 
        size = 1;
        for j = 1:length(visited)
            if matrix(node, j) > 0 && ~visited(j) 
                size = size + dfs(j);
            end
        end
    end
end

function density = inner_density(matrix)
    if size(matrix, 1) > 1
        count = sum(matrix,"all");
        density = count / (size(matrix, 1)*(size(matrix, 1)-1));
    else
        density = nan;
    end
end

%% connectivity between two maps
function connectivity = inter_connectivity(matrix)
    if size(matrix, 1) == 0 || size(matrix, 2) == 0
        connectivity = nan;
        return;
    end
    n = size(matrix, 1) + size(matrix, 2);
    zeroRows = sum(all(matrix == 0, 2));
    zeroCols = sum(all(matrix == 0, 1));
    connectivity = 1 - (zeroCols + zeroRows) / n;
end

function density = inter_density(matrix)
    if size(matrix, 1) > 0 && size(matrix, 2) > 0
        count = sum(matrix,"all");
        density = count / (size(matrix, 1)*size(matrix, 2));
    else 
        density = nan;
    end
end