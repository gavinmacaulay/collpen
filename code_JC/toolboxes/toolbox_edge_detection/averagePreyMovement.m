function [x, y, u, v] =  averagePreyMovement(fr,px,py)

% Xx = [fr ones(size(fr,1),1)];
% a = regress(px,Xx);
% 
% Yy = [fr ones(size(fr,1),1)];
% b = regress(py,Yy);
% 
% reg_x = Xx*a;
% reg_y = Yy*b;

% For 3 points the mean is equivalent to applying regression
x = mean(px);
y = mean(py);

inc_x = (px(3)-px(1))/2;
inc_y = (py(3)-py(1))/2;

u = inc_x;
v = inc_y;

end