% load("data\seizures_with_maps.mat");
function new_table = connection_ratio(new_table, i)
    new_table.connection_rate_before_tp{i} = mean(calculateConnectionRates(new_table.region_connections_before_tp{i}));
    new_table.connection_rate_after_tp{i} = mean(calculateConnectionRates(new_table.region_connections_after_tp{i}));
    length1 = length(new_table.region_labels_before_tp{i});
    length2 = length(new_table.region_labels_after_tp{i});
    if length1>0 || length2>0
        new_table.connectivity_across_tp{i} = connectedRatio(...
            new_table.region_connections_all{i},...
            1:length1,...
            (length1+1):(length1+length2) ...
            );
    else
        new_table.connectivity_across_tp{i} = NaN;
    end
end


%% 

function connectionRates = calculateDirectConnectionRates(adjMatrix)
    n = size(adjMatrix, 1);
    connectionRates = zeros(1, n);
    for i = 1:n
        connectionRates(i) = (sum(adjMatrix(i,:) > 0) - (adjMatrix(i,i) > 0)) / (n - 1);
    end
end


function connectionRates = calculateConnectionRates(adjMatrix)
    n = size(adjMatrix, 1); 
    connectionRates = zeros(1, n); 
    visited = false(1, n); 

    for i = 1:n
        dfs(i); 
        connectionRates(i) = (sum(visited) - 1) / (n - 1); 
        visited(:) = false;
    end

    function dfs(node)
        visited(node) = true; 
        for j = 1:length(visited)
            if adjMatrix(node, j) > 0 && ~visited(j) 
                dfs(j);
            end
        end
    end
end
function ratio = connectedRatio(matrix, a, b)

    n = size(matrix, 1); 
    visited = false(1, n); 
    queue = []; 
    
    for i = 1:length(a)
        if ~visited(a(i))
            queue(end+1) = a(i);
            while ~isempty(queue)
                node = queue(1);
                queue(1) = [];
                visited(node) = true;
                for j = 1:n
                    if matrix(node, j) > 0 && ~visited(j)
                        queue(end+1) = j;
                    end
                end
            end
        end
    end
    
    connectedCount = 0;
    for i = 1:length(b)
        if visited(b(i))
            connectedCount = connectedCount + 1;
        end
    end
    
    ratio = connectedCount / length(b);
end
