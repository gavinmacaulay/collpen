function [mean_dot_product mean_angle mean_range mean_relative_range] = ...
            get_PIV_GT_mean_comparison_by_denoising_technique(...
            denoising_technique_name, PIV_GT_comparisons, win_size)
        
% This function averages information of the PIV and GT comparison for a
% given denoising technique and window size. The input variable 
% 'PIV_GT_comparisons'contains the full set of comparisons for all window 
% sizes and denoising techniques.
        
    disp(['[PIV_GT_compare_by_denoising_technique]: Extract results for denoising technique '...
        denoising_technique_name]);
    
    dot_product_acc = [];
    angle_acc       = [];
    range           = [];
    relative_range  = [];
    
    % Get all comparisons for a window size
    comparison_win_size = PIV_GT_comparisons{win_size,1};
    
    
    % Average comparisons per denoising_technique_name
    for i=1:length(comparison_win_size)
        comparison = comparison_win_size(i);
        if(~isempty(strfind(comparison.piv_file,denoising_technique_name)))
            dot_product_acc = [dot_product_acc comparison.dotproduct];
            angle_acc       = [angle_acc comparison.angles];
            range           = [range comparison.ranges];
            relative_range  = [relative_range comparison.relative_range];
        end        
    end
    mean_dot_product    = mean(dot_product_acc);
    mean_angle          = mean(angle_acc);
    mean_range          = mean(range);
    mean_relative_range = mean(relative_range);
        
end