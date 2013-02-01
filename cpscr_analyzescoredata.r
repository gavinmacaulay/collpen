setwd('/repositories/CollPen_mercurial')

file_orca <- 'C:/repositories/CollPen_mercurial/score_anova.csv'
dat<-read.table(file_orca,sep = ";",header = TRUE)
names(dat)


dat_aov <- aov(dat$v_score ~ dat$v_scorer + dat$v_obtype + dat$t_treatmenttype)
summary(dat_aov)

dat_ANOVA ={'b_block' 'b_groupsize' 's_subblock' 's_treatmenttype' 't_treatment'...
            't_treatmenttype' 't_start_time_mt' 't_stop_time_mt' 't_F1' 't_F2' 't_SL'...
            't_duration' ' t_rt' 'v_obtype' 'v_scorer' 'v_score'};

table(dat$b_block)
table(dat$b_groupsize)
table(dat$s_subblock)
table(dat$s_treatmenttype)

table(dat$t_treatment)
table(dat$t_treatmenttype)
table(dat$t_F2)
table(dat$t_F2)
table(dat$t_SL)
table(dat$t_duration)
table(dat$t_rt)
table(dat$v_obtype)
table(dat$v_scorer)
table(dat$v_score)

table(dat$t_treatmenttype)

table(dat$t_treatmenttype)



predmodel <- aov(dat_predmodel$score ~ dat_predmodel$scorer + dat_predmodel$obtype + dat_predmodel$t_treatmenttype)
summary(predmodel)

file_vessel <- "score_anova_vessel.csv"
dat_vessel<-read.table(file_vessel,sep = ";",header = TRUE)
vessel_vessel <- aov(dat_vessel$score ~ dat_vessel$scorer + dat_vessel$obtype + dat_vessel$t_treatmenttype)
summary(vessel_vessel)

# Something is fucked in 32.4.11 + 17.1.1 + 25.1.1
file_tones <- "score_anova_tones.csv"
dat_tones<-read.table(file_tones,sep = ";",header = TRUE)
tones <- aov(dat_tones$score ~ dat_tones$scorer + dat_tones$obtype + dat_tones$t_treatmenttype)
anova(tones)




