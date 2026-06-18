library(tidyverse)
library(lme4)
library(ordinal)
library(this.path)

# Read Matlab data from CSV file:
fdir <- this.path::this.dir()
fname <- 'tot.csv'
fpath <- file.path(fdir, "Results", fname)
eyeData <- read_csv(fpath)

# Convert numerical data to ordered data type
eyeData <- eyeData %>% 
	mutate(RespOrd = ordered(as_factor(Response)))
# Convert subject IDs to a nominal factor to help with grouping
eyeData$Subject <- as_factor(eyeData$Subject)
# Normalize motion, since it's on a WILDLY different scale from everything else
eyeData$MotionZ <- scale(eyeData$Motion)
# eyeData$InteractivityZ <- scale(eyeData$Interactivity)
# eyeData$CommunicationZ <- scale(eyeData$Communication)

# LINEAR MODEL
# This is a bear to interpret without any p values
linModel <- lme4::lmer(Eyetrack ~ MotionZ*AttentionDetail + (Interactivity + RespOrd) * (Communication + SocialSkills) + (1 | Subject) - AttentionDetail, 
											 data = eyeData)

# PROBIT MODEL
ordModel <- ordinal::clmm(RespOrd ~ MotionZ + Interactivity + Communication + (1 | Subject),
															 data = eyeData,
															 link = "probit")

bigModel <- ordinal::clmm(RespOrd ~ MotionZ + Interactivity * (SocialSkills + Communication + AttentionDetail) +  (1 | Subject),
													data = eyeData,
													link = "probit")

biggerModel <- ordinal::clmm(RespOrd ~ MotionZ + Duration + Interactivity * (SocialSkills + Communication + AttentionDetail) +  (1 | Subject),
													data = eyeData,
													link = "probit")

# Display stats by saing summary(model), e.g.:
summary(biggerModel)


# LOGIT MODEL
# summary(model.ologit <- polr(RespOrd ~ Motion + Interactivity + Communication,
# 															method="logistic", data=eyeData))

# You can then use ggpredict to get the predicted probabilities of each DV level
# from a LOGIT model, given a discrete data point to predict from.
# I can then imagine bootstrapping this to get a posterior distribution.
# ggpredict(model.ologit, terms = RespOrd,
# 					condition = c(Motion=.5, Interactivity=.5, Communication=22))


# In Matlab, you would use fitmnr() then predict()
# But we're using R because Matlab doesn't support RFX models for ordinal DVs
# mdl = fitmnr(data, 'Response ~ Motion + AttentionDetail + Communication + SocialSkills + SocialSkills:Interactivity', 'ModelType', 'ordinal', 'Link', 'probit');
# [prediction,cumprobs,lower,upper] = predict(mdl,[testValA testValB etc],Alpha=0.01,ProbabilityType="cumulative")
