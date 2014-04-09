setwd('/repositories/CollPen_mercurial/vesselavoidancepaper')
library(R.matlab)

#####################################
#                                   #
# Figure 3 Observed stimuli figure  #
#                                   #
#####################################

fw1 <- 0.0393701*122
fh1 <- 0.0393701*130

dat <- readMat("Figure1.mat")

#pdf("Figure1.pdf",width = fw1, height = fh1)
png(filename="Figure3.png",width = fw1, height = fh1, units="in",res=700)

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

plot(dat$fig31.1[1,],dat$fig31.1[2,],'col'=gray(.8),xlim=c(0,800),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")))
lines(dat$fig31.2[1,],dat$fig31.2[2,])
mtext("(g)",side=3,line=0,adj=0)
plot(dat$fig32.1[1,],dat$fig32.1[2,],'col'=gray(.8),xlim=c(0,800),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
lines(dat$fig32.2[1,],dat$fig32.2[2,])
mtext("(h)",side=3,line=0,adj=0)
plot(dat$fig33.1[1,],dat$fig33.1[2,],'col'=gray(.8),xlim=c(0,800),ylim=c(40,140),type="l",xlab="frequency (Hz)",ylab="")
lines(dat$fig33.2[1,],dat$fig33.2[2,])
mtext("(i)",side=3,line=0,adj=0)

dev.off()


#####################################
#                                   #
# Figure 4 Vertical array figure    #
#                                   #
#####################################

fw1 <- 0.0393701*122
fh1 <- 0.0393701*130

dat <- readMat("Figure4.mat")

f11 <- data.frame(t = dat$fig11[1,], H1 = dat$fig11[2,], H2 = dat$fig11[3,],
        H3 = dat$fig11[4,],H4 = dat$fig11[5,],H5 = dat$fig11[6,], 
        H6 = dat$fig11[7,],H7 = dat$fig11[8,],H8 = dat$fig11[9,])
f12 <- data.frame(t = dat$fig12[1,], H1 = dat$fig12[2,], H2 = dat$fig12[3,],
        H3 = dat$fig12[4,],H4 = dat$fig12[5,],H5 = dat$fig12[6,], 
        H6 = dat$fig12[7,],H7 = dat$fig12[8,],H8 = dat$fig12[9,])
f21 <- data.frame(t = dat$fig21[1,], H1 = dat$fig21[2,], H2 = dat$fig21[3,],
        H3 = dat$fig21[4,],H4 = dat$fig21[5,],H5 = dat$fig21[6,], 
        H6 = dat$fig21[7,],H7 = dat$fig21[8,],H8 = dat$fig21[9,])
f22 <- data.frame(t = dat$fig22[1,], H1 = dat$fig22[2,], H2 = dat$fig22[3,],
        H3 = dat$fig22[4,],H4 = dat$fig22[5,],H5 = dat$fig22[6,], 
        H6 = dat$fig22[7,],H7 = dat$fig22[8,],H8 = dat$fig22[9,])
f31 <- data.frame(t = dat$fig31[1,], H1 = dat$fig31[2,], H2 = dat$fig31[3,],
        H3 = dat$fig31[4,],H4 = dat$fig31[5,],H5 = dat$fig31[6,], 
        H6 = dat$fig31[7,],H7 = dat$fig31[8,],H8 = dat$fig31[9,])
f32 <- data.frame(t = dat$fig32[1,], H1 = dat$fig32[2,], H2 = dat$fig32[3,],
        H3 = dat$fig32[4,],H4 = dat$fig32[5,],H5 = dat$fig32[6,], 
        H6 = dat$fig32[7,],H7 = dat$fig32[8,],H8 = dat$fig32[9,])



#pdf("Figure1.pdf",width = fw1, height = fh1)
png(filename="Figure4.png",width = fw1, height = fh1, units="in",res=700)

par(mfrow=c(3,2),omi=c(0.1,0.1,0.1,0.1),mar=c(4, 4.5, .8, .4), bty ="l")

plot(f11$t,f11$H1,type="l",xlab="",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(60,110),'col'=gray(0))
lines(f11$t,f11$H2,'col'=gray(.1))
lines(f11$t,f11$H3,'col'=gray(.2))
lines(f11$t,f11$H4,'col'=gray(.3))
lines(f11$t,f11$H5,'col'=gray(.4))
lines(f11$t,f11$H6,'col'=gray(.5))
lines(f11$t,f11$H7,'col'=gray(.6))
lines(f11$t,f11$H8,'col'=gray(.7))
mtext("(a)",side=3,line=0,adj=0)

plot(f12$t,f12$H1,type="l",xlab="",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(60,110),'col'=gray(0))
lines(f12$t,f12$H2,'col'=gray(.1))
lines(f12$t,f12$H3,'col'=gray(.2))
lines(f12$t,f12$H4,'col'=gray(.3))
lines(f12$t,f12$H5,'col'=gray(.4))
lines(f12$t,f12$H6,'col'=gray(.5))
lines(f12$t,f12$H7,'col'=gray(.6))
lines(f12$t,f12$H8,'col'=gray(.7))
mtext("(b)",side=3,line=0,adj=0)

plot(f21$t,f21$H1,type="l",xlab="",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(70,130),'col'=gray(0))
lines(f21$t,f21$H2,'col'=gray(.1))
lines(f21$t,f21$H3,'col'=gray(.2))
lines(f21$t,f21$H4,'col'=gray(.3))
lines(f21$t,f21$H5,'col'=gray(.4))
lines(f21$t,f21$H6,'col'=gray(.5))
lines(f21$t,f21$H7,'col'=gray(.6))
lines(f21$t,f21$H8,'col'=gray(.7))
mtext("(c)",side=3,line=0,adj=0)

plot(f22$t,f22$H1,type="l",xlab="",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(70,130),'col'=gray(0))
lines(f22$t,f22$H2,'col'=gray(.1))
lines(f22$t,f22$H3,'col'=gray(.2))
lines(f22$t,f22$H4,'col'=gray(.3))
lines(f22$t,f22$H5,'col'=gray(.4))
lines(f22$t,f22$H6,'col'=gray(.5))
lines(f22$t,f22$H7,'col'=gray(.6))
lines(f22$t,f22$H8,'col'=gray(.7))
mtext("(d)",side=3,line=0,adj=0)

plot(f31$t,f31$H1,type="l",xlab="frequency (Hz)",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(70,130),'col'=gray(0))
lines(f31$t,f31$H2,'col'=gray(.1))
lines(f31$t,f31$H3,'col'=gray(.2))
lines(f31$t,f31$H4,'col'=gray(.3))
lines(f31$t,f31$H5,'col'=gray(.4))
lines(f31$t,f31$H6,'col'=gray(.5))
lines(f31$t,f31$H7,'col'=gray(.6))
lines(f31$t,f31$H8,'col'=gray(.7))
mtext("(e)",side=3,line=0,adj=0)

plot(f32$t,f32$H1,type="l",xlab="frequency (Hz)",ylab=expression(paste("PSD (dB re 1",mu,"P",a^2," H",z^-1,")")),ylim=c(70,130),'col'=gray(0))
lines(f32$t,f32$H2,'col'=gray(.1))
lines(f32$t,f32$H3,'col'=gray(.2))
lines(f32$t,f32$H4,'col'=gray(.3))
lines(f32$t,f32$H5,'col'=gray(.4))
lines(f32$t,f32$H6,'col'=gray(.5))
lines(f32$t,f32$H7,'col'=gray(.6))
lines(f32$t,f32$H8,'col'=gray(.7))
mtext("(f)",side=3,line=0,adj=0)

dev.off()



#####################################
#                                   #
#        Collate the data set       #
#                                   #
#####################################

#
# Manual scoring set
#

file <- 'C:/repositories/CollPen_mercurial/score_anova_simple.csv'
dat<-read.table(file,sep = ";",header = TRUE)
library(nlme)
# Vessel noise data only
T2<-dat[(dat$s_treatmenttype=='vessel'),]
# Only block>20
T2<-T2[(T2$b_block>20),]

# Day number
T2$day<-floor(T2$t_start_time_mt) - min(floor(T2$t_start_time_mt))+1

scoredata <- data.frame(block=T2$b_block, subblock=T2$s_subblock,treatment=T2$t_treatment,day=T2$day, vessel=factor(T2$t_treatmenttype, label=c("GOS","GOSup","JH")), 
                 groupsize=factor(T2$b_groupsize, label=c("L","S")),score=T2$v_score)

#
# VA and dd
#

library(XLConnect)
# This file is generated by cpscr_vapaper_figures.m
va <- loadWorkbook("VAvessel_ch2.xls", create = F)
dat<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# VA ratios (vertical echo sounder)
VA_log <- log(dat$sv/dat$sv_0)
VA <- (dat$sv/dat$sv_0)

dd <- (dat$m_0 - dat$m)

# Collate the EKdata and get rid of the score (NaNs)
EKdata<-data.frame(c(dat[!(names(dat) %in% c("score","type","groupsize"))],data.frame(VA_log = VA_log,vessel=factor(dat$type, label=c("GOS","GOSup","JH")), 
                 groupsize=factor(dat$groupsize, label=c("L","S")),VA = VA,dd = dd)))

#
# Didson information (large group only)
#

#didf <- loadWorkbook("Dvessel.xls", create = F)
#did<-readWorksheet(didf,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)
#
## Pick only large school size
#did<-did[(did$groupsize=='L'),]
#ds <- (did$speed-did$speed_0)
#dc <- (did$cav-did$cav_0)
#didsondata <- data.frame(c(did,data.frame(ds=ds,dc=dc)))
#

#
# Create the data frame
#


# merge two data frames by ID and Country
SD <- merge(scoredata,EKdata,by=c("block","subblock","treatment","groupsize","vessel"),all.x=T,all.y=T)
#total2 <- merge(total,T3,by=c("block","subblock","treatment","groupsize","type"),all.x=F,all.y=T)
SD["block"] <- SD["block"]-20

# Write to Excel file
wb <- loadWorkbook("SuppData.xlsx", create = TRUE)
createSheet(wb, name = "SuppData")
writeWorksheet(wb, SD, sheet = "SuppData")
saveWorkbook(wb)

#####################################
#                                   #
# Figure 4     #
#                                   #
#####################################

dat4 <- readMat("Figure4.mat")





