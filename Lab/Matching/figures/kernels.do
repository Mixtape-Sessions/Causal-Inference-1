* Part 1: Rename Variables in Each Dataset and Save
clear

* File 1: Linear TS
use ols_all_linear_TS_mc.dta, clear
gen id=_n
drop att ols tymons_att ra nn nn_ba psmatch ipw_att
rename ols_bias ols_bias_linear_TS
rename tymon_bias tymon_bias_linear_TS
rename ra_bias ra_bias_linear_TS
rename nn_bias nn_bias_linear_TS
rename nnba_bias nnba_bias_linear_TS
rename psmatch_bias psmatch_bias_linear_TS
rename ipw_bias ipw_bias_linear_TS
save temp1.dta, replace

* File 2: Linear
use ols_all_linear_mc.dta, clear
gen id=_n
drop att ols tymons_att ra nn nn_ba psmatch ipw_att
rename ols_bias ols_bias_linear
rename tymon_bias tymon_bias_linear
rename ra_bias ra_bias_linear
rename nn_bias nn_bias_linear
rename nnba_bias nnba_bias_linear
rename psmatch_bias psmatch_bias_linear
rename ipw_bias ipw_bias_linear
save temp2.dta, replace

* File 3: Logistic
use ols_all_logistic_mc.dta, clear
gen id=_n
drop att ols tymons_att ra nn nn_ba psmatch ipw_att
rename ols_bias ols_bias_logistic
rename tymon_bias tymon_bias_logistic
rename ra_bias ra_bias_logistic
rename nn_bias nn_bias_logistic
rename nnba_bias nnba_bias_logistic
rename psmatch_bias psmatch_bias_logistic
rename ipw_bias ipw_bias_logistic
save temp3.dta, replace

* File 4: Logit TS
use ols_all_logit_TS_mc.dta, clear
gen id=_n
drop att ols tymons_att ra nn nn_ba psmatch ipw_att
rename ols_bias ols_bias_logit
rename tymon_bias tymon_bias_logit
rename ra_bias ra_bias_logit
rename nn_bias nn_bias_logit
rename nnba_bias nnba_bias_logit
rename psmatch_bias psmatch_bias_logit
rename ipw_bias ipw_bias_logit
save temp4.dta, replace

* File 5: Unknown
use ols_all_unknown_mc.dta, clear
gen id=_n
drop att ols tymons_att ra nn nn_ba psmatch ipw_att
rename ols_bias ols_bias_unknown
rename tymon_bias tymon_bias_unknown
rename ra_bias ra_bias_unknown
rename nn_bias nn_bias_unknown
rename nnba_bias nnba_bias_unknown
rename psmatch_bias psmatch_bias_unknown
rename ipw_bias ipw_bias_unknown
save temp5.dta, replace

* Part 2: Merge Files
use temp1.dta, clear
merge 1:1 id using temp2.dta
drop _merge
merge 1:1 id using temp3.dta
drop _merge
merge 1:1 id using temp4.dta
drop _merge
merge 1:1 id using temp5.dta
drop _merge

save merged_data.dta, replace

twoway (kdensity tymon_bias_linear_TS, lcolor(black) lwidth(thick) lpattern(solid)) (kdensity ra_bias_linear_TS, lcolor(blue) lwidth(thick) lpattern(dash)) (kdensity nn_bias_linear_TS, lcolor(red) lwidth(thick) lpattern(tight_dot)) (kdensity nnba_bias_linear_TS, lcolor(stone) lwidth(thick) lpattern(shortdash_dot)) (kdensity psmatch_bias_linear_TS, lcolor(gs10) lwidth(thick) lpattern(longdash_dot)) (kdensity ipw_bias_linear_TS, lcolor(gs5) lwidth(thick) lpattern(shortdash_dot_dot)), xtitle("Bias") title("Bias of 6 estimators with misspecification") subtitle("Normalized linear propensity score") note("ATT = $2673 and 500 simulations") legend(order(1 "Tymon's ATT" 2 "RA" 3 "NN" 4 "NN w/BA" 5 "PSM" 6 "IPW"))

graph export "./normalized_linear_kernel.png", as(png) replace

twoway (kdensity tymon_bias_linear, lcolor(black) lwidth(thick) lpattern(solid)) (kdensity ra_bias_linear, lcolor(blue) lwidth(thick) lpattern(dash)) (kdensity nn_bias_linear, lcolor(red) lwidth(thick) lpattern(tight_dot)) (kdensity nnba_bias_linear, lcolor(stone) lwidth(thick) lpattern(shortdash_dot)) (kdensity psmatch_bias_linear, lcolor(gs10) lwidth(thick) lpattern(longdash_dot)) (kdensity ipw_bias_linear, lcolor(gs5) lwidth(thick) lpattern(shortdash_dot_dot)), xtitle("Bias") title("Bias of 6 estimators with misspecification") subtitle("Linear propensity score") note("ATT = $2596 and 500 simulations") legend(order(1 "Tymon's ATT" 2 "RA" 3 "NN" 4 "NN w/BA" 5 "PSM" 6 "IPW"))

graph export "./linear_kernel.png", as(png) replace

twoway (kdensity tymon_bias_logistic, lcolor(black) lwidth(thick) lpattern(solid)) (kdensity ra_bias_logistic, lcolor(blue) lwidth(thick) lpattern(dash)) (kdensity nn_bias_logistic, lcolor(red) lwidth(thick) lpattern(tight_dot)) (kdensity nnba_bias_logistic, lcolor(stone) lwidth(thick) lpattern(shortdash_dot)) (kdensity psmatch_bias_logistic, lcolor(gs10) lwidth(thick) lpattern(longdash_dot)) (kdensity ipw_bias_logistic, lcolor(gs5) lwidth(thick) lpattern(shortdash_dot_dot)), xtitle("Bias") title("Bias of 6 estimators with misspecification") subtitle("Logistic propensity score") note("ATT = $3104 and 500 simulations") legend(order(1 "Tymon's ATT" 2 "RA" 3 "NN" 4 "NN w/BA" 5 "PSM" 6 "IPW"))

graph export "./logistic_kernel.png", as(png) replace

twoway (kdensity tymon_bias_logit, lcolor(black) lwidth(thick) lpattern(solid)) (kdensity ra_bias_logit, lcolor(blue) lwidth(thick) lpattern(dash)) (kdensity nn_bias_logit, lcolor(red) lwidth(thick) lpattern(tight_dot)) (kdensity nnba_bias_logit, lcolor(stone) lwidth(thick) lpattern(shortdash_dot)) (kdensity psmatch_bias_logit, lcolor(gs10) lwidth(thick) lpattern(longdash_dot)) (kdensity ipw_bias_logit, lcolor(gs5) lwidth(thick) lpattern(shortdash_dot_dot)), xtitle("Bias") title("Bias of 6 estimators with misspecification") subtitle("Logit propensity score") note("ATT = $5059 and 500 simulations") legend(order(1 "Tymon's ATT" 2 "RA" 3 "NN" 4 "NN w/BA" 5 "PSM" 6 "IPW"))

graph export "./logit_kernel.png", as(png) replace

twoway (kdensity tymon_bias_unknown, lcolor(black) lwidth(thick) lpattern(solid)) (kdensity ra_bias_unknown, lcolor(blue) lwidth(thick) lpattern(dash)) (kdensity nn_bias_unknown, lcolor(red) lwidth(thick) lpattern(tight_dot)) (kdensity nnba_bias_unknown, lcolor(stone) lwidth(thick) lpattern(shortdash_dot)) (kdensity psmatch_bias_unknown, lcolor(gs10) lwidth(thick) lpattern(longdash_dot)) (kdensity ipw_bias_unknown, lcolor(gs5) lwidth(thick) lpattern(shortdash_dot_dot)), xtitle("Bias") title("Bias of 6 estimators with misspecification") subtitle("Unknown propensity score") note("ATT = $1756 and 500 simulations") legend(order(1 "Tymon's ATT" 2 "RA" 3 "NN" 4 "NN w/BA" 5 "PSM" 6 "IPW"))

graph export "./unknown_kernel.png", as(png) replace
