* Simulation with heterogenous treatment effects, unconfoundedness and OLS estimation
clear all
program define het_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(27.5,1.75) 	if treat==0
	gen 	gpa = rnormal(2.3,0.5) 		if treat==0
	replace gpa = rnormal(1.76,0.45) 	if treat==1

	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	gen age_sq = age^2
	gen gpa_sq = gpa^2
	gen interaction=gpa*age

	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000*gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2105
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	gen earnings = treat*y1 + (1-treat)*y0

	* Regression 1: constant treatment effects, no quadratics	
	reg earnings treat age gpa, robust 
	local treat1=_b[treat]
	scalar treat1 = `treat1'
	gen treat1=`treat1'

	* Regression 2: constant treatment effects, quadratics and interaction
	reg earnings treat age age_sq gpa gpa_sq c.gpa#c.age, robust 
	local treat2=_b[treat]
	scalar treat2 = `treat2'
	gen treat2=`treat2'
	

	* Regression 3: Heterogenous treatment effects, partial saturation
	regress earnings i.treat##c.age##c.gpa, robust

	* Obtain the coefficients
	local treat_coef = _b[1.treat]
	local age_treat_coef = _b[1.treat#c.age]
	local gpa_treat_coef = _b[1.treat#c.gpa]
	local age_gpa_treat_coef = _b[1.treat#c.age#c.gpa]

	* Save the coefficients as scalars and generate variables
	scalar treat_coef = `treat_coef'
	gen treat_coef_var = `treat_coef'

	scalar age_treat_coef = `age_treat_coef'
	gen age_treat_coef_var = `age_treat_coef'
	
	scalar gpa_treat_coef = `gpa_treat_coef'
	gen gpa_treat_coef_var = `gpa_treat_coef'

	scalar age_gpa_treat_coef = `age_gpa_treat_coef'
	gen age_gpa_treat_coef_var = `age_gpa_treat_coef'

	* Calculate the mean of the covariates
	egen mean_age = mean(age), by(treat)
	egen mean_gpa = mean(gpa), by(treat)
	
	* Calculate the ATT
	gen treat3 = treat_coef_var + ///
				age_treat_coef_var * mean_age + ///
                gpa_treat_coef_var * mean_gpa + ///
                age_gpa_treat_coef_var * mean_age * mean_gpa if treat == 1

	* Drop coefficient variables
	drop treat_coef_var age_treat_coef_var gpa_treat_coef_var age_gpa_treat_coef_var mean_gpa mean_age
	
	
	* Regression 4: Heterogenous treatment effects, full saturation
	regress earnings i.treat##c.age##c.age_sq##c.gpa##c.gpa_sq, robust

	* Obtain the coefficients
	local treat_coef = _b[1.treat]
	local age_treat_coef = _b[1.treat#c.age]
	local age_sq_treat_coef = _b[1.treat#c.age_sq]
	local gpa_treat_coef = _b[1.treat#c.gpa]
	local gpa_sq_treat_coef = _b[1.treat#c.gpa_sq]
	local age_age_sq_coef = _b[1.treat#c.age#c.age_sq]
	local age_gpa_coef = _b[1.treat#c.age#c.gpa]
	local age_gpa_sq_coef = _b[1.treat#c.age#c.gpa_sq]
	local age_sq_gpa_coef = _b[1.treat#c.age_sq#c.gpa]
	local age_sq_gpa_sq_coef = _b[1.treat#c.age_sq#c.gpa_sq]
	local gpa_gpa_sq_coef = _b[1.treat#c.gpa#c.gpa_sq]

	* Save the coefficients as scalars and generate variables
	scalar treat_coef = `treat_coef'
	gen treat_coef_var = `treat_coef'

	scalar age_treat_coef = `age_treat_coef'
	gen age_treat_coef_var = `age_treat_coef'
	
	scalar age_sq_treat_coef = `age_sq_treat_coef'
	gen age_sq_treat_coef_var = `age_sq_treat_coef'

	scalar gpa_treat_coef = `gpa_treat_coef'
	gen gpa_treat_coef_var = `gpa_treat_coef'

scalar gpa_sq_treat_coef = `gpa_sq_treat_coef'
gen gpa_sq_treat_coef_var = `gpa_sq_treat_coef'

scalar age_age_sq_coef = `age_age_sq_coef'
gen age_age_sq_coef_var = `age_age_sq_coef'

scalar age_gpa_coef = `age_gpa_coef'
gen age_gpa_coef_var = `age_gpa_coef'

scalar age_gpa_sq_coef = `age_gpa_sq_coef'
gen age_gpa_sq_coef_var = `age_gpa_sq_coef'

scalar age_sq_gpa_coef = `age_sq_gpa_coef'
gen age_sq_gpa_coef_var = `age_sq_gpa_coef'

scalar age_sq_gpa_sq_coef = `age_sq_gpa_sq_coef'
gen age_sq_gpa_sq_coef_var = `age_sq_gpa_sq_coef'

scalar gpa_gpa_sq_coef = `gpa_gpa_sq_coef'
gen gpa_gpa_sq_coef_var = `gpa_gpa_sq_coef'

* Calculate the mean of the covariates
egen mean_age = mean(age), by(treat)
egen mean_age_sq = mean(age_sq), by(treat)
egen mean_gpa = mean(gpa), by(treat)
egen mean_gpa_sq = mean(gpa_sq), by(treat)

* Calculate the ATT
gen treat4 = treat_coef_var + ///
                age_treat_coef_var * mean_age + ///
                age_sq_treat_coef_var * mean_age_sq + ///
                gpa_treat_coef_var * mean_gpa + ///
                gpa_sq_treat_coef_var * mean_gpa_sq + ///
                age_treat_coef_var * mean_age * age_age_sq_coef + ///
                age_treat_coef_var * mean_age * age_gpa_coef + ///
                age_treat_coef_var * mean_age * age_gpa_sq_coef + ///
                age_sq_treat_coef_var * mean_age_sq * age_sq_gpa_coef + ///
                age_sq_treat_coef_var * mean_age_sq * age_sq_gpa_sq_coef + ///
                gpa_treat_coef_var * mean_gpa * gpa_gpa_sq_coef if treat == 1

* Drop coefficient variables
drop treat_coef_var age_treat_coef_var age_sq_treat_coef_var gpa_treat_coef_var gpa_sq_treat_coef_var ///
     age_age_sq_coef_var age_gpa_coef_var age_gpa_sq_coef_var age_sq_gpa_coef_var age_sq_gpa_sq_coef_var gpa_gpa_sq_coef_var

collapse (max) att treat1 treat2 treat3 treat4
	 
	 
    end 

simulate att treat1 treat2 treat3 treat4, reps(1000): het_te

* Figure1: non-saturated, age and gpa only
kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2423 2500) xline(2422.848, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age and gpa) ytitle("") title("") note("")

graph save "Graph" "./sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq, interaction
kdensity _sim_3, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2500 2500)  xline(2500, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age gpa and polynomials) ytitle("") title("") note("")

graph save "Graph" "./sim2.gph", replace

* Figure3: saturated treatment with age gpa and interactions
kdensity _sim_4, xtitle(Estimated ATT) xline(2105, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2003 2105) xline(2003, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./sim3.gph", replace

* Figure4: saturated treatment with age gpa polynomials and interactions
kdensity _sim_5, xtitle(Estimated ATT) xline(2105, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2105 2107) xline(2107, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa polynomials and interactions) ytitle("") title("") note("")

graph save "Graph" "./sim4.gph", replace

graph combine ./sim1.gph ./sim2.gph ./sim3.gph ./sim4.gph, title(OLS Simulations with heterogenous treatment effects) note(Four kernel density plots of estimated coefficients form four regressions and 1000 simulations)

graph save "Graph" "./combined_kernels.gph", replace
graph export ./combined_kernels_ols.jpg, as(jpg) name("Graph") quality(90) replace


capture log close 
exit
