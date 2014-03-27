setwd('/repositories/CollPen_mercurial/vesselavoidancepaper')
library(R.matlab)
library(ggplot2)
library(XLConnect)
require(gridExtra)


#####################################
#                                   #
#         The responses             #
#                                   #
#####################################

# Read data
didf <- loadWorkbook("SuppData.xlsx", create = F)
SD<-readWorksheet(didf,sheet="SuppData", startRow = 0, endRow = 0, startCol = 0, endCol = 0)

#
# The scoring team
#

mean(SD$score[!is.na(SD$score)])
# t-test in log domain
sd(SD$score)/sqrt(length(SD$score))

T2_aov <- aov(SD$score ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))
summary(T2_aov)
bartlett.test(SD$score ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))

T2_aov <- aov(log(SD$score) ~ factor(SD$vessel) + factor(SD$groupsize) + factor(SD$vessel)*factor(SD$groupsize)+factor(SD$block))





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
#         Figure 5           #
#                            #
##############################


fw2 <- 0.0393701*90*1.2
fh2 <- 0.0393701*80*2
pdf("figure5.pdf",width = fw2, height = fh2)

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



pdf("SuppFig1.pdf",width = fw2, height = fh2)


p1<-ggplot(aes(y=score, x=factor(block)),data=SD) +
     geom_boxplot(colour='black') + 
     xlab("") +
     ylab("Score") +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)
        

p2<- ggplot(aes(y=VA, x = factor(block)),data=SD) +
     geom_boxplot(colour='black') + 
     xlab(" ") +
     ylab("VA") +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)

p3 <-ggplot(aes(y=dd, x = factor(block)),data=SD) +
     geom_boxplot(colour='black') + 
     ylab("Vertical change (m)") +
     xlab("Block #") +
     theme_bw() +
     opts(axis.line = theme_segment(colour = "black"),
        panel.grid.major = theme_blank(),
        panel.grid.minor = theme_blank(),
        panel.border = theme_blank())+
        geom_vline(xintercept = 0)

grid.arrange(p1, p2, p3)

dev.off()



