% Script to generate .mat files from a series of .ddf didson data
% sequences.

%% Find recursively all subdirectories in a directory containing ddf files
clear
in_dir = '/Volumes/Datos/collpen/data';

ddf_files = rdir([in_dir '/**/*.ddf']);
sub_folders = {};


for i = 1:length(ddf_files)
    index = strfind(ddf_files(i).name,'/');
    ddf_folder = ddf_files(i).name(1:index(end)-1);
    sub_folders = [sub_folders ; ddf_folder];   
end

sub_folders = unique(sub_folders);



%% Loop through the ddf unpacking the info to get .m files

out_type = 'D'; % Create Matlab file per ddf file


for i = 1:length(sub_folders)
    disp(['Converting folder ' num2str(i) ' of ' ...
          num2str(length(sub_folders))]);
    current_ddf = sub_folders{i};
    cp_ConvertDidsonToMat(current_ddf,out_type);
end
    disp('End');
