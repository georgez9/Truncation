function plot_connectivity_differences(CDP, CDN, titleStr)
    if iscell(CDP) || iscell(CDN)
        CDP_mat = cell2mat(CDP);
        CDN_mat = cell2mat(CDN);
    else
        CDP_mat = CDP;
        CDN_mat = CDN;
    end

    figure;
    set(gcf, 'Visible', 'on');
    
    boxplot([CDP_mat, CDN_mat], 'Labels', {'Prior to truncation point', 'Next to truncation point'});
    hold on;
    
    x_CDP = ones(length(CDP_mat), 1);
    scatter(x_CDP, CDP_mat, 'o');
    
    x_CDN = repmat(2, length(CDN_mat), 1);
    scatter(x_CDN, CDN_mat, 'o');
    ylim([-1, 1]);
    hold off;

    title(titleStr);
    ylabel('Values');
end