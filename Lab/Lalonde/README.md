# Lalonde

This dataset is one of the most commonly used dataset in econometrics based on [Lalonde (1986)](https://econpapers.repec.org/article/aeaaecrev/v_3a76_3ay_3a1986_3ai_3a4_3ap_3a604-20.htm) and [Dehejia and Wahba (2002)](https://www.uh.edu/~adkugler/Dehejia&Wahba.pdf). Both the paper by Lalonde and Dehejia and Wahba both wanted to evaluate causal inference methods using non-experimental data. Cleverly, they start with an experimental dataset to estimate the 'true' causal effect and then use non-experimental data to evaluate an econometric method.

Our two datasets are:

1. `https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta` which contains data from an experimental sample. In the sample, individuals are offered a job training program and we want to evaluate the effect on future earnings `re78` (real-earnings in 1978).

2. `https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta` which contains data from the CPS.


## Part 1: Experimental vs. Observational Analysis

1. We will first perform analysis on the experimental dataset `https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta`

a. Estimate the effect of treatment, `treat`, on real-earnings in 1978, `re78`. This will be the "true" treatment effect estimate that we will try to recreate with the non-experimental CPS sample. 

b. Further, show baseline covariate balance on the following variables: `re74`, `re75`, `marr`, `educ`, `age`, `black`, `hisp`. 

2. Now, take the treated units from the `nsw` dataset and append to it the CPS control sample `https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta`. Perform a simple difference-in-means on the combined dataset to estimate the treatment effect with no control group adjustment.

## Part 2: Selection on Observable Methods

1. Estimate a simple OLS model with `age + agesq + agecube + educ + educsq + marr + nodegree + black + hisp + re74 + re75 + u74 + u75` as additive controls listed.  Interpret the coefficient.  

2. Fit a propensity score (logit) model using the following covariates `age + agesq + agecube + educ + educsq + marr + nodegree + black + hisp + re74 + re75 + u74 + u75`, where `u74` and `u75` are indicators for being unemployed in 1974 and 1975 (`re74`/`re75` = 0). Take those weights and calculate the inverse propensity-score weights for the ATT and use these weights in a simple regression of `re78` on the treatment dummy, `treat`. 

3. Note that the previous estimate was still negative. That is because we have extreme values for the estimated propensity score. Trim the data to observations with pscore $> 0.1$ and $< 0.9$ and reestimate the inverse propensity-score weighted regression of `re78` on `treat`.

4. Using (i) 1:1 nearest-neighbor propensity-score matching with replacement, (ii) nearest neighbor matchting Mahanalobis distance minimization with and without bias adjustment and (iv) regression adjustment, estimate the ATT. You should use the same covariates as part b. 


*Note: for Stata, you can use `-teffects-` for these. For R, you can use the `{MatchIt}` and `{Matching}` packages*


