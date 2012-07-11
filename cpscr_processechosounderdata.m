%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
par.datadir = 'F:\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\matlabtoolbox';

% Parameters and metadata
file = fullfile(par.reposdir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

%% Run
for i=17:33
        cp_ProcessEchosounderdata(block(i).b_block,block,par);
end


