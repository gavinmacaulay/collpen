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

par.calibration = [ones(1,16)*11.53 1 1]; % [Pa/V]

%% Run

% some blocks had problems with the recording of array data (channels
% missing and others full of noise). Channel 1 never seemed to work and
% channel 8 was intermittent. Blocks 27, 28, and 29 are the best set of
% data with only channel 1 missing. Block 27_3_2 has some noise at the end
% of the recording, and block 29 is noisy, so we focus
% on block 28 for the manuscript...

par.export_plot = true;
for i = 21:35
    cp_ProcessArraydata(block(i).b_block,block,par);
end

