% Channel 1 on the GPT was connected to the horizontal looking echo
% sounder, which was mounted on a ladder hanging off the side of the net
% pen. The transducer was placed at 1.3m depth. The channel 2 of the GPT
% was connected to the other transducer on a gimball near the bottom of the
% pen and oriented vertically (approximately 9m depth).     

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
par.ek60.displayRange=[0 11;0 9.5];% depth to display image over
par.ek60.AnalyzeRange=[.7 10 ; .3 8.5];% analyssis range for channel 1 and depth for channel 2 (min, max)
par.ek60.channelsToProcess=[1 2]; % which channels to plot
par.ek60.smoothWindow=31;% number of pings to smooth over with running mean
%par.ek60.writePath='C:\Collpen\Processing\alexCode\';% ticks plotten on x axis on this interval
par.ek60.preTrialTime=152/(24*3600) ;% time in days to plot data before and after the trial
par.ek60.minPings=par.ek60.smoothWindow*2; %minimum pings for plotting a graph if less than this, then skip
par.ek60.transdepth = 9.29;%m

% Smoothing filter for sv data
% Fs = 4.5;  % Sampling Frequency
% Fpass = 0.01;            % Passband Frequency
% Fstop = 0.01;            % Stopband Frequency
% Dpass = 0.057501127785;  % Passband Ripple
% Dstop = 0.0001;          % Stopband Attenuation
% dens  = 20;              % Density Factor
% % Calculate the order from the parameters using FIRPMORD.
% [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
% % Calculate the coefficients using the FIRPM function.
% b  = firpm(N, Fo, Ao, W, {dens});
% Hd = dfilt.dffir(b);
% par.ek60.Hd=Hd;

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
%clc
VA1=[];
VA2=[];
for i=19:36%78 80:83]Skip the last ones, these are bottle only
    disp(['Block ',num2str(i)])
    if i>36
        par.ek60.channelsToProcess=1;
    else
        par.ek60.channelsToProcess=[1 2];
    end
    [VA1sub,VA2sub]=cp_ProcessEchosounderdata(block(i).b_block,block,par);
    close all
    VA1 = [VA1;VA1sub];
    if length(par.ek60.channelsToProcess)==2
        VA2 = [VA2;VA2sub];
    end
    save VA VA1 VA2
end
xlswrite('VA1.xls',VA1)
xlswrite('VA2.xls',VA2)
VA1nonan = VA1(~isnan(VA1(:,4)),:);
VA2nonan = VA2(~isnan(VA2(:,4)),:);
xlswrite('VA1nonan.xls',VA2nonan)
xlswrite('VA2nonan.xls',VA2nonan)


%% Write figures for Guillaume

for i=26%[26 30]
    disp(['Block ',num2str(i)])
    par.ek60.channelsToProcess=[1 2];
    [~,~]=cp_ProcessEchosounderdata(block(i).b_block,block,par);
end

