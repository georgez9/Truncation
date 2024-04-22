function draw_connection_circle(id, patient_ID, matter_connection_matrix, seizure_connection_matrix, seizure_1, seizure_1_labels, seizure_2, seizure_2_labels)
    save_file = true;
    N = 128;
    
    % the circle axis
    theta = linspace(0, 2*pi, N+1);
    theta(end) = [];
    x = cos(theta);
    y = sin(theta);
    
    figure('Position', [100, 100, 1200, 900]);
    set(gcf, 'Visible', 'off');
    set(gcf, 'Color', [1, 1, 1]);
    axis equal;
    axis off;

    % Test matrix
    if nargin == 0 % default value
        id = 0;
        patient_ID = "TEST";
        matter_connection_matrix = zeros(N, N);
        matter_connection_matrix(35, 56) = 3; 
        matter_connection_matrix(56, 35) = 2;
        matter_connection_matrix(56, 60) = 2;
        matter_connection_matrix(60, 56) = 2;
        seizure_connection_matrix = zeros(N, N);
        seizure_connection_matrix(56, 60) = 2;
        seizure_1 = [56 35];
        seizure_1_labels = ["l.postcentral_2" "l.postcentral_1"];
        seizure_2 = 60;
        seizure_2_labels = "l.precentral_4";
        set(gcf, 'Visible', 'on');
        save_file = false;
    end

    hold on;
    
    for i = 1:N
        plot(x(i), y(i), 'o', 'MarkerEdgeColor', [0.8, 0.8, 0.8], 'MarkerFaceColor', 'none');
    end

    % seperate so they won't overlap
    for i = 1:N
        for j = 1:N
            % delete the self connection
            if i == j
                matter_connection_matrix(i, j) = 0;
            end

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
        plot1 = plot(x(onset), y(onset), 'o', 'MarkerEdgeColor', [0, 0, 0], 'MarkerFaceColor', [0.7, 1, 0.7]);
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
        plot2 = plot(x(onset), y(onset), 'o', 'MarkerEdgeColor', [0, 0, 0], 'MarkerFaceColor', [1, 0.7, 0.7]);
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
    
    % For every seizure2, find if there is any connection with seizure 1
    % if not, highlight it in the graph
    % that means that region don't follow the seizure pathway
    
    seizure_isolated = seizure_2;
    indices = [];
    for i = 1:size(seizure_2, 2)
        for j = 1:size(seizure_1, 2)
            if matter_connection_matrix(seizure_2(i), seizure_1(j)) > 0
                indices(end+1) = seizure_2(i);
                break;
            end
        end
    end

    % Find out the percentage that follow the pathway



    % Also, for every region2, calculate the percentage that it has a
    % conncetion with the region1


    
    hold off;
    % title('Connection circle');

    legend([plot1, plot2], {"Regions before truncation point", "Regions after truncation point"}, 'Location', 'bestoutside', 'Orientation', 'horizontal');

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
    
    if save_file
        filename = sprintf('%s\\%d_%s_matter_connection_matrix.png', "pictures", id, patient_ID); 
        saveas(gcf, filename); 
    end 

end