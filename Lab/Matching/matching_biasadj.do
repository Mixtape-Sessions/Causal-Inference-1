* Simulated data, nearest neighbor matching, with and without bias adjustment.
clear all
program define match_bc, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	
	* Poor pre-treatment fit
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(30,3) 		if treat==0
	gen 	gpa = rnormal(2.3,0.75) 	if treat==0
	replace gpa = rnormal(1.76,0.5) 	if treat==1
	
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	* All combinations 
	gen age_sq 		= age^2
	gen gpa_sq 		= gpa^2
	gen interaction	= gpa*age

	gen y0 = 15000 + 10.25*age + -10.5*age_sq + 1000*gpa + -10.5*gpa_sq + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 100 * age + 1000 * gpa
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 1980
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	gen earnings = treat*y1 + (1-treat)*y0
 
** Mis-specified models 
* No bias correction
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local match1 = b[1,1]
	scalar match1=`match1'
	gen match1=`match1'

* With bias correction
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)
	mat b=e(b)
	local match2 = b[1,1]
	scalar match2=`match2'
	gen match2=`match2'
	
** Correctly specified models 
* No bias correction
	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local match3 = b[1,1]
	scalar match3=`match3'
	gen match3=`match3'

* With bias correction
	teffects nnmatch (earnings age gpa age_sq gpa_sq interaction) (treat), atet nn(1) metric(maha) biasadj(age gpa age_sq gpa_sq interaction)
	mat b=e(b)
	local match4 = b[1,1]
	scalar match4=`match4'
	gen match4=`match4'

** Overfitted models 
gen age_3 = age^3
gen gpa_3 = gpa^3

* No bias correction
	teffects nnmatch (earnings age gpa interaction age_sq gpa_sq age_3 gpa_3) (treat), atet nn(1) metric(maha) 
	mat b=e(b)
	local match5 = b[1,1]
	scalar match5=`match5'
	gen match5=`match5'

* With bias correction
	teffects nnmatch (earnings age gpa interaction age_sq gpa_sq age_3 gpa_3) (treat), atet nn(1) metric(maha) biasadj(age gpa interaction age_sq gpa_sq age_3 gpa_3)
	mat b=e(b)
	local match6 = b[1,1]
	scalar match6=`match6'
	gen match6=`match6'
	 
collapse (max) att match1 match2 match3 match4 match5 match6
	 
    end 

simulate att match1 match2 match3 match4 match5 match6, reps(1000): match_bc

capture log close
exit

* Set up the graph for those who want it
set scheme white_tableau

* Define colors and line patterns that work well in color and grayscale
local c1 "blue"
local c2 "red"
local p1 "solid"
local p2 "dash"

* Create the graphs
twoway (kdensity *sim*2, color(`c1') lpattern(`p1')) ///
       (kdensity *sim*3, color(`c2') lpattern(`p2')) ///
       (pci 0 1980 0.05 1980, lcolor(black) lpattern(dot)), ///
       title("Underfit Model") ///
       xtitle("") ytitle("Density", size(small) margin(r=2)) ///
       xline(1980, lwidth(medthick) lcolor(black) lpattern(tight_dot)) ///
       xlabel(1920(40)2100, labsize(vsmall)) ///
       ylabel(0(0.01)0.045, labsize(small)) ///
       legend(order(1 "Non-bias-corrected" 2 "Bias-corrected" 3 "True ATT ($1800)") rows(1) size(small)) ///
       note("Controls for age and gpa only", size(vsmall)) ///
       name(g1, replace) yscale(range(0 0.05))

twoway (kdensity *sim*4, color(`c1') lpattern(`p1')) ///
       (kdensity *sim*5, color(`c2') lpattern(`p2')) ///
       (pci 0 1980 0.05 1980, lcolor(black) lpattern(dot)), ///
       title("Correctly Specified Model") ///
       xtitle("") ytitle("") ///
       xline(1980, lwidth(medthick) lcolor(black) lpattern(tight_dot)) ///
       xlabel(1920(40)2100, labsize(vsmall)) ///
       ylabel(0(0.01)0.045, labsize(small)) ///
       legend(off) ///
       note("Controls for age and gpa, age-squared and" "gpa-squared, and age×gpa interaction", size(vsmall)) ///
       name(g2, replace) yscale(range(0 0.05))

twoway (kdensity *sim*6, color(`c1') lpattern(`p1')) ///
       (kdensity *sim*7, color(`c2') lpattern(`p2')) ///
       (pci 0 1980 0.05 1980, lcolor(black) lpattern(dot)), ///
       title("Overfit Model") ///
       xtitle("") ytitle("") ///
       xline(1980, lwidth(medthick) lcolor(black) lpattern(tight_dot)) ///
       xlabel(1920(40)2100, labsize(vsmall)) ///
       ylabel(0(0.01)0.045, labsize(small)) ///
       legend(off) ///
       note("Controls for age, age-squared, age-cubed, gpa," "gpa-squared, gpa-cubed and age×gpa interaction", size(vsmall)) ///
       name(g3, replace) yscale(range(0 0.05))

* Combine graphs with a common legend
grc1leg g1 g2 g3, ///
    rows(1) ///
    legendfrom(g1) ///
    title("Comparison of ATT Estimates Across Model Specifications", size(medium)) ///
    subtitle("Kernel density estimates of ATT from 1,000 simulations", size(small)) ///
    l1title("") b1title("") ///
    xsize(16) ysize(7)

* Export the graph
graph export "../graphics/att_estimates_comparison.png", replace width(1600) height(770)

