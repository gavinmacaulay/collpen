%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
par.datadir = 'F:\collpen\AustevollExp\data\HERRINGexp';

% Parameters and metadata
file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

% file2 = fullfile(par.datadir,'block.mat');
% load(file2)

% Parameters for the spectrogram
par.avgtime = 0.1;%s
par.p_ref = 1e-6; % [Pa]
par.ws=10000*60*4;%4 min of 8khz sampling
par.Nwindow=256*4;
par.Nfft=256*8;
par.Noverlap=fix(par.Nwindow/2);

%% Run
for i=14
        cp_ProcessHydrophonedata(block(i).b_block,block,par);
end
