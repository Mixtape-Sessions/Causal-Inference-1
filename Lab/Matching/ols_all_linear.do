clear all
cd "/Users/scunning/Causal-Inference-1/Lab/Matching"

* DGP from ols_linear_sim

* Set up the results file
tempname handle
postfile `handle' att ols tymons_att ra nn nn_ba psmatch ipw_att using results.dta, replace

* Loop through the iterations
forvalues i = 1/500 {
    clear
    drop _all 
	set seed `i'
	set obs 5000

	* Generating covariates
	quietly gen 	age = rnormal(25,2.5) 		
	quietly gen 	gpa = rnormal(2.3,0.75)

	* Recenter covariates
	quietly su age
    quietly replace age = (age - r(mean)) / 9.857341  // normalize age

	quietly su gpa
    quietly replace gpa = (gpa - r(mean)) / 2.661211  // normalize gpa

 	* Generate quadratics and interaction
    quietly gen age_sq = age^2
    quietly gen gpa_sq = gpa^2
    quietly gen interaction = age*gpa

	
	* Generate the potential outcomes
    quietly gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 2000*interaction + rnormal(0,5)
    quietly gen y1 = y0 + 2500 + 100 * age + 1000*gpa
    quietly gen treatment_effect = y1 - y0

	
	* Generate linear propensity score
    quietly gen lin_comb = (0.1*age - 0.02*age_sq + 0.8*gpa - 0.08*gpa_sq) + 1700/5000
	
	
    * Normalize the linear combination
    quietly egen max_lin_comb = max(lin_comb)
    quietly gen lin_pscore = lin_comb / max_lin_comb

    * Adjust the treatment assignment
    quietly gen treat = runiform(0,1) < lin_pscore

	
    * Calculate ATT
    quietly su treatment_effect if treat == 1, meanonly
    quietly local att = r(mean)

    * Generate earnings variable
    quietly gen earnings = treat * y1 + (1 - treat) * y0

	* Get the OLS coefficient and OLS theorem decomposition of the ATT 
	quietly hettreatreg age gpa age_sq gpa_sq, o(earnings) t(treat) vce(robust)
	quietly local ols `e(ols1)'
	quietly local tymons_att `e(att)'
	
	
	* RA in teffects to estimate the ATT
	quietly teffects ra (earnings age gpa age_sq gpa_sq) (treat), atet
	quietly mat b=e(b)
	quietly local ra = b[1,1]
	quietly scalar ra=`ra'
	quietly gen ra=`ra'


	* Nearest neighbor, no bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq) (treat), atet nn(1) metric(maha) 
	quietly mat b=e(b)
	quietly local nn = b[1,1]
	quietly scalar nn=`nn'
	quietly gen nn=`nn'

	
	* Nearest neighbor, bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq )
	quietly mat b=e(b)
	quietly local nn_ba = b[1,1]
	quietly scalar nn_ba=`nn_ba'
	quietly gen nn_ba=`nn_ba'
	 
	
	* Propensity score matching in teffects to estimate the ATT
	quietly teffects psmatch (earnings) (treat age gpa age_sq gpa_sq), atet
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
save ./ols_all_linear.dta, replace 


use ./ols_all_linear.dta, clear

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


* Format the macro to display only two decimal places
local ols_bias_fmt: display %9.2f `ols_bias'
local tymon_bias_fmt: display %9.2f `ra_bias'
local ra_bias_fmt: display %9.2f `ra_bias'
local nn_bias_fmt: display %9.2f `nn_bias'
local nnba_bias_fmt: display %9.2f `nnba_bias'
local psmatch_bias_fmt: display %9.2f `psmatch_bias'
local ipw_bias_fmt: display %9.2f `ipw_bias'

* Use the formatted macro in your display and kdensity commands
kdensity ols_bias, xtitle("Bias") title("Bias of OLS estimator") note("Bias is equal to `ols_bias_fmt' and ATT is $2693")
graph export "./figures/ols_bias.png", as(png) name("Graph") replace


kdensity tymon_bias, xtitle("Bias") title("Bias of Tymon's ATT estimator") note("Bias is equal to `tymon_bias_fmt' and ATT is $2693")
graph export "./figures/tymon_bias.png", as(png) name("Graph") replace


kdensity ra_bias, xtitle("Bias") title("Bias of Regression Adjustment ATT estimator") note("Bias is equal to `ra_bias_fmt' and ATT is $2693")
graph export "./figures/ra_bias.png", as(png) name("Graph") replace


kdensity nn_bias, xtitle("Bias") title("Bias of nearest neighbor matching ATT estimator") subtitle(no bias adjustment) note("Bias is equal to `nn_bias_fmt', ATT is $2693 and estimator is the Mahanalobis distance minimization")
graph export "./figures/nn_bias.png", as(png) name("Graph") replace


kdensity nnba_bias, xtitle("Bias") title("Bias of nearest neighbor matching ATT estimator") subtitle(with bias adjustment) note("Bias is equal to `nnba_bias_fmt' and ATT is $2693")
graph export "./figures/nnba_bias.png", as(png) name("Graph") replace

kdensity psmatch_bias, xtitle("Bias") title("Bias of Propensity Score Matching ATT estimator") note("Bias is equal to `psmatch_bias_fmt' and ATT is $2693")
graph export "./figures/psmatch_bias.png", as(png) name("Graph") replace


kdensity ipw_bias, xtitle("Bias") title("Bias of Inverse Probability Weighting ATT estimator") note("Bias is equal to `ipw_bias_fmt' and ATT is $2693")
graph export "./figures/ipw_bias.png", as(png) name("Graph") replace




save ./ols_all_linear_mc.dta, replace
