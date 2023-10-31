    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	
	* Poor pre-treatment fit
	gen 	age = rnormal(20,2.5) 		if treat==1
	replace age = rnormal(35,3) 		if treat==0
	gen 	gpa = rnormal(2.8,0.75) 	if treat==0
	replace gpa = rnormal(1.26,0.5) 	if treat==1

	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	* All combinations 
	gen age_sq 		= age^2
	gen age_agesq 	= age*age_sq
	gen agesq_agesq	= age_sq^2
	gen gpa_sq 		= gpa^2
	gen gpa_gpasq 	= gpa*gpa_sq
	gen gpasq_gpasq = gpa_sq^2
	gen interaction	= gpa*age
	gen agegpa		= age*gpa	 
	gen age_gpasq 	= age*gpa_sq
	gen gpa_agesq 	= gpa*age_sq
	gen gpasq_agesq = age_sq*gpa_sq

	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 5000*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000*gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 1980
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	gen earnings = treat*y1 + (1-treat)*y0

	