%% test reading from ddf

% This generates a mat file where the raw data is in D
data_dir='/Volumes/Datos/collpen/data/block1/didson';% Where the ddf?s are
type='A';
cp_ConvertDidsonToMat(data_dir,type);
 
%Should produce a mat file, which is read into matlab by read ?matfile?
 
%Gets a 3D matrix into memory.
%  
% T=20; % timestamp
% for i = 1:size(D,1)
% imagesc(squeeze(D(i,:,:)));
% pause(0.1);
% end
 a = D;

%% View result from ddf to mat
close all
clear all


load('/Volumes/Datos/collpen/ddf/2013-07-16_095507.mat')


%preprocessing_params = struct('apply_denoising', 0, 'threshold_method', 0,'threshold_level',0.08,'window_size',11,'thickening_level',5,'strel_size',5,'opening_iterations',4, 'debug', 1);
preprocessing_params = struct('apply_denoising', 1, 'threshold_method', 2,'threshold_level',0.06,'window_size',20,'thickening_level',5,'strel_size',5,'opening_iterations',4, 'debug', 1);

bg_image = imread('/Volumes/Datos/collpen/ddf/2013-07-16_095507_BG.bmp');
c = clock;
colormap pink
for i=2380:1:size(D,1)
    E = squeeze(D(i,:,:));
    E = uint8(E);
    E = imrotate(E,180,'bilinear');
    %figure(1);
    pause(0.1);
    %drawnow;
    %imagesc(E);
    %imwrite(E,['/Volumes/Datos/collpen/ddf/frames/' num2str(i) '.png'],'png');
    I = PIV_imagePreprocess(E, bg_image, preprocessing_params);

end

%% Test PIV_createBGImageFromDDF

path = '/Volumes/Datos';
PIV_createBGImageFromDDF(path,1,30,50);
