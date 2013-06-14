setwd('/repositories/CollPen_mercurial')

file_orca <- 'C:/repositories/CollPen_mercurial/score_anova.csv'
dat<-read.table(file_orca,sep = ";",header = TRUE)
names(dat)

# Checking data
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

# Fix a problem in the data, i.e change premodel to predmodel
dat$s_treatmenttype[(dat$s_treatmenttype=='premodel')] = 'predmodel'


# After consulting Arne Johannes we have decided to merge observation type and 
# observation system.
dat2 <- by(dat$v_score,dat$s_subblock,mean)

dat2 <- by(dat$v_score,c(as.factor(dat$b_block),as.factor(dat$s_subbblock),as.factor(dat$t_treatment)),mean)



# Overview ANOVA
dat_aov <- aov(dat$v_score ~ dat$v_scorer + dat$v_obtype + dat$t_treatmenttype)
summary(dat_aov)

# Is there a time effect?
time<-(dat$t_start_time_mt - min(dat$t_start_time_mt))*60*24 # In minutes
score <- dat$score
plot(dat$v_score,time)
tim <- lm(dat$v_score ~ time)
summary(tim)

# glm
score<-dat$v_score/3
glm.out=glm(score ~ dat$b_block + factor(dat$b_groupsize) + dat$s_subblock + dat$t_treatment + factor(dat$v_scorer) + factor(dat$v_obtype)  + factor(dat$s_treatmenttype),family=quasibinomial(logit))
summary(glm.out)

# Tones with sweeps
T1<-dat[(dat$s_treatmenttype=='tones'),]
T1_aov <- aov(T1$v_score ~ T1$v_scorer + T1$v_obtype + T1$t_SL + T1$t_F1 + T1$t_rt)
summary(T1_aov)
plot(T1_aov)

# Tones without sweeps
T2<-dat[((dat$t_F1==dat$t_F2)&(dat$s_treatmenttype=='tones')),]
T2_aov <- aov(T2$v_score ~ T2$v_scorer + T2$v_obtype + T2$t_SL + T2$t_F1 + T2$t_rt)
summary(T2_aov)
names(dat)

glm.out=glm(T2$v_score/3 ~ T2$t_rt + T2$t_SL + T2$t_F1 + T2$b_block + factor(T2$b_groupsize) + T2$t_treatment + factor(T2$v_scorer) ,family=quasibinomial(logit))

# Vessel
V1 <- dat[(dat$s_treatmenttype=='vessel'),]
V1_aov <- aov(V1$v_score ~ V1$v_scorer + V1$v_obtype + V1$t_treatmenttype)
summary(V1_aov)

# Orca
# Vessel
O1 <- dat[(dat$s_treatmenttype=='orca'),]
O1_aov <- aov(V1$v_score ~ V1$v_scorer + V1$v_obtype + V1$t_treatmenttype)
summary(O1_aov)

# Bottle (some fields are premodel! F¤%&%¤#)
B1 <- dat[(dat$s_treatmenttype=='predmodel')|(dat$s_treatmenttype=='premodel'),]
B1_aov <- aov(B1$v_score ~ B1$v_scorer + B1$v_obtype + B1$t_treatmenttype)
summary(B1_aov)



