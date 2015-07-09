function vr = rotateVector(v, theta, debug)
% This function rotate a vector a determined angle
% The input vector 'v' is alocated as a 4 components array:
% v = [originx, originy, endx, endy] and the output 'vr' as well
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

% Traslate vector to the origin of coordinate (0,0)
p = [v(3) - v(1) , v(4) - v(2)];

% Generate rotation matrix
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

rotated_p = double(R) * double(p');

% Translate vector back to v's origin of coordinates
vr = [v(1) , v(2) , rotated_p(1) + v(1) , rotated_p(2) + v(2)];
vr = round(vr);

if(debug)
    hold on
    grid on
    quiver(vr(1), vr(2), ((vr(3)-v(1))), ((vr(4)-v(2))));
end

end