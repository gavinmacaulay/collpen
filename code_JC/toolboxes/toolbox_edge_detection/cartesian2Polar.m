function [angleMatlab r] = cartesian2Polar(x, y)

r = sqrt(x*x+y*y);  % radius r
if x == 0 
    if y > 0
        thetaD = 90;
    elseif y < 0
        thetaD = 270;
    else
        %disp('The angle of a zero vector is not defined!');
        thetaD = 0;   % we follow most software to assign a 0.
    end
else
    if x > 0
        if y >=0
            thetaD = atand(y/x);
        else
            thetaD = 360 + atand(y/x);
        end
    else
        thetaD = 180 + atand(y/x);
    end
end
% disp('radius = '); disp(r);
% disp('angle (in degrees) = '); disp(thetaD);

% No need to do the following check with MATLAB's answer:

angleMatlab = 180*atan2(y,x)/pi;
if angleMatlab < 0
    angleMatlab = 360 + angleMatlab;
end
% disp('angle computed using atan2 in MATLAB (in degrees): '); 
% disp(angleMatlab)
end