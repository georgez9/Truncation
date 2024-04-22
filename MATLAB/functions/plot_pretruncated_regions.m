function plot_pretruncated_regions(labels, frequency)
    your_simple_brain_plot_path = 'C:\Users\75766\Desktop\Simple-Brain-Plot'; % need to change this path
    
    addpath(your_simple_brain_plot_path);
    load_path = fullfile(your_simple_brain_plot_path, 'examples', 'regionDescriptions.mat');
    load(load_path, 'regionDescriptions');
    % figure save as: ...\Simple-Brain-Plot\examples\figures\figure_lausanne120_aseg.svg
    save_path = fullfile(your_simple_brain_plot_path, 'examples', 'figures', 'figure');
    
    % colormap
    blankColor = hex2rgb('#eeeeee');
    startColor = hex2rgb('#6e6a91');
    middleColor1 = hex2rgb('#ca8bb5');
    middleColor2 = hex2rgb('#f887a7');
    % #f6bc78
    endColor = hex2rgb('#f7cb67');   
    % cm = [startColor; endColor];
    % numColors = 10;
    % fineSpace = linspace(1, size(cm, 1), numColors);
    % cm = interp1(cm, fineSpace, 'linear');

    cm = [startColor; middleColor1; middleColor2; endColor];
    cm = [blankColor; interp1(cm, 1:0.01:size(cm,1))];


    regions = regionDescriptions.lausanne120_aseg;
    values = zeros(size(regions));
    [found, position] = ismember(labels, regions);
    if any(~found)
        missingItems = smallArray(labels);
        error('%s not found', join(missingItems, ", "));
    end
    for i = 1:size(position, 1)
        values(position(i)) = frequency(i);
    end
    
    plotBrain(regionDescriptions.lausanne120_aseg, ...
        values, cm, ...
        'atlas', 'lausanne120_aseg', ...
        'savePath', save_path);

    function rgb = hex2rgb(hex)
        hex = hex(~ismember(hex,'#'));
        rgb = sscanf(hex, '%2x%2x%2x', [1 3]) / 255;
    end
end