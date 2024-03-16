clear all

* Set up the results file
tempname handle
postfile `handle' ate att atu prob_treat prob_control n w1 w0 delta tymons_ate tymons_ols ols tymons_att tymons_atu bias_ate bias_att bias_atu using results.dta, replace

* Loop through the iterations
forvalues i = 4/4996 {
    clear
    set seed 5150
    set obs 5000
    gen treat = 0 
    replace treat = 1 in `i'/5000

    * Imbalanced covariates
    gen 	age = rnormal(25, 2.5) if treat == 1
    replace age = rnormal(30, 3) if treat == 0
    gen 	gpa = rnormal(2.3, 0.75) if treat == 0
    replace gpa = rnormal(1.76, 0.5) if treat == 1

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
    quietly gen y1 = y0 + 2500 + 100 * age + 2000 * gpa
    quietly gen treatment_effect = y1 - y0

    * Calculate ATE, ATT, and ATU
    su treatment_effect, meanonly
    local ate = r(mean)
	gen ate = `ate'
    su treatment_effect if treat == 1, meanonly
    local att = r(mean)
	gen att = `att'
    su treatment_effect if treat == 0, meanonly
    local atu = r(mean)
	gen atu = `atu'

    * Generate earnings variable
    quietly gen earnings = treat * y1 + (1 - treat) * y0

    * Regression
    reg earnings age gpa age_sq gpa_sq interaction treat, robust
	local ols = _b[treat]
	gen ols = `ols'

	* Get the weights, OLS coefficient and ALPE 
	hettreatreg age gpa age_sq gpa_sq interaction, o(earnings) t(treat) vce(robust)
	local tymons_ols `e(ols1)'
	local tymons_ate `e(ate)'
	local tymons_att `e(att)'
	local tymons_atu `e(atu)'
	local prob_treat `e(p1)'
	local prob_control `e(p0)'
	local n `e(N)'
	local w1 `e(w1)'
	local w0 `e(w0)'
	local delta `e(delta)'
	

	
	gen bias_ate = tymons_ate - ate
	gen bias_att = tymons_att - att
	gen bias_atu = tymons_atu - atu
	
    * Post the results to the results file
    post `handle' (`ate') (`ate') (`ateu') (`tymons_ols') (`tymons_ate') (`tymons_att') (`tymons_atu') (`prob_treat') (`prob_control') (`n') (`w1') (`w0') (`tymons_atu') (`delta') (`bias_ate') (`bias_att')  (`bias_atu')
	}

* Close the postfile
postclose `handle'

* Use the results
use results.dta, clear


	