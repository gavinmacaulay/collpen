function [VA1,VA2]=cp_ProcessEchosounderdata(blockn,block,par)

% This is the block, subblock, treatment vector. If the vecotr is shorter,
%
% Parameters for picking the right data
% Channel 1:
% VA1 = [blockn subblock treatment sv_pass sv_ref m_pass m_ref]
% Channel 2:
% VA2 = [blockn subblock treatment sv_pass sv_ref m_pass m_ref]

% block(blockn).subblock(subblockn).treatment(treatmentn)
N = length(block(blockn).subblock);
VA1=[];
VA2=[];
% read in the raw data (this happens once per block)
dataPath=fullfile(par.datadir,['block',num2str(blockn)],'echosounder');
[ek60]=cpsrReadEK60(dataPath,par);

% Loop over subblock
for j=1:N
    % Loop over treatment
    for l = 1:length(block(blockn).subblock(j).treatment)
       try
            hdr = fullfile(par.datadir,'figures',['echosounder_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock),'_']);
            d.starttime = block(blockn).subblock(j).treatment(l).t_start_time_mt;
            d.stoptime = block(blockn).subblock(j).treatment(l).t_stop_time_mt;
            
            if strcmp(block(blockn).subblock(j).treatment(l).t_treatmenttype,'tones')
                d.str = [hdr,block(blockn).subblock(j).treatment(l).t_treatmenttype,'_F1_',num2str(block(blockn).subblock(j).treatment(l).t_F1),...
                    '__F2_',num2str(block(blockn).subblock(j).treatment(l).t_F1),'__rt_',num2str(block(blockn).subblock(j).treatment(l).t_rt),...
                    '__SL_',num2str(block(blockn).subblock(j).treatment(l).t_SL)];
            else
                d.str = [hdr,block(blockn).subblock(j).treatment(l).t_treatmenttype];
            end
            d.str_anon  = [hdr,'treat',num2str(block(blockn).subblock(j).treatment(l).t_treatment)];
            d.hdr = ['echosounder_block',num2str(block(blockn).b_block),'_sub',num2str(block(blockn).subblock(j).s_subblock),'_treat',num2str(block(blockn).subblock(j).treatment(l).t_treatment)];
            %disp(d.hdr)
            
            % Plot figure for Guillauem #1 paper.
            if (block(blockn).b_block==30) && (block(blockn).subblock(j).s_subblock==3) && (block(blockn).subblock(j).treatment(l).t_treatment == 2)
                pl=true;
            else
                pl=false;
            end
            
            VAsub=cpsrPlotEK60(ek60,d,par,pl,block,blockn,j,l);
            VA1 = [VA1;[blockn j l VAsub(1).sv_pass VAsub(1).sv_ref VAsub(1).m_pass VAsub(1).m_ref]];
            if length(par.ek60.channelsToProcess)==2
            VA2 = [VA2;[blockn j l VAsub(2).sv_pass VAsub(2).sv_ref VAsub(2).m_pass VAsub(2).m_ref]];
            end
         catch err
             disp([d.hdr,' failed'])
         end
    end
end

clear ek60 %

% cpsrReadEK60
%
% script reads in EK60 files from a directory using rawreader and concatenates them into a
% single structure.
%
% inputs
% dataPath - path to the *.raw data files
%par.ek60.timeZoneOffset=2;  % Time offset using +2 as data timestamps are utc and we are +2 (check this if timestamps look strange)
%par.ek60.useCalParFile=0;  % 1 means use a file after calibration, 2 is just use whatever is in raw data for uncalibrated calcs
%par.ek60.calFileName='';   % name of EK60 calibration file to use if par =1
%par.ek60.channelsWanted=[1 2]; %channels wanted
%
% outputs
% ek60 - rawreader structure file

function [ek60]=cpsrReadEK60(dataPath,par)


temp=['fileList=dir(''' fullfile(dataPath,'*.raw'),''');'];
eval(temp);

% read in files from an entire directory and concatenate the pings

for i=1:size(fileList);
    % read in whole file
    [header, rawData, rstate] = readEKRaw(fullfile(dataPath,fileList(i).name),'Angles', false,'TimeOffset' ,par.ek60.timeZoneOffset);
    
    % generate a cal file  (again assumes that no changes in calibration
    % parameters ocurred !
    if par.ek60.useCalParFile==0;
        calParms       = readEKRaw_GetCalParms(header, rawData);
    elseif par.ek60.useCalParFile==1;
        calParms = readEKRaw_ReadXMLParms(par.ek60.calFileName); %  extract calibration parameters from xml cal file
    end
    
    %  convert power to sv
    rawData = readEKRaw_Power2Sv(rawData, calParms);
    
    % loop through the pings (If there are less than wanted channels):
    dum = par.ek60.channelsWanted;
    if length(dum)> length(rawData.pings)
        dum=1;
    end
    for chan=dum
        if i==1
            a=fieldnames(rawData.pings);  % get names in structure
            b=fieldnames(rawData.config);  % get names in structure
        end
        
        for j=1:size(a,1);  % loop through pings
            if i==1
                eval( ['ek60.pings(',num2str(chan),').', a{j} , ' =[];']); % initialize new struct
            end
            
            if (strcmp(a{j},'range'))  ;  % only do range one time  as has different orientation than the others.  Assumes range does not change
                if i==1
                    eval( ['ek60.pings(',num2str(chan),').',a{j} '=[ rawData.pings(',num2str(chan),').',a{j},'];' ]);
                end
            else
                eval( ['ek60.pings(',num2str(chan),').',a{j} '=[ ek60.pings(',num2str(chan),').',a{j},' rawData.pings(',num2str(chan),').',a{j},'];' ]);
                
            end
        end
        
        % loop through config-- ASSUMES THAT CONFIGURATION IS CONSTANT BETWEEN FILES !!!
        for j=1:size(b,1)
            eval( ['ek60.config(',num2str(chan),').',b{j} '=[  rawData.config(',num2str(chan),').',b{j},'];' ]);
        end
    end
    
    % loop through the GPS data
    if i==1;
        c=fieldnames(rawData.gps);  % get names in structure
    end
    for j=1:size(c,1);  % loop through fields
        if i==1
            eval( ['ek60.gps.', c{j} , ' =[];']); % initialize new struct
        end
        eval( ['ek60.gps.',c{j} '=[ ek60.gps.',c{j},' rawData.gps.',c{j},'];' ]);
    end
    
end



function [VA]=cpsrPlotEK60(ek60,d,par,pl,block,blockn,subblockn,treatn)
% inputs
% ek60 - ek60 data read in with rawreader for entire block
% label - string with a description of the events
% event_start = start of event in mat time
%event_end = end of event in mat time
%par.ek60.displayThreshold=[-70 -34] ; % display threshold for plotting
%par.ek60.displayRange=[0 9.5;0 9.5];% depth to display image over
%par.ek60.AnalyzeRange=[1 9 ; 1 9];% analyssis range (min, max) by channel
%par.ek60.channelsToProcess=[1 2] % which channels to plot
%par.ek60.smoothWindow=31% number of pings to smooth over with running mean
%par.ek60.writePath='C:\Collpen\Processing\alexCode\'% ticks plotten on x axis on this interval
%par.ek60.preTrialSec=120 % time in seconds to plot data before and after the trial
%par.ek60.minPings=smoothWindow*2 %minimum pings for plotting
%
% outputs
% generates a png file displaying echosounder data
% echogram with event start stop times, and median depth smoothed over
% smoothwindow
% also gives mean Sv


eventStart=d.starttime;
eventEnd=d.stoptime;

% for each channel of interest, process the data
for i=1:length(par.ek60.channelsToProcess);
    ch=par.ek60.channelsToProcess(i);
    % covert times of interest into indices
    % piece of interest
    [index.ping]=( ((ek60.pings(ch).time>eventStart-par.ek60.preTrialTime))...
        &((ek60.pings(ch).time<eventEnd+par.ek60.preTrialTime)) ) ;
    index.ping=find(index.ping==1);  % index into data of interest to plot
    
    index.labels=[ min(find(ek60.pings(ch).time>eventStart))  min(find(ek60.pings(ch).time>eventEnd))]; % indicies for vertical axis labels based on start and stop times of the event
    %
    
    fname=[d.str,'_channel_', num2str(ch)]; % string for naming
    fname_anon=[d.str_anon,'_channel_', num2str(ch)]; % string for naming
    
    % range index for data anlysis and display
    index.analyze=find(ek60.pings(ch).range >=par.ek60.AnalyzeRange(ch,1) & ek60.pings(ch).range<=par.ek60.AnalyzeRange(ch,2) );
    index.disp=find(ek60.pings(ch).range >=par.ek60.displayRange(ch,1) & ek60.pings(ch).range <=par.ek60.displayRange(ch,2) );
    
    stime=(ek60.pings(ch).time(index.labels(1))); % start time
    
    % Calculate some statistics for plotting;
    % now compute sv (i.e. linear units m^2/m^3)
    sv=10.^(ek60.pings(ch).Sv(index.analyze,index.ping)/10);
    meansv=(mean(sv,1));
    
    % compute the median depth
    for k=1:size(sv,2)
        temp= cumsum(sv(:,k));
        temp=temp./max(temp);  % cumulative sum normalized to 1
        ind=min(find(temp>0.5)); % median depth
        medRange(k)=ek60.pings(ch).range(index.analyze(ind));
    end
    
    if size(sv,2)>par.ek60.minPings;
        % apply a running mean to compute sv should probably ultimatley use a
        % better windowing scheme...
        meansvSmoothed=filter(ones(1,par.ek60.smoothWindow)/par.ek60.smoothWindow,1,meansv);
        medRangeSmoothed=filter(ones(1,par.ek60.smoothWindow)/par.ek60.smoothWindow,1,medRange);
        % smoothing winow has edge effects so generate index for data not to plot
        ind=par.ek60.smoothWindow:length(meansvSmoothed);
        
        time = (ek60.pings(ch).time(index.ping)-stime)*3600*24;
        
        % Calculate the VA coefficient and median depth changes
        %if 
        type = block(blockn).subblock(subblockn).s_treatmenttype;
        if strcmp(type,'vessel')
            ind_ref  = time > par.ek60.preRefTimeVA(1) & time < par.ek60.preRefTimeVA(2);
            ind_pass = time > par.ek60.passTimeVA(1)   & time < par.ek60.passTimeVA(2);
        elseif strcmp(type,'orca')
            ind_ref  = time > par.ek60.preRefTimeKW(1) & time < par.ek60.preRefTimeKW(2);
            ind_pass = time > par.ek60.passTimeKW(1)   & time < par.ek60.passTimeKW(2);
        end
        
        if (strcmp(type,'vessel')||strcmp(type,'orca'))%&i==2 %Only do this for channel 2
            VA(i).sv_pass = mean(meansv(ind_pass));
            VA(i).sv_ref  = mean(meansv(ind_ref));
            VA(i).m_pass = mean(medRange(ind_pass));
            VA(i).m_ref  = mean(medRange(ind_ref));
            plVA = true;
            
        else
            plVA = false;
            VA(i).sv_pass = NaN;
            VA(i).sv_ref  = NaN;
            VA(i).m_pass = NaN;
            VA(i).m_ref  = NaN;
        end
        
        % plot figure 1
        
        scrsz = get(0,'ScreenSize');
        figure('Position',scrsz)
        subplot(4,1,1:3)
        dum = par.ek60.transdepth-(ek60.pings(ch).range(index.disp));
        if pl && i==2
            imagesc(time,dum,(ek60.pings(ch).Sv(index.disp,index.ping)))
            axis ij  %changes frame of reference to the axis
            ylabel('Depth (m)')
        else
            imagesc(time,(ek60.pings(ch).range(index.disp)),(ek60.pings(ch).Sv(index.disp,index.ping)))
            axis xy  %changes frame of reference to the axis
            ylabel('Range (m)')
        end
        hold on
        h1=plot((ek60.pings(ch).time(index.ping(ind))-stime)*3600*24,medRangeSmoothed(ind),'k','linewidth',2); % plot median range of backscatter 50% percentile in analysis window
        for j=1:length(index.labels); % plot vertical marks for start/stop
            h2(j)=plot([(ek60.pings(ch).time(index.labels(j))-stime)*3600*24 (ek60.pings(ch).time(index.labels(j))-stime)*3600*24],...
                [par.ek60.displayRange(ch,1),par.ek60.displayRange(ch,2)],'w','linewidth',1.5);
        end
        if plVA
            plot(time([min(find(ind_pass)) max(find(ind_pass))]),[VA.m_pass VA.m_pass],'Color',[.99 .99 .99],'linewidth',1.5)
            plot(time([min(find(ind_ref))  max(find(ind_ref)) ]),[VA.m_ref  VA.m_ref ],'Color',[.99 .99 .99],'linewidth',1.5)
        end
        
        caxis(par.ek60.displayThreshold)
        colorbar('location','SouthOutside')
        % axis([min(index.ping) max(index.ping) par.ek60.displayRange(ch,:)])
        
        %datetick('keeplimits')
        
        h3=title(fname,'interpreter', 'none');
        
        % now generate an SV time series
        subplot(4,1,4)
        plot((ek60.pings(ch).time(index.ping(ind))-stime)*3600*24,10*log10(meansv(ind)),'k');
        hold on
        plot((ek60.pings(ch).time(index.ping(ind))-stime)*3600*24,10*log10(meansvSmoothed(ind)),'.-');
        xlabel('Time relative to stimulus start (sec)')
        ylabel('Sv (m ^{-1})','interpreter','Tex')
        if plVA
            plot(time([min(find(ind_pass)) max(find(ind_pass))]),10*log10([VA.sv_pass VA.sv_pass]),'Color',[.4 .4 .4],'linewidth',1.5)
            plot(time([min(find(ind_ref)) max(find(ind_ref))]),10*log10([VA.sv_ref VA.sv_ref]),'Color',[.4 .4 .4],'linewidth',1.5)
        end
        axis tight
        
        eval(['print ',fname,' -r200',' -dpng'])
        delete(h3)
        eval(['print ',fname_anon,' -r200',' -dpng'])
        
        % Plot Guillaumes figure
        if pl && i==2
            % Delete depth and vertical lines
            delete(h1)
            delete(h2)
            %delete(h3)
            print('-dpng','-r800',fullfile(par.datadir,'figures','Guillaume_Figure1'))
        end
        close
    end
end

