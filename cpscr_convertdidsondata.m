%% Create avi from Didson data relative to each "passing"
clear
close all

%% Create time stamp data
clear
rootDataDir = '\\callisto\collpen\AustevollExp\data';

% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block0\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block1\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block2\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block3\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block4\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block5\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block6\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block7\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block8\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block9\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block10\didson'),'T')

%cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block13\didson'),'T')
%cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block14\didson'),'T')
%cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block15\didson'),'T')
%cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block16\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block17\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block18\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block19\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block20\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block21\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block22\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block23\didson'),'T') 
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block24\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block25\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block26\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block27\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block28\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block29\didson'),'T')
% 
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block30\didson'),'T') 
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block31\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block32\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block33\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block34\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block35\didson'),'T')
cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block36\didson'),'T')

%% The HERRINGexp - creating the avi per treatment
clc
% Data directory
%par.datadir = 'G:\collpen\AustevollExp\data\HERRINGexp';
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.parfile ='\\callisto\collpen\AustevollExp\data\HERRINGexp\CollPenAustevollLog.xls';

% used by plotting function 
par.didson.preTrialTime = 8/(24*3600) ;% time in days to plot data before and after the trial

% Parameters and metadata
block = cp_GetExpPar(par.parfile);

%17:36

% Functions to convert Didson data to mat and avi files
for i=36%34:36%17:36
    cp_ProcessDidsondata(block(i).b_block,block,par);
end

%% The HERRINGcort

%% Covnert the Salmondata to mat and avi files

rootDataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp\';
cp_ConvertDidsonToMat(fullfile(rootDataDir, 'salmondata','A'))




