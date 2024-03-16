clear all
cd "/Users/scunning/Causal-Inference-1/Lab/Matching"

* Set up the results file
tempname handle
postfile `handle' ate att atu ols prob_treat prob_control n tymons_ate tymons_att tymons_atu w1 w0  delta using results.dta, replace

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
    quietly gen lin_comb = (0.1*age - 0.02*age_sq + 0.8*gpa - 0.08*gpa_sq) + `i'/5000
	
	
    * Normalize the linear combination
    quietly egen max_lin_comb = max(lin_comb)
    quietly gen lin_pscore = lin_comb / max_lin_comb

    * Adjust the treatment assignment
    quietly gen treat = runiform(0,1) < lin_pscore

	
    * Calculate ATE, ATT, and ATU
    quietly su treatment_effect, meanonly
    quietly local ate = r(mean)
    quietly su treatment_effect if treat == 1, meanonly
    quietly local att = r(mean)
    quietly su treatment_effect if treat == 0, meanonly
    quietly local atu = r(mean)

    * Generate earnings variable
    quietly gen earnings = treat * y1 + (1 - treat) * y0

	* Get the weights, OLS coefficient and ALPE 
	quietly hettreatreg age gpa age_sq gpa_sq interaction, o(earnings) t(treat) vce(robust)
	local ols `e(ols1)'
	local prob_treat `e(p1)'
	local prob_control `e(p0)'
	local n `e(N)'
	local tymons_ate `e(ate)'
	local tymons_att `e(att)'
	local tymons_atu `e(atu)'
	local w1 `e(w1)'
	local w0 `e(w0)'
	local delta `e(delta)'
	
	

	

    * Post the results to the results file
    post `handle' (`ate') (`att') (`atu') (`ols') (`prob_treat') (`prob_control') (`n') (`tymons_ate') (`tymons_att') (`tymons_atu') (`w1') (`w0') (`delta')

	}

* Close the postfile
postclose `handle'

* Use the results
use ./results.dta, clear
save ./linear1.dta, replace


gsort prob_treat
gen id=_n

* Simple graph of omega 1 weight against the probability of treatment
twoway (line w1 prob_treat), ytitle("OLS weight on APLE,1") ///
		xtitle("Probability of Treatment") title("Weighted Average Interpretation of OLS Theorem") ///
		subtitle("Treatment Group Size vs. APLE,1 Weights") ///
		note("5000 simulations of the 1st linear propensity score to generate increasing group shares") ///
		legend(position(6))
		
graph export "/Users/scunning/Desktop/linear_pscore_weights.png", as(png) name("Graph")	  replace 
		


* Shows the OLS coefficient moves towards the ATU as the share of units treated rises
twoway (scatter ols prob_treat, mcolor(blue)) (scatter att prob_treat, mcolor(red)) ///
       (scatter atu prob_treat, mcolor(green)), ///
       legend(label(1 "OLS") label(2 "ATT") label(3 "ATU")) ///
       yline(2500, lpattern(dash) lcolor(black)) ///
       xline(0.5, lpattern(dash) lcolor(yello)) ///
	   title(OLS ATT and ATU changed with group share) ///
	   subtitle(Linear propensity score #1) ///
       xtitle("Probability of Treatment") ytitle("Parameter / Coefficient")

	   
graph export "/Users/scunning/Desktop/linear_pscore_ols.png", as(png) name("Graph")	   replace

	   
#delimit cr




