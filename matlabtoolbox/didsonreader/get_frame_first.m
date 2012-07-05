function data =get_frame_first(filename)
%This is compatible with DDF_0, DDF_1, DDF_2, DDF_3 and DDF_4 files used with V1, V2, V3, V4, and V5 topside software. 

% Interprets headers 
% It outputs a data structure 
% filename = filename (and path) to ddf file of interest
%

% Output Data structure format:
%  version   Version of ddf file.
%  minrange  Minimum range of display in meters
%  maxrange  Maximum range of display in meters
%  numbeams  Number of beams in array (48 or 96)
%  fileheaderlength  Number of bytes in file header
%  frameheaderlength Number of bytes in frame header
%  fid       File identification number
%  numframes Number of frames in the ddf file
%If reverse is set, the software will fliplr the frame

fid=fopen(filename,'rb');
if fid == -1
    fprintf('No Such File: %s \n',filename);
    return
end
str=char(fread(fid,3,'char'));
if(~strcmp('DDF',str'))
    fprintf('This file is not a DDF file. \n');
    fclose(fid);
    return
end
version=fread(fid,1,'uint8'); %get version number
switch version
case 0
    fileheader=get_file_header_ddf0(fid);
    frameheader=get_frame_header_ddf01(fid,fileheader.resolution);
case 1
    fileheader=get_file_header_ddf1(fid);
    frameheader=get_frame_header_ddf01(fid,fileheader.resolution);
    frameheader.configflags=1;
case 2
    fileheader=get_file_header_ddf2(fid);
    frameheader=get_frame_header_ddf2(fid,fileheader.resolution);
case 3
    fileheader=get_file_header_ddf3(fid);
    frameheader=get_frame_header_ddf3(fid,fileheader.resolution,fileheader.serialnumber);
case 4
    fileheader=get_file_header_ddf4(fid);
    frameheader=get_frame_header_ddf4(fid,fileheader.resolution,fileheader.serialnumber);
    
otherwise
    fprintf ('Illegal version number is %d\n', version);
    return
end

fileheader.version=version;
fprintf('File version %d Number of frames: %d\n',fileheader.version, fileheader.numframes);

data.version=fileheader.version;
data.serialnumber=fileheader.serialnumber;

switch frameheader.configflags
case 0
    data.configuration ='DIDSON-S Extended Windows';
case 1
    data.configuration ='DIDSON-S Classic Windows';
case 2
    data.configuration ='DIDSON-LR Extended Windows';
case 3
    data.configuration ='DIDSON-LR Classic Windows';
end

data.minrange=frameheader.windowstart;
data.maxrange=data.minrange + frameheader.windowlength;
data.numbeams = fileheader.numbeams;    
data.reverse=fileheader.reverse;
data.fileheaderlength = fileheader.length;
data.frameheaderlength = frameheader.length;
data.fid=fid;
data.numframes=fileheader.numframes; %number of frames in the file

frame=uint8(fread(fid,[data.numbeams,512],'uint8'));

if data.reverse == 0
    frame=fliplr(frame'); %Transposed and flipped data frame assumes uninverted sonar
else
    frame=frame'; % Assume inverted sonar
end
data.frame=frame;
data.receivergain=fileheader.receivergain;
data.flag=0; %establish a flag entry for get_new_image.m
%data.panwcom=frameheader.panwcom;     %pan from pan/tilt with compass present
%data.tiltwcom=frameheader.tiltwcom;   %tilt from pan/tilt with compass present
%data.sonarpan=frameheader.sonarpan;   %pan from pan/tilt with no compass
%data.sonartilt=frameheader.sonartilt; %tilt from pan/tilt with no compass