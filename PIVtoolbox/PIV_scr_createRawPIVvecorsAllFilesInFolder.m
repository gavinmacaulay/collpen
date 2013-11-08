
folder ='\\callisto\collpen\AustevollExp\data\HERRINGexp\figures';
files=dir([folder '\*.avi']);
numoffiles=length(files);

parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
parstrpiv128= struct('showmsg',1,'winsize',128,'olap',0.75,'write',1,'useold',1);
parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',1);
parstrpiv32 = struct('showmsg',1,'winsize',32,'olap',0.75,'write',1,'useold',1);
parstrpiv16 = struct('showmsg',1,'winsize',16,'olap',0.75,'write',1,'useold',1);  

totaltime = 0;
for i=1:numoffiles
    tic
    disp(['Analysing file num ' num2str(i) ' of ' num2str(numoffiles)]);
    filepath = [folder '\' files(i).name];
    
    [bgimage, filepathbg] = PIV_createBGImage(folder, files(i).name, parstrbgimage); 
    disp(['..BGImage saved as: ' filepathbg]);
    
    disp(['..File: ' filepath]);
    disp('....Setting: 128');
    [datapath rawpivel] = PIV_getRawPIVvectors(folder, files(i).name, parstrpiv128);
    disp('....Setting: 64');
    [datapath rawpivel] = PIV_getRawPIVvectors(folder, files(i).name,parstrpiv64);
    disp('....Setting: 32');
    [datapath rawpivel] = PIV_getRawPIVvectors(folder, files(i).name, parstrpiv32);
    disp('....Setting: 16');
    [datapath rawpivel] = PIV_getRawPIVvectors(folder, files(i).name, parstrpiv16);
    t=toc;
   
   totaltime=t+totaltime;
   timeleft = totaltime/double(i)*numoffiles-totaltime;
   
   disp(['..Calculation time: ' num2str(t/60) ' min']);
   disp(['Totaltime so far: ' num2str(totaltime) ' min']);
   disp(['Estimated time left: ' num2str(timeleft) ' min']);
    
end