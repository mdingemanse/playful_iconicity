# publication quality figures

# packages# Packages and useful functions
list.of.packages <- c("tidyverse","GGally","ggthemes","readxl","ggrepel","cowplot","extrafont")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

mean.na <- function(x) mean(x, na.rm = T)
sd.na <- function(x) sd(x, na.rm = T)


# load data

words <- read_csv("data/words.csv") %>%
  dplyr::select(-X1)


# load fonts
# unfortunately I can't get the Imprint Std MT font to work, so let's forget about that
#font_import(pattern="Imprint",prompt=F)
#loadfonts()
#windowsFonts(ImprintMT=windowsFont("Imprint Std MT"))
#Sys.setenv(R_GSCMD="C:/Program Files (x86)/gs/gs8.64/bin/gswin32c.exe")


# set ggplot theme
theme_set(theme_tufte(base_size = 12))


# Figure 1 ----------------------------------------------------------------

words.setA <- words %>% filter(set == "A")
words.setB <- words %>% filter(set == "B")
words.setC <- words %>% filter(set == "C")

these_words <- c("baboon","jiggle","giggle","smooch","zigzag","murmur","roar","scratch","victim","grade","grenade","business","canoe","magpie","deuce","buttocks","plush","grain","mud","tender","waddle","fluff","sound")

pA <- ggplot(words.setA,aes(ico,fun,label=word)) +
  ggtitle("Iconicity and funniness (n = 1.419)") +
  labs(x="iconicity rating", y = "funniness rating") +
  stat_smooth(method="loess",colour="grey",span=0.8) +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words.setA, word %in% these_words),
    aes(label=word),
    size=4,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines"),
    min.segment.length = unit(1.5,"lines")
  ) +
  NULL

pB <- ggplot(words %>% drop_na(ico),aes(ico)) +
  ggtitle("Iconicity ratings (n = 2.945)") +
  labs(x = "iconicity") + scale_x_continuous(limits=c(-5,5)) +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
  stat_density(geom="line") + geom_rug()

pC <- ggplot(words %>% drop_na(fun),aes(fun)) +
  ggtitle("Funniness ratings (n = 4.996)") +
  labs(x = "funniness") + scale_x_continuous(limits=c(1,5)) +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
  stat_density(geom="line") + geom_rug()

right_panel <- plot_grid(pB, pC,ncol = 1,labels=c("B","C"), label_size=16)

plot_grid(pA, right_panel,labels=c("A",NA,NA), label_size=16, rel_widths = c(1.8,1.2))

ggsave("paper/fig1_ico_funniness_labelled.png",width=8,height=5,dpi=600)
ggsave("paper/fig1_ico_funniness_labelled.pdf",width=8,height=5)



# Figure 3 ----------------------------------------------------------------

p3A <- ggplot(words.setA,aes(ico,fun_resid)) +
  ggtitle("Human ratings", subtitle="(n = 1.419)") +
  labs(x="iconicity", y="funniness (residuals)") + 
  scale_y_continuous(limits=c(-1,2)) + scale_x_continuous(limits=c(-2,5)) +
  geom_point(alpha=0.3,na.rm=T) +
  stat_smooth(method="lm",se=T,colour="grey",fill="white",alpha=0.9)

p3B <- ggplot(words.setB,aes(ico_imputed,fun_resid)) +
  ggtitle("Human vs imputed ratings",subtitle="(n = 3.577)") + 
  scale_y_continuous(limits=c(-1,2)) + scale_x_continuous(limits=c(-2,5)) +
  labs(x="imputed iconicity",y="funniness (residuals)") +
  geom_point(alpha=0.3,na.rm=T) +
  stat_smooth(method="lm",se=T,colour="grey",fill="white",alpha=0.9)

p3C <- ggplot(words.setC,aes(ico_imputed,fun_imputed_resid)) +
  ggtitle("Imputed ratings", subtitle="(n = 63.680)") +
  labs(x="imputed iconicity",y="imputed funniness (residuals)") + 
  scale_y_continuous(limits=c(-1,2)) + scale_x_continuous(limits=c(-2,5)) +
  geom_point(alpha=0.3,na.rm=T) +
  stat_smooth(method="lm",se=T,colour="grey",fill="white",alpha=0.9)

plot_grid(p3A, p3B, p3C, labels="AUTO", label_size=16,nrow=1)

ggsave("paper/fig3_ico_funniness_lm.png",width=8,height=3,dpi=600)
ggsave("paper/fig3_ico_funniness_lm.pdf",width=8,height=3)


# Figure 4 ----------------------------------------------------------------

words <- words %>%
  mutate(group = ifelse(diff_rank > 18,"highest","other"))

words %>% filter(set == "A") %>%
  ggplot(aes(ico,fun)) + 
  labs(x="iconicity rating",y="funniness rating") +
  geom_point(shape=21,fill=NA,alpha=0.8,na.rm=T) +
  geom_point(shape=21,fill="black",alpha=1,na.rm=T,data=subset(words.setA,diff_rank > 18)) +
  geom_label_repel(
    seed=2015,
    force=0.5,
    data=sample_n(subset(words.setA,diff_rank > 18),40),
    aes(label=word),
    size=3,
    alpha=0.8,
    segment.colour="grey20",
    segment.alpha=0.2,
    min.segment.length=1,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.2, "lines"),
    point.padding=unit(0.3,"lines")
  )

ggsave("paper/fig4_ico_funniness_highestrated.png",width=8,height=5,dpi=600)
ggsave("paper/fig4_ico_funniness_highestrated.pdf",width=8,height=5)


# Figure 5 ----------------------------------------------------------------


onsets <- "^(bl|cl|cr|dr|fl|sc|sl|sn|sp|spl|sw|tr|pr|sq)"
codas <- "(nch|mp|nk|rt|rl|rr|sh|wk)$"
verbdim <- "([b-df-hj-np-tv-xz]le)$" # i.e., look for -le after a consonant

# tag words for these patterns, applying verbdim only to verbs
# add a cumulative measure of complexity
words <- words %>%
  mutate(complex.coda = ifelse(str_detect(word,pattern=codas),1,0),
         complex.onset = ifelse(str_detect(word,pattern=onsets),1,0),
         complex.verbdim = ifelse(str_detect(word,pattern=verbdim),
                                  ifelse(POS == "Verb",1,0),0)) %>%
  mutate(cumulative = rowSums(.[c("complex.coda","complex.onset","complex.verbdim")])) 

# define snippets to minimise repetition
markedness_layers <- list(
  stat_smooth(method="loess", span=0.8,color="black",se=T),
  stat_smooth(method="loess", span=0.7,se=F, color="black",show.legend = T,linetype="longdash",aes(y=onset)),
  stat_smooth(method="loess", span=0.7,se=F, color="black",show.legend = T,linetype="dashed",aes(y=coda)),
  stat_smooth(method="loess", span=0.7,se=F, color="black",show.legend = T,linetype="dotted",aes(y=verbdim))
)

# there are many other avoidable redundancies here but okay
p4A <- words %>%
  drop_na(diff_rank) %>%
  mutate(fun_perc = ntile(fun,100)) %>%
  group_by(fun_perc) %>%
  summarise(n=n(),
            onset=mean.na(complex.onset),
            coda=mean.na(complex.coda),
            verbdim=mean.na(complex.verbdim),
            complexity=mean.na(cumulative)) %>%
  ggplot(aes(fun_perc,complexity)) +
  labs(y="structural markedness",x="funniness percentile") +
  scale_y_continuous(limits=c(0,1)) +
  geom_point(shape=1) +
  markedness_layers +
  annotate("segment",x=20,xend=40,y=0.96,yend=0.96,colour="black",linetype="solid",size=0.8) +
  annotate("segment",x=20,xend=40,y=0.88,yend=0.88,colour="black",linetype="longdash",size=0.8) +
  annotate("segment",x=20,xend=40,y=0.80,yend=0.80,colour="black",linetype="dashed",size=0.8) +
  annotate("segment",x=20,xend=40,y=0.72,yend=0.72,colour="black",linetype="dotted",size=0.8) +
  annotate("text",x=45,y=c(0.97,0.89,0.81,0.73),
           label=c("cumulative","onset","coda","-le suffix"),
           hjust=0,size=3.8,family="serif")

p4B <- words %>%
  drop_na(diff_rank) %>%
  mutate(ico_perc = ntile(ico,100)) %>%
  group_by(ico_perc) %>%
  summarise(n=n(),
            onset=mean.na(complex.onset),
            coda=mean.na(complex.coda),
            verbdim=mean.na(complex.verbdim),
            complexity=mean.na(cumulative)) %>%
  ggplot(aes(ico_perc,complexity)) +
  labs(y="structural markedness",x="iconicity percentile") +
  scale_y_continuous(limits=c(0,1)) +
  geom_point(shape=1) +
  markedness_layers 

p4C <- words %>%
  drop_na(diff_rank) %>%
  mutate(funico_perc = ntile(ico_z + fun_z,100)) %>%
  group_by(funico_perc) %>%
  summarise(n=n(),
            onset=mean.na(complex.onset),
            coda=mean.na(complex.coda),
            verbdim=mean.na(complex.verbdim),
            complexity=mean.na(cumulative)) %>%
  ggplot(aes(funico_perc,complexity)) +
  labs(y="structural markedness",x="funniness + iconicity percentile") +
  scale_y_continuous(limits=c(0,1)) +
  geom_point(shape=1) +
  markedness_layers

plot_grid(p4A, p4B, p4C, labels="AUTO", label_size=16,nrow=1)

ggsave("paper/fig5_markedness_panel.png",width=8,height=3)
ggsave("paper/fig5_markedness_panel.pdf",width=8,height=3)
