# Examining iconicity ratings
# Mark Dingemanse, 2017

# Clear workspace
rm(list=ls())

# check for /in/ and /out/ directories (create them if needed)
add_working_dir <- function(x) { if(file.exists(x)) { cat(x,"dir:",paste0(getwd(),"/",x,"/")) } else { dir.create(paste0(getwd(),"/",x)) 
  cat("subdirectory",x,"created in",getwd()) } }
add_working_dir("in")
add_working_dir("out")

# Packages and useful functions
list.of.packages <- c("tidyverse","ggthemes","ggrepel","GGally","lme4","Hmisc","readxl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

`%notin%` <- function(x,y) !(x %in% y) 

# Load data ---------------------------------------------------------------

# Iconicity ratings from Winter et al. 2017, Perry et al. 2015
load(file="in/iconicity-ratings.Rdata")

# three methods from Perry et al. 2015
ratings = read_csv("in\\threefold_ratings_English_Perry_et_al.csv")
summary(ratings$alien)

# Predicted iconicity ratings from Bill
p.ico <- read_csv("in/ipennl.csv")
names(p.ico) <- tolower(names(p.ico))

ico <- left_join(p.ico,d.ico)
ico$language <- as.factor(ico$language)

# add SUBTLEX data for Dutch and English
# from CRR, Ghent University
subtlex.en <- read_excel(path="in/SUBTLEX-US frequency list with PoS and Zipf information.xlsx") %>%
  plyr::rename(c("Word" = "word","FREQcount" = "freq_count","Lg10WF" = "freq_log","Dom_PoS_SUBTLEX" = "POS")) %>%
  dplyr::select(word,freq_log,POS) %>%
  mutate(language = "en")
subtlex.nl <- read_excel(path="in/SUBTLEX-NL.cd-above2.with-POS.xlsx",
                         range=cell_cols("A:K"),
                         col_types=c("text",rep("numeric",9),"text")) %>%
  plyr::rename(c("Word" = "word","FREQcount" = "freq_count","Lg10WF" = "freq_log","dominant.pos" = "POS")) %>%
  dplyr::select(word,freq_log,POS) %>%
  mutate(language = "nl")
subtlex <- bind_rows(subtlex.en,subtlex.nl)
summary(subtlex$freq_log)

# FIXME: add SUBTLEX frequency to ico words
icotest <- left_join(ico,subtlex)
summary(icotest$freq_log)
summary(ico$freq_log)

  
# Compare collected and inferred iconicity ratings ------------------------


icoen <- ico %>% 
  filter(language=="en") %>%
  mutate(overlap = ifelse(is.na(iconicity),0,1)) %>%
  mutate(difference = iconicity - iconicity_predicted) %>%
  mutate(absolute_difference = abs(difference)) %>%
  mutate(difference_direction = ifelse(difference > 0,"lower","higher"))

# most different words (> 3 standard deviations absolute difference)
diffabs.sd <- sd(icoen$absolute_difference,na.rm=T)

# The range of iconicity_predcited seems to be (i) more compressed and (ii) 
# skewed positive relative to the original iconicity ratings
summary(icoen$iconicity)
summary(icoen[which(icoen$overlap == 1),]$iconicity_predicted)  

range1 <- sum(abs(range(icoen$iconicity,na.rm=T)))
range2 <- sum(abs(range(icoen[which(icoen$overlap == 1),]$iconicity_predicted)))
range1/range2 # compressed by a factor of 1.87

summary(icoen$iconicity_predicted)
summary(icoen[which(icoen$overlap == 0),]$iconicity_predicted)  

ggplot(icoen,aes(iconicity,iconicity_predicted)) +
  theme_tufte() +
  geom_point(alpha=0.5,na.rm=T) +
  geom_smooth(na.rm=T,method="loess",colour="grey")

ggplot(icoen,aes(iconicity,iconicity_predicted)) +
  theme_tufte() +
  ggtitle("Predicted vs rated iconicity — maximally different words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(icoen,absolute_difference > 4.5*diffabs.sd),
    # alpha=0.5,  # (affects not just the bounding box)
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
ggsave(file="out/iconicity_predictions_outliers.png",width=6,height=4)
ggsave(file="out/iconicity_predictions_outliers.pdf",width=6,height=4)

# Where are the largest absolute differences? Not strikingly different at either
# end, though perhaps a bit more at the negative end of the scale
ggplot(icoen,aes(iconicity,absolute_difference)) +
  theme_tufte() + 
  geom_point(alpha=0.5) +
  ggtitle("Absolute difference between ratings and predictions") +
  geom_smooth(aes(x=iconicity_predict,y=absolute_difference),method="loess",color="grey")

# most different words
icoen %>%
  filter(absolute_difference > 3*diffabs.sd) %>%
  arrange(iconicity_predicted) %>%
  dplyr::select(word,iconicity,iconicity_predicted,absolute_difference) %>%
  View(.)

iconew <- icoen %>%
  filter(overlap==0)


# How do predicted ratings correlate with other values? -------------------


# Predicted iconicity shows higher correlation with frequency than ratings
cor.test(icoen$iconicity,icoen$freq_log)
cor.test(iconew$iconicity_predicted,iconew$freq_log)
# but lower correlation with AoA
cor.test(icoen$iconicity,icoen$KupermanAOA)
cor.test(iconew$iconicity_predicted,iconew$KupermanAOA)


# Are the peaks around round numbers a result of the original rating scale? If 
# so, their spread over predicted values may be a nice test case for what the 
# predictions are capturing (keeping iconicity rating constant, how do 
# predictions differ?)

icoen %>%
  filter(iconicity==1.5) %>%
  dplyr::select(word,iconicity_predicted) %>%
  arrange(-iconicity_predicted) %>%
  View(.)


# Peeking into the negative corner
  
icoen %>%
  filter(iconicity_predicted <0, iconicity <0) %>%
  dplyr::select(word,iconicity,iconicity_predicted) %>%
  arrange(iconicity) %>%
  View(.)

icoen %>%
  filter(iconicity_predicted >=0, iconicity <0) %>%
  dplyr::select(word,iconicity,iconicity_predicted) %>%
  arrange(iconicity_predicted) %>%
  View(.)

icoen %>%
  filter(iconicity <0, diffabs > 2) %>%
  dplyr::select(word,iconicity,iconicity_predicted) %>%
  arrange(iconicity_predicted) %>%
  View(.)


# Examining written words on -5...0...5 scale -----------------------------

bottom <- d.ico %>%
  filter(language == "en",iconicity < -0.5) %>%
  arrange(iconicity) %>%
  summarise(count=n())
View(bottom)

# Comparing 3 Perry et al. 2015 rating methods ----------------------------

ggpairs(ratings,columns=c("written","spoken","alien"),lower=list(continuous="smooth",method="loess"))

bottom <- d.ico %>%
  filter(language == "en",iconicity < -0.5) %>%
  arrange(iconicity) %>%
  summarise(count=n())

# Finding maximally different words
ratings <- ratings %>% 
  mutate(alien_perc = ntile(alien,10)) %>%
  mutate(written_perc = ntile(written,10)) %>%
  mutate(spoken_perc = ntile(spoken,10))


# Iconicity and AoA -------------------------------------------------------


# highly iconic but late AoA
d.ico %>% 
  mutate(iconicity_perc = ntile(iconicity,10)) %>%
  mutate(AOA_perc = ntile(KupermanAOA,10)) %>%
  filter(iconicity_perc > 9, AOA_perc > 8) %>%
  arrange(-iconicity) %>%
  dplyr::select(word,iconicity,KupermanAOA,iconicity_perc,AOA_perc) %>%
  View(.)

# mean AoA
d.ico %>%
  mutate(iconicity_perc = ntile(iconicity,10)) %>%
  filter(language == "en",iconicity_perc > 8) %>%
  summarise(meanAoA = mean(KupermanAOA,na.rm=T))
d.ico %>%
  mutate(iconicity_perc = ntile(iconicity,10)) %>%
  filter(language == "en",iconicity_perc < 2) %>%
  summarise(meanAoA = mean(KupermanAOA,na.rm=T))
cor.test(d.ico$iconicity,d.ico$KupermanAOA)


