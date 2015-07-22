addpath('/Volumes/Datos/collpen/denoise_polar')
savepath

d=dir('/Volumes/Datos/collpen/denoise_polar/*.avi');

for i=1:length(d)
    par(i).showmsg = 20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs = 1.3;
    par(i).ssnrs = .2;
    filedir{i} = '/Volumes/Datos/collpen/denoise_polar';
    file{i} = d(i).name;
end
    
for i=1:length(d)
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    %parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',0);
    % Establish background image
    parstrbgimage = struct('showmsg',1,'Nframes',200,'perc',30,...
                           'write',1,'useold',0);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, ...
                                              parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp([datestr(now),' BGImage saved as: ' filepathbg]);

end