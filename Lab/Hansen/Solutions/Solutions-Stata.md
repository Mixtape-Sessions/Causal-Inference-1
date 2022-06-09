
# Hansen DWI Replication

**Directions:** Download `hansen_dwi.dta` from GitHub at the following
address. Note these data are not exactly the same as his because of
confidentiality issues (so he couldn’t share all of it).

<https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi.dta>

The outcome variable is `recidivism` which is measuring whether the
person showed back up in the data within 4 months. Use this data to
answer the following questions.

``` stata
******************************************************************************************
* name: hansen.do
* author: scott cunningham (baylor)
* description: replicate figures and tables in Hansen 2015 AER
* last updated: december 5, 2021
******************************************************************************************
* load the data from github
use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear

* Re-center our running variable at bac1=0.08
ren bac1 bac1_old
gen bac1=bac1_old-0.08
```

1.  We will only focus on the 0.08 BAC cutoff; not the 0.15 cutoff. Take
    the following steps.
    -   Create a treatment variable (`dui`) equaling 1 if `bac1 >= 0.08`
        and 0 otherwise in your do/R file.
    -   Replicate Hansen’s Figure 1 examining whether there is any
        evidence for manipulation on the running variable. Produce a raw
        histogram using `bac1`, then use the density test in Cattaneo,
        Titunik and Farrell’s `rddensity` package. Can you find any
        evidence for manipulation? What about heaping?

``` stata
* Q1a: create some treatment variable for bac1>=0.08
gen dui = 0
replace dui = 1 if bac1_old>=0.08 & bac1~=. // Stata when it sees a period (missing) in a variable it 
// thinks that that observation is equal to positive infinity. And so since positive infinity
// is greater than 0.08, it will assign dui = 1 for that missing value which can create
// major problems. 
```

    (191,548 real changes made)

``` stata
* Q1b: Find evidence for manipulation or HEAPING using histograms
histogram bac1, discrete width(0.001) ytitle(Density) xtitle(Running variable (blood alcohol content)) xline(0.0) title(Density of observations across the running variable)
```

    (start=-.08, width=.001)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)

![](graph1.svg)

``` stata
* use the Cattaneo, et al. -rddensity-
rddensity bac1, c(0.0) plot
```

    Computing data-driven bandwidth selectors.

    Point estimates and standard errors have been adjusted for repeated observations.
    (Use option nomasspoints to suppress this adjustment.)

    RD Manipulation test using local polynomial density estimation.

         c =     0.000 | Left of c  Right of c          Number of obs =       214558
    -------------------+----------------------          Model         = unrestricted
         Number of obs |     23010      191548          BW method     =         comb
    Eff. Number of obs |     14727       28946          Kernel        =   triangular
        Order est. (p) |         2           2          VCE method    =    jackknife
        Order bias (q) |         3           3
           BW est. (h) |     0.023       0.023

    Running variable: bac1.
    ------------------------------------------
                Method |      T          P>|T|
    -------------------+----------------------
                Robust |   -0.1387      0.8897
    ------------------------------------------

    P-values of binomial tests. (H0: prob = .5)
    -----------------------------------------------------
     Window Length / 2 |       <c         >=c |     P>|T|
    -------------------+----------------------+----------
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
    -----------------------------------------------------
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style eltblue * .8 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style black * .9 not found in class color, default attributes used)
    (note:  named style black * .9 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)

![](graph2.svg)

2.  Recreate Table 2 Panel A but only `white`, `male`, age (`aged`) and
    accident (`acc`) as dependent variables. Use your equation 1) for
    this. Are the covariates balanced at the cutoff? Use two separate
    bandwidths (0.03 to 0.13; 0.055 to 0.105) for estimation.

``` stata
* Q2: Table 2 on white, male, aged, and acc
* yi = Xi′γ + α1DUIi + α2BACi + α3BACi × DUIi + ui
* Are the covariates balanced at the cutoff? Use two separate bandwidths (0.03 to 0.13; 0.055 to 0.105) 

reg white dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg male dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg acc dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg aged dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
```

    Linear regression                               Number of obs     =     89,967
                                                    F(3, 89963)       =       3.80
                                                    Prob > F          =     0.0098
                                                    R-squared         =     0.0001
                                                    Root MSE          =     .35452

    ------------------------------------------------------------------------------
                 |               Robust
           white |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |   .0057037   .0050081     1.14   0.255    -.0041122    .0155197
            bac1 |   .0787543   .2142164     0.37   0.713    -.3411078    .4986163
                 |
      dui#c.bac1 |
              1  |   .0156179   .2339552     0.07   0.947    -.4429319    .4741678
                 |
           _cons |   .8462753   .0040898   206.93   0.000     .8382594    .8542912
    ------------------------------------------------------------------------------


    Linear regression                               Number of obs     =     89,967
                                                    F(3, 89963)       =       1.50
                                                    Prob > F          =     0.2120
                                                    R-squared         =     0.0001
                                                    Root MSE          =     .40598

    ------------------------------------------------------------------------------
                 |               Robust
            male |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |   .0061842   .0057036     1.08   0.278    -.0049948    .0173633
            bac1 |    -.20997   .2397792    -0.88   0.381     -.679935    .2599949
                 |
      dui#c.bac1 |
              1  |   .3070719   .2632392     1.17   0.243    -.2088744    .8230182
                 |
           _cons |   .7842362   .0046297   169.39   0.000     .7751619    .7933104
    ------------------------------------------------------------------------------


    Linear regression                               Number of obs     =     89,967
                                                    F(3, 89963)       =      44.02
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0015
                                                    Root MSE          =     .30138

    ------------------------------------------------------------------------------
                 |               Robust
             acc |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |  -.0033503   .0040615    -0.82   0.409    -.0113109    .0046102
            bac1 |  -1.095895   .1863283    -5.88   0.000    -1.461097   -.7306937
                 |
      dui#c.bac1 |
              1  |   1.888365   .2030573     9.30   0.000     1.490374    2.286355
                 |
           _cons |   .0834312   .0032967    25.31   0.000     .0769698    .0898927
    ------------------------------------------------------------------------------


    Linear regression                               Number of obs     =     89,967
                                                    F(3, 89963)       =      62.95
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0023
                                                    Root MSE          =     11.573

    ------------------------------------------------------------------------------
                 |               Robust
            aged |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |  -.1404517   .1643506    -0.85   0.393    -.4625773    .1816738
            bac1 |  -69.16367    7.22027    -9.58   0.000    -83.31533   -55.01201
                 |
      dui#c.bac1 |
              1  |   76.04933   7.843989     9.70   0.000     60.67519    91.42348
                 |
           _cons |   33.91989    .134631   251.95   0.000     33.65602    34.18377
    ------------------------------------------------------------------------------

3.  Recreate Figure 2 panel A-D. Fit a picture using linear and
    separately quadratic with confidence intervals.

``` stata
* Q3: Create Figure 2 panel A-D using cmogram on our covariates (white, male, age, acc)
* cmogram outcome running variable, cut(cutoff) scatter line(cutoff) polynomial
quietly cmogram white bac1, cut(0.0) scatter line(0.0)
quietly cmogram white bac1, cut(0.0) scatter line(0.0) lfitci
quietly cmogram white bac1, cut(0.0) scatter line(0.0) qfitci
```

    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)


    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)

![](graph3.svg) ![](graph4.svg) ![](graph5.svg)

``` stata
* scatter
twoway (scatter white bac1  if bac1_old>=0.03 & bac1_old<=0.13, sort) if bac1_old>=0.03 & bac1_old<=0.13, ytitle(White means) xtitle(Blood alcohol content running variable) xline(0.08) title(Covariate test on whites) note(Cutoff is at blood alcohol content of 0.08)
```

    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)

![](graph6.svg)

``` stata
* binscatter
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui)
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui) line(qfit)
```

    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)

![](graph7.svg) ![](graph8.svg) ![](graph9.svg)

4.  Estimate equation (1) with recidivism (`recid`) as the outcome. This
    corresponds to Table 3 column 1, but since I am missing some of his
    variables, your sample size will be the entire dataset of 214,558.
    Nevertheless, replicate Table 3, column 1, Panels A and B. Note that
    these are local linear regressions and Panel A uses as its bandwidth
    0.03 to 0.13. But Panel B has a narrower bandwidth of 0.055 to
    0.105. Your table should have three columns and two A and B panels
    associated with the different bandwidths.:
    -   Column 1: control for the `bac1` linearly

-   Column 2: interact `bac1` with cutoff linearly
-   Column 3: interact `bac1` with cutoff linearly and as a quadratic
-   For all analysis, estimate uncertainty using heteroskedastic robust
    standard errors. \[ed: But if you want to show off, use Kolesár and
    Rothe’s 2018 “honest” confidence intervals (only available in R).\]

``` stata
* Q4a: Our main results. regression of recidivism onto the equation (1) model with linear bac1. 
reg recidivism dui bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q4b: Our main results. regression of recidivism onto the equation (1) model with interacted linear bac1. 
reg recidivism dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q4c: Our main results. regression of recidivism onto the equation (1) model with interacted linear and quadratic bac1. 
gen bac1_squared = bac1^2
reg recidivism dui##c.(bac1 bac1_squared) if bac1_old>=0.03 & bac1_old<=0.13, robust
```

    Linear regression                               Number of obs     =     89,967
                                                    F(2, 89964)       =      22.10
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0005
                                                    Root MSE          =     .30896

    ------------------------------------------------------------------------------
                 |               Robust
      recidivism |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
             dui |  -.0265852   .0040402    -6.58   0.000    -.0345039   -.0186664
            bac1 |   .3311663   .0748867     4.42   0.000     .1843891    .4779434
           _cons |   .1218405   .0025842    47.15   0.000     .1167755    .1269054
    ------------------------------------------------------------------------------


    Linear regression                               Number of obs     =     89,967
                                                    F(3, 89963)       =      16.16
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0005
                                                    Root MSE          =     .30896

    ------------------------------------------------------------------------------
                 |               Robust
      recidivism |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |  -.0236156   .0043611    -5.42   0.000    -.0321632   -.0150679
            bac1 |   .0058758   .1869112     0.03   0.975    -.3604684    .3722199
                 |
      dui#c.bac1 |
              1  |   .3915569   .2039907     1.92   0.055     -.008263    .7913768
                 |
           _cons |    .117067   .0036053    32.47   0.000     .1100006    .1241333
    ------------------------------------------------------------------------------



    Linear regression                               Number of obs     =     89,967
                                                    F(5, 89961)       =      10.43
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0006
                                                    Root MSE          =     .30896

    ------------------------------------------------------------------------------------
                       |               Robust
            recidivism |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------------+----------------------------------------------------------------
                 1.dui |  -.0143164   .0062329    -2.30   0.022    -.0265329      -.0021
                  bac1 |  -.9996903   .6023927    -1.66   0.097    -2.180374    .1809935
          bac1_squared |  -24.61442   13.77078    -1.79   0.074    -51.60502    2.376178
                       |
            dui#c.bac1 |
                    1  |    1.01584   .6902344     1.47   0.141    -.3370126    2.368693
                       |
    dui#c.bac1_squared |
                    1  |   31.87052   15.13755     2.11   0.035     2.201073    61.53997
                       |
                 _cons |    .111337   .0048742    22.84   0.000     .1017835    .1208905
    ------------------------------------------------------------------------------------

5.  Repeat but drop units in the close vicinity of 0.08 (0.079-0.081)
    (i.e., the “donut hole” regression).

``` stata
* Q5: "donut hole" dropping close to 0.08 (we'll discuss why later)
preserve
drop if bac1_old>=0.079 & bac1_old<=0.081
reg recidivism dui##c.(bac1) if bac1_old>=0.03 & bac1_old<=0.13, robust
rdrobust recidivism bac1, c(0.0) p(1) bwselect(msetwo) all
```

    (1,882 observations deleted)


    Linear regression                               Number of obs     =     88,085
                                                    F(3, 88081)       =      16.13
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0006
                                                    Root MSE          =     .30882

    ------------------------------------------------------------------------------
                 |               Robust
      recidivism |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.dui |  -.0251374   .0047988    -5.24   0.000    -.0345429   -.0157318
            bac1 |   .0658608   .2024701     0.33   0.745    -.3309787    .4627003
                 |
      dui#c.bac1 |
              1  |   .3315719   .2183359     1.52   0.129    -.0963645    .7595083
                 |
           _cons |   .1185888    .004124    28.76   0.000     .1105057    .1266718
    ------------------------------------------------------------------------------

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     212676
    -------------------+----------------------            BW type       =     msetwo
         Number of obs |     21128      191548            Kernel        = Triangular
    Eff. Number of obs |     13136       77539            VCE method    =         NN
        Order est. (p) |         1           1
        Order bias (q) |         2           2
           BW est. (h) |     0.024       0.054
           BW bias (b) |     0.040       0.086
             rho (h/b) |     0.619       0.633
            Unique obs |        79         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.02108     .00664   -3.1748  0.001     -.0341     -.008068
        Bias-corrected | -.02202     .00664   -3.3163  0.001    -.03504     -.009008
                Robust | -.02202     .00848   -2.5985  0.009   -.038636     -.005412
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

6.  Recreate the top panel of Figure 3 according to the following rule:
    -   Fit linear fit using only observations with less than 0.15 BAC
        on the `bac1`
    -   Fit quadratic fit using only observations with less than 0.15
        BAC on the `bac1`
    -   Use `rdplot` to do the same.

``` stata
* Q6: Figure 3 using less than 0.15 bac on the bac1
quietly cmogram recidivism bac1, cut(0.0) scatter line(0.0) lfitci
quietly cmogram recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, cut(0.0) scatter line(0.0) lfitci
quietly cmogram recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, cut(0.0) scatter line(0.0) qfitci
```

    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)

![](graph10.svg) ![](graph11.svg) ![](graph12.svg)

``` stata
binscatter recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui)
binscatter recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui) line(qfit)
```

    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)

![](graph13.svg) ![](graph14.svg)

7.  Estimate local polynomial regressions with triangular kernel and
    bias correction using `rdrobust`. Experiment with other kernels and
    polynomials.

``` stata
* Q7: Local polynomial regressions with (default) triangular kernel and bias correction
rdrobust recidivism bac1, p(1) c(0.0)
rdrobust recidivism bac1, p(1) c(0.0) kernel(uniform)
rdrobust recidivism bac1, p(1) c(0.0) kernel(epanechnikov)
```

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        = Triangular
    Eff. Number of obs |     16574       41013            VCE method    =         NN
        Order est. (p) |         1           1
        Order bias (q) |         2           2
           BW est. (h) |     0.031       0.031
           BW bias (b) |     0.050       0.050
             rho (h/b) |     0.633       0.633
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.01826     .00567   -3.2203  0.001   -.029376     -.007147
                Robust |     -          -     -2.5025  0.012   -.029963     -.003643
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        =    Uniform
    Eff. Number of obs |     13794       24555            VCE method    =         NN
        Order est. (p) |         1           1
        Order bias (q) |         2           2
           BW est. (h) |     0.020       0.020
           BW bias (b) |     0.035       0.035
             rho (h/b) |     0.580       0.580
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional |   -.017     .00629   -2.7017  0.007   -.029325     -.004666
                Robust |     -          -     -2.2894  0.022   -.031834     -.002468
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        = Epanechnikov
    Eff. Number of obs |     16195       37939            VCE method    =         NN
        Order est. (p) |         1           1
        Order bias (q) |         2           2
           BW est. (h) |     0.029       0.029
           BW bias (b) |     0.049       0.049
             rho (h/b) |     0.601       0.601
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.01835     .00568   -3.2280  0.001   -.029492     -.007208
                Robust |     -          -     -2.5188  0.012   -.030063     -.003751
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

``` stata
* Higher order polynomials
rdrobust recidivism bac1, p(2) c(0.0)
rdrobust recidivism bac1, p(3) c(0.0)
rdrobust recidivism bac1, p(4) c(0.0)
```

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        = Triangular
    Eff. Number of obs |     17545       50370            VCE method    =         NN
        Order est. (p) |         2           2
        Order bias (q) |         3           3
           BW est. (h) |     0.038       0.038
           BW bias (b) |     0.050       0.050
             rho (h/b) |     0.750       0.750
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.01762     .00748   -2.3544  0.019   -.032283     -.002951
                Robust |     -          -     -2.1374  0.033   -.034943     -.001513
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        = Triangular
    Eff. Number of obs |     17825       53491            VCE method    =         NN
        Order est. (p) |         3           3
        Order bias (q) |         4           4
           BW est. (h) |     0.039       0.039
           BW bias (b) |     0.049       0.049
             rho (h/b) |     0.801       0.801
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.01716     .00958   -1.7911  0.073   -.035932      .001618
                Robust |     -          -     -1.5725  0.116   -.037595      .004124
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

    Mass points detected in the running variable.

    Sharp RD estimates using local polynomial regression.

          Cutoff c = 0 | Left of c  Right of c            Number of obs =     214558
    -------------------+----------------------            BW type       =      mserd
         Number of obs |     23010      191548            Kernel        = Triangular
    Eff. Number of obs |     17936       55055            VCE method    =         NN
        Order est. (p) |         4           4
        Order bias (q) |         5           5
           BW est. (h) |     0.040       0.040
           BW bias (b) |     0.050       0.050
             rho (h/b) |     0.816       0.816
            Unique obs |        81         318

    Outcome: recidivism. Running variable: bac1.
    --------------------------------------------------------------------------------
                Method |   Coef.    Std. Err.    z     P>|z|    [95% Conf. Interval]
    -------------------+------------------------------------------------------------
          Conventional | -.01324     .01168   -1.1336  0.257   -.036121      .009648
                Robust |     -          -     -0.9290  0.353    -.03678      .013126
    --------------------------------------------------------------------------------
    Estimates adjusted for mass points in the running variable.

<!-- Can't get to work right now -->
<!-- ![](graph15.svg) -->
<!-- ![](graph16.svg) -->

``` stata
* McCrary density test: remember it's a density test *on the running variable* (lagdemvoteshare)
rddensity bac1, c(0.0) plot
```

    Computing data-driven bandwidth selectors.

    Point estimates and standard errors have been adjusted for repeated observations.
    (Use option nomasspoints to suppress this adjustment.)

    RD Manipulation test using local polynomial density estimation.

         c =     0.000 | Left of c  Right of c          Number of obs =       214558
    -------------------+----------------------          Model         = unrestricted
         Number of obs |     23010      191548          BW method     =         comb
    Eff. Number of obs |     14727       28946          Kernel        =   triangular
        Order est. (p) |         2           2          VCE method    =    jackknife
        Order bias (q) |         3           3
           BW est. (h) |     0.023       0.023

    Running variable: bac1.
    ------------------------------------------
                Method |      T          P>|T|
    -------------------+----------------------
                Robust |   -0.1387      0.8897
    ------------------------------------------

    P-values of binomial tests. (H0: prob = .5)
    -----------------------------------------------------
     Window Length / 2 |       <c         >=c |     P>|T|
    -------------------+----------------------+----------
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
                 0.000 |      909           0 |    0.0000
    -----------------------------------------------------
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red * 1.2 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style red % 20 not found in class color, default attributes used)
    (note:  named style eltblue * .8 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style blue % 20 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style red % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style black * .9 not found in class color, default attributes used)
    (note:  named style black * .9 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style blue % 30 not found in class color, default attributes used)
    (note:  named style white % 0 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)
    (note:  named style cyan * 1.2 not found in class color, default attributes used)

![](graph17.svg)
