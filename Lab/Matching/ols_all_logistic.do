clear all
cd "/Users/scunning/Causal-Inference-1/Lab/Matching"

* DGP from logistic propensity score

* Set up the results file
tempname handle
postfile `handle' att ols tymons_att ra nn nn_ba psmatch ipw_att using results.dta, replace

* Loop through the iterations
forvalues i = 1/5000 {
    clear
    drop _all 
	set obs 5000
	set seed 1501

	* Generating covariates
	quietly gen 	age = rnormal(25,2.5) 		
	quietly gen 	gpa = rnormal(2.3,0.75)

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
	quietly gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 2000*interaction + rnormal(0,5)
	quietly gen y1 = y0 + 2500 + 100 * age + 1000*gpa
	quietly gen treatment_effect = y1 - y0

	
	* Generate logistic propensity score with varying intercept
	gen true_pscore = 1 / (1 + exp(-(0.2*age - 0.03*age_sq + 2*gpa - 0.2*gpa_sq + `i'/1000 - 3)))
	
	* Treatment assignment based on the propensity score
	gen treat = runiform(0,1) < true_pscore

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
save ./ols_all_logistic.dta, replace
