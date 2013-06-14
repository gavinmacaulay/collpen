% Cells to convert the hydrophone data into Matlab files

%% Toplevel directory, underwhich the data can be found. Adjust as necessary
%rootDataDir = 'F:\collpen\AustevollExp\data\HERRINGexp\';


%% The NTNU experiment
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'NTNUexp\block1\hydrophones'))


%% The PVexp
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block1\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block2\hydrophones'))


%% The HERRINGexp
clear

rootDataDir = '\\callisto\collpen\AustevollExp\data\';
channelsToExport = [17 18];

%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block1\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block2\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block3\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block4\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block5\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block6\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block7\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block8\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block9\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block10\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block13\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block14\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block15\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block16\hydrophones'),channelsToExport)%FAILED!!!
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block17\hydrophones'),channelsToExport)%FAILED
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block18\hydrophones'),channelsToExport)%FAILED
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block18\hydrophones'),channelsToExport)%FAILED
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block19\hydrophones'))% File 9 FAILED!!!
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block20\hydrophones'))% OK!
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block21\hydrophones'))%  File 13 21_3_2 Failed
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block22\hydrophones'))% File 17 Warning: 22_3_3.tdms failed 
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block23\hydrophones'))% 
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block24\hydrophones'))% Warning: 24_3_2.tdms failed 
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block25\hydrophones'))% Warning: 25_1_1.tdms failed Warning: 25_4_1.tdms failed 
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block26\hydrophones'))% Warning: 26_1_1.tdms failed , Warning: 26_1_2.tdms failed 

%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block27\hydrophones'))%FAILED 
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block28\hydrophones'))% Warning: 28_3_1.tdms failed ok tom 17

cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block32\hydrophones'))% Warning: 26_1_1.tdms failed , Warning: 26_1_2.tdms failed 

%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block34\hydrophones'))% Warning: 26_1_1.tdms failed , Warning: 26_1_2.tdms failed 

%% The HERRINGcort

rootDataDir = '\\callisto\collpen\AustevollExp\data\';
channelsToExport =[1 2 3 4];
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGcortisol\test1\hydrophones'),channelsToExport)

cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGcortisol\test1\hydrophones'))
