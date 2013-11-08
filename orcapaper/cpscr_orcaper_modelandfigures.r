setwd('/repositories/CollPen_mercurial/orcapaper')
library(R.matlab)

#####################################
#                                   #
# Figure 2 Observed stimuli figure  #
#                                   #
#####################################

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

# Orca data only
T2<-dat[(dat$s_treatmenttype=='orca'),]
T2_aov <- aov(T2$v_score ~ T2$t_treatmenttype + T2$b_groupsize)
summary(T2_aov)

#
# Vertical echo sounder data VA/DP analysis
#

library(XLConnect)
# This file is generated by cpscr_vapaper_figures.m
va <- loadWorkbook("VAorca_ch2.xls", create = F)
dat<-readWorksheet(va,sheet="Sheet1", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

# VA ratios (vertical echo sounder)
VA <- log(dat$sv/dat$sv_0)
VA_aov <- aov(VA ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
summary(VA_aov)

VA_lme <- lm(VA ~ factor(dat$type) + factor(dat$groupsize) + factor(dat$type)*factor(dat$groupsize))
summary(VA_lme)

TukeyHSD(VA_lme,ordered=T)

# Depth difference

DP <- (dat$m_0 - dat$m)
DP_aov <- aov(DP ~ dat$type + dat$groupsize)
summary(DP_aov)

#
# Horizontal echo sounder data VA/DP analysis
#

# Here we have problems with pen wall echoes. 
# The following blocks are not valid:
# 20,21,22,23,27,28,29,30,31,32,33,34 



#
# Didson school parameters (to come)
#

#
# Figure 3: Plotting
#

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

