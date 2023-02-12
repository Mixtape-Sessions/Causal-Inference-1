*****************************************************
* name: iv_simulation.do
* author: scott cunningham (baylor)
* description: simulation with constant and heterogenous treatment effects
*****************************************************
clear
capture log close
set seed 20200403

* 100,000 people with differing levels of covid symptoms

set obs 100000
gen person = _n


* Treatment and unobserved ability
gen 	ability = rnormal()

gen 	iv = rnormal()

gen 	school = 6 + 2*iv + 100*ability + rnormal(0,1)
replace school = 1 if school<0
sort school

quietly su school, detail

gen 	hs = 0
replace hs = 1 if school > 12

* Constant treatment effects
gen age = runiform(18,65)
gen 	earnings1 = 7450 + 1000*hs + 500*ability + 10.25*age + rnormal(0,1)

* Heterogenous treatment effects: Potential outcomes with (Y1) and without (Y0) college
sum age
gen 	het = (age - `r(mean)') 

gen earnings2 = 7450 + 1000*hs + 500 * hs*het + 500*ability + 10.25*age + rnormal(0,1)


ivregress 2sls earnings1 age (hs = iv), robust
ivregress 2sls earnings2 age (hs = iv), robust
