%% This script plot the figures for the orca paper.
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

load(fullfile('C:\repositories\CollPen_mercurial\','VA.mat'));


%% Prepare VA data
% Fit block informaion and va data
VAvessel={'block','sub block','treatment','sv_0','sv','m_0','m','score','type','group size'};
% Desse manglar:
%27 3 2
%27 3 3
%33 4 1

% Several of the horizontal blocks are invalid due to net pen wall
% interactions

%# 20,21,22,23,27,28,29,30,31,32,33,34
blocks{1} = [24:26 35];
% The vertical ones are ok
blocks{2} = 20:35;

for ch=1:2
    eval(['VA=VA',num2str(ch),';']);
VAvessel={'block','subblock','treatment','sv_0','sv','m_0','m','score','type','groupsize'};
    for b=blocks{ch}
        for sb=1:length(block(b).subblock)
            if strcmp(block(b).subblock(sb).s_treatmenttype,'orca')
                for trn=1:length(block(b).subblock(sb).treatment)
                    % Match with va data
                    switch block(b).subblock(sb).treatment(trn).t_treatmenttype
                        case 'orca_nor'
                            tr = 'NOR';
                        case 'orca_can'
                            tr = 'CAN';
                        case 'orca_is'
                            tr = 'IS';
                    end
                    gs='NaN';
                    switch block(b).b_groupsize
                        case 'large group in M09'
                            gs='L';
                        case 'small group in M09'
                            gs='S';
                    end
                    ind=VA(:,1)==b & VA(:,2)==sb & VA(:,3)==trn;
                    %                     indsc=scr(:,1)==b & scr(:,3)==sb & scr(:,5)==trn;
                    if sum(ind)>0
                        vas = num2cell(VA(ind,:));% groupsize tr
                    else
                        vas = num2cell([b sb trn NaN NaN NaN NaN]);% groupsize tr
                    end
                    
                    %                     if sum(indsc)>0
                    %                         scrs = num2cell(scr(indsc,14));% groupsize tr
                    %                     else
                    scrs = num2cell(NaN);% groupsize tr
                    %                     end
                    
                    VAvessel=[VAvessel;[vas scrs tr gs]];
                end
            end
        end
    end
    disp(VAvessel)
    xlswrite(['VAorca_ch',num2str(ch),'.xls'],VAvessel)
    clear VAvessel
end
