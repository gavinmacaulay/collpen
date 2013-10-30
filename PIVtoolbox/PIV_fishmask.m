function = PIV_fishmask(filedir,file,par)
%function = PIV_fishmask(filedir,file,par)
%
% Estimate the mask where fish/no fish are present in the PIV array
% 
% Input:
% file    : Avi file name from didson without the .avi extension
% filedir : Directory to store output files
% par     : Parameter structure
% par.N   : Number of frames to establish bg image (or whatever)
%
% Input files (must be in filedir)
% [file'_PIV.mat'] - PIV estimates
% 
% Outputfiles (written to fildir):
%?
%
% The CollPen PIV analysis toolbox
% (c) Lars Helge Stien
%

file = fullfile(filedir,file);

% and so on

