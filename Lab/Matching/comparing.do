* comparing.do. Simulated dataset with imbalance in age and gpa, both of which are confounders

	clear 
    drop _all 
	set seed 5150
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000 // equal proportions in treatment and control
	
	* Poor pre-treatment fit (imbalance on covariates which will introduce matching bias)
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(30,3) 		if treat==0
	gen 	gpa = rnormal(2.3,0.75) 	if treat==0
	replace gpa = rnormal(1.76,0.5) 	if treat==1

	* Visualize the imbalance
	twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))

	twoway (histogram gpa if treat==1,  color(blue)) ///
       (histogram gpa if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))

	* Estimate the propensity score
	logit treat age gpa
	predict pscore
	label variable pscore "Propensity score"
	
	twoway (histogram pscore if treat==1,  color(red)) ///
       (histogram pscore if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))
	   
	* Re-center the covariates
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	* Some quadratics and an interaction 
	gen age_sq 		= age^2
	gen gpa_sq 		= gpa^2
	gen interaction	= gpa*age
	gen e = rnormal(0,5)

	* Modeling potential outcomes as functions of X but differently depending on Y0 or Y1 -- "heterogeneity in the potential outcomes with respect to the covariates"
	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + e
	label variable y0 "Earnings without a college degree"
	
	gen y1 = y0 + 2500 + 100 * age + 1100 * gpa // heterogeneous treatment effects with respect to age and gpa
	label variable y1 "Earnings with a college degree"
	
	gen delta = y1 - y0

	su delta 				// ATE = 2500
	
	su delta if treat==1 	// ATT = 1962
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	su delta if treat==0 	// ATU = 3037
	local atu = r(mean)
	scalar atu = `atu'
	gen atu = `atu'

	* Switching equation creates a "realized outcome" based on treatment assignment
	
	gen earnings = treat*y1 + (1-treat)*y0

	* 1) Standard regression assuming constant treatment effects
	
	reg earnings age gpa age_sq gpa_sq interaction treat, robust	// biased
	
	* 2) Nearest neighbor matching without 

	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha)  // biased

	* 3) Nearest neighbor matching with bias adjustment/correction

	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha) biasadj(age age_sq gpa gpa_sq interaction) // unbiased

	* 4) Introduction to regression adjustment (the long way, then the short way)
	* First estimate the fully interacted regression model (ideally saturated)
	
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

	* Second obtain the coefficients
	local treat_coef 		= _b[1.treat] // 0
	local age_treat_coef 	= _b[1.treat#c.age] // 1
	local agesq_treat_coef 	= _b[1.treat#c.age_sq] // 2
	local gpa_treat_coef 	= _b[1.treat#c.gpa] // 3
	local gpasq_treat_coef 	= _b[1.treat#c.gpa_sq] // 4
	local age_gpa_coef 		= _b[1.treat#c.age#c.gpa] // 5
	

	* Third save the coefficients as scalars and generate variables
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
		
	
	* Fourth, calculate the mean of the covariates in the treatment sample only
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
	
	su interaction if treat==1
	local mean_agegpa = `r(mean)'
	gen mean_agegpa = `mean_agegpa'

	
* Fifth, calculate the ATT by taking a sum of the products
gen treat4 = 	treat_coef_var + /// 0
                age_treat_coef_var * mean_age + /// 1
                agesq_treat_coeff_var * mean_agesq + /// 2
                gpa_treat_coef_var * mean_gpa + /// 3
                gpasq_treat_coef_var * mean_gpasq + /// 4
                age_gpa_coef_var * mean_agegpa  

* Or you take the short way and use -teffects ra- 

teffects ra (earnings age gpa age_sq gpa_sq interaction) (treat), atet  // unbiased

su delta if treat==1
su treat4

* Or the Kitagawa-Oaxaca-Blinder method (the medium way)
reg earnings age gpa age_sq-interaction if treat==1
predict mu1

reg earnings age gpa age_sq-interaction if treat==0
predict mu0

gen te_hat = mu1-mu0
su te_hat // ATE = $299.55
su te_hat if treat==1 // ATT = $1962.592
su te_hat if treat==0 // ATU = $3036.509

* You can also get the ATU using this formula:  ATE = pATT + (1-p)ATU where p is share of units treated.  Then you just solve for ATU.  ATU = (ATE - pATT)/(1-p).  

* Calculate the proportion of treated units
sum treat
local p_treated = `r(mean)'

* Calculate the ATU
gen delta_atu = (treat_coef_var - `p_treated' * treat4) / (1 - `p_treated')

su delta if treat==0 // ATU = $3037.5
su delta_atu 		 // ATU = $3036.5

** Other methods using propensity scores with and without bias adjustment. 

* 5) Inverse probability weighting

teffects ipw (earnings) (treat age gpa age_sq gpa_sq interaction, logit), atet // biased

* 6) Inverse probability weighting with an outcome regression model for double robust
	
teffects ipwra (earnings age gpa age_sq gpa_sq interaction) (treat age gpa age_sq gpa_sq interaction, logit), atet // unbiased
	
* 7) Propensity score matching
	
teffects psmatch (earnings) (treat age gpa age_sq gpa_sq interaction, logit), atet // biased
