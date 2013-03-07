%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
%par.datadir = 'G:\collpen\AustevollExp\data\HERRINGexp';
par.datadir='\\callisto\collpen\AustevollExp\data\HERRINGexp';
%par.reposdir = 'C:\repositories\CollPen_mercurial';
par.reposdir ='C:\repositories\CollPen_mercurial';
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
par.ek60.preTrialTime=152/(24*3600) ;% time in days to plot data before and after the trial
par.ek60.minPings=par.ek60.smoothWindow*2; %minimum pings for plotting a graph if less than this, then skip
par.ek60.transdepth = 9.29;%m

par.ek60.preRefTimeVA = ([-152 -88]+21);% time in seconds to define the reference window for vessel avoidance (adjusted for the difference bewtween start time and max pressure, i.e +21s)
par.ek60.passTimeVA   = [-3 3]+21;% time in seconds to define the reference window for killer whale pb
par.ek60.preRefTimeKW = [-152 -88];% time in seconds to define the reference window for killer whale pb
par.ek60.passTimeKW   = [0 60];% time in seconds to define the reference window for killer whale pb

% Example data for vessel avoidance and killer whale play back (for
% plotting a nice conceptual figure for the papers)
par.exampleVA = [21,1];
par.exampleKW = [21,4];



% Parameters and metadata
file = fullfile(par.datadir,'\CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

%% Run
% first run processed from 17 to 33

% block30 throws this error
% Warning: Invalid datagram at offset 14091480(d) - Searching for next datagram...
%these two files have malformed telegrams and can't be read so I moved them
%into a subdirectory named malformed in block 30
%HerringExp-D20120710-T075240.raw
%HerringExp-D20120710-T044626.raw
clc
VA=[];
for i=18:36
    disp(['Block ',num2str(i)])
    VAsub=cp_ProcessEchosounderdata(block(i).b_block,block,par);
    VA = [VA;VAsub];
    save VA VA
end
xlswrite('VA.xls',VA)
VA2 = VA(~isnan(VA(:,4)),:);
xlswrite('VAnonan.xls',VA2)

