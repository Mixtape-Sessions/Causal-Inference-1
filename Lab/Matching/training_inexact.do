* Creating the training data
clear
capture log close
set obs 30
set seed 10202

gen 	treat = 0
replace treat = 1 in 1/10
bysort treat: gen unit=_n
gsort -treat unit
gen row = _n

gen 	age = runiform(25,50) if treat==0 // Non-trainees are older
replace age = runiform(18,33) if treat==1 // Trainees are younger
replace age = round(age)
gsort -treat

gen age_sq = age^2

* Heterogenous treatment effects
su age
gen 	het = (age - `r(mean)') 

gen earnings = 9841 + 1607.50 * treat + 100 * treat * het + 500 * age + 10.5*age_sq + rnormal(0,5) 
replace earnings = round(earnings)

teffects nnmatch (earnings age) (treat), atet vce(iid) gen(match) 
drop row
gen row=_n

gsort -treat unit 
list treat row unit age earnings match1

teffects nnmatch (earnings age) (treat), atet vce(iid) gen(match2) biasadj(age)

