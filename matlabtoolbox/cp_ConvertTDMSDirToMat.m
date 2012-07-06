function cp_ConvertTDMSDirToMat(dataDir,channelsToExport)

% A function to convert all TDMS files in the given directory into
% Matlab structures.
% Designed for the NTNU hydrophone data from the Austevoll Collpen
% experiments.
%
% channels is converting only the cannels specified

d = dir(fullfile(dataDir, '*.tdms'));
warning('hack')
for i = 1:9%10:length(d)
    if exist(fullfile(dataDir,d(i).name))
        if nargin<2
            cp_ReadAndSaveTDMSFile(dataDir, d(i).name);
        else
            cp_ReadAndSaveTDMSFile(dataDir, d(i).name,channelsToExport);
        end
    else
        warning(['No data file in ',dataDir, d(i).name])
    end
end