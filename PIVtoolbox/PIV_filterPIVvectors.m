function [xs ys fus fvs snrs pkhs is] = PIV_filterPIVvectors(xs, ys, us, vs, snrs, pkhs, is, parstr)
% Filters input vectors
%
%


    dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: Start');
    
    % Testing input
    if nargin==7 
       [xs, ys, us, vs, snrs, pkhs, is, parstr] = checkingArguments(xs, ys, us, vs, snrs, pkhs, is);
    elseif nargin==8
       [xs, ys, us, vs, snrs, pkhs, is, parstr] = checkingArguments(xs, ys, us, vs, snrs, pkhs, is, parstr);
    else
       [xs, ys, us, vs, snrs, pkhs, is, parstr] = checkingArguments();
       dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: End');
       return;
    end
    [rows,cols,n] = size(xs);
    fus=us;
    fvs=vs;
    
    % TODO: Dette er test filen hvor vi kan oppdatere
    
    %Global Filtering
    for i=1:n
        x=xs(:,:,i); y=ys(:,:,i); u=us(:,:,i); v=vs(:,:,i);
        [T u v]=evalc('globfilt(x,y,u,v,4)');
        fus(:,:,i)=u; fvs(:,:,i)=v;
    end
   
    
    % Averaging over time
    if parstr.timeaverage
        dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: ..Averaging PIVs over time');
        as = parstr.timeaverage;
        SE=ones(1,as)/as;
        fus=filter(SE,1,fus,[],3); 
        fvs=filter(SE,1,fvs,[],3);
    end
    
    % median filter per frame
    if parstr.localmedian
        dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: ..Median filtering each PIV frame');
        for i=1:n
            fus(:,:,i)= medfilt2(fus(:,:,i),parstr.localmedian);
            fvs(:,:,i)= medfilt2(fvs(:,:,i),parstr.localmedian);
        end
    end
    
    % Thresholding fish based on backgroundimage
    if ~isempty(parstr.backgroundimage)
        Bimage  = parstr.backgroundimage;
        Bvalues = double(Bimage(ys(:,1,1),xs(1,:,1)));
        for i=1:n
            Ts              = (is(:,:,i)-Bvalues)>10;
            fus(:,:,i)      = fus(:,:,i).*Ts;
            fvs(:,:,i)      = fvs(:,:,i).*Ts;
        end
    end
    
    
    
    dispMsg(parstr.showmsg,'[PIV_filterPIVvectors]: End');
end

% Showing msgtxt if on
function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end

% Checking that input arguments are correct
function [xs, ys, us, vs, snrs, pkhs, is, parstr]=checkingArguments(xs, ys, us, vs, snrs, pkhs, is, parstr)
    dparstr = struct('showmsg',1,'global',4,'timeaverage',15,'localmedian',[3 3],'backgroundimage',[]);
    
    % Initiating arguments
    if nargin<7
        warning('Too few input arguments:  PIV_filterPIVvectors(xs, ys, us, vs, snrs, pkhs, is, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    elseif nargin==7
        parstr=dparstr;
    elseif nargin>8
        warning('Too many input arguments: PIV_filterPIVvectors(xs, ys, us, vs, snrs, pkhs, is, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    else % nargin ==8 
        if sum(strcmp('showmsg',fieldnames(parstr)))==1
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('global',fieldnames(parstr)))==1
            dparstr.global = parstr.global;
        end
        if sum(strcmp('timeaverage',fieldnames(parstr)))==1
            dparstr.timeaverage = parstr.timeaverage;
        end
        if sum(strcmp('localmedian',fieldnames(parstr)))==1
            dparstr.localmedian = parstr.localmedian;
        end
        if sum(strcmp('backgroundimage',fieldnames(parstr)))==1
            dparstr.backgroundimage = parstr.backgroundimage;
        end
        parstr = dparstr;
    end
    
end