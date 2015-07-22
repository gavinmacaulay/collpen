%% Find PIVs from denoised videos in case it is necessary


PIV_technique = 0;
debug = 0;

%video_folder = '/Volumes/Datos/collpen/predator/test/denoised/';
video_folder = '/Volumes/Datos/collpen/RedSlip/';
winsize=32;
%denoise_video_folder(video_folder,denoising_techniques(i,1),denoising_techniques(i,2),denoising_techniques_name{i});
JC_PIV_getPIVvectorsFromFolder(video_folder, 0, -1, {'previously_denoised'}, winsize)

%% Load PIV information

close all
clear 
% video_in = '/Volumes/Datos/collpen/predator/test/denoised/predmodel2013_TREAT_White net_didson_block38_sub1___02-Background_subtraction_+_normalization_filter.avi';
% video_out = '/Volumes/Datos/collpen/predator/test/denoised/video.avi';
% pivs = '/Volumes/Datos/collpen/predator/test/denoised/PIVdata/32/previously_denoised/predmodel2013_TREAT_White net_didson_block38_sub1___02-Background_subtraction_+_normalization_filter_PIV.mat';

video_in = '/Volumes/Datos/collpen/data/block1/didson/denoised/2013-07-16_085600___bg_sub.avi';
pivs = '/Volumes/Datos/collpen/data/block1/didson/PIVdata/32/previously_denoised/2013-07-16_085600_PIV.mat';
video_out = 'data/block1/didson/denoised/video.avi';

% video_in = '/Volumes/Datos/collpen/RedSlip/gopro_40%.avi';
% pivs = '/Volumes/Datos/collpen/RedSlip/PIVdata/32/previously_denoised/gopro_40%_PIV.mat';
% video_out = '/Volumes/Datos/collpen/RedSlip/denoised/PIV_video.avi';

% video_in = '/Volumes/Datos/collpen/RedSlip/denoised/gopro_40%___bg_sub.avi';
% pivs = '/Volumes/Datos/collpen/RedSlip/denoised/PIVdata/32/previously_denoised/gopro_40%___bg_sub_PIV.mat';
% video_out = '/Volumes/Datos/collpen/RedSlip/denoised/PIV_video.avi';

load(pivs);
map = createcolormap([1 2 10 48 64], [255 255 128 ; 255 255 0 ; 255 153 0 ; 255 0 0 ; 0 0 0]);

xs_1 = xs(:,:,1);
ys_1 = ys(:,:,1);

start_pos = 1;
%end_pos = 10;
input_video = VideoReader(video_in);
end_pos = input_video.NumberOfFrames-1;
us_mean = zeros(size(us(:,:,1)));
vs_mean = zeros(size(vs(:,:,1)));
for i = start_pos:end_pos
    disp(i);
    
    I = read(input_video,i);
%     mask = mask_low_intensity(I, xs_1, ys_1);
%     mask(find(mask(:)<8))=0;
%     us_mean = us_mean + (us(:,:,i).*mask);
%     vs_mean = vs_mean + (vs(:,:,i).*mask);     
    us_mean = us_mean + us(:,:,i);
    vs_mean = vs_mean + vs(:,:,i);
    if(max(max(us(:,:,i)))>15 || min(min(us(:,:,i)))< -15)
        mesh(us(:,:,i));
    end

end


%% PIVs are given in px/frame
us_mean = us_mean / (end_pos-start_pos+1);
vs_mean = vs_mean / (end_pos-start_pos+1);

%Transform from px/frame to m/sec
m_px_ratio = 58;
sec_frame_ratio = 1/8;

magnitude_uv = sqrt(us_mean.*us_mean + vs_mean.*vs_mean);

magnitude_uv = magnitude_uv * 8; % Speed in pixels/second [/ 115;] 
min_magnitude = min(magnitude_uv(:));
max_magnitude = max(magnitude_uv(:));




% display result

I = read(input_video,1);
I = (I.*0)+255;
imagesc(I); axis equal; axis tight;
hold on;
colormap(map);
quiverc(xs_1,ys_1,us_mean,vs_mean);

colorbar
set(gca,'CLim', [min_magnitude max_magnitude]);

disp('Finished!');