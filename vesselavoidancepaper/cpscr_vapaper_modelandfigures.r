setwd('/repositories/CollPen_mercurial/vesselavoidancepaper')

library(R.matlab)

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
# Vessel noise
#

T2<-dat[(dat$s_treatmenttype=='vessel'),]

# What is the mean and std score
mean(T2$v_score)
sd(T2$v_score)

T2_aov <- aov(T2$v_score ~ T2$t_treatmenttype + T2$b_groupsize)
summary(T2_aov)

# You must submit your illustrations in an electronic form. Please submit the 
# original graphic files. Do not insert figures into your Word document. 
# Springer prefers that files be submitted in TIFF or EPS format, with at 
# least 300 dpi resolution. PDF, JPG, Excel, and PowerPoint files may also 
# be acceptable for simple figures but not for anything complex.  

#All art must be submitted as electronic files. If necessary, please scan art at 600 dpi.

#Remember when considering figures that they will probably be reduced to fit onto a book page, so pay particular attention to making labels highly legible and not too small. You may want to photocopy your figures to the expected final size as a test to determine legibility. The usable page size of the book will be about 4.5 x 7.5 inches. Most figures (including their caption) will occupy half a page. Labels should be in a sans-serif font, preferably Helvetica. When at final reduction the size should be no smaller than 8 point. Please ensure that your figures are clearly labeled.

#For further information on figure formatting, please visit http://tinyurl.com/yzwf49l.

#When preparing your figures, size figures to fit in the column width.
#For most journals the figures should be 39 mm, 84 mm, 129 mm, or 174 mm wide and not higher than 234 mm.
#For books and book-sized journals, the figures should be 80 mm or 122 mm wide and not higher than 198 mm.
# mm to inches 0.0393701




#
# Figure 2
#

fw2 <- 0.0393701*90
fh2 <- 0.0393701*80

pdf("figure2.pdf",width = fw2, height = fh2)
boxplot(T2$v_score ~ as.integer(T2$t_treatmenttype),ylab="Score",names=c("GOS","GOSup","JH"))
dev.off()

#
# Figure 1
#

fw1 <- 0.0393701*122
fh1 <- 0.0393701*130

dat <- readMat("Figure1.mat")

pdf("Figure1.pdf",width = fw1, height = fh1)

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




