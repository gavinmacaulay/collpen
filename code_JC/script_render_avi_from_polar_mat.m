% Script to generate .avi files from a series of .mat data coming from ddf
% (in polar coordinates)

%% Find recursively all subdirectories in a directory containing ddf files
clear
in_dir = '/Volumes/Datos/collpen/methods_paper_sources/didson_herring/';

ddf_files = rdir([in_dir '/**/*.mat']);
% sub_folders = {};
% 
% 
% for i = 1:length(ddf_files)
%     index = strfind(ddf_files(i).name,'/');
%     ddf_folder = ddf_files(i).name(1:index(end)-1);
%     sub_folders = [sub_folders ; ddf_folder];   
% end
% 
% sub_folders = unique(sub_folders);

%% Render avi files


% Data contained in D has the following format (frame,height,width)

frame_rate = 8; % by default Didson works at a frequence of 8 samples
                % per second
for i = 1:length(ddf_files)
    disp(['Rendering file ' num2str(i) ' of ' num2str(length(ddf_files))]);
    try
        load(ddf_files(i).name);
        avi_out = strrep(ddf_files(i).name, '.mat', '_raw_polar.avi');
        mat_to_avi(D,avi_out,frame_rate,-1, -1);
        video_reader = VideoReader(avi_out);
        I = read(video_reader,1);
        [r c] = size(I);        
        avi_out_wide = strrep(ddf_files(i).name, '.mat', '_raw_polar_wide.avi');
        change_video_framerate_resolution(avi_out,avi_out_wide,0,r,c*2,0,0); % For ARIS only?
        
    catch
        disp('Wrong mat data file');
    end    
    
end
disp('End');

%% Render avi files from single videos

frame_rate = 8;

ddf_path    = '/Volumes/Datos/collpen/denoising_tests/sources/';

ddf_file    = [ddf_path '2013-07-17_085620.mat'];
avi_out   = [ddf_path '2013-07-17_085620_1825_1920_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,1825,1920);

ddf_file    = [ddf_path '2013-07-17_171402.mat'];
avi_out   = [ddf_path '2013-07-17_171402_1844_1947_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,1844,1947);

ddf_file    = [ddf_path '2013-07-18_090802.mat'];
avi_out   = [ddf_path '2013-07-18_090802_1735_1810_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,1735,1810);

ddf_file    = [ddf_path '2013-07-18_120502.mat'];
avi_out   = [ddf_path '2013-07-18_120502_1450_1520_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,1450,1520);

ddf_file    = [ddf_path '2013-07-18_161457.mat'];
avi_out   = [ddf_path '2013-07-18_161457_726_804_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,726,804);

ddf_file    = [ddf_path '2013-07-19_105504.mat'];
avi_out   = [ddf_path '2013-07-19_105504_1758_1821_raw_polar.avi'];
load(ddf_file);
mat_to_avi(D,avi_out,frame_rate,1758,1821);


%%

ddf_path    = '/Volumes/Datos/collpen/denoising_tests/sources/';

ddf_file    = [ddf_path '2013-07-17_085620.avi'];
avi_out   = [ddf_path '2013-07-17_085620_1825_1920_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,1825,1920);

ddf_file    = [ddf_path '2013-07-17_171402.avi'];
avi_out   = [ddf_path '2013-07-17_171402_1844_1947_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,1844,1947);

ddf_file    = [ddf_path '2013-07-18_090802.avi'];
avi_out   = [ddf_path '2013-07-18_090802_1735_1810_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,1735,1810);

ddf_file    = [ddf_path '2013-07-18_120502.avi'];
avi_out   = [ddf_path '2013-07-18_120502_1450_1520_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,1450,1520);

ddf_file    = [ddf_path '2013-07-18_161457.avi'];
avi_out   = [ddf_path '2013-07-18_161457_726_804_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,726,804);

ddf_file    = [ddf_path '2013-07-19_105504.avi'];
avi_out   = [ddf_path '2013-07-19_105504_1758_1821_raw_cartesian.avi'];
change_video_framerate_resolution(ddf_file,avi_out,0,0,0,1758,1821);

