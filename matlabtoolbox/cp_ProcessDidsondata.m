function cp_ProcessDidsondata(blockn,block,par)
%
% This function reads the Didson data and creates short movies associated
% with the each stimuli. The videos are stored in the figures folder
%
% block(blockn).subblock(subblockn).treatment(treatmentn)
N = length(block(blockn).subblock);

% Read timeindex file for the Didson data

T=load(fullfile(par.datadir,['block',num2str(blockn)],'didson','T.mat'));
T=T.T;

% Loop over subblock
for j=1:N
    % Loop over treatment
    for l = 1:length(block(blockn).subblock(j).treatment)
        try
            
            d.ddfdir  = fullfile(par.datadir,['block',num2str(block(blockn).b_block)],'didson');
            d.hdr  = ['didson_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock),'_treat',num2str(block(blockn).subblock(j).treatment(l).t_treatment)];
            d.avifile = fullfile(par.datadir,'figures',[d.hdr,'.avi']);
            
            d.starttime = block(blockn).subblock(j).treatment(l).t_start_time_mt;
            d.stoptime = block(blockn).subblock(j).treatment(l).t_stop_time_mt;
            
            d.starttime0 = block(blockn).subblock(j).treatment(l).t_start_time_mt - par.didson.preTrialTime;
            d.stoptime0 = block(blockn).subblock(j).treatment(l).t_stop_time_mt + par.didson.preTrialTime;
            
            disp(d.hdr)
            %         disp(d.ddfdir)
            %         disp(d.avifile)
            %         disp(datestr(d.starttime0))
            %         disp(datestr(d.starttime))
            %         disp(datestr(d.stoptime))
            %         disp(datestr(d.stoptime0))
            %         % Get files and frames to be read and plotted from the index data
            % (T.mat)
            
            %Sometimes there are NaN in the time vector. Let's interpolate:
            nanind=~isnan(T(:,1));
            x = 1:length(T(:,1));
            T(:,1) = interp1(x(nanind),T(nanind,1),x,'linear','extrap');
            ind = T(:,1)>d.starttime0 & T(:,1)<d.stoptime0;
            if sum(ind)==0
                warning(['Failed: No Didson data for ',d.hdr])
                disp(['Data spans:',datestr(T(1,1)),' to ',datestr(T(end,1))])
                disp(['Passing spans:',datestr(d.starttime0),' to ',datestr(d.stoptime0)])
            else
                [~,ind1]=min(abs(T(:,1)-d.starttime));
                [~,ind2]=min(abs(T(:,1)-d.stoptime));
                d.indstart = T(ind1,:);
                d.indstop = T(ind2,:);
                d.Tsub = T(ind,:);
                d.files=unique(d.Tsub(:,3));
                d.startindex = d.Tsub(1,2);
                d.stopindex = d.Tsub(end,2);
                cpsrPlotDidson(d,par);
            end
        catch err
            warning([d.ddfdir,' failed'])
        end
    end
end

function [ek60]=cpsrPlotDidson(d,par)
% The ddf file in the directory
ddf = dir(fullfile(d.ddfdir, '*.ddf'));

% Generate the avi file
trackflowavi = avifile(d.avifile,'keyframe',20,...
    'Compression','none');

border=1;

for i=1:size(d.files);
    % Open ddf file
    file = fullfile(d.ddfdir,ddf(d.files(i)).name);
    data=get_frame_first(file);
    % Only one file
    if length(d.files)==1
        frames = d.startindex:d.stopindex;
    else % Several files
        if i==1 % If this is the first of several files
            frames = d.startindex:data.numframes;
        elseif i==size(d.files) % If this is the last of several files
            frames = 1:data.numframes;
        else %if this is the middle of several files
            frames = 1:d.stopindex;
        end
    end
    % Loop over frames for the open file
    for framenumber = frames
        data=get_frame_new(data,framenumber);
        
        if i==1&&framenumber==frames(1) % Generate plot if this is the first frame
            iptsetpref('Imshowborder','tight');
            data=make_first_image(data,4,400); %make the first image array
            fd = imshow(data.image);
            colormap bone;%(bluebar);
            set(gca,'Clim',[30,200]); %set bottom and top of color map
            set(fd,'EraseMode','none','CDataMapping','scaled');
            %h=text(50,25,'Pre exposure','color',[1 1 1]);
        else % If the plot have been made, update it
            if framenumber==1 % If this is the first frame in a new file
                data = make_first_image(data,4,400); %make the first image array
            else
                data = make_new_image(data,data.frame);
            end
            if d.files(i)==d.indstart(3) && framenumber==d.indstart(2)% If the time is prior/after to the experiment start/stop
                border = 2;
            elseif d.files(i)==d.indstop(3) && framenumber==d.indstop(2) % If the time is prior to the experiment start
                border = 3;
            end
            % Apply border color
            switch border
                case 1
                    %h=text(50,25,'Pre exposure','color',[1 1 1]);
                case 2
                    %h=text(50,25,'EXPOSURE','color',[1 1 1]);
                case 3
                    %h=text(50,25,'Post exposure','color',[1 1 1]);
            end
            set(fd,'CData',data.image);
        end
        % And add the frame to the avi file
        trackflowavi = addframe(trackflowavi,getframe(gca));
        drawnow;
        delete(h)
    end
    % Close the ddf file
    fclose(data.fid);
end
% Close the avi file
trackflowavi = close(trackflowavi);

