function [datatpath xs ys us vs snrs pkhs is] = PIV_getRawPIVvectors(folder, avifilename, parstr)
    % Initiation
    datatpath = [];
    if nargin==2
        [folder, avifilename, parstr] = checkingArguments(folder, avifilename);
    elseif nargin==3
        [folder, avifilename,parstr] = checkingArguments(folder, avifilename,parstr);
    else
        [folder, avifilename, parstr] = checkingArguments();
        return;
    end
    
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: Start');
    tmpdatatpath = strrep([folder '\' avifilename],'.avi','_RAWPIV.mat');
    
    %Do not repeat if analysis already done
    if parstr.useold
        currentparstr = parstr;
        if exist(tmpdatatpath, 'file') == 2
            load(tmpdatatpath);
            if isequal(currentparstr,parstr)
                dispMsg(parstr.showmsg,'[createPIVs]: ..Using previously created PIVs');
                dispMsg(parstr.showmsg,'[createPIVs]: End');
                return;
            else
                clear xs ys us vs snrs pkhs is;
                parstr = currentparstr;
            end
        end
    end
    
    
    % Getting raw vectors/datas
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]:..Run 1 of 4');
    [xs1 ys1 us1 vs1 snrs1 pkhs1 is1] = PIV_getSubRawPIVvectors(folder, avifilename, parstr, 0, 0);
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]:..Run 2 of 4');
    [xs2 ys2 us2 vs2 snrs2 pkhs2 is2] = PIV_getSubRawPIVvectors(folder, avifilename, parstr, 0, 1);
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]:..Run 3 of 4');
    [xs3 ys3 us3 vs3 snrs3 pkhs3 is3] = PIV_getSubRawPIVvectors(folder, avifilename, parstr, 1, 0);
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]:..Run 4 of 4');
    [xs4 ys4 us4 vs4 snrs4 pkhs4 is4] = PIV_getSubRawPIVvectors(folder, avifilename, parstr, 1, 1);
    
    % Combining vectors
    [rows,cols,n] = size(xs1);
    trows=rows*2;
    tcols=cols*2;
    
    xs   = zeros(trows,tcols,n);
    ys   = zeros(trows,tcols,n);
    us   = zeros(trows,tcols,n);
    vs   = zeros(trows,tcols,n);
    snrs = zeros(trows,tcols,n);
    pkhs = zeros(trows,tcols,n);
    is   = zeros(trows,tcols,n);
    
    xs(1:2:trows-1,1:2:tcols-1,:) = xs1;
    xs(2:2:trows-0,1:2:tcols-1,:) = xs2;
    xs(1:2:trows-1,2:2:tcols-0,:) = xs3;
    xs(2:2:trows-0,2:2:tcols-0,:) = xs4;
    
    ys(1:2:trows-1,1:2:tcols-1,:) = ys1;
    ys(2:2:trows-0,1:2:tcols-1,:) = ys2;
    ys(1:2:trows-1,2:2:tcols-0,:) = ys3;
    ys(2:2:trows-0,2:2:tcols-0,:) = ys4;
    
    us(1:2:trows-1,1:2:tcols-1,:) = us1;
    us(2:2:trows-0,1:2:tcols-1,:) = us2;
    us(1:2:trows-1,2:2:tcols-0,:) = us3;
    us(2:2:trows-0,2:2:tcols-0,:) = us4;
     
    vs(1:2:trows-1,1:2:tcols-1,:) = vs1;
    vs(2:2:trows-0,1:2:tcols-1,:) = vs2;
    vs(1:2:trows-1,2:2:tcols-0,:) = vs3;
    vs(2:2:trows-0,2:2:tcols-0,:) = vs4;
    
    snrs(1:2:trows-1,1:2:tcols-1,:) = snrs1;
    snrs(2:2:trows-0,1:2:tcols-1,:) = snrs2;
    snrs(1:2:trows-1,2:2:tcols-0,:) = snrs3;
    snrs(2:2:trows-0,2:2:tcols-0,:) = snrs4;
    
    pkhs(1:2:trows-1,1:2:tcols-1,:) = pkhs1;
    pkhs(2:2:trows-0,1:2:tcols-1,:) = pkhs2;
    pkhs(1:2:trows-1,2:2:tcols-0,:) = pkhs3;
    pkhs(2:2:trows-0,2:2:tcols-0,:) = pkhs4;
    
    is(1:2:trows-1,1:2:tcols-1,:) = is1;
    is(2:2:trows-0,1:2:tcols-1,:) = is2;
    is(1:2:trows-1,2:2:tcols-0,:) = is3;
    is(2:2:trows-0,2:2:tcols-0,:) = is4;
    
    % writing mat file with vectors
    if parstr.write
        datapath=tmpdatatpath;
        dispMsg(parstr.showmsg,['[[PIV_getRawPIVvectors]: ..Writing mat file with Raw PIV vectors: ' datapath]);
        save(datapath,'xs','ys','us','vs','snrs','pkhs','is','parstr');
    end

    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: End');
end

function [xs ys us vs snrs pkhs is] = PIV_getSubRawPIVvectors(folder, avifilename, parstr, dx, dy)
% dx     : 1 or 0
% dy     : 1 or 0
% winsize: 32 64 128

    winsize=parstr.winsize;
    
    %% Initiating
    
    %addpath('MatPIV161');
    %filepath='DidsonFilesOfInterest\didson_block22_sub1_treat1.avi';
    filepath=[folder '/' avifilename];
    
    %% Opening movie object
    disp(['[PIV_getRawPIVvectors]:..Opening ' filepath]);
    info     = aviinfo(filepath);
    movieobj = mmreader(filepath);


    %% Bacground image
    bgimagepath = strrep(filepath,'.avi','_BG.bmp');
    disp(['[PIV_getRawPIVvectors]:..Loading BG Image ' bgimagepath]);
    %Ib = imread(bgimagepath);
    clear imagename a b;

    %% PIV settings 
    param='single'; %multi/single 
    dt=1/15; 
    olap=0.5; %overlap=50%
    cols=floor(info.Width/(winsize*olap)-1); 
    rows=floor(info.Height/(winsize*olap)-1); 
    n       = info.NumFrames-1;
    ws = winsize/2;
    wd = round(ws/2);
    if dx==1
        dx = dx*ws;
    else
        dx=1;
    end
    if dy==1
        dy = dy*ws;
    else
        dy=1;
    end
    
    %n=5; % TODO: Remove, is here for debugging purpo

    % PIV data vectors
    xs     = zeros(rows,cols,n);
    ys     = zeros(rows,cols,n);
    us     = zeros(rows,cols,n);
    vs     = zeros(rows,cols,n);
    snrs   = zeros(rows,cols,n);
    pkhs   = zeros(rows,cols,n);
    is     = zeros(rows,cols,n);

    %% PIV - loop
    dispMsg(parstr.showmsg,['[PIV_getRawPIVvectors]:..Performing PIV-analysis of all frames']); c=0;
    RGB2    = read(movieobj, 1);
    I2      = uint8(zeros(info.Height,info.Width));
    %IB      = Ib;
    %IB(1:info.Height-dx,1:info.Width-dy)=Ib(dx:info.Height-1,dy:info.Width-1);
    I2(1:info.Height-dx,1:info.Width-dy)=RGB2(dx:info.Height-1,dy:info.Width-1,1);
    
    %warning off; I2=I2-IB; warning on;
    for i=1:1:n
        I1  = I2;

        % Loading frames
        RGB2    = read(movieobj, i+1);
        I2(1:info.Height-dx,1:info.Width-dy)=RGB2(dx:info.Height-1,dy:info.Width-1,1);
        %warning off; I2=I2-IB; warning on;
        %I2      = medfilt2(I2,[3 3]);
        %figure(1);imshow(I2);

        % Outut to show that something is happening
        c=c+1;
        if c>30
            dispMsg(parstr.showmsg,['[PIV_getRawPIVvectors]:....Frame: ' num2str(i) ' of ' num2str(n) ' analysed']); c=0;
        end

        % PIV
        try
            [T,xs(:,:,i),ys(:,:,i),us(:,:,i),vs(:,:,i),snrs(:,:,i),pkhs(:,:,i)] = evalc('matpiv(I1,I2,winsize,dt,olap,param)');
            tmpx=xs(1,:,i);
            tmpy=ys(:,1,i);
            is(:,:,i)=I1(tmpy(:),tmpx(:));
            if dx>1
                xs(:,:,i) = xs(:,:,i)+wd;
            end
            if dy>1
                ys(:,:,i) = ys(:,:,i)+wd;
            end       
        catch exception
            warning(['[PIV_getRawPIVvectors]: Error in matpiv for frames ' num2str(i) ' and ' num2str(i+1)]);
            disp(exception.message);
        end
    end
    

end

% Showing msgtxt if on
function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end


    
% Checking that input arguments are correct
function [folder, avifilename,parstr]=checkingArguments(folder, avifilename,parstr)
    avifilename=strrep([avifilename '.avi'],'.avi.avi','.avi');
    dparstr = struct('showmsg',1,'winsize',64,'write',1,'useold',1);
    
    % Initiating arguments
    if nargin<2
        warning(1,'Too few input arguments: PIV_getRawPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr));
        return;
    elseif nargin==2
        parstr=dparstr;
    elseif nargin>3
        warning(2,'Too many input arguments:PIV_getRawPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr));
        return;
    else  % nargin==3 
        if sum(strcmp('showmsg',fieldnames(parstr)))==1
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('winsize',fieldnames(parstr)))==1
            dparstr.winsize = parstr.winsize;
        end
        if sum(strcmp('write',fieldnames(parstr)))==1
            dparstr.write = parstr.write;
        end
        if sum(strcmp('useold',fieldnames(parstr)))==1
            dparstr.useold = parstr.useold;
        end
        parstr = dparstr;
    end
    
end


