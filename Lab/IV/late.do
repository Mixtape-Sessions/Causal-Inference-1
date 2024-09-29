* LATE interpretation of IV. Work in progress. I have potential outcomes, but now I need potential treatment status (d0 and d1). 

clear
capture log close
set seed 20200403

* 100,000 people 

set obs 10000
gen person = _n

* Unobserved ability, the instrument and our treatment (school)
gen 	ability = rnormal()
su 		ability
replace ability = ability - `r(mean)'

gen 	iv = rnormal()
replace iv = 0 if iv<0
replace iv = 1 if iv>0


/*
Need to fix this part. I have to have the potential treatment status

gen 	index = 6 + 100*iv + 100*ability + rnormal(0,1)
su index, de

gen 	college = 0
replace college = 1 if index>=`r(p75)'

gen 	y0 = 1500 + 750*college + 400*ability  + rnormal(0,1)
gen 	y1 = y0 + 1550 + 1000*college + 500*college*ability + rnormal(0,1)

gen 	delta = y1-y0
su delta

gen 	earnings = college*y1 + (1-college)*y0

reg earnings college // ATE is 1941 but OLS is 4472.794
su delta

* Two stage least squares (i.e., Wald IV)
ivregress 2sls earnings (college = iv), robust first

* Note it is still wrong, but it is only the ATE for the LATE. 

*/

