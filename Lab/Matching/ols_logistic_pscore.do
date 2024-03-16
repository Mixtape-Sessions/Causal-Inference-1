* Attempting to create a DGP with selection driven by a logistic propensity score
    clear 
	ssc install hettreatreg, replace

    drop _all 
	set obs 5000
	set seed 1501
	
	* Generating covariates
	gen 	age = rnormal(25,2.5) 		
	gen 	gpa = rnormal(2.3,0.75)

	* Recenter covariates
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

 	* Generate quadratics and interaction
	gen 	age_sq = age^2
	gen 	gpa_sq = gpa^2
	gen 	interaction = age*gpa	

	
	* Generate the potential outcomes
	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 2000*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000*gpa
	gen delta = y1 - y0

	
	* Generate logistic propensity score
	gen pscore = 1 / (1 + exp(-(0.2*age - 0.03*age_sq + 2*gpa - 0.2*gpa_sq + 500/1000 - 3)))
	
	
	* Treatment assignment based on the propensity score
	gen treated = runiform(0,1) < pscore

	
	* Summarize the aggregate causal parameters
	su delta 			 // ATE = 2500
	su delta if treat==1 // ATT = 3262
	su delta if treat==0 // ATU = 2402


	* Switching equation
	gen earnings = treat*y1 + (1-treat)*y0

	
	* OLS with additive controls under exogeneity
	reg earnings treat age gpa age_sq gpa_sq interaction, robust

	
	* Decomposition of OLS using Tymon's OLS theorem
	hettreatreg age gpa age_sq gpa_sq interaction, o(earnings) t(treat)


	* Or use RA in teffects to estimate the ATT

	teffects ra (earnings age gpa age_sq gpa_sq interaction) (treat), atet
	su delta if treat==1

	
	* Or use nearest neighbor in teffects to estimate the ATT

	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet

	* Bias adjustment
	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), biasadj(age gpa age_sq gpa_sq interaction) atet
	su delta if treat==1

	* or use inverse propensity score weighting
	logit treat age gpa age_sq gpa_sq interaction
	
	* predict the propensity score
	predict est_pscore

	* Checking support 
	twoway (histogram est_pscore if treat==1,  color(green)) ///
       (histogram est_pscore if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))

	* inverse propensity scores weights (ATT)
	gen inv_ps_weight = treat + (1-treat) * est_pscore/(1-est_pscore)
	
	* inverse propensity score weighting (IPW) without trimming
	su delta if treat==1
	reg earnings i.treat [aw=inv_ps_weight]
	
	* Trim off 0.1 and 0.9
	drop if est_pscore<0.01 
	drop if est_pscore>0.9
	
	sum delta if treat==1
	* inverse propensity score weighting (IPW) with trimming
	reg earnings i.treat [aw=inv_ps_weight]

	* Or use propensity score matching in teffects to estimate the ATT

	teffects psmatch (earnings) (treat age gpa age_sq gpa_sq interaction), atet 
	su delta if treat==1
	
