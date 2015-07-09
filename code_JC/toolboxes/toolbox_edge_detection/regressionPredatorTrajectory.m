function [reg_x reg_y reg_frames_x reg_frames_y mx my] = ...
    regressionPredatorTrajectory(predator_x, predator_y, frames, debug)


if(debug)
    subplot(1,3,1)
end

X = [predator_x ones(size(predator_x,1),1)]; % Add column of 1's to include constant term in regression
a = regress(predator_y,X) ;  % = [a1; a0]
if(debug)
    plot(predator_x,X*a,'-');  % This line perfectly overlays the previous fit line
    hold all
    
end
reg_x =  predator_x;
reg_y =  X*a;


Xx = [predator_x ones(size(predator_x,1),1)]; % Add column of 1's to include constant term in regression
a = regress(frames,Xx) ;  % = [a1; a0]
if(debug)
    subplot(1,3,2)
    plot(Xx*a,predator_x,'-');  % This line perfectly overlays the previous fit line
    hold all
    title('Frames vs. X');
end
reg_frames_x = Xx*a;

% Calculate the slope of the segments frame,x
regression_x = Xx*a;

m = (predator_x(end)-predator_x(1))/(regression_x(end)-regression_x(1));
mx = m;


Xy = [predator_y ones(size(predator_y,1),1)]; % Add column of 1's to include constant term in regression
a = regress(frames,Xy) ;  % = [a1; a0]
if(debug)
    subplot(1,3,3)
    plot(Xy*a,predator_y,'-');  % This line perfectly overlays the previous fit line
    hold all
    title('Frames vs. Y');
end
reg_frames_y = Xy*a;

% Calculate the slope of the segments frame,y
regression_y = Xy*a;

m = (predator_y(end)-predator_y(1))/(regression_y(end)-regression_y(1));
my = m;


end