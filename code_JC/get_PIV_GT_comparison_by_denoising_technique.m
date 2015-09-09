function [dot_product_acc, angle_acc, range_acc, relative_range_acc] = ...
            get_PIV_GT_comparison_by_denoising_technique(...
            denoising_technique_name, PIV_GT_comparisons, win_size)
        
% This function averages information of the PIV and GT comparison for a
% given denoising technique and window size. The input variable 
% 'PIV_GT_comparisons'contains the full set of comparisons for all window 
% sizes and denoising techniques.
        
    disp(['[PIV_GT_compare_by_denoising_technique]: Extract results for denoising technique '...
        denoising_technique_name]);
    
    dot_product_acc = [];
    angle_acc       = [];
    range_acc           = [];
    relative_range_acc  = [];
    
    % Get all comparisons for a window size
    comparison_win_size = PIV_GT_comparisons{win_size,1};
    
    
    % Average comparisons per denoising_technique_name
    for i=1:length(comparison_win_size)
        comparison = comparison_win_size(i);
        if(~isempty(strfind(comparison.piv_file,denoising_technique_name)))
            dot_product_acc = [dot_product_acc; comparison.dotproduct];
            angle_acc       = [angle_acc; comparison.angles];
            range_acc           = [range_acc; comparison.ranges];
            relative_range_acc  = [relative_range_acc; comparison.relative_range];
        end        
    end

    index = ~isnan(angle_acc);
    angle_acc = angle_acc(index);
    dot_product_acc = dot_product_acc(index);
    range_acc = range_acc(index);
    relative_range_acc = relative_range_acc(index);    
%     mean_dot_product    = mean(dot_product_acc);
%     mean_angle          = mean(angle_acc);
%     mean_range          = mean(range_acc);
%     mean_relative_range = mean(relative_range_acc);
        
end