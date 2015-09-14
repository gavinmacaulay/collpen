            %% Script to check what denoising technique works better for PIV computation
%
% The script is divided into different blocks that can be run separatedly
% as long as the script has ben run at least once (to generate the
% intermediate data). In any case, it is recommended running the
% first block to configure the input variables.
%
% 
% This is the folder structure generated by this script
% 
% . % The root folder intially contains the raw input videos and some manually labelled prey positions (groundtruth)
% ----- PIV_GT_result % Result of the comparison between the calculated PIVs and the groundtruth
% |   ----- PIV_GT_comparisons.mat
% |   ----- PIV_GT_comparisons.xls
% ----- PIVdata % Background images from the input videos (for denoising)
% |   ----- video1_BG.bmp
% |   ----- video2_BG.bmp
% ----- denoised % Folder containing denoised videos and their associated PIVS
% |   ----- PIVdata
% |   |   ----- 16 % Window size for PIV computation
% |   |   |   ----- video1___01-Raw\ images-filter_PIV.mat
% |   |   |   ----- video1___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   |   |   ----- video2___01-Raw\ images-filter_PIV.mat
% |   |   |   ----- video2___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   |   ----- 32
% |   |   |   ----- video1___01-Raw\ images-filter_PIV.mat
% |   |   |   ----- video1___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   |   |   ----- video2___01-Raw\ images-filter_PIV.mat
% |   |   |   ----- video2___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   |   ----- 64
% |   |       ----- video1___01-Raw\ images-filter_PIV.mat
% |   |       ----- video1___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   |       ----- video2___01-Raw\ images-filter_PIV.mat
% |   |       ----- video2___02-Background_subtraction_+_normalization_filter_PIV.mat
% |   ----- video1___01-Raw\ images-filter.avi
% |   ----- video1___02-Background_subtraction_+_normalization_filter.avi
% |   ----- video2___01-Raw\ images-filter.avi
% |   ----- video2___02-Background_subtraction_+_normalization_filter.avi
% ----- video1.avi
% ----- video2.avi
% ----- prey_position % Folder containing the groundtruth
%     ----- video1_prey_positions.mat
%     ----- predmodel2013_TREAT_Brown\ net_didson_block521_sub1_prey_positions.mat
%

%% Select Input parameters
clear
close all 

% -------------------------------------------------------------------------------
% Change video folder to the one containing your videos
% The folder should containt all input videos to be tested and a folder
% containing manually labelled prey positions under the name
% '/prey_position'. This folder is generated by the script 'test_prey_labeling.m'
% -------------------------------------------------------------------------------

%video_folder = 'C:\collpen_jc\method_paper_sources';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\ARIS_arissfw_cartesian';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\ARIS_arissfw_polar';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\ARIS_raw_cartesian';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\ARIS_raw_polar';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\ARIS_raw_polarwide';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\DIDSON_arissfw_cartesian';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\DIDSON_arissfw_polar';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\DIDSON_raw_cartesian';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\DIDSON_raw_polar';
%video_folder = 'C:\collpen_jc\method_paper_GT_vs_PIV\DIDSON_raw_polarwide';
video_folder = 'C:\collpen_jc\test';
% -------------------------------------------------------------------------------
% Select the window size for PIV computation
% This is the distance among PIVs and also indicates the maximum distance
% detected between frames. That is, in a window_size of 16 pixels the 
% maximum displacement between frames will be 16/2 = 8 pixels.
% -------------------------------------------------------------------------------

PIV_winsize         =[32];% [16,32,64];

% -------------------------------------------------------------------------------
% Configuration of the input videos
% -------------------------------------------------------------------------------

px_per_meter        = 71.4413;
frames_per_second   = 8;

% Select denoising techniques to be applied. 

denoising_techniques_name{1}  = [];
denoising_techniques_name{2}  = [];
denoising_techniques_name{3}  = [];
denoising_techniques_name{4}  = [];
denoising_techniques_name{5}  = [];
denoising_techniques_name{6}  = [];
denoising_techniques_name{7}  = [];
denoising_techniques_name{8}  = [];
denoising_techniques_name{9}  = [];
denoising_techniques_name{10} = [];
denoising_techniques_name{11} = [];
denoising_techniques_name{12} = [];
denoising_techniques_name{13} = [];
denoising_techniques_name{14} = [];
denoising_techniques_name{15} = [];
denoising_techniques_name{16} = [];
denoising_techniques_name{17} = [];
denoising_techniques_name{18} = [];
denoising_techniques_name{19} = [];
denoising_techniques_name{20} = [];
denoising_techniques_name{21} = [];
denoising_techniques_name{22} = [];
denoising_techniques_name{23} = [];
denoising_techniques_name{24} = [];
denoising_techniques_name{25} = [];
denoising_techniques_name{26} = [];

denoising_techniques = zeros(26,2);

% -------------------------------------------------------------------------------
% Comment or uncomment the desired denoising techniques
% -------------------------------------------------------------------------------

denoising_techniques(1,:)  = [-1,0];    % Raw images
denoising_techniques(2,:)  = [0,0];     % Background subtraction + normalization
denoising_techniques(3,:)  = [1,0];     % Gaussian
denoising_techniques(4,:)  = [3,0];     % Median
denoising_techniques(5,:)  = [5,0];     % Median + average
denoising_techniques(6,:)  = [1,1];     % Wavelet + gaussian
denoising_techniques(7,:)  = [3,1];     % Wavelet + Median
denoising_techniques(8,:)  = [5,1];     % Wavelet + Median + average
denoising_techniques(9,:)  = [9,50];    % DPAD 50
denoising_techniques(10,:) = [11,50];   % DPAD 50 + Median
denoising_techniques(11,:) = [10,25];   % SRAD 25
denoising_techniques(12,:) = [10,50];   % SRAD 50
denoising_techniques(13,:) = [10,100];  % SRAD 100
denoising_techniques(14,:) = [12,25];   % SRAD 25 + Median
denoising_techniques(15,:) = [12,50];   % SRAD 50 + Median
denoising_techniques(16,:) = [12,100];  % SRAD 100 + Median
denoising_techniques(17,:) = [8,0];     % Frost
denoising_techniques(18,:) = [0,-1];    % Background subtraction only
% denoising_techniques(19,:)  = [9,25];    % DPAD 25
% denoising_techniques(20,:)  = [9,75];    % DPAD 75
% denoising_techniques(21,:)  = [9,100];    % DPAD 100
% denoising_techniques(22,:) = [11,25];   % DPAD 25 + Median
denoising_techniques(23,:) = [11,75];   % DPAD 75 + Median
% denoising_techniques(24,:) = [11,100];   % DPAD 100 + Median
% denoising_techniques(25,:) = [10,75];  % SRAD 100
denoising_techniques(26,:) = [12,75];   % SRAD 75 + Median

denoising_techniques_name{1}  = '01-Raw images-filter';
denoising_techniques_name{2}  = '02-Background_subtraction_+_normalization_filter';
denoising_techniques_name{3}  = '03-Gaussian-filter';
denoising_techniques_name{4}  = '04-Median-filter';
denoising_techniques_name{5}  = '05-Median + average-filter';
denoising_techniques_name{6}  = '06-Wavelet + gaussian-filter';
denoising_techniques_name{7}  = '07-Wavelet + Median-filter';
denoising_techniques_name{8}  = '08-Wavelet + Median + average-filter';
denoising_techniques_name{9}  = '09-DPAD 50-filter';
denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
denoising_techniques_name{11} = '11-SRAD 25-filter';
denoising_techniques_name{12} = '12-SRAD 50-filter';
denoising_techniques_name{13} = '13-SRAD 100-filter';
denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';
denoising_techniques_name{17} = '17-Frost-filter';
denoising_techniques_name{18} = '18-Background_subtraction_only';
% denoising_techniques_name{19}  = '19-DPAD 25';
% denoising_techniques_name{20} = '20-DPAD 75';
% denoising_techniques_name{21} = '21-DPAD 100';
% denoising_techniques_name{22} = '22-DPAD 25 + Median-filter';
denoising_techniques_name{23} = '23-DPAD 75 + Median-filter';
% denoising_techniques_name{24} = '24-DPAD 100 + Median-filter';
% denoising_techniques_name{25} = '25-SRAD 100';
denoising_techniques_name{26} = '26-SRAD 75 + Median-filter';


%% PIVs vs Groundtruth

% Input: Folders (one per window size) containing PIVs calculated from
%        the denoised videos
%        Folder containing manually tracked fish
%
% Output: File containing the comparisons

denoised_folder = [video_folder '/denoised'];
save_path = [video_folder '/PIV_GT_result/'];
img_path = [video_folder '/PIV_GT_result/img/'];
prey_gt_folder = [video_folder '/prey_position/'];
save_images = 0;
PIV_GT_comparisons = cell(length(PIV_winsize),1);
for i = 1:length(PIV_winsize)
    disp(['Compare PIVs to groundtruth in winsize ' int2str(PIV_winsize(i))]);
    PIVs_folder = [denoised_folder '/PIVdata/' int2str(PIV_winsize(i))];
    comparison_result = compare_PIV_to_GT(PIVs_folder,prey_gt_folder,...
        video_folder, px_per_meter, frames_per_second,img_path,save_images);
    PIV_GT_comparisons{i} = comparison_result;
    
end

save_path = [video_folder '/PIV_GT_result/'];
if~(exist(save_path,'dir')==7)
    disp(['Creating data folder: ' save_path]);
    mkdir(save_path);
end

save_path = [save_path 'PIV_GT_comparisons.mat'];

save(save_path, 'PIV_GT_comparisons','prey_gt_folder','PIV_winsize',...
    'denoised_folder','video_folder');

%% Summarize the results

% Input: File containing the result of the comparison between PIVs and
%        manually labelled fish (groundtruth)
%
% Output: Excel file containing the summary of the comparisons
% (human-friendly)

load_path = [video_folder '/PIV_GT_result/PIV_GT_comparisons.mat'];
load(load_path);

summary_file_path = [video_folder '/PIV_GT_result/PIV_GT_comparisons.txt'];
fileID = fopen(summary_file_path,'w');

% Variables to store the whole comparison sets
accumulated_angle           = cell(1);
accumulated_range           = cell(1);
accumulated_dot_product     = cell(1);
accumulated_relative_range  = cell(1);
accumulated_denoising_name  = cell(1);
accumulated_distance        = cell(1);

for j = 1:length(PIV_winsize)
    if(~isempty(PIV_winsize(j)))
        fprintf(fileID,'Denoising summary for window size %d\n\n', PIV_winsize(j));
        fprintf(fileID,'Denoising\tDot product\tAngle\tRange\tRelative range\tDistance\n');
        
        accumulated_angle{1,j}          = [];
        accumulated_range{1,j}          = [];
        accumulated_dot_product{1,j}    = [];
        accumulated_relative_range{1,j} = [];       
        accumulated_denoising_name{1,j} = [];
        accumulated_distance{1,j}       = [];

        for i = 1:length(denoising_techniques_name)
            if(~isempty(denoising_techniques_name{i}))
                [dot_product_acc, angle_acc, range_acc, relative_range_acc, distance_acc] = ...
                    get_PIV_GT_comparison_by_denoising_technique(...
                    denoising_techniques_name{i}, PIV_GT_comparisons, j);
                accumulated_distance{1,j} = [accumulated_distance{1,j} , distance_acc'];
                accumulated_angle{1,j} = [accumulated_angle{1,j} , angle_acc'];
                accumulated_range{1,j} = [accumulated_range{1,j} , range_acc'];
                accumulated_dot_product{1,j} = [accumulated_dot_product{1,j} , ...
                    relative_range_acc'];
                accumulated_relative_range{1,j} = [accumulated_relative_range{1,j} ,...
                    dot_product_acc'];
                
                c = repmat(denoising_techniques_name{i},length(angle_acc),1);                
                b = strvcat(accumulated_denoising_name{1,j});
                d = strvcat({b ; c});
                
                accumulated_denoising_name{1,j} = d;
                median_dot_product    = median(dot_product_acc);
                median_angle          = median(angle_acc);
                median_range          = median(range_acc);
                median_relative_range = median(relative_range_acc);
                median_distance       = median(distance_acc);
                fprintf(fileID,'%s\t%f\t%f\t%f\t%f\t%f\n',...
                    denoising_techniques_name{i},median_dot_product, ...
                    median_angle, median_range, median_relative_range, median_distance);
            end
        end
        fprintf(fileID,'\n\n');
    end
end


summary_file_path = [video_folder '/PIV_GT_result/PIV_GT_comparisons_all_data.mat'];
save(summary_file_path,'accumulated_angle','accumulated_range',...
'accumulated_dot_product','accumulated_relative_range','accumulated_denoising_name','accumulated_distance');

fclose(fileID);

%% Plot box and whiskers 

%f = boxplot(accumulated_dot_product{1,2}', accumulated_denoising_name{1,2},'datalim',[0,200],'extrememode','compress','medianstyle','line','plotstyle','compact','boxstyle','outline');


%%

load_path = [video_folder '/PIV_GT_result/PIV_GT_comparisons.mat'];
load(load_path);

dpr_file_path = [video_folder '/PIV_GT_result/PIV_GT_raw_comparisons_dot_product.txt'];
ang_file_path = [video_folder '/PIV_GT_result/PIV_GT_raw_comparisons_angle.txt'];
rng_file_path = [video_folder '/PIV_GT_result/PIV_GT_raw_comparisons_range.txt'];
rrg_file_path = [video_folder '/PIV_GT_result/PIV_GT_raw_comparisons_relative_range.txt'];
dst_file_path = [video_folder '/PIV_GT_result/PIV_GT_raw_comparisons_distance.txt'];


dpr_fileID = fopen(dpr_file_path,'w');
ang_fileID = fopen(ang_file_path,'w');
rng_fileID = fopen(rng_file_path,'w');
rrg_fileID = fopen(rrg_file_path,'w');
dst_fileID = fopen(dst_file_path,'w');

for j = 1:length(PIV_winsize)
   disp(['Check window size ' num2str(PIV_winsize(j))]);
   fprintf(dpr_fileID,'\n\n\n\nDenoising for window size %d\n\n', PIV_winsize(j));
   fprintf(ang_fileID,'\n\n\n\nDenoising for window size %d\n\n', PIV_winsize(j));
   fprintf(rrg_fileID,'\n\n\n\nDenoising for window size %d\n\n', PIV_winsize(j));
   fprintf(rng_fileID,'\n\n\n\nDenoising for window size %d\n\n', PIV_winsize(j));
   fprintf(dst_fileID,'\n\n\n\nDenoising for window size %d\n\n', PIV_winsize(j));

   win_comparison = PIV_GT_comparisons{j};
   for i = 1:length(win_comparison) 
      single_comparison = win_comparison(i); 
      fprintf(dpr_fileID,'\n%d\t%s\n%f ' ,i,single_comparison.piv_file,...
          single_comparison.dotproduct);
      fprintf(ang_fileID,'\n%d\t%s\n%f ' ,i,single_comparison.piv_file,...
          single_comparison.angles);      
      fprintf(rng_fileID,'\n%d\t%s\n%f ' ,i,single_comparison.piv_file,...
          single_comparison.ranges);      
      fprintf(rrg_fileID,'\n%d\t%s\n%f ' ,i,single_comparison.piv_file,...
          single_comparison.relative_range); 
      fprintf(dst_fileID,'\n%d\t%s\n%f ' ,i,single_comparison.piv_file,...
          single_comparison.distances);
   end   
    
end
fclose(dpr_fileID);
fclose(ang_fileID);
fclose(rrg_fileID);
fclose(rng_fileID);
fclose(dst_fileID);


