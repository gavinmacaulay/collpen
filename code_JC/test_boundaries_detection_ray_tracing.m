%% Script to test Predator-Prey interaction 
%
% This script uses the first method developed that consists of a
% preprocessing and binarization of the a set of input images, with a set of
% previously defined predator positions, to locate the non-zero
% pixels closer to the predator.
% 
% Preconditions
% A set of predator positions and direction matched with a set of frames
% must have been generated in advance
%


addpath('/Volumes/Datos/collpen/collpen')
savepath

close all
clear 
clc

debug = 1;
save_info = 1;
filepath = '/Volumes/Datos/collpen/videos/2013-07-17_100650.avi';
bg_image = imread('/Volumes/Datos/collpen/videos/PIVdata/2013-07-17_100650_BG.bmp');
preprocessing_params = struct('apply_denoising', 1, 'threshold_method', 0,'threshold_level',0.15,'window_size',20,'thickening_level',3,'strel_size',5,'opening_iterations',4, 'debug', debug);
boundary_detection_params = struct('angle', 180, 'beams', 180, 'min_range', 30);

[frames distances pos_x pos_y angles] = boundariesDetectionRayTracing(filepath, bg_image,preprocessing_params, boundary_detection_params, save_info, debug);


%% Test Predator-Prey interaction based on ray tracing on video folder

close all
clear 
clc

addpath('/Volumes/Datos/collpen/collpen')
savepath

debug = 1;
save_info = 1;
filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
bg_image = imread('/Volumes/Datos/collpen/videos/PIVdata/2013-07-17_100650_BG.bmp');
preprocessing_params = struct('apply_denoising', 1, 'threshold_method', 0,'threshold_level',0.15,'window_size',20,'thickening_level',6,'strel_size',5,'opening_iterations',5, 'debug', debug);
boundary_detection_params = struct('angle', 180, 'beams', 360, 'min_range', 30);

d = dir([filepath '*.avi']);

D = [];
for i = 1:length(d)
    file_name = d(i).name;
    bg_path = [filepath 'PIVdata/' strrep(d(i).name,'.avi','_BG.bmp')];
    bg_image = imread(bg_path);
    tic
    disp(['Analyzing video (' num2str(i) '/' num2str(length(d)) ') ' file_name]);
    [frames distances pos_x pos_y angles interp_extrap] = boundariesDetectionRayTracing(filepath, file_name, bg_image,preprocessing_params, boundary_detection_params, save_info, debug);
    toc
    file_index = repmat(i,size(frames,1),1);
    
    D = [D ; [file_index frames angles distances pos_x pos_y interp_extrap ]];
end

save_file = [filepath 'predator_prey_interaction_ray_tracing.mat'];

alpha = boundary_detection_params.angle;
samples = boundary_detection_params.beams;
min_range = boundary_detection_params.min_range;

save(save_file, 'D', 'min_range', 'alpha', 'samples');
disp(['Data saved in ' save_file]);

disp('Finished!!');


%% Plot detected data in a semi-circular region centered in the predator
clear all
close

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
load_file = [filepath 'predator_prey_interaction_ray_tracing.mat'];
load(load_file);


step = 8;
max_range = max(D(:,4));
I = zeros(max_range+1,(2*max_range)+1);

center_x = round(max_range+1);
center_y = 0;

%discard repeatet mesurements (This should be repeated samples per frame!)
% D2 = D(:,[1,2,4,5,6,7]);
% [D3 ia ic] = unique(D2,'rows');
% D2 = [D3(:,1) , D3(:,2) , D(ia,3) , D3(:,3) , D3(:,4) , D3(:,5) , D3(:,6)];



DD = D(~any(isnan(D),2),:);
[videos last_index all_indexes] = unique(DD(:,1));
D_filtered = [];

initial_index = 1;
for i = 1:length(last_index) % Eliminate repeated samples from each frame (due to round)
    D2 = DD(initial_index:last_index(i),:); 
    D3 = D2(:,[1,2,4,5,6,7]);
    [D4 ia ic] = unique(D3,'rows');
    D_filtered = [D_filtered ;  [D4(:,1) , D4(:,2) , D2(ia,3) , D4(:,3) , D4(:,4) , D4(:,5) , D4(:,6)]];

    initial_index = last_index(i)+1;    
end



rows = length(D_filtered);
for i = 1:rows
    
    if(D_filtered(i,7)==2) %Not consider extrapolated frames
    angle = D_filtered(i,3);
    range = D_filtered(i,4);
    
    % Transform from angles ranging from -90 to 90 with the origin on the
    % predator direction to angles from 0 to 180 to simplify further calculations
    if(angle<0)
        angle = 90+angle;
    else
        angle = abs(90 + angle);
    end
    
    if(~isnan(range))
        x = round(range * cosd(angle));
        y = round(range * sind(angle));
        
        I(y+1,center_x + x) = I(y+1,center_x +x)+1;
        
        
    end
    end
    
end

imagesc(I);
axis equal
axis tight

bin_x = 1:step:(2*max_range)+1;
bin_y = 1:step:max_range+1;

I2 = zeros(length(bin_y),length(bin_x));

prev_x = 1;
prev_y = 1;
for i=1:length(bin_x)-1
    for j = 1:length(bin_y)-1
        curr_x = bin_x(i+1);
        curr_y = bin_y(j+1);
        M = I(prev_y:curr_y,prev_x:curr_x);
        I2(j,i) = sum(sum(M));
        prev_y = curr_y+1;
    end
    prev_x = curr_x+1;    
end
figure;
imagesc(I2);
axis equal
axis tight


%% Plot angle vs range



plot(D_filtered(:,3), D_filtered(:,4),'.b');



%% Your data set:
% [Data file, frame no, angle, range, intensity]
% D=...
%     [1 1 12 1.4 4;...
%     1 1 2 3.3 4;...
%     1 1 5 5.4 4;...
%     1 1 7 2.4 4;...
%     1 1 8 7.4 4;...
%     1 1 2 5.4 4;...
%     1 1 2 3.5 4;...
%     1 1 1 4.4 4;...
%     2 1 12 1.4 4;...
%     2 1 2 3.3 4;...
%     2 1 5 5.4 4;...
%     2 1 7 2.4 4;...
%     2 1 8 7.4 4;...
%     2 1 2 5.4 4;...
%     2 1 2 3.5 4;...
%     2 1 1 4.4 4];
% Bin values


clear all
close
clc

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
save_file = [filepath 'predator_prey_interaction_ray_tracing.mat'];
disp(['Loading file ' save_file]);
load(save_file);
bin_th = -alpha/2:5:alpha/2;
bin_r = min_range:5:300;
bin_D = NaN([length(bin_th) length(bin_r)]);
for i=1:(length(bin_th)-1)
    for j=1:(length(bin_r)-1)
        ind_th = bin_th(i+1)>D(:,3) & bin_th(i)<D(:,3);
        ind_r = bin_r(j+1)>D(:,4) & bin_r(j)<D(:,4);
        bin_D(i,j)= sum(D(ind_th&ind_r,4)>0);
    end
end
plot(bin_D,'.')
colormap pink
xlabel('Range')
ylabel('Theta')