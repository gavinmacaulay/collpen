function PIV_calculateContoursFromVideo(openings, closings, threshold, path, run_once)

% CALCULATECONTOURSFROMVIDEO
%
%  Input Arguments:
%    openings = number of iterations for the opening morphological filter
%    closings = number of iterations for the closing morphological filter
%    threshold = value for the thresholding operation 
%    path = directory with the videos to be analyzed (*.avi is mandatory at the end 
%    (if empty a default one is considered '/Volumes/Datos/collpen/videos'
%
%  Preconditions:
%    A background image must exist in path/PIVdata for each video (with the
%    same name). The script cpscr_processdidsondata.m generates the bg
%    images
%
% (c) Jose Carlos Castillo - 2014



% Remove this two lines if path problems appear
addpath('/Volumes/Datos/collpen/collpen/PIVtoolbox')
savepath

if(isempty(path))
    path = '/Volumes/Datos/collpen/videos';
end

d = dir([path '/*.avi']);

for i=1:length(d)
    par(i).showmsg = 20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs = 1.3;
    par(i).ssnrs = .2;
    filedir{i} = path;
    file{i} = d(i).name;
end

for i=1:length(d)
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    %parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',1);

    parstrbgimage = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1, 'openings', openings, 'closings',closings,'threshold',threshold, 'run_once',run_once);
    
    % Start processing the edges
    PIV_findEdges(filedir{i}, file{i}, parstrbgimage);  

end