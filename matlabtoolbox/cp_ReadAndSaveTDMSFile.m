function cp_ReadAndSaveTDMSFile(dataDir, filename, channelsToExport)
% Much of this code comes from example code provided by NI.

% Assume that the NI dll is in a particular place relative to where this
% file lives.
libname = 'nilibddc';
[path, ~, ~] = fileparts(mfilename('fullpath'));
arch = computer('arch');
NI_TDM_DLL_Path = fullfile(path, 'NI', 'dev', 'bin', arch, [libname '.dll']);
NI_TDM_H_Path = fullfile(path, 'NI', 'dev', 'include', arch, [libname '_m.h']);

DDC_FILE_NAME					=	'name';
DDC_FILE_DESCRIPTION			=	'description';
DDC_FILE_TITLE					=	'title';
DDC_FILE_AUTHOR					=	'author';
DDC_FILE_DATETIME				=	'datetime';
DDC_CHANNELGROUP_NAME			=	'name';
DDC_CHANNELGROUP_DESCRIPTION	=	'description';
DDC_CHANNEL_NAME				=	'name';
WF_START_TIME                   =   'wf_start_time';
WF_INCREMENT                    =   'wf_increment';

if ~libisloaded('nilibddc')
    loadlibrary(NI_TDM_DLL_Path,NI_TDM_H_Path)
end

Data_Path = filename;
[~, saveName, ~] = fileparts(Data_Path);
saveFileName = fullfile(dataDir, [saveName '.mat']); 

%Open the file (Always call 'DDC_CloseFile' when you are finished using a file)
fileIn = 0;
[err,dummyVar,dummyVar,file]=calllib(libname,'DDC_OpenFileEx', ...
    fullfile(dataDir, Data_Path),'',1,fileIn);


%Read and display file name property
filenamelenIn = 0;
%Get the length of the 'DDC_FILE_NAME' string property
[err,dummyVar,filenamelen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,DDC_FILE_NAME,filenamelenIn);
if err==0 %Only proceed if the property is found
    %Initialize a string to the length of the property value
    pfilename=libpointer('stringPtr',blanks(filenamelen));
    [err,dummyVar,filename]=calllib(libname,'DDC_GetFileProperty',file,DDC_FILE_NAME,pfilename,filenamelen+1);
    setdatatype(filename,'int8Ptr',1,filenamelen);
    disp(['Loading: ' char(Data_Path)]);
end

%Get channel groups
%Get the number of channel groups
numgrpsIn = 0;
[err,numgrps] = calllib(libname,'DDC_GetNumChannelGroups',file,numgrpsIn);
%Get channel groups only if the number of channel groups is greater than zero
if numgrps>0
	%Initialize an array to hold the desired number of groups
    pgrps=libpointer('int64Ptr',zeros(1,numgrps));
    [err,grps] = calllib(libname,'DDC_GetChannelGroups',file,pgrps,numgrps);
end    

for i=1:numgrps % For each channel group
    
    %Get channel group name property
    grpnamelenIn = 0;
    [err,dummyVar,grpnamelen] = calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(i),DDC_CHANNELGROUP_NAME,grpnamelenIn);
    if err == 0 % Only proceed if the property is found
		% Initialize a string to the length of the property value
        pgrpname = libpointer('stringPtr',blanks(grpnamelen));
        [err,dummyVar,grpname] = calllib(libname,'DDC_GetChannelGroupProperty',grps(i),DDC_CHANNELGROUP_NAME,pgrpname,grpnamelen+1);
        setdatatype(grpname,'int8Ptr',1,grpnamelen);
    else
        grpname = libpointer('stringPtr','');
    end
        
    %Get channel group description property
    grpdesclenIn = 0;
    [err,dummyVar,grpdesclen]=calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(i),DDC_CHANNELGROUP_DESCRIPTION,grpdesclenIn);
    if err==0 %Only proceed if the property is found
		%Initialize a string to the length of the property value
        pgrpdesc=libpointer('stringPtr',blanks(grpdesclen));
        [err,dummyVar,grpdesc]=calllib(libname,'DDC_GetChannelGroupProperty',grps(i),DDC_CHANNELGROUP_DESCRIPTION,pgrpdesc,grpdesclen+1);
    end
    
    %Get channels
    numchansIn = 0;
    %Get the number of channels in this channel group
    [err,numchans]=calllib(libname,'DDC_GetNumChannels',grps(i),numchansIn);
    %Get channels only if the number of channels is greater than zero
    if numchans>0
		%Initialize an array to hold the desired number of channels
        pchans=libpointer('int64Ptr',zeros(1,numchans));
        [err,chans]=calllib(libname,'DDC_GetChannels',grps(i),pchans,numchans);
    end
    
    channames=cell(1,numchans);
    
    for j = 1:numchans %For each channel in the channel group
        %Get channel name property
        channamelenIn = 0;
        [err,dummyVar,channamelen] = calllib(libname, ...
            'DDC_GetChannelStringPropertyLength', chans(j), ...
            DDC_CHANNEL_NAME, channamelenIn);
        if err == 0 % Only proceed if the property is found
			% Initialize a string to the length of the property value
            pchanname = libpointer('stringPtr', blanks(channamelen));
            
            [err,dummyVar,channame] = calllib(libname,'DDC_GetChannelProperty', ...
                chans(j), DDC_CHANNEL_NAME, pchanname, channamelen+1);
            
            setdatatype(channame,'int8Ptr',1,channamelen);
            channames{j} = char(channame.Value);
        else
            channames{j} = '';
        end
        
        %Get channel data type
        typeIn = 0;
        [err,type] = calllib(libname,'DDC_GetDataType',chans(j),typeIn);
        
        %Get channel values if data type of channel is double (DDC_Double = 10)
        if strcmp(type,'DDC_Double')
            numvalsIn = 0;
            [err,numvals] = calllib(libname,'DDC_GetNumDataValues',chans(j),numvalsIn);
			%Initialize an array to hold the desired number of values
            pvals=libpointer('doublePtr',zeros(1,numvals));
            [err,vals] = calllib(libname,'DDC_GetDataValues',chans(j),0,numvals,pvals);
            setdatatype(vals,'doublePtr',1,numvals);
            %Add channel values to a matrix. 
            chanvals(:,j) = (vals.Value); 
            
            % Start time
            yearIn = 0;
            monthIn = 0;
            dayIn = 0;
            hourIn = 0;
            minuteIn = 0;
            secondIn = 0;
            msecondIn = 0;
            wkdayIn = 0;
            [err,dummyVar,year,month,day,hour,minute,second,msecond,wkday] ...
                = calllib(libname,'DDC_GetChannelPropertyTimestampComponents', ...
                chans(j),WF_START_TIME,yearIn,monthIn,dayIn,hourIn,minuteIn,secondIn,msecondIn,wkdayIn);
            if err==0 %Only proceed if the property is found
                start_timestamp(j) = datenum(double(year), double(month), ...
                    double(day), double(hour), double(minute), ...
                    double(second+msecond));
            end
            
            % Time between samples
            pincrement = libpointer('doublePtr', 0);
            [err, dummyVar, increment] ...
                = calllib(libname, 'DDC_GetChannelProperty', chans(j), WF_INCREMENT, pincrement, 0);
            if err==0 %Only proceed if the property is found
                setdatatype(increment, 'doublePtr', 1, 1);
                sample_rate(j) = 1/increment.Value;
            end
            
        else
            disp(type)
        end
    end
end

if nargin < 3
    channelsToExport = [1:23];
end

chanvals = single(chanvals);
channames = channames{channelsToExport};

data = struct('fileName', Data_Path, 'chanNames', channames, ...
    'values', chanvals(:,channelsToExport), 'start_time', start_timestamp(channelsToExport), ...
    'sample_rate', sample_rate(channelsToExport));
disp(['Saving: ' saveName])
save(saveFileName, 'data')

%Close file
err = calllib(libname,'DDC_CloseFile',file);

unloadlibrary(libname)

