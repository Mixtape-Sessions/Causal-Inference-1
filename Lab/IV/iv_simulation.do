*****************************************************
* name: iv_simulation.do
* author: scott cunningham (baylor)
* description: simulation with constant treatment effects and the Wald IV estimator expressed three ways
*****************************************************
clear
capture log close
set seed 20200403

* 100,000 people 

set obs 100000
gen person = _n

* Unobserved ability, the instrument and our treatment (school)
gen 	ability = rnormal()
su 		ability
replace ability = ability - `r(mean)'

gen 	iv = rnormal()
replace iv = 0 if iv<0
replace iv = 1 if iv>0

gen 	index = 6 + 100*iv + 100*ability + rnormal(0,1)
su index, de

gen college = 0
replace college = 1 if index>=`r(p75)'

* Constant treatment effects
gen 	earnings1 = 7450 + 1000*college + 500*ability + rnormal(0,1)

* OLS
reg earnings1 college ability // MHE call this the "long regression" (bc it has all the variables)
reg earnings1 college		  // "the short regression"

* Wald IV 1. Wald IV can be vieweed as the ratio of two regression coefficients (reduced form divided by first stage)
reg earnings1 iv
local rf = _b[iv] // reduced form
scalar rf = `rf'
gen rf=`rf'

reg college iv
local fs = _b[iv] // first stage
scalar fs = `fs'
gen fs=`fs'

gen wald_iv = rf/fs
su wald_iv

* Wald IV 2. Wald IV estimator is also the ratio of two covariances (Cov(Y,Z) divided by Cov(S,Z))
* Cov(Y,Z) = E[YZ] - E[Y]E[Z]
* Cov(S,Z) = E[SZ] - E[S]E[Z]

egen mean_wage = mean(earnings1)
egen mean_iv = mean(iv)
egen mean_educ = mean(college)
gen yz_product = mean_wage*mean_iv
gen sz_product = mean_educ*mean_iv

gen yz = earnings1*iv
gen sz = college*iv

egen mean_yz = mean(yz)
egen mean_sz = mean(sz)

* Wald estimator: Cov(Y,Z) / Cov(S,Z)

gen cov_yz = mean_yz - yz_product
gen cov_sz = mean_sz - sz_product

gen wald_iv2 = cov_yz/cov_sz // notice that in the wald estimator, you are dividing by a covariance measuring the statistical correlation between schooling and the instrument. If schooling and the instrument are not correlated (say they are independent), then Wald is undefined because you can't divide by a zero.
su wald_iv2 wald_iv


** Wald IV 3. Two stage least squares is the Wald IV estimator when there are no covariates and the treatment is binary and the instrument is binary.

* 1st stage: regress schooling onto the instrument

regress college  iv, robust
predict collegehat

* 2nd stage: regress earnings outcome onto the "fitted value of the treatment variable"
regress earnings1  collegehat, robust
summarize wald_iv*

regress earnings1 iv, robust // reduced form
regress earnings1 iv, robust // first stage

regress earnings1 college, robust // Estimated return to college is biased upward 

ivregress 2sls earnings1 (college=iv), first robust // Estimated return to college is $1,009 which is what we found earlier

* We want to test the strengthe of the first stage using the appropriate F statistic and calculating the Andeson-Rubin confidence intervals

weakivtest // Montiel Olea and Pflueger effective F statistic
twostepweakiv 2sls earnings1 (college = iv), robust

capture log close
exit
