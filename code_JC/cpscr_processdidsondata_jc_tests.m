% Example script for the CollPen PIV analysis toolbox
%

%% Create raw PIV

addpath('/Volumes/Datos/collpen/predator/polar_videos')
savepath

d=dir('/Volumes/Datos/collpen/predator/polar_videos/*.avi');

for i=1:length(d)
    par(i).showmsg = 20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs = 1.3;
    par(i).ssnrs = .2;
    filedir{i} = '/Volumes/Datos/collpen/predator/polar_videos';
    file{i} = d(i).name;
end
    
for i=1:length(d)
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    %parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',0);
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',200,'perc',30,'write',1,'useold',0);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp([datestr(now),' BGImage saved as: ' filepathbg]);

end

%% Calculate Contours

addpath('/Volumes/Datos/collpen/collpen/')
savepath

d=dir('/Volumes/Datos/collpen/videos/*.avi');
    
for i=1:length(d)
    par(i).showmsg = 20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs = 1.3;
    par(i).ssnrs = .2;
    filedir{i} = '/Volumes/Datos/collpen/videos';
    file{i} = d(i).name;
end

showmsg = 1;
for i=1:length(d)
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',1);
    % Edges calculation
    findEdges(filedir{i}, file{i}, showmsg);  

end

















