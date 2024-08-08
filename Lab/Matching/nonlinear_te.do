******************************************************************
* name: nonlinear_te.do
* author: scott cunningham (baylor)
* description: violate the linearity assumption in OLS but maintain unconfoundedness
******************************************************************

    clear 
    drop _all 
	set obs 5000
	set seed 15800
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(35,2.5) 		if treat==0
	replace age = rnormal(30,2) 		if treat==1
	gen 	gpa = rnormal(2.3,0.75) 	if treat==0
	replace gpa = rnormal(1.76,0.25) 	if treat==1
	
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	su age, detail
	replace age = age - `r(mean)'

	gen gpa_age = age*gpa
	
	su age, detail

	* Admittedly weird nonlinear data generating process: Y0
	gen 	y0 = rnormal()
	replace y0 = 200 + rnormal() if age < `r(p25)'
	replace y0 = 0 +   runiform() if age>= `r(p25)' & age<=`r(p75)'
	replace y0 = 150 + rnormal() if age>`r(p75)'

	su gpa_age, detail
	
	* Admittedly weird nonlinear data generating process: Y1
	gen  	y1 = 0
	replace y1 = y0 + 2000 * (0.25)*gpa_age + rnormal(1,25) if gpa_age >= `r(p5)'  & gpa_age < `r(p25)'
	replace y1 = -10*y0 + 25*age + (0.1)*gpa if age >= `r(p25)' & gpa_age < `r(p50)'
	replace y1 = 10*y0 + (5)*gpa_age + gpa + rnormal(5,5) if gpa_age >= `r(p50)' & gpa_age<`r(p75)'
	replace y1 = y0 + (0.05) * gpa_age + 2*age if gpa_age>=`r(p75)'

	gen delta = y1-y0
	
	su delta // ATE = approximately 26.45
	local ate = r(mean)
	scalar ate = `ate'
	gen ate = `ate'

	su delta if treat==1 // ATT = approximately 271.08
	local att = r(mean)
	scalar att = `att'
	gen att = `att'
	
	gen earnings = treat*y1 + (1-treat)*y0
		
	* Regression: Constant treatment effects with age control
	reg earnings treat age gpa gpa_age

	** ATE
	local reg_ate1=_b[treat]
	scalar reg_ate1 = `reg_ate1'
	gen reg_ate1=`reg_ate1'

	* Regression: Heterogenous treatment effects with age
	regress earnings i.treat##c.age i.treat##c.gpa i.treat##c.gpa_age, robust

	** ATE 
	local reg_ate2=_b[1.treat]
	scalar reg_ate2 = `reg_ate2'
	gen reg_ate2=`reg_ate2'

	** ATT
	* Obtain the coefficients
	local treat_coef = _b[1.treat]
	local age_treat_coef = _b[1.treat#c.age]
	local gpa_treat_coef = _b[1.treat#c.gpa]
	local gpaage_treat_coef = _b[1.treat#c.gpa_age]

	
	* Save the coefficients as scalars and generate variables
	scalar treat_coef = `treat_coef'
	gen treat_coef_var = `treat_coef'

	scalar age_treat_coef = `age_treat_coef'
	gen age_treat_coef_var = `age_treat_coef'

	scalar gpa_treat_coef = `gpa_treat_coef'
	gen gpa_treat_coef_var = `gpa_treat_coef'
	
	scalar gpaage_treat_coef = `gpaage_treat_coef'
	gen gpaage_treat_coef_var = `gpaage_treat_coef'

	* Calculate the mean of the age covariate for treatment group only
	egen mean_age = mean(age) if treat==1
	egen max_age = max(mean_age)
	replace mean_age = max_age if treat==0
	
	egen mean_gpa = mean(gpa) if treat==1
	egen max_gpa = max(mean_gpa)
	replace mean_gpa = max_gpa if treat==0

	egen mean_gpaage = mean(gpaage) if treat==1
	egen max_gpaage = max(mean_gpaage)
	replace mean_gpaage = max_gpaage if treat==0
	
	* Calculate the ATT
gen reg_att = 	treat_coef_var + /// 0
                age_treat_coef_var * mean_age + /// 1
                gpa_treat_coef_var * mean_gpa + /// 2
                gpaage_treat_coef_var * mean_gpaage
	
	** Regression adjustment method	
	
	teffects ra (earnings age gpa gpa_age) (treat), atet

	
	** Distance minimization matching method
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local nn_att1 = b[1,1]
	scalar nn_att1=`nn_att1'
	gen nn_att1=`nn_att1'

	** Distance minimization matching method with bias adjustment
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa) 
	mat b=e(b)
	local nn_att2 = b[1,1]
	scalar nn_att2=`nn_att2'
	gen nn_att2=`nn_att2'
