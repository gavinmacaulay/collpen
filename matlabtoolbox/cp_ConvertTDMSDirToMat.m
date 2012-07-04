function cp_ConvertTDMSDirToMat(dataDir)

% A function to convert all TDMS files in the given directory into
% Matlab structures.
% Designed for the NTNU hydrophone data from the Austevoll Collpen
% experiments.

d = dir(fullfile(dataDir, '*.tdms'));
for i = 1:length(d)
    if exist(fullfile(dataDir,d(i).name))
        cp_ReadAndSaveTDMSFile(dataDir, d(i).name);
    else
        warning(['No data file in ',dataDir, d(i).name])
    end
end