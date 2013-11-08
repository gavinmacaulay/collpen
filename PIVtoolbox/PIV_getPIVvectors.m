function [xs ys us vs snrs pkhs datatpath] = PIV_filterPIVvectors(folder, avifilename,parstr)
    % Testing input
    if nargin<3 
        [folder, avifilename,parstr] = checkingArguments(folder, avifilename);
    else
       [folder, avifilename,parstr] = checkingArguments(folder, avifilename,parstr);
    end
   
   
    dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: Start');

    % PIV analysis
    dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: ..Getting raw PIV vectors');
    tmp = struct('showmsg',1,'winsize',64);
    [xs ys us vs snrs pkhs is] = PIV_getRawPIVvectors(folder, avifilename, tmp);
    [rows,cols,n] = size(xs);
    
    % Unfiltered
    fxs   = xs;
    fys   = ys;
    fus   = us;
    fvs   = vs;
    fsnrs = snrs;
    pkhs  = pkhs;
    is    = is;
    
    %Lobal Filtering
    for i=1:n
        x=xs(:,:,i); y=ys(:,:,i); u=us(:,:,i); v=vs(:,:,i);
        [T u v]=evalc('globfilt(x,y,u,v,4)');
        fxs(:,:,i)=x; fys(:,:,i)=y; fus(:,:,i)=u; fvs(:,:,i)=v;
    end
   
    % Averaging over time
    if parstr.timefilt
        dispMsg(parstr.showmsg,'[createPIVs]: ..Averaging PIVs over time');
        as = 15;
        SE=ones(1,as)/as;
        fus=filter(SE,1,fus,[],3); 
        fvs=filter(SE,1,fvs,[],3);
    end
    
    % median filter per frame
    if parstr.medianfilt
        dispMsg(parstr.showmsg,'[createPIVs]: ..Median filtering each PIV frame');
        for i=1:n
            fus(:,:,i)= medfilt2(fus(:,:,i),[3 3]);
            fvs(:,:,i)= medfilt2(fvs(:,:,i),[3 3]);
        end
    end
    
    dispMsg(parstr.showmsg,'[createPIVs]: End');
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
    dparstr = struct('showmsg',1,'winsize',128,'timefilt',1,'medianfilt',1,'write',1,'useold',1);
    
    % Initiating arguments
    if nargin<2
        warning(1,'Too few input arguments: PIV_getPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    elseif nargin==2
        parstr=dparstr;
    elseif nargin>3
        warning(2,'Too many input arguments:PIV_getPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    else % nargin ==3 
        if sum(strcmp('showmsg',fieldnames(parstr)))==1
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('winsize',fieldnames(parstr)))==1
            dparstr.winsize = parstr.winsize;
        end
        if sum(strcmp('timefilt',fieldnames(parstr)))==1
            dparstr.timefilt = parstr.timefilt;
        end
        if sum(strcmp('medianfilt',fieldnames(parstr)))==1
            dparstr.medianfilt = parstr.medianfilt;
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