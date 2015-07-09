function [ranges angles] = getAnglesRangesToPredator(pred_vec, prey_rows , prey_cols)
% This function calculates the angles and ranges of all pixels defined by
% prey_rows and prey_cols to the vector of the predator trajectory
% (pred_vect).
%
% Input:
%   - pred_vec : Vector defining predator position and direction [start_x start_y end_x end_y]
%   - prey_rows : Vector defining possible prey pixels x components
%   - prey_cols : Vector defining possible prey pixels y components
%
% Output:
%   - ranges : For each prey position, ranges contains the distance to the predator
%   - angles : For each prey position, angles contains the angle with
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

predator_n = [pred_vec(3)-pred_vec(1) , pred_vec(4) - pred_vec(2)]; % Traslate predator vector to the origin of coordinates
alpha = atand(predator_n(1,1)/predator_n(1,2)); % Calculate angle with respect to the x axis

angles = [];
ranges = [];

% For each prey position 
for i = 1:length(prey_rows) 
       
    prey_n = [prey_cols(i) - pred_vec(1) , prey_rows(i) - pred_vec(2)]; % Scale to the origin of coordinates
    
    beta = atand(prey_n(1,1)/prey_n(1,2)); % Calculate angle to x axis
    
    gamma = beta - alpha; % Calculate angle to predator vector
    
    range = sqrt(prey_n(1,1)^2 + prey_n(1,2)^2); % Calculate range
    
    angles = [angles gamma];
    ranges = [ranges range];
    
end
  angles = round(angles');
ranges = round(ranges');  

end