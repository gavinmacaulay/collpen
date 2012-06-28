% Functions:
% 
% File converion functions:
% cp_ConvertExposurepar - Cov
%
% cp_ConvertCurrent - reads and converts the CARUSO power supply current measurement files into a Matlab formatted file. 
%                        Will merge together multiple files into one Matlab file.
%
% cp_ConvertTDMStoMat - reads and convert the NI TDMS hydrophone files into Matlab format files.
%
% Data processing functions:
% cp_CalibrationConstant - Get the calibration constant for each frequency for the tone stimuli
%
% Other:
% xml_write - Write an xml file from a matlab struct 
%
% Scripts (to be moved later):
% cpscr_masterconvertdata - The master script for converting data
% cpscr_tonetreatmentblock - The script for running one block (change block number before running each block)
%