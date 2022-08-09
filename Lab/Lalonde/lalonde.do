** Lalonde.do ******************************************************************
** Kyle Butts, CU Boulder Economics
** 
** replicate analysis of Lalonde (1986) and Dehejia and Wahba (2002)

use "https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta", clear

* ssc install cem

********************************************************************************
* Part 1
********************************************************************************

*-> 1. Experimental Analysis
  *-> Baseline Covariate Balance
  foreach y of varlist re74 re75 marr educ age black hisp {
    qui reg `y' i.treat, r
    est store `y'
  }
  est tab *, keep(1.treat) se

  *-> Estimate treatment effect
  reg re78 i.treat, r



*-> 2. Non-experimental Analysis
  
  *-> Append in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
  drop if treat==0
  append using "https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta"

  *-> "Treatment" effect
  reg re78 i.treat, r


********************************************************************************
* Part 2
********************************************************************************

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

  * inverse propensity score weights (ATT)
  gen inv_ps_weight = treat + (1-treat) * pscore/(1-pscore)
  * ATE
  * gen inv_ps_weight = inv_ps_weight = treat / pscore + (1-treat) * 1/(1-pscore)
  * ATC
  * gen inv_ps_weight = treat * (1-pscore)/pscore - (1-treat)

  reg re78 i.treat [aw=inv_ps_weight], r

*-> 2. Inverese propensity score weighting with trimming
  preserve
  drop if pscore < 0.1 | pscore > 0.9
  reg re78 i.treat [aw=inv_ps_weight], r
  restore

*-> 3. Propensity Score Matching
  teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75, logit), atet gen(ps_cps) nn(1)


*-> 4. Coarsened Exact Matching
  cem age (10 20 30 40 60) agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75, treatment(treat) 
  reg re78 treat [iweight=cem_weights], robust
