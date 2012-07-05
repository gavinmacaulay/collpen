% Cells to convert the hydrophone data into Matlab files

%% Toplevel directory, underwhich the data can be found. Adjust as necessary
rootDataDir = 'F:\collpen\AustevollExp\data\HERRINGexp\';


%% The NTNU experiment
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'NTNUexp\block1\hydrophones'))


%% The PVexp
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block1\hydrophones'))
%cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block2\hydrophones'))


%% The HERRINGexp
clear
rootDataDir = 'F:\collpen\AustevollExp\data\';
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
cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'HERRINGexp\block18\hydrophones'),channelsToExport)

