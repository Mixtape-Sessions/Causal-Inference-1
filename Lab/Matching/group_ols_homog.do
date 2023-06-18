    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2500/5000

	ssc install hettreatreg, replace
	
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
	gen agegpa		= age*gpa	 

	gen y0 = 15000 + 10.25*age - 1 * age_sq + 1000*gpa - 2 * gpa_sq + rnormal(0,5)
	gen y1 = y0 + 2500 + 20 * age + 10 * gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2448
	su delta if treat==0 // ATU = 2552

	gen earnings = treat*y1 + (1-treat)*y0


	*  RA in teffects

	teffects ra (earnings age gpa age_sq gpa_sq agegpa) (treat), atet

	su delta if treat==1

	* Heterogenous treatment effect and groups

	su delta
	su delta if treat==1
	su delta if treat==0

	reg earnings treat age gpa age_sq gpa_sq agegpa, robust

	hettreatreg age gpa age_sq gpa_sq agegpa, o(earnings) t(treat)



