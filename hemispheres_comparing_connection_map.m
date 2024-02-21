function hemispheres_comparing_connection_map(labels, maps)
    if nargin == 0
        load('data\matter_connections.mat');
        labels = matter_connections_with_labels.grey_matter_connections{:, 1}';
        % maps = matter_connections_with_labels.grey_matter_connections{:, 2:129} + 2*matter_connections_with_labels.white_matter_connections{:, 2:129};
        maps = matter_connections_with_labels.white_matter_connections{:, 2:129};
    end
    
    labels = replace(labels, '_', '\_');

    sublabel1 = {};
    sublabel1_index = [];
    for i = 1:length(labels)
        label = labels{i};
        if startsWith(label, 'l.')
            sublabel1{end+1} = label;
            sublabel1_index(end+1) = i;
        end
    end
    [sublabel1, sort1] = sort(sublabel1);
    sublabel1_index = sublabel1_index(sort1);
    submap1 = maps(sublabel1_index, sublabel1_index);

    sublabel2 = {};
    sublabel2_index = [];
    for i = 1:length(labels)
        label = labels{i};
        if startsWith(label, 'r.')
            sublabel2{end+1} = label;
            sublabel2_index(end+1) = i;
        end
    end
    [sublabel2, sort2] = sort(sublabel2);
    sublabel2_index = sublabel2_index(sort2);
    submap2 = maps(sublabel2_index, sublabel2_index);
    
    submap3 = submap1 - submap2;
    
    for i = 1:length(sublabel1)
        disp([sublabel1{i}, sublabel2{i}])
    end

    myColormap = [1 1 1; 0 1 1; 0 0 0; 1 0 0];

    figure;
    subplot(1,3,1);
    imagesc(submap1);
    colormap(myColormap);
    axis equal;
    axis tight;
    yticks(1:length(sublabel1));
    yticklabels(sublabel1);
    hold on; % draw grid
    for k = 0.5:1:length(sublabel1)+0.5
        line(xlim, [k, k], 'Color', [0.8 0.8 0.8]);
    end
    for k = 0.5:1:length(sublabel1)+0.5
        line([k, k], ylim, 'Color', [0.8 0.8 0.8]);
    end
    hold off;
    subplot(1,3,2);
    imagesc(submap2);
    colormap(myColormap);
    axis equal;
    axis tight;
    yticks(1:length(sublabel2));
    yticklabels(sublabel2);
    hold on; % draw grid
    for k = 0.5:1:length(sublabel2)+0.5
        line(xlim, [k, k], 'Color', [0.8 0.8 0.8]);
    end
    for k = 0.5:1:length(sublabel2)+0.5
        line([k, k], ylim, 'Color', [0.8 0.8 0.8]);
    end
    hold off;
    subplot(1,3,3);
    imagesc(submap3);
    colormap(myColormap);
    axis equal;
    axis tight;
        hold on; % draw grid
    for k = 0.5:1:length(sublabel2)+0.5
        line(xlim, [k, k], 'Color', [0.8 0.8 0.8]);
    end
    for k = 0.5:1:length(sublabel2)+0.5
        line([k, k], ylim, 'Color', [0.8 0.8 0.8]);
    end
    hold off;
end