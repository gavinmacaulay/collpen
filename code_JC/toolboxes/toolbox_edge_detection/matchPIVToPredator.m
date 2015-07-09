function [frame_acc pred_x_acc pred_y_acc pred_u_acc pred_v_acc piv_x_acc piv_y_acc ...
    piv_u_acc piv_v_acc intensity_wsize_acc intensity_half_wsize_acc score_acc fov_limit_acc] =...
    matchPIVToPredator(folder, file, wsize, fps, denoising_method, denoising_param, fov_left1, fov_left2, fov_right1, fov_right2)

frame_acc                   = [];
pred_x_acc                  = [];
pred_y_acc                  = [];
pred_u_acc                  = [];
pred_v_acc                  = [];
piv_x_acc                   = [];
piv_y_acc                   = [];
piv_u_acc                   = [];
piv_v_acc                   = [];
intensity_wsize_acc         = [];
intensity_half_wsize_acc    = [];
score_acc                   = [];
fov_limit_acc               = [];

% Load PIV data
pivdatapath   = strrep([folder 'PIVdata/'  file],'.avi','_PIV.mat');
if exist(pivdatapath,'file')~=2
    disp(['matchPIVToPredator: PIV data file not found in path: ' pivdatapath]);
    disp('Aborting...');
    return;
end
load(pivdatapath);


% Load Background

bgpath = [folder 'PIVdata/' file];
bgpath = strrep(bgpath, '.avi','_BG.bmp');

if exist(bgpath,'file')~=2
    disp(['matchPIVToPredator: Bg image not found in path: ' bgpath]);
    disp('Aborting...');
    return;
end
BG = imread(bgpath);
[r c nc] = size(BG);
if (nc > 1)
    BG = rgb2gray(BG);
end

% Load predator data

% Check if predator info is available
matPath = strrep(file,'.avi','_interp_extrap_path.mat');
matPath = [folder 'predator_position/' matPath];
if exist(matPath,'file')~=2
    disp(['matchPIVToPredator: mat file not found in path: ' matPath]);
    disp('Aborting...');
    return;
end
load(matPath);

% Load predator info
frames = frame_pixel_info(:,1);
predator_x = frame_pixel_info(:,2);
predator_y = frame_pixel_info(:,3);
inter_extrap = frame_pixel_info(:,4);

filepath = [folder file];
movieobj = VideoReader(filepath);
I         = read(movieobj, 1);
%nf          = info.NumFrames;
[h w z]     = size(I);
if(z>1)
    I = rgb2gray(I);
end
I = normalizeSonarImage(I);

% Create image mask to discard points out of the sonar field of view
mask_x = [6; 100; 200; 300; 394; 214; 186; 6];
mask_y = [28; 12; 4; 12; 28; 738; 738; 28];
mask = [mask_x mask_y];

mask_img = roipoly(I, mask(:,1), mask(:,2)); % Create ROI mask
mask_img = single(mask_img);
index = find(mask_img==0);
mask_img(index) = NaN; % Pixels out of the ROI are assigned to NaN

mask_img = single(mask_img);

for i = 1: length(predator_x)-1
    disp(['Analizing frame ' int2str(i) '/' int2str(length(predator_x)-1)]);
    % Get predator vector
    v = [round(predator_x(i)) round(predator_y(i)) round(predator_x(i+1)) round(predator_y(i+1))];
    
    
    % Read and mask frame
    I         = read(movieobj, frames(i));
    [h w z]     = size(I);
    if(z>1)
        I = rgb2gray(I);
    end
    I = normalizeSonarImage(I);
    I = single(I);
    %Preprocessing
    I = preprocessingSonarImage(I, BG, denoising_method, denoising_param, 0, 0);

    I = I.*mask_img;
    
%     v = vs(:,:,frames(i)); % In pixels/frame
%     u = us(:,:,frames(i)); % In pixels/frame
    
    vvv = vs(:,:,frames(i));%/fps; % In pixels/frame
    uuu = us(:,:,frames(i));%/fps; % In pixels/frame
    
    xxx = xs(:,:,frames(i));
    yyy = ys(:,:,frames(i));
    
    pkhspkhs = pkhs(:,:,frames(i));
    
%     figure(1); 
%     imagesc(I); axis equal; axis tight; colormap gray; hold on;
%     quiver(xxx,yyy,u,v,0);
%     hold
%     
%     figure(2); 
%     imagesc(I); axis equal; axis tight; colormap gray; hold on;
%     quiver(xxx,yyy,uuu,vvv,0);
    
    
    [piv_x piv_y piv_u piv_v intensity_wsize intensity_half_wsize score fov_limit] =...
        matchPIV(I, v, xxx, yyy, uuu, vvv, pkhspkhs, wsize, fov_left1, fov_left2, fov_right1, fov_right2);
    
    frame_acc                   = [frame_acc ; repmat(frames(i),size(piv_x,1),1)];
    pred_x_acc                  = [pred_x_acc ; repmat(predator_x(i),size(piv_x,1),1)];
    pred_y_acc                  = [pred_y_acc ; repmat(predator_y(i),size(piv_x,1),1)];
    pred_u_acc                  = [pred_u_acc ; repmat(predator_x(i+1)-predator_x(i),size(piv_x,1),1)];
    pred_v_acc                  = [pred_v_acc ; repmat(predator_y(i+1)-predator_y(i),size(piv_x,1),1)];
    piv_x_acc                   = [piv_x_acc ; piv_x];
    piv_y_acc                   = [piv_y_acc ; piv_y];
    piv_u_acc                   = [piv_u_acc ; piv_u];
    piv_v_acc                   = [piv_v_acc ; piv_v];
    intensity_wsize_acc         = [intensity_wsize_acc ; intensity_wsize];
    intensity_half_wsize_acc    = [intensity_half_wsize_acc ; intensity_half_wsize];
    score_acc                   = [score_acc ; score];
    fov_limit_acc               = [fov_limit_acc ; fov_limit];
    
end


end


function [piv_x piv_y piv_u piv_v intensity_wsize intensity_half_wsize score flow_limit] =...
    matchPIV(I, v, xs, ys, us,vs, pkhs, wsize, fov_left1, fov_left2, fov_right1, fov_right2)

piv_x                   = [];
piv_y                   = [];
piv_u                   = [];
piv_v                   = [];
intensity_wsize         = [];
intensity_half_wsize    = [];
score                   = [];
flow_limit               = [];

cent_x = v(1);
cent_y = v(2);
angle = atand((v(4)-v(2))/(v(3)-v(1)));

% Angle correction. Otherwise all angles would be possitive
if((v(3)-v(1)) < 0 )
    angle = angle + 180;
end

theta = 90;
r = 10;

pline_x = r * cosd(theta + angle) + cent_x;
pline_y = r * sind(theta + angle) + cent_y;

% Describe the straight line that passes through 2 points
% syms x y
% f(x,y) = (x - cent_x) / (pline_x - cent_x) - (y - cent_y) / (pline_y - cent_y);

% Check if the second point of the predator trajectory is above or below
% the straight line
%side = eval(f(v(3),v(4)));
side = distanceToStraightLine(v(3),v(4),cent_x,cent_y,pline_x, pline_y);

if side > 0
    side = 1;
else
    side = -1;
end


%piv_position = eval(f(xs,ys));

piv_position = distanceToStraightLine(xs,ys,cent_x,cent_y,pline_x, pline_y);


piv_position_side = piv_position .* side;
% Select pivs on the same side of the straight line as the predator
% direction
index = find(piv_position_side>=0);

piv_x                   = xs(index);
piv_y                   = ys(index);
piv_u                   = us(index);
piv_v                   = vs(index);
score                   = pkhs(index);


index2 = ~isnan(piv_u) | ~isnan(piv_v);
piv_x                   = piv_x(index2);
piv_y                   = piv_y(index2);
piv_u                   = piv_u(index2);
piv_v                   = piv_v(index2);
score                   = score(index2);

low_line_x1 = piv_x - wsize/2;
low_line_y1 = piv_y - wsize/2;
low_line_x2 = piv_x + wsize/2;
low_line_y2 = piv_y - wsize/2;
up_line_x1  = piv_x - wsize/2;
up_line_y1  = piv_y + wsize/2;
up_line_x2  = piv_x + wsize/2;
up_line_y2  = piv_y + wsize/2;

side_low1 = distanceToStraightLine(low_line_x1, low_line_y1, fov_left1(1), fov_left1(2), fov_left2(1), fov_left2(2));
side_low2 = distanceToStraightLine(low_line_x2, low_line_y2, fov_left1(1), fov_left1(2), fov_left2(1), fov_left2(2));
side_up1  = distanceToStraightLine(up_line_x1, up_line_y1, fov_right1(1), fov_right1(2), fov_right2(1), fov_right2(2));
side_up2  = distanceToStraightLine(up_line_x2, up_line_y2, fov_right1(1), fov_right1(2), fov_right2(1), fov_right2(2));

low_change  = side_low1 .* side_low2;
high_change = side_up1 .* side_up2;

low_change_index = low_change < 0; % Each point of the low_line on different sides of the fov
high_change_index = high_change < 0;

flow_limit = low_change_index | high_change_index;

%  imagesc(I); hold on; axis equal; axis tight; colormap gray
%  
%  
%  quiver(piv_x(flow_limit),piv_y(flow_limit),piv_u(flow_limit)*8,piv_v(flow_limit)*8,'b');
%   quiver(piv_x(~flow_limit),piv_y(~flow_limit),piv_u(~flow_limit)*8,piv_v(~flow_limit)*8,'r');

% plot([cent_x pline_x],[cent_y pline_y],'y');
% quiver(v(1),v(2),v(3)-v(1),v(4)-v(2),4),'r';

[r c] = size(I);

for i = 1:size(piv_x,1)
    
    lower_bound_x = piv_x(i)-wsize/2;
    if(lower_bound_x<1)
        lower_bound_x = 1;
    end
    
    lower_bound_y = piv_y(i)-wsize/2;
    if(lower_bound_y<1)
        lower_bound_y = 1;
    end
    
    upper_bound_x = piv_x(i)+wsize/2;
    if(upper_bound_x > c)
        upper_bound_x = c;
    end
    
    upper_bound_y = piv_y(i)+wsize/2;
    if(upper_bound_y > r)
        upper_bound_y = r;
    end   
    Iwindow = I(lower_bound_y:upper_bound_y,lower_bound_x:upper_bound_x);
    intensity_wsize = [intensity_wsize ; mean(Iwindow(~isnan(Iwindow)))];
    
    lower_bound_x = piv_x(i)-wsize/4;
    if(lower_bound_x<1)
        lower_bound_x = 1;
    end
    
    lower_bound_y = piv_y(i)-wsize/4;
    if(lower_bound_y<1)
        lower_bound_y = 1;
    end
    
    upper_bound_x = piv_x(i)+wsize/4;
    if(upper_bound_x<1)
        upper_bound_x = 1;
    end
    
    upper_bound_y = piv_y(i)+wsize/4;
    if(upper_bound_y<1)
        upper_bound_y = 1;
    end 
    Iwindow = I(lower_bound_y:upper_bound_y, lower_bound_x:upper_bound_x);
    intensity_half_wsize = [intensity_half_wsize ; mean(Iwindow(~isnan(Iwindow)))];
end


end
