function cp_ConvertDidsonToMat(dataDir,type)
disp(dataDir)
%
% dataDir:
% Directory where the respective ddf files are placed
%
% Type:
% type=='A'. Creates avi files
% type=='D'. Creates a matlab file per ddf file
% type=='T'. Creates a time index file

if nargin==1
    type='A';
end

% A function to convert all didson files to mat files.

d = dir(fullfile(dataDir, '*.ddf'));

T = [];
for i =1:length(d)
    disp(['File ',num2str(i),' of ',num2str(length(d))])
    if exist(fullfile(dataDir,d(i).name))
        Tsub=cp_ReadAndSaveDidson(fullfile(dataDir, d(i).name),type);
    else
        warning(['No data file in ',dataDir, d(i).name])
        Tsub=[];
    end
    T = [T; [Tsub repmat(i,size(Tsub))]];
end
save(fullfile(dataDir,'T.mat'),'T')

function[T] = cp_ReadAndSaveDidson(filename,type)
% Deliver the time data vector
matfilename = [filename(1:end-3),'mat'];

% Create data set and store to matlab
data = get_frame_first(filename);
T = NaN([data.numframes 2]);
D = NaN([data.numframes size(data.frame,1) size(data.frame,2)]);
D(1,:,:) = data.frame;
T(1,1) = data.datenum;
T(1,2) = 1;
for i = 2:data.numframes %= pari.startframe:pari.endframe
    data=get_frame_new(data,i);
    if ~isempty(data.frame)% If the data frame is empty, keep the NaN's
        D(i,:,:) = data.frame;
    end
    if ~isempty(data.datenum)% If the data frame is empty, keep the NaN's
        T(i,1) = data.datenum;
    end
    T(i,2)=i;
end
fclose(data.fid); %Close the ddf file
data.frame=[];
data.frame = D;
if type=='D'
    save(matfilename,'D','T')
end

if type=='A'
    % Generate avi file
    
    avifilename = [filename(1:end-3),'avi'];
    
    data=get_frame_first(filename);
    iptsetpref('Imshowborder','tight');
    data=make_first_image(data,4,400); %make the first image array
    %data=make_first_image(data,4,2000); %make the first image array
    fd = imshow(data.image);
    colormap bone;%(bluebar);
    set(gca,'Clim',[30,200]); %set bottom and top of color map
    set(fd,'EraseMode','none','CDataMapping','scaled');
    
    trackflowavi = avifile(avifilename,'keyframe',20,...
        'Quality',100);
    
    for framenumber = 2:data.numframes
        data=get_frame_new(data,framenumber);
        data=make_new_image(data,data.frame);
        set(fd,'CData',data.image);
        trackflowavi = addframe(trackflowavi,getframe(gca));
        drawnow;
        disp(['Frame ',num2str(framenumber),...
            ' of ',num2str(data.numframes)])
    end
    
    % Close the files
    fclose(data.fid); %Close the ddf file
    trackflowavi = close(trackflowavi);
end
