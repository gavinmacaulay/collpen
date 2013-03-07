%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

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

% Example data for vessel avoidance and killer whale play back (for
% plotting a nice conceptual figure for the papers)
par.exampleVA = [21,1];
par.exampleKW = [21,4];

par.CPA = 38;

%% Run
for i=21
        cp_ProcessHydrophonedata(block(i).b_block,block,par);
end
