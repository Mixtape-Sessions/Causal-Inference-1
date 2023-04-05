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
	su delta if treat==1 // ATT = 2119
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
	reg earnings treat##c.age##c.gpa, robust
	local beta = _b[1.treat]
	scalar beta=`beta'
	gen beta =`beta'
	
	local c = _b[1.treat#c.age#c.gpa]
	scalar c = `c'
	gen saturate = `c'

	su age if treat==1
	local mean_age_treat=`r(mean)'
	scalar mean_age_treat = `mean_age_treat'
	gen mean_age_treat = `mean_age_treat'

	gen treat3 = beta + saturate*mean_age_treat
	drop mean_age_treat saturate beta
	
	* Regression 4: Heterogenous treatment effects, full saturation
	reg earnings treat##c.age##c.gpa##c.age_sq##c.gpa_sq, robust
	local beta = _b[1.treat]
	scalar beta=`beta'
	gen beta =`beta'
	
	local c = _b[1.treat#c.age#c.gpa#c.age_sq#c.gpa_sq]
	scalar c = `c'
	gen saturate = `c'

	su age if treat==1
	local mean_age_treat=`r(mean)'
	scalar mean_age_treat = `mean_age_treat'
	gen mean_age_treat = `mean_age_treat'

	gen treat4 = beta + saturate*mean_age_treat
	drop mean_age_treat saturate beta

    end 

simulate att treat1 treat2 treat3 treat4, reps(1000): het_te

* Figure1: non-saturated, age and gpa only
kdensity _sim_1, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2423 2500) xline(2422.848, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age and gpa) ytitle("") title("") note("")

graph save "Graph" "./sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq, interaction
kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2423 2500)  xline(2423.018, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age gpa and polynomials) ytitle("") title("") note("")

graph save "Graph" "./sim2.gph", replace

* Figure3: saturated treatment with age gpa and interactions
kdensity _sim_3, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2467 2500) xline(2467.083, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./sim3.gph", replace

* Figure4: saturated treatment with age gpa polynomials and interactions
kdensity _sim_4, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xline(2500.012, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa polynomials and interactions) ytitle("") title("") xlabel(2500) note("")

graph save "Graph" "./sim4.gph", replace

graph combine ./sim1.gph ./sim2.gph ./sim3.gph ./sim4.gph, title(OLS Simulations with heterogenous treatment effects) note(Four kernel density plots of estimated coefficients form four regressions and 1000 simulations)

graph save "Graph" "./combined_kernels.gph", replace
graph export ./combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace


capture log close 
exit
