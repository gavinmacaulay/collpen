setwd('/repositories/CollPen_mercurial/vesselavoidancepaper')
library(R.matlab)

#####################################
#                                   #
# Figure 2 Observed stimuli figure  #
#                                   #
#####################################

fw1 <- 0.0393701*122
fh1 <- 0.0393701*130

dat <- readMat("Figure1.mat")

#pdf("Figure1.pdf",width = fw1, height = fh1)
png(filename="Figure2.png",width = fw1, height = fh1, units="in",res=700)

par(mfrow=c(3,3),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")

plot(dat$fig11.1[1,],dat$fig11.1[2,],'col'=gray(.8),xlim=c(-10,40),ylim=c(100,150),type="l",xlab="time (s)",ylab=expression(paste("SPL (dB re 1",mu,"Pa)")))
lines(dat$fig11.2[1,],dat$fig11.2[2,])
mtext("(a)",side=3,line=0,adj=0)

plot(dat$fig12.1[1,],dat$fig12.1[2,],'col'=gray(.8),xlim=c(-10,40),ylim=c(100,150),type="l",xlab="time (s)",ylab="")
lines(dat$fig12.2[1,],dat$fig12.2[2,])
mtext("(b)",side=3,line=0,adj=0)
plot(dat$fig13.1[1,],dat$fig13.1[2,],'col'=gray(.8),xlim=c(-10,40),ylim=c(100,150),type="l",xlab="time (s)",ylab="")
mtext("(c)",side=3,line=0,adj=0)
lines(dat$fig13.2[1,],dat$fig13.2[2,])

plot(dat$fig21.1[1,]/1000,dat$fig21.1[2,],xlim=c(-10,40),ylim=c(-5,5),type="l",xlab="time (ms)",ylab="Pressure (Pa)")
lines(dat$fig21.2[1,]/1000,dat$fig21.2[2,],'col'=gray(.8))
mtext("(d)",side=3,line=0,adj=0)
plot(dat$fig22.2[1,]/1000,dat$fig22.2[2,],xlim=c(-10,40),ylim=c(-50,50),type="l",xlab="time (ms)",ylab="")
lines(dat$fig22.1[1,]/1000,dat$fig22.1[2,],'col'=gray(.8))
mtext("(e)",side=3,line=0,adj=0)
plot(dat$fig23.2[1,]/1000,dat$fig23.2[2,],xlim=c(-10,40),ylim=c(-50,50),type="l",xlab="time (ms)",ylab="")
lines(dat$fig23.1[1,]/1000,dat$fig23.1[2,],'col'=gray(.8))
mtext("(f)",side=3,line=0,adj=0)

plot(dat$fig31.1[1,],dat$fig31.1[2,],'col'=gray(.8),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")))
lines(dat$fig31.2[1,],dat$fig31.2[2,])
mtext("(g)",side=3,line=0,adj=0)
plot(dat$fig32.1[1,],dat$fig32.1[2,],'col'=gray(.8),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
lines(dat$fig32.2[1,],dat$fig32.2[2,])
mtext("(h)",side=3,line=0,adj=0)
plot(dat$fig33.1[1,],dat$fig33.1[2,],'col'=gray(.8),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
lines(dat$fig33.2[1,],dat$fig33.2[2,])
mtext("(i)",side=3,line=0,adj=0)

dev.off()

#####################################
#                                   #
#        Figure 3: The responses    #
#                                   #
#####################################

#
# Manual scoring data set
#

file <- 'C:/repositories/CollPen_mercurial/score_anova_simple.csv'
dat<-read.table(file,sep = ";",header = TRUE)
names(dat)
library(nlme)
# Vessel noise data only
T2<-dat[(dat$s_treatmenttype=='vessel'),]
T2_aov <- aov(T2$v_score ~ factor(T2$t_treatmenttype) + factor(T2$b_groupsize) + factor(T2$t_treatmenttype)*factor(T2$b_groupsize))
summary(T2_aov)

#
# Echo sounder data VA/DP analysis
#

library(XLConnect)
# This file is generated by cpscr_vapaper_figures.m
va <- loadWorkbook("VAvessel_ch2.xls", create = F)
dat<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# VA ratios (vertical echo sounder)
VAv <- log(dat$sv/dat$sv_0)
VA_aov <- aov(VAv ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
summary(VA_aov)
bartlett.test(VAv ~ factor(dat$type) + factor(dat$groupsize)+ factor(dat$type)*factor(dat$groupsize))
TukeyHSD(VA_aov,ordered=T)

# Depth difference
DPv <- (dat$m_0 - dat$m)
DP_aov <- aov(DPv ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
summary(DP_aov)
bartlett.test(DPv ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
TukeyHSD(DP_aov,ordered=T)

#
# Horizontal echo sounder
#

va <- loadWorkbook("VAvessel_ch1.xls", create = F)
dath<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# VA ratios (vertical echo sounder)
VAh <- log(dath$sv/dath$sv_0)
VAh_aov <- aov(VAh ~ factor(dath$type) + factor(dath$groupsize) + factor(dath$type)*factor(dath$groupsize))
summary(VAh_aov)
bartlett.test(VAh ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
TukeyHSD(VAh_aov,ordered=T)

# Range difference
DPh <- (dath$m_0 - dath$m)
DPh_aov <- aov(DPh ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
summary(DPh_aov)
bartlett.test(DPh ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
TukeyHSD(DPh_aov,ordered=T)


#
# Didson information (large group only)
#

didf <- loadWorkbook("Dvessel.xls", create = F)
did<-readWorksheet(didf,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# Pick only large school size
did<-did[(did$groupsize=='L'),]

dspeed <- (did$speed-did$speed_0)
DS_aov <- aov(dspeed ~ factor(did$type))
summary(DS_aov)
boxplot(dspeed ~ factor(did$type))


# CAV difference
dcav <- (did$cav - did$cav_0)
cav_aov <- aov(dcav ~ factor(did$type))
summary(cav_aov)
boxplot(dcav ~ factor(did$type))



#
# Figure 3: Plotting
#

fw2 <- 0.0393701*90*1.2
fh2 <- 0.0393701*80*2
pdf("figure3.pdf",width = fw2, height = fh2)
par(mfrow=c(3,1),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")
boxplot(T2$v_score ~ as.integer(T2$t_treatmenttype) + T2$b_groupsize,ylab="Score",names=F)
mtext("(a)",side=3,line=0,adj=0)
boxplot(VAv ~ dat$type + dat$groupsize,ylab="log(VA)",names=F)
mtext("(b)",side=3,line=0,adj=0)
boxplot(DPv ~ dat$type + dat$groupsize,ylab="Vertical change (m)")
mtext("(c)",side=3,line=0,adj=0)
dev.off()



fw2 <- 0.0393701*90*2*1.2
fh2 <- 0.0393701*80*2
pdf("figure4.pdf",width = fw2, height = fh2)
par(mfrow=c(4,2),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")

boxplot(DPh ~ dath$type + dath$groupsize,ylab="Range change (m)",names=F)
mtext("(d)",side=3,line=0,adj=0)
boxplot(VAh ~ dath$type + dath$groupsize,ylab="log[VA hor]( )")
mtext("(e)",side=3,line=0,adj=0)

boxplot(dspeed ~ did$type + did$groupsize,ylab="Speed( )")
mtext("(f)",side=3,line=0,adj=0)
boxplot(dcav ~ did$type + did$groupsize,ylab="CAV ( )")
mtext("(g)",side=3,line=0,adj=0)


dev.off()


#############################################
#                                           #
#        OBSOLETE                           #
#                                           #
#############################################

#
# Manual scoring data set
#


library(XLConnect)
# This file is generated by cpscr_vapaper_figures.m
va <- loadWorkbook("didson_stationary_sorted.xls", create = F)
dat<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)


fw2 <- 0.0393701*90*2
fh2 <- 0.0393701*80*2

pdf("figure4.pdf",width = fw2, height = fh2)
par(mfrow=c(3,2),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")

# Orca 2012
orca2012<-dat[(dat$Type=='orca2012'),]
orca_speed <- aov(orca2012$Speed ~ factor(orca2012$NT))
summary(orca_speed)
orca_vac <- aov(orca2012$CAV ~ factor(orca2012$NT))
summary(orca_vac)

boxplot(orca2012$CAV ~factor(orca2012$NT))
mtext("(a) Orca 2012 CAV",side=3,line=0,adj=0)
boxplot(orca2012$CAV ~factor(orca2012$NT))
mtext("(b) Orca 2012 Speed",side=3,line=0,adj=0)

# Vessel noise 2012
vessel2012<-dat[(dat$Type=='vessel2012'),]
vessel_speed <- aov(vessel2012$Speed ~ factor(vessel2012$NT))
summary(vessel_speed)
vessel_vac <- aov(vessel2012$CAV ~ factor(vessel2012$NT))
summary(vessel_vac)

boxplot(orca2012$CAV ~factor(orca2012$NT))
mtext("(c) Vessel 2012 CAV",side=3,line=0,adj=0)
boxplot(orca2012$Speed ~factor(orca2012$NT))
mtext("(d) Vessel 2012 Speed",side=3,line=0,adj=0)

# White/black net
predmodel2013<-dat[(dat$Type=='predmodel2013'),]
orca_speed <- aov(predmodel2013$Speed ~ factor(predmodel2013$NT))
summary(orca_speed)
orca_vac <- aov(predmodel2013$CAV ~ factor(predmodel2013$NT))
summary(orca_vac)

boxplot(predmodel2013$CAV ~factor(predmodel2013$NT))
mtext("(e) Predmodel 2013 CAV",side=3,line=0,adj=0)
boxplot(predmodel2013$Speed ~factor(predmodel2013$NT))
mtext("(f) Predmodel 2013 Speed",side=3,line=0,adj=0)

dev.off()





