* This simulation is intended to illustrate practical challenges when faced with data generating processes that do not satisfy the requirements of exogeneity and the most common estimation procedures and specifications used.  The DGP will be as follows:

* 1. Simple linearity with homogenous treatment effects, two covariates and good overlap using OLS and inexact matching with and without bias adjustment, as well as full saturation. 
* 2. Simple linearity with heterogenous treatment effects, two covariates and good overlap using OLS and inexact matching with and without bias adjustment, as well as full saturation. 
* 3. Simple linearity with heterogenous treatment effects, two covariates and poor overlap using OLS and inexact matching with and without bias adjustment, as well as full saturation. 
* 4. Linearity with heterogenous treatment effects, two covariates and quadratics and poor overlap using OLS and inexact matching with and without bias adjustment, as well as full saturation.
* 5. Nonlinearity, non-smooth with heterogenous treatment effects that vary with one covariate and poor overlap using OLS and inexact matching with and without bias adjustment, as well as full saturation.

clear
capture log close
set seed 10500

set obs 5000
gen 	person = _n

gen 	treat = 0 
replace treat = 1 in 2501/5000


* 1. Good overlap, constant treatment effects, linearity
gen 	age = rnormal(30,2)
gen 	gpa = rnormal(2.75,2)

su age
replace age = age - `r(mean)'
su gpa
replace gpa = gpa - `r(mean)'

gen y0 = 15000 + 10.25*age + 1000*gpa + rnormal(0,5)
gen y1 = y0 + 2500 

gen delta = y1 - y0

su delta // ATE = 2500
su delta if treat==1 // ATT = 2500
drop delta

gen 	earnings1 = treat*y1 + (1-treat)*y0


reg earnings1 treat age gpa, robust
reg earnings1 treat##c.age treat##c.gpa treat##c.age##c.gpa, robust

teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(maha) 
teffects nnmatch (earnings1 age gpa) (treat), ate nn(1) metric(maha) biasadj(age gpa)

teffects nnmatch (earnings1 age gpa) (treat), atet nn(1) metric(maha) 
teffects nnmatch (earnings1 age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)

drop y0 y1

* 2. Good overlap, heterogeneous treatment effects
gen y0 = 15000 + 10.25*age + 1000*gpa + rnormal(0,5)
gen y1 = y0 + 2500 + 100 * age + 1000*gpa 
gen delta = y1 - y0

su delta // ATE = 2500
su delta if treat==1 // ATT = 2505

gen 	earnings2 = treat*y1 + (1-treat)*y0


reg earnings2 treat age gpa, robust
reg earnings2 treat##c.age treat##c.gpa treat##c.age##c.gpa, robust

teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(maha) 
teffects nnmatch (earnings2 age gpa) (treat), ate nn(1) metric(maha) biasadj(age gpa)

teffects nnmatch (earnings2 age gpa) (treat), atet nn(1) metric(maha) 
teffects nnmatch (earnings2 age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)

* 3. Poor overlap, heterogeneous treatment effects, no polynomials

drop age gpa y0 y1 delta 

gen 	age = rnormal(25,2.5) 		if treat==1
replace age = rnormal(27.5,1.75) 	if treat==0
gen 	gpa = rnormal(2.3,0.5) 		if treat==0
replace gpa = rnormal(1.76,0.45) 	if treat==1

su age
replace age = age - `r(mean)'

su gpa
replace gpa = gpa - `r(mean)'

* Illustrate overlap problems
twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), title(Age by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

twoway (histogram gpa if treat==1,  color(green)) ///
       (histogram gpa if treat==0,  ///
	   fcolor(none) lcolor(black)), title(GPA by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

gen y0 = 15000 + 10.25*age + 1000*gpa + rnormal(0,5)
gen y1 = y0 + 2500 + 100 * age + 1000*gpa
gen delta = y1 - y0

su delta // ATE = 2500
su delta if treat==1 // ATT = 2102

gen 	earnings3 = treat*y1 + (1-treat)*y0


reg earnings3 treat age gpa, robust
reg earnings3 treat##c.age treat##c.gpa treat##c.age##c.gpa, robust

teffects nnmatch (earnings3 age gpa) (treat), ate nn(1) metric(maha) 
teffects nnmatch (earnings3 age gpa) (treat), ate nn(1) metric(maha) biasadj(age gpa)

teffects nnmatch (earnings3 age gpa) (treat), atet nn(1) metric(maha) 
teffects nnmatch (earnings3 age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)
	   
* 4. Poor overlap, heterogenous treatment effects, polynomials

drop age gpa y0 y1 delta 

gen 	age = rnormal(25,2.5) 		if treat==1
replace age = rnormal(27.5,1.75) 	if treat==0
gen 	gpa = rnormal(2.3,0.5) 		if treat==0
replace gpa = rnormal(1.76,0.45) 	if treat==1

su age
replace age = age - `r(mean)'

su gpa
replace gpa = gpa - `r(mean)'

gen age_sq = age^2
gen gpa_sq = gpa^2
gen interaction=gpa*age

gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0,5)
gen y1 = y0 + 2500 + 100 * age + 1000*gpa
gen delta = y1 - y0

su delta // ATE = 2500
su delta if treat==1 // ATT = 2106

gen 	earnings4 = treat*y1 + (1-treat)*y0
	   
reg earnings4 treat age gpa, robust
reg earnings4 treat##c.age treat##c.gpa treat##c.age##c.gpa, robust

teffects nnmatch (earnings4 age gpa) (treat), ate nn(1) metric(maha) 
teffects nnmatch (earnings4 age gpa) (treat), ate nn(1) metric(maha) biasadj(age gpa)

teffects nnmatch (earnings4 age gpa) (treat), atet nn(1) metric(maha) 
teffects nnmatch (earnings4 age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)
	   
* Illustrate overlap problems
twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), title(Age by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

twoway (histogram age_sq if treat==1,  color(green)) ///
       (histogram age_sq if treat==0,  ///
	   fcolor(none) lcolor(black)), title(Age-squared by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

twoway (histogram gpa if treat==1,  color(green)) ///
       (histogram gpa if treat==0,  ///
	   fcolor(none) lcolor(black)), title(GPA by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

twoway (histogram gpa_sq if treat==1,  color(green)) ///
       (histogram gpa_sq if treat==0,  ///
	   fcolor(none) lcolor(black)), title(GPA-squared by treatment status) legend(order(1 "Treated" 2 "Not treated" ))
	   
* 5. Potential outcomes, non-smooth, non-linear, step function in age

drop age y0 y1 delta

gen 	age = rnormal(25,2.5) 		if treat==0
replace age = rnormal(30,1.5) 		if treat==1

* Illustrate overlap problems
twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), title(Age by treatment status) legend(order(1 "Treated" 2 "Not treated" ))

su age, detail

gen 	y0 = rnormal()
replace y0 = 200 + rnormal() if age < `r(p25)'
replace y0 = 25 + runiform() if age>= `r(p25)' & age<=`r(p75)'
replace y0 = 85 + rnormal() if age>`r(p75)'

gen  	y1 = -50
replace y1 = y0 + 2000 if age < `r(p25)'
replace y1 = y0 + 100  if age>= `r(p25)' & age<=`r(p75)'
replace y1 = y0 + 1150 if age>`r(p75)'

gen delta = y1-y0

su delta // ATE = 838
su delta if treat==1 // ATT = 993

gen 	earnings5 = treat*y1 + (1-treat)*y0

replace age = age - `r(mean)'

reg earnings5 treat age
reg earnings5 treat##c.age

teffects nnmatch (earnings5 age) (treat), ate nn(1) metric(maha) 
teffects nnmatch (earnings5 age) (treat), ate nn(1) metric(maha) biasadj(age)

teffects nnmatch (earnings5 age) (treat), atet nn(1) metric(maha) 
teffects nnmatch (earnings5 age) (treat), atet nn(1) metric(maha) biasadj(age)

