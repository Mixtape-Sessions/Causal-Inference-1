* ssc install reganat

* Creating the training data
clear
capture log close
set obs 3000
set seed 10202

gen 	treat = 0
replace treat = 1 in 1/750

* Overlap
gen 	age = runiform(18,32) 		if treat==1
replace age = rnormal(35,3) 		if treat==0
gen 	gpa = rnormal(2.3,0.5) 		if treat==0
replace gpa = rnormal(1.76,2.45) 	if treat==1

su age gpa
replace age = age - `r(mean)'
replace gpa = gpa - `r(mean)'

* Constant treatment effects
gen earnings = 9841 + 1607.50 * treat + -250 * age + 10.25 * gpa + rnormal() 

* Multivariate regression
reg earnings treat age gpa, robust

* FWL auxilary regression
reg treat age gpa, robust
predict treat_hat
gen treat_squiggle = treat - treat_hat
reg earnings treat_squiggle, robust

* FWL in code

reg earnings treat

regress earnings treat age gpa

reganat earnings treat age gpa, dis(treat) biline


