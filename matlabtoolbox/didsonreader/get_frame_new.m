function data=get_frame_new(data,framenumber);
% gets specified frame of data from DIDSON Data File
% data = output structure from "get_first_frame" m-file
% framenumber = scalar number of the frame desired in the file


datalength = 512*data.numbeams;
numbytes= data.fileheaderlength + (framenumber -1)*(data.frameheaderlength + datalength);
status=fseek(data.fid,numbytes,'bof');
resolution=(data.numbeams-48)/96;
switch data.version
case 0
  header=get_frame_header_ddf01(data.fid,resolution);
case 1
  header=get_frame_header_ddf01(data.fid,resolution);
case 2
  header=get_frame_header_ddf2(data.fid,resolution);
case 3
  header=get_frame_header_ddf3(data.fid,resolution,data.serialnumber);
case 4
  header=get_frame_header_ddf4(data.fid,resolution,data.serialnumber);
otherwise
    fprintf ('Illegal version number is %d\n', version);
    return
end

maxirange = header.windowstart + header.windowlength;
if (header.windowstart ~= data.minrange) | (maxirange ~= data.maxrange) 
    data.minrange = header.windowstart;
    data.maxrange = maxirange;
    data.flag =1; %set data flag to alert other programs that the ranges have changed.
end

frame=uint8(fread(data.fid,[data.numbeams,512],'uint8'));
if data.reverse == 0
    frame=fliplr(frame'); %Transposed and flipped data frame assumes uninverted sonar
else
    frame=frame'; % Assume inverted sonar
end
data.frame=frame;
%data.panwcom=header.panwcom;     %pan from pan/tilt with compass present
%data.tiltwcom=header.tiltwcom;   %tilt from pan/tilt with compass present
%data.sonarpan=header.sonarpan;   %pan from pan/tilt with no compass
%data.sonartilt=header.sonartilt; %tilt from pan/tilt with no compass
