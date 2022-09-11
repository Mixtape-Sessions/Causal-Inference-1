********************************************************************************
* name: hansen_long.do
* author: scott cunningham (baylor)
* description: replicate parts of hansen's 2015 AER (longer for exposition)
* last updated: sept 11, 2022
********************************************************************************
clear
capture log close

use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear

* Checking for manipulation in the running variable first by plotting a histogram
hist bac1, discrete color(gs13%60) scheme(sj) xline(0.08)

gen		dui = 0
replace dui = 1 if bac1>=0.08 & bac1~=.

ren bac1 bac1_orig
gen bac1=bac1_orig-0.08

rddensity bac1, c(0) plot

* Regression model is Y = D + BAC + DBAC + Covariates + e

* Checking for covariate balance
reg white dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg male dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg aged dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg acc dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust

* Let's make a few nonparametric pictures using one of our graphing preferred commands
cmogram white bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, cut(0.08) line(0.08) lfit
cmogram male bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, cut(0.08) line(0.08) lfit
cmogram aged bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, cut(0.08) line(0.08) lfit
cmogram acc bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, cut(0.08) line(0.08) lfit

* Main results. Use figures
cmogram recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit histopts(bin(30))
cmogram recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) qfit histopts(bin(30))

rdplot recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, p(1) c(0.08) kernel(triangular) bwselect(msetwo)
rdplot recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, p(2) c(0.08) kernel(triangular) bwselect(msetwo)

* Main results. local polynomial regressions with triangular kernel
rdrobust recidivism bac1_orig, p(1) c(0.08) kernel(triangular) bwselect(msetwo)
rdrobust recidivism bac1_orig, p(2) c(0.08) kernel(triangular) bwselect(msetwo)


* Donut hole
drop if bac1_orig>=0.079 & bac1_orig<=0.081

rdrobust recidivism bac1_orig, p(1) c(0.08) kernel(triangular) bwselect(msetwo)
rdrobust recidivism bac1_orig, p(2) c(0.08) kernel(triangular) bwselect(msetwo)
