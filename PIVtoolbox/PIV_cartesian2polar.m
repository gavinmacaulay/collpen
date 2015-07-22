function [polarImg]=PIV_cartesian2polar(M)

X0=size(M,1)/2; Y0=size(M,2)/2;
[Y X z]=find(M);
X=X-X0; Y=Y-Y0;
theta = atan2(Y,X);
rho = sqrt(X.^2+Y.^2);

% Determine the minimum and the maximum x and y values:
rmin = min(rho); tmin = min(theta);
rmax = max(rho); tmax = max(theta);

% Define the resolution of the grid:
rres=128; % # of grid points for R coordinate. (change to needed binning)
tres=128; % # of grid points for theta coordinate (change to needed binning)

F = TriScatteredInterp(rho,theta,z,'natural');

%Evaluate the interpolant at the locations (rhoi, thetai).
%The corresponding value at these locations is polarImg:

[rhoi,thetai] = meshgrid(linspace(rmin,rmax,rres),linspace(tmin,tmax,tres));
polarImg = F(rhoi,thetai);
