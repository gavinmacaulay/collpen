% Cells to convert the hydrophone data into Matlab files

%% Toplevel directory, underwhich the data can be found. Adjust as necessary
rootDataDir = '..\2012 June\';


%% The NTNU experiment
cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'NTNUexp\block1\hydrophones'))


%% The PVexp
cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block1\hydrophones'))
cp_ConvertTDMSDirToMat(fullfile(rootDataDir, 'PVexp\block2\hydrophones'))

