clear 
capture log close

cd "/Users/scott_cunningham/Documents/Causal-Inference-1/Lab/Matching"

/* Four programs:

		1. co_te: constant treatment effects, polynomials, good overlap
		2. cpo_te: constant treatment effects, polynomials, poor overlap
		3. het_te: heterogenous treatment effects, polynomials, good overlap
		4. hetpo_te: heterogenous treatment effects, polynomials, poor overlap
		
*/

* 1. Constant treatment effects, good overlap
clear all
program define co_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		
	gen 	gpa = rnormal(2.3,0.5) 		

	gen y0 = 15000 + 10.25*age + 1000*gpa + rnormal(0,5)
	gen y1 = y0 + 2500 
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2500

	gen earnings = treat*y1 + (1-treat)*y0

	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	reg earnings treat age gpa, robust 
	local co_te1=_b[treat]
	scalar co_te1 = `co_te1'
	gen co_te1=`co_te1'
		
	reg earnings treat##c.age treat##c.gpa treat##c.age##c.gpa, robust
	local co_te2=_b[1.treat]
	scalar co_te2 = `co_te2'
	gen co_te2=`co_te2'
	
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) 
	matrix co_te3 = e(b)
	matrix list co_te3
	local co_te3 = `co_te3'
	gen co_te3=`co_te3'
	
	teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) biasadj(age gpa)
	
	
    end 

	
** 1. Good overlap, constant treatment effects, polynomials
simulate co_te1 co_te2 , reps(1000): co_te

save ./data/co.dta, replace	

use ./data/co.dta, replace	


* Figure1: non-saturated, age and gpa only
kdensity _sim_1, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2500.186 2500)  xline(2500.186, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated model) ytitle("") title("") note("")

graph save "Graph" "./figures/co_sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq
kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2500.188 2500)  xline(2500.188, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated model) ytitle("") title("") note("")

graph save "Graph" "./figures/co_sim2.gph", replace


graph combine ./figures/co_sim1.gph ./figures/co_sim2.gph, title(Kernel density plots four two OLS specifications) subtitle(Constant treatment effects and good overlap) note(Two regression specifications (without and with saturation) and 1000 simulations)

graph save "Graph" "./figures/co_combined_kernels.gph", replace
graph export ./figures/co_combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace




	
* 2. Constant treatment effects, poor overlap
clear all
program define cpo_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(27.5,1.75) 	if treat==0
	gen 	gpa = rnormal(2.3,0.5) 		if treat==0
	replace gpa = rnormal(1.76,0.45) 	if treat==1

	gen y0 = 15000 + 10.25*age + 1000*gpa + rnormal(0,5)
	gen y1 = y0 + 2500 
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2500

	gen earnings = treat*y1 + (1-treat)*y0

	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'

	reg earnings treat age gpa, robust 
	local cpo_te1=_b[treat]
	scalar cpo_te1 = `cpo_te1'
	gen cpo_te1=`cpo_te1'
		
	reg earnings treat##c.age treat##c.gpa treat##c.age##c.gpa, robust
	local cpo_te2=_b[1.treat]
	scalar cpo_te2 = `cpo_te2'
	gen cpo_te2=`cpo_te2'
	

    end 

	
simulate cpo_te1 cpo_te2 , reps(1000): cpo_te
save ./data/cpo.dta, replace	

use ./data/cpo.dta, replace	


* Figure1: non-saturated, age and gpa only
kdensity _sim_1, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2499.923 2500) xline(2499.923, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age and gpa) ytitle("") title("") note("")

graph save "Graph" "./figures/cpo_sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq
kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2500 2499.942)  xline(2499.942, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age gpa and polynomials) ytitle("") title("") note("")

graph save "Graph" "./figures/cpo_sim2.gph", replace



graph combine ./figures/cpo_sim1.gph ./figures/cpo_sim2.gph ./figures/cpo_sim3.gph ./figures/cpo_sim4.gph, title(Kernel density plots two OLS specifications) subtitle(Constant treatment effects and poor overlap) note(Two regression specifications (without and with saturation) and 1000 simulations)

graph save "Graph" "./figures/cpo_combined_kernels.gph", replace
graph export ./figures/cpo_combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace
	
	
* 3. Heterogenous treatment effects, good overlap
clear all
program define het_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		
	gen 	gpa = rnormal(2.3,0.5) 		

	gen interaction=gpa*age
	su interaction 
	replace interaction = interaction - `r(mean)'
	
	gen age_sq = age^2
	gen gpa_sq = gpa^2
	
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'
	
	su age_sq
	replace age_sq = age_sq - `r(mean)'
	
	su gpa_sq
	replace gpa_sq = gpa_sq - `r(mean)'


	gen y0 = 15000 + 10.25*age + 1000*gpa + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 505 * age + 1000*gpa - 1000*interaction - 25*age_sq + 1000*gpa_sq
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2610

	gen earnings = treat*y1 + (1-treat)*y0
	   
	reg earnings treat age gpa, robust 
	local het_te1=_b[treat]
	scalar het_te1 = `het_te1'
	gen het_te1=`het_te1'
		

	reg earnings treat##c.age treat##c.gpa treat##c.age##c.gpa, robust
	local het_te2=_b[1.treat]
	scalar het_te2 = `het_te2'
	gen het_te2=`het_te2'
	

    end 
	

simulate het_te1 het_te2 , reps(1000): het_te

save ./data/het.dta, replace	

use ./data/het.dta, replace	

* Figure1: non-saturated, age and gpa only
kdensity _sim_1, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2500 2500.363) xline(2500.363, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age and gpa) ytitle("") title("") note("")

graph save "Graph" "./figures/het_sim1.gph", replace


* Figure3: saturated treatment with age gpa and interactions
kdensity _sim_3, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2499.981 2500) xline(2499.981, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./figures/het_sim3.gph", replace


graph combine ./figures/het_sim1.gph ./figures/het_sim2.gph ./figures/het_sim3.gph ./figures/het_sim4.gph, title(Kernel density plots four four OLS specifications) subtitle(Heterogenous treatment effects and good overlap) note(Four regression specifications and estimates from 1000 simulations)

graph save "Graph" "./figures/het_combined_kernels.gph", replace
graph export ./figures/het_combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace
		

		
		
* 4. Heterogenous treatment effects, poor overlap
clear all
program define hetpo_te, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

    clear 
    drop _all 
	set obs 5000
	gen 	treat = 0 
	replace treat = 1 in 2501/5000
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(27.5,1.75) 	if treat==0
	gen 	gpa = rnormal(2.3,0.5) 		if treat==0
	replace gpa = rnormal(1.76,0.45) 	if treat==1

	gen interaction=gpa*age
	su interaction 
	replace interaction = interaction - `r(mean)'
	
	gen age_sq = age^2
	gen gpa_sq = gpa^2
	
	su age
	replace age = age - `r(mean)'

	su gpa
	replace gpa = gpa - `r(mean)'
	
	su age_sq
	replace age_sq = age_sq - `r(mean)'
	
	su gpa_sq
	replace gpa_sq = gpa_sq - `r(mean)'

	gen y0 = 15000 + 10.25*age + 1000*gpa + 500*interaction + rnormal(0,5)
	gen y1 = y0 + 2500 + 505 * age + 10*gpa - 10*interaction - 2*age_sq - 500*gpa_sq
	gen delta = y1 - y0

	su delta // ATE = 2500
	su delta if treat==1 // ATT = 2676

	gen earnings = treat*y1 + (1-treat)*y0
	   
	reg earnings treat age gpa, robust 
	local hetpo_te1=_b[treat]
	scalar hetpo_te1 = `hetpo_te1'
	gen hetpo_te1=`hetpo_te1'
		
	reg earnings treat##c.age treat##c.gpa treat##c.age##c.gpa, robust
	local hetpo_te2=_b[1.treat]
	scalar hetpo_te2 = `hetpo_te2'
	gen hetpo_te2=`hetpo_te2'
	
    end 

		
simulate hetpo_te1 hetpo_te2 hetpo_te3 hetpo_te4, reps(1000): hetpo_te

save ./data/hetpo.dta, replace	

use ./data/hetpo.dta, replace	


* Figure1: non-saturated, age and gpa only
kdensity _sim_1, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2423.105 2500) xline(2423.105, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age and gpa) ytitle("") title("") note("")

graph save "Graph" "./figures/hetpo_sim1.gph", replace

* Figure2: non-saturated, age, age-sq, gpa, gpa-sq
kdensity _sim_2, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2423.216 2500)  xline(2423.216, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Non-saturated controls age gpa and polynomials) ytitle("") title("") note("")

graph save "Graph" "./figures/hetpo_sim2.gph", replace

* Figure3: saturated treatment with age gpa and interactions
kdensity _sim_3, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2467.159 2500) xline(2467.159, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa and interactions) ytitle("") title("") note("")

graph save "Graph" "./figures/hetpo_sim3.gph", replace

* Figure4: saturated treatment with age gpa polynomials and interactions
kdensity _sim_4, xtitle(Estimated ATE) xline(2500, lwidth(medthick) lpattern(dash) lcolor(blue) extend) xlabel(minmax 2500 2500.012) xline(2500.012, lwidth(med) lpattern(solid) lcolor(red) extend) subtitle(Saturated w/ age gpa polynomials and interactions) ytitle("") title("") xlabel(2500) note("")

graph save "Graph" "./figures/hetpo_sim4.gph", replace

graph combine ./figures/hetpo_sim1.gph ./figures/hetpo_sim2.gph ./figures/hetpo_sim3.gph ./figures/hetpo_sim4.gph, title(Kernel density plots four four OLS specifications) subtitle(Heterogenous treatment effects and poor overlap) note(Four regression specifications and estimates from 1000 simulations)

graph save "Graph" "./figures/hetpo_combined_kernels.gph", replace
graph export ./figures/hetpo_combined_kernels.jpg, as(jpg) name("Graph") quality(90) replace
		
				