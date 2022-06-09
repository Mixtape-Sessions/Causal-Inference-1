******************************************************************************************
* name: hansen.do
* author: scott cunningham (baylor)
* description: replicate figures and tables in Hansen 2015 AER
* last updated: december 5, 2021
******************************************************************************************

capture log close
clear
cd "/Users/scott_cunningham/Dropbox/CI Workshop/Assignments/Hansen"
capture log using ./hansen.log, replace

* ssc install gtools
* net install binscatter2, from("https://raw.githubusercontent.com/mdroste/stata-binscatter2/master/")
* ssc install cmogram
* lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace
* Load the raw data into memory
* net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
* ssc install rdrobust, replace
* net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
* net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace

* load the data from github
use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear

* Re-center our running variable at bac1=0.08
ren bac1 bac1_old
gen bac1=bac1_old-0.08

* Q1a: create some treatment variable for bac1>=0.08
gen dui = 0
replace dui = 1 if bac1_old>=0.08 & bac1~=. // Stata when it sees a period (missing) in a variableit 
// thinks that that observation is equal to positive infinity. And so since positive infinity
// is greater than 0.08, it will assign dui = 1 for that missing value which can create
// major problems. 

* Q1b: Find evidence for manipulation or HEAPING using histograms
histogram bac1, discrete width(0.001) ytitle(Density) xtitle(Running variable (blood alcohol content)) xline(0.0) title(Density of observations across the running variable)

* use the Cattaneo, et al. -rddensity-
rddensity bac1, c(0.0) plot

* Q2: Table 2 on white, male, aged, and acc
* yi = Xi′γ + α1DUIi + α2BACi + α3BACi × DUIi + ui
* Are the covariates balanced at the cutoff? Use two separate bandwidths (0.03 to 0.13; 0.055 to 0.105) 

reg white dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg male dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg acc dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust
reg aged dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q3: Create Figure 2 panel A-D using cmogram on our covariates (white, male, age, acc)
* cmogram outcome running variable, cut(cutoff) scatter line(cutoff) polynomial
cmogram white bac1, cut(0.0) scatter line(0.0)
cmogram white bac1, cut(0.0) scatter line(0.0) lfitci
cmogram white bac1, cut(0.0) scatter line(0.0) qfitci

* scatter
twoway (scatter white bac1  if bac1_old>=0.03 & bac1_old<=0.13, sort) if bac1_old>=0.03 & bac1_old<=0.13, ytitle(White means) xtitle(Blood alcohol content running variable) xline(0.08) title(Covariate test on whites) note(Cutoff is at blood alcohol content of 0.08)

* binscatter
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui)
binscatter white bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui) line(qfit)

* Q4a: Our main results. regression of recidivism onto the equation (1) model with linear bac1. 
reg recidivism dui bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q4b: Our main results. regression of recidivism onto the equation (1) model with interacted linear bac1. 
reg recidivism dui##c.bac1 if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q4c: Our main results. regression of recidivism onto the equation (1) model with interacted linear and quadratic bac1. 
gen bac1_squared = bac1^2
reg recidivism dui##c.(bac1 bac1_squared) if bac1_old>=0.03 & bac1_old<=0.13, robust

* Q5: "donut hole" dropping close to 0.08 (we'll discuss why later)
preserve
drop if bac1_old>=0.079 & bac1_old<=0.081
reg recidivism dui##c.(bac1) if bac1_old>=0.03 & bac1_old<=0.13, robust
rdrobust recidivism bac1, c(0.0) p(1) bwselect(msetwo) all
restore

* Q6: Figure 3 using less than 0.15 bac on the bac1
cmogram recidivism bac1, cut(0.0) scatter line(0.0) lfitci
cmogram recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, cut(0.0) scatter line(0.0) lfitci
cmogram recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, cut(0.0) scatter line(0.0) qfitci

binscatter recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui)
binscatter recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, by(dui) line(qfit)

* Q7: Local polynomial regressions with (default) triangular kernel and bias correction
rdrobust recidivism bac1, p(1) c(0.0)
rdrobust recidivism bac1, p(1) c(0.0) kernel(uniform)
rdrobust recidivism bac1, p(1) c(0.0) kernel(epanechnikov)

* Higher order polynomials
rdrobust recidivism bac1, p(2) c(0.0)
rdrobust recidivism bac1, p(3) c(0.0)
rdrobust recidivism bac1, p(4) c(0.0)

* RD PLOT
rdplot recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, p(0) masspoints(off) c(0.0) graph_options(title(Recidivism for BAC of 0.08))
rdplot recidivism bac1 if bac1_old>=0.03 & bac1_old<=0.13, p(2) masspoints(off) c(0.0) graph_options(title(Recidivism for BAC of 0.08))

* McCrary density test: remember it's a density test *on the running variable* (lagdemvoteshare)
rddensity bac1, c(0.0) plot
