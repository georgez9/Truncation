function create_and_save_matter_connection_map(subMatrix, rowIndices, colIndices, rowLabels, colLabels, patient_ID, id, mapType, picturesPath)
    myColormap = [1 1 1; 1/255*255 1/255*255 1/255*0; 1/255*0 1/255*255 1/255*255; 1/255*0 1/255*255 1/255*0];
    
    % Create figure
    figure;
    set(gcf, 'Visible', 'off');
    imagesc(subMatrix);
    h = colorbar;
    set(h, 'Ticks', [0.5 1.5 2.5 3.5], 'TickLabels', {'none', 'grey matter', 'white matter', 'both'});
    clim([0 4]);
    colormap(myColormap);
    axis equal;
    axis tight;
    
    % Set ticks and labels
    xticks(1:length(colIndices));
    yticks(1:length(rowIndices));
    yticklabels(rowLabels);
    xticklabels(colLabels);
    
    % Draw the grid
    hold on;
    for k = 0.5:1:length(rowIndices)+0.5
        line(xlim, [k, k], 'Color', [0.6 0.6 0.6]);
    end
    for k = 0.5:1:length(colIndices)+0.5
        
        line([k, k], ylim, 'Color', [0.6 0.6 0.6]);
    end
    hold off;
    
    set(gca, 'YDir', 'normal');
    
    % Save the figure
    filename = sprintf('%s\\%d_%s_%s_matter_connection_map.png', picturesPath, id, patient_ID, mapType); 
    saveas(gcf, filename); 
end
