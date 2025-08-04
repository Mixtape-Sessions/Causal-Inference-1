********************************************************************************
* name: hansen_long.do
* author: scott cunningham (baylor)
* description: replicate parts of hansen's 2015 AER (longer for exposition)
* last updated: sept 11, 2022
********************************************************************************
clear
capture log close

* Install packages:
* net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
* net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
* net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
* ssc install cmogram 

use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear

* Checking for manipulation in the running variable first by plotting a histogram
hist bac1, discrete width(0.001) color(gs10%90) scheme(sj) xline(0.08) title("BAC Histogram")

rddensity bac1, c(0.08) plot

* Create treatment dummy for whether you were arrested for a DUI (bac1>=0.08 and you are arrested)
gen		dui = 0
replace dui = 1 if bac1>=0.08 & bac1~=.

* rescale or recenter the running variable around the cutoff by subtracting 0.08 from the bac1 variable
ren bac1 bac1_orig
gen bac1=bac1_orig-0.08

* Checking for manipulation in the running variable first by plotting a histogram
hist bac1_orig, discrete width(0.001) color(gs13%60) scheme(sj) xline(0.08)
hist bac1, discrete width(0.001) color(gs13%60) scheme(sj) xline(0.0)
hist bac1_orig, discrete width(0.001) color(gs13%60) scheme(sj) xline(0.08)

rddensity bac1, c(0) plot

* Regression model is Y = D + BAC + DBAC + Covariates + e

* Checking for covariate balance
reg male dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg white dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg aged dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg acc dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust

* Let's make a few nonparametric pictures using one of our graphing preferred commands
cmogram acc bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit
cmogram male bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit
cmogram aged bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit
cmogram white bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit

* Main results. Use figures
cmogram recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) lfit histopts(bin(30))
cmogram recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, scatter cut(0.08) line(0.08) qfit histopts(bin(30))

rdplot recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, p(0) c(0.08) kernel(triangular) bwselect(msetwo)
rdplot recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, p(1) c(0.08) kernel(triangular) bwselect(msetwo)
rdplot recid bac1_orig if bac1_orig>=0.03 & bac1_orig<=0.13, p(2) c(0.08) kernel(triangular) bwselect(msetwo)

* Main results. local polynomial regressions with rectangular kernel
gen bac1_sq = bac1^2
reg recid dui##c.bac1 if bac1_orig>=0.03 & bac1_orig<=0.13, robust
reg recid dui##c.(bac1 bac1_sq) if bac1_orig>=0.03 & bac1_orig<=0.13, robust

* Local polynomial regressions with triangular kernel and optimal bandwidth

rdrobust recidivism bac1_orig, p(0) c(0.08) kernel(triangular) bwselect(msetwo) all
rdrobust recidivism bac1_orig, p(1) c(0.08) kernel(triangular) bwselect(msetwo) all
rdrobust recidivism bac1_orig, p(2) c(0.08) kernel(triangular) bwselect(msetwo) all

* Donut hole and repeat the above
drop if bac1_orig>=0.079 & bac1_orig<=0.081

