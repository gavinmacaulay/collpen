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
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block36\didson'),'T')

% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block37\didson'),'T')

% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block38\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block39\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block40\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block41\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block42\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block43\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block44\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block45\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block46\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block47\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block48\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block49\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block50\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block51\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block52\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block53\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block54\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block55\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block56\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block57\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block58\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block59\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block60\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block61\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block62\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block63\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block64\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block65\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block66\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block67\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block68\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block69\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block70\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block71\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block72\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block73\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block74\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block75\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block76\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block77\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block78\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block79\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block80\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block81\didson'),'T')
% cp_ConvertDidsonToMat(fullfile(rootDataDir, 'HERRINGexp\block82\didson'),'T')



%% The HERRINGexp - creating the avi per treatment
clear
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
for i=17:82
    try
    cp_ProcessDidsondata(block(i).b_block,block,par);
    end
end

%% Calculate school parameters (This is Lars' part)

% Data directory
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.parfile ='\\callisto\collpen\AustevollExp\data\HERRINGexp\CollPenAustevollLog.xls';

% Parameters and metadata
block = cp_GetExpPar(par.parfile);

%par.didson.preTrialTime = 8/(24*3600) ;% time in days to plot data before and after the trial

% The time lag before during/exposure for VA data
par.preRefTimeVA = ([-152 -88]+21)/(24*3600);% time in seconds to define the reference window for vessel avoidance (adjusted for the difference bewtween start time and max pressure, i.e +21s)
par.passTimeVA   = ([-3 3]+21)/(24*3600);% time in seconds to define the reference window for VA pb
par.preRefTimeKW = ([-152 -88])/(24*3600);% time in seconds to define the reference window for killer whale pb
par.passTimeKW   = ([0 60])/(24*3600);% time in seconds to define the reference window for killer whale pb
par.preRefTimeWB = ([0 30])/(24*3600);% time in seconds to define the reference window for the 2013 experiment. Note that this is different from the 2012 experiment

% Functions to extract school parameters
for i=48:82%48:82%17:82
    try
    cp_ProcessDidsonSchoolParameters(block(i).b_block,block,par);
    end
end


%% The HERRINGcort

%% Covnert the Salmondata to mat and avi files

rootDataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp\';
cp_ConvertDidsonToMat(fullfile(rootDataDir, 'salmondata','A'))




