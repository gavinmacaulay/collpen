% Example script for the CollPen PIV analysis toolbox
%
% (c) Lars Helge Stien/Nils Olav Handegard

% Define the 4 Different examples

% Dense milling
file{1} = 'predmodel2013_White net_didson_block39_sub1';
filedir{1} = 'data';
par(1).showmsg=20;
par(1).etc = 1;%etc

% Sparse
file{2} = 'predmodel2013_Orca_didson_block72_sub1';
filedir{2} = 'data';
par(2).N=20;
par(2).etc = 1;%etc

% Dense dynamic (bottle treatment)
file{3} = 'didson_block37_sub1_treat1';
filedir{3} = 'data';
par(3).N=20;
par(3).etc = 1;%etc

% Sparse dynamic (bottle treatment)
file{4} = 'nn';
filedir{4} = 'data';
par(4).N=20;
par(4).etc = 1;%etc
   
% Process the stationary case, look for swimming speed, school structure
% (temporal and spatial)
for i=2:2
    disp(['Running example on file: ' num2str(i) ', ' file{i} '.']);
    
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp(['BGImage saved as: ' filepathbg]);
        
    % Estimate flow fields
    parstrpiv128= struct('showmsg',1,'winsize',128,'olap',0.75,'write',1,'useold',1);
    parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',1);
    parstrpiv32 = struct('showmsg',1,'winsize',32,'olap',0.75,'write',1,'useold',1);
    parstrpiv16 = struct('showmsg',1,'winsize',16,'olap',0.75,'write',1,'useold',1);  
    [datapath rawpivel] = PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv128);
        
    % Filter flow field - Her kan det eksperimenteres 
    parstrfilt = struct('showmsg',1,'global',4,'timeaverage',5,'localmedian',[3 3],'backgroundimage',bgimage);
    [xs ys us vs snrs pkhs is] = PIV_filterPIVvectors(rawpivel.xs, rawpivel.ys, rawpivel.us, rawpivel.vs, rawpivel.snrs, rawpivel.pkhs, rawpivel.is, parstrfilt);
    
    % Illustrate the PIVs
    dparstravi = struct('showmsg',1,'id','19');
    avipath = PIV_createAVIfigure(filedir{i}, file{i}, xs, ys, us, vs, snrs, pkhs, is, dparstravi);
    disp(['Avi showing results stored in: ' avipath]);

end

% Probably different for the dynamic example
for i=3:4

    % Establish background image
    %parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    %[image, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    %disp(['BGImage saved as: ' filepathbg]);
     
    % Estimate flow field
    %PIV_flowfieldestimate(filedir{i},file{i},par(i))
    
    % Estimate the PIV
    %PIV_fishmask(filedir{i},file{i},par(i))
    
    % And so on...
end