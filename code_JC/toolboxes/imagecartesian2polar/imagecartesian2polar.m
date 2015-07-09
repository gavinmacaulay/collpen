function [H]=imagecartesian2polar(I,radius_min,radius_max,angle,make_square)

% IMAGECARTESIAN2POLAR converts a given bidimensional graycolor image from 
% cartesian coordinates to polar coordinates according to usually B-mode 
% ultrasounds image representation. 
% The input image, I(i,j), is mapped (rows->columns) to (double) polar 
% coordinates (xx,yy) and then represented as a surface (I(xx,yy))
%
% Input:
%      I:           bidimensional graycolor image
%      radius_min : min radius length
%                   accepted values: min_radius>=0
%                   by default 0
%      radius_max : max radius length {max_radius>min_radius)
%                   accepted values: max_radius>min_radius
%                   by default 100
%      angle:      # of angles to be considered for decomposition
%                  (degrees). The polar representation spans the interval
%                  [-angle/2,angle/2]
%                   accepted values: 0<=angle<=360
%                   by default 60
%      make_square: option to transform the input non-square image to a 
%                   square MxM or NxN image (the biggest one). To
%                   accomplish that, the image is resized.  This option
%                   accepts a value:
%                     0: the input image is not resized
%                     1: the input image is resized
%                   by default 0
%                   The purpose of this is only to force always the output
%                   image to show the appearance to the normally seen
%                   on echographic systems.
%
% Output:
%        H:   a handle to the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage Example:
% Example 1:
%  I=im2double(imread('cameraman.tif'));
%  imagecartesian2polar(I,0,20,30,0)
% Example 2:
%  I=im2double(imread('mri.tif'));
%  imagecartesian2polar(I,20,40)
% Example 3:
%  I=im2double(imread('testpat1.png'));
%  imagecartesian2polar(I,10,30,60,0)
% Example 4:
%  I=im2double(imread('tissue.png'));
%  imagecartesian2polar(rgb2gray(I),10,30,60,1) %convert two graycolor
% Example 5:
%  I=im2double(imread('logo.tif'));
%  imagecartesian2polar(I,10,30,360,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important:
% after the transformation, the image may show the mesh behind it, due to
% the surface representation. To avoid that, it is recommended to resize
% the image. For instance, this happens for the Example 1 "cameraman.tif", 
% To avoid it, try before the polar transformation I=imresize(I,3), and 
% the undesired visual effect is significantly reduced  (and the CPU cost 
% is also increased)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear previous variables, clean the command window and close previous
% figures
clc;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check the argument data

if (nargin < 1)
      error('Error in the number of arguments (it should be >0). Use: I,radius_min,radius_max,angle,make_square');
 end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if there are some arguments by default
 
if exist('radius_min','var') == 0
      radius_min = 0;
end

if exist('radius_max','var') == 0
      radius_max = 100;
end

if exist('angle','var') == 0
      angle = 90;
end

if exist('make_square','var') == 0
      make_square=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if the input argument data are valid

 if (radius_min < 0)
     error('radius_min sholud be >=0')
 end

 if (radius_max <= radius_min)
     error('radius_max sholud be >radius_min')
 end

 if (angle<0 && angle>360)
     error('angle sholud be  0<=angle<=360')
 end

 if (make_square ~= 0 && make_square ~= 1)
     error('make_square sholud be either 0, or, 1')
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Plot the input image (rectangular coordinates)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure(1)
% %I=imadjust(I); %activate if needed
% imshow((I));
% title('Input image (rectangular coordinates)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M N]=size(I);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the option make_square==1, the input image is resized
 if make_square==1     
    if(M>N) dim=M;
     else dim=N;
    end
    I=imresize(I,[dim dim]);
    [M N]=size(I);         
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We rotate pi/2 the input image to have the desired view
I=imrotate(I,90);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The mapping from cartesian to polar coordinates


lenses = 1.012;
lensea = [.0030 -0.0055 2.6829 48.04];
% Create lense distortion lookup table
s = lenses;
a = lensea;
theta2 = (-16:.1:16);
lenseth = theta2;
lensei  = 1+(s*(a(1)*theta2.^3 + a(2)*theta2.^2 + a(3)*theta2 + a(4)));

th = interp1(lensei, lenseth,1:N);
 
% theta_max=angle;
% step_theta=theta_max/(N-1);
step_r=(radius_max-radius_min)/(M-1);
[r,theta] = meshgrid(radius_min:step_r:radius_max, th);

xx=-r.*cos(theta*pi/180)-radius_min;
yy=-r.*sin(theta*pi/180)-radius_min;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map the input image I to the polar coordinates xx,yy and represent as 
% a surface surface (viewed from above)
figure(2);
H=surface(yy,xx,im2double(I),'edgecolor','interp'); 
colormap(gray)
view(-180,90)
%axis equal
axis off
%figure(3);
%imagesc(H);
%title('Output image mapped to polar coordinates')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Luis Gomez Deniz, Nov. 2011
% CTIM (Image Technology Center), University of Las Palmas Gran Canaria
% Canary Islands, SPAIN
% lgomez@ctim.es
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
