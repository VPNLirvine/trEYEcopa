# This is looking at changes in the rate of fixation over time, per trial
library(tidyverse)
library(this.path)
library(lme4) # for initial Gaussian mixed effects models
library(glmmTMB) # allows mixed model regression using tweedie distribution
library(ggpubr) # publication-ready plots (for significance stars)

fdir <- this.path::this.dir()
fname <- 'TC_fixddt.csv'
eyeWinData <- file.path(fdir, "Results", fname) %>% read_csv()

fname <- 'MW_fixddt.csv'
mwWinData <- file.path(fdir, "Results", fname) %>% read_csv()

# Set proper variable types
eyeWinData <- eyeWinData %>% 
	mutate(RespOrd = ordered(as_factor(Response)),
				 Subject = as_factor(Subject),
				 StimName = as_factor(StimName),
				 Quadrant = as.numeric(Quadrant),
				 QuadOrd = ordered(as_factor(Quadrant), c('1st Quarter','2nd Quarter','3rd Quarter','4th Quarter')),
				 QuadCat = as_factor(Quadrant),
				 MotionZ = scale(Motion))
eyeWinData <- eyeWinData %>% rename(FixationRate = Eyetrack)

mwWinData <- mwWinData %>% 
	mutate(Subject = as_factor(Subject),
				 StimName = as_factor(StimName),
				 Quadrant = as.numeric(Quadrant),
				 QuadOrd = ordered(as_factor(Quadrant), c('1st Quarter','2nd Quarter','3rd Quarter','4th Quarter')),
				 QuadCat = as_factor(Quadrant),
				 MotionZ = scale(Motion))
mwWinData <- mwWinData %>% rename(FixationRate = Eyetrack)

# Inspect DV
# Overall distribution:
ggplot(data = eyeWinData, mapping = aes(x = FixationRate)) + geom_histogram()
eyeWinData %>% summarize(Mean = mean(FixationRate), SD = sd(FixationRate))
eyeWinData %>% 
	group_by(Quadrant) %>% 
	summarize(Mean = mean(FixationRate), SD = sd(FixationRate))
# non-normal, bottoms out at 0, non-integer values: not Poisson but Exponential
# Plot 
ggplot(data = eyeWinData, mapping = aes(y = FixationRate, x = QuadOrd)) + geom_boxplot()

# Below is less than ideal because of assumed Gaussian...
# Perform ANOVA
aov(FixationRate ~ QuadCat, data = eyeWinData) %>% summary()
aov(FixationRate ~ QuadCat + AttentionDetail + Communication + SocialSkills, data = eyeWinData) %>% summary()
# Results show a significant effect of QuadCat and Communication, no interactions
# Now do post-hoc t tests
pairwise.t.test(eyeWinData$FixationRate, eyeWinData$QuadOrd, p.adjust.method = 'bonferroni')
# 1 > rest; 2 >3 marginally, but 2 = 4; 3 < 4
# Check the size of the confidence intervals
aov(FixationRate ~ QuadOrd, data = eyeWinData) %>% TukeyHSD()
# Visualize with boxplots
ggplot(data = eyeWinData, mapping = aes(y = FixationRate, x = QuadOrd)) + 
	geom_boxplot() + 
	geom_pwc(label = "p.adj.signif", 
					 method = "t.test",
					 p.adjust.method = "bonferroni") +
	labs(x = "Video Time (quarters)",
			 y = "Fixation Rate")

# Now check interactions with AQ.
# Since glmmTMB has no exponential distribution function, use a Tweedie
# But first, follow the original regression procedure of Gaussian for parameter selection
lmer(FixationRate ~ (Interactivity+MotionZ+QuadOrd)*
		 	(SocialSkills + Communication + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = eyeWinData) %>% 
	summary(correlation=TRUE)

# These factors were significant:
glmmTMB(FixationRate ~ QuadOrd + MotionZ*SocialSkills + MotionZ*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")) %>% summary()
# Test whether removing some of the weaker factors improves model fit or not:
anova(
	glmmTMB(FixationRate ~ (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ QuadOrd + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ MotionZ + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ QuadOrd + MotionZ + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ MotionZ*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ QuadOrd + MotionZ*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ QuadOrd + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")),
	glmmTMB(FixationRate ~ QuadOrd + MotionZ*AttentionDetail + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log"))
)

# Retaining all factors provides better fit than any of them in isolation
glmmTMB(FixationRate ~ QuadOrd + MotionZ*AttentionDetail + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log")) %>% summary()

# Plot all three effects as separate figures
# It's technically possible to do it in one figure, but that's hard to read
# Apply the z-scoring to motion inside the regression equation, so that it stores the raw values
mdl <- glmmTMB(FixationRate ~ QuadOrd + scale(Motion)*AttentionDetail + scale(Motion)*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeWinData, family = tweedie(link = "log"))
	
p1 <- plot(predict_response(mdl, terms = c('Motion', 'SocialSkills [quartiles]')), 
					 show_data = TRUE,
					 colors = "viridis",
					 n_rows = 1) +
	labs(x = "Motion (pix/sec)", y = "Fixation Rate (fix/sec)", color = "AQ Soc.", title = "") + 
	guides(color = guide_legend(reverse = TRUE))
p2 <- plot(predict_response(mdl, terms = c('Motion', 'AttentionDetail [quartiles]')), 
					 show_data = TRUE,
					 colors = "viridis",
					 n_rows = 1) +
	labs(x = "Motion (pix/sec)",y = "Fixation Rate (fix/sec)", color = "AQ Attn.", title = "") + 
	guides(color = guide_legend(reverse = TRUE))

p3 <- ggplot(data = eyeWinData, mapping = aes(y = FixationRate, x = QuadOrd)) + 
	geom_boxplot() + 
	geom_pwc(label = "p.adj.signif", 
					 method = "t.test",
					 p.adjust.method = "bonferroni") +
	labs(x = "Video Time",
			 y = "Fixation Rate")
# ggarrange(p3, p1, p2, labels = "AUTO", legend = "right", ncol = 3)
ggsave('F8.eps', plot = p3, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "eps")



##
# Vignettes
# Visualize with boxplots
ggplot(data = mwWinData, mapping = aes(x = FixationRate, color = QuadOrd)) + geom_histogram(binwidth=.25) + coord_cartesian(xlim = c(0,8)) + facet_wrap(vars(QuadOrd))
ggplot(data = mwWinData, mapping = aes(y = FixationRate, x = QuadOrd)) + 
	geom_boxplot() + 
	geom_pwc(label = "p.adj.signif", 
					 method = "t_test",
					 p.adjust.method = "bonferroni")
# Report descriptive statistics
mwWinData %>% 
	summarize(Mean = mean(FixationRate), SD = sd(FixationRate))
mwWinData %>% 
	group_by(Quadrant) %>% 
	summarize(Mean = mean(FixationRate), SD = sd(FixationRate))

# Basic ANOVA
aov(FixationRate ~ QuadCat, data = mwWinData) %>% summary()
aov(FixationRate ~ QuadCat + AttentionDetail + Communication + SocialSkills, data = mwWinData) %>% summary()
# Check for unequal variance
lm(FixationRate ~ QuadCat, data = mwWinData) %>% car::leveneTest()
# Run a test that allows unequal variance
oneway.test(FixationRate ~ QuadCat, data = mwWinData)
# Result: there is still a difference between quarters.
# Now do post-hoc t tests
pairwise.t.test(mwWinData$FixationRate, mwWinData$QuadOrd, p.adjust.method = 'bonf')

# Return to our regression procedure
lmer(FixationRate ~ Category + (MotionZ + Interactivity + QuadOrd) * 
		 	(SocialSkills + Communication + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwWinData) %>% summary()
# Model will not converge, nothing is considered a significant predictor.
# Leave it at that.
