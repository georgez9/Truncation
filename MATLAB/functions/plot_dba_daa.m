% work with shuffing.m
function plot_dba_daa(result_table)
    figure('Position', [100, 100, 1300, 1000], Visible='on');
    color1 = '#336699'; 
    color2 = '#99cccc'; 
    color3 = '#ff6666'; 
    rgbColor1 = sscanf(color1(2:end), '%2x%2x%2x', [1 3])'/255;
    rgbColor2 = sscanf(color2(2:end), '%2x%2x%2x', [1 3])'/255;
    rgbColor3 = sscanf(color3(2:end), '%2x%2x%2x', [1 3])'/255;
    
    ylim_value = [-1, 1.2];
    
    subplot(2, 3, 1);
    boxplot([result_table.DBA_all_ac, result_table.DBA_all_pr, result_table.DBA_all_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DBA_all_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DBA_all_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DBA_all_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;
    xticklabels({});
    
    subplot(2, 3, 2);
    boxplot([result_table.DBA_white_ac, result_table.DBA_white_pr, result_table.DBA_white_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DBA_white_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DBA_white_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DBA_white_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;
    
    subplot(2, 3, 3);
    boxplot([result_table.DBA_grey_ac, result_table.DBA_grey_pr, result_table.DBA_grey_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DBA_grey_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DBA_grey_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DBA_grey_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;
    
    subplot(2, 3, 4);
    boxplot([result_table.DAA_all_ac, result_table.DAA_all_pr, result_table.DAA_all_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DAA_all_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DAA_all_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DAA_all_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;
    
    subplot(2, 3, 5);
    boxplot([result_table.DAA_white_ac, result_table.DAA_white_pr, result_table.DAA_white_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DAA_white_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DAA_white_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DAA_white_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;
    
    subplot(2, 3, 6);
    boxplot([result_table.DAA_grey_ac, result_table.DAA_grey_pr, result_table.DAA_grey_pt], 'Colors', 'k');
    hold on;
    scatter(1, result_table.DAA_grey_ac, 10, rgbColor1', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(2, result_table.DAA_grey_pr, 10, rgbColor2', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    scatter(3, result_table.DAA_grey_pt, 10, rgbColor3', 'filled', 'jitter', 'on', 'MarkerFaceAlpha', 0.5);
    ylim(ylim_value);
    hold off;

end