function [pixel_x pixely pixel_intensity pixel_angle distance] = getRegionValues(I,v, max_range, angle , steps, debug)
% Unfinished function. Other approach was develop that is better than this one
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

pixel_x = [];
pixely = [];
pixel_intensity = [];
pixel_angle = [];
distance = [];

[h w] = size(I);

I_polygons = zeros(h,w);


% Calculate angles to scan

half_angle = angle/2; % Split the angle to get the aperture on both sides of 'predator_vect' orientation
half_step = steps/2; % Half the angle implies half the steps

step_vector = []; % Initialize steps vector

for i = 0:half_angle/half_step:half_angle % get angle steps on the right side
    step_vector = [step_vector -i];
end

for i = half_angle/half_step:half_angle/half_step:half_angle % get angle steps on the left side
    step_vector = [step_vector i];
end

step_vector


[step_vector indexes] = sort(step_vector);

first_step = step_vector(1);
vectors = size(step_vector);

 for i = step_vector(2:length(vectors))
     vr = rotateVector(v, i, debug); % Range to detect boundaries 
    
 end

end


