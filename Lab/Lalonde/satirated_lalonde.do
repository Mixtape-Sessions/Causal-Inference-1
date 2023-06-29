    clear 
    drop _all 
	use nswcps, clear
	
	* Regression 3: Misspecified saturated regression model
	#delimit; 
	regress re78 i.treated##c.age i.treated##c.age2
				i.treated##c.educ i.treated##i.black
				i.treated##i.hispanic i.treated##i.married
				i.treated##i.nodegree i.treated##c.re75
				i.treated##c.re74, robust;
	#delimit cr
				
	* Obtain the coefficients
	local treat_coef = _b[1.treated]
	local age_treat_coef = _b[1.treated#c.age]
	local age2_treat_coef = _b[1.treated#c.age2]
	local educ_treat_coef = _b[1.treated#c.educ]
	local black_treat_coef = _b[1.treated#1.black]
	local hisp_treat_coef = _b[1.treated#1.hispanic]
	local married_treat_coef = _b[1.treated#1.married]
	local nodegree_treat_coef = _b[1.treated#1.nodegree]
	local re75_treat_coef = _b[1.treated#c.re75]
	local re74_treat_coef = _b[1.treated#c.re74]

	* Save the coefficients as scalars and generate variables
	scalar treat_coef = `treat_coef'
	gen treat_coef = `treat_coef'

	scalar age_treat_coef = `age_treat_coef'
	gen age_treat_coef = `age_treat_coef'
	
	scalar age2_treat_coef = `age2_treat_coef'
	gen age2_treat_coef = `age2_treat_coef'

	scalar educ_treat_coef = `educ_treat_coef'
	gen educ_treat_coef = `educ_treat_coef'

	scalar black_treat_coef = `black_treat_coef'
	gen black_treat_coef = `black_treat_coef'
	
	scalar hisp_treat_coef = `hisp_treat_coef'
	gen hisp_treat_coef = `hisp_treat_coef'

	scalar married_treat_coef = `married_treat_coef'
	gen married_treat_coef = `married_treat_coef'

	scalar nodegree_treat_coef = `nodegree_treat_coef'
	gen nodegree_treat_coef = `nodegree_treat_coef'

	scalar re75_treat_coef = `re75_treat_coef'
	gen re75_treat_coef = `re75_treat_coef'

	scalar re74_treat_coef = `re74_treat_coef'
	gen re74_treat_coef = `re74_treat_coef'
	
	* Calculate the mean of the covariates
	egen mean_age = mean(age) if treated==1
	egen mean_age2 = mean(age2) if treated==1
	egen mean_educ = mean(educ) if treated==1
	egen mean_black = mean(black) if treated==1
	egen mean_hisp = mean(hispanic) if treated==1
	egen mean_married = mean(married) if treated==1
	egen mean_nodegree = mean(nodegree) if treated==1
	egen mean_re75 = mean(re75) if treated==1
	egen mean_re74 = mean(re74) if treated==1
	
	* Calculate the ATT using the saturated regression
	gen att = treat_coef + ///
				age_treat_coef * mean_age + ///
				age2_treat_coef * mean_age2 + ///
                educ_treat_coef * mean_educ + ///
				black_treat_coef * mean_black + ///
                hisp_treat_coef * mean_hisp + ///
                married_treat_coef * mean_married + ///
                re74_treat_coef * mean_re74 + ///
                re75_treat_coef * mean_re75 + ///
                nodegree_treat_coef * mean_nodegree if treated == 1

* OLS estimate of the ATT is biased towards 796.  
	sum att				

* Outcome regression is the same estimator.  
teffects ra (re78 age-re75) (treated), atet

* Tymon's decompostion based on group size
hettreatreg age-re75, o(re78) t(treated)

* Nearest neighbor
	teffects nnmatch (re78 age-re75) (treated), atet nn(1) metric(maha) biasadj(age-re75)


