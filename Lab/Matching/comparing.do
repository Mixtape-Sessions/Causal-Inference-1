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

	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000*gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 1980
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	gen earnings = treat*y1 + (1-treat)*y0


	* Regression: Fully interacted regression model
	
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

* Or use RA in teffects

teffects ra (earnings age gpa age_sq gpa_sq agegpa) (treat), atet

su delta if treat==1
su treat4
