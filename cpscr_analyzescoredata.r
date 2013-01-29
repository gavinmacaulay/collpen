

file_orca <- "score_anova_orca.csv"
dat_orca<-read.table(file_orca,sep = ";",header = TRUE)
orca <- glm(dat_orca$score ~ dat_orca$scorer + dat_orca$obtype + dat_orca$t_treatmenttype)
anova(orca)


file_predmodel <- "score_anova_predmodel.csv"
dat_predmodel<-read.table(file,sep = ";",header = TRUE)
predmodel <- glm(dat_predmodel$score ~ dat_predmodel$scorer + dat_predmodel$obtype + dat_predmodel$t_treatmenttype)
anova(predmodel)


file_vessel <- "score_anova_vessel.csv"
dat_vessel<-read.table(file_vessel,sep = ";",header = TRUE)
vessel_vessel <- glm(dat_vessel$score ~ dat_vessel$scorer + dat_vessel$obtype + dat_vessel$t_treatmenttype)
anova(vessel_vessel)


file_tones <- "score_anova_tones.csv"
dat_tones<-read.table(file_tones,sep = ";",header = TRUE)
tones <- glm(dat_tones$score ~ dat_tones$scorer + dat_tones$obtype + dat_tones$t_treatmenttype)
anova(tones)




