%% Test denoise folder with videos

video_folder = '/Volumes/Datos/collpen/RedSlip/';
denoising_method = 0;
denoising_params = -1;
denoising_label = 'bg_sub';

denoise_video_folder(video_folder,denoising_method,denoising_params,...
                     denoising_label);

%% Parameters

clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Describe the set of tests %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

denoising_techniques = [
%   -1,0;    % Raw images
    0,0;    % Background subtraction + normalization
    1,0;    % Gaussian
    3,0;    % Median
    5,0;    % Median + average
    1,1;    % Wavelet + gaussian
    3,1;    % Wavelet + Median
    5,1;    % Wavelet + Median + average
    9,50;   % DPAD 50
    11,50;  % DPAD 50 + Median
    10,25;  % SRAD 25
    10,50;  % SRAD 50
    10,100; % SRAD 100
    12,25;  % SRAD 25 + Median
    12,50;  % SRAD 50 + Median
    12,100; % SRAD 100 + Median
    8,0;     % Frost
    0,-1;    % Background subtraction only
    ];
%
% denoising_techniques_name{1}  = '01-Raw images-filter';
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

denoising_techniques_name{1}  = '06-Wavelet + gaussian-filter';
denoising_techniques_name{2}  = '07-Wavelet + Median-filter';
denoising_techniques_name{3}  = '08-Wavelet + Median + average-filter';

denoising_techniques_name{1}  = '01-Raw images-filter';
denoising_techniques_name{2}  = '04-Median-filter';
denoising_techniques_name{3}  = '05-Median + average-filter';
denoising_techniques_name{4} = '11-SRAD 25-filter';
denoising_techniques_name{5} = '12-SRAD 50-filter';
denoising_techniques_name{6} = '14-SRAD 25 + Median-filter';
denoising_techniques_name{7} = '15-SRAD 50 + Median-filter';

%% Filter and render videos

video_folder = '/Volumes/Datos/collpen/denoise_polar/';

for i = 1: length(denoising_techniques)
    if(~cellfun(@isempty,denoising_techniques_name(i)))
        denoise_video_folder(video_folder,denoising_techniques(i,1),denoising_techniques(i,2),denoising_techniques_name{i});
        
        
        %   JC_PIV_getPIVvectorsFromFolder(folder, denoising_techniques(i,1), denoising_techniques(i,2), denoising_techniques_name(i), winsize)
    end
end

%% Find PIVs from denoised videos


PIV_technique = 0;
debug = 0;

%video_folder = '/Volumes/Datos/collpen/predator/test/denoised/';
video_folder = '/Volumes/Datos/collpen/denoise_polar/denoised/';
winsize=16;
%denoise_video_folder(video_folder,denoising_techniques(i,1),denoising_techniques(i,2),denoising_techniques_name{i});
JC_PIV_getPIVvectorsFromFolder(video_folder, -1, -1, {'previously_denoised'}, winsize)


%% Render denoised video with PIVs overlayed

winsize=32;

video_folder = '/Volumes/Datos/collpen/RedSlip/';
video_name = 'gopro_40%.avi';
video_file = [video_folder video_name];

mat_file = [video_folder 'PIVdata/' num2str(winsize) '/previously_denoised/' video_name];
mat_file = strrep(mat_file,'.avi','_PIV.mat');  

movieobj = VideoReader(video_file);
load(mat_file);

for i = 1:movieobj.NumberOfFrames-1
    disp(i);
    img = read(movieobj,i);
    h = imagesc(img);
    hold on; axis equal; axis tight;
    quiver(xs(:,:,i),ys(:,:,i),us(:,:,i).*pkhs(:,:,i),vs(:,:,i).*pkhs(:,:,i));
    hold off;
    pause(0.5);
end


%% Video to images

video_path = '/Volumes/Datos/collpen/predator/test/denoised/predmodel2013_TREAT_White net_didson_block38_sub1___02-Background subtraction + normalization-filter.avi';
video_to_image_files(video_path);