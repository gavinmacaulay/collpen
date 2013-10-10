setwd('/repositories/CollPen_mercurial/vesselavoidancepaper')
library(R.matlab)

#
# Figure 2 Observed stimuli figure
#

fw1 <- 0.0393701*122
fh1 <- 0.0393701*130

dat <- readMat("Figure1.mat")

#pdf("Figure1.pdf",width = fw1, height = fh1)
png(filename="Figure1.png",width = fw1, height = fh1, units="in",res=700)

par(mfrow=c(3,3),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")

plot(dat$fig11[1,],dat$fig11[2,],ylim=c(110,150),type="l",xlab="time (s)",ylab=expression(paste("SPL (dB re 1",mu,"Pa)")))
mtext("(a)",side=3,line=0,adj=0)
plot(dat$fig12[1,],dat$fig12[2,],ylim=c(110,150),type="l",xlab="time (s)",ylab="")
mtext("(b)",side=3,line=0,adj=0)
plot(dat$fig13[1,],dat$fig13[2,],ylim=c(110,150),type="l",xlab="time (s)",ylab="")
mtext("(c)",side=3,line=0,adj=0)

plot(dat$fig21[1,],dat$fig21[2,],ylim=c(-50,50),type="l",xlab="time (ms)",ylab="Pressure (Pa)")
mtext("(d)",side=3,line=0,adj=0)
plot(dat$fig22[1,],dat$fig22[2,],ylim=c(-50,50),type="l",xlab="time (ms)",ylab="")
mtext("(e)",side=3,line=0,adj=0)
plot(dat$fig23[1,],dat$fig23[2,],ylim=c(-50,50),type="l",xlab="time (ms)",ylab="")
mtext("(f)",side=3,line=0,adj=0)

plot(dat$fig31[1,],dat$fig31[2,],ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")))
mtext("(g)",side=3,line=0,adj=0)
plot(dat$fig32[1,],dat$fig32[2,],ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
mtext("(h)",side=3,line=0,adj=0)
plot(dat$fig33[1,],dat$fig33[2,],ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
mtext("(i)",side=3,line=0,adj=0)

dev.off()

#
# Figure 3 Behaviour
#

#Manual scoring
file <- 'C:/repositories/CollPen_mercurial/score_anova_simple.csv'
dat<-read.table(file,sep = ";",header = TRUE)
names(dat)

# Checking data
table(dat$b_block)
table(dat$b_groupsize)
table(dat$s_subblock)
table(dat$s_treatmenttype)
table(dat$t_treatment)
table(dat$v_score)

# Vessel noise data only
T2<-dat[(dat$s_treatmenttype=='vessel'),]

T2_aov <- aov(T2$v_score ~ T2$t_treatmenttype + T2$b_groupsize)
summary(T2_aov)

# VA/DP analysis
library(XLConnect)
va <- loadWorkbook("VAvessel.xls", create = F)
dat<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# VA ratios
VA <- log(dat$sv/dat$sv_0)
VA_aov <- aov(VA ~ dat$type + dat$groupsize)
summary(VA_aov)

DP <- (dat$m_0 - dat$m)
DP_aov <- aov(DP ~ dat$type + dat$groupsize)
summary(DP_aov)

# Figure 3 plotting
fw2 <- 0.0393701*90*2
fh2 <- 0.0393701*80*2
pdf("figure3.pdf",width = fw2, height = fh2)
par(mfrow=c(3,1),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")
#boxplot(T2$v_score ~ as.integer(T2$t_treatmenttype) + T2$b_groupsize,ylab="Score",names=c("GOS","GOSup","JH"))
boxplot(T2$v_score ~ as.integer(T2$t_treatmenttype) + T2$b_groupsize,ylab="Score ( )",names=F)
mtext("(a)",side=3,line=0,adj=0)
boxplot(DP ~ dat$type + dat$groupsize,ylab="Depth change (m)",names=F)
mtext("(b)",side=3,line=0,adj=0)
boxplot(VA ~ dat$type + dat$groupsize,ylab="log[VA] ( )")
mtext("(c)",side=3,line=0,adj=0)
dev.off()

