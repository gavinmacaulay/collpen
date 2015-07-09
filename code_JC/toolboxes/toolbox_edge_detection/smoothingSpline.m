function [x_interp y_interp] = smoothingSpline(x_in, y_in)


x_interp = (min(x_in):1:max(x_in))';

% In fact, the formulation used by csapi (p.235ff of A Practical Guide to Splines) 
% is very sensitive to scaling of the independent variable. A simple analysis of 
% the equations used shows that the sensitive range for p is around 1/(1+epsilon), 
% with epsilon := h^3/16, and h the average difference between neighboring sites. 
% Specifically, you would expect a close following of the data when p = 1/(1+epsilon/100)
% and some satisfactory smoothing when p = 1/(1+epsilon*100).

epsilon = ((x_in(end)-x_in(1))/(numel(x_in)-1))^3/16;

p = 1/(1+epsilon*10^3);

y_interp = csaps(x_in, y_in, p, x_interp);


end