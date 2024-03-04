function display_the_sequences(id, sequences, labels, truncation_point, patient_id, save_graphs)
    if save_graphs
        figure;
        set(gcf,'Visible','off');
        imagesc(sequences);
        myColormap = [1 1 1; 1/255*38 1/255*70 1/255*83; 1/255*233 1/255*196 1/255*107];
        colormap(myColormap);
        xline(double(truncation_point)+0.5, 'r', {'Truncation point'});
        yticks(1:size(labels, 1));
        yticklabels(labels);
        % draw the truncation point line
        hold on;
        for k = 0.5:1:size(sequences, 2)+0.5  
            line(xlim, [k, k], 'Color', [0.6 0.6 0.6]);
        end
        hold off;
        % set(gca, 'YDir', 'normal');
        filename = sprintf('pictures_for_sorted_sequences\\%d_%s.png', id, patient_id); 
        saveas(gcf, filename); 
    end
end