function display_the_sequences(id, sequences, labels, truncation_point, patient_id, save_graphs)
    if 0
        figure;
        set(gcf,'Visible','on');
        imagesc(sequences);
        myColormap = [1 1 1; 1/255*106 1/255*64 1/255*140; 1/255*204 1/255*169 1/255*76];
        colormap(myColormap);

        h = xline(double(truncation_point)+0.5, 'r', 'Truncation point', 'LineWidth', 3);
        h.LabelVerticalAlignment = 'bottom';
        h.FontSize = 20;
        % yticklabels(labels);
        yticks(1:size(labels, 1));
        yticklabels(1:length(labels)); 
        set(gca, 'TickLength', [0 0]);
        set(gca, 'XTick', []);
        % draw the truncation point line
        hold on;
        for k = 0.5:1:size(sequences, 2)+0.5  
            line(xlim, [k, k], 'Color', [0 0 0]);
        end
        hold off;
        % set(gca, 'YDir', 'normal');
        filename = sprintf('pictures_for_sorted_sequences\\%d_%s.png', id, patient_id); 
        saveas(gcf, filename); 
    end
end