** Thornton.do *****************************************************************
** Kyle Butts, CU Boulder Economics
** 
** Analysis of Thornton (2008)

use "https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta", clear

********************************************************************************
* Part 1
********************************************************************************

*-> 1.a. Calculate by hand
  sum got if any == 0
  local got0 = r(mean)
  sum got if any == 1
  local got1 = r(mean)
  local te = `got1' - `got0'

  disp "Treatment Effect Estimate: `te'"

*-> 1.b. Calculate using OLS
  reg got i.any, vce(cluster villnum)


*-> 2. "Check" the experimental design by looking at covariates
  foreach y of varlist male age hiv2004 educ2004 land2004 usecondom04 {
    reg `y' i.any tinc i.under i.rumphi i.balaka, vce(cluster villnum)
  }

*-> Dose-response function
  * high incentive (>= $2)
  reg got i.any if tinc >= 2 | tinc == 0, vce(cluster villnum) 
  
  * low incentive (<= $1)
  reg got i.any if tinc <= 1 | tinc == 0, vce(cluster villnum)

  * linear dose-response function
  reg got i.any tinc, vce(cluster villnum)


********************************************************************************
* Part 2
********************************************************************************

*-> Randomization Inference

  use https://github.com/scunning1975/mixtape/raw/master/thornton_hiv.dta, clear

  tempfile hiv
  save "`hiv'", replace

  * Calculate true effect using absolute value of SDO
  egen 	te1 = mean(got) if any==1
  egen 	te0 = mean(got) if any==0

  collapse (mean) te1 te0
  gen 	ate = te1 - te0
  keep 	ate
  gen iteration = 1

  tempfile permute1
  save "`permute1'", replace

  * Create a hundred datasets

  forvalues i = 2/1000 {
    use "`hiv'", replace

    drop any
    set seed `i'
    gen random_`i' = runiform()
    sort random_`i'
    gen one=_n
    drop random*
    sort one

    gen 	any = 0
    replace any = 1 in 1/2222

    * Calculate test statistic using absolute value of SDO
    egen 	te1 = mean(got) if any==1
    egen 	te0 = mean(got) if any==0

    collapse (mean) te1 te0
    gen 	ate = te1 - te0
    keep 	ate

    gen 	iteration = `i'
    tempfile permute`i'
    save "`permute`i''", replace
  }

  use "`permute1'", replace
  forvalues i = 2/1000 {
    append using "`permute`i''"
  }

  tempfile final
  save "`final'", replace

  * Calculate exact p-value
  * ascending order
  sort ate  
  gen rank = (_N + 1) - _n
  su rank if iteration==1
  gen pvalue = rank/_N
  list if iteration==1

