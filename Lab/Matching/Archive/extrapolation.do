* Visualizing common support with two DGP

* Common support, linearity DGP
clear
capture log close
set seed 10500

set obs 5000
gen age = rnormal(30,0.75)
gen age_sq = age*age


gen earnings = 10000 - 100*age + age_sq + rnormal(0,250)

reg earnings c.age##c.age_sq
predict yhat

* Generate a dataset with the age range you want for extrapolation (e.g., 0 to 50)
gen id = _n
expand 50
bys id: gen new_age = _n
gen new_age_sq = new_age*new_age
predict yhat_extrapolate if new_age != .

* Create the twoway plot with lfit and scatter
twoway (lfit yhat age) (scatter earnings age, sort), xscale(range(25 35)) yscale(range(500 1200))

capture log close
exit

* Visualizing extrapolation
scatter earnings age if treat==0, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) || scatter earnings age if treat==1, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) || line yhat age if treat==0, mcolor(red) msize(small) mlabel(treat) mlabsize(small) range(`x_min'(5)`x_max') sort || line yhat age if treat==1, mcolor(red) msize(small) mlabel(treat) mlabsize(small) range(`x_min'(5)`x_max') sort xtitle("Age") ytitle("Earnings") 



	scatter earnings age if treat == 1, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) || lfit earnings age if treat == 1, mcolor(red) msize(small) mlabel(treat) mlabsize(small) xlabel(`x_min'(5)`x_max') subtitle(Treated) 
	
	graph save "Graph" "./extrapolate1_good.gph", replace

	* Visualizing extrapolation for control
	scatter earnings age if treat == 0, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) || lfit earnings age if treat == 0, mcolor(red) msize(small) mlabel(treat) mlabsize(small) xlabel(`x_min'(5)`x_max') subtitle(Control) 

	graph save "Graph" "./extrapolate2_good.gph", replace
	
	graph combine ./extrapolate1_good.gph ./extrapolate2_good.gph, title(Visualizing extrapolation) subtitle(Linear DGP and common support) 
	
	graph save "Graph" "./combined_extrapolate_good.gph", replace
	graph export ./combined_extrapolate_good.jpg, as(jpg) name("Graph") quality(90) replace
	

	* Lack of support, nonlinear DGP
    clear 
    drop _all 
	set seed 1234
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		if treat==0
	replace age = rnormal(30,1.5) 		if treat==1

	su age
	replace age = age - `r(mean)'

	su age, detail
	replace age = age - `r(mean)'
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
	gen earnings = treat*y1 + (1-treat)*y0
	
	* Extend the x-axis rangeto illustrate the extrapolation beyond the support of the data
	su age
	local x_min = `r(min)' - 2
	local x_max = `r(max)' + 2

	* Visualizing extrapolation for treated
	scatter earnings age if treat == 1, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) xlabel(`x_min'(5)`x_max') || lfit earnings age if treat == 1, mcolor(red) msize(small) mlabel(treat) mlabsize(small) xlabel(`x_min'(5)`x_max') subtitle(Treated) 
	
	graph save "Graph" "./extrapolate1.gph", replace

	* Visualizing extrapolation for control
	scatter earnings age if treat == 0, mcolor(blue) msize(small) mlabel(treat) mlabsize(small) || lfit earnings age if treat == 0, mcolor(red) msize(small) mlabel(treat) mlabsize(small) xlabel(`x_min'(5)`x_max') subtitle(Control) 

	graph save "Graph" "./extrapolate2.gph", replace
	
	graph combine ./extrapolate1.gph ./extrapolate2.gph, title(Visualizing extrapolation) subtitle(Nonlinear DGP and no common support) 
	
	graph save "Graph" "./combined_extrapolate.gph", replace
	graph export ./combined_extrapolate.jpg, as(jpg) name("Graph") quality(90) replace
	
	graph combine ./extrapolate1_good.gph ./extrapolate2_good.gph ./extrapolate1.gph ./extrapolate2.gph, title(Visualizing extrapolation) subtitle(Linearity and common support) 
	
	graph export ./combined_extrapolate_all.jpg, as(jpg) name("Graph") quality(90) replace


