% Functions:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File conversion functions  :
%
% cp_ConvertExposurepar - Cov
%
% cp_ConvertCurrent - reads and converts the CARUSO power supply current measurement files into a Matlab formatted file. 
%                        Will merge together multiple files into one Matlab file.
%
% cp_ConvertTDMStoMat - reads and convert the NI TDMS hydrophone files into Matlab format files.
% cp_ConvertDidsonToMat - Convert didson files to mat files OR generate a timeindex for the didson files.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data processing functions:
%
% cp_CalibrationConstant - Get the calibration constant for each frequency for the tone stimuli
% cp_ProcessDidsondata - Reads the didson files and generates movies for each treatment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other:
%
% xml_write - Write an xml file from a matlab struct 
%
% Scripts (to be moved later):
% cpscr_masterconvertdata - The master script for converting data
% cpscr_tonetreatmentblock - The script for running one block (change block number before running each block)
%