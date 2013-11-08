% Example script for the CollPen PIV analysis toolbox
%
% (c) Lars Helge Stien/Nils Olav Handegard

%% Define the parameters for the 4 examples

for i=1:4
    par(i).showmsg=20;
    % This defines the snrs weights. w =.5*(1+erf(snrs-msnrs)/sqrt(2*snrss^2)
    par(i).msnrs=1.3;
    par(i).ssnrs=.2;
    par(i).templag = 30;
end

% Dense milling
file{1} = 'predmodel2013_White net_didson_block39_sub1';
filedir{1} = 'data';

% Sparse
file{2} = 'predmodel2013_Orca_didson_block72_sub1';
filedir{2} = 'data';

% Dense dynamic (bottle treatment)
file{3} = 'didson_block37_sub1_treat1';
filedir{3} = 'data';

% Sparse dynamic (bottle treatment)
file{4} = 'nn';
filedir{4} = 'data';
   
%% Process the stationary case, look for swimming speed, school structure
% (temporal and spatial)
for i=1:2
    disp(['Running example on file: ' num2str(i) ', ' file{i} '.']);
    
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    [image, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp(['BGImage saved as: ' filepathbg]);
    
    
    % Estimate flow field
    parstrpiv = struct('showmsg',1,'winsize',64,'write',1,'useold',1);
    [datatpath xs ys us vs snrs pkhs is] = PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv);
    
    % Filter flow field
    
    %PIV_flowfieldestimate(filedir{i},file{i},par(i))
    
    % Estimate the PIV
    %PIV_fishmask(filedir{i},file{i},par(i))
end

%% Analysis of the stationary case

for i=1:2
    PIV_schoolstructure(filedir{i}, file{i}, par(i));
end

%% Probably different for the dynamic example
for i=3:3

   disp(['Running example on file: ' num2str(i) ', ' file{i} '.']);
    
    % Establish background image
    parstrbgimage       = struct('showmsg',1,'Nframes',500,'perc',30,'write',1,'useold',1);
    [image, filepathbg] = PIV_createBGImage(filedir{i}, file{i}, parstrbgimage); % alternativ par(i) hvor vi angir spesifikt for hver fil 
    disp(['BGImage saved as: ' filepathbg]);
    
    
    % Estimate flow field
    parstrpiv = struct('showmsg',1,'winsize',64,'write',1,'useold',1);
    [datatpath xs ys us vs snrs pkhs is] = PIV_getRawPIVvectors(filedir{i}, file{i}, parstrpiv);
    
end