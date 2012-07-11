%% Process hydrophone data and create figure in the figure directory
clear
close all

% Data directory
par.datadir = 'F:\collpen\AustevollExp\data\HERRINGexp';
par.datadir = 'C:\repositories\matlabtoolbox';

% Parameters and metadata
file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

%% Block timeline
clf

subplot(121)
k=1;
ind =[1:6 11:12];
for i=ind%length(block)
    hold on
    plot([block(i).b_starttime_mt block(i).b_starttime_mt],[0 1])
    text(block(i).b_starttime_mt,(length(ind)-k)/length(ind),...
        ['Block ',num2str(block(i).b_block),', ',block(i).b_starttime])
    k=k+1;
end
datetick

subplot(122)
k=1;
ind= [7:10 13:length(block)];
for i=ind
    hold on
    plot([block(i).b_starttime_mt block(i).b_starttime_mt],[0 1])
    text(block(i).b_starttime_mt,(length(ind)-k)/length(ind),...
        ['Block ',num2str(block(i).b_block),', ',block(i).b_starttime])
    k=k+1;
end
datetick   
    
%% Subblock timelines
k=1;
close all
%ind= 1:length(block);
ind= 17:length(block);

for i=ind
    figure
    hold on
    k=1;
    N = length(block(i).subblock);
    M = (12+5+3+3+4);
    for j=1:N
        disp(block(i).subblock(j))
        plot([block(i).subblock(j).s_start_time_mt block(i).subblock(j).s_stop_time_mt],[(M-k)/M (M-k)/M],'r')

%         plot([block(i).subblock(j).s_start_time_mt block(i).subblock(j).s_start_time_mt],[0 1])
%         plot([block(i).subblock(j).s_stop_time_mt block(i).subblock(j).s_stop_time_mt],[0 1],'r')
        text(block(i).subblock(j).s_stop_time_mt,(M-k)/M,...
            ['Subblock ',num2str(block(i).subblock(j).s_subblock),', ',block(i).subblock(j).s_notes],'interpreter','none')
        k=k+1;
        for l = 1:length(block(i).subblock(j).treatment)
            plot([block(i).subblock(j).treatment(l).t_start_time_mt block(i).subblock(j).treatment(l).t_stop_time_mt],[(M-k)/M (M-k)/M])
            plot(block(i).subblock(j).treatment(l).t_start_hydrophonePC_mt, (M-k)/M,'*')
            if strcmp(block(i).subblock(j).treatment(l).t_treatmenttype,'tones')
            text(block(i).subblock(j).treatment(l).t_stop_time_mt,(M-k)/M,...
                [block(i).subblock(j).treatment(l).t_treatmenttype,', F1=',num2str(block(i).subblock(j).treatment(l).t_F1),...
                ', F2=',num2str(block(i).subblock(j).treatment(l).t_F1),', rt=',num2str(block(i).subblock(j).treatment(l).t_rt),...
                ', SL=',num2str(block(i).subblock(j).treatment(l).t_SL)],'interpreter','none')
            else
            text(block(i).subblock(j).treatment(l).t_stop_time_mt,(M-k)/M,...
                [block(i).subblock(j).treatment(l).t_treatmenttype],'interpreter','none')
            end
            k=k+1;
        end
    end
    title(['Block ',num2str(block(i).b_block),', ',block(i).b_comments],'interpreter','none')
    datetick
    pause
end


