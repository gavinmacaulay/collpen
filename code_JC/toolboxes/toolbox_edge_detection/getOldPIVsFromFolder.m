function getOldPIVsFromFolder(folder, denoising_method, denoising_param, denoising_label)

d=dir([folder '*.avi']);

for i=1:length(d)
    filedir{i} = folder;
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata'];
if ~(exist(datafolder,'dir')==7)
    disp(['Creating data folder, ' datafolder]);
    mkdir(datafolder);
end

for i = 1:length(d)
    disp(['Processing file ' int2str(i) '/' int2str(length(d))]);
    disp(denoising_label);
    filepath = [filedir{i}  file{i}];
    % Datapath
    datapath = [folder 'PIVdata/' denoising_label{1} '/'];
    if ~(exist(datapath,'dir')==7)
        disp(['Creating data folder, ' datapath]);
        mkdir(datapath);
    end
    datapath   = strrep([datapath file{i}],'.avi','_PIV.mat');
    
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    parstrpiv64 = struct('showmsg',1,'winsize',16,'olap',0.5,'write',1,'useold',0);
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp([datestr(now),' BGImage saved as: ' filepathbg]);
    tic    
    % Estimate flow fields
    [datapath rawpivel] = JC_PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv64);
    toc
    
    
    disp(['... Writing mat file with Raw PIV vectors: ' datapath]);
    %save(datapath, 'us','vs');
    disp('Data saved');
end