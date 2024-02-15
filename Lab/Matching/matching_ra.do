    clear 
    drop _all 
	set seed 5000
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	
	* Poor pre-treatment fit
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(30,3) 		if treat==0
	gen 	gpa = rnormal(2.3,0.75) 	if treat==0
	replace gpa = rnormal(1.76,0.5) 	if treat==1
	
	twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))
	   
	twoway (histogram gpa if treat==1,  color(blue)) ///
       (histogram gpa if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))

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
	su delta if treat==1 // ATT = 1977
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	gen earnings = treat*y1 + (1-treat)*y0
	
	** Regression methods (incorrect and regression adjustment)
	* Incorrect regression specification
	reg earnings treat age gpa age_sq gpa_sq agegpa, robust
	
	* Regression adjustment model 1
	teffects ra (earnings age gpa age_sq gpa_sq agegpa) (treat), atet
	
	* Regression adjustment model 2
	teffects ra (earnings age gpa age_sq gpa_sq agegpa) (treat), ate

	
	** Nearest neighbor (mahanalobis distance minimization) matching (ATE, ATT)
	* Matching model 1	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), ate nn(1) metric(maha) 

	* Matching model 2	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), ate nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq agegpa)

	* Matching model 3	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), atet nn(1) metric(maha) 

	* Matching model 4	 
	teffects nnmatch (earnings age gpa age_sq gpa_sq agegpa) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq agegpa)
