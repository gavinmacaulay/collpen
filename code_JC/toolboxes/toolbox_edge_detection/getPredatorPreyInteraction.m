function [intensity rows cols ranges angles] = getPredatorPreyInteraction(I, predator_dir , alpha , samples , min_range, max_range , debug)
% Given a frame that contains a predator, a circular region in front of it is
% created and used as a mask on the frame to identify those pixels inside it.
% Thus, for each pixel its position is returned (rows, cols) as well as the
% intensity value, its distance to the predator (ranges) and the angle. The
% circular region is built by means of adding curves with different
% radius
%
% Input:
%   - I : Frame to analyze
%   - predator_dir : Vector containing predator position and direction
%   - alpha : Aperture of the circular region (180 means semi-circle)
%   - samples : Number of beans to define the circular region. 
%   - range : Maximum radius of the circular region
%   - debug : Parameter to display the results
%
% Output:
%   - intensity : Intensity values of the pixels inside the circular region
%   - rows : y coordinates of the pixels inside the circular region
%   - cols : x coordinates of the pixels inside the circular region
%   - ranges : distance of the pixels (x,y) to the predator origin of
%   coordinates
%   - angles : angle between predator direction and the vector
%   (predator_origin, eax_pixel_in_circular_region)
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com


[h w] = size(I); % Get size height and width of I

mat = getCircularRegion(predator_dir, h , w , alpha, samples, min_range, max_range); % Generate the circular region mask

I_masked = I .* uint8(mat); % Apply mask


% Find non zero pixels in the masked image
[rows cols intensity] = find(I_masked);


% Calculate angles and ranges to the predator vector
[ranges angles] = getAnglesRangesToPredator(predator_dir , rows , cols);

% Display result
if(debug)
    colormap gray
    
    subplot(1,3,1)
    imagesc(I);
    axis equal
    subplot(1,3,2);
    imagesc(mat);
    axis equal
    subplot(1,3,3);
    
    imagesc(I_masked);
    axis equal
    hold on
    quiver(predator_dir(1), predator_dir(2) , predator_dir(3) - predator_dir(1) , predator_dir(4) - predator_dir(2));
    
    %plot(x,y,'r');
    axis equal
end
end