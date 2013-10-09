setwd('/repositories/CollPen_mercurial')

file <- 'C:/repositories/CollPen_mercurial/score_anova_simple.csv'
dat<-read.table(file,sep = ";",header = TRUE)
names(dat)

# Fix data

#ind<-(dat$b_groupsize=="large group in M09")
#dat$b_groupsize[ind]="large group"
#dat$b_groupsize[!ind]="small group"


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
table(dat$v_score)
table(dat$t_treatmenttype)

# Overview ANOVA
dat_aov <- aov(dat$v_score ~ dat$t_treatmenttype)
summary(dat_aov)

# Is there a time effect?
time<-(dat$t_start_time_mt - min(dat$t_start_time_mt))*60*24 # In minutes
score <- dat$score
plot(dat$v_score,time)
tim <- lm(dat$v_score ~ time)
summary(tim)

#
# Tones with sweeps
#

T1 <- dat[(dat$s_treatmenttype=='tones'),]
T1_aov <- aov(T1$v_score ~ T1$t_SL + as.factor(T1$t_F1!=T1$t_F2) + as.factor(T1$b_groupsize))
summary(T1_aov)
plot(T1_aov)

#
# Tones without sweeps
#

T2<-dat[((dat$t_F1==dat$t_F2)&(dat$s_treatmenttype=='tones')),]
# What is the mean and std score
mean(T2$v_score)
sd(T2$v_score)

T2_aov <- aov(T2$v_score ~ T2$t_SL + T2$t_F1 + T2$t_rt + T2$b_groupsize)
summary(T2_aov)

# Figure 1
pdf("Tones_figure1.pdf",width = 3, height = 7)
par(mfrow=c(4,1),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4, .8, .4), bty ="l")
boxplot(T2$v_score ~ T2$t_SL,xlab=expression(paste("SL (dB re 1",mu,"Pa)")),ylab="Score")
mtext("(a)",side=3,line=0,adj=0)

boxplot(T2$v_score ~ T2$t_F1,xlab="F (Hz)",ylab="Score")
mtext("(b)",side=3,line=0,adj=0)

boxplot(T2$v_score ~ T2$t_rt,xlab="Rise Time (ms)",ylab="Score")
mtext("(c)",side=3,line=0,adj=0)

boxplot(T2$v_score ~ T2$b_groupsize,,xlab="Groupsize",ylab="Score",axes=F)
axis(1,at=c(0,1,2,3),labels=c("","Large","Small",""))
axis(2)
mtext("(d)",side=3,line=0,adj=0)
dev.off()

T2_glm <- glm(T2$v_score ~ T2$t_SL + T2$t_F1 + T2$t_rt+ T2$b_groupsize)
summary(T2_glm)


#
# Vessel
#

V1 <- dat[(dat$s_treatmenttype=='vessel'),]
V1_aov <- aov(V1$v_score ~ V1$t_treatmenttype+ V1$b_groupsize)
summary(V1_aov)
plot(V1_aov)
mean(V1$v_score)
sd(V1$v_score)

#
# Orca
#

O1 <- dat[(dat$s_treatmenttype=='orca'),]
O1_aov <- aov(O1$v_score ~ O1$t_treatmenttype + O1$b_groupsize)
summary(O1_aov)
mean(O1$v_score)
sd(O1$v_score)


#
# Bottle (some fields are premodel! F¤%&%¤#)
#

B1 <- dat[(dat$s_treatmenttype=='predmodel')|(dat$s_treatmenttype=='premodel'),]
B1_aov <- aov(B1$v_score ~ B1$t_treatmenttype)
summary(B1_aov)
plot(B1_aov)
mean(B1$v_score)



