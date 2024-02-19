function draw_connection_circle(id, patient_ID, matter_connection_matrix, seizure_connection_matrix, seizure_1, seizure_1_labels, seizure_2, seizure_2_labels)
    N = 128;
    
    theta = linspace(0, 2*pi, N+1);
    theta(end) = [];
    x = cos(theta);
    y = sin(theta);
    
    % test matrix
    % matter_connection_matrix = zeros(N, N);
    % matter_connection_matrix(1, 14) = 1; 
    % matter_connection_matrix(23, 104) = 2;
    % matter_connection_matrix(63, 84) = 3;
    % 
    % seizure_1 = [1, 14, 35, 3];
    % seizure_2 = [5, 8, 12];
    % seizure_1_labels = ["add" 'b' 'cs' 'd'];
    % seizure_2_labels = ['i' 'j' 'm'];

    figure;
    set(gcf, 'Visible', 'off');
    set(gcf, 'Color', [1, 1, 1]);
    axis equal;
    axis off;
    hold on;
    
    for i = 1:N
        plot(x(i), y(i), 'o', 'MarkerEdgeColor', [0.8, 0.8, 0.8], 'MarkerFaceColor', 'none');
    end

    % seperate so they won't overlap
    for i = 1:N
        for j = 1:N
            if matter_connection_matrix(i, j) == 2
                plot([x(i) x(j)], [y(i) y(j)], 'Color', [254, 255, 223]/255, 'LineWidth', 6);
            end
        end
    end

    for i = 1:N
        for j = 1:N
            if matter_connection_matrix(i, j) == 1
                plot([x(i) x(j)], [y(i) y(j)], 'Color', [223, 254, 255]/255, 'LineWidth', 6);
            end
        end
    end

    for i = 1:N
        for j = 1:N
            if matter_connection_matrix(i, j) == 3
                plot([x(i) x(j)], [y(i) y(j)], 'Color', [238, 255, 223]/255, 'LineWidth', 6);
            end
        end
    end

    for i = 1:N
        for j = 1:N
            if seizure_connection_matrix(i, j) > 0
                plot([x(i) x(j)], [y(i) y(j)], 'Color', 'r', 'LineWidth', 1);
            end
        end
    end
    
    for i = 1:size(seizure_1, 2)
        onset = seizure_1(i);
        plot(x(onset), y(onset), 'o', 'MarkerEdgeColor', [0, 0, 0], 'MarkerFaceColor', [1, 0.5, 0.5]);
        if x(onset) > 0 && y(onset) >= 0
            text(x(onset)+0.03, y(onset)+0.03, seizure_1_labels(i), 'HorizontalAlignment', 'left', 'FontSize', 9);
        elseif x(onset) >= 0 && y(onset) < 0
            text(x(onset)+0.03, y(onset)-0.03, seizure_1_labels(i), 'HorizontalAlignment', 'left', 'FontSize', 9);
        elseif x(onset) < 0 && y(onset) <= 0
            text(x(onset)-0.03, y(onset)-0.03, seizure_1_labels(i), 'HorizontalAlignment', 'right', 'FontSize', 9);
        elseif x(onset) <= 0 && y(onset) > 0
            text(x(onset)-0.03, y(onset)+0.03, seizure_1_labels(i), 'HorizontalAlignment', 'right', 'FontSize', 9);
        end
    end
    
    for i = 1:size(seizure_2, 2)
        onset = seizure_2(i);
        plot(x(onset), y(onset), 'o', 'MarkerEdgeColor', [0, 0, 0], 'MarkerFaceColor', [0.5, 0.5, 1]);
        if x(onset) > 0 && y(onset) >= 0
            text(x(onset)+0.03, y(onset)+0.03, seizure_2_labels(i), 'HorizontalAlignment', 'left', 'FontSize', 9);
        elseif x(onset) >= 0 && y(onset) < 0
            text(x(onset)+0.03, y(onset)-0.03, seizure_2_labels(i), 'HorizontalAlignment', 'left', 'FontSize', 9);
        elseif x(onset) < 0 && y(onset) <= 0
            text(x(onset)-0.03, y(onset)-0.03, seizure_2_labels(i), 'HorizontalAlignment', 'right', 'FontSize', 9);
        elseif x(onset) <= 0 && y(onset) > 0
            text(x(onset)-0.03, y(onset)+0.03, seizure_2_labels(i), 'HorizontalAlignment', 'right', 'FontSize', 9);
        end
    end
    
    hold off;
    title('Connection circle');

    filename = sprintf('%s\\%d_%s_matter_connection_circle.png', "pictures", id, patient_ID); 
    saveas(gcf, filename); 

    figure;
    set(gcf, 'Visible', 'off');
    imagesc(matter_connection_matrix);
    colormap([1 1 1; 1 0 0; 0 0 1; 1 0 1])

    h = colorbar;
    set(h, 'Ticks', [0.5 1.5 2.5 3.5], 'TickLabels', {'none', 'grey matter', 'white matter', 'both'});
    clim([0 4]);
    axis equal;
    axis tight;
    filename = sprintf('%s\\%d_%s_matter_connection_matrix.png', "pictures", id, patient_ID); 
    saveas(gcf, filename); 

end