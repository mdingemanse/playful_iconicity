# for ILL slides

# 2986 iconicity ratings
norms %>%
  filter(!is.na(iconicity)) %>%
  summarise(count=n())

# 4997 humour ratings
norms %>%
  filter(!is.na(humour)) %>%
  summarise(count=n())

# 
norms %>%
  filter(!is.na(humour) & !is.na(iconicity)) %>% 
  summarise(count=n())

words %>%
  filter(!is.na(humour) & !is.na(iconicity)) %>% 
  summarise(count=n())

# 70462 words with imputed norms
words %>%
  filter(!is.na(iconicity_imputed) & !is.na(humour_imputed)) %>%
  summarise(count=n())

# 63721 words with imputed norms
words %>%
  filter(is.na(humour) & is.na(iconicity)) %>% 
  filter(!is.na(iconicity_imputed) & !is.na(humour_imputed)) %>%
  summarise(count=n())


# 
words %>%
  filter(!is.na(iconicity) & !is.na(humour)) %>%
  summarise(count=n())


# plots -------------------------------------------------------------------

# get fonts, set theme

install.packages("extrafont")
library(extrafont)
# font_import() # (only run this once on each system — takes time)
loadfonts(device="win")

theme_slides <- theme_tufte() +
  theme(plot.title = element_text(size=32,family="Gill Sans MT",margin=margin(15,0,5.5,0)))
theme_set(theme_slides)

# let's get plotting!

ggplot(words,aes(iconicity,humour)) +
  theme(legend.position="none") + 
  geom_point(size=2.5,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_rank == 20),
    aes(label=word),
    size=7,
    alpha=0.8,
    segment.colour = "grey",
    label.size=NA,
    label.r=unit(0,"lines"),
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/title_slide_words.png",width=12,height=9)


ggplot(words,aes(iconicity,humour)) +
  ggtitle("Humour and iconicity") +
  geom_point(size=2,alpha=0.5,na.rm=T)
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real.png",width=12,height=9)

ggplot(words,aes(iconicity,humour)) +
  ggtitle("Humour and iconicity") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_smooth(method="loess",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real_loess.png",width=12,height=9)

ggplot(words %>% filter(iconicity > -0),aes(iconicity,humour)) +
  ggtitle("Humour and iconicity") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_smooth(method="lm",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real_from0_loess.png",width=12,height=9)

ggplot(words %>% filter(iconicity > -0),aes(iconicity,humour)) +
  ggtitle("Humour and iconicity") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_smooth(method="lm",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_from0_lm.png",width=12,height=9)


ggplot(words,aes(iconicity,humour)) +
  ggtitle("Humour and iconicity: highest rated words") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_rank == 20),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real_top.png",width=12,height=9)

words %>%
  filter(diff_rank > 18) %>%
  arrange(desc(humour)) %>%
  dplyr::select(word,humour,iconicity) %>%
  View()


ggplot(words,aes(iconicity,humour)) +
  ggtitle("Humour and iconicity: lowest rated words") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_rank <= 3),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real_bottom.png",width=12,height=9)

diffabs.sd <- sd(words$diff_abs,na.rm=T)

ggplot(words,aes(iconicity,humour)) +
  ggtitle("Humour and iconicity: maximally different words") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_abs > 3.5*diffabs.sd),
    # alpha=0.5,  # (affects not just the bounding box)
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_real_divergent.png",width=12,height=9)

# imputed iconicity -------------------------------------------------------


words_imputed <- words %>%
  filter(!is.na(humour) & set == "unrated")

ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  ggtitle("Humour ratings by imputed iconicity ratings") + 
  geom_point(size=2,shape=16,alpha=0.5)
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_imputed.png",width=12,height=9)

ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  ggtitle("Humour ratings by imputed iconicity ratings") + 
  geom_point(size=2,shape=16,alpha=0.5) +
  geom_smooth(method="loess",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_imputed_loess.png",width=12,height=9)


ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  ggtitle("Humour and imputed iconicity: highest scores") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed,diff_rank_imputed_ico == 20) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_imputed_top.png",width=12,height=9)

words_imputed %>%
  filter(diff_rank_imputed_ico > 19) %>%
  arrange(desc(iconicity_imputed)) %>%
  dplyr::select(word,humour,iconicity_imputed) %>%
  slice(1:20)


ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  ggtitle("Humour and imputed iconicity: lowest scoring words") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed,diff_rank_imputed_ico <= 2) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_imputed_bottom.png",width=12,height=9)

words_imputed %>%
  filter(diff_rank_imputed_ico <= 2) %>%
  arrange(-desc(iconicity_imputed)) %>%
  dplyr::select(word,humour,iconicity_imputed) %>%
  slice(1:20)

diffabs.sd <- sd(words_imputed$diff_abs_imputed_ico,na.rm=T)

ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  ggtitle("Humour and imputed iconicity: maximally different words") +
  geom_point(size=2,alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=sample_n(subset(words_imputed,diff_abs_imputed_ico > 3.5*diffabs.sd),80) %>%
      filter(iconicity_imputed >1.5 | humour > 3),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/humico_imputed_divergent.png",width=12,height=9)

# unknown unknowns --------------------------------------------------------

words_imputed_intersection <- words %>%
  filter(is.na(humour) & is.na(iconicity)) %>%
  filter(!is.na(humour_imputed) & !is.na(iconicity_imputed))
words_imputed_intersection %>%
  summarise(n=n())

ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  ggtitle("Imputed humour and imputed iconicity") +
  geom_point(size=2,alpha=0.2,na.rm=T)
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/both_imputed.png",width=12,height=9)

# geom_smooth may run out of memory, so compute loess only for 5000 randomly sampled wds
ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  ggtitle("Imputed humour and imputed iconicity") +
  geom_point(size=2,alpha=0.2,na.rm=T) +
  geom_smooth(method="loess",alpha=0.3,linetype="dotted",color="grey",data=words_imputed_intersection %>% sample_n(5000))
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/both_imputed_loess.png",width=12,height=9)

ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  ggtitle("Highest rated words") +
  geom_point(size=2,alpha=0.2,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed_intersection,diff_rank_imputed > 18) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/both_imputed_top2.png",width=12,height=9)


words_imputed_intersection %>%
  filter(diff_rank_imputed > 19) %>%
  arrange(desc(iconicity_imputed)) %>%
  dplyr::select(word,humour_imputed,iconicity_imputed) %>%
  slice(1:20)

words_imputed_intersection %>%
  filter(diff_rank_imputed > 19) %>%
  arrange(desc(humour_imputed)) %>%
  dplyr::select(word,humour_imputed,iconicity_imputed) %>%
  slice(1:20)


ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  ggtitle("Lowest rated words") +
  geom_point(size=2,alpha=0.2,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed_intersection,diff_rank_imputed <= 2) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/both_imputed_bottom.png",width=12,height=9)

words_imputed_intersection %>%
  filter(diff_rank_imputed <= 2) %>%
  arrange(-desc(iconicity_imputed)) %>%
  dplyr::select(word,humour_imputed,iconicity_imputed) %>%
  slice(1:20)


# logletterfreq and AoA ---------------------------------------------------


words %>%
  drop_na(iconicity,humour) %>% 
  ggplot(aes(iconicity,logletterfreq, color=diff_rank)) +
  ggtitle("Iconicity by log letter frequency distribution") + 
  labs(color="hum+ico") + theme(legend.position = c(0.8,0.2)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess",alpha=0.3,linetype="dotted",color="grey")

words %>%
  drop_na(iconicity,humour) %>% 
  ggplot(aes(diff_rank,logletterfreq+6)) +
  ggtitle("Humour + iconicity percentiles by log letter frequency") + 
  labs(x="humour + iconicity summed 10 percentiles",y="log letter frequency") +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/logletterfreq_percentiles.png",width=12,height=9)

words %>%
  drop_na(iconicity,humour) %>% 
  filter(triphone_perc > 9) %>%
  arrange(desc(triphone_perc)) %>%
  dplyr::select(word,humour,iconicity,unsTPAV) %>%
  slice(1:20)



words %>% 
  drop_na(iconicity,humour,aoa) %>% 
  ggplot(aes(iconicity,humour)) +
  ggtitle("Humour & iconicity: log letter frequency") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_smooth(aes(iconicity,logletterfreq_perc/2),method="lm",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/logletterfreq_loess.png",width=12,height=9)

words %>% 
  drop_na(iconicity,humour,aoa) %>% 
  ggplot(aes(iconicity,humour)) +
  ggtitle("Humour & iconicity: marked words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=. %>% filter(logletterfreq < -3, diff_rank > 12) %>% sample_n(30),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/logletterfreq_words.png",width=12,height=9)

words %>% 
  drop_na(iconicity,humour,aoa) %>% 
  ggplot(aes(iconicity,humour)) +
  ggtitle("Humour & iconicity: age of acquisition") +
  geom_point(alpha=0.5,na.rm=T)
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/aoa_a.png",width=12,height=9)

words %>% 
  drop_na(iconicity,humour,aoa) %>% 
  ggplot(aes(iconicity,humour)) +
  ggtitle("Humour & iconicity: age of acquisition") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_smooth(aes(iconicity,aoa-4),method="lm",alpha=0.3,linetype="dotted",color="grey")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/aoa_loess.png",width=12,height=9)

last_plot() +
  geom_point(data=. %>% filter(aoa < 3.3),color="red") +
  geom_label_repel(
    data=. %>% filter(aoa < 3.3),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/aoa_loess_words.png",width=12,height=9)

words %>% 
  drop_na(iconicity,humour,aoa) %>% 
  ggplot(aes(iconicity,humour)) +
  ggtitle("Humour & iconicity: words learned below age 3.5") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_point(data=. %>% filter(aoa < 3.3),color="red") +
  geom_label_repel(
    data=. %>% filter(aoa < 3.3),
    aes(label=word),
    size=7,
    alpha=0.8,
    label.size=NA,
    segment.colour = "grey",
    force=1.2,
    label.padding=unit(0.2, "lines"),
    point.padding=unit(0.4,"lines")
  )
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/aoa_below_3.5.png",width=12,height=9)

words %>%
  filter(!is.na(iconicity)) %>% 
  dplyr::select(iconicity,humour,unsDENS,unsBPAV,unsPOSPAV,unsTPAV,unsLCPOSPAV) %>%
  ggpairs(cardinality_threshold=20) +
  ggtitle("Iconicity and humour by phonological probability measures")
ggsave("D:/Dropbox/Presentations/20190502 Lund ILL/figs/iphod_measures.png",width=12,height=9)




# fun ---------------------------------------------------------------------

words %>%
  arrange(humour) %>%
  dplyr::select(word,humour)
  slice(1:10)


