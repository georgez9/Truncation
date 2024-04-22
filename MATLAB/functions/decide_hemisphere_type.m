% return the hemisphere that the seizure took place
% left, right, both
function type = decide_hemisphere_type(labels1, labels2)
    labels = [labels1; labels2]';
    if ~isempty(labels)
        left_right = [0 0];
        for i  = 1:length(labels)
            if startsWith(labels(i), "l.") || startsWith(labels(i), "Left")
                left_right(1) = 1;
            elseif startsWith(labels(i), "r.") || startsWith(labels(i), "Right")
                left_right(2) = 1;
            end
        end
        if left_right(1) == 1 && left_right(2) == 1
            type = "both";
        elseif left_right(1) == 1
            type = "left";
        elseif left_right(2) == 1
            type = "right";
        else
            type = "error";
        end
    else
        type = "missing";
    end
end