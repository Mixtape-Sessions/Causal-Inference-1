cd "/Users/scunning/Causal-Inference-1/Lab/Matching"
clear all
set seed 5150
set scheme s2color

* Create results dataset first
clear
set obs 1000
gen trial = _n
gen att = .
gen ate = .
gen ra_att = .
gen ra_ate = .     // Added ra_ate
gen canonical_ols = .
save "simulation_results.dta", replace

* Number of trials
local n_trials = 1000

* Simulation loop
forval trial = 1/`n_trials' {
    clear
    set obs 5000
    
    * First generate ALL base variables
    gen treat = 0
    gen age = .
    gen gpa = .
    gen age_sq = .
    gen gpa_sq = .
    gen interaction = .
    gen e = .
    gen y0 = .
    gen y1 = .
    gen earnings = .
    gen y_diff = .
    
    * Now do all replacements and calculations
    replace treat = 1 in 2501/5000
    replace age = cond(treat == 1, rnormal(25,2.5), rnormal(30,3))
    replace gpa = cond(treat == 1, rnormal(1.76,0.5), rnormal(2.3,0.75))
    
    * Center covariates
    sum age, meanonly
    replace age = age - r(mean)
    sum gpa, meanonly
    replace gpa = gpa - r(mean)
    
    * Now calculate transformed variables
    replace age_sq = age^2
    replace gpa_sq = gpa^2
    replace interaction = age * gpa
    replace e = rnormal(0,250)
    
    * Calculate outcomes
    replace y0 = 15000 + 10.25 * age - 10.5 * age_sq + 1000 * gpa - 10.5 * gpa_sq + 500 * interaction + e
    replace y1 = y0 + 2500 + 100 * age + 1100 * gpa
    replace earnings = treat * y1 + (1 - treat) * y0
    replace y_diff = y1 - y0
    
    * True ATT
    sum y_diff if treat == 1, meanonly
    local true_att = r(mean)
	
    * True ATE
    sum y_diff, meanonly
    local true_ate = r(mean)
    
    * Canonical OLS
    quietly reg earnings age gpa age_sq gpa_sq interaction treat, robust
    local canonical_ols = _b[treat]
    
    * Regression Adjustment
    quietly reg earnings i.treat##(c.age c.age_sq c.gpa c.gpa_sq c.interaction)
    local ra_ate = _b[1.treat]
    
    * Mean of covariates for treated
    sum age if treat == 1, meanonly
    local mean_age = r(mean)
    sum age_sq if treat == 1, meanonly
    local mean_age_sq = r(mean)
    sum gpa if treat == 1, meanonly
    local mean_gpa = r(mean)
    sum gpa_sq if treat == 1, meanonly
    local mean_gpa_sq = r(mean)
    sum interaction if treat == 1, meanonly
    local mean_interaction = r(mean)
    
    * Calculate RA ATT
    local ra_att = _b[1.treat] + _b[1.treat#c.age] * `mean_age' + ///
        _b[1.treat#c.age_sq] * `mean_age_sq' + ///
        _b[1.treat#c.gpa] * `mean_gpa' + ///
        _b[1.treat#c.gpa_sq] * `mean_gpa_sq' + ///
        _b[1.treat#c.interaction] * `mean_interaction'
    
    * Save results
    preserve
    use "simulation_results.dta", clear
    replace att = `true_att' if trial == `trial'
    replace ate = `true_ate' if trial == `trial'
    replace ra_ate = `ra_ate' if trial == `trial'
    replace ra_att = `ra_att' if trial == `trial'
    replace canonical_ols = `canonical_ols' if trial == `trial'
    save "simulation_results.dta", replace
    restore
}


* Load results and create plot
use "simulation_results.dta", clear
set scheme cleanplots
* Calculate mean ATT
sum att, meanonly
local mean_att = r(mean)
* Calculate mean ATE
sum ate, meanonly
local mean_ate = r(mean)

twoway (kdensity ra_ate, lcolor(black) lpattern(solid) lwidth(medthick)) ///
       (kdensity canonical_ols, lcolor(gs8) lpattern(longdash_dot) lwidth(medthick)), ///
       title("Distribution of Coefficient Estimates") ///
       subtitle("RA vs Canonical OLS") ///
       note(`"True ATE is vertical dashed line equalling $2500, RA is centered at $2500 and Canonical OLS is centered"' `"at $2380."') ///
       xtitle("Estimate") ytitle("Density") ///
       legend(order(1 "RA Estimate" 2 "Canonical OLS")) ///
       xline(`mean_ate', lcolor(black) lpattern(dash) lwidth(medthick))
	   
graph export "kernel_density_plot.png", replace


* Calculate mean RA estimate
sum ra_att, meanonly
local mean_ra_att = round(r(mean), 0.01)

* Calculate mean ATT (true value)
sum att, meanonly
local true_att = round(r(mean), 0.01)



twoway (kdensity ra_att, lcolor(black) lpattern(solid) lwidth(medthick)), ///
       title("Distribution of RA Coefficient Estimates") ///
       note("True ATT is solid vertical line equalling $`true_att', RA estimate is centered at $`mean_ra_att'.") ///
       xtitle("Estimate") ytitle("Density") ///
       legend(order(1 "RA Estimate")) ///
       xline(`true_att', lcolor(black) lpattern(solid) lwidth(medthick)) ///
       xline(`mean_ra_att', lcolor(gs6) lpattern(dash) lwidth(medthick))
	   
	   
graph export "kernel_density_plotatt.png", replace
capture log close
exit


capture log close
exit
	
	
	
* Calculate mean ATT
sum att, meanonly
local mean_att = r(mean)

* Calculate mean ATE
sum ate, meanonly
local mean_ate = r(mean)
  

* Create separate density plots
twoway (kdensity ra_ate, color(blue%30)) ///
       (kdensity canonical_ols, color(red%30)), ///
       title("Distribution of Coefficient Estimates") ///
       subtitle("RA vs Canonical OLS") ///
       note("True ATT is vertical dashed line equalling $2500, RA is centered at $2500 and Canonical OLS is centered at $2380.") ///
       xtitle("Estimate") ytitle("Density") ///
       legend(order(1 "RA Estimate" 2 "Canonical OLS")) ///
       xline(`mean_ate = r(mean)', lcolor(black) lpattern(dash) )

graph export "kernel_density_plot.png", replace

