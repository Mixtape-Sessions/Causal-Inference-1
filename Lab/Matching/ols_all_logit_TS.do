clear all
cd "/Users/scunning/Causal-Inference-1/Lab/Matching"

* DGP from logit propensity score

* Set up the results file
tempname handle
postfile `handle' att ols tymons_att ra nn nn_ba psmatch ipw_att using results.dta, replace

* Loop through the iterations
forvalues i = 1/5000 {
    clear
    drop _all 
	set obs 5000
	set seed 12042023

	* Generating covariates
	quietly gen 	age = rnormal(35,10.5) 		
	quietly gen 	gpa = rnormal(12,3)

	* Recenter covariates
	quietly su age
	quietly replace age = age - `r(mean)'

	quietly su gpa
	quietly replace gpa = gpa - `r(mean)'

 	* Generate quadratics and interaction
	quietly gen 	age_sq = age^2
	quietly gen 	gpa_sq = gpa^2
	quietly gen 	interaction = age*gpa	
	
	* Generate the potential outcomes
	quietly gen y0 = 22000 + 260*age + -16*age_sq + 1800*gpa + 110*gpa_sq + 40*interaction + rnormal(0,14000)
	quietly gen y1 = y0 + 2500 + -250*age + -500*gpa
	quietly gen treatment_effect = y1 - y0
	
	* Generate logit propensity score
	quietly gen lin_index = -0.13*age + -0.0004*age_sq + -0.6*gpa + -0.055*gpa_sq - 4.5 + `i'*0.00225
	quietly gen true_pscore = exp(lin_index)/(1+exp(lin_index))
	
	* Generate treatment status
	quietly gen treat = runiform(0,1) < true_pscore

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
	quietly hettreatreg age gpa age_sq gpa_sq interaction, o(earnings) t(treat) vce(robust)
	quietly local ols `e(ols1)'
	quietly local tymons_att `e(att)'
	
	
	* RA in teffects to estimate the ATT
	quietly teffects ra (earnings age gpa age_sq gpa_sq interaction) (treat), atet
	quietly mat b=e(b)
	quietly local ra = b[1,1]
	quietly scalar ra=`ra'
	quietly gen ra=`ra'


	* Nearest neighbor, no bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha) 
	quietly mat b=e(b)
	quietly local nn = b[1,1]
	quietly scalar nn=`nn'
	quietly gen nn=`nn'

	
	* Nearest neighbor, bias adjustment	 
	quietly teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq interaction)
	quietly mat b=e(b)
	quietly local nn_ba = b[1,1]
	quietly scalar nn_ba=`nn_ba'
	quietly gen nn_ba=`nn_ba'
	 
	
	* Propensity score matching in teffects to estimate the ATT
	quietly teffects psmatch (earnings) (treat age gpa age_sq gpa_sq interaction), atet
	quietly mat b=e(b)
	quietly local psmatch = b[1,1]
	quietly scalar psmatch=`psmatch'
	quietly gen psmatch=`psmatch'
	
	
	* inverse propensity score weights (ATT)
	quietly reg treat age age_sq gpa gpa_sq interaction
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
save ./ols_all_logit_TW.dta, replace

