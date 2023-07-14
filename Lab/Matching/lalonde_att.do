******************************************************************************
* name: lalonde_att.do
* description: estimate the ATT using Lalonde original dataset
* author: scott cunningham (baylor)
* last updated: july 4, 2023
******************************************************************************

clear
capture log close

use "https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta", clear

*-> 1. Experimental Analysis

  *-> Estimate treatment effect (ATE = $1794)
  reg re78 i.treat, r


*-> Append in the CPS controls
  drop if treat==0
  append using "https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta"

  *-> Biased estimate of ATE
  reg re78 i.treat, r
  
*-> Regression adjustment from controls from Dehejia and Wahba
  *-> Create variables
  gen agesq = age^2
  gen agecube = age^3
  gen edusq = educ^2
  gen u74 = (re74 == 0)
  gen u75 = (re75 == 0)
  
*-> 1. Simple additive control model

reg re78 treat age agesq agecube educ edusq marr nodegree black hisp, r

teffects ra (re78 age agesq agecube educ edusq marr nodegree black hisp) (treat), atet

