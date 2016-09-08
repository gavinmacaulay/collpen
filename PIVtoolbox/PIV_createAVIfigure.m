function savepath = PIV_createAVIfigure(folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr)
    
    % Testing input
    if nargin==9 
       [folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr] = checkingArguments(folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr);
    elseif nargin==10
       [folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr] = checkingArguments(folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr);
    else
       [folder, avifilename, xs, ys, us, vs, w, pkhs, is, parstr] = checkingArguments();
       dispMsg(parstr.showmsg,'[PIV_createAVIfigure]: End');
       return;
    end
    
    dispMsg(parstr.showmsg,'[PIV_createAVIfigure]: Start');
    
    
    
    % Datafolder
    datafolder = fullfile(folder,'/PIVavis');
    if ~exist(datafolder,'dir')==7
        dispMsg(parstr.showmsg,['[PIV_createAVIfigure]: Creating data folder, ' datafolder]);
        mkdir(datafolder);
    end
    %avifilepath = [folder '/' avifilename];
    %savepath    = [datafolder '/' strrep(avifilename,'.avi', ['_PIV' parstr.id '.avi'])];

    avifilepath = fullfile(folder,avifilename);
    savepath    = fullfile(datafolder,[avifilename(1:end-4),'_PIV.avi']);
    if ~exist(avifilepath)
        error('File not found')
    end
    
    % Loading movie
    dispMsg(parstr.showmsg,['[PIV_createAVIfigure]: Loading avi-file: ' avifilepath]);
    movieobj = VideoReader(avifilepath);
    %info     = aviinfo(avifilepath);

    
    % Generate new illustration movie
    dispMsg(parstr.showmsg,['[PIV_createAVIfigure]: Generating movie: ' savepath]);
    [rows,cols,n] = size(xs);
    
    aviobj = VideoWriter(savepath)
    aviobj.FrameRate = 8;
    open(aviobj)
        
    close all;
    fig    = figure('Position', [50 100, 2*250,2*400]);
    
   % try
        for i=1:1:n
            % Vectors
            x = xs(:,:,i); y = ys(:,:,i);
            u = us(:,:,i); v = vs(:,:,i);

            %Arrow plot
            ni =~isnan(u)&~isnan(v);
            quiver(x(ni),y(ni),u(ni),v(ni),'-k');
%            quiver(x,y,u,v,'-k'); title('PIV');
            hold on
            %axis([1 info.Width 1 info.Height]);
            set(gca,'YDir','reverse')
            F       = getframe(fig);
            Ap       = F.cdata;
            [a b c] = size(Ap);
            
            % w
            imagesc(x(1,:),y(:,1),w(:,:,i),[0 1]); title('w');
            ni =~isnan(u)&~isnan(v);
            quiver(x(ni),y(ni),u(ni),v(ni),'-k');
            
            axis tight
            pause(0.05)
            F       = getframe(fig);
            Sp       = F.cdata;
            
%             % pkhs
%             imagesc(x(1,:),y(:,1),pkhs(:,:,i),[0 1]); title('pkhs');
%             quiver(x,y,u,v,'-k');
%             F       = getframe(fig);
%             Pp       = F.cdata;
            
            hold off
            
            % Movie frame
            warning off
            RGB     = read(movieobj, i);
            I       = imresize(RGB(:,:,1),[2*327 2*195]);
            
            % Combining figures
%            FI          = uint8(ones(a,3*b,3)*204);
            FI          = uint8(ones(a,2*b,3)*204);
            FI(1:a,1:b,:) = uint8(Sp);
            FI(60:60+2*327-1,b+60:b+60+2*195-1,1)= I;
            FI(60:60+2*327-1,b+60:b+60+2*195-1,2)= I;
            FI(60:60+2*327-1,b+60:b+60+2*195-1,3)= I;
%             FI(1:a,2*b:3*b-1,:) = uint8(Pp);
            writeVideo(aviobj,FI);
            %aviobj      = addframe(aviobj,FI);
            imagesc(FI)
            warning on;
        end
%     catch exception
%         warning(['Error making movie: ' savepath]);
%         aviobj = close(aviobj);
%         return;
%     end
    close(fig);
    close(aviobj);
    dispMsg(parstr.showmsg,'[PIV_createAVIfigure]: Movie saved.');
    dispMsg(parstr.showmsg,'[PIV_createAVIfigure]: End');
end

% Showing msgtxt if on
function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end
    


% Checking that input arguments are correct
function [folder, avifilename, xs, ys, us, vs, snrs, pkhs, is, parstr] = checkingArguments(folder, avifilename, xs, ys, us, vs, snrs, pkhs, is, parstr)
    dparstr = struct('showmsg',1,'id','');
%    avifilename = strrep([avifilename '.avi'],'.avi.avi','.avi');
    
    % Initiating arguments
    if nargin<9
        disp('Too few input arguments:  PIV_createAVIfigure(folder, avifilename, xs, ys, us, vs, snrs, pkhs, is, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    elseif nargin==9
        parstr=dparstr;
    elseif nargin>10
        disp('Too many input arguments: PIV_createAVIfigure(folder, avifilename, xs, ys, us, vs, snrs, pkhs, is, parstr), parstr:')
        disp(fieldnames(dparstr))
        return;
    else % nargin ==10
        if sum(strcmp('showmsg',fieldnames(parstr)))==1 %use "isfield" instead???
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('id',fieldnames(parstr)))==1
            dparstr.id = parstr.id;
        end
        parstr = dparstr;
    end
    
end
