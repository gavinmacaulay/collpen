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
#         The responses             #
#                                   #
#####################################

# Read data
library(XLConnect)
didf <- loadWorkbook("SuppData.xlsx", create = F)
SD<-readWorksheet(didf,sheet="SuppData", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

#
# The scoring team
#

T2_aov <- aov(SD$score ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
summary(T2_aov)

"boxplot(SD$score ~ factor(SD$block))


#
# Echosounder VA analysis
#

# What is the mean response and is the VA significantly different from 1 (or different from 0 in log domain)
# Mean response
mean(SD$VA[!is.na(SD$VA)])
# t-test in log domain
t.test(SD$VA_log)

# VA (vessel avoidance) ANOVA
VA_aov <- aov(SD$VA_log ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
summary(VA_aov)
bartlett.test(SD$VA_log ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
TukeyHSD(VA_aov,ordered=T)

#
# Echosounder dd analysis
#

# What is the mean response and is the dd significantly different from 0?
mean(SD$dd[!is.na(SD$dd)])
t.test(SD$dd)

# dd (depth difference) ANOVA
dd_aov <- aov(SD$dd ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
summary(dd_aov)
bartlett.test(SD$dd ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
TukeyHSD(dd_aov,ordered=T)

##############################
#                            #
#         Figure 4           #
#                            #
##############################

library(ggplot2)
require(gridExtra)

fw2 <- 0.0393701*90*1.2
fh2 <- 0.0393701*80*2
pdf("figure4.pdf",width = fw2, height = fh2)

p1<-ggplot(aes(y=score, x = vessel, fill = groupsize),data=SD) +
     geom_boxplot(aes(colour = factor(groupsize),ylab="Score"),colour='black') + 
     xlab("") +
     ylab("Score") +
     scale_fill_manual('groupsize', values = c('Large' = 'grey90', 'Small' = 'grey50'))  +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)
        

p2<- ggplot(aes(y=VA, x = vessel, fill = groupsize),data=SD) +
     geom_boxplot(aes(colour = factor(groupsize)),colour='black') + 
     xlab(" ") +
     ylab("VA") +
     scale_fill_manual('groupsize', values = c('Large' = 'grey90', 'Small' = 'grey50'))  +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)

p3<-ggplot(aes(y=dd, x = vessel, fill = groupsize),data=SD) +
     geom_boxplot(aes(colour = factor(groupsize)),colour='black') + 
     ylab("Vertical change (m)") +
     scale_fill_manual('groupsize', values = c('Large' = 'grey90', 'Small' = 'grey50'))  +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)

grid.arrange(p1, p2, p3)

dev.off()

