Playful iconicity: data & analyses
================
Mark Dingemanse & Bill Thompson
(this version: 2019-11-28)

  - [Introduction](#introduction)
      - [Data sources](#data-sources)
      - [Descriptive data](#descriptive-data)
      - [Figures](#figures)
  - [Main analyses](#main-analyses)
      - [Funniness and iconicity](#funniness-and-iconicity)
      - [Funniness and imputed
        iconicity](#funniness-and-imputed-iconicity)
      - [Imputed funniness and imputed
        iconicity](#imputed-funniness-and-imputed-iconicity)
      - [Structural properties of highly rated
        words](#structural-properties-of-highly-rated-words)
  - [End](#end)

## Introduction

This code notebook provides a fully reproducible workflow for the paper
**Playful iconicity: Structural markedness underlies the relation
between funniness and iconicity**. To increase readability, not all code
chunks present in the .Rmd source are shown in the output.

### Data sources

Primary data sources:

  - *iconicity ratings*: Perry, Lynn K. et al. Iconicity in the Speech
    of Children and Adults. Developmental Science.
    <doi:10.1111/desc.12572>
  - *funniness ratings*: Engelthaler, Tomas, and Thomas T. Hills. 2017.
    Humor Norms for 4,997 English Words. Behavior Research Methods,
    July, 1-9. <doi:10.3758/s13428-017-0930-6>

We use these ratings in our analyses, but we also feed them to our
[imputation method](/benchmark-prediction.py), which regresses the human
ratings against semantic vectors in order to generate imputed ratings
for an additional 63.680 words.

Secondary data sources:

  - *number of morphemes*: Balota, D. A., Yap, M. J., Hutchison, K. A.,
    Cortese, M. J., Kessler, B., Loftis, B., … Treiman, R. (2007). The
    English Lexicon Project. Behavior Research Methods, 39(3), 445–459.
    doi: 10.3758/BF03193014
  - *word frequency*: Brysbaert, M., New, B., & Keuleers, E. (2012).
    Adding part-of-speech information to the SUBTLEX-US word
    frequencies. Behavior Research Methods, 44(4), 991–997. doi:
    10.3758/s13428-012-0190-4 (for *word frequency*)
  - *lexical decision times*: Keuleers, E., Lacey, P., Rastle, K., &
    Brysbaert, M. (2012). The British Lexicon Project: Lexical decision
    data for 28,730 monosyllabic and disyllabic English words. Behavior
    Research Methods, 44(1), 287-304. doi: 10.3758/s13428-011-0118-4
  - *phonotactic measures*: Vaden, K.I., Halpin, H.R., Hickok, G.S.
    (2009). Irvine Phonotactic Online Dictionary, Version 2.0. \[Data
    file\]. Available from <http://www.iphod.com>.

Secondary data sources used in supplementary analyses:

  - *valence, arousal and dominance*: Warriner, A.B., Kuperman, V., &
    Brysbaert, M. (2013). Norms of valence, arousal, and dominance for
    13,915 English lemmas. Behavior Research Methods, 45, 1191-1207
  - *age of acquisition*: Kuperman, V., Stadthagen-Gonzalez, H., &
    Brysbaert, M. (2012). Age-of-acquisition ratings for 30,000 English
    words. Behavior Research Methods, 44(4), 978-990. doi:
    10.3758/s13428-012-0210-4

After collating these data sources we add a range of summary variables,
mainly for easy plotting and subset selection.

``` r
words <- words %>%
  mutate(fun_perc = ntile(fun,10),
         fun_resid_perc = ntile(fun_resid,10),
         ico_perc = ntile(ico,10),
         diff_rank = fun_perc + ico_perc,
         ico_imputed_perc = ntile(ico_imputed,10),
         fun_imputed_perc = ntile(fun_imputed,10),
         fun_imputed_resid_perc = ntile(fun_imputed_resid,10),
         diff_rank_setB = fun_perc + ico_imputed_perc,
         diff_rank_setC = fun_imputed_perc + ico_imputed_perc,
         diff_rank_setD = fun_imputed_perc + ico_perc,
         logletterfreq_perc = ntile(logletterfreq,10),
         dens_perc = ntile(unsDENS,10),
         biphone_perc = ntile(unsBPAV,10),
         triphone_perc = ntile(unsTPAV,10),
         posprob_perc = ntile(unsPOSPAV,10),
         valence_perc = ntile(valence,10))
```

### Descriptive data

We have **4.996** words rated for funniness, **2.945** rated for
iconicity, and **1.419** in the intersection (set A). We have **3.577**
words with human funniness ratings and imputed iconicity ratings (set
B). We have imputed data for a total of **70.202** words, and we’re
venturing outside the realm of rated words for **63.680** of them (set
C).

(We also have 1.526 words with human iconicity ratings and imputed
funniness ratings in set D, the mirror image of set B; this is not used
in the paper but reported on in Supplementary Analyses below.)

<table>

<thead>

<tr>

<th style="text-align:left;">

set

</th>

<th style="text-align:right;">

n

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

A

</td>

<td style="text-align:right;">

1419

</td>

</tr>

<tr>

<td style="text-align:left;">

B

</td>

<td style="text-align:right;">

3577

</td>

</tr>

<tr>

<td style="text-align:left;">

C

</td>

<td style="text-align:right;">

63680

</td>

</tr>

<tr>

<td style="text-align:left;">

D

</td>

<td style="text-align:right;">

1526

</td>

</tr>

</tbody>

</table>

    ## # A tibble: 3 x 9
    ##   word    ico   fun ico_perc fun_perc ico_imputed fun_imputed
    ##   <chr> <dbl> <dbl>    <int>    <int>       <dbl>       <dbl>
    ## 1 wigg~   2.6  3.52       10       10        3.37        3.39
    ## 2 wobb~   2.4  3.15        9       10        3.06        3.11
    ## 3 wagg~  NA   NA          NA       NA        2.37        3.42
    ## # ... with 2 more variables: ico_imputed_perc <int>,
    ## #   fun_imputed_perc <int>

The most important columns in the data are shown below for set A. Sets B
and C feature `ico_imputed` and `fun_imputed` instead of or in addition
to the human ratings. The field `diff_rank` is the sum of `fun` and
`ico` deciles for a given word: a word with `diff_rank` 2 occurs in the
first decile (lowest 10%) of both funniness and iconicity ratings, and a
word with `diff_rank` 20 occurs in the 10th decile (highest 10%) of
both.

<table>

<caption>

Structure of the data

</caption>

<thead>

<tr>

<th style="text-align:left;">

word

</th>

<th style="text-align:right;">

ico

</th>

<th style="text-align:right;">

fun

</th>

<th style="text-align:right;">

logletterfreq

</th>

<th style="text-align:right;">

logfreq

</th>

<th style="text-align:right;">

rt

</th>

<th style="text-align:left;">

nmorph

</th>

<th style="text-align:right;">

diff\_rank

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

flap

</td>

<td style="text-align:right;">

2.7692308

</td>

<td style="text-align:right;">

3.071429

</td>

<td style="text-align:right;">

\-3.157663

</td>

<td style="text-align:right;">

2.133539

</td>

<td style="text-align:right;">

575.9231

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

20

</td>

</tr>

<tr>

<td style="text-align:left;">

bleep

</td>

<td style="text-align:right;">

3.9285714

</td>

<td style="text-align:right;">

2.931818

</td>

<td style="text-align:right;">

\-2.746375

</td>

<td style="text-align:right;">

2.136721

</td>

<td style="text-align:right;">

655.1622

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

19

</td>

</tr>

<tr>

<td style="text-align:left;">

weed

</td>

<td style="text-align:right;">

1.7000000

</td>

<td style="text-align:right;">

3.128205

</td>

<td style="text-align:right;">

\-2.593606

</td>

<td style="text-align:right;">

2.778875

</td>

<td style="text-align:right;">

566.5000

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

18

</td>

</tr>

<tr>

<td style="text-align:left;">

shriek

</td>

<td style="text-align:right;">

3.5000000

</td>

<td style="text-align:right;">

2.458333

</td>

<td style="text-align:right;">

\-2.752525

</td>

<td style="text-align:right;">

1.518514

</td>

<td style="text-align:right;">

671.9189

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

17

</td>

</tr>

<tr>

<td style="text-align:left;">

fun

</td>

<td style="text-align:right;">

0.8333333

</td>

<td style="text-align:right;">

3.355556

</td>

<td style="text-align:right;">

\-3.216379

</td>

<td style="text-align:right;">

4.079579

</td>

<td style="text-align:right;">

499.4474

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

16

</td>

</tr>

<tr>

<td style="text-align:left;">

seaweed

</td>

<td style="text-align:right;">

2.5000000

</td>

<td style="text-align:right;">

2.382353

</td>

<td style="text-align:right;">

\-2.503129

</td>

<td style="text-align:right;">

1.949390

</td>

<td style="text-align:right;">

658.5263

</td>

<td style="text-align:left;">

2

</td>

<td style="text-align:right;">

15

</td>

</tr>

<tr>

<td style="text-align:left;">

stumble

</td>

<td style="text-align:right;">

1.7000000

</td>

<td style="text-align:right;">

2.407407

</td>

<td style="text-align:right;">

\-2.892918

</td>

<td style="text-align:right;">

2.004321

</td>

<td style="text-align:right;">

548.1538

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

14

</td>

</tr>

<tr>

<td style="text-align:left;">

parka

</td>

<td style="text-align:right;">

0.8000000

</td>

<td style="text-align:right;">

2.454546

</td>

<td style="text-align:right;">

\-2.944659

</td>

<td style="text-align:right;">

1.505150

</td>

<td style="text-align:right;">

709.4091

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

13

</td>

</tr>

<tr>

<td style="text-align:left;">

bookcase

</td>

<td style="text-align:right;">

0.8181818

</td>

<td style="text-align:right;">

2.439024

</td>

<td style="text-align:right;">

\-2.815705

</td>

<td style="text-align:right;">

1.690196

</td>

<td style="text-align:right;">

688.0286

</td>

<td style="text-align:left;">

2

</td>

<td style="text-align:right;">

12

</td>

</tr>

<tr>

<td style="text-align:left;">

doctor

</td>

<td style="text-align:right;">

1.6000000

</td>

<td style="text-align:right;">

2.100000

</td>

<td style="text-align:right;">

\-2.779546

</td>

<td style="text-align:right;">

4.129110

</td>

<td style="text-align:right;">

498.2105

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:right;">

11

</td>

</tr>

</tbody>

</table>

### Figures

For a quick impression of the main findings, this section reproduces the
figures from the paper.

**Figure 1: Overview** ![](out/figures-1.png)<!-- -->

**Figure 3: Funniness and iconicity**

![](out/fig_3_panel-1.png)<!-- -->

**Figure 4: Highest rated words**

![](out/figure_upper-1.png)<!-- -->

**Figure 5: Structural markedness**

![](out/figure_foregrounding-1.png)<!-- -->

## Main analyses

### Funniness and iconicity

#### Reproducing prior results

Engelthaler & Hills report frequency as the strongest correlate with
funniness (less frequent words are rated as more funny), and lexical
decision RT as the second strongest (words with slower RTs are rated as
more funny). By way of sanity check let’s replicate their analysis.

Raw correlations hover around 28%, as reported (without corrections or
controls) in their paper. A linear model with funniness as dependent
variable and frequency and RT as predictors shows a role for both,
though frequency accounts for a much larger portion of the variance
(15%) than rt (0.6%).

To what extent do frequency and RT predict funniness?

**Model m0:** lm(formula = fun \~ logfreq + rt, data = words %\>%
drop\_na(fun))

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

78.329

</td>

<td style="text-align:right;">

454.096

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.083

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

17.315

</td>

<td style="text-align:right;">

100.380

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.020

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

4993

</td>

<td style="text-align:right;">

861.264

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

#### Known knowns

If frequency and RT explain some of the variance in funniness ratings,
how much is left for iconicity? We’ll do this analysis on the core set
of 1419 words for which we have funniness and iconicity ratings.

Turns out that the magnitude estimate of iconicity is about half that of
frequency, and with positive sign instead of a negative one (higher
funniness ratings go with higher iconicity ratings). The effect of
iconicity ratings is much larger than RT, the second most important
correlate reported by Engelthaler & Hill.

**Model m1.1**: lm(formula = fun \~ logfreq + rt, data = words %\>%
filter(set == , “A”))

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

36.143

</td>

<td style="text-align:right;">

247.813

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.149

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1.249

</td>

<td style="text-align:right;">

8.562

</td>

<td style="text-align:right;">

0.003

</td>

<td style="text-align:right;">

0.006

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1416

</td>

<td style="text-align:right;">

206.519

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

**Model m1.2**: lm(formula = fun \~ logfreq + rt + ico, data = words
%\>% filter(set == , “A”))

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

36.143

</td>

<td style="text-align:right;">

258.779

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.155

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1.249

</td>

<td style="text-align:right;">

8.941

</td>

<td style="text-align:right;">

0.003

</td>

<td style="text-align:right;">

0.006

</td>

</tr>

<tr>

<td style="text-align:left;">

ico

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

8.891

</td>

<td style="text-align:right;">

63.661

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.043

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

197.628

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison of m1.1 and m1.2

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1416

</td>

<td style="text-align:right;">

206.5194

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

197.6281

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

8.891332

</td>

<td style="text-align:right;">

63.66118

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

Partial correlations show 20.6% covariance between funniness and
iconicity, partialing out log frequency as a mediator. This shows the
effects of iconicity and funniness are not reducible to frequency alone.

<table>

<caption>

funniness and iconicity controlling for word frequency

</caption>

<thead>

<tr>

<th style="text-align:right;">

estimate

</th>

<th style="text-align:right;">

p.value

</th>

<th style="text-align:right;">

statistic

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

gp

</th>

<th style="text-align:left;">

Method

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

0.2064276

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

7.938811

</td>

<td style="text-align:right;">

1419

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

pearson

</td>

</tr>

</tbody>

</table>

**Example words**

Both high: *zigzag, squeak, chirp, pop, clunk, moo, clang, oink, zoom,
smooch, babble, squawk, thud, gush, fluff, flop, waddle, giggle, tinkle,
ooze*

Both low: *silent, statement, poor, cellar, incest, window, lie, coffin,
platform, address, slave, wait, year, case*

High funniness, low iconicity: *belly, buttocks, beaver, chipmunk,
turkey, bra, hippo, chimp, blonde, penis, pun, dingo, trombone, deuce,
lark, gander, magpie, tongue, giraffe, hoe*

High iconicity, low funniness: *click, roar, crash, chime, scratch,
swift, sunshine, low, break, clash, shoot, airplane, dread*

N.B. controlling for frequency in these lists (by using `fun_resid`
instead of `fun`) does not make a difference in ranking, so not done
here and elsewhere.

What about compound nouns among high iconicity words? From eyeballing,
it seems to be about 10% in a set of the highest rated 200 nouns. Many
probable examples can be found by looking at highly rated nouns with
multiple morphemes: *zigzag, buzzer, skateboard, sunshine, zipper,
freezer, snowball, juggler, airplane, bedroom, goldfish, seaweed,
lipstick, mixer, corkscrew, doorknob, killer, moonlight, tummy, kingdom,
razor, singer, ashtray, fireworks, pliers, racer, uproar* (*zigzag*, one
of the few reduplicative words in English, is included here because the
Balota et al. database lists it as having 2 morphemes).

### Funniness and imputed iconicity

Here we study the link between funniness ratings and imputed iconicity
ratings.

Compared to model m2.1 with just log frequency and lexical decision time
as predictors, model m2.2 including imputed iconicity as predictor
provides a significantly better fit and explains a larger portion of the
variance.

**Model m2.1**: lm(formula = fun \~ logfreq + rt, data = words.setB)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

39.528

</td>

<td style="text-align:right;">

218.214

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.058

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

20.487

</td>

<td style="text-align:right;">

113.100

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.031

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

3574

</td>

<td style="text-align:right;">

647.400

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

**Model m2.2**: lm(formula = fun \~ logfreq + rt + ico\_imputed, data =
words.setB)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

39.528

</td>

<td style="text-align:right;">

245.736

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.064

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

20.487

</td>

<td style="text-align:right;">

127.365

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.034

</td>

</tr>

<tr>

<td style="text-align:left;">

ico\_imputed

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

72.669

</td>

<td style="text-align:right;">

451.769

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.112

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

3573

</td>

<td style="text-align:right;">

574.731

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

3574

</td>

<td style="text-align:right;">

647.3997

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

3573

</td>

<td style="text-align:right;">

574.7308

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

72.66885

</td>

<td style="text-align:right;">

451.7694

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

A partial correlations analysis shows that imputed iconicity values
correlate with funniness ratings at at least the same level as actual
iconicity ratings, controlling for frequency (r = 0.32, p \< 0.0001).

**Example words**

High imputed funniness and high imputed iconicity: *swish, chug, bop,
gobble, smack, blip, whack, oomph, poke, wallop, funk, chuckle, quickie,
wriggle, quiver, scamp, burp, hooky, oodles, weasel*

Low imputed funniness and low imputed iconicity: *subject, ransom,
libel, bible, siege, hospice, conduct, arsenic, clothing, negro, mosque,
typhoid, request, expense, author, length, anthrax, mandate, plaintiff,
hostage*

High funniness and low imputed iconicity: *heifer, dinghy, cuckold,
nudist, sheepdog, oddball, spam, harlot, getup, rickshaw, sac, kiwi,
whorehouse, soiree, condom, plaything, croquet, charade, fiver, loch*

Low funniness and high imputed iconicity: *shudder, scrape, taps,
fright, heartbeat, puncture, choke, tremor, biceps, glimpse, disgust,
doom, stir, dent, scold, bully, reign, blister, check, horror*

What about analysable compounds among high iconicity nouns? Here too
about 10%, with examples like *heartbeat, mouthful, handshake, bellboy,
comeback, catchphrase*.

### Imputed funniness and imputed iconicity

Model 3.1: lm(formula = fun\_imputed \~ logfreq + rt, data = words.setC)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

92.862

</td>

<td style="text-align:right;">

1018.093

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.050

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

13.422

</td>

<td style="text-align:right;">

147.150

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.008

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

19204

</td>

<td style="text-align:right;">

1751.629

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

Model 3.2: lm(formula = fun\_imputed \~ logfreq + rt + ico\_imputed,
data = words.setC)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

92.862

</td>

<td style="text-align:right;">

1258.529

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.062

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

13.422

</td>

<td style="text-align:right;">

181.901

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.009

</td>

</tr>

<tr>

<td style="text-align:left;">

ico\_imputed

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

334.714

</td>

<td style="text-align:right;">

4536.279

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.191

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

19203

</td>

<td style="text-align:right;">

1416.915

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

19204

</td>

<td style="text-align:right;">

1751.629

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

19203

</td>

<td style="text-align:right;">

1416.915

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

334.7145

</td>

<td style="text-align:right;">

4536.279

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

Partial correlations show that imputed iconicity and imputed funniness
share 43% covariance not explained by word frequency.

<table>

<caption>

imputed funniness and imputed iconicity controlling for word frequency

</caption>

<thead>

<tr>

<th style="text-align:right;">

estimate

</th>

<th style="text-align:right;">

p.value

</th>

<th style="text-align:right;">

statistic

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

gp

</th>

<th style="text-align:left;">

Method

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

0.4274166

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

119.302

</td>

<td style="text-align:right;">

63680

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

pearson

</td>

</tr>

</tbody>

</table>

**Example words**

High imputed funniness and high imputed iconicity: *whoosh, whirr,
whooshing, brr, argh, chomp, whir, swoosh, brrr, zaps, squeaks,
whirring, squelchy, gulps, smacking, growls, clanks, squish, whoo, clop*

Low imputed funniness and low imputed iconicity: *apr, dei, covenants,
palestinians, covenant, clothier, palestinian, variant, mitochondria,
israelis, serb, sufferers, herein, isotope, duration, ciudad, appellant,
palestine, alexandria, infantrymen*

High imputed funniness and low imputed iconicity: *pigs, monkeys, herr,
raja, franz, lulu, von, beau, caviar, penguins, elves, virgins,
lesbians, fez, amuse, hawaiian, hens, salami, perverts, gertrude*

Low imputed funniness and high imputed iconicity: *slashes, gunshots,
footstep, cries, footsteps, fade, froze, cr, swelter, crushing,
piercing, shoots, breathing, sobs, tremors, strokes, choking, slammed,
shocked, ng*

What about compound nouns here? In the top 200 nouns we can spot \~5
(*shockwave, doodlebug, flashbulb, backflip, footstep*) but that is of
course a tiny tail end of a much larger dataset than the earlier two.

A better way is to sample 200 random nouns from a proportionate slice of
the data, i.e. 200 \* 17.8 = 3560 top nouns in imputed iconicity. In
this subset we find at least 30 non-iconic analysable compounds:
*fireworm, deadbolt, footstep, pockmark, uppercut, woodwork, biotech,
notepad, spellbinder, henchmen, quicksands, blowgun, heartbreaks,
moonbeams, sketchpad*, et cetera.

``` r
words.setC %>% 
  filter(ico_imputed_perc > 9,
         POS == "Noun") %>%
  arrange(-ico_imputed) %>%
  slice(1:200) %>%
  dplyr::select(word) %>% unlist %>% unname() 

set.seed(1983)
words.setC %>% 
  filter(ico_imputed_perc > 9,
         POS == "Noun") %>%
  arrange(-ico_imputed) %>%
  slice(1:3560) %>%
  sample_n(200) %>%
  dplyr::select(word) %>% unlist %>% unname() 
```

### Structural properties of highly rated words

#### Log letter frequency

Mean iconicity and mean funniness are higher for lower log letter
frequency quantiles:

<table>

<caption>

Mean funniness and iconicity by log letter frequency quantiles

</caption>

<thead>

<tr>

<th style="text-align:right;">

logletterfreq\_perc

</th>

<th style="text-align:right;">

mean\_ico

</th>

<th style="text-align:right;">

mean\_fun

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1.2562724

</td>

<td style="text-align:right;">

2.510892

</td>

</tr>

<tr>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1.0972947

</td>

<td style="text-align:right;">

2.434144

</td>

</tr>

<tr>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.9435569

</td>

<td style="text-align:right;">

2.339590

</td>

</tr>

<tr>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

0.7677072

</td>

<td style="text-align:right;">

2.313565

</td>

</tr>

<tr>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.6163793

</td>

<td style="text-align:right;">

2.323666

</td>

</tr>

<tr>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0.7206575

</td>

<td style="text-align:right;">

2.286704

</td>

</tr>

<tr>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0.7950753

</td>

<td style="text-align:right;">

2.361308

</td>

</tr>

<tr>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.8434129

</td>

<td style="text-align:right;">

2.284869

</td>

</tr>

<tr>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

0.7531960

</td>

<td style="text-align:right;">

2.249879

</td>

</tr>

<tr>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

0.5100479

</td>

<td style="text-align:right;">

2.273432

</td>

</tr>

</tbody>

</table>

High-iconicity high-funniness words tend to have lower log letter
frequencies:

<table>

<caption>

Log letter frequency percentiles for upper quantiles of funniness +
iconicity

</caption>

<thead>

<tr>

<th style="text-align:left;">

word

</th>

<th style="text-align:right;">

fun

</th>

<th style="text-align:right;">

ico

</th>

<th style="text-align:right;">

diff\_rank

</th>

<th style="text-align:right;">

logletterfreq\_perc

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

zigzag

</td>

<td style="text-align:right;">

3.113636

</td>

<td style="text-align:right;">

4.300000

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

squeak

</td>

<td style="text-align:right;">

3.230769

</td>

<td style="text-align:right;">

4.230769

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

chirp

</td>

<td style="text-align:right;">

3.000000

</td>

<td style="text-align:right;">

4.142857

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

buzzer

</td>

<td style="text-align:right;">

2.833333

</td>

<td style="text-align:right;">

4.090909

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

pop

</td>

<td style="text-align:right;">

3.294118

</td>

<td style="text-align:right;">

4.076923

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

bleep

</td>

<td style="text-align:right;">

2.931818

</td>

<td style="text-align:right;">

3.928571

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

clunk

</td>

<td style="text-align:right;">

3.344828

</td>

<td style="text-align:right;">

3.928571

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

moo

</td>

<td style="text-align:right;">

3.700000

</td>

<td style="text-align:right;">

3.882353

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

4

</td>

</tr>

<tr>

<td style="text-align:left;">

clang

</td>

<td style="text-align:right;">

3.200000

</td>

<td style="text-align:right;">

3.857143

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

boom

</td>

<td style="text-align:right;">

2.829268

</td>

<td style="text-align:right;">

3.846154

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

bang

</td>

<td style="text-align:right;">

2.843750

</td>

<td style="text-align:right;">

3.833333

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

murmur

</td>

<td style="text-align:right;">

2.812500

</td>

<td style="text-align:right;">

3.833333

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

whirl

</td>

<td style="text-align:right;">

2.911765

</td>

<td style="text-align:right;">

3.818182

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crunch

</td>

<td style="text-align:right;">

2.857143

</td>

<td style="text-align:right;">

3.785714

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

rip

</td>

<td style="text-align:right;">

2.827586

</td>

<td style="text-align:right;">

3.736842

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

sludge

</td>

<td style="text-align:right;">

2.875000

</td>

<td style="text-align:right;">

3.700000

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

ping

</td>

<td style="text-align:right;">

2.875000

</td>

<td style="text-align:right;">

3.636364

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

oink

</td>

<td style="text-align:right;">

3.871795

</td>

<td style="text-align:right;">

3.615385

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:left;">

zoom

</td>

<td style="text-align:right;">

3.043478

</td>

<td style="text-align:right;">

3.600000

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

smooch

</td>

<td style="text-align:right;">

3.333333

</td>

<td style="text-align:right;">

3.600000

</td>

<td style="text-align:right;">

20

</td>

<td style="text-align:right;">

3

</td>

</tr>

</tbody>

</table>

Model comparison with funniness as the DV and log letter frequency as an
additional predictor shows that a model including log letter frequency
provides a significantly better fit.

**Model m4.1**: lm(formula = fun \~ logfreq + rt + ico, data = words
%\>% filter(set == , “A”))

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

36.143

</td>

<td style="text-align:right;">

258.779

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.155

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1.249

</td>

<td style="text-align:right;">

8.941

</td>

<td style="text-align:right;">

0.003

</td>

<td style="text-align:right;">

0.006

</td>

</tr>

<tr>

<td style="text-align:left;">

ico

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

8.891

</td>

<td style="text-align:right;">

63.661

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.043

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

197.628

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

**Model m4.2**: lm(formula = fun \~ logfreq + rt + ico + logletterfreq,
data = words %\>% , filter(set == “A”))

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

36.143

</td>

<td style="text-align:right;">

265.179

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.158

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1.249

</td>

<td style="text-align:right;">

9.162

</td>

<td style="text-align:right;">

0.003

</td>

<td style="text-align:right;">

0.006

</td>

</tr>

<tr>

<td style="text-align:left;">

ico

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

8.891

</td>

<td style="text-align:right;">

65.236

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.044

</td>

</tr>

<tr>

<td style="text-align:left;">

logletterfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4.906

</td>

<td style="text-align:right;">

35.994

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.025

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1414

</td>

<td style="text-align:right;">

192.722

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

197.6281

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

1414

</td>

<td style="text-align:right;">

192.7222

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4.905856

</td>

<td style="text-align:right;">

35.9942

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

Partial correlations show that funniness rating and log letter frequency
have a covariance of -15.7% controlling for iconicity, and that
iconicity and log letter frequency have a covariance of -16.3%
controlling for funniness ratings (all p \< 0.0001 correcting for
multiple comparisons).

<table>

<caption>

funniness and log letter frequency controlling for iconicity

</caption>

<thead>

<tr>

<th style="text-align:right;">

estimate

</th>

<th style="text-align:right;">

p.value

</th>

<th style="text-align:right;">

statistic

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

gp

</th>

<th style="text-align:left;">

Method

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

\-0.157001

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

\-5.982098

</td>

<td style="text-align:right;">

1419

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

pearson

</td>

</tr>

</tbody>

</table>

<table>

<caption>

iconicity and log letter frequency controlling for funniness

</caption>

<thead>

<tr>

<th style="text-align:right;">

estimate

</th>

<th style="text-align:right;">

p.value

</th>

<th style="text-align:right;">

statistic

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

gp

</th>

<th style="text-align:left;">

Method

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

\-0.1634579

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

\-6.234739

</td>

<td style="text-align:right;">

1419

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

pearson

</td>

</tr>

</tbody>

</table>

Model comparison for combined funniness and iconicity scores suggests
that having log letter frequency as a predictor significantly improves
fit over and above word frequency and lexical decision time.

**Model m5.1**: lm(formula = funico \~ logfreq + rt, data = words.setA)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

420.245

</td>

<td style="text-align:right;">

206.078

</td>

<td style="text-align:right;">

0.0

</td>

<td style="text-align:right;">

0.127

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5.516

</td>

<td style="text-align:right;">

2.705

</td>

<td style="text-align:right;">

0.1

</td>

<td style="text-align:right;">

0.002

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1416

</td>

<td style="text-align:right;">

2887.579

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

**Model m5.2**: lm(formula = funico \~ logfreq + rt + logletterfreq,
data = words.setA)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

420.245

</td>

<td style="text-align:right;">

219.963

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.135

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5.516

</td>

<td style="text-align:right;">

2.887

</td>

<td style="text-align:right;">

0.09

</td>

<td style="text-align:right;">

0.002

</td>

</tr>

<tr>

<td style="text-align:left;">

logletterfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

184.189

</td>

<td style="text-align:right;">

96.407

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.064

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

2703.390

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1416

</td>

<td style="text-align:right;">

2887.579

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

2703.390

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

184.1887

</td>

<td style="text-align:right;">

96.40745

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

#### Structural analysis

We carry out a qualitative analysis of the 80 highest ranked words (top
deciles for funniness+iconicity) to see if there are formal cues of
foregrounding and structural markedness that can help predict funniness
and iconicity ratings. Then we find these cues in the larger dataset and
see if the patterns hold up.

This analysis reveals the following sets of complex onsets, codas, and
verbal diminutive suffixes that are likely structural cues of markedness
(given here in the form of regular expressions):

  - onsets: `^(bl|cl|cr|dr|fl|sc|sl|sn|sp|spl|sw|tr|pr|sq)`
  - codas: `(nch|mp|nk|rt|rl|rr|sh|wk)$`
  - verbal suffix: `[b-df-hj-np-tv-xz]le)$`" (i.e., look for -le after a
    consonant)

We tag these cues across the whole dataset (looking for the *-le* suffix
only in verbs because words like *mutable, unnameable, scalable,
manacle* are not the same phenomenon) in order to see how they relate to
funniness and iconicity.

Model the contribution of markedness relative to logletter frequency.
Model comparison shows that a model including the measure of cumulative
markedness as predictor provides a significantly better fit (F = 52.78,
p \< 0.0001) and explains a larger portion of the variance (adjusted R2
= 0.21 vs. 0.18) than a model with just word frequency, lexical decision
time and log letter frequency.

**Model m5.3**: lm(formula = funico \~ logfreq + rt + logletterfreq +
cumulative, , data = words.setA)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

420.245

</td>

<td style="text-align:right;">

228.013

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.139

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5.516

</td>

<td style="text-align:right;">

2.993

</td>

<td style="text-align:right;">

0.084

</td>

<td style="text-align:right;">

0.002

</td>

</tr>

<tr>

<td style="text-align:left;">

logletterfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

184.189

</td>

<td style="text-align:right;">

99.936

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.066

</td>

</tr>

<tr>

<td style="text-align:left;">

cumulative

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

97.283

</td>

<td style="text-align:right;">

52.783

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.036

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

1414

</td>

<td style="text-align:right;">

2606.107

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

Model comparison of m5.2 and m5.3

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1415

</td>

<td style="text-align:right;">

2703.390

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

1414

</td>

<td style="text-align:right;">

2606.107

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

97.28312

</td>

<td style="text-align:right;">

52.78307

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

Now we trace cumulative markedness in the imputed portions of the
dataset, and do the same model comparison as above.

First have a look at a random sample of top imputed words and their
markedness:

<table>

<caption>

Cumulative markedness in a random sample of words from the highest
quantile of imputed iconicity

</caption>

<thead>

<tr>

<th style="text-align:left;">

word

</th>

<th style="text-align:right;">

ico\_imputed\_perc

</th>

<th style="text-align:right;">

ico\_imputed

</th>

<th style="text-align:right;">

cumulative

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

brr

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

4.065481

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

squish

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

3.570914

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

clunks

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.965891

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

scamp

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.397420

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

spank

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.360551

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

squoosh

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.312993

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crunk

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.165342

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

sw

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.898677

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

flipping

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.875252

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

flatly

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.819130

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

crumping

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.737702

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

flourish

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.722582

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crispy

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.721382

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

snappish

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.612547

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

flush

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.598260

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

scrumptious

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.491476

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

blank

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.435437

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

tramp

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.426469

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

speakeasy

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.393087

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

scornfully

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.366685

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

And at a random sample of words from lower quadrants and their
markedness:

<table>

<caption>

Cumulative markedness in a random sample of words from lower quantiles
of imputed iconicity

</caption>

<thead>

<tr>

<th style="text-align:left;">

word

</th>

<th style="text-align:right;">

ico\_imputed\_perc

</th>

<th style="text-align:right;">

ico\_imputed

</th>

<th style="text-align:right;">

cumulative

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

spoilsport

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0.7898544

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

draughted

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0.7022719

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

drank

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0.6164557

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

sweetfish

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0.5390918

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

protectress

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0.5275526

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

transmits

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.4734109

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

schrank

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.4676592

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

blamed

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.4105656

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

flatfish

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.3870658

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crystallised

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.3525224

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

trench

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

0.2827599

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

preshrunk

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.1581131

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

spectroscopic

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.1460491

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

splendours

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.0495967

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

prelaunch

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.0355877

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

spearfish

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0.0134083

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

flemish

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

\-0.0374782

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

flamingos

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

\-0.0452134

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

cryptography

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

\-0.1193397

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

triangulation

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

\-0.1590728

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

Looks like random samples of 20 high-complexity words always feature a
majority of high iconicity words:

<table>

<caption>

Imputed ratings for 20 random words high in cumulative markedness

</caption>

<thead>

<tr>

<th style="text-align:left;">

word

</th>

<th style="text-align:right;">

ico\_imputed\_perc

</th>

<th style="text-align:right;">

ico\_imputed

</th>

<th style="text-align:right;">

fun\_imputed

</th>

<th style="text-align:right;">

cumulative

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

squoosh

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.3129932

</td>

<td style="text-align:right;">

2.945588

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

squirt

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

2.1139378

</td>

<td style="text-align:right;">

3.302116

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crump

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.7575309

</td>

<td style="text-align:right;">

3.072162

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

snaffle

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.6898653

</td>

<td style="text-align:right;">

3.005494

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crank

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.6032802

</td>

<td style="text-align:right;">

2.772123

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

flush

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.5982598

</td>

<td style="text-align:right;">

2.668945

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

clump

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.5840648

</td>

<td style="text-align:right;">

2.744887

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

spangle

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.5792685

</td>

<td style="text-align:right;">

3.046803

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

scribble

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.5335878

</td>

<td style="text-align:right;">

2.832759

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

swink

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.5061947

</td>

<td style="text-align:right;">

3.015406

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

tramp

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

1.4264688

</td>

<td style="text-align:right;">

2.899633

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

slapdash

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

1.3323017

</td>

<td style="text-align:right;">

2.544342

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

prank

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.9101965

</td>

<td style="text-align:right;">

3.091282

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

crawfish

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.8564163

</td>

<td style="text-align:right;">

2.726631

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

sweetheart

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.8273857

</td>

<td style="text-align:right;">

2.711589

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

spinsterish

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0.5475747

</td>

<td style="text-align:right;">

2.329725

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

scrimp

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.4658493

</td>

<td style="text-align:right;">

2.534127

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

flatfish

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0.3870658

</td>

<td style="text-align:right;">

2.628965

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

prelaunch

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0.0355877

</td>

<td style="text-align:right;">

2.304523

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

scottish

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

\-0.2946582

</td>

<td style="text-align:right;">

2.556597

</td>

<td style="text-align:right;">

2

</td>

</tr>

</tbody>

</table>

Let’s have a closer look at subsets. First quadrants, then deciles.

<table>

<caption>

Markedness cues across quartiles of imputed iconicity

</caption>

<thead>

<tr>

<th style="text-align:right;">

target\_perc

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

onset

</th>

<th style="text-align:right;">

coda

</th>

<th style="text-align:right;">

verbdim

</th>

<th style="text-align:right;">

complexity

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

15920

</td>

<td style="text-align:right;">

0.0639447

</td>

<td style="text-align:right;">

0.0060302

</td>

<td style="text-align:right;">

0.0003769

</td>

<td style="text-align:right;">

0.0703518

</td>

</tr>

<tr>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

15920

</td>

<td style="text-align:right;">

0.0731784

</td>

<td style="text-align:right;">

0.0076005

</td>

<td style="text-align:right;">

0.0009422

</td>

<td style="text-align:right;">

0.0817211

</td>

</tr>

<tr>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

15920

</td>

<td style="text-align:right;">

0.0923367

</td>

<td style="text-align:right;">

0.0097362

</td>

<td style="text-align:right;">

0.0009422

</td>

<td style="text-align:right;">

0.1030151

</td>

</tr>

<tr>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

15920

</td>

<td style="text-align:right;">

0.1583543

</td>

<td style="text-align:right;">

0.0155151

</td>

<td style="text-align:right;">

0.0049623

</td>

<td style="text-align:right;">

0.1788317

</td>

</tr>

</tbody>

</table>

<table>

<caption>

Markedness cues across deciles of imputed iconicity

</caption>

<thead>

<tr>

<th style="text-align:right;">

target\_perc

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

onset

</th>

<th style="text-align:right;">

coda

</th>

<th style="text-align:right;">

verbdim

</th>

<th style="text-align:right;">

complexity

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0565327

</td>

<td style="text-align:right;">

0.0061244

</td>

<td style="text-align:right;">

0.0003141

</td>

<td style="text-align:right;">

0.0629711

</td>

</tr>

<tr>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0684673

</td>

<td style="text-align:right;">

0.0045540

</td>

<td style="text-align:right;">

0.0004711

</td>

<td style="text-align:right;">

0.0734925

</td>

</tr>

<tr>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0714510

</td>

<td style="text-align:right;">

0.0084799

</td>

<td style="text-align:right;">

0.0001570

</td>

<td style="text-align:right;">

0.0800879

</td>

</tr>

<tr>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0675251

</td>

<td style="text-align:right;">

0.0069095

</td>

<td style="text-align:right;">

0.0010992

</td>

<td style="text-align:right;">

0.0755339

</td>

</tr>

<tr>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0788317

</td>

<td style="text-align:right;">

0.0080088

</td>

<td style="text-align:right;">

0.0012563

</td>

<td style="text-align:right;">

0.0880967

</td>

</tr>

<tr>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0819724

</td>

<td style="text-align:right;">

0.0078518

</td>

<td style="text-align:right;">

0.0006281

</td>

<td style="text-align:right;">

0.0904523

</td>

</tr>

<tr>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.0978329

</td>

<td style="text-align:right;">

0.0105214

</td>

<td style="text-align:right;">

0.0010992

</td>

<td style="text-align:right;">

0.1094535

</td>

</tr>

<tr>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.1103957

</td>

<td style="text-align:right;">

0.0111495

</td>

<td style="text-align:right;">

0.0025126

</td>

<td style="text-align:right;">

0.1240578

</td>

</tr>

<tr>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.1350503

</td>

<td style="text-align:right;">

0.0144472

</td>

<td style="text-align:right;">

0.0028266

</td>

<td style="text-align:right;">

0.1523241

</td>

</tr>

<tr>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

6368

</td>

<td style="text-align:right;">

0.2014761

</td>

<td style="text-align:right;">

0.0191583

</td>

<td style="text-align:right;">

0.0076947

</td>

<td style="text-align:right;">

0.2283291

</td>

</tr>

</tbody>

</table>

Comparison of models with combined imputed funniness and iconicity as a
dependent variable shows that a linear model including cumulative
markedness as predictor provides a significantly better fit (F1,19230 =
337.3, p \< 0.0001) and explains a little bit more the variance
(adjusted R2 = 0.124 vs. 0.109) than a model with just word frequency,
lexical decision time and log letter frequency.

**Model m5.4**: lm(formula = funico\_imputed \~ logfreq + rt +
logletterfreq, data = words.setC)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1025.303

</td>

<td style="text-align:right;">

361.774

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.018

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4.778

</td>

<td style="text-align:right;">

1.686

</td>

<td style="text-align:right;">

0.194

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

<tr>

<td style="text-align:left;">

logletterfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5608.765

</td>

<td style="text-align:right;">

1979.029

</td>

<td style="text-align:right;">

0.000

</td>

<td style="text-align:right;">

0.093

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

19203

</td>

<td style="text-align:right;">

54423.210

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

**Model m5.5**: lm(formula = funico\_imputed \~ logfreq + rt +
logletterfreq + , cumulative, data = words.setC)

<table>

<thead>

<tr>

<th style="text-align:left;">

predictor

</th>

<th style="text-align:right;">

df

</th>

<th style="text-align:right;">

SS

</th>

<th style="text-align:right;">

\(F\)

</th>

<th style="text-align:right;">

\(p\)

</th>

<th style="text-align:right;">

partial \(\eta^2\)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

logfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1025.303

</td>

<td style="text-align:right;">

368.110

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.019

</td>

</tr>

<tr>

<td style="text-align:left;">

rt

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4.778

</td>

<td style="text-align:right;">

1.716

</td>

<td style="text-align:right;">

0.19

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

<tr>

<td style="text-align:left;">

logletterfreq

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5608.765

</td>

<td style="text-align:right;">

2013.687

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.095

</td>

</tr>

<tr>

<td style="text-align:left;">

cumulative

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

939.486

</td>

<td style="text-align:right;">

337.299

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.017

</td>

</tr>

<tr>

<td style="text-align:left;">

Residuals

</td>

<td style="text-align:right;">

19202

</td>

<td style="text-align:right;">

53483.724

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

</tbody>

</table>

<table>

<caption>

model comparison

</caption>

<thead>

<tr>

<th style="text-align:right;">

Res.Df

</th>

<th style="text-align:right;">

RSS

</th>

<th style="text-align:right;">

Df

</th>

<th style="text-align:right;">

Sum of Sq

</th>

<th style="text-align:right;">

F

</th>

<th style="text-align:right;">

Pr(\>F)

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

19203

</td>

<td style="text-align:right;">

54423.21

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

<td style="text-align:right;">

</td>

</tr>

<tr>

<td style="text-align:right;">

19202

</td>

<td style="text-align:right;">

53483.72

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

939.4858

</td>

<td style="text-align:right;">

337.299

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

## End

Thanks for your interest. If you find this useful, consider checking out
the following resources that have been helpful in preparing this
Rmarkdown document:

  - Two of my own past projects (remember, the person most grateful for
    your well-documented past code is future you):
      - [Expressiveness and grammatical
        integration](http://ideophone.org/collab/expint/) (by Mark
        Dingemanse)
      - [Coloured vowels: open data and
        code](https://github.com/mdingemanse/colouredvowels/blob/master/BRM_colouredvowels_opendata.md)
        (by Mark Dingemanse & Christine Cuskley)
  - [Formatting ANOVA tables in
    R](http://www.understandingdata.net/2017/05/11/anova-tables-in-r/)
    (by Rose Hartman, Understanding Data)
  - [Iconicity in the speech of children and
    adults](https://github.com/bodowinter/iconicity_acquisition) (by
    Bodo Winter)
  - [English letter
    frequencies](http://practicalcryptography.com/cryptanalysis/letter-frequencies-various-languages/english-letter-frequencies/)

And of course have a look at the paper itself — latest preprint here:
[Playful iconicity](https://psyarxiv.com/9ak7e/)
