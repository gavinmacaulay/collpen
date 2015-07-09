function [px_relative_predator py_relative_predator angles ranges intensity gradient px_absolute_predator py_absolute_predator] = ... 
    getCircularRegion(I, I_mask, v, h , w , alpha, samples, min_range, max_range, first_frame, debug)

% This function obtains a circular sector with center in v two first values
% and an angle and radius defined by alpha and range, respectiely. The
% circular region is generated generating parts of circumferences
% incrementally untill "range" is reached
%
% Input:
%   - v : reference vector [x1 , y1 , x2 , y2] associated to the predator
%   direction
%   - h : height of the sonar image to set the bounds of the circular
%   region
%   - w : width of the sonar image to set the bounds of the circular
%   region
%   - alpha : amplitude of the circular region. This will be set to alpha/2 on each side
%   of the direction of v
%   - samples : beans to generate each circumference
%   - min_range : minimum range for the circular region
%   - max_range : radious for the circular region
%   - first_frame : Flag to initialize gradient calculation
%   - debug : display debug information 
%
% Output:
%   - px_relative_predator 
%   - py_relative_predator 
%   - angles 
%   - ranges 
%   - intensity 
%   - gradient
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com


I = single(I);
[rows cols] = size(I);

centx = v(1);
centy = v(2);

px_absolute_predator = [];
py_absolute_predator = [];
angles = [];
ranges = [];
px_relative_predator = [];
py_relative_predator = [];

angle = atand((v(4)-v(2))/(v(3)-v(1)));

% Angle correction. Otherwise all angles would be possitive
if((v(3)-v(1)) < 0 )
    angle = angle + 180;
end

for r=min_range:1:max_range

    %theta = 0 : ((alpha) / 1000) : (alpha);
    
   % theta = -alpha/2 : ((alpha)/samples) : alpha/2;
    theta = -alpha/2 : ((alpha)/(1.2*pi*r)) : alpha/2; % Adaptative bean calculation with respect to the distance
    % theta = theta;
    
    % pixel position using predator position as origin of coordinates
    px_pred = r * cosd(theta); 
    py_pred = r * sind(theta);   

    a = size(theta,2);
    b = size(px_pred,2);

    
    
    % Absolute pixel position with respect to the image
    pline_x = r * cosd(theta + angle) + centx;
    pline_y = r * sind(theta + angle) + centy;
    
    
    % Filter out points out of the image
    %index = find(pline_x'<c & pline_x'>0 & pline_y'<r & pline_y'>0);
    index = find(pline_x'<cols & pline_x'>0 );

    px_pred = px_pred(index);
    py_pred = py_pred(index);
    pline_x = pline_x(index);
    pline_y = pline_y(index);
    theta   = theta(index);
    
    index = find(pline_y'<rows & pline_y'>0 );
    px_pred = px_pred(index);
    py_pred = py_pred(index);
    pline_x = pline_x(index);
    pline_y = pline_y(index);
    theta   = theta(index);


    px_relative_predator = [px_relative_predator ; px_pred'];
    py_relative_predator = [py_relative_predator ; py_pred'];
    px_absolute_predator = [px_absolute_predator ; pline_x'];
    py_absolute_predator = [py_absolute_predator ; pline_y'];
    angles = [angles ; theta'];
    ranges = [ranges ; repmat(r,1,length(pline_x))'];
    %     if(debug)
    %         plot((pline_x), (pline_y), '.r');
    %         axis equal
    %         axis tight
    %     end
end

% Get temporal gradient gt

[gy gx gt] = grad2Dm(I,1);

gt = abs(gt);

% apply mask
gt = gt .* I_mask;
I = I .* I_mask;
% 
% if(debug)
%     subplot(1,2,1);    
%     imagesc(I);
%     hold on;
%     axis equal
%     axis tight
%     plot((px_absolute_predator), (py_absolute_predator), '.r');
%     axis equal
%     axis tight
%     quiver(v(1),v(2), v(3)-v(1),v(4)-v(2),2);
%     
%     subplot(1,2,2);
%     imagesc(gt);
%     hold on;
%     plot(centx,centy,'or');
%     axis equal
%     axis tight
% end


% Filter points out of bounds


pxr = round(px_absolute_predator);
pyr = round(py_absolute_predator);

intensity = [];
gradient = [];

for i = 1:size(pxr,1)
    
    if(pxr(i) > 0 && pyr(i)>0 && pxr(i)< w && pyr(i) < h)
        intensity_pixel = I(pyr(i), pxr(i));
        gradient_pixel = gt(pyr(i), pxr(i));
%          if(intensity_pixel == 0)
%              intensity_pixel = NaN;
%              gradient_pixel = NaN;
%          end
    else
        intensity_pixel = NaN;
        gradient_pixel = NaN;
    end
    
    
    intensity = [intensity ; intensity_pixel];
    gradient = [gradient ; gradient_pixel];
end

if(debug)
    K = I;
    figure(1); imagesc(I); axis equal; axis tight; colormap gray;
    hold on
    quiver(v(1),v(2), v(3)-v(1),v(4)-v(2),2);
    J = zeros(rows,cols);
    %figure; 
    %plot(pxr,pyr,intensity,'.');
    for i = 1:size(intensity,1)
        if(pxr(i)>0 && pyr(i)>0)
        J(pyr(i),pxr(i)) = intensity(i);
        
        K(pyr(i),pxr(i)) = abs(K(pyr(i),pxr(i)) - intensity(i));
        
        
        end
    end
    figure(2); imagesc(J); axis equal; axis tight; colormap gray;
    figure(3); imagesc(K); axis equal; axis tight; colormap gray;

end

% Filter out NaN values
% index = ~any(isnan(intensity),2);
% intensity = intensity(index,:);
% gradient = gradient(index,:);
% px = px(index,:);
% py = py(index,:);
% angles = angles(index,:);
% ranges = ranges(index,:);

end

