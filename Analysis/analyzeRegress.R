library(tidyverse)
library(ordinal)
library(this.path)
library(glmmTMB) # allows mixed model regression using beta distribution
library(mgcv) # for betar() family that works better than glmmTMB's beta_family()
library(lme4) # for initial Gaussian models. More flexible.

# setup
fdir <- this.path::this.dir()

# Read Matlab data from CSV file:
fname <- 'TC_alldata.csv' # has all gaze DVs, each named instead of being 'Eyetrack'
fpath <- file.path(fdir, "Results", fname)
eyeData <- read_csv(fpath)

# r-z transform the ISC values using atanh, so they can be modeled with a N.dist
eyeData$ISCrz <- atanh(eyeData$ISC)
# Convert ratings from numerical to ordered data type
# Convert IDs from string to "factor" data type, to help with grouping
eyeData <- eyeData %>% 
	mutate(RespOrd = ordered(as_factor(Response)),
				 Subject = as_factor(Subject),
				 StimName = as_factor(StimName))
# Normalize motion, since it's on a WILDLY different scale from everything else
eyeData$MotionZ <- scale(eyeData$Motion)

#
# Time on Target
#
# Since the gaze-based DVs are proportions, i.e. bounded 0:1,
# we model them with a beta distribution instead of a normal.
# But first, use a Gaussian to identify the relevant factors:
lmer(TimeOnTarget ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)

# Significant factors are: Response, Interactivity, Motion, Communication, Resp:Attn, Int:Comm.
# Response has a quadratic factor that is marginally significant (p = .09).
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
			glmmTMB(TimeOnTarget ~ 1 + Response + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response*AttentionDetail + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Response + Interactivity + MotionZ + Communication + Response:AttentionDetail + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
)

# Final model for ToT:
glmmTMB(TimeOnTarget ~ Response + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

#
# Scaled Fixation, aka Fixation Durations
#
lmer(ScaledFixation ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>% 
	summary(correlation=TRUE)

# Significant predictors are SocialSkills + Interactivity:AttentionDetail + Interactivity:Communication
anova(glmmTMB(ScaledFixation ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + Interactivity:Communication + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity:Communication + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit"))
)

# Final model for Fixation Duration:
glmmTMB(ScaledFixation ~ 1 + Interactivity:Communication + Interactivity:AttentionDetail+ (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

#
# Deviance: proportion of time there was motion, but gaze was elsewhere
#
lmer(Deviance ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)
# Significant factors are Response, Interactivity, and Social Skills, with no interactions.
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
glmmTMB(Deviance ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData, family = betar(link = "logit")) %>% summary()

#
# ISC
#
# This is a correlation coefficient, so it's r-z transformed
# Then we simply fit a Gaussian distribution.
# Can convert the betas back to correlation coefficient units using tanh
# ...but first, test the non-transformed version
lmer(ISC ~ 1 + (Response + Interactivity + Duration + MotionZ) * 
					(SocialSkills + Communication + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = eyeData) %>%
	summary(correlation=TRUE)

# Attention to Detail and Interact:Comm are the only significant factors
anova(glmmTMB(ISCrz ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + Interactivity + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + Interactivity*Communication + (1 | Subject) + (1 | StimName), data = eyeData),
			glmmTMB(ISCrz ~ 1 + AttentionDetail + Interactivity:Communication + (1 | Subject) + (1 | StimName), data = eyeData)
)

# Final model for ISC: NO PREDICTORS
glmmTMB(ISCrz ~ 1 + (1 | Subject) + (1 | StimName), data = eyeData) %>% summary()

# RATINGS
# The ratings 1-5 are an ordinal variable, and require a different type of model
# If you exponentiate the coefficients, you get an odds ratio.
# ...but first, fit a Gaussian to response as a linear factor "for consistency"
lmer(Response ~ ScaledFixation + TimeOnTarget + ISC + (MotionZ + Duration + Interactivity) * 
		 	(Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName),
		 data = eyeData) %>% 
	summary()

# Significant factors are ISC, Duration, Interactivity, Communication, and Int:Social
# Now do model comparison.
# clmm fits a mixed model; to drop the grouping var, use clm.
anova(ordinal::clmm(RespOrd ~ 1 + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + Duration + (1 | Subject),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + Duration + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ISC + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + Interactivity:SocialSkills + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + Duration + ISC + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ISC + Duration + Communication + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ISC + Interactivity + Communication + Interactivity:SocialSkills + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit"),
			ordinal::clmm(RespOrd ~ 1 + ISC + Duration + Interactivity + Communication + Interactivity:SocialSkills + (1 | Subject) + (1 | StimName),
										data = eyeData,
										link = "logit")
)

# Final model for Responses: Duration
ordWinner <- ordinal::clmm(RespOrd ~ 1 + Duration + (1 | Subject) + (1 | StimName),
											 data = eyeData,
											 link = "logit")
summary(ordWinner)
exp(coef(ordWinner)) # give the Odds Ratios of each term increasing the DV
exp(confint(ordWinner)) # give confidence intervals on those Odds Ratios

# You may also want to test the assumption of parallel lines for each IV
# that is, at each level of the ordinal DV, the fixed effects are the same.
# You can do this using MASS::polr() %>% brant::brant()
# but unfortunately, polr() doesn't support random effects, our key thing.


## Plotting
# lmer has built-in plot methods, but glmmTMB does not.
# So I need to build custom plots.

# This is a basic scatterplot of Interactivity against ToT.
ggplot(data = eyeData,
			 aes(x = Interactivity, y = TimeOnTarget)) +
	geom_point()

# Modify the scatterplot to add a regression line
ggplot(data = eyeData,
			 aes(x = Interactivity, y = TimeOnTarget)) +
	geom_point() +
	geom_smooth(formula = y ~ x, method = "lm")

# Now try to split the regression line by group...
ggplot(data = eyeData,
			 aes(x = Communication, y = TimeOnTarget, group = StimName)) +
	geom_point(aes(color = StimName)) +
	geom_smooth(formula = y ~ x, method = "lm", aes(color = StimName))

# Now try to manually plot the regression line based on the model...

## Plotting our own residual ~ fitted
lmer_fitted <- predict(fit_lmer, newdata = dat, re.form = ~(1 + Days|Subject))
lmer_resid <- dat$Reaction - lmer_fitted

plot(x = lmer_fitted,
		 y = lmer_resid,
		 pch = 19,
		 main = "Resid ~ Fitted",
		 xlab = "Fitted",
		 ylab = "Residuals")
abline(h = 0,
			 col = "red",
			 lwd = 3,
			 lty = 2)

## Martin & Weisberg data
# Get Data
fname <- 'MW_alldata.csv'
fpath <- file.path(fdir, "Results", fname)
mwData <- read_csv(fpath)
# Process data
mwData$ISCrz <- atanh(mwData$ISC)
mwData$Interactivity <- mwData$Interactivity %>% 
	replace_na(0)
mwData$TimeOnTarget <- mwData$TimeOnTarget %>% 
	replace_na(0)
mwData <- mwData %>% 
	mutate(MotionZ = scale(mwData$Motion))
mwData <- mwData %>% 
	mutate(StimName = as_factor(StimName))
mwData <- mwData %>% 
	mutate(Category = as_factor(Category))

# Calculate models
# Exclude duration, since it's constant for all these videos

# Time on Target
# Since the gaze-based DVs are proportions, i.e. bounded 0:1,
# we model them with a beta distribution instead of a normal.
# But first, use a Gaussian to identify the relevant factors:
lmer(TimeOnTarget ~ 1 + 
					(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = mwData) %>%
	summary()

# Significant factors are: Interactivity & Int:Attn
anova(glmmTMB(TimeOnTarget ~ 1 + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + (1 | Subject), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + AttentionDetail + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity*AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(TimeOnTarget ~ 1 + Interactivity + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit"))
)

# Final model for ToT: exactly what lmer identified.
glmmTMB(TimeOnTarget ~ 1 + Interactivity + Interactivity:AttentionDetail + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")) %>% summary()

#
# Scaled Fixation, aka Fixation Durations
#
lmer(ScaledFixation ~ 1 + Category +
					(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = mwData) %>%
	summary()
# Only the intercepts are significant.
# Interactivity, SocialSkills, and Communication are all marginally significant.
anova(glmmTMB(ScaledFixation ~ 1 + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Communication + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + SocialSkills + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Communication + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity + (1 | Subject), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Communication + Interactivity + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit")),
			glmmTMB(ScaledFixation ~ 1 + Interactivity + SocialSkills + (1 | Subject) + (1 | StimName), data = mwData, family = betar(link = "logit"))
)

# Deviance: proportion of time there was motion, but gaze was elsewhere
# Also a proportion 0:1, so modeled with a beta distribution.
# But the initial model is with a Gaussian:
lmer(Deviance ~ 1 + Category + 
					(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
					(1 | Subject) + (1 | StimName), 
				data = mwData) %>%
	summary(correlation=TRUE)
# Nothing is significant by this account. Call it there.


# ISC
# r-z transform the ISC values using atanh
# Fit a Gaussian distribution
# Convert the betas back to correlation coefficient units using tanh
lmer(ISC ~ 1 + Category + 
		 	(MotionZ + Interactivity) * (Communication + SocialSkills + AttentionDetail) + 
		 	(1 | Subject) + (1 | StimName), 
				data = mwData) %>% 
	summary(correlation=TRUE)
# Nothing is significant, but the two AQ factors are strongly correlated with the random intercepts.
# So check those out.
anova(glmmTMB(ISCrz ~ 1 + (1 | Subject) + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + Communication + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + SocialSkills + (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + Communication + (1 | Subject)+ (1 | StimName), data = mwData),
			glmmTMB(ISCrz ~ 1 + SocialSkills + (1 | Subject)+ (1 | StimName), data = mwData)
)

# Result: nothing improves over the null model.