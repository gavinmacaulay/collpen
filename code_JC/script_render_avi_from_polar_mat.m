% Script to generate .avi files from a series of .mat data coming from ddf
% (in polar coordinates)

%% Find recursively all subdirectories in a directory containing ddf files
clear
in_dir = '/Volumes/Datos/collpen/data';

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

frame_rate = 8; % by default, Didson works at a frequence of 8 samples
                % per second
for i = 1:length(ddf_files)
    disp(['Rendering file ' num2str(i) ' of ' num2str(length(ddf_files))]);
    try
        load(ddf_files(i).name);
        avi_out = strrep(ddf_files(i).name, '.mat', '.avi');
        mat_to_avi(D,avi_out,frame_rate);
        
    catch
        disp('Wrong mat data file');
    end
    
    
end
disp('End');



