% Example script for the CollPen PIV analysis toolbox
%
% (c) Lars Helge Stien/Nils Olav Handegard

%% Create raw PIV

% Note: The PIV algorithms is changed to get the velocities in *pixels per
% frame*

d=dir('\\callisto\collpen\AustevollExp\data\didson_stationary\data\*.avi');

for i=1:length(d)
    par(i).showmsg = 20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs = 1.3;
    par(i).ssnrs = .2;
    filedir{i} = '\\callisto\collpen\AustevollExp\data\didson_stationary\data';
    file{i} = d(i).name;
end
    
for i=92:136%:length(d)
    disp([datestr(now),' Running on file: ' num2str(i) ', ' file{i} '.']);
    parstrpiv = struct('showmsg',1,'winsize',32,'olap',0.5,'write',1,'useold',0);
    % Establish background image
    parstrbgimage       = struct('showmsg',logical(1),'Nframes',500,'perc',30,'write',1,'useold',1);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp([datestr(now),' BGImage saved as: ' filepathbg]);
        
    % Estimate flow fields
    [datapath rawpivel] = PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv);
     disp(['Elapsed time is ',num2str(toc/60),' minutes'])
end

% Filter, weigh and calculate metrics
clear
d=dir('\\callisto\collpen\AustevollExp\data\didson_stationary\data\*.avi');
for i=1:length(d)
    filedir{i} = '\\callisto\collpen\AustevollExp\data\didson_stationary\data';
    file{i} = d(i).name;
    par(i).templag = 20;
    par(i).w = struct('msnrs',1.3,'ssnrs',0.5,'mthr',10,'sthr',7);
end

for i=92:136%120:length(d)
    tic
    disp(['File ',num2str(i),' of ',num2str(length(d))])
    % Load rawpivel data
    datafile = fullfile(filedir{i},'PIVdata',[file{i}(1:end-4),'_PIV.mat']);
    bgimage  = fullfile(filedir{i},'PIVdata',[file{i}(1:end-4),'_BG.bmp']);
    load(datafile)
    rawpivel = pivdatas.rawpivel;
    
    % Parse file string
    datapoint_1 = regexp(file{i}(1:end-4),'_','split');
    datapoint_1{4}=sscanf(datapoint_1{4},'block%d');
    datapoint_1{5}=sscanf(datapoint_1{5},'sub%d');
    if datapoint_1{4}>36
        datapoint_1{6}='NA';
    else
        datapoint_1{6}=sscanf(datapoint_1{6},'treat%d');
    end
    
    % Filter flow field
    parstrfilt = struct('showmsg',1,'global',4,'timeaverage',5,'localmedian',[3 3],'backgroundimage',bgimage);
    [xs ys us vs snrs pkhs is] = PIV_filterPIVvectors(rawpivel.xs, rawpivel.ys, rawpivel.us, rawpivel.vs, rawpivel.snrs, rawpivel.pkhs, rawpivel.is, parstrfilt);
    
    % Weigths
    w=PIV_weights(snrs,pkhs,is,par(i).w);
    
    % Calculate school metrics
    disp('PIV_schoolstructure]: Calculating the correlation measures')
    [speed,dalpha,dcav,cav,c]=PIV_schoolstructure(xs,ys,us,vs,w,par(i));
    disp('PIV_schoolstructure]: End')
    
    % The primary sampling unit
    PSU = [datapoint_1 {speed,cav}];
    % Data point from this video for analysis (NEED TO PARSE THE FILENAMES)
    %{speed,cav}
    
    % Store the filtered school data, weoghts and metrics to file
    save(fullfile(filedir{i},[file{i}(1:end-4),'_school.mat']),'PSU','speed','dalpha','dcav','cav','xs','ys','us','vs','snrs','pkhs','is','w','c','par')
    disp(['Elapsed time is ',num2str(toc/60),' minutes'])
end

%% Plot C
clear
d=dir('\\callisto\collpen\AustevollExp\data\didson_stationary\data\*.avi');
for i=1:length(d)
    filedir{i} = '\\callisto\collpen\AustevollExp\data\didson_stationary\data';
    file{i} = d(i).name;
end
clf
hold on
m=1;
for i=92:106
    disp(file{i}(1:end-4))
    load(fullfile(filedir{i},[file{i}(1:end-4),'_school.mat']))
    c.r = unique(c.mr(:));
    plot(c.r/71,c.cs,'r')
    R(m).A = trapz(c.r(1:100)/71,c.cs(1:100));
    R(m).title = file{i}(1:end-4);
    m=m+1;
%    L{i}=[PSU{1},' ',PSU{2},' Block',num2str(PSU{4}),'_',num2str(PSU{5}),'_',num2str(PSU{6})];
end
for i=121:136
    disp(file{i}(1:end-4))
    load(fullfile(filedir{i},[file{i}(1:end-4),'_school.mat']))
    c.r = unique(c.mr(:));
    plot(c.r/71,c.cs,'b')
    R(m).A = trapz(c.r(1:100)/71,c.cs(1:100));
    R(m).title = file{i}(1:end-4);
    m=m+1;
%    L{i}=[PSU{1},' ',PSU{2},' Block',num2str(PSU{4}),'_',num2str(PSU{5}),'_',num2str(PSU{6})];
end


%legend(L)
plot([0 4],[0 0],'r')
xlim([0 4])
xlabel('Distance (m)')
ylabel('Correlation length \Xi')

%% Create AVI
clear
d=dir('\\callisto\collpen\AustevollExp\data\didson_stationary\data\*.avi');
for i=1:length(d)
    filedir{i} = '\\callisto\collpen\AustevollExp\data\didson_stationary\data';
    file{i} = d(i).name;
end

for i=1:3%:length(d)
    load(fullfile(filedir{i},[file{i}(1:end-4),'_school.mat']))
    % Create AVIs
    dparstravi = struct('showmsg',1,'id','');
    avipath = PIV_createAVIfigure(filedir{i}, file{i}, xs, ys, us, vs, w, pkhs, is, dparstravi);
    disp(['Avi showing results stored in: ' avipath]);
    toc
end

%% Compile data set for analysis in R
clear
d=dir('\\callisto\collpen\AustevollExp\data\didson_stationary\data\*_school.mat');
PSUcombined = {'Type','NT','dummy','Block','Subblock','Treatment','Speed','CAV'};
for i=1:3%length(d)
    filedir{i} = '\\callisto\collpen\AustevollExp\data\didson_stationary\data';
    file{i} = d(i).name;
    load(fullfile(filedir{i},file{i}))
    PSUcombined = [PSUcombined ;PSU];
end

% Link with par variable...

%xlswrite('\\callisto\collpen\AustevollExp\data\didson_stationary\didson_stationary.xls',PSUcombined)


