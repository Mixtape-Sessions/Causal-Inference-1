cd "/Users/scott_cunningham/Documents/Causal-Inference-1/Lab/Matching"

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
	
	* Poor pre-treatment fit
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(30,3) 		if treat==0
	gen 	gpa = rnormal(2.3,0.75) 	if treat==0
	replace gpa = rnormal(1.76,0.5) 	if treat==1
	
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	* All combinations 
	gen age_sq 		= age^2
	gen gpa_sq 		= gpa^2
	gen interaction	= gpa*age
	gen agegpa		= age*gpa	 

	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000 * gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 1980
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
	
	* Regression 3: Misspecified interacted regression model
	regress earnings i.treat##c.age##c.gpa, robust
	local ate1=_b[1.treat]
	scalar ate1 = `ate1'
	gen ate1=`ate1'

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
	egen mean_age 		= mean(age) if treat==1
	egen mean_gpa 		= mean(gpa) if treat==1
	egen mean_age_gpa 	= mean(agegpa) if treat==1
	
	* Calculate the ATT
	gen treat3 = treat_coef_var + ///
				age_treat_coef_var * mean_age + ///
                gpa_treat_coef_var * mean_gpa + ///
                age_gpa_treat_coef_var * mean_age_gpa 

	* Drop coefficient variables
	drop treat_coef_var age_treat_coef_var gpa_treat_coef_var age_gpa_treat_coef_var mean_gpa mean_age
		
	* Regression 4: Fully interacted regression model
	#delimit ;
	
	regress earnings 	i.treat##c.age 
						i.treat##c.age_sq
						i.treat##c.gpa 
						i.treat##c.gpa_sq					
						i.treat##c.age##c.gpa;
	#delimit cr					
	
	local ate2=_b[1.treat]
	scalar ate2 = `ate2'
	gen ate2=`ate2'

	* Obtain the coefficients
	local treat_coef 		= _b[1.treat] // 0
	local age_treat_coef 	= _b[1.treat#c.age] // 1
	local agesq_treat_coef 	= _b[1.treat#c.age_sq] // 2
	local gpa_treat_coef 	= _b[1.treat#c.gpa] // 3
	local gpasq_treat_coef 	= _b[1.treat#c.gpa_sq] // 4
	local age_gpa_coef 		= _b[1.treat#c.age#c.gpa] // 5
	

	* Save the coefficients as scalars and generate variables
	scalar 	treat_coef = `treat_coef'
	gen 	treat_coef_var = `treat_coef' // 0

	scalar 	age_treat_coef = `age_treat_coef'
	gen 	age_treat_coef_var = `age_treat_coef' // 1
	
	scalar 	agesq_treat_coef = `agesq_treat_coef'
	gen 	agesq_treat_coeff_var = `agesq_treat_coef' // 2

	scalar 	gpa_treat_coef = `gpa_treat_coef'
	gen 	gpa_treat_coef_var = `gpa_treat_coef' // 3

	scalar 	gpasq_treat_coef = `gpasq_treat_coef'
	gen 	gpasq_treat_coef_var = `gpasq_treat_coef' // 4

	scalar 	age_gpa_coef = `age_gpa_coef'
	gen 	age_gpa_coef_var = `age_gpa_coef' // 5
		
	
	* Calculate the mean of the covariates
	su 	age if treat==1
	local mean_age = `r(mean)'
	gen mean_age = `mean_age'
	
	su age_sq if treat==1
	local mean_agesq = `r(mean)'
	gen mean_agesq = `mean_agesq'
	
	su gpa if treat==1
	local mean_gpa = `r(mean)'
	gen mean_gpa = `mean_gpa'
	
	su gpa_sq if treat==1
	local mean_gpasq = `r(mean)'
	gen mean_gpasq = `mean_gpasq'
	
	su agegpa if treat==1
	local mean_agegpa = `r(mean)'
	gen mean_agegpa = `mean_agegpa'

	
* Calculate the ATT
gen treat4 = 	treat_coef_var + /// 0
                age_treat_coef_var * mean_age + /// 1
                agesq_treat_coeff_var * mean_agesq + /// 2
                gpa_treat_coef_var * mean_gpa + /// 3
                gpasq_treat_coef_var * mean_gpasq + /// 4
                age_gpa_coef_var * mean_agegpa  

	 
* Matching model 1	 
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local match1 = b[1,1]
	scalar match1=`match1'
	gen match1=`match1'

* Matching model 2	 
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)
	mat b=e(b)
	local match2 = b[1,1]
	scalar match2=`match2'
	gen match2=`match2'
	 
* Matching model 3	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local match3 = b[1,1]
	scalar match3=`match3'
	gen match3=`match3'

* Matching model 4	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq agegpa)
	mat b=e(b)
	local match4 = b[1,1]
	scalar match4=`match4'
	gen match4=`match4'
	 
	 
collapse (max) att treat1 treat2 ate1 ate2 treat3 treat4 match1 match2 match3 match4
	 
	 
    end 

simulate att treat1 treat2 ate1 ate2 treat3 treat4 match1 match2 match3 match4, reps(1000): het_te


** Regressions ATE
* Figure1: Control for age and gpa

kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2500 2717) xline(2717, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Control for age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./figures/sim2.gph", replace


* Figure2: Control for age and gpa, polynomials and interactions

kdensity _sim_3, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2500 2388) xline(2388, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Plus higher order polynomials) ytitle("") title("") note("")

graph save "Graph" "./figures/sim3.gph", replace

graph combine ./figures/sim2.gph ./figures/sim3.gph, title(OLS Estimates of ATE with heterogenous treatment effects) subtitle(Non-saturated models) note(Two kernel density plots of estimated coefficients from 1000 simulations)

graph save "Graph" "./figures/combined_kernels_ate.gph", replace
graph export ./figures/nonsaturated_kernels_ate.jpg, as(jpg) name("Graph") quality(90) replace


**Saturated regressions
* Figure3: Saturate age and gpa
kdensity _sim_4, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2500 2532) xline(2532, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Interactions w/ age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./figures/sim4.gph", replace

kdensity _sim_5, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(2500) xline(2500, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Interactions w/ quadratics and interactions) ytitle("") title("") note("")

graph save "Graph" "./figures/sim5.gph", replace

graph combine ./figures/sim4.gph ./figures/sim5.gph, title(Interacted regression estimates of ATE) note(ATE is 2500 from 1000 simulations.)
graph save "Graph" "./figures/combined_kernels.gph", replace
graph export ./figures/combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace


* Figure2: Regression adjustment estimates of the ATT

kdensity _sim_6, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980 1746) xline(1746, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Shorter ATT interaction model) ytitle("") title("") note("")

graph save "Graph" "./figures/sim6.gph", replace

kdensity _sim_7, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980) xline(1980, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Longer ATT interaction model) ytitle("") title("") note("")

graph save "Graph" "./figures/sim7.gph", replace

graph combine ./figures/sim6.gph ./figures/sim7.gph, title(Regression adjustment OLS) note(1000 Monte Carlo simulations)
graph save "Graph" "./figures/combined_ra.gph", replace
graph export ./figures/combined_ra.jpg, as(jpg) name("Graph") quality(90) replace



** Matching
* Figure5: Matching without bias adjustment
kdensity _sim_8, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980 2007) xline(2007, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Age and GPA and no bias adjustment) ytitle("") title("") note("")

graph save "Graph" "./figures/sim_8.gph", replace

* Figure6: Matching with bias adjustment
kdensity _sim_9, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980 1998) xline(1998, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Age and GPA with bias adjustment) ytitle("") title("") note("")

graph save "Graph" "./figures/sim_9.gph", replace


* Figure8: Matching without bias adjustment
kdensity _sim_10, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980 2007) xline(2007, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Age and GPA polynomials without bias adjustment) ytitle("") title("") note("")

graph save "Graph" "./figures/sim_10.gph", replace

* Figure9: Matching with bias adjustment
kdensity _sim_11, xtitle(Estimated ATT) xline(1980, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(1980 1980) xline(1980, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Age and GPA polynomials with bias adjustment) ytitle("") title("") note("")

graph save "Graph" "./figures/sim_11.gph", replace


graph combine ./figures/sim_10.gph ./figures/sim_11.gph, title(Nearest Neighbor Matching with Minimized Maha Distance) note(Estimated ATT from 1000 simulations using nearest neighbor matching)

graph save "Graph" "./figures/combined_kernels_maha.gph", replace
graph export ./figures/combined_kernels_maha.jpg, as(jpg) name("Graph") quality(90) replace

capture log close 
exit
