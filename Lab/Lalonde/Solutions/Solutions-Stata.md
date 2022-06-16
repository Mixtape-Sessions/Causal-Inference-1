
# Lalonde

This dataset is one of the most commonly used dataset in econometrics
based on [Lalonde
(1986)](https://econpapers.repec.org/article/aeaaecrev/v_3a76_3ay_3a1986_3ai_3a4_3ap_3a604-20.htm)
and [Dehejia and Wahba
(2002)](https://www.uh.edu/~adkugler/Dehejia&Wahba.pdf). Both the paper
by Lalonde and Dehejia and Wahba both wanted to evaluate causal
inference methods using non-experimental data. Cleverly, they start with
an experimental dataset to estimate the ‘true’ causal effect and then
use non-experimental data to evaluate an econometric method.

Our two datasets are:

1.  `https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta`
    which contains data from an experimental sample. In the sample,
    individuals are offered a job training program and we want to
    evaluate the effect on future earnings `re78` (real-earnings in
    1978).

2.  `https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta`
    which contains data from the CPS.

## Part 1: Experimental vs. Observational Analysis

1.  We will first perform analysis on the experimental dataset
    `https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta`

``` stata
use "https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta", clear
* ssc install cem
```

1.  Estimate the effect of treatment, `treat`, on real-earnings in 1978,
    `re78`. This will be the “true” treatment effect estimate that we
    will try to recreate with the non-experimental CPS sample.

``` stata
*-> Estimate treatment effect
reg re78 i.treat, r
```

    Linear regression                               Number of obs     =        445
                                                    F(1, 443)         =       7.15
                                                    Prob > F          =     0.0078
                                                    R-squared         =     0.0178
                                                    Root MSE          =     6579.5

    ------------------------------------------------------------------------------
                 |               Robust
            re78 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
         1.treat |   1794.342   670.8245     2.67   0.008     475.9486    3112.736
           _cons |   4554.801   340.2038    13.39   0.000     3886.187    5223.415
    ------------------------------------------------------------------------------

2.  Further, show baseline covariate balance on the following variables:
    `re74`, `re75`, `marr`, `educ`, `age`, `black`, `hisp`.

``` stata
*-> Baseline Covariate Balance
foreach y of varlist re74 re75 marr educ age black hisp {
  qui reg `y' i.treat, r
  est store `y'
}
est tab *, keep(1.treat) se
```

        Variable |    re74         re75         marr         educ         age         black         hisp     
    -------------+-------------------------------------------------------------------------------------------
         1.treat | -11.452958     265.1463    .03534304    .25748441    .76237006    .01632017   -.04823285  
                 |  503.45874    304.99978    .03654939     .1785001    .68423765    .03564668    .02597923  
    ---------------------------------------------------------------------------------------------------------
                                                                                                 legend: b/se

2.  Now, take the treated units from the `nsw` dataset and append to it
    the CPS control sample
    `https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta`.
    Perform a simple difference-in-means on the combined dataset to
    estimate the treatment effect with no control group adjustment.

``` stata
*-> Append in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
drop if treat==0
append using "https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta"
```

    (260 observations deleted)

``` stata
*-> "Treatment" effect
reg re78 i.treat, r
```

    Linear regression                               Number of obs     =     16,177
                                                    F(1, 16175)       =     213.24
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.0087
                                                    Root MSE          =       9629

    ------------------------------------------------------------------------------
                 |               Robust
            re78 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
         1.treat |  -8497.516   581.9158   -14.60   0.000    -9638.135   -7356.897
           _cons |   14846.66   76.29073   194.61   0.000     14697.12     14996.2
    ------------------------------------------------------------------------------

## Part 2: Selection on Observable Methods

1.  Fit a propensity score (logit) model using the following covariates
    `age + agesq + agecube + educ + educsq + marr + nodegree + black + hisp + re74 + re75 + u74 + u75`,
    where `u74` and `u75` are indicators for being unemployed in 1974
    and 1975 (`re74`/`re75` = 0). Take those weights and calculate the
    inverse propensity-score weights and use these weights in a simple
    regression of `re78` on the treatment dummy, `treat`.

``` stata
*-> Create variables
gen agesq = age^2
gen agecube = age^3
gen edusq = educ^2
gen u74 = (re74 == 0)
gen u75 = (re75 == 0)

*-> 1. Inverse propensity score weighting
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75

* predict propensity score
predict pscore

* Poor propensity score match
* hist pscore, by(treat)

* inverse propensity score weights
gen inv_ps_weight = treat * 1/pscore + (1-treat)*1/(1-pscore)
```

    Iteration 0:   log likelihood = -1011.0713  
    Iteration 1:   log likelihood = -622.44491  
    Iteration 2:   log likelihood = -441.45525  
    Iteration 3:   log likelihood = -410.74564  
    Iteration 4:   log likelihood = -407.21264  
    Iteration 5:   log likelihood = -407.18136  
    Iteration 6:   log likelihood = -407.18136  

    Logistic regression                             Number of obs     =     16,177
                                                    LR chi2(13)       =    1207.78
                                                    Prob > chi2       =     0.0000
    Log likelihood = -407.18136                     Pseudo R2         =     0.5973

    ------------------------------------------------------------------------------
           treat |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
             age |   2.370112   .3467711     6.83   0.000     1.690454    3.049771
           agesq |   -.066071   .0110491    -5.98   0.000    -.0877268   -.0444152
         agecube |   .0005616   .0001106     5.08   0.000     .0003448    .0007785
            educ |   .9026219   .2517539     3.59   0.000     .4091933    1.396051
           edusq |  -.0528026   .0134422    -3.93   0.000    -.0791489   -.0264563
            marr |  -1.524701   .2496259    -6.11   0.000    -2.013959   -1.035444
        nodegree |   .8970794    .328123     2.73   0.006     .2539701    1.540189
           black |   3.829216   .2657018    14.41   0.000      3.30845    4.349982
            hisp |    1.66281   .4068256     4.09   0.000      .865447    2.460174
            re74 |   .0000256   .0000308     0.83   0.405    -.0000347     .000086
            re75 |  -.0001992   .0000391    -5.09   0.000    -.0002759   -.0001224
             u74 |   1.778029   .2895587     6.14   0.000     1.210505    2.345554
             u75 |   .0150168   .2571788     0.06   0.953    -.4890443    .5190779
           _cons |  -34.78074    3.77135    -9.22   0.000    -42.17245   -27.38903
    ------------------------------------------------------------------------------
    Note: 12 failures and 0 successes completely determined.

    (option pr assumed; Pr(treat))

``` stata
reg re78 i.treat [aw=inv_ps_weight], r
```

    (sum of wgt is   2.2406e+04)

    Linear regression                               Number of obs     =     16,177
                                                    F(1, 16175)       =      22.22
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.1048
                                                    Root MSE          =       8878

    ------------------------------------------------------------------------------
                 |               Robust
            re78 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
         1.treat |  -6784.387   1439.237    -4.71   0.000    -9605.451   -3963.322
           _cons |   14722.91   78.40934   187.77   0.000     14569.22     14876.6
    ------------------------------------------------------------------------------

2.  Note that the previous estimate was still negative. That is because
    we have extremem values for pscore. For example, a control unit with
    pscore $=0.0001$ receives a huge weight: $(1/0.0001) = 1000$. Trim
    the data to observations with pscore $> 0.1$ and $< 0.9$ and
    reestimate the inverse propensity-score weighted regression of
    `re78` on `treat`.

``` stata
*-> 2. Inverese propensity score weighting with trimming
preserve
drop if pscore < 0.1 | pscore > 0.9
reg re78 i.treat [aw=inv_ps_weight], r
restore
```

    (15,807 observations deleted)

    (sum of wgt is   7.6571e+02)

    Linear regression                               Number of obs     =        370
                                                    F(1, 368)         =       3.26
                                                    Prob > F          =     0.0718
                                                    R-squared         =     0.0111
                                                    Root MSE          =       6405

    ------------------------------------------------------------------------------
                 |               Robust
            re78 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
         1.treat |   1350.894   748.0434     1.81   0.072    -120.0822     2821.87
           _cons |   4385.504   417.8374    10.50   0.000     3563.855    5207.152
    ------------------------------------------------------------------------------

3.  Using (i) 1:1 nearest-neighbor propensity-score matching with
    replacement and (ii) coarsened exact matching, estimate a treatment
    effect. You should use the same covariates as part b.

``` stata
*-> 3. Propensity Score Matching
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75, logit), atet gen(ps_cps) nn(1)
```

    Treatment-effects estimation                   Number of obs      =     16,177
    Estimator      : propensity-score matching     Matches: requested =          1
    Outcome model  : matching                                     min =          1
    Treatment model: logit                                        max =          9
    ------------------------------------------------------------------------------
                 |              AI Robust
            re78 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
    ATET         |
           treat |
       (1 vs 0)  |   1727.186   761.7544     2.27   0.023     234.1744    3220.197
    ------------------------------------------------------------------------------

*Note: for Stata, you can use `-teffects-` command for (i) and the
`-cem-` package for (ii). For R, you can use the `{MatchIt}` package*

``` stata
*-> 4. Coarsened Exact Matching
cem age (10 20 30 40 60) agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75, treatment(treat) 
reg re78 treat [iweight=cem_weights], robust
```

    Matching Summary:
    -----------------
    Number of strata: 8738
    Number of matched strata: 43

                   0      1
          All  15992    185
      Matched    176     79
    Unmatched  15816    106


    Multivariate L1 distance: .51255777

    Univariate imbalance:

                    L1      mean       min       25%       50%       75%       max
         age    .07947    .53235         1         1         0         1         0
       agesq    .09845    20.224        33        35         0        49         0
     agecube    .14909    582.96       817       919         0      1801         0
        educ   3.7e-16   1.8e-15         0         0         0         0         0
       edusq   3.7e-16  -1.1e-13         0         0         0         0         0
        marr   1.8e-16  -2.8e-17         0         0         0         0         0
    nodegree   3.1e-16  -1.1e-16         0         0         0         0         0
       black   3.6e-16  -5.6e-16         0         0         0         0         0
        hisp   6.2e-17  -1.4e-17         0         0         0         0         0
        re74     .0597    84.692         0         0         0         0   -94.801
        re75    .03614   -43.642         0         0         0   -115.32   -545.65
         u74   4.7e-16  -7.8e-16         0         0         0         0         0
         u75   2.2e-16  -3.3e-16         0         0         0         0         0

    (sum of wgt is   2.5500e+02)

    Linear regression                               Number of obs     =        255
                                                    F(1, 253)         =       6.17
                                                    Prob > F          =     0.0136
                                                    R-squared         =     0.0403
                                                    Root MSE          =     5797.4

    ------------------------------------------------------------------------------
                 |               Robust
            re78 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           treat |   2559.071   1030.202     2.48   0.014     530.2075    4587.934
           _cons |   4157.077   700.3383     5.94   0.000     2777.842    5536.313
    ------------------------------------------------------------------------------
