function [image, filepathbg] = PIV_createBGImage(folder, avifilename, parstr)
%
% Bacground estimation
% 
% Input:
% file          : Avi file name from didson without the .avi extension
% filedir       : Directory to store output files
% parstr        : Parameter structure
% parstr.showmsg: 1 or 0, if 1 shows messages 
% parstr.Nframes: Number of frames to establish bg image 
% parstr.perc   : Percentile used to establish bg image 
% parstr.write  : 1 or 0, 1 writes BG image to file
% parstr.useold : 1 or 0, loads old BG image if available
% Outputfiles (written to fildir):
% [file'_bg.bmp'] - Background image
    % avifilename - allowing for specified with or whithout .avi
    avifilename=strrep([avifilename '.avi'],'.avi.avi','.avi');
    
    % default parstr
    dparstr = struct('showmsg',0,'Nframes',500,'perc',30,'write',0,'useold',0);
    tmpfilepathbg = strrep([folder '\' avifilename],'.avi','_BG.bmp');
    
    % Setting return to empty
    image=[];
    filepathbg=[];
    
    % Initiating arguments
    if nargin<2
        warning(1,'Too few input arguments: PIV_createBGImage(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    end
    if nargin>3
        warning(2,'Too many input arguments: PIV_createBGImage(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    end
    if nargin == 3 
        if sum(strcmp('showmsg',fieldnames(parstr)))==1
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('Nframes',fieldnames(parstr)))==1
            dparstr.Nframes = parstr.Nframes;
        end
        if sum(strcmp('perc',fieldnames(parstr)))==1
            dparstr.perc = parstr.perc;
        end
        if sum(strcmp('write',fieldnames(parstr)))==1
            dparstr.write = parstr.write;
        end
        if sum(strcmp('useold',fieldnames(parstr)))==1
            dparstr.useold = parstr.useold;
        end
    end
    parstr = dparstr;
    
    % using old if its exists - avoids reruns
    if parstr.useold==1
         if exist(tmpfilepathbg, 'file') == 2
             dispMsg(parstr.showmsg,'[PIV_createBGImage]: Using previously created BG image')
             filepathbg = tmpfilepathbg;
             image      = imread(filepathbg);
             return;
         end
    end
    
    % getting BG image
    dispMsg(parstr.showmsg,'[PIV_createBGImage]: Getting BG image')
    image = getBGImage([folder '\' avifilename], parstr.showmsg,parstr.perc, parstr.Nframes);

    % writing BG image
    if parstr.write==1
        filepathbg = tmpfilepathbg;
        dispMsg(parstr.showmsg,['[PIV_createBGImage]: Writing BG image: ' filepathbg]);
        imwrite(image,filepathbg);
    end

end


function I = getBGImage(filepath, msg,perc,n)
% getBGImage(filepath) provides a background image for a Didson avi
% getBGImage(filepath, 0) means that script msgs are noy displayed
% getBGImage(filepath) uses the default msg=1, perc=30, n=500

    %% Opening movie object
    dispMsg(msg,'[PIV_createBGImage]: ..Loading movie')
    info     = aviinfo(filepath);
    movieobj = mmreader(filepath);


    %% Setting up image stack
    dispMsg(msg,'[PIV_createBGImage]: ..Setting up image stack')
    RGB         = uint16(read(movieobj, 1));
    nf          = min(info.NumFrames,n);
    [m n z]     = size(RGB);
    Is          = zeros(m,n,nf);
    for f=1:1:nf
        RGB         = uint16(read(movieobj, f));
        Is(:,:,f)   = RGB(:,:,1);
    end

    %% Generating percentile BG image
    dispMsg(msg,'[PIV_createBGImage]: ..Generating BG  image')
    I=zeros(m,n);
    for i=1:m
        for j=1:n
            I(i,j)  = prctile(Is(i,j,:),perc);
        end
    end
    warning off
    I=uint8(I);
    warning on
end

function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end