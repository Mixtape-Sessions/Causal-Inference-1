
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

``` r
library(tidyverse)
```

    ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
    ✔ tibble  3.1.7     ✔ dplyr   1.0.9
    ✔ tidyr   1.2.0     ✔ stringr 1.4.0
    ✔ readr   2.1.2     ✔ forcats 0.5.1

    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()

``` r
library(fixest)
library(haven)
library(MatchIt)

# Experimental data
df_exp <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta")
```

1.  Estimate the effect of treatment, `treat`, on real-earnings in 1978,
    `re78`. This will be the “true” treatment effect estimate that we
    will try to recreate with the non-experimental CPS sample.

``` r
# Estimate treatment effect
df_exp |> 
  feols(re78 ~ i(treat), vcov = "hc1")
```

    OLS estimation, Dep. Var.: re78
    Observations: 445 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error  t value  Pr(>|t|)    
    (Intercept)  4554.80    340.204 13.38845 < 2.2e-16 ***
    treat::1     1794.34    670.824  2.67483 0.0077534 ** 
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 6,564.7   Adj. R2: 0.015606

2.  Further, show baseline covariate balance on the following variables:
    `re74`, `re75`, `marr`, `educ`, `age`, `black`, `hisp`.

``` r
df_exp |> 
  feols(
    c(re74, re75, marr, educ, age, black, hisp) ~ i(treat),
    vcov = "hc1"
  ) |>
  etable()
```

                               model 1            model 2            model 3
    Dependent Var.:               re74               re75               marr
                                                                            
    (Intercept)     2,107.0*** (352.9) 1,266.9*** (192.5) 0.1538*** (0.0224)
    treat = 1           -11.45 (503.5)      265.1 (305.0)    0.0353 (0.0365)
    _______________ __________________ __________________ __________________
    S.E. type       Heteroskedas.-rob. Heteroskedas.-rob. Heteroskedas.-rob.
    Observations                   445                445                445
    R2                         1.11e-6            0.00172            0.00217
    Adj. R2                   -0.00226           -0.00053           -8.73e-5

                              model 4           model 5            model 6
    Dependent Var.:              educ               age              black
                                                                          
    (Intercept)     10.09*** (0.1001) 25.05*** (0.4378) 0.8269*** (0.0235)
    treat = 1         0.2575 (0.1785)   0.7624 (0.6842)    0.0163 (0.0357)
    _______________ _________________ _________________ __________________
    S.E. type       Heteroskeda.-rob. Heteroskeda.-rob. Heteroskedas.-rob.
    Observations                  445               445                445
    R2                        0.00503           0.00281            0.00047
    Adj. R2                   0.00278           0.00056           -0.00179

                               model 7
    Dependent Var.:               hisp
                                      
    (Intercept)     0.1077*** (0.0193)
    treat = 1        -0.0482. (0.0260)
    _______________ __________________
    S.E. type       Heteroskedas.-rob.
    Observations                   445
    R2                         0.00707
    Adj. R2                    0.00483
    ---
    Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

2.  Now, take the treated units from the `nsw` dataset and append to it
    the CPS control sample
    `https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta`.
    Perform a simple difference-in-means on the combined dataset to
    estimate the treatment effect with no control group adjustment.

``` r
df_cps <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/cps_mixtape.dta")

# Treated experimental units with CPS units as controls
df_nonexp <- bind_rows(df_exp |> filter(treat == 1), df_cps)
```

``` r
df_nonexp |> feols(re78 ~ i(treat), vcov = "hc1")
```

    OLS estimation, Dep. Var.: re78
    Observations: 16,177 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error  t value  Pr(>|t|)    
    (Intercept) 14846.66    76.2907 194.6063 < 2.2e-16 ***
    treat::1    -8497.52   581.9158 -14.6027 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 9,628.4   Adj. R2: 0.008667

## Part 2: Selection on Observable Methods

1.  Fit a propensity score (logit) model using the following covariates
    `age + agesq + agecube + educ + educsq + marr + nodegree + black + hisp + re74 + re75 + u74 + u75`,
    where `u74` and `u75` are indicators for being unemployed in 1974
    and 1975 (`re74`/`re75` = 0). Take those weights and calculate the
    inverse propensity-score weights and use these weights in a simple
    regression of `re78` on the treatment dummy, `treat`.

``` r
df_nonexp <- df_nonexp |>
  mutate(
    agesq = age^2,
    agecube = age^3,
    educsq = educ * educ,
    u74 = case_when(re74 == 0 ~ 1, TRUE ~ 0),
    u75 = case_when(re75 == 0 ~ 1, TRUE ~ 0),
  )

logit_nsw <- feglm(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  family = binomial(link = "logit"),
  data = df_nonexp
)

df_nonexp$pscore <- predict(logit_nsw, type = "response")

# inverse propensity score weights
df_nonexp <- df_nonexp |> 
  mutate(
    inv_ps_weight = treat * 1/pscore + (1-treat) * 1/(1-pscore)
  )
```

``` r
# Weights are implicitly normalized when using `feols`,
# plus it gives standard errors
df_nonexp |> 
  feols(re78 ~ i(treat),
    weights = ~inv_ps_weight, vcov = "hc1"
  )
```

    OLS estimation, Dep. Var.: re78
    Observations: 16,177 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error   t value   Pr(>|t|)    
    (Intercept) 14722.91    78.4093 187.76983  < 2.2e-16 ***
    treat::1    -6784.39  1439.2374  -4.71388 2.4507e-06 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 10,447.8   Adj. R2: 0.104767

2.  Note that the previous estimate was still negative. That is because
    we have extremem values for pscore. For example, a control unit with
    pscore $=0.0001$ receives a huge weight: $(1/0.0001) = 1000$. Trim
    the data to observations with pscore $> 0.1$ and $< 0.9$ and
    reestimate the inverse propensity-score weighted regression of
    `re78` on `treat`.

``` r
df_nonexp |> 
  filter(pscore > 0.1 & pscore < 0.9) |>
  feols(re78 ~ i(treat),
    weights = ~inv_ps_weight, vcov = "hc1"
  )
```

    OLS estimation, Dep. Var.: re78
    Observations: 370 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error  t value  Pr(>|t|)    
    (Intercept)  4385.50    417.837 10.49572 < 2.2e-16 ***
    treat::1     1350.89    748.043  1.80590   0.07175 .  
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 9,189.1   Adj. R2: 0.008368

3.  Using (i) 1:1 nearest-neighbor propensity-score matching with
    replacement and (ii) coarsened exact matching, estimate a treatment
    effect. You should use the same covariates as part b.

*Note: for Stata, you can use `-teffects-` command for (i) and the
`-cem-` package for (ii). For R, you can use the `{MatchIt}` package*

``` r
# 1:1 nearest neighbor matching with replacement on
# the Mahalanobis distance
nn_out <- matchit(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  data = df_nonexp, distance = "mahalanobis",
  replace = TRUE, estimand = "ATT"
)

df_nonexp$nn_weights = nn_out$weights

df_nonexp |> 
  feols(
    re78 ~ i(treat), weights = ~nn_weights, vcov = "hc1"
  )
```

    NOTE: 15,882 observations removed because of 0-weight.

    OLS estimation, Dep. Var.: re78
    Observations: 295 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error t value   Pr(>|t|)    
    (Intercept)  4493.69    636.852 7.05609 1.2405e-11 ***
    treat::1     1855.46    860.591 2.15603 3.1895e-02 *  
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 7,086.8   Adj. R2: 0.012418

``` r
cem_out <- matchit(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  data = df_nonexp,
  method = "cem", estimand = "ATT"
)

df_nonexp$cem_weights = cem_out$weights

feols(
  re78 ~ i(treat), weights = ~cem_weights,
  data = df_nonexp,  vcov = "hc1"
)
```

    NOTE: 16,021 observations removed because of 0-weight.

    OLS estimation, Dep. Var.: re78
    Observations: 156 
    Standard-errors: Heteroskedasticity-robust 
                Estimate Std. Error t value   Pr(>|t|)    
    (Intercept)  4162.18    698.158 5.96165 1.6426e-08 ***
    treat::1     2651.10   1164.290 2.27701 2.4163e-02 *  
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 5,925.3   Adj. R2: 0.037828
