library(tidyverse)
library(this.path) # to load local data
library(lme4) # linear mixed effects regressions, for initial models
library(ordinal) # for ordinal logistic regression that lme4 doesn't cover
library(glmmTMB) # general mixed models. Accepts more distributions than lme4
library(mgcv) # for betar() family that works better than glmmTMB's beta_family()
library(ggpubr) # for significance stars on boxplots
library(cowplot) # to adjoin separate plots into one object

# This is a script logging my statistical results for this specific dataset,
# not a generalized function for analyzing arbitrary new data.

# setup
fdir <- this.path::this.dir()


## Martin & Weisberg data, aka "the vignettes"
# Get Data
# The expected file is exported from Matlab by calling:
# exportResults(combineMWData(), 'alldata');
fname <- 'MW_alldata.csv'
fpath <- file.path(fdir, "Results", fname)
mwData <- read_csv(fpath)
# Process data
mwData$ISCrz <- atanh(mwData$ISC)
mwData <- mwData %>% 
	mutate(MotionZ = scale(mwData$Motion))
mwData <- mwData %>% 
	mutate(StimName = as_factor(StimName))
mwData <- mwData %>% 
	mutate(Category = as_factor(Category))
# Do this because some functions exclude rows with an N/A in ANY field,
# even those you're not considering.
# Then you'll have to manually exclude those 0s when they're intended as N/As.
mwData$Interactivity <- mwData$Interactivity %>%
	replace_na(0)
mwData$TimeOnTarget <- mwData$TimeOnTarget %>%
	replace_na(0)

# Calculate models
# Exclude duration as a predictor, since it's constant for all these videos

# Scaled Fixation, aka Fixation Durations
# Exclude Interactivity since it's set to 0 for all mechanical videos.
# Include Category instead.
lmer(ScaledFixation ~ 1 + Category +
		 	(MotionZ) * (Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwData) %>%
	summary(correlation=TRUE)
# Only the intercepts are significant.


# Time on Target
# Since the gaze-based DVs are proportions, i.e. bounded 0:1,
# we model them with a beta distribution instead of a normal.
# But first, use a Gaussian to identify the relevant factors:
lmer(TimeOnTarget ~ 1 + 
		 	(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwData %>% filter(Category == 'social')) %>%
	summary()

# Significant factors are SocialSkills*Motion, with Interactivity marginal t=1.91
# Keep all main effects of any interaction term.
glmmTMB(TimeOnTarget ~ 1 + Interactivity + SocialSkills*MotionZ + (1 | Subject) + (1 | StimName), 
				data = mwData %>% filter(Category == 'social'), 
				family = betar(link = "logit")) %>% 
	summary()

anova(glmmTMB(TimeOnTarget ~ 1 + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + MotionZ + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + SocialSkills + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + SocialSkills*MotionZ + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + SocialSkills*MotionZ + (1 | Subject) + (1 | StimName), data = mwData %>% filter(Category == 'social'), family = betar(link = "logit"))
)
# Result: Interactivity is best, but still not a better model than the null.


# Deviance: proportion of time there was motion, but gaze was elsewhere
# Also a proportion 0:1, so modeled with a beta distribution.
# But perform feature selection with a Gaussian:
lmer(Deviance ~ 1 + Category + (MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwData) %>%
	summary(correlation=TRUE)
# Nothing is significant by this account. Call it there.
glmmTMB(Deviance ~ 1 + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")) %>% summary()


# ISC
# r-z transform the ISC values using atanh
# Fit a Gaussian distribution
# Convert the betas back to correlation coefficient units using tanh
lmer(ISCrz ~ 1 + Category + 
		 	(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwData) %>% 
	summary(correlation=TRUE)

# Motion:Communication is marginally significant.
# Two AQ factors are strongly correlated with the random intercepts.
# Check those out.
glmmTMB(ISCrz ~ 1 + scale(Motion)*Communication + (1 | Subject) + (1 | StimName), data = mwData) %>% summary()

anova(glmmTMB(ISCrz ~ 1 + (1 | Subject) + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + Communication + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + SocialSkills + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + scale(Motion) + (1 | Subject) + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + Communication + (1 | Subject) + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + SocialSkills + (1 | Subject)+ (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + scale(Motion) * Communication + (1 | Subject) + (1 | StimName), data = mwData)
)

# Result: nothing improves over the null model.


# First Fixation Latency
# The time it takes to fixate the first character to move
# Ideal model is an Exponential/inverse Gaussian distribution
lmer(FixRT ~ 1 + (Interactivity + MotionZ) * 
		 	(SocialSkills + Communication + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = mwData %>% filter(FixRT != Inf, Category != 'mechanical')) %>%
	summary(correlation=TRUE)
# Result: No predictors are selected, AND it's a singular matrix.
# Leave it at that.



## TriCOPA data
# Read Matlab data from CSV file.
# The expected file is exported from Matlab by calling:
# exportResults(combineTCData(), 'alldata');
fname <- 'TC_alldata.csv' # has all gaze DVs, each named instead of being 'Eyetrack'
fpath <- file.path(fdir, "Results", fname)
eyeData <- read_csv(fpath)

# r-z transform the ISC values using atanh, 
# so they can be modeled with a Normal distribution
eyeData$ISCrz <- atanh(eyeData$ISC)
# Convert ratings from numerical to ordinal data type
# Convert IDs from string to "factor" data type, to help with grouping
eyeData <- eyeData %>% 
	mutate(RespOrd = ordered(as_factor(Response)),
				 Subject = as_factor(Subject),
				 StimName = as_factor(StimName))
# Normalize motion, since it's on a WILDLY different scale from everything else
eyeData$MotionZ <- scale(eyeData$Motion)
eyeData$DurZ <- scale(eyeData$Duration)


# RATINGS
# The ratings 1-5 are an ordinal variable, and require a different type of model
# If you exponentiate the coefficients, you get an odds ratio.
# ...but first, fit a Gaussian to response as a linear factor "for consistency"
lmer(Response ~ (ScaledFixation + TimeOnTarget + ISC + MotionZ + DurZ + Interactivity) * 
		 	(Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName),
		 data = eyeData) %>% 
	summary(correlation=TRUE)

# Significant factors are TimeOnTarget*Communication, SocialSkills
# Marginal significance for ScaledFixation and Duration
# Now do model comparison.
# clmm fits a mixed model; to drop the grouping var, use clm.
ordinal::clmm(RespOrd ~ 1 + SocialSkills + scale(Duration) + ScaledFixation + TimeOnTarget*Communication + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit") %>% summary()

anova(ordinal::clmm(RespOrd ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + scale(Duration) + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ScaledFixation + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ScaledFixation + Duration + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ScaledFixation + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + scale(Duration) + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ScaledFixation + scale(Duration) + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + TimeOnTarget*Communication + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + SocialSkills + scale(Duration) + ScaledFixation + TimeOnTarget*Communication + (1 | Subject) + (1 | StimName), data = eyeData, link = "logit")
)

# Final model for Responses: Duration
tcrat <- ordinal::clmm(RespOrd ~ 1 + Duration + Communication + (1 | Subject) + (1 | StimName),
											 data = eyeData,
											 link = "logit")
summary(tcrat)
exp(coef(tcrat)) # give the Odds Ratios of each term increasing the DV
exp(confint(tcrat)) # give confidence intervals on those Odds Ratios

# Here's a stacked bar plot showing the changing probability of each rating
# Generate one plot for each significant fixed effect
p1 <- ggplot(data = predict_response(tcrat, terms = "Duration"), 
						 mapping = aes(x = x, y = predicted, fill = response.level)) + 
	geom_bar(position=position_stack(reverse = TRUE), stat="identity") +
	labs(x = "Stimulus Duration", y = "Predicted Probability", fill = "Clarity Rating") +
	scale_fill_discrete(palette = ggeffects_palette(palette = "warm"),
											guide = guide_legend(reverse = TRUE)) +
	scale_y_continuous(labels = scales::percent) +
	theme_gray()

p2 <- ggplot(data = predict_response(tcrat, terms = "Communication"), 
						 mapping = aes(x = x, y = predicted, fill = response.level)) + 
	geom_bar(position=position_stack(reverse = TRUE), stat="identity") +
	labs(x = "Communication Skills AQ", y = "Predicted Probability", fill = "Clarity Rating") +
	scale_fill_discrete(palette = ggeffects_palette(palette = "warm"),
											guide = guide_legend(reverse = TRUE)) + 
	scale_y_continuous(labels = scales::percent) +
	theme_gray()
# Join both plots into a single object and save to disk
p3 <- ggarrange(p1, p2, labels = 'AUTO', common.legend = TRUE, legend = "right")
ggsave('F3.eps', plot = p3, path = paste0(fdir, '/Figures/'), dpi = 800, width = 7, height = 3.5, units = "in", device = "eps")
ggsave('F3.jpg', plot = p3, path = paste0(fdir, '/Figures/'), dpi = 800, width = 7, height = 3.5, units = "in", device = "jpg")



# Scaled Fixation, aka Fixation Durations
# A proportion bounded 0:1, so best modeled with a beta distribution
# But first, feature selection:
lmer(ScaledFixation ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
		 	(SocialSkills + Communication + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = eyeData) %>% 
	summary(correlation=TRUE)

# Significant predictors are SocialSkills + Interactivity:AttentionDetail + Interactivity:Communication + SocialSkills:MotionZ
# Include all main effects associated with any interaction term.
glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + Interactivity*AttentionDetail + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

anova(glmmTMB(ScaledFixation ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + Interactivity*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + SocialSkills*MotionZ + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*AttentionDetail + SocialSkills*MotionZ + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + Interactivity*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + Interactivity*AttentionDetail + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + Interactivity*AttentionDetail + MotionZ*SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
)

# Final model for Fixation Duration:
glmmTMB(ScaledFixation ~ 1 + SocialSkills + Interactivity*AttentionDetail + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

# Plot:
mdl <- glmmTMB(ScaledFixation ~ 1 + SocialSkills + Interactivity*AttentionDetail + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
p1 <- plot(predict_response(mdl, terms = c('Interactivity', 'Communication [quartiles]')), show_data = TRUE, dot_alpha = 1, colors = "warm") +
	labs(y = "Fixation Proportion", color = "AQ Com.", title = "") + 
	guides(color = guide_legend(reverse = TRUE)) +
	scale_y_continuous(labels = scales::percent) +
	scale_x_continuous(labels = scales::percent) +
	theme_gray() +
	theme(axis.ticks.length = unit(0, "points"))
p2 <- plot(predict_response(mdl, terms = c('Interactivity', 'AttentionDetail [quartiles]')), show_data = TRUE, dot_alpha = 1, colors = "warm") +
	labs(y = "Fixation Proportion", color = "AQ Attn.", title = "") + 
	guides(color = guide_legend(reverse = TRUE)) +
	scale_y_continuous(labels = scales::percent) +
	scale_x_continuous(labels = scales::percent) +
	theme_gray() +
	theme(axis.ticks.length = unit(0, "points"))
# Take this otherwise-simple plot from ggeffects and reconstruct it in ggplot
# I want all 3 plots to be visually aligned when combined with ggarrange(),
# but p3 refuses to add a legend, so I need to add a dummy legend with blanks...
# p3 <- plot(predict_response(mdl, terms = 'SocialSkills'), show_data = TRUE, color = "red")
preds <- predict_response(mdl, terms = 'SocialSkills')
p3 <- ggplot(preds, aes(x = x, y = predicted, fill = TRUE)) +
	geom_point(data = eyeData, mapping = aes(x = SocialSkills, y = ScaledFixation, group = TRUE), color = "black", alpha = 1) +
	geom_ribbon(aes(ymin = conf.low, ymax = conf.high), fill = "red", alpha = .3) +
	geom_line(color = "red", linewidth = 1) +
	labs(y = "Fixation Proportion", x = "AQ Social Skills", title = NULL, fill = "               ") +
	scale_y_continuous(labels = scales::percent) +
	guides(fill = guide_legend(override.aes = list(alpha = 0)),
				 color = guide_legend(override.aes = list(alpha = 0))) +
	theme_gray() +
	theme(
		# legend.title = element_blank(),
		legend.text = element_blank(),
		legend.key = element_blank(),
		axis.ticks.length = unit(0, "points"))
# Join figures and save to disk
p4 <- ggarrange(p3, p1, p2, labels = "AUTO", ncol = 1)
ggsave('F4.eps', plot = p4, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 7, units = "in", device = "eps")
ggsave('F4.jpg', plot = p4, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 7, units = "in", device = "jpg")



# Time on Target
# Since the gaze-based DVs are proportions, i.e. bounded 0:1,
# we model them with a beta distribution instead of a normal.
# But first, use a Gaussian to identify the relevant factors:
lmer(TimeOnTarget ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)

# Significant factors are: Response, Interactivity, Communication, Resp:Attn, Int:Comm.
anova(glmmTMB(TimeOnTarget ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Communication + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response + (1 | Subject), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + (1 | Subject), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + MotionZ + (1 | Subject), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + MotionZ + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response:AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response + Interactivity + Response:AttentionDetail + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response*AttentionDetail + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response + Interactivity + Communication + Response:AttentionDetail + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
)

# Final model for ToT:
mdl <- glmmTMB(TimeOnTarget ~ Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
mdl %>% summary()
# Figure is too dense for 3.5 x 3.5, so put legend on top and reduce font size
p1 <- plot(predict_response(mdl, terms = c('Interactivity', 'Communication [quartiles]')), show_data = TRUE, dot_alpha = 1, colors = "viridis") +
	labs(y="Time on Target", title="") +
	guides(color = guide_legend(position = "top")) +
	scale_y_continuous(labels = scales::percent) +
	scale_x_continuous(labels = scales::percent) +
	theme_gray(base_size = 11) +
	theme(legend.key.size = unit(2, "mm"))
ggsave('F5.eps', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "eps")
ggsave('F5.jpg', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "jpg")



# Deviance: proportion of time there was motion, but gaze was elsewhere
# Bounded 0:1, so test with a beta distribution
lmer(Deviance ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)
# Significant factors are Response, Interactivity, and Social Skills, with no interactions.
glmmTMB(Deviance ~ 1 + Response + Interactivity + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

anova(
	glmmTMB(Deviance ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Response + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + (1 | Subject), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + SocialSkills + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + SocialSkills + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + SocialSkills + (1 | Subject), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Interactivity + SocialSkills + Response + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Response + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
	glmmTMB(Deviance ~ 1 + Response + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
)

# Final model for Deviance:
mdl <- glmmTMB(Deviance ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
mdl %>% summary()
p1 <- plot(predict_response(mdl, terms = 'Interactivity'), show_data = TRUE, dot_alpha = 1, colors = "red") +
	labs(y = "Deviance from Motion", title = "") +
	scale_x_continuous(labels = scales::percent) +
	scale_y_continuous(labels = scales::percent) +
	theme_gray()
ggsave('F6.eps', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "eps")
ggsave('F6.jpg', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "jpg")



# ISC
# This is a correlation coefficient, so it's r-z transformed
# Then we simply fit a Gaussian distribution.
# Can convert the betas back to correlation coefficient units using tanh
# ...but first, test the non-transformed version
lmer(ISCrz ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)

# Attention to Detail and Interactivity are the only significant factors
glmmTMB(ISCrz ~ 1 + AttentionDetail + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData) %>% summary()

anova(glmmTMB(ISCrz ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + Interactivity + (1 | Subject), data = eyeData),
			glmmTMB(ISCrz ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData)
)

# Final model for ISC: Interactivity
# Since the DV has been transformed, we need to un-transform the data and predictions
# predict_response does not detect tanh-atanh relations, so I'm doing it manually
mdl <- glmmTMB(ISCrz ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData)
mdl %>% summary()
preds <- predict_response(mdl, terms = 'Interactivity')
# If I just mutate across these vars, it drops half the rows for some reason.
# So I'm doing it manually.
	preds$predicted = tanh(preds$predicted)
	preds$conf.low = tanh(preds$conf.low)
	preds$conf.high = tanh(preds$conf.high)
p1 <- ggplot() +
	geom_point(data = eyeData,
						 mapping = aes(x = Interactivity, y = ISC),
						 alpha = 1) +
	geom_line(data = preds,
							mapping = aes(x = x, y = predicted), color = "red") +
		geom_ribbon(data = preds,
								mapping = aes(x = x, ymin = conf.low, ymax = conf.high),
								alpha = 0.2, fill = "red") +
	coord_cartesian(ylim = c(0,1)) +
	scale_y_continuous(labels = scales::percent) +
	scale_x_continuous(labels = scales::percent) +
	theme_gray()
ggsave('F7.eps', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "eps")
ggsave('F7.jpg', plot = p1, path = paste0(fdir, '/Figures/'), dpi = 800, width = 3.5, height = 3.5, units = "in", device = "jpg")

# This is a much simpler call, but the DV is on a transformed scale.
# plot(predict_response(mdl, terms = 'Interactivity'), show_data = TRUE, colors = "red") +
# 	labs(y = "Intersubject Scanpath Correlation", title = "")



# First Fixation Latency
# This is a reaction time between a character moving and gaze first meeting it
# Thus, it is bounded from 0 to +Infinity continuously
# RTs are best modeled by an exponential Gaussian distribution,
# but that is exclusive of 0, and we happen to have several 0s, where subs were
# already fixating the character before it started moving.
# There's also a few instances where RT = Inf, meaning no character was ever fixated
# So let's ignore those rows for this DV specifically
lmer(FixRT ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
		 	(SocialSkills + Communication + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
		 data = eyeData %>% filter(FixRT != Inf)) %>%
	summary(correlation=TRUE)

# The only significant predictor is Social Skills AQ, with several interaction terms
glmmTMB(FixRT ~ 1 + SocialSkills + Response:SocialSkills + Response:Communication + Interactivity:AttentionDetail + Duration:SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")) %>% summary()

anova(glmmTMB(FixRT ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + SocialSkills + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + Response:SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + Response:Communication + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + Duration:SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log")),
			glmmTMB(FixRT ~ 1 + SocialSkills + Response:SocialSkills + Response:Communication + Interactivity:AttentionDetail + Duration:SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData %>% filter(FixRT != Inf), family = tweedie(link = "log"))
)
# None of these factors are considered significant when fit to a Tweedie distribution
# (essentially an Exponential that allows zeros by adding a logistic component)

