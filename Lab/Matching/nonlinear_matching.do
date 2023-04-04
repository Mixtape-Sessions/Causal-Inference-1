* Simulation of non-smooth, non-linear, step function in continuous age confounder satisfying unconfoundedness but not exogeneity. 

clear all
program define nonlinear_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		if treat==0
	replace age = rnormal(30,1.5) 		if treat==1

	su age
	replace age = age - `r(mean)'

	su age, detail
	replace age = age - `r(mean)'
	su age, detail

	gen 	y0 = rnormal()
	replace y0 = 200 + rnormal() if age < `r(p25)'
	replace y0 = 25 + runiform() if age>= `r(p25)' & age<=`r(p75)'
	replace y0 = 85 + rnormal() if age>`r(p75)'

	gen  	y1 = -50
	replace y1 = y0 + 2000 if age < `r(p25)'
	replace y1 = y0 + 100  if age>= `r(p25)' & age<=`r(p75)'
	replace y1 = y0 + 1150 if age>`r(p75)'

	gen delta = y1-y0

	su delta if treat==1 // ATT = approximately 600
	local att = r(mean)
	scalar att = `att'
	gen att = `att'
	
	gen earnings = treat*y1 + (1-treat)*y0
		
	reg earnings treat age
	local treat1=_b[treat]
	scalar treat1 = `treat1'
	gen treat1=`treat1'

	reg earnings treat##c.age
	local treat2=_b[1.treat]
	scalar treat2 = `treat2'
	gen treat2=`treat2'

	teffects nnmatch (earnings age) (treat), atet nn(1) metric(maha) // 603 exactly right
	mat b=e(b)
	local treat3 = b[1,1]
	scalar treat3=`treat3'
	gen treat3=`treat3'

	teffects nnmatch (earnings age) (treat), atet nn(1) metric(maha) biasadj(age) // 603 exactly right
	mat b=e(b)
	local treat4 = b[1,1]
	scalar treat4=`treat4'
	gen treat4=`treat4'
    end 

simulate att treat1 treat2 treat3 treat4, reps(1000): nonlinear_te

save ./nonline_te.dta, replace

* Figure1: non-saturated, age and gpa only
kdensity _sim_2, xtitle(Estimated ATE) xline(603, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(-114 603) xline(-114, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated OLS) ytitle("") title("") note("")

graph save "Graph" "./sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq
kdensity _sim_3, xtitle(Estimated ATE) xline(603, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(245 603)  xline(245, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated regression) ytitle("") title("") note("")

graph save "Graph" "./sim2.gph", replace

* Figure3: saturated treatment with age gpa and interactions
kdensity _sim_4, xtitle(Estimated ATE) xline(603, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(603) xline(603, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Distance minimization without bias correction) ytitle("") title("") note("")

graph save "Graph" "./sim3.gph", replace

* Figure4: saturated treatment with age gpa polynomials and interactions
kdensity _sim_5, xtitle(Estimated ATE) xline(603, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(603) xline(603, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Distance minimization with bias correction) ytitle("") title("") note("")

graph save "Graph" "./sim4.gph", replace

graph combine ./sim1.gph ./sim2.gph ./sim3.gph ./sim4.gph, title(OLS Simulations with heterogenous treatment effects) note(Four kernel density plots of estimated coefficients from OLS and matching and 1000 simulations)

graph save "Graph" "./combined_kernels.gph", replace
graph export ./combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace





capture log close 
exit
