clear all
cd "/Users/scunning/Causal-Inference-1/Lab/Matching"

* DGP from with imbalanced covariates (unknown propensity score)

* Set up the results file
tempname handle
postfile `handle' att ols tymons_att ra nn nn_ba psmatch ipw_att using results.dta, replace

* Loop through the iterations
forvalues i = 1/500 {
    clear
    drop _all 
	set seed `i'
	set obs 5000

	gen treat = 0 
    replace treat = 1 in 3400/5000


    * Imbalanced covariates
    gen 	age = rnormal(25, 2.5) 		if treat == 1
    replace age = rnormal(30, 3) 		if treat == 0
    gen 	gpa = rnormal(2.3, 0.75) 	if treat == 0
    replace gpa = rnormal(1.76, 0.5) 	if treat == 1

    * Re-center the covariates
    su age, meanonly
    replace age = age - r(mean)

    su gpa, meanonly
    replace gpa = gpa - r(mean)

    * Quadratics and interaction
    quietly gen age_sq = age^2
    quietly gen gpa_sq = gpa^2
    quietly gen interaction = gpa * age

    * Modeling potential outcomes
    quietly gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0, 5)
    quietly gen y1 = y0 + 2500 + 100 * age + 1100 * gpa
    quietly gen treatment_effect = y1 - y0

	
    * Calculate ATE, ATT, and ATU
    quietly su treatment_effect, meanonly
    quietly local ate = r(mean)
    quietly su treatment_effect if treat == 1, meanonly
    quietly local att = r(mean)
    quietly su treatment_effect if treat == 0, meanonly
    quietly local atu = r(mean)

	
    * Generate earnings variable
    quietly gen earnings = treat * y1 + (1 - treat) * y0
	

	* Get the OLS coefficient and OLS theorem decomposition of the ATT 
	quietly hettreatreg age gpa age_sq gpa_sq , o(earnings) t(treat) vce(robust)
	quietly local ols `e(ols1)'
	quietly local tymons_att `e(att)'
	
	
	* RA in teffects to estimate the ATT
	quietly teffects ra (earnings age gpa age_sq gpa_sq ) (treat), atet
	quietly mat b=e(b)
	quietly local ra = b[1,1]
	quietly scalar ra=`ra'
	quietly gen ra=`ra'


	* Nearest neighbor, no bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq ) (treat), atet nn(1) metric(maha) 
	quietly mat b=e(b)
	quietly local nn = b[1,1]
	quietly scalar nn=`nn'
	quietly gen nn=`nn'

	
	* Nearest neighbor, bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq ) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq )
	quietly mat b=e(b)
	quietly local nn_ba = b[1,1]
	quietly scalar nn_ba=`nn_ba'
	quietly gen nn_ba=`nn_ba'
	 
	
	* Propensity score matching in teffects to estimate the ATT
	quietly teffects psmatch (earnings) (treat age gpa age_sq gpa_sq ), atet
	quietly mat b=e(b)
	quietly local psmatch = b[1,1]
	quietly scalar psmatch=`psmatch'
	quietly gen psmatch=`psmatch'
	
	
	* inverse propensity score weights (ATT)
	quietly reg treat age age_sq gpa gpa_sq 
	quietly predict pscore
	quietly gen inv_ps_weight = treat + (1-treat) * pscore/(1-pscore)
	quietly reg earnings i.treat [aw=inv_ps_weight], r
	quietly local ipw_att=_b[1.treat]
	quietly scalar ipw_att = `ipw_att'
	quietly gen ipw_att=`ipw_att'

	
    * Post the results to the results file
    post `handle' (`att') (`ols') (`tymons_att') (`ra') (`nn') (`nn_ba') (`psmatch') (`ipw_att')

	}

* Close the postfile
postclose `handle'

* Use the results
use results.dta, clear
save ./ols_all_unknown.dta, replace

use ./ols_all_unknown.dta, replace

gen ols_bias = att - ols
gen tymon_bias = att - tymons_att
gen ra_bias = att - ra
gen nn_bias = att - nn
gen nnba_bias = att - nn_ba
gen psmatch_bias = att - psmatch 
gen ipw_bias = att - ipw_att 

su ols_bias
local ols_bias `r(mean)'

su tymon_bias
local tymon_bias `r(mean)'

su ra_bias
local ra_bias `r(mean)'

su nn_bias
local nn_bias `r(mean)'

su nnba_bias
local nnba_bias `r(mean)'

su psmatch_bias
local psmatch_bias `r(mean)'

su ipw_bias
local ipw_bias `r(mean)'

su att
local att `r(mean)'


* Format the macro to display only two decimal places
local ols_bias_fmt: display %9.2f `ols_bias'
local tymon_bias_fmt: display %9.2f `tymon_bias'
local ra_bias_fmt: display %9.2f `ra_bias'
local nn_bias_fmt: display %9.2f `nn_bias'
local nnba_bias_fmt: display %9.2f `nnba_bias'
local psmatch_bias_fmt: display %9.2f `psmatch_bias'
local ipw_bias_fmt: display %9.2f `ipw_bias'
local att_fmt: display %9.2f `att'

* Use the formatted macro in your display and kdensity commands
kdensity ols_bias, xtitle("Bias") title("Bias of OLS estimator") note("Bias is equal to `ols_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/ols_bias.png", as(png) name("Graph") replace


kdensity tymon_bias, xtitle("Bias") title("Bias of Tymon's ATT estimator") note("Bias is equal to `tymon_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/tymon_bias.png", as(png) name("Graph") replace


kdensity ra_bias, xtitle("Bias") title("Bias of Regression Adjustment ATT estimator") note("Bias is equal to `ra_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/ra_bias.png", as(png) name("Graph") replace


kdensity nn_bias, xtitle("Bias") title("Bias of nearest neighbor matching ATT estimator") subtitle(no bias adjustment) note("Bias is equal to `nn_bias_fmt', ATT is $`att_fmt' and estimator is the Mahanalobis distance minimization")
graph export "./figures/nn_bias.png", as(png) name("Graph") replace


kdensity nnba_bias, xtitle("Bias") title("Bias of nearest neighbor matching ATT estimator") subtitle(with bias adjustment) note("Bias is equal to `nnba_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/nnba_bias.png", as(png) name("Graph") replace

kdensity psmatch_bias, xtitle("Bias") title("Bias of Propensity Score Matching ATT estimator") note("Bias is equal to `psmatch_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/psmatch_bias.png", as(png) name("Graph") replace


kdensity ipw_bias, xtitle("Bias") title("Bias of Inverse Probability Weighting ATT estimator") note("Bias is equal to `ipw_bias_fmt' and ATT is $`att_fmt'")
graph export "./figures/ipw_bias.png", as(png) name("Graph") replace

save ./ols_all_unknown_mc.dta, replace
 






