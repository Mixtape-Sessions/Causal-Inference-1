* Nearest neighbor matching using teffects with bias correction. Dataset is the matched sample from using the minimizing of the non-normalized Euclidean distance from earlier
clear
capture log close
set seed 10500

set obs 5000
gen 	person = _n

gen 	treat = 0
replace treat = 1 in 1/750

* Overlap
gen 	age = runiform(18,32) 		if treat==1
replace age = rnormal(35,3) 		if treat==0
gen 	gpa = rnormal(2.3,0.5) 		if treat==0
replace gpa = rnormal(1.76,0.45) 	if treat==1

gen 	interaction = age*gpa
gen 	age_sq = age^2
gen 	gpa_sq = gpa^2

* A trick to creating heterogenous treatment effects
su 		age
gen 	het = (age - `r(mean)') 

gen earnings1 = 15000 + 2500*treat + 100 * treat*het + 10.25*age + 25000*gpa + rnormal(0,5)

gen earnings2 = 15000 + 2500*treat + 100 * treat*het + 10.25*age + -0.5*age_sq + 25000*gpa + -0.5*gpa_sq + 500*interaction + rnormal(0,5)

* OLS on linear model. - BLUE
reg earnings1 treat
reg earnings1 treat age gpa
reg earnings1 treat##c.age gpa
reg earnings1 treat##c.age treat##c.gpa

* OLS on nonlinear model. 
reg earnings2 treat
reg earnings2 treat age gpa
reg earnings2 treat##c.age gpa
reg earnings2 treat##c.age treat##c.gpa

* Nearest neighbor match on age and high school gpa for the ATET using euclidean distance
teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(eucl) generate(match1) 

teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(eucl) generate(match2)  biasadj(age gpa)

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(eucl) generate(match3) 

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(eucl) generate(match4)  biasadj(age gpa)


* Nearest neighbor match on age and high school gpa for the ATET using Maha distance
teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(maha) generate(match5) 

teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(maha) generate(match6)  biasadj(age gpa)

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(maha) generate(match7) 

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(maha) generate(match8)  biasadj(age gpa)


* Nearest neighbor match on age and high school gpa for the ATET using inverse d sample covariate covariance distance
teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(ivar) generate(match9) 

teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(ivar) generate(match10)  biasadj(age gpa)

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(ivar) generate(match11) 

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(ivar) generate(match12)  biasadj(age gpa)


