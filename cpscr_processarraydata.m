%% Process hydrophone array data and create figures in the figure directory

% Data directory
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = '.\matlabtoolbox';

% Parameters and metadata
file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

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
for i = 21:35
    cp_ProcessArraydata(block(i).b_block,block,par);
end
