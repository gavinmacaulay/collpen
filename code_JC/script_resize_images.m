% Script to resize images to adjust them to a specific resolution, filling
% the gaps with white pixels
clear
close all

path    = '/Volumes/Datos/Dropbox/SocialRobotics/';
h       = 800;
w       = 1200;

rel_h_w = h/w;
d       = [dir([path '*.jpg']) ; dir([path '*.png']) ; dir([path '*.bmp'])];
   
datafolder = [path 'scaled'];
if ~(exist(datafolder,'dir')==7)
        disp(['Creating data folder, ' datafolder]);
        mkdir(datafolder);
end

for i=1:size(d,1)
    img = zeros(h,w,3);
    img(:,:,:) = 255;
    img = uint8(img);
    input_img = imread([path d(i).name]);
    [r c nc] = size(input_img);
    rel_r_c = r/c;
    if rel_r_c < rel_h_w % Input image wider than reference image, set w as scale factor
       input_img = imresize(input_img, [NaN w]);
       [r c nc] = size(input_img);
       img(h/2-r/2:h/2+r/2-1,1:w,:) = input_img(1:r,1:c,:);
    elseif rel_r_c > rel_h_w 
       input_img = imresize(input_img, [h NaN]); % Input image higher than reference image, set h as scale factor
       [r c nc] = size(input_img);
       img(1:h,w/2-c/2:w/2+c/2-1,:) = input_img(1:r,1:c,:);
        
    else % Images have equal dimensions
        img = input_img;
    end
        
    %imagesc(img); axis equal; axis tight
    datapath = [datafolder '/esc_' d(i).name];
    disp(['Saving ' datapath]);
    imwrite(img, datapath);
end
