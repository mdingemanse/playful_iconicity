# Iconicity and humour ratings -----------------------------------------------------------
# Mark Dingemanse, August 2017

# Motivation: Iconicity is closely allied to expressivity and playfulness
# (Samarin 1966, Dingemanse 2011).

# Prediction: iconicity ratings will be positively correlated with humor
# ratings, controlling for frequency.

# Outliers (words where ratings disagree most) help to discover other features 
# at play. E.g. 'blonde' is in the top 10 percentile of funny words but only in 
# the 2nd percentile of iconicity ratings. Probably related to a genre of jokes.
# On the other hand, some onomatopoeia are highly iconic but associated with 
# negative rather than with funny events, e.g. 'crash', 'scratch','roar', 'clash'.

# Preliminaries -----------------------------------------------------------

# Clear workspace
rm(list=ls())

# check for /in/ and /out/ directories (create them if needed)
add_working_dir <- function(x) { if(file.exists(x)) { cat(x,"dir:",paste0(getwd(),"/",x,"/")) } else { dir.create(paste0(getwd(),"/",x)) 
  cat("subdirectory",x,"created in",getwd()) } }
add_working_dir("in")
add_working_dir("out")

# Packages and useful functions
list.of.packages <- c("tidyverse","GGally","readxl","lme4","ppcor")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

`%notin%` <- function(x,y) !(x %in% y) 

# Load data ---------------------------------------------------------------

# get ratings

# Perry, Lynn K. et al. “Iconicity in the Speech of Children and Adults.”
# Developmental Science, n/a-n/a. doi:10.1111/desc.12572.
iconicity <- read_csv("https://raw.githubusercontent.com/bodowinter/iconicity_acquisition/master/data/iconicity.csv") %>%
  mutate(POS = SUBTLEX_dom_POS) %>%
  plyr::rename(c("Word" = "word","Iconicity"="iconicity","OrthoLength"="len_ortho","SUBTLEX_Rawfreq" = "freq_count"))

# Engelthaler, Tomas, and Thomas T. Hills. 2017. “Humor Norms for 4,997 English
# Words.” Behavior Research Methods, July, 1–9. doi:10.3758/s13428-017-0930-6.
humor <- read_csv("https://raw.githubusercontent.com/tomasengelthaler/HumorNorms/master/humor_dataset.csv") %>%
  plyr::rename(c("mean" = "humor"))

df <- merge(iconicity,humor,by="word") %>%
  drop_na(iconicity,humor,freq_count)


# Test relation -----------------------------------------------------------

ggpairs(df,columns=c("iconicity","humor","freq_count","KupermanAOA"),lower=list(continuous = "smooth",alpha=0.5))
ggsave(file="out/playful_iconicity_ggpairs.png",width=6,height=6)


# Iconicity much better predictor than frequency, which was the best predictor
# according to Engelthaler & Hills (2017)
cor.test(df$humor,df$freq_count)
cor.test(df$humor,df$iconicity)

# Humor shows a positive correlation with iconicity rating, as predicted:
ggplot(df,aes(iconicity,humor)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess")
ggsave(file="out/playful_iconicity_scatterplot1.png",width=6,height=4)

# The relation is strongest for positive iconicity ratings:
ggplot(df %>% filter(iconicity > 0),aes(iconicity,humor)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess")
ggsave(file="out/playful_iconicity_scatterplot2.png",width=6,height=4)


# LME with orthographic length as a random effect shows that a model including 
# iconicity in addition to frequency provides a significantly better fit.
m0 <- lmer(humor ~ freq_count + (1|len_ortho),data=df)
m1 <- lmer(humor ~ freq_count + iconicity + (1|len_ortho),data=df)
m2 <- lmer(humor ~ iconicity + (1|len_ortho),data=df)

m0
m1
anova(m0,m1)


# Partial correlations

# There is 25.6% covariance between humor and iconicity, partialing out 
# frequency as a mediator.
pcor.test(x=df$humor,y=df$iconicity,z=df$freq_count)

# There is -11.2% covariance between frequency, partialing out 
# iconicity as a mediator.
pcor.test(x=df$humor,y=df$freq_count,z=df$iconicity)

# But no correlation between iconicity and frequency when partialing out humor.
pcor.test(x=df$iconicity,y=df$freq_count,z=df$humor)


# Which words disagree most across the ratings?

df <- df %>% 
  mutate(humor_perc = ntile(humor,10)) %>%
  mutate(iconicity_perc = ntile(iconicity,10))

# rated as funny but not iconic
df %>% 
  filter(humor_perc > 9, iconicity_perc < 4) %>%
  arrange(iconicity) %>%
  dplyr::select(word,humor,humor_perc,iconicity,iconicity_perc)

# rated as iconic but not funny
df %>% 
  filter(iconicity_perc > 9, humor_perc < 4) %>%
  arrange(humor) %>%
  dplyr::select(word,humor,humor_perc,iconicity,iconicity_perc) %>%
  slice(1:20)

# Which words are rated as very iconic AND very funny?
df %>%
  filter(iconicity_perc >9,humor_perc >9) %>%
  arrange(desc(iconicity)) %>%
  dplyr::select(word,humor,humor_perc,iconicity,iconicity_perc)
