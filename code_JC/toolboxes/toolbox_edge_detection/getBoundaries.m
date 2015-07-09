function [distances edges_x edges_y step_angle] = getBoundaries(img, predator_vect, angle, step, debug)

% This function calculate the distances from a reference point and
% orientation (predator_vect) to a subset of boundaries in the input image
% (img).

% Inputs:
%   - img : binary image
%   - predator_vect: reference vector with position and orientation
%   - angle : aperture to check distances (in degrees)
%   - steps : number of steps to cover 'angle' (uint8)
%
% Output: 
%   - distances : array containing the euclidean distance to the edges (-1 if
%   no edge is found)
%   - edges_x : array containing edges x component (-1 if no edge is found)
%   - edges_y : array containing edges y component (-1 if no edge is found)
%   - step_angle : angle at which each edge has been searched
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com



distances = [];
edges_x = [];
edges_y = [];
step_angle = [];

% If the predator is contained in the binary image the algorithm deletes it

% figure;
% imagesc(img);
% hold on
% plot(predator_vect(1),predator_vect(2),'ro');
% If predator position is not 0
if(img(predator_vect(2),predator_vect(1))~=0)
    labels = bwlabel(img,4); % label image regions
    label = labels(predator_vect(2),predator_vect(1)); % get label that matches predator positon
    img(labels==label)=0; % delete predator region  
end

if(debug)
  subplot(1,2,1);
  colormap gray;
  imagesc(img);
  hold on;
end

% figure;
% imagesc(img);

% Calculate angles to scan
half_angle = angle/2; % Split the angle to get the aperture on both sides of 'predator_vect' orientation
half_step = step/2; % Half the angle implies half the steps

step_vector = []; % Initialize steps vector
for i = 0:half_angle/half_step:half_angle % get angle steps on the right side
    step_vector = [step_vector -i];
end

for i = half_angle/half_step:half_angle/half_step:half_angle % get angle steps on the left side
    step_vector = [step_vector i];
end

for i = step_vector
    vr = rotateVector(predator_vect, i, debug); % Range to detect boundaries
    
    % Move in img along vr to get the first non zero pixel (boundary)
    [d e_x e_y] = getBoundary(img, vr);
    
    if(debug)
        if(e_x ~= NaN)
        quiver(vr(1),vr(2), e_x - vr(1), e_y - vr(2));
        end
    end
    
    distances = [distances d];
    edges_x = [edges_x e_x];
    edges_y = [edges_y e_y];
    step_angle = [step_angle i];
end

% The results initially follow this pattern: 
%      0,-step_angle,-2*step_angle,...,step_angle,2*step_angle,... 
% For the plot to make more sense, the output is sorted
%      ...,-2*step_angle,-step_angle,0,step_angle,2*step_angle,...
[step_angle indexes] = sort(step_angle);
distances = distances(indexes);
edges_x = edges_x(indexes);
edges_y = edges_y(indexes);

if(debug)
  hold on
  quiver(predator_vect(1),predator_vect(2),predator_vect(3)-predator_vect(1),predator_vect(4)-predator_vect(2));
  plot(edges_x, edges_y, '.','markerSize',8);  %Plot found edges
  title('Vectors');
  
  subplot(1,2,2);
  plot(step_angle,distances);
  title('Detected edges');
  ylabel('Distance to the edge');
  xlabel('Angle');
end

end


