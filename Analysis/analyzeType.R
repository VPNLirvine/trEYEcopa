library(tidyverse) # for ggplot etc
library(this.path) # to load local data
library(ggpubr) # for significance stars on boxplots
library(cowplot) # to adjoin separate plots into one object

# This function generates plots to compare stimulus parameters between TC and MW

fdir <- this.path::this.dir()
# Get the relevant data from Matlab
# For MW, call:
# exportResults(combineMWData(), 'alldata');
fname <- 'MW_alldata.csv'
fpath <- file.path(fdir, "Results", fname)
mwData <- read_csv(fpath)
# For TC, call:
# exportResults(combineTCData(), 'alldata');
fname <- 'TC_alldata.csv' # has all gaze DVs, each named instead of being 'Eyetrack'
fpath <- file.path(fdir, "Results", fname)
eyeData <- read_csv(fpath)
# Now extract the relevant items and combine them into a single dataframe
stimData <- bind_rows(
	eyeData %>% 
		group_by(StimName) %>% 
		summarize(Interactivity = mean(Interactivity),
							Motion = mean(Motion),
							Type = "TriCOPA"), 
	mwData %>% 
		group_by(StimName) %>% 
		summarize(Interactivity = mean(Interactivity),
							Motion = mean(Motion),
							Type = "Vignettes"))

# Generate boxplots showing differences in Motion and Interactivity for TCvsMW
# MW has some NaNs for Interactivity; they should be silently ignored
p1 <- ggplot(data = stimData,
						 aes(x = Type, y = Motion)) +
	geom_boxplot() +
	geom_pwc(label = "p.adj.signif", 
					 method = "t.test",
					 p.adjust.method = "bonferroni") +
	theme_gray()
p2 <- ggplot(data = stimData,
						 aes(x = Type, y = Interactivity)) +
	geom_boxplot() +
	geom_pwc(label = "p.adj.signif", 
					 method = "t.test",
					 p.adjust.method = "bonferroni") +
	theme_gray()
p3 <- ggarrange(p1, p2, labels = 'AUTO', common.legend = TRUE, legend = "top")
ggsave('F9.eps', plot = p3, path = paste0(fdir, '/Figures/'), dpi = 800, width = 7, height = 3.5, units = "in", device = "eps")
ggsave('F9.jpg', plot = p3, path = paste0(fdir, '/Figures/'), dpi = 800, width = 7, height = 3.5, units = "in", device = "jpg")