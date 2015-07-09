function map = createcolormap(bins, rgb)
% This function returns a colormap according to the steps and colors
% specified in the input arguments
%
% EXAMPLE:
%
% bins = [1 2 10 48 64];
% color_step = [255 255 128 ; 255 255 0 ; 255 153 0 ; 255 0 0 ; 0 0 0];
% map = createcolormap(bins, color_step);
%
    map = zeros(max(bins),3);
    for i = 1:length(bins(:))-1
        init_bin = bins(i);
        end_bin = bins(i+1);
        range = end_bin-init_bin+1;
        map(init_bin:end_bin,1) = linspace(rgb(i,1),rgb(i+1,1),range);
        map(init_bin:end_bin,2) = linspace(rgb(i,2),rgb(i+1,2),range);
        map(init_bin:end_bin,3) = linspace(rgb(i,3),rgb(i+1,3),range);
    end
    map = map/255;
end