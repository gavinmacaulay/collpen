%% Read metadata
clear
par.datadir='\\callisto\collpen\AustevollExp\data\HERRINGexp';
file = fullfile(par.datadir,'\CollPenAustevollLog.xls');
block = cp_GetExpPar(file);
save

%% Create excel sheets
clear
load
%trtype={'orca','predmodel','tones','music','vessel'};
obtype={'video','didson','ek60vertical','ek60horizontal'};

% I found this error
%34	4	1
%34	4	2
%34	4	3
%34	4	4
%34	4	5

dat_ANOVA ={'b_block' 'b_groupsize' 's_subblock' 's_treatmenttype' 't_treatment'...
    't_treatmenttype' 't_start_time_mt' 't_stop_time_mt' 't_F1' 't_F2' 't_SL'...
    't_duration' ' t_rt' 'v_obtype' 'v_scorer' 'v_score'};

for b=17:size(block,1)
    for s=1:size(block(b).subblock,2)
        % Pick only data of the correct type
        for t=1:size(block(b).subblock(s).treatment,2)
            trt   = block(b).subblock(s).treatment(t);
            sbl   = block(b).subblock(s);
            if strcmp(sbl.s_treatmenttype,'tones')
                t_treatmenttype = [trt.t_treatmenttype,'_F1',num2str(trt.t_F1),'_F2',num2str(trt.t_F2),...
                    '_SL',num2str(trt.t_SL),'_dur',num2str(trt.t_duration),'_rt',num2str(trt.t_rt)];
            else
                t_treatmenttype = trt.t_treatmenttype;
            end
            dum={block(b).b_block block(b).b_groupsize sbl.s_subblock ...
                sbl.s_treatmenttype trt.t_treatment t_treatmenttype ...
                trt.t_start_time_mt trt.t_stop_time_mt trt.t_F1 trt.t_F2 trt.t_SL...
                trt.t_duration trt.t_rt'};
            % Data sheet for ANOVA
            if ~isfield(trt,'score')||isempty(trt.score)
                warning(['No data at all for for block:',...
                            num2str(block(b).b_block),' Subblock:',num2str(sbl.s_subblock),...
                            ' Treatment:',num2str(trt.t_treatment)])
            else
                for ob = 1:length(trt.score)
                    % Add all scorers (v-level)
                    if ~isempty(trt.score(ob).d_score)
                        scr = trt.score(ob).d_score;
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'AnneBritt' scr.score_AnneBritt]];
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'Felicia' scr.score_Felicia]];
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'Georg' scr.score_Georg]];
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'Lise' scr.score_Lise]];
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'Herdis' scr.score_Herdis]];
                        dat_ANOVA = [dat_ANOVA ;[dum trt.score(ob).d_obtype 'Kirsti' scr.score_Kirsti]];
                    else
                        warning(['Missing data for block:',...
                            num2str(block(b).b_block),' Subblock:',num2str(sbl.s_subblock),...
                            ' Treatment:',num2str(trt.t_treatment),' Obstype:',obtype{ob}])
                    end
                end
            end
        end
    end
end

nrows=size(dat_ANOVA,1);
str = '%u; %s; %u; %s; %u; %s; %f; %f; %u; %u; %u; %u; %u; %s; %s; %u\n';
str_h = '%s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s\n';
fid = fopen('score_anova.csv', 'wt');
fprintf(fid,str_h, dat_ANOVA{1,:});
for row=2:nrows
    fprintf(fid,str, dat_ANOVA{row,:});
end
fclose(fid)

