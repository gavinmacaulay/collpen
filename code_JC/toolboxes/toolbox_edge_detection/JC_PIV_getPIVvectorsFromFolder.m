function JC_PIV_getPIVvectorsFromFolder(folder, denoising_method, denoising_param, denoising_label,winsize)
% Data will be saved following this scheme:
% ./PIVdata/denoising_label/avi_file_name.mat


d=dir([folder '*.avi']);

for i=1:length(d)
    filedir{i} = folder;
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata/'];
if ~(exist(datafolder,'dir')==7)
    disp(['Creating data folder, ' datafolder]);
    mkdir(datafolder);
end

for i = 1:length(d)
    disp(['Processing file ' int2str(i) '/' int2str(length(d))]);
    disp(denoising_label);
    filepath = [filedir{i}  file{i}];
    
    avifilename = d(i).name;
    
    % Datapath
    datapath = [folder 'PIVdata/' int2str(winsize) '/'  denoising_label{1} '/'];
    if ~(exist(datapath,'dir')==7)
        disp(['Creating data folder, ' datapath]);
        mkdir(datapath);
    end
    datapath   = strrep([datapath file{i}],'.avi','_PIV.mat');
    
    parstrpiv64 = struct('showmsg',1,'winsize',winsize,'olap',0.5,'write',1,'useold',0);
    [xs ys us vs snrs pkhs is] = JC_PIV_getPIVvectors(folder, avifilename, denoising_method, denoising_param, denoising_label, parstrpiv64);

 % Filter vectors
%     parstrfilt = struct('showmsg',1,'global',4,'timeaverage',5,'localmedian',[3 3]);
% 
%     [xs ys us vs snrs pkhs is] = PIV_filterPIVvectors(xs, ys, us, vs, snrs, pkhs, is, parstrfilt);

        % writing mat file with vectors
        
    % Discard NaN values
    
    i_us = find(isnan(us));
    us(i_us) = 0;
    i_vs = find(isnan(vs));
    us(i_vs) = 0;
    
    disp(['[PIV_getRawPIVvectors]: ..Writing mat file with Raw PIV vectors: ' datapath]);
    save(datapath,'xs', 'ys', 'us', 'vs', 'snrs', 'pkhs', 'is');
    
    disp('[PIV_getRawPIVvectors]: End');

   

end
