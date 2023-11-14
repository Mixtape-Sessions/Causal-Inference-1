clear all
set obs 100

* Create a variable for the variance of the propensity score among the treated
gen var_pscore_1 = _n * 0.0025

* Set fixed values
local rho 0.5
local var_pscore_0 0.1

* Calculate the weight
gen weight1 = (1 - `rho') * `var_pscore_0' / (`rho' * var_pscore_1 + (1 - `rho') * `var_pscore_0')

* Create the graph
twoway (line weight1 var_pscore_1, lcolor(black) lwidth(medium) lpattern(solid)), ytitle("Weight on APLE,1") xtitle("Variance of Propensity Score among Treated") title("Weight on APLE1 and Var(P(X)|D=1]") note("P(X)|D=1 is the propensity score for the treatment group")

graph export ./tymon_variance_weight.png, as(png) name("Graph")


