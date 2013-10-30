% Example script for the CollPen PIV analysis toolbox
%
% (c) Lars Helge Stien

% Exmaple file
file = whatever; % whatever.avi
filedir = wherever;

% Parameters
par.N=20;
par.etc = 1;etc

% Establish background image
PIV_bgimage(filedir,file,par)

% Estimate flow field
PIV_flowfieldestimate(filedir,file,par)

% Estimate the PIV
PIV_fishmask(filedir,file,par)

