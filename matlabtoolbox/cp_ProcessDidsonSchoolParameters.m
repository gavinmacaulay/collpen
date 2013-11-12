function cp_ProcessDidsonSchoolParameters(blockn,block,par)
%
% This function reads the Didson data and calculates key school parameters
% before and during exposure.
%
% Input:
% blockn - The block number
% block  - The metadata structure
% par    - Processing parameters (defineing time lags)
% par.preRefTimeVA = [a b] : Time in range seconds to define the reference window for vessel avoidance
% par.passTimeVA   = [a b] : Time range in seconds to define the reference window for VA pb
% par.preRefTimeKW = [a b] : Time range in seconds to define the reference window for killer whale pb
% par.passTimeKW   = [a b] : Time in seconds to define the reference window for killer whale pb
% par.preRefTimeWB = [a b] : Time in seconds to define the reference window for the 2013 experiment. Note that this is different from the 2012 experiment
%
%
% Output:
% dat.<mean school parameter>
% dat.<mean school parameter>
% dat.<mean school parameter>
% dat.<mean school parameter>
% ...



% The number of subblocks for this block
N = length(block(blockn).subblock);

% Read timeindex file for the Didson data (this is generated by
% "cp_ConvertDidsonToMat.m")
T=load(fullfile(par.datadir,['block',num2str(blockn)],'didson','T.mat'));
T=T.T;

% Define the directory where the data is
d.ddfdir  = fullfile(par.datadir,['block',num2str(block(blockn).b_block)],'didson');

% Loop over subblocks
for j=1:N
    % There are 3 different cases
    if strcmp(block(blockn).subblock(j).s_treatmenttype,'orca')&& ismember(blockn,17:36)
        cas = 'vessel2012';
        % Vessel reaction (2012): s_treatmenttype = orca & block \in {17 36}
        %
        % In this case we are calculating the school parameters *before* and
        % *during* vessel playback, i.e. one pair for each treatment. The time
        % intervals are the same as the VA parameters for the echo sounder data.
    elseif strcmp(block(blockn).subblock(j).s_treatmenttype,'vessel')&& ismember(blockn,17:36)
        cas = 'orca2012';
        % Orca playback (2012): s_treatmenttype = vessel & block \in {17 36}
        %
        % In this case we are calculating the school parameters *before* and
        % *during* orca playback, i.e. one pair for each treatment. The time
        % intervals are the same as the parameters for the echo sounder data.
    elseif strcmp(block(blockn).subblock(j).s_treatmenttype,'predmodel')&& ismember(blockn,37:82)
        cas = 'predmodel2013';
        % Orca playback and black/white net  + predmodel (2013): s_treatmenttype = predmodel & block \in {37 82}
        %
        % This case is different since we only extract the school parameters
        % for each subblock, i.e. not each treatment and we do not calculate
        % "before" and "after" data
    else
        cas='XX';
    end
    
    if ~strcmp(cas,'XX')
        % If we have predmodel 2013 we have to define the strat/stop times per
        % subblock and not loop over treatments
        if strcmp(cas,'predmodel2013')
            % Start and stop time of the didson data
            %             d.starttime(1)  = block(blockn).subblock(j).s_start_time_mt + par.preRefTimeWB(1);
            %             d.stoptime(1)   = block(blockn).subblock(j).s_start_time_mt + par.preRefTimeWB(2);
            d.starttime(1)  = par.preRefTimeWB(1);
            d.stoptime(1)   = par.preRefTimeWB(2);
            
            d.hdr  = [block(blockn).b_groupsize,'_','didson_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock)];
            nt=1;
        else
            nt=length(block(blockn).subblock(j).treatment);
        end
        
        % Loop over treatment
        for l = 1:nt
            
  %          try % Sometimes it fails. This avoids the whole thing to crash.
                
                % If we have orca or vessel we have to define the strat/stop
                % times per treatment
                if strcmp(cas,'vessel2012')
                    d.starttime(1)  = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.passTimeVA(1);
                    d.stoptime(1)   = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.passTimeVA(2);
                    d.starttime(2) = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.preRefTimeVA(1);
                    d.stoptime(2)  = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.preRefTimeVA(2);
                    hdrn = {'_TREAT','_NULL'};
                    d.hdr  = ['didson_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock),'_treat',num2str(block(blockn).subblock(j).treatment(l).t_treatment)];
                elseif strcmp(cas,'orca2012')
                    % Start and stop time of the didson data
                    d.starttime(1)  = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.passTimeKW(1);
                    d.stoptime(1)   = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.passTimeKW(2);
                    d.starttime(2) = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.preRefTimeKW(1);
                    d.stoptime(2)  = block(blockn).subblock(j).treatment(l).t_start_time_mt + par.preRefTimeKW(2);
                    hdrn = {'_TREAT','_NULL'};
                    d.hdr  = ['didson_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock),'_treat',num2str(block(blockn).subblock(j).treatment(l).t_treatment)];
                elseif strcmp(cas,'predmodel2013')
                    hdrn = {''};
                else
                    hdrn = {''};
                    error('Unknown case')
                end
                

                % (T.mat)
                
                %Sometimes there are NaN in the time vector. Let's interpolate:
                nanind=~isnan(T(:,1));
                x = 1:length(T(:,1));
                T(:,1) = interp1(x(nanind),T(nanind,1),x,'linear','extrap');
                
                % Loop over one or two start times
                for k = 1:length(d.starttime)
                    
                    d.hdr2=[cas,hdrn{k},'_',d.hdr];
                    d.avifile = fullfile(par.datadir,'figures',[d.hdr2,'.avi']);
                    
                    disp(d.hdr2)
                    disp(d.ddfdir)
                    disp(d.avifile)
                    disp(datestr(d.starttime(k)))
                    disp(datestr(d.stoptime(k)))
                    
                    % Get files and frames to be read and plotted from the index data
                    if strcmp(cas,'predmodel2013')
                        % In this case it is only relative to start of
                        % file!
                        ind = (T(:,1)-T(1,1))>d.starttime(k) & (T(:,1)-T(1,1))<d.stoptime(k);
                    else
                        ind = T(:,1)>d.starttime(k) & T(:,1)<d.stoptime(k);
                    end
                    
                    % Are data available?
                    if sum(ind)==0
                        warning(['Failed: No Didson data for ',d.hdr])
                        disp(['Data spans:',datestr(T(1,1)),' to ',datestr(T(end,1))])
                        disp(['Passing spans:',datestr(d.starttime0),' to ',datestr(d.stoptime0)])
                    else
                        [~,ind1]=min(abs(T(:,1)-d.starttime(k)));
                        [~,ind2]=min(abs(T(:,1)-d.stoptime(k)));
                        d.indstart = T(ind1,:);
                        d.indstop = T(ind2,:);
                        d.Tsub = T(ind,:);
                        d.files=unique(d.Tsub(:,3));
                        d.startindex = d.Tsub(1,2);
                        d.stopindex = d.Tsub(end,2);
                        % Now we have finally selected a time window. Let's do
                        % the calculations:
                        cpsrPlotDidson(d);
                    end
                end
%            catch err
%                warning([d.ddfdir,' failed'])
%            end
        end
    end
end

function [ek60]=cpsrPlotDidson(d)

% This is the function to do add the algorithms

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
            %h=text(50,25,d.hdr2,'interpreter','none','color',[1 1 1]);
        else % If the plot have been made, update it
            if framenumber==1 % If this is the first frame in a new file
                data = make_first_image(data,4,400); %make the first image array
            else
                data = make_new_image(data,data.frame);
            end
%             if d.files(i)==d.indstart(3) && framenumber==d.indstart(2)% If the time is prior/after to the experiment start/stop
%                 border = 2;
%             elseif d.files(i)==d.indstop(3) && framenumber==d.indstop(2) % If the time is prior to the experiment start
%                 border = 3;
%             end
%             % Apply border color
%             switch border
%                 case 1
%                     h=text(50,25,'Pre exposure','color',[1 1 1]);
%                 case 2
%                     h=text(50,25,'EXPOSURE','color',[1 1 1]);
%                 case 3
%                     h=text(50,25,'Post exposure','color',[1 1 1]);
%             end
            set(fd,'CData',data.image);
        end
        % And add the frame to the avi file
        trackflowavi = addframe(trackflowavi,getframe(gca));
        drawnow;
%        delete(h)
    end
    % Close the ddf file
    fclose(data.fid);
end
% Close the avi file
trackflowavi = close(trackflowavi);

