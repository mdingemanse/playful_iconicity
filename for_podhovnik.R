
words.setA <- words %>% filter(set == "A")
words.setB <- words %>% filter(set == "B")
words.setC <- words %>% filter(set == "C")

these_words <- c("cat","purr","meow","claw","paw","hiss")

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

words %>%
  filter(word %in% these_words) %>%
  dplyr::select(word,logfreq,ico,fun,ico_imputed,fun_imputed,ico_imputed_perc,fun_imputed_perc)

ggplot(words,aes(ico_imputed,fun_imputed,label=word)) +
  theme_tufte() + 
  ggtitle("Iconicity and funniness (n = 70200)") +
  labs(x="iconicity rating", y = "funniness rating") +
#  stat_smooth(method="loess",colour="grey",span=0.8) +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words, word %in% these_words),
    aes(label=word),
    colour="red",
    size=4,
    alpha=1,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines"),
    min.segment.length = unit(1.5,"lines")
  ) 
ggsave("purr.png")
