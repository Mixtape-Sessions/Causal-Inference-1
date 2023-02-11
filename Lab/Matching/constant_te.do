* Creating the training data
clear
capture log close
set obs 3000
set seed 10202

gen 	treat = 0
replace treat = 1 in 1/750
bysort treat: gen unit=_n

gen 	age = rnormal(27.5,1) if treat==0 // Non-trainees are older
replace age = rnormal(20,0.5) if treat==1 // Trainees are younger
replace age = round(age)

* Constant treatment effects
gen earnings = 9841 + 1607.50 * treat + 25 * age + rnormal() 

* OLS
reg earnings treat age, robust

cap n teffects nnmatch (earnings) (treat), ate ematch(age) vce(iid) gen(match1) 

teffects nnmatch (earnings age) (treat), ate vce(iid) gen(match2) 

