function [px_relative_accumulated, py_relative_accumulated, angles_accumulated, ranges_accumulated, intensity_accumulated, ...
    frames_accumulated, gradient_accumulated, px_absolute_accumulated, py_absolute_accumulated, interpolated_extrapolated]...
          = getCircularRegionFromVideo(filepath, filename, alpha, samples, min_range, max_range, mask, denoising_method,denoising_param, debug)
%      
% This function calculates the circular region in front a predator position
% through a series of video frames. 
%
% Input:
%   - filepath : Folder in which the video is located
%   - filename : Video file to analyze
%   - alpha : amplitude of the circular region. This will be set to alpha/2
%   on each side of the predator direction
%   - samples : beans to generate each circumference
%   - min_range : minimum range for the circular region
%   - max_range : radious for the circular region
%   - mask : Image mask to avoid pixels out of sonar field of view
%   (boundary is also slightly cropped)
%   - debug : display debug information
%
% Output:
%
%
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

      
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
[~ , ~, z]     = size(BG);
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
[~ , ~, z]     = size(I);
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

grad2Dm(I,1,1); % Initialize gradient 

%textprogressbar('getCircularRegionFromVideo: Extracting video information: ');

for i = 1: length(predator_x)-1
    I         = read(movieobj, 1);
    [h, w, z]     = size(I);
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
    
    [px_relative py_relative, angle, ranges, intensity, gradient, px_absolute, py_absolute] = ...
        getCircularRegion(I, mask_img, v, h , w , alpha, samples, min_range, max_range, first_frame, debug);
    first_frame = false;
    px_relative_accumulated{i} = px_relative;
    py_relative_accumulated{i} = py_relative;
    px_absolute_accumulated{i} = px_absolute;
    py_absolute_accumulated{i} = py_absolute;
    angles_accumulated{i} = angle;
    ranges_accumulated{i} = ranges;
    intensity_accumulated{i} = intensity;
    gradient_accumulated{i} = gradient;
    frames_accumulated{i} = repmat(frames(i),[length(intensity),1]); 
    interpolated_extrapolated{i} = repmat(inter_extrap(i),[length(intensity),1]); 
    
    progress = i *100 /(length(predator_x)-1)

   % textprogressbar(progress);

end
%textprogressbar('getCircularRegionFromVideo: Done');    

end
