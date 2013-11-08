function = PIV_bgimage(filedir,file,par)
%function = PIV_bgimage(filedir,file,par)
%
% Bacground estimation
% 
% Input:
% file    : Avi file name from didson without the .avi extension
% filedir : Directory to store output files
% par     : Parameter structure
% par.N   : Number of frames to establish bg image (or whatever)
%
% Outputfiles (written to fildir):
% [file'_bg.bmp'] - Background image

%
% The CollPen PIV analysis toolbox
% (c) Lars Helge Stien
%

file = fullfile(filedir,[file,'.avi']);

% and so on

