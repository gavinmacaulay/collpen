%% Test getCircularRegion from folder


clear
close all
clc

filepath = '/Volumes/Datos/collpen/predator/test/';
d = dir([filepath '*.avi']);

alpha = 180;
samples = 500 ;
min_range = 30;
max_range = 250;
debug = 0;

mask_x = [6; 100; 200; 300; 394; 214; 186; 6];
mask_y = [28; 12; 4; 12; 28; 738; 738; 28];
mask = [mask_x mask_y];
denoising_method = 10;
denoising_param = 25;
disp('Proces started');
%datestr(now,'HH:MM:SS')
for i = 1 : length(d)
    D = [];
    file_name =  d(i).name;
    tic
    disp(['Analyzing video (' num2str(i) '/' num2str(length(d)) ') ' file_name]);
    [px_relative_acc, py_relative_acc, angles_acc, ranges_acc, intensity_acc, ...
        frames_acc, gradient_acc, px_absolute_acc, py_absoute_acc, interpolated_extrapolated] ...
        = getCircularRegionFromVideo(filepath, d(i).name, alpha, samples, min_range, max_range, ...
        mask, denoising_method,denoising_param, debug);
    file_index = repmat(i,size(angles_acc{1},1),1);
    for j = 1 : size(angles_acc,2)
        file_index = repmat(i,size(angles_acc{j},1),1);
        D = [D ; [double(file_index) double(frames_acc{j}) double(angles_acc{j}) double(ranges_acc{j})...
            double(intensity_acc{j}) double(gradient_acc{j}) double(px_relative_acc{j})...
            double(py_relative_acc{j}) double(interpolated_extrapolated{j})]];
    end
    toc
    
    D = D(~any(isnan(D),2),:);
    save_file = [filepath strrep(file_name,'.avi', '_circular_region.mat')];
    
    save(save_file, 'D', 'min_range', 'max_range', 'alpha', 'samples');
    disp(['Data saved in ' save_file]);
end


% filter NaN intensity measurements


disp('Finished!!');
%datestr(now,'HH:MM:SS')


%% Preparing data (optimized version)
clear
close all
clc

filepath = '/Volumes/Datos/collpen/predator/test/';
d = dir([filepath '*.avi']);

load_path = [filepath strrep(d(1).name,'.avi','_circular_region.mat')];

load(load_path);
disp('Preparing data for plotting');



% Just keep x, y, intensity
E = [round(D(:,7)) round(D(:,8)) D(:,5)];

in = D(:,9)==2; % Filter extrapolated predator positions

E = E(in,:);

% Get x  unique values
index = unique(round(D(:,7)));

A = [];

tic
for i=1:size(index,1)

% isolate x values
ind = E(:,1) == index(i);
F = E(ind,:); % unique x values (still multiple y values)
ind2 = unique(F(:,2)); % isolate y values
for j = 1:size(ind2,1)
ind22 = F(:,2) == ind2(j);
G = F(ind22,:); % isolate duplicated x,y pairs
int_avg = mean(G(:,3));

A = [A ; index(i) ind2(j) int_avg];
end
    
    
end
toc
disp('Done!');

%%
point = [50 20 ; 0 30 ];
circle = [5 0 30];

p = [point(:,1) - circle(:,1) , point(:,2) - circle(:,2) ];

d = hypot(point(:,1),point(:,2));

%d = sqrt(sum(power(point - circle(:,1:2), 2), 2));
b = d-circle(:,3)<=1e-12;



%%
close all

x = linspace(-sqrt(900),sqrt(900));
y1 = sqrt(900-x.^2);
y2 = -sqrt(900-x.^2);
plot(x,y1,x,y2)
hold on
plot(point(:,1),point(:,2),'*');
axis equal


%%
close all
maxa1 = max(A(:,1)+1);
mina1 = min(A(:,1));
maxa2 = max(A(:,2)+1);
mina2 = min(A(:,2));

I = zeros(maxa1-mina1,maxa2-mina2);

ax = A(:,2)-mina2+1;
ay = A(:,1)-mina1+1;

%I(ax,ay) = A(:,3);
for i = 1:size(ax,1)
   I(ay(i),ax(i)) = A(i,3); 
end
imagesc(I);axis equal, axis tight;
colorbar

range = sqrt(A(:,2).^2 + A(:,1).^2);
figure;
plot(range,A(:,3),'*');xlabel('range'); ylabel('Intensity');

range = sqrt(ax.^2 + ay.^2);
figure;
plot(range,A(:,3),'*');xlabel('range'); ylabel('Intensity');

%% Preparing data for plotting from folder

% close all
% filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
% load_file = [filepath 'predator_prey_interaction_circular_region.mat'];
% load(load_file);


clear
close all
clc

filepath = '/Volumes/Datos/collpen/predator/test/';
d = dir([filepath '*.avi']);

load_path = [filepath strrep(d(1).name,'.avi','_circular_region.mat')];

load(load_path);
disp('Preparing data for plotting');
tic
keyboard
I = zeros(max_range+1, (2*max_range)+1);
I_temp = zeros(max_range+1, (2*max_range)+1);
I_samples = zeros(max_range+1, (2*max_range)+1);

I_gradient = zeros(max_range+1, (2*max_range)+1);
I_gradient_temp = zeros(max_range+1, (2*max_range)+1);
I_gradient_samples = zeros(max_range+1, (2*max_range)+1);

center_x = round(max_range+1);
center_y = 0;

prev_frame = D(1,2);
rows = size(D,1);


angles = D(:,3);
ranges = D(:,4);
belowzero = find(angles<0);
aboveequalzero = find(angles>=0);
% Transform from angles ranging from -90 to 90 with the origin on the
% predator direction to angles from 0 to 180 to simplify further calculations
angles(belowzero) = 90 + angles(belowzero);
angles(aboveequalzero) = abs(90 + angles(aboveequalzero));
x = round(ranges .* cosd(angles));
y = round(ranges .* sind(angles));

textprogressbar('Progress: ');
for i = 1:rows
    if(D(i,9)==2) % == 2 --> Not consider extrapolated frames; >0 --> Consider all frames
        %
        %         angle = D(i,3);
        %         range = D(i,4);
        %
        %         % Transform from angles ranging from -90 to 90 with the origin on the
        %         % predator direction to angles from 0 to 180 to simplify further calculations
        %         if(angle<0)
        %             angle = 90+angle;
        %         else
        %             angle = abs(90 + angle);
        %         end
        %
        %         x = round(range * cosd(angle));
        %         y = round(range * sind(angle));
        
        %         xx = round(D(i,7));
        %         yy = round(D(i,8));
        I_temp(y(i)+1,center_x + x(i)) = I_temp(y(i)+1,center_x + x(i)) + D(i,5);
        I_samples(y(i)+1,center_x + x(i)) = I_samples(y(i)+1,center_x + x(i)) + 1;
        
        I_gradient_temp(y(i)+1,center_x + x(i)) = I_gradient_temp(y(i)+1,center_x + x(i)) + D(i,6);
        % I_gradient_samples(y+1,center_x + x) = I_gradient_samples(y+1,center_x + x) + 1;
        
    end
    disp([num2str(i*100/rows) '% completed']);
    %progress = i *100 /rows;
    %     textprogressbar(progress);
    %     pause(0.5);
end
textprogressbar('Done');

toc
disp('Data ready');





%% Preparing data for plotting

% close all
% filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
% load_file = [filepath 'predator_prey_interaction_circular_region.mat'];
% load(load_file);

disp('Preparing data for plotting');
tic

I = zeros(max_range+1, (2*max_range)+1);
I_temp = zeros(max_range+1, (2*max_range)+1);
I_samples = zeros(max_range+1, (2*max_range)+1);

I_gradient = zeros(max_range+1, (2*max_range)+1);
I_gradient_temp = zeros(max_range+1, (2*max_range)+1);
I_gradient_samples = zeros(max_range+1, (2*max_range)+1);

center_x = round(max_range+1);
center_y = 0;

prev_frame = D(1,2);
rows = size(D,1);


angles = D(:,3);
ranges = D(:,4);
belowzero = find(angles<0);
aboveequalzero = find(angles>=0);
% Transform from angles ranging from -90 to 90 with the origin on the
% predator direction to angles from 0 to 180 to simplify further calculations
angles(belowzero) = 90 + angles(belowzero);
angles(aboveequalzero) = abs(90 + angles(aboveequalzero));
x = round(ranges .* cosd(angles));
y = round(ranges .* sind(angles));

textprogressbar('Progress: ');
for i = 1:rows
    if(D(i,9)==2) % == 2 --> Not consider extrapolated frames; >0 --> Consider all frames
        %
        %         angle = D(i,3);
        %         range = D(i,4);
        %
        %         % Transform from angles ranging from -90 to 90 with the origin on the
        %         % predator direction to angles from 0 to 180 to simplify further calculations
        %         if(angle<0)
        %             angle = 90+angle;
        %         else
        %             angle = abs(90 + angle);
        %         end
        %
        %         x = round(range * cosd(angle));
        %         y = round(range * sind(angle));
        
        %         xx = round(D(i,7));
        %         yy = round(D(i,8));
        I_temp(y(i)+1,center_x + x(i)) = I_temp(y(i)+1,center_x + x(i)) + D(i,5);
        I_samples(y(i)+1,center_x + x(i)) = I_samples(y(i)+1,center_x + x(i)) + 1;
        
        I_gradient_temp(y(i)+1,center_x + x(i)) = I_gradient_temp(y(i)+1,center_x + x(i)) + D(i,6);
        % I_gradient_samples(y+1,center_x + x) = I_gradient_samples(y+1,center_x + x) + 1;
        
    end
    disp([num2str(i*100/rows) '% completed']);
    %progress = i *100 /rows;
    %     textprogressbar(progress);
    %     pause(0.5);
end
textprogressbar('Done');

toc
disp('Data ready');




%% Plotting averaged & binned info

close all

I = I_temp;
I_gradient = I_gradient_temp;

figure;
imagesc(I);
axis equal
axis tight
%colormap hot
colorbar;

bin_x = 1:step:(2*max_range)+1;
bin_y = 1:step:max_range+1;

I2 = zeros(length(bin_y),length(bin_x));
I2_gradient = zeros(length(bin_y),length(bin_x));

prev_x = 1;
prev_y = 1;
for i=1:length(bin_x)-1
    curr_x = bin_x(i+1);
    for j = 1:length(bin_y)-1
        curr_y = bin_y(j+1);
        M = I(prev_y:curr_y,prev_x:curr_x);
        %keyboard
        I2(j,i) = sum(sum(M));
        prev_y = curr_y+1;
        
        M_gradient = I_gradient(prev_y:curr_y,prev_x:curr_x);
        %keyboard
        I2_gradient(j,i) = sum(sum(M_gradient));
        
        
    end
    prev_x = curr_x+1;
end
% figure;
% imagesc(I2);
% axis equal
% axis tight
% colormap hot
% colorbar;

I3 = I./I_samples;
figure; imagesc(I3);
title('I3');
axis equal;
axis tight;
colorbar

I3_gradient = I_gradient./I_samples;
figure; imagesc(I3_gradient);
title('I3gradient');
axis equal;
axis tight;
colorbar


%% Plot range vs intensity and range vs gradient

figure;
plot(D(:,4), D(:,5),'.');
xlabel('Range');
ylabel('Intensity');
figure;
plot(D(:,4), D(:,6),'.');
xlabel('Range')
ylabel('Gradient');

%% Test getBoundaries

% First method to detect predator-prey interaction based on thresholding
% and ray tracing.


addpath('/Volumes/Datos/collpen/collpen')
savepath

close all
clear
I = imread('sonar1.png');
bg_image = imread('/Volumes/Datos/collpen/predator/brown_net/seq1/PIVdata/predmodel2013_TREAT_Brown net_didson_block45_sub1_BG.bmp');
%preprocessing_params = struct('apply_denoising', 1, 'threshold_method', 2,'threshold_level',0.06,'window_size',20,'thickening_level',5,'strel_size',5,'opening_iterations',4, 'debug', 1);
preprocessing_params = struct('apply_denoising', 1, 'threshold_method', 0,'threshold_level',0.1,'window_size',20,'thickening_level',5,'strel_size',5,'opening_iterations',4, 'debug', 1);
debug = 1; % getBoundaries debug


filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';


%info     = aviinfo(filepath);
movieobj = VideoReader(filepath);


RGB         = uint16(read(movieobj, 1));
nf          = movieobj.NumberOfFrames;
[m n z]     = size(RGB);
Is          = zeros(m,n,nf);
angle = 180;
beams = 60;

v = [275 186 330 178];

for i = 1:nf
    
    I = rgb2gray(read(movieobj, i));
    
    if(preprocessing_params.debug)
        pause(0.1);
        figure(1);
    end
    I_filtered = imagePreprocess(I, bg_image, preprocessing_params);
    
    
    %bw = 1-bw;
    if(debug)
        figure(2);
    end
    [distances pos_x pos_y angles] = getBoundaries(I_filtered, v, angle, beams,debug);
    
    smooth_distances = smooth(distances,15,'lowess');
    
    binary_distances = distances;
    
    binary_distances(binary_distances>0) = 1;
    binary_distances(binary_distances<0) = 0;
    
    figure(3);
    axis equal
    subplot(1,2,1);
    colormap pink
    imagesc(I);
    hold on;
    quiver(v(1),v(2),v(3)-v(1),v(4)-v(2));
    plot(pos_x, pos_y, '.','markerSize',8);  %Plot found edges
    title('Vectors');
    subplot(1,2,2);
    xlim([-angle/2 angle/2]);
    plot(angles,distances, 'color', 'b');
    hold on
    plot(angles,smooth_distances, 'color' , 'r');
    title('Detected edges');
    ylabel('Range');
    xlabel('Angle');
    hold off
    
    ginput
    %     subplot(2,2,3);
    %     xlim([-angle/2 angle/2]);
    %     plot(angles,binary_distances);
    %     title('Detected edges');
    %     ylabel('Edge Found');
    %     xlabel('Angle');
end




%% Create circular region in front of the predator
% Use region as a mask to get the real data
% Second method to detect predator-prey interaction using circular masks
% to consider pixels in front of the predator without thresholding.
% TO DO: Check regression methods

addpath('/Volumes/Datos/collpen/collpen');
savepath;
close all
clear
clc



alpha = 180;
samples = 500;
max_range = 150; % distance from the predator to be considered
min_range = 25;
debug = 1;
frame_no = 1;
file_no = 1;


I = rgb2gray(imread('sonar2.png'));
%     Just to acquire points for testing
%      imagesc(I);
%      ginput

% Test predator vector
v = [115, 263 , 134 , 293];

[intensity rows columns ranges angles] = getPredatorPreyInteraction(I , v, alpha , samples , min_range , max_range , debug);

samples = size(intensity);
timestamp(1:samples(1)) = frame_no;
timestamp = timestamp';
data_file(1:samples(1)) = file_no;


info = [timestamp , rows , columns , ranges , angles , intensity];

figure(3);
[r c]  = size(I);
I_r = zeros(r,c);

for i = 1 :size(rows,1)
    I_r(rows(i),columns(i)) = intensity(i);
end
colormap gray;
imagesc(I_r);
hold on
axis equal
quiver(v(1), v(2), v(3)-v(1), v(4) - v(2), 2);


inf = unique(sort(angles));
for i=1:size(inf,1)
    inf(i)
    index = find(angles==inf(i));
    figure(3);
    hold on;
    vr = rotateVector(v,inf(i),0);
    quiver(vr(1), vr(2), vr(3) - vr(1), vr(4) - vr(2));
    
    figure(2);
    
    rng = ranges(index);
    [rng indx] = sort(rng);
    int = intensity(index);
    int = int(indx);
    
    
    plot(rng,int,'ro');
    title(['Angle ' int2str(inf(i))]);
    xlabel('Range');
    ylabel('Intensity');
    hold on
    intensity_fit = fit_logistic(rng,double(int));
    plot(rng,intensity_fit,'b');
    
    smooth_intensity = smooth(double(int),30,'lowess');
    plot(rng,smooth_intensity, 'g');
    axis([min_range max_range 0 256]);
    
    hold off
    
    % ginput;
end

figure;
subplot(1,2,1);
plot(angles , intensity,'.');
subplot(1,2,2);
plot(ranges, intensity , '.');


%% Test getCircularRegion for single image file


close all
clear
clc

I = rgb2gray(imread('sonar2.png'));

[h w] = size(I);
alpha = 180;
samples = 10 ;
min_range = 10;
max_range = 100;
debug = 1;
v = [112, 230 , 130 , 293];

[px py angle ranges intensity] = getCircularRegion(I, v, h , w , alpha, samples, min_range, max_range, debug);



%% Test getCircularRegion from video

clear
close all
clc

filepath = '/Volumes/Datos/collpen/predator/white_net/seq1/';
filename = 'predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';

alpha = 180;
samples = 500 ;
min_range = 30;
max_range = 150;
debug = 1;
tic
[px_relative_acc py_relative_acc angles_acc ranges_acc intensity_acc frames_acc gradient_acc interpolated_extrapolated] = getCircularRegionFromVideo(filepath, filename, alpha, samples, min_range, max_range,debug);
toc


%% Generate mask to avoid noise from the sides of the field of view

mask_x = [6; 100; 200; 300; 394; 214; 186; 6];
mask_y = [28; 12; 4; 12; 28; 738; 738; 28];
mask = [mask_x mask_y];
I = imread('');
mask = roipoly(I,mask_x,mask_y);








%% Cluster info to try to isolate boundary

% h = fspecial('gaussian');
% I4 = filter2(h,I3_gradient);
close all

nClusters = 10;
clusterIndices = kmeans(I3_gradient(:), nClusters);
imagesc(I3_gradient);
title('I3gradient');
axis equal;
axis tight;

pause(0.5)
figure;
imagesc(reshape(clusterIndices, size(I)));
axis equal;
axis tight;
colorbar
%colormap hot


%% Load optical flow vectors


clear
clc

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';
load(fullfile('/Volumes/Datos/collpen/predator/brown_net/seq1/PIVdata/predmodel2013_TREAT_Brown net_didson_block45_sub1_PIV.mat'));
%of_size = size(xs);
xs = pivdatas.rawpivel.xs;
xy = pivdatas.rawpivel.ys;
us = pivdatas.rawpivel.us;
vs = pivdatas.rawpivel.vs;
snrs = pivdatas.rawpivel.snrs;
pkhs = pivdatas.rawpivel.pkhs;
is = pivdatas.rawpivel.is;


%info     = aviinfo(filepath);
movieobj = VideoReader(filepath);


RGB         = uint16(read(movieobj, 1));
nf          = movieobj.NumberOfFrames;
[m n z]     = size(RGB);
%Is          = zeros(m,n,nf);
angle = 180;
beams = 60;


%%
load('/Volumes/Datos/collpen/predator/brown_net/seq1/predator_position/predmodel2013_TREAT_Brown net_didson_block45_sub1_interp_extrap_path.mat');
load('/Volumes/Datos/collpen/predator/brown_net/seq1/predmodel2013_TREAT_Brown net_didson_block45_sub1_school.mat');


pred_x = frame_pixel_info(:,2);
pred_x = round(pred_x/8);
pred_x = pred_x*8;


pred_y = frame_pixel_info(:,3);
pred_y = round(pred_y/8);
pred_y = pred_y*8;

close all
plot(pred_x,pred_y,'-r.');
hold on
plot(frame_pixel_info(:,2),frame_pixel_info(:,3),'-b.');
axis equal

plot(xs(:,:,1),ys(:,:,1));

quiver(xs(:,:,1),ys(:,:,1), us(:,:,1),vs(:,:,1));


[x, y, z] = size(xs);
close
for i =1:z
    pause(0.1);
    quiver(xs(:,end:1,i),ys(:,end:1,i), us(:,end:1,i),vs(:,end:1,i));
end

%%
% [Data file, frame no, angle, range, intensity]
% D=[1 1 12 1.4 4;...
%    1 1 2 3.3 4;...
%    1 1 5 5.4 4;...
%    1 1 7 2.4 4;...
%    1 1 8 7.4 4;...
%    1 1 2 5.4 4;...
%    1 1 2 3.5 4;...
%    1 1 1 4.4 4;...
%    2 1 12 1.4 4;...
%    2 1 2 3.3 4;...
%    2 1 5 5.4 4;...
%    2 1 7 2.4 4;...
%    2 1 8 7.4 4;...
%    2 1 2 5.4 4;...
%    2 1 2 3.5 4;...
%    2 1 1 4.4 4];
% Bin values

clear all
close
clc

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
load_file = [filepath 'predator_prey_interaction_circular_region.mat'];
disp(['Loading file ' load_file]);
load(load_file);
bin_th = -alpha/2:5:alpha/2;
bin_r = min_range:5:150;
bin_D = NaN([length(bin_th) length(bin_r)]);
tic
for i=1:(length(bin_th)-1)
    for j=1:(length(bin_r)-1)
        ind_th = bin_th(i+1)>D(:,3) & bin_th(i)<D(:,3);
        ind_r = bin_r(j+1)>D(:,4) & bin_r(j)<D(:,4);
        bin_D(i,j)= mean(D(ind_th&ind_r,5));
    end
end
toc
close
imagesc(bin_D)
xlabel('Range')
ylabel('Theta')

