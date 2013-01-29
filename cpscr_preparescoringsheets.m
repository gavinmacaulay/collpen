%% Read metadata
clear
par.datadir='\\callisto\collpen\AustevollExp\data\HERRINGexp';
file = fullfile(par.datadir,'\CollPenAustevollLog.xls');
block = cp_GetExpPar(file);
save

%% Create excel sheets
clear
load
trtype={'orca','predmodel','tones','music','vessel'};
obtype={'score_video','score_didson','score_ek60vertical','score_ek60horizontal'};

m=0;
I=[];

% I found this error
%34	4	1
%34	4	2
%34	4	3
%34	4	4
%34	4	5


for tr=1:5
    %    excelsheet{tr}.trtype = trtype{tr};
    dat_ANOVA ={'t_treatmenttype' 'file' 'block' 'subblock' 'treatment' 'obtype' 'scorer' 'score'};
    for ob = 1:length(obtype)
        dat ={'t_treatmenttype' 'file' 'block'	'subblock'	'treatment'	 'score_AnneBritt'	'comment_AnneBritt'	'score_Felicia'	'comment_Felicia'	'score_Georg'	'comment_Georg'	'score_Lise'	'comment_Lise'	'score_Guillaume'	'comment_Guillaume'	'score_Herdis'	'comment_Herdis'	'score_Kirsti'	'comment_Kirsti'};
        % If tones
        dat_tone ={'t_treatmenttype' 't_F1'	't_F2'	't_SL'	't_duration'	't_rt' 'file' 'block'	'subblock'	'treatment'	  'score_AnneBritt'	'comment_AnneBritt'	'score_Felicia'	'comment_Felicia'	'score_Georg'	'comment_Georg'	'score_Lise'	'comment_Lise'	'score_Guillaume'	'comment_Guillaume'	'score_Herdis'	'comment_Herdis'	'score_Kirsti'	'comment_Kirsti'};
        for i=17:size(block,1)
            for j=1:size(block(i).subblock,2)
                % Pick only data of the correct type
                if strcmp(block(i).subblock(j).s_treatmenttype,trtype{tr})
                    for k=1:size(block(i).subblock(j).treatment,2)
                        c   = block(i).subblock(j).treatment(k);
                        % Check if there is missing data
                        if isfield(block(i).subblock(j).treatment(k),obtype{ob})
                            if eval(['~isempty(block(i).subblock(j).treatment(k).',obtype{ob},')'])
                                eval(['d = block(i).subblock(j).treatment(k).',obtype{ob},';'])
                                if strcmp(trtype{tr},'tones')
                                    sub ={c.t_treatmenttype c.t_F1 c.t_F2 c.t_SL c.t_duration c.t_rt ...
                                        d.file d.block d.subblock d.treatment d.score_AnneBritt d.comment_AnneBritt ...
                                        d.score_Felicia d.comment_Felicia d.score_Georg d.comment_Georg ...
                                        d.score_Lise d.comment_Lise d.score_Guillaume d.comment_Guillaume ...
                                        d.score_Herdis d.comment_Herdis d.score_Kirsti d.comment_Kirsti};
                                    dat_tone = [dat_tone;sub];
                                    % Data sheet for ANOVA
                                    
                                    dum = {[c.t_treatmenttype,'_F1',num2str(c.t_F1),'_F2',num2str(c.t_F2),...
                                        '_SL',num2str(c.t_SL),'_dur',num2str(c.t_duration),'_rt',num2str(c.t_rt)] ...
                                        d.file d.block d.subblock d.treatment};
                                    
                                else
                                    sub ={c.t_treatmenttype d.file d.block d.subblock d.treatment d.score_AnneBritt d.comment_AnneBritt ...
                                        d.score_Felicia d.comment_Felicia d.score_Georg d.comment_Georg ...
                                        d.score_Lise d.comment_Lise d.score_Guillaume d.comment_Guillaume ...
                                        d.score_Herdis d.comment_Herdis d.score_Kirsti d.comment_Kirsti};
                                    dat = [dat;sub];
                                    % Data sheet for ANOVA
                                    dum = {c.t_treatmenttype d.file d.block d.subblock d.treatment};
                                end
                                %dat_ANOVA ={'t_treatmenttype' 'file' 'block' 'subblock' 'treatment' 'obtype' 'scorer' 'score'};
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'AnneBritt' d.score_AnneBritt]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Felicia' d.score_Felicia]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Georg' d.score_Georg]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Lise' d.score_Lise]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Guillaume' d.score_Guillaume]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Herdis' d.score_Herdis]];
                                dat_ANOVA = [dat_ANOVA ;[dum obtype(ob) 'Kirsti' d.score_Kirsti]];
                            end
                        end
                    end
                end
            end
        end
        % Save excel sheet
        if strcmp(trtype{tr},'tones')
            xlswrite('score.xls',dat_tone,[obtype{ob},'_',trtype{tr}])
        else
            xlswrite('score.xls',dat,[obtype{ob},'_',trtype{tr}])
        end
    end
    disp(['score_anova_',trtype{tr},'.xls'])
    xlswrite(['score_anova_',trtype{tr},'.xls'],dat_ANOVA)
end

