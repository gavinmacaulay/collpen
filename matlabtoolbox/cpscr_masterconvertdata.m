%% This script contains the data conversion

datadir  = 'Q:\collpen\AustevollExp\data\';
exposure = 'HERRINGexp';

%% Read block meta data
%TODO

%% Converting the sound exposure matlab file to xml
for block = 1:5
    path = fullfile(datadir,exposure,['block',num2str(block)],'soundstimuli');
    file = ['par_block',num2str(block),'.mat'];
    if exist(fullfile(path,file))
%        try
            cp_ConvertExposurepar(path,file)
 %       end
    else
        warning(['No parameterfile for block ',num2str(block)])
    end
end
