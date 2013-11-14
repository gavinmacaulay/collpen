clear
close all

% Example script for the CollPen PIV analysis toolbox
%
% (c) Lars Helge Stien/Nils Olav Handegard


% Dense dynamic (bottle treatment)
file{3} = 'didson_block37_sub1_treat1';
for i=1:9
    filedir{i} = 'data';
end

file{1} = 'predmodel2013_White net_didson_block39_sub1';
file{2} = 'predmodel2013_White net_didson_block44_sub1';
file{3} = 'predmodel2013_White net_didson_block54_sub1';
file{4} = 'predmodel2013_White net_didson_block53_sub1';
file{5} = 'predmodel2013_Brown net_didson_block52_sub1';
file{6} = 'predmodel2013_Brown net_didson_block50_sub1';
file{7} = 'predmodel2013_Brown net_didson_block46_sub1';
file{8} = 'predmodel2013_Brown net_didson_block45_sub1';
file{9} = 'predmodel2013_White net_didson_block43_sub1';


%% Process the stationary case, look for swimming speed, school structure
% (temporal and spatial)
for i=1:9
    disp(['Running example on file: ' num2str(i) ', ' file{i} '.']);
    
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    [bgimage, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp(['BGImage saved as: ' filepathbg]);
        
    % Estimate flow fields
    %parstrpiv128= struct('showmsg',1,'winsize',128,'olap',0.75,'write',1,'useold',1);
    parstrpiv64 = struct('showmsg',1,'winsize',64,'olap',0.75,'write',1,'useold',1);
    %parstrpiv32 = struct('showmsg',1,'winsize',32,'olap',0.75,'write',1,'useold',1);
    %parstrpiv16 = struct('showmsg',1,'winsize',16,'olap',0.75,'write',1,'useold',1);  
    
    [datapath rawpivel] = PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv64);
    
    % Filter flow field - Her kan det eksperimenteres
    parstrfilt = struct('showmsg',1,'global',4,'timeaverage',5,'localmedian',[3 3],'backgroundimage',bgimage);
    [xs ys us vs snrs pkhs is] = PIV_filterPIVvectors(rawpivel.xs, rawpivel.ys, rawpivel.us, rawpivel.vs, rawpivel.snrs, rawpivel.pkhs, rawpivel.is, parstrfilt);
    
    % Weigths
    par(i).w = struct('msnrs',1.3,'ssnrs',0.5,'mthr',10,'sthr',7);
    w=PIV_weights(snrs,pkhs,is,par(i).w);
    
    % Calculate school metrics
    par(i).templag=20;
    [speed{i},dalpha{i},dcav{i},cav{i}]=PIV_schoolstructure(xs,ys,us,vs,w,par(i));
    
    save didsonresults speed dalpha dcav cav
    
    % Create AVI
    dparstravi = struct('showmsg',1,'id','');
    avipath = PIV_createAVIfigure(filedir{i}, file{i}, xs, ys, us, vs, w, pkhs, is, dparstravi);
    disp(['Avi showing results stored in: ' avipath]);
end

%% Probably different for the dynamic example
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