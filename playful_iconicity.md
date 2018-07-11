Playful iconicity: relating iconicity and humor ratings
================
Mark Dingemanse & Bill Thompson
(this version: 2018-07-11)

Abstract
--------

Iconic words are widespread in natural languages (Nuckolls 1999; Perniss, Thompson, and Vigliocco 2010), and iconic methods of communication are common in everyday interaction (Clark 2016). Scholars working on iconic words have long drawn attention to their expressive and playful nature, but empirical studies of when and why some words appear more playful than others are rare. Here we study the intersection of iconicity and playfulness using databases of humour ratings (Engelthaler and Hills 2017) and iconicity ratings (Perry et al. 2017) that have recently become available. We combine correlational evidence and linguistic analysis to understand what makes people rate words as playful and iconic. We also introduce and benchmark a method for imputing iconicity ratings using word embeddings. The method is applicable more generally to the task of increasing the intersection between iconicity ratings and other norm sets.

Ideophones are iconic words with sensory meanings found in many of the world’s languages (Nuckolls 1999). Their marked phonology has been connected to playful and expressive functions of language (Samarin 1970; Zwicky and Pullum 1987), and they have been defined —only partly tongue-in-cheek— as “those words with are such fun to use” (Welmers 1973). In an independent strand of research, people have recently started to investigate the perceived humour of word forms. For nonwords, humour ratings appear to correlate with a measure of entropy which may be linked to phonological markedness (Westbury et al. 2016). For existing English words, a new set of humour norms finds that the strongest correlates are with frequency and lexical decision time (Engelthaler and Hills 2017). Neither of these studies consider a link to iconicity, so the newly available ratings enable us, for the first time, to empirically test intuitions about the playfulness of iconic words.

Here we test the prediction that iconicity ratings will be positively correlated with humor ratings, controlling for frequency. We find that iconicity and humour are related with good accuracy across the entire range of judgments: many highly iconic words are rated as highly funny (‘tinkle’, ‘oink’, ‘waddle’), and many words rated as not iconic are rated as not funny (‘tray’, ‘spider’, ‘wait’). Using an independent set of data, we also find that imputed iconicity values correlate with humour ratings at the same level as actual iconicity ratings, controlling for frequency. This demonstrates the utility of our imputation method for generalising beyond relatively small sets of seed words (Thompson and Lupyan under review). Areas where the ratings deviate bring to light other mediating factors. For instance, “blonde” is rated as highly funny but not iconic; its humour rating is likely derived from co-occurrence relations (e.g. appearance in a genre of jokes) rather than from its formal characteristics. On the other hand, highly iconic words like ‘crash’, ‘scratch’ and ‘roar’ are low in humour ratings, likely because they are associated with negative events, pointing to valence and arousal as potential mediating variables.

Playfulness and iconicity are pervasive features of language, and their investigation can shed light on fundamental topics in language development (Cook 2000) and language use (Jakobson and Waugh 1979). This study makes four substantive contributions to experimental work on iconicity. Empirically, it (i) puts the playfulness of iconic words on firm empirical footing and (ii) illuminates what makes people rate words as funny and/or iconic by examining associations and dissociations between sets of ratings. Methodologically, it (iii) introduces and benchmarks a method for imputing iconicity ratings and (iv) examines strengths and limitations of iconicity ratings, both collected & imputed.

Explaining iconic words has been declared a risky enterprise: “linguists … cannot handle them. If they handle them carelessly, they will run into problems” (Gomi 1989). Likewise, explaining humour has been compared to dissecting an animal: you understand it better, but it dies in the process. If our study helps to explain the relation between humour and iconicity, at least we have killed two birds with one stone.

Setup
-----

``` r
# Clear workspace
rm(list=ls())

# check for /in/ and /out/ directories (create them if needed)
add_working_dir <- function(x) { if(file.exists(x)) { cat(x,"dir:",paste0(getwd(),"/",x,"/")) } else { dir.create(paste0(getwd(),"/",x)) 
  cat("subdirectory",x,"created in",getwd()) } }
add_working_dir("in")
add_working_dir("out")

# Packages and useful functions
list.of.packages <- c("tidyverse","GGally","ggthemes","readxl","ggrepel","ppcor","stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

`%notin%` <- function(x,y) !(x %in% y) 
```

Data
----

Data sources:

-   Perry, Lynn K. et al. “Iconicity in the Speech of Children and Adults.” Developmental Science, n/a-n/a. <doi:10.1111/desc.12572>
-   Engelthaler, Tomas, and Thomas T. Hills. 2017. “Humor Norms for 4,997 English Words.” Behavior Research Methods, July, 1–9. <doi:10.3758/s13428-017-0930-6>
-   Warriner, A.B., Kuperman, V., & Brysbaert, M. (2013). Norms of valence, arousal, and dominance for 13,915 English lemmas. Behavior Research Methods, 45, 1191-1207

In `norms`, available ratings are combined with imputed norms and with frequency / POS data from SUBTLEX

``` r
norms <- read_csv("in/combined-experimental-norms-with-humour-iconicity-aversion-taboo-predictions.csv")

subtlex <- read_excel(path="in/SUBTLEX-US frequency list with PoS and Zipf information.xlsx") %>%
  plyr::rename(c("Word" = "word","FREQcount" = "freq_count","Lg10WF" = "freq_log","Dom_PoS_SUBTLEX" = "POS")) %>%
  dplyr::select(word,freq_log,POS) %>%
  filter(word %in% norms$word)

# which words are in the norms, but not in subtlex? some pretty colourful ones, but
# not too many — we'll exclude them so we have frequency data for every word
unique(norms$word)[unique(norms$word) %notin% unique(subtlex$word)]

words <- norms %>%
  left_join(subtlex) %>%
  drop_na(freq_log,POS) %>%
  mutate(set = ifelse(is.na(iconicity), "unrated", "rated")) # indicate subsets

words <- words %>%
  mutate(humour_perc = ntile(humour,10),
         iconicity_perc = ntile(iconicity,10),
         valence_perc = ntile(valence,10),
         difference = humour_perc - iconicity_perc,
         diff_abs = abs(difference),
         diff_rank = humour_perc+iconicity_perc,
         ico_imputed_perc = ntile(iconicity_imputed,10),
         hum_imputed_perc = ntile(humour_imputed,10),
         diff_imputed_ico = humour_perc - ico_imputed_perc,
         diff_abs_imputed_ico = abs(diff_imputed_ico),
         diff_rank_imputed_ico = humour_perc + ico_imputed_perc,
         diff_imputed = hum_imputed_perc - ico_imputed_perc,
         diff_abs_impute = abs(diff_imputed),
         diff_rank_imputed = hum_imputed_perc + ico_imputed_perc)
```

Words
-----

Which words are rated as highly funny *and* highly iconic? And what are the most differently rated words?

Let's start by plotting the top ranked words:

``` r
ggplot(words,aes(iconicity,humour)) +
  theme_tufte() + ggtitle("Humour and iconicity: highest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_rank == 20),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/similarity-1.png)

``` r
words %>%
  filter(diff_rank > 19) %>%
  arrange(desc(humour)) %>%
  dplyr::select(word,humour,iconicity) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##       word   humour iconicity
    ##      <chr>    <dbl>     <dbl>
    ##  1  waddle 4.045455  3.100000
    ##  2  tinkle 3.962963  3.000000
    ##  3    oink 3.871795  3.615385
    ##  4  cuckoo 3.743590  2.900000
    ##  5   snort 3.741935  2.785714
    ##  6   fluff 3.724138  3.214286
    ##  7     moo 3.700000  3.882353
    ##  8   yahoo 3.689655  2.769231
    ##  9  jiggle 3.645161  2.583333
    ## 10  wiggle 3.523810  2.600000
    ## 11   whiff 3.500000  2.916667
    ## 12   yodel 3.441176  2.900000
    ## 13  squawk 3.418605  3.461538
    ## 14 juggler 3.400000  2.600000
    ## 15  giggle 3.391304  3.000000
    ## 16  bubbly 3.352941  2.818182
    ## 17 squeeze 3.344828  2.538462
    ## 18   clunk 3.344828  3.928571
    ## 19  smooch 3.333333  3.600000
    ## 20   prick 3.325000  2.642857

Many highly iconic words are also rated as highly funny. The power of iconic words to evoke colourful imagery (as in *waddle, tinkle, oink, fluff, jiggle, smooch*) likely plays a major role here. Samarin (1969) connects the occurrence of laughter following the use of ideophones to their imagistic and sensory meanings.

The distribution across the senses is remarkable, with movement, visual phenomena, sounds, and tactile texture represented. (Given what we know about the correlation of sensory ratings with iconicity ratings (Winter et al. 2017), this suggests that sensory ratings and humor ratings will also correlate well.)

Let's also have a quick look at the converse: words rated as low in funniness and low in iconicity.

``` r
ggplot(words,aes(iconicity,humour)) +
  theme_tufte() + ggtitle("Humour and iconicity: lowest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_rank <= 3),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/similarity_2-1.png)

``` r
words %>%
  filter(diff_rank <= 3) %>%
  arrange(desc(humour)) %>%
  dplyr::select(word,humour,iconicity) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##        word   humour  iconicity
    ##       <chr>    <dbl>      <dbl>
    ##  1   planet 2.064516 -0.6153846
    ##  2    share 2.058824 -0.4444444
    ##  3  account 2.052632 -0.4285714
    ##  4   system 2.037037 -0.5000000
    ##  5    quota 2.030303 -0.9166667
    ##  6    proxy 2.030303 -0.8181818
    ##  7   spider 2.029412 -0.5454545
    ##  8  million 2.028571 -0.6923077
    ##  9    cloth 2.028571 -0.7000000
    ## 10     coat 2.025641 -0.8000000
    ## 11    mural 2.021277 -1.0000000
    ## 12    whole 2.000000 -0.7692308
    ## 13     menu 2.000000 -1.3636364
    ## 14      oak 2.000000 -0.6363636
    ## 15 lacrosse 2.000000 -0.5454545
    ## 16    choir 1.972222 -0.6363636
    ## 17  trouble 1.969697 -0.5000000
    ## 18     army 1.969697 -0.5454545
    ## 19    title 1.969697 -0.6923077
    ## 20     dusk 1.931034 -0.9090909

Sidenote: plotting words with the smallest absolute difference across the boards is kind of messy and not very helpful.

``` r
ggplot(words,aes(iconicity,humour)) +
  theme_tufte() + ggtitle("Humor and iconicity: congruently rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_abs == 0),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/similarity_across-1.png)

``` r
words %>%
  filter(diff_abs == 0) %>%
  arrange(desc(humour)) %>%
  dplyr::select(word,humour,iconicity,diff_abs) %>%
  sample_n(20)
```

    ## # A tibble: 20 x 4
    ##       word   humour   iconicity diff_abs
    ##      <chr>    <dbl>       <dbl>    <int>
    ##  1   dough 2.208333  0.50000000        0
    ##  2     lie 1.757576 -0.63636364        0
    ##  3   sleep 2.296296  0.76923077        0
    ##  4    bull 2.589744  1.40000000        0
    ##  5    walk 2.322581  0.72727273        0
    ##  6    tang 3.172414  2.69230769        0
    ##  7  coffin 1.891892 -0.60000000        0
    ##  8  school 2.040000 -0.21428571        0
    ##  9     moo 3.700000  3.88235294        0
    ## 10   cabin 2.088235  0.09090909        0
    ## 11   clang 3.200000  3.85714286        0
    ## 12    grub 2.875000  1.84615385        0
    ## 13   chirp 3.000000  4.14285714        0
    ## 14     ant 2.275000  0.60000000        0
    ## 15   stray 2.324324  0.70000000        0
    ## 16    pill 2.166667  0.30000000        0
    ## 17    hold 2.441176  0.84615385        0
    ## 18 harpoon 2.500000  1.10000000        0
    ## 19  jacket 2.193548  0.50000000        0
    ## 20    skin 1.973684 -0.08333333        0

But there are also quite some cases where the two ratings don't add up:

``` r
# difference sd
diffabs.sd <- sd(words$diff_abs,na.rm=T)

ggplot(words,aes(iconicity,humour)) +
  theme_tufte() + ggtitle("Humour and iconicity: maximally different words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words,diff_abs > 3.5*diffabs.sd),
    # alpha=0.5,  # (affects not just the bounding box)
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/difference-1.png)

Among funny words not rated as iconic, there are lots of animals (dingo, hippo, chipmunk, turkey, giraffe), some taboo words (buttocks, penis, hoe), and joke-related words like pun and blonde.

``` r
# rated as funny but not iconic
words %>% 
  filter(humour_perc > 9, iconicity_perc < 4) %>%
  arrange(desc(humour)) %>%
  dplyr::select(word,humour,iconicity) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##        word   humour   iconicity
    ##       <chr>    <dbl>       <dbl>
    ##  1    dingo 3.682927 -0.50000000
    ##  2 buttocks 3.625000  0.25000000
    ##  3      hoe 3.600000 -1.45454545
    ##  4    penis 3.567568 -0.20000000
    ##  5   gander 3.500000 -0.91666667
    ##  6    deuce 3.475000 -0.73333333
    ##  7    belly 3.379310  0.25000000
    ##  8    hippo 3.366667  0.00000000
    ##  9    chimp 3.307692 -0.09090909
    ## 10 chipmunk 3.230769  0.10000000
    ## 11   turkey 3.214286  0.06666667
    ## 12      pun 3.210526 -0.37500000
    ## 13   tongue 3.166667 -1.00000000
    ## 14      bra 3.166667  0.00000000
    ## 15   blonde 3.121212 -0.16666667
    ## 16  giraffe 3.096774 -1.19047619
    ## 17   magpie 3.066667 -0.91666667
    ## 18   beaver 3.064516  0.20000000
    ## 19     lark 3.025641 -0.90000000
    ## 20 trombone 3.000000 -0.63636364

How about words rated as iconic but not rated as funny?

``` r
# rated as iconic but not funny
words %>% 
  filter(iconicity_perc > 9, humour_perc < 3) %>%
  arrange(valence) %>%
  dplyr::select(word,humour,iconicity,humour_perc,iconicity_perc,valence_perc) %>%
  slice(1:20)
```

    ## # A tibble: 9 x 6
    ##       word   humour iconicity humour_perc iconicity_perc valence_perc
    ##      <chr>    <dbl>     <dbl>       <int>          <int>        <int>
    ## 1    crash 1.731707  3.769231           1             10            1
    ## 2    dread 1.583333  2.545455           1             10            1
    ## 3    shoot 1.838710  2.600000           1             10            2
    ## 4      low 1.575758  2.916667           1             10            3
    ## 5  scratch 1.800000  3.285714           1             10            5
    ## 6    break 2.034483  2.900000           2             10            5
    ## 7 airplane 2.057143  2.545455           2             10            6
    ## 8     roar 2.031250  3.923077           2             10            6
    ## 9 sunshine 2.064516  3.090909           2             10           10

Valence is one reason for some iconic words not being rated as funny. Words like 'crash', 'dread', 'scratch' and 'shoot' (all in the lowest percentiles of valence) may be highly iconic but they have no positive or humorous connotations. So the image-evoking potency of iconic words does not always translate into funniness. Samarin proposed that ideophones are not in themselves humourous, but they *are* "the locus of affective meaning" (Samarin 1969:321).

Explorations that may or may not be worth reporting
---------------------------------------------------

The iconicity / humour relation shows up reliably across word classes; most pronounced in verbs.

``` r
words %>%
  filter(POS %in% c("Adjective","Noun","Verb")) %>%
  ggplot(aes(iconicity,humour,color=POS)) +
  theme_tufte() + ggtitle("Humour and iconicity by POS") +
  geom_point(alpha=0.5) +
  geom_smooth(method="lm") +
  facet_wrap(~ POS)
```

![](out/explorations-1.png)

Iconicity ~ humour: existing ratings
------------------------------------

First eyeball data. Iconicity looks a pretty good predictor in addition to frequency, which was the best predictor according to Engelthaler & Hills (2017). Humor shows a positive correlation with iconicity rating, as predicted. The relation is clearest for iconicity ratings &gt;0. My take on this (based on considerations noted elsewhere) is that the negative iconicity ratings do not capture one thing.

``` r
summary(lm(humour ~ freq_log + iconicity, words))
```

    ## 
    ## Call:
    ## lm(formula = humour ~ freq_log + iconicity, data = words)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.25767 -0.23487 -0.02947  0.21634  1.43344 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  2.80998    0.03953  71.077  < 2e-16 ***
    ## freq_log    -0.18037    0.01260 -14.313  < 2e-16 ***
    ## iconicity    0.07256    0.00914   7.939 4.12e-15 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.3748 on 1416 degrees of freedom
    ##   (68824 observations deleted due to missingness)
    ## Multiple R-squared:  0.1845, Adjusted R-squared:  0.1833 
    ## F-statistic: 160.2 on 2 and 1416 DF,  p-value: < 2.2e-16

``` r
ggplot(words,aes(humour,freq_log)) +
  theme_tufte() + ggtitle("Humour ratings by log frequency") + 
  geom_point(alpha=0.5) +
  geom_smooth(method="lm")
```

![](out/plots-1.png)

``` r
ggplot(words,aes(humour,iconicity)) +
  theme_tufte() + ggtitle("Humour ratings by iconicity") + 
  geom_point(alpha=0.5) +
  geom_smooth(method="lm")
```

![](out/plots-2.png)

Let's residualise out `freq_log` so we get a better look at the humor ~ iconicity relation; and conversely, residualise `iconicity` to look at humor ~ frequency.

``` r
summary(lm(humour ~ freq_log + iconicity,words))
```

    ## 
    ## Call:
    ## lm(formula = humour ~ freq_log + iconicity, data = words)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.25767 -0.23487 -0.02947  0.21634  1.43344 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  2.80998    0.03953  71.077  < 2e-16 ***
    ## freq_log    -0.18037    0.01260 -14.313  < 2e-16 ***
    ## iconicity    0.07256    0.00914   7.939 4.12e-15 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.3748 on 1416 degrees of freedom
    ##   (68824 observations deleted due to missingness)
    ## Multiple R-squared:  0.1845, Adjusted R-squared:  0.1833 
    ## F-statistic: 160.2 on 2 and 1416 DF,  p-value: < 2.2e-16

``` r
words$residuals_frequency <- NA
words[which(!is.na(words$freq_log) & !is.na(words$humour)),]$residuals_frequency <- residuals(lm(humour ~ freq_log,words))
ggplot(words,aes(iconicity,residuals_frequency)) +
  theme_tufte() + ggtitle("Iconicity, frequency residualised out") + 
  geom_point(shape=16,alpha=0.5) +
  geom_smooth(method="lm")
```

![](out/residualising1-1.png)

``` r
words$residuals_iconicity <- NA
words[which(!is.na(words$iconicity) & !is.na(words$humour)),]$residuals_iconicity <- residuals(lm(humour ~ iconicity,words))
ggplot(words,aes(freq_log,residuals_iconicity)) +
  theme_tufte() + ggtitle("Log frequency, iconicity residualised out") + 
  geom_point(shape=16,alpha=0.5) +
  geom_smooth(method="lm")
```

![](out/residualising1-2.png)

Iconicity ~ humour: imputed ratings
-----------------------------------

Now look at our imputed iconicity ratings. To avoid double-dipping we tease apart words for which the predictions overlap with the iconicity ratings (n=1419) and words for which predictions are newly inferred (n=3577) (encoded in `$set`).

Imputed iconicity values correlate with humor ratings, controlling for frequency. For every point gained in predicted iconicity there's a .22 increase in humor rating.

``` r
words %>% filter(!is.na(humour)) %>%
  group_by(set) %>%
  summarise(n = n())
```

    ## # A tibble: 2 x 2
    ##       set     n
    ##     <chr> <int>
    ## 1   rated  1419
    ## 2 unrated  3577

``` r
# create a separate df with only the unrated words with imputed iconicity ratings
words_imputed <- words %>%
  filter(!is.na(humour) & set == "unrated")

summary(lm(humour ~ freq_log + iconicity_imputed,words_imputed))
```

    ## 
    ## Call:
    ## lm(formula = humour ~ freq_log + iconicity_imputed, data = words_imputed)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.18636 -0.27246 -0.04259  0.22983  1.71218 
    ## 
    ## Coefficients:
    ##                   Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)        2.63279    0.02594  101.49   <2e-16 ***
    ## freq_log          -0.16064    0.01105  -14.54   <2e-16 ***
    ## iconicity_imputed  0.22436    0.01098   20.44   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.4091 on 3574 degrees of freedom
    ## Multiple R-squared:  0.1547, Adjusted R-squared:  0.1542 
    ## F-statistic: 326.9 on 2 and 3574 DF,  p-value: < 2.2e-16

``` r
ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  theme_tufte() + ggtitle("Humour ratings by imputed iconicity ratings") + 
  geom_point(shape=16,alpha=0.5) +
  geom_smooth(method="lm") +
  facet_wrap(~set)
```

![](out/iconicity_imputed-1.png)

Let's have a closer look at the words in this new set. Again, we're looking only at the words for which we didn't have iconicity ratings in the first place to avoid double-dipping.

Many of the words rated as highly funny that our method identifies as high in imputed iconicity are imitative forms like swish, chug, gobble, smack, blip, whack, oomph, chuckle, wriggle.

``` r
ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  theme_tufte() + ggtitle("Humour and iconicity: highest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed,diff_rank_imputed_ico == 20) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/iconicity_imputed_words_1-1.png)

``` r
words_imputed %>%
  filter(diff_rank_imputed_ico > 19) %>%
  arrange(desc(iconicity_imputed)) %>%
  dplyr::select(word,humour,iconicity_imputed) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##       word   humour iconicity_imputed
    ##      <chr>    <dbl>             <dbl>
    ##  1   swish 3.172414          3.753121
    ##  2    chug 3.733333          3.751669
    ##  3     bop 3.577778          3.629748
    ##  4  gobble 3.645161          3.319210
    ##  5   smack 3.117647          3.267757
    ##  6    blip 3.055556          2.872613
    ##  7   whack 3.545455          2.871249
    ##  8   oomph 3.933333          2.778939
    ##  9    poke 3.275000          2.763418
    ## 10  wallop 3.666667          2.592597
    ## 11    funk 3.750000          2.568374
    ## 12 chuckle 3.685714          2.511191
    ## 13 quickie 3.685714          2.465730
    ## 14 wriggle 3.441176          2.458105
    ## 15  quiver 3.096774          2.427625
    ## 16   scamp 3.107143          2.397420
    ## 17    burp 3.264706          2.366497
    ## 18   hooky 3.413793          2.225164
    ## 19  oodles 3.840000          2.206217
    ## 20  weasel 3.687500          2.201631

On the lower side of the rankings, many of the words low in humour ratings and low in imputed iconicity are non-imitative forms like subject, ransom, libel, conduct, clothing, request and author. Our imputed iconicity measure is clearly picking up something related to what people do when they rate words for iconicity.

``` r
ggplot(words_imputed,aes(iconicity_imputed,humour)) +
  theme_tufte() + ggtitle("Humour and imputed iconicity: lowest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed,diff_rank_imputed_ico <= 2) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/iconicity_imputed_words_2-1.png)

``` r
words_imputed %>%
  filter(diff_rank_imputed_ico <= 2) %>%
  arrange(-desc(iconicity_imputed)) %>%
  dplyr::select(word,humour,iconicity_imputed) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##         word   humour iconicity_imputed
    ##        <chr>    <dbl>             <dbl>
    ##  1   subject 1.794118        -1.2291900
    ##  2    ransom 1.891892        -0.9377655
    ##  3     libel 1.821429        -0.8756799
    ##  4     bible 1.862069        -0.8363551
    ##  5     siege 1.827586        -0.8149955
    ##  6   hospice 1.703704        -0.8021329
    ##  7   conduct 1.897436        -0.7077795
    ##  8   arsenic 1.551020        -0.7011770
    ##  9  clothing 1.921053        -0.6365016
    ## 10     negro 1.791667        -0.6266399
    ## 11    mosque 1.777778        -0.5918647
    ## 12   typhoid 1.709677        -0.5678349
    ## 13   request 1.818182        -0.5244449
    ## 14   expense 1.916667        -0.4940790
    ## 15    author 1.666667        -0.4564817
    ## 16    length 1.916667        -0.4260772
    ## 17   anthrax 1.764706        -0.4255076
    ## 18   mandate 1.818182        -0.4058705
    ## 19 plaintiff 1.878049        -0.3867146
    ## 20   hostage 1.710526        -0.3810785

The intersection of imputed ratings
-----------------------------------

Now let's look at the "unknown unknown": the intersection of imputed ratings for humour and for iconicity. Since we have these for 63721 words not rated before, this is venturing quite far out of the comfort of human-collected ratings.

``` r
words_imputed_intersection <- words %>%
  filter(is.na(humour) & is.na(iconicity)) %>%
  filter(!is.na(humour_imputed) & !is.na(iconicity_imputed))
words_imputed_intersection %>%
  summarise(n=n())
```

    ## # A tibble: 1 x 1
    ##       n
    ##   <int>
    ## 1 63721

``` r
ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  theme_tufte() + ggtitle("Imputed humour and imputed iconicity") +
  geom_point(alpha=0.5,na.rm=T)
```

![](out/imputed_intersection-1.png)

As above, let's look at the top and bottom ends of the intersection.

On the top end, we find highly imitative words like whoosh, whirr, whizzle, squeaks, chomp, slackety, boing, etc.

**Open question / to do:** What can we say about the quality of the imputed humour ratings? Would be great if we could link that to a measure of entropy as Westbury et al. 2017 do for nonwords. That would give us a measure independent of word2vec data that can serve as a cross-check for the imputed humour ratings. I think it's highly likely to work.

``` r
ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  theme_tufte() + ggtitle("Humour and iconicity: highest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed_intersection,diff_rank_imputed > 19) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/intersection_imputed_words_1-1.png)

``` r
words_imputed_intersection %>%
  filter(diff_rank_imputed > 19) %>%
  arrange(desc(iconicity_imputed)) %>%
  dplyr::select(word,humour_imputed,iconicity_imputed) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##        word humour_imputed iconicity_imputed
    ##       <chr>          <dbl>             <dbl>
    ##  1   whoosh       2.905735          4.280172
    ##  2    whirr       2.945714          4.242872
    ##  3      brr       2.988076          4.065481
    ##  4    chomp       3.157756          3.813039
    ##  5     whir       3.068760          3.806808
    ##  6   swoosh       2.983470          3.802145
    ##  7     brrr       3.023402          3.774931
    ##  8     zaps       3.136237          3.774506
    ##  9  squeaks       3.236797          3.769440
    ## 10 squelchy       2.902890          3.706240
    ## 11    gulps       2.918545          3.667204
    ## 12 smacking       2.886123          3.665312
    ## 13   clanks       2.824783          3.584415
    ## 14     whoo       3.101658          3.560813
    ## 15     clop       3.624225          3.552962
    ## 16    yowls       3.007058          3.527649
    ## 17 clackety       3.336467          3.517783
    ## 18    buzzy       3.088766          3.494994
    ## 19  whizzle       3.485750          3.484934
    ## 20 screechy       3.128866          3.472191

On the lower side of the rankings, many of the words low in humour ratings and low in imputed iconicity are non-imitative forms like subject, ransom, libel, conduct, clothing, request and author. Our imputed iconicity measure is clearly picking up something related to what people do when they rate words for iconicity.

``` r
ggplot(words_imputed_intersection,aes(iconicity_imputed,humour_imputed)) +
  theme_tufte() + ggtitle("Humour and imputed iconicity: lowest rated words") +
  geom_point(alpha=0.5,na.rm=T) +
  geom_label_repel(
    data=subset(words_imputed_intersection,diff_rank_imputed <= 2) %>% arrange(desc(iconicity_imputed)) %>% slice(1:40),
    aes(label=word),
    size=2.5,
    alpha=0.8,
    label.size=NA,
    label.r=unit(0,"lines"),
    box.padding=unit(0.35, "lines"),
    point.padding=unit(0.3,"lines")
  )
```

![](out/intersection_imputed_words_2-1.png)

``` r
words_imputed_intersection %>%
  filter(diff_rank_imputed <= 2) %>%
  arrange(-desc(iconicity_imputed)) %>%
  dplyr::select(word,humour_imputed,iconicity_imputed) %>%
  slice(1:20)
```

    ## # A tibble: 20 x 3
    ##            word humour_imputed iconicity_imputed
    ##           <chr>          <dbl>             <dbl>
    ##  1          apr       1.817228         -1.490223
    ##  2          dei       2.021663         -1.463575
    ##  3    covenants       1.917819         -1.386876
    ##  4 palestinians       1.855983         -1.381957
    ##  5     covenant       1.949790         -1.340520
    ##  6     clothier       1.961125         -1.337835
    ##  7  palestinian       1.656509         -1.263986
    ##  8      variant       1.862685         -1.256117
    ##  9 mitochondria       1.909340         -1.249674
    ## 10     israelis       1.922933         -1.245422
    ## 11         serb       2.017302         -1.216935
    ## 12    sufferers       1.629080         -1.209489
    ## 13       herein       2.021290         -1.198094
    ## 14      isotope       1.758388         -1.184239
    ## 15     duration       1.910982         -1.175651
    ## 16       ciudad       1.953961         -1.170954
    ## 17    appellant       1.934171         -1.167905
    ## 18    palestine       1.988103         -1.161564
    ## 19   alexandria       2.005226         -1.131837
    ## 20  infantrymen       1.976268         -1.108527

Stats
-----

Partial correlations show a -9.4% correlation between iconicity and frequency when partialing out humour. This is as expected: Winter et al. (2017) report a negative correlation between iconicity and frequency. Partial correlations also show -35.6% covariance between humour and frequency, controlling out iconicity as a mediator (the more frequent a word, the less funny). This replicates the finding reported by Engelthaler and Hill (2017). Finally, there is 20.6% covariance between humour and iconicity, partialing out log frequency as a mediator.

``` r
words_intersection <- words[complete.cases(words %>% dplyr::select(word,humour,freq_log,iconicity)),]

pcor.test(x=words_intersection$iconicity,y=words_intersection$freq_log,z=words_intersection$humour)
```

    ##      estimate      p.value statistic    n gp  Method
    ## 1 -0.09429068 0.0003773552 -3.564016 1419  1 pearson

``` r
pcor.test(x=words_intersection$humour,y=words_intersection$freq_log,z=words_intersection$iconicity)
```

    ##     estimate      p.value statistic    n gp  Method
    ## 1 -0.3555085 1.688727e-43 -14.31271 1419  1 pearson

``` r
pcor.test(x=words_intersection$humour,y=words_intersection$iconicity,z=words_intersection$freq_log)
```

    ##    estimate      p.value statistic    n gp  Method
    ## 1 0.2064276 4.122044e-15  7.938811 1419  1 pearson

We can do the same for the imputed iconicity ratings, again using only the unrated subset to avoid double dipping. Looks like there is 32.3% covariance between humor and imputed iconicity, partialing out log frequency as a mediator:

``` r
pcor.test(x=words_imputed$humour,y=words_imputed$iconicity_imputed,z=words_imputed$freq_log)
```

    ##    estimate      p.value statistic    n gp  Method
    ## 1 0.3234563 7.050977e-88  20.43573 3577  1 pearson

Finally, we can do this for the intersection of imputed ratings, using only the unrated portion of the data. We find 42.8% covariance between imputed humour and imputed iconicity, partialing out log frequency.

``` r
words.imp <- words_imputed_intersection %>%
  dplyr::select(word, humour_imputed, iconicity_imputed, freq_log) %>%
  drop_na()

pcor.test(x=words.imp$humour_imputed,y=words.imp$iconicity_imputed,z=words.imp$freq_log)
```

    ##    estimate p.value statistic     n gp  Method
    ## 1 0.4275994       0  119.4029 63721  1 pearson

Discussion
----------

The negative relation between humor and frequency reported by Engelthaler and Hill (2017) is replicated for a subset of words for which we have iconicity ratings. However, controlling for this relation, there remains a strong partial correlation of 20.6% between iconicity and humor ratings — stronger than the next highest correlation reported by Engelthaler and Hill (which was for lexical decision time).

Many highly iconic words are rated as funny, and many words rated as not iconic are rated as not funny. This sheds light on the relation between iconicity and playfulness. Across languages, iconic words display marked phonotactics, sound play and evocative imagery, all things that can make iconic words sound funny. The data analysed here suggests these aspects of iconic words indeed lead to higher funniness ratings, though only for positively valenced words.

The discrepancies between humor and iconicity ratings also shed light on the various factors that go into humor ratings. Highly funny words not rated as highly iconic include animal names, taboo words and joke-related words. This shows that at least some humor ratings are made on the basis of semantics and word associations.

The basic correlations hold up well in sections of data for which we imputed ratings, demonstrating the robustness of the method for ratings imputation used here, and suggesting that this method can feasibly be used to increase the intersection of ratings in large lexical datasets.

References
----------

-   Clark, Herbert H. 2016. “Depicting as a method of communication.” Psychological Review 123 (3): 324–347. <doi:10.1037/rev0000026>.
-   Cook, Guy. 2000. Language Play, Language Learning. 1 edition. Oxford: Oxford University Press, February 21.
-   Engelthaler, Tomas, and Thomas T. Hills. 2017. “Humor norms for 4,997 English words.” Behavior Research Methods: 1–9. <doi:10.3758/s13428-017-0930-6>.
-   Gomi, Taro. 1989. An Illustrated Dictionary of Japanese Onomatopoeic Expressions. Transl. by J. Turrent. Tokyo: Japan Times.
-   Jakobson, Roman, and Linda R. Waugh. 1979. The Sound Shape of Language. Bloomington: Indiana University Press.
-   Nuckolls, Janis B. 1999. “The Case for Sound Symbolism.” Annual Review of Anthropology 28: 225–252.
-   Perniss, Pamela, Robin L. Thompson, and Gabriella Vigliocco. 2010. “Iconicity as a General Property of Language: Evidence from Spoken and Signed Languages.” Frontiers in Psychology 1 (227): 1–15. <doi:10.3389/fpsyg.2010.00227>.
-   Perry, Lynn K., Marcus Perlman, Bodo Winter, Dominic W. Massaro, and Gary Lupyan. 2017. “Iconicity in the speech of children and adults.” Developmental Science. <doi:10.1111/desc.12572>. <http://onlinelibrary.wiley.com/doi/10.1111/desc.12572/abstract>.
-   Samarin, William J. 1970. “Inventory and choice in expressive language.” Word 26: 153–169.
-   Thompson, Bill, and Gary Lupyan. under review. Automatic Estimation of Lexical Concreteness in 77 Languages. In .
-   Welmers, William E. 1973. African Language Structures. Berkeley: University of California Press.
-   Westbury, Chris, Cyrus Shaoul, Gail Moroschan, and Michael Ramscar. 2016. “Telling the world’s least funny jokes: On the quantification of humor as entropy.” Journal of Memory and Language 86: 141–156. <doi:10.1016/j.jml.2015.09.001>.
-   Zwicky, Arnold M., and Geoffrey K. Pullum. 1987. Plain Morphology and Expressive Morphology. In Proceedings of the Thirteenth Annual Meeting of the Berkeley Linguistics Society, ed by. John Aske, Beery, Natasha, Laura Michaelis, and Hana Filip, VII:330–340. Berkeley: Berkeley Linguistics Society.
