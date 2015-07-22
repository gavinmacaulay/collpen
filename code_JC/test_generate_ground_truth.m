% Script to generate the ground truth for the boundary detection
close all, clear

filepath = '/Volumes/Datos/collpen/predator/test/';
filename = 'predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';

matPath = strrep(filename,'.avi','_interp_extrap_path.mat');
matPath = [filepath 'predator_position/' matPath];
if exist(matPath,'file')~=2
    disp(['getCircularRegionFromVideo: mat file not found in path: ' matPath]);
    disp('Aborting...');
    return;
end
load(matPath);

frames = frame_pixel_info(:,1);
startframe = frames(1);
endframe = frames(end);;


fullfilename = [filepath filename];

info     = aviinfo(fullfilename);
movieobj = mmreader(fullfilename);
RGB         = rgb2gray(read(movieobj, 1));
nf          = info.NumFrames;


RGB         = rgb2gray(read(movieobj, endframe));
imagesc(RGB);axis equal; axis tight; colormap gray
title(['Frame ' int2str(endframe)]);
xlabel('Click the desired positions to create a region (double click to close it). To continue, double click inside the region');
h = impoly;
%position = getPosition(h)
position = wait(h)
%keyboard

[r c] = size(position);
positions = zeros(r,c,endframe-startframe);

positions(:,:,endframe-startframe) = position(:,:);

for i = endframe-1:-1:startframe
    RGB         = rgb2gray(read(movieobj, i));
    imagesc(RGB);axis equal; axis tight; colormap gray
    title(['Frame ' int2str(i)]);
xlabel('Click the desired positions to create a region (double click to close it). To continue, double click inside the region');

    h = impoly(gca,position);
   % position = getPosition(h)

    position = wait(h)
    positions(:,:,i-startframe) = position(:,:);

end

save_path = strrep(filename,'.avi','_ground_truth.mat');
save(save_path,'positions');