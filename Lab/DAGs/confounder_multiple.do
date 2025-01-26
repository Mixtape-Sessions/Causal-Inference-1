* Multiple ways to satisfy the backdoor criterion, but some may still be better, not because of bias, but for precision. 

clear
capture log close
set seed 10501

**********
* Define dgp
**********

cap program drop dgp
program define dgp

set obs 10000

* Confounder triangle: 
* D -> Y
* X1 -> Y
* X2 -> Y
* X3 -> D
* X2 -> X3 <- X1

* Generate Covariates (Baseline values)
  gen x1 = rnormal(35, 10)
  sum x1
  replace x1 = x1-`r(mean)'

  gen x2 = rnormal(35, 10)
  sum x2
  replace x2 = x2-`r(mean)'

  gen x3 = 10 * x1 + 10 * x2 + rnormal(35, 10)
  sum x3
  replace x3 = x3-`r(mean)'
  
* Treatment probability increases with age and decrease with gpa
  gen prob = 0.5 + 0.25 * (x3 > 0)
  gen treat = runiform() < prob

* Data generating process for error  
  gen	 e = rnormal(0, 5)
  gen	y0 = 100 + 100 * x1 + -50 * x2 + e 

* Covariate-based treatment effect with constant treatment effects
  gen	y1 = y0 + 1000 
  
* Aggregate causal parameters
  gen delta = y1-y0
  sum delta, meanonly
  gen ate = `r(mean)'
  su delta if treat==1, meanonly
  gen att = `r(mean)'
  su delta if treat==0, meanonly
  gen atu = `r(mean)'
  
  su ate att atu // constant treatment effects

* Switching equation   
  gen earnings = treat*y1 + (1-treat)*y0
  
end

********************************************************************************
* Generate a sample
********************************************************************************
clear
quietly dgp
sum att ate

* Regressions

  reg earnings treat, robust
  reg earnings treat x3, robust
  reg earnings treat x2 x3, robust
  reg earnings treat x1 x3, robust
  reg earnings treat x1 x2, robust
  reg earnings treat x1 x2 x3, robust

********************************************************************************
* Monte-carlo simulation
********************************************************************************
cap program drop sim
program define sim, rclass
  clear
  quietly dgp
  
  * Regressions
  reg earnings treat, robust
  return scalar ols_sdo = _b[treat]
  
  reg earnings treat x3, robust
  return scalar ols3 = _b[treat]
  
  reg earnings treat x2 x3, robust
  return scalar ols23 = _b[treat]

  reg earnings treat x1 x3, robust
  return scalar ols13 = _b[treat]
  
  reg earnings treat x1 x2, robust
  return scalar ols12 = _b[treat]

  reg earnings treat x1 x2 x3, robust
  return scalar ols123 = _b[treat]
  
end

simulate ols_sdo = r(ols_sdo) ols3 = r(ols3) ols23 = r(ols23) ols13=r(ols13) ols12 = r(ols12) ols123 = r(ols123), reps(1000): sim
sum
  
  
  
capture log close
exit


  
  
  