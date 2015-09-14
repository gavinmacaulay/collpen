function getIntensitiesAheadPredatorFromVideo(filepath, filename, mask, min_range,...
    max_range, denoising_method,denoising_param, debug)


% Check if predator info is available      
matPath = strrep(filename,'.avi','_interp_extrap_path.mat');
matPath = [filepath 'predator_position/' matPath];
if exist(matPath,'file')~=2
    disp(['getCircularRegionFromVideo: mat file not found in path: ' matPath]);
    disp('Aborting...');
    return;
end
load(matPath);

% Check whether BG image is available
datafolder = [filepath 'PIVdata'];
tmpfilepathbg = strrep([datafolder '/' filename],'.avi','_BG.bmp');
if exist(tmpfilepathbg,'file')~=2
    disp(['getCircularRegionFromVideo: BG file not found in path: ' tmpfilepathbg]);
    disp('Aborting...');
    return;
end
BG = imread(tmpfilepathbg); % Load bg image 
[h w z]     = size(BG);
if(z>1)
    BG = rgb2gray(BG);
end

%BG = normalizeSonarImage(BG); % Normalize bg
mask_img = roipoly(BG, mask(:,1), mask(:,2)); % Create ROI mask
mask_img = single(mask_img);
index = find(mask_img==0);
mask_img(index) = NaN; % Pixels out of the ROI are assigned to NaN


movieobj = VideoReader([filepath filename]);

I         = read(movieobj, 1);
nf          = movieobj.NumberOfFrames;
[h w z]     = size(I);
if(z>1)
    I = rgb2gray(I);
end

% Initialize information containers
px_relative_accumulated = [];
py_relative_accumulated = [];
px_absolute_accumulated = [];
py_absolute_accumulated = [];
angles_accumulated = [];
ranges_accumulated = [];
intensity_accumulated = [];
frames_accumulated = [];
gradient_accumulated = [];
interpolated_extrapolated = [];

% Load predator info
frames = frame_pixel_info(:,1);
predator_x = frame_pixel_info(:,2);
predator_y = frame_pixel_info(:,3);
inter_extrap = frame_pixel_info(:,4);
first_frame = true;

for i = 1: length(predator_x)-1
    I         = read(movieobj, 1);
    [h w z]     = size(I);
    if(z>1)
        I = rgb2gray(I);
    end
    %I = normalizeSonarImage(I); % Normalize
    % Background subtraction
    %I = abs(I-BG);   
    
    I = preprocessingSonarImage(I,BG,denoising_method,denoising_param,0,0);

    % Apply mask (change of plans. Mask will be applied inside
    % getCircularRegion. This makes sense as a gaussian filter will be
    % applied to the image, adding some noise at the edge    
    v = [round(predator_x(i)) round(predator_y(i)) round(predator_x(i+1)) round(predator_y(i+1))];
   
end



end


function getIntensitiesAheadPredator(I, mask_img, v, min_range,max_range, ...
    denoising_method,denoising_param, debug)
    
I = I.*mask_img;

% Get pixel index inside min_range

[r c] = size(I);
[R C] = ndgrid(1:r,1:c);
circle = [v(1), v(2), min_range];
points = [R(:),C(:)];
index_min_range = inCircle(points,circle);



% Get pixel index inside max_range
circle = [v(1), v(2), max_range];
index_max_range = inCircle(points,circle);

% Subtract
index_circle = index_max_range & ~index_min_range;

R_circle = R(index_circle);
C_circle = C(index_cicle);

% Get pixels ahead of the predator
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

% Check if the second point of the predator trajectory is above or below
% the straight line

side = distanceToStraightLine(v(3),v(4),cent_x,cent_y,pline_x, pline_y);
if side > 0
    side = 1;
else
    side = -1;
end
pixel_position = distanceToStraightLine(R_circle,C_circle,cent_x,cent_y,pline_x, pline_y);
pixel_position_side = pixel_position .* side;

index = piv_position>=0;

px_relative_predator = C(index)-cent_x;
py_relative_predator = R(index)-cent_y;


end