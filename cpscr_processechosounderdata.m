%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
par.datadir = 'F:\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial';

% used by rawreading function - cpsrReadEK60
par.ek60.timeZoneOffset=2;  % Time offset using +2 as data timestamps are utc and we are +2 (check this if timestamps look strange)
par.ek60.useCalParFile=0;  % 1 means use a file after calibration, 2 is just use whatever is in raw data for uncalibrated calcs
par.ek60.calFileName='';   % name of EK60 calibration file to use if par =1
par.ek60.channelsWanted=[1 2]; %channels wanted

% used by plotting function - cpsrPlotEK60
par.ek60.displayThreshold=[-70 -34] ; % display threshold for plotting
par.ek60.displayRange=[0 9.5;0 9.5];% depth to display image over
par.ek60.AnalyzeRange=[1 9 ; 1 9];% analyssis range (min, max) by channel
par.ek60.channelsToProcess=[1 2]; % which channels to plot
par.ek60.smoothWindow=31;% number of pings to smooth over with running mean
%par.ek60.writePath='C:\Collpen\Processing\alexCode\';% ticks plotten on x axis on this interval
par.ek60.preTrialTime=120/(24*3600) ;% time in days to plot data before and after the trial

% Parameters and metadata
file = fullfile(par.reposdir,'matlabtoolbox\CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

%% Run
for i=17%:33
        cp_ProcessEchosounderdata(block(i).b_block,block,par);
end


