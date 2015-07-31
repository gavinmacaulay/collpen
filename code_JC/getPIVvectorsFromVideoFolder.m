function getPIVvectorsFromVideoFolder(folder, winsize)
% Data will be saved following this scheme:
% ./PIVdata/denoising_label/avi_file_name.mat

disp('[getPIVvectorsFromVideoFolder]: Start');

if folder(end)~='/'
    folder = [folder '/'];
end

d=dir([folder '*.avi']);

% Datafolder
datafolder = [folder 'PIVdata/'];
if ~(exist(datafolder,'dir')==7)
    disp(['Creating data folder, ' datafolder]);
    mkdir(datafolder);
end

for i = 1:length(d)
    disp(['[getPIVvectorsFromVideoFolder]: Processing file ' int2str(i) '/' int2str(length(d))]);
    
    % Datapath
    datapath = [folder 'PIVdata/' int2str(winsize) '/' ];
    if ~(exist(datapath,'dir')==7)
        disp(['Creating data folder, ' datapath]);
        mkdir(datapath);
    end
    datapath   = strrep([datapath d(i).name],'.avi','_PIV.mat');
    
    parstrpiv64 = struct('showmsg',1,'winsize',winsize,'olap',0.5,...
                         'write',1,'useold',0);
    [xs ys us vs snrs pkhs is] = getPIVvectorsFromVideo(folder, d(i).name, parstrpiv64);

 % Filter vectors
%     parstrfilt = struct('showmsg',1,'global',4,'timeaverage',5,'localmedian',[3 3]);
% 
%     [xs ys us vs snrs pkhs is] = PIV_filterPIVvectors(xs, ys, us, vs, snrs, pkhs, is, parstrfilt);

        % writing mat file with vectors
        
    % Discard NaN values
    
    i_us = isnan(us);
    us(i_us) = 0;
    i_vs = isnan(vs);
    us(i_vs) = 0;
    
    disp(['[getPIVvectorsFromVideoFolder]: ..Writing mat file with Raw PIV vectors: ' datapath]);
    save(datapath,'xs', 'ys', 'us', 'vs', 'snrs', 'pkhs', 'is');
    
    disp('[getPIVvectorsFromVideoFolder]: End');

   

end
