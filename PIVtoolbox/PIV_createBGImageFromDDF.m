function PIV_createBGImageFromDDF(folder, show_msg, percentile, num_frames)
% This method loops over all ddf files in a folder, converting them into
% Matlab format. Afterwards, for each matlab file, a background estimation
% image is generated
%
% Bacground estimation
% 
% Input:
% folder       : Directory containing ddf files and to store output files
% show_msg     : 1 or 0, if 1 shows messages 
% num_frames   : Number of frames to establish bg image 
% percentile   : Percentile used to establish bg image 
%
% This is a version from the code in PIV_createBGImage.m  
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com



% Generate mat files from ddf's
% Type:
% type=='A'. Creates avi files
% type=='D'. Creates a matlab file per ddf file
% type=='T'. Creates a time index file
type = 'D';
cp_ConvertDidsonToMat(folder,type);


% Loop among the .mat files to create bg images
d = dir([folder '/*.ddf']);

for i = 1:length(d)
    tmp_mat_file = strrep(d(i).name,'.ddf','.mat');
    load([folder '/' tmp_mat_file]); % Loads images into D variable
    
    % Calculate BG
    I = getBGImage(D, show_msg, percentile, num_frames);

    % Save BG
    tmp_file_path_bg = strrep([d(i).name],'.ddf','_BG.bmp');
    file_path_bg = [folder '/' tmp_file_path_bg];

    dispMsg(show_msg,['[PIV_createBGImageFromDDF]: Writing BG image: ' file_path_bg]);
    imwrite(I,file_path_bg);
end


end


function I = getBGImage(images_mat, msg,perc,n)

   
    % Setting up image stack
    dispMsg(msg,'[PIV_createBGImageFromDDF]: ..Setting up image stack')
    RGB         = uint16(squeeze(images_mat(1,:,:)));
    nf          = min(size(images_mat,1),n);
    [m n z]     = size(RGB);
    Is          = zeros(m,n,nf);

for i=1:1:nf
    E = squeeze(images_mat(i,:,:));
    E = uint8(E);
    E = imrotate(E,180,'bilinear'); % Image in polar coordinates
    
    Is(:,:,i) = E(:,:,1);
    
end
    

    % Generating percentile BG image
    dispMsg(msg,'[PIV_createBGImageFromDDF]: ..Generating BG  image')
    I=zeros(m,n);
    for i=1:m
        for j=1:n
            I(i,j)  = prctile(Is(i,j,:),perc);
        end
    end
    %warning off
    I=uint8(I);
    %warning on
end

function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end