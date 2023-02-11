* Creating the training data
clear
capture log close
set obs 3000
set seed 10202

* ssc install reganat

gen 	treat = 0
replace treat = 1 in 1/750

* Overlap
gen 	age = runiform(18,32) 		if treat==1
replace age = rnormal(35,3) 		if treat==0
gen 	gpa = rnormal(2.3,0.5) 		if treat==0
replace gpa = rnormal(1.76,0.45) 	if treat==1

* Constant treatment effects
gen earnings = 9841 + 1607.50 * treat + 25 * age + 1.25*gpa + rnormal() 

* Multivariate regression
reg earnings treat age gpa, robust

* FWL auxilary regression
reg treat age gpa, robust
predict treat_hat
gen treat_tilde = treat - treat_hat
reg earnings treat_tilde, robust

* FWL in code

reg earnings age
reg earnings gpa
regress earnings treat age gpa

reganat earnings treat age gpa, dis(age gpa) biline


