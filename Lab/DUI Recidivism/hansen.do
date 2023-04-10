********************************************************************************
* name: hansen.do
* author: scott cunningham (baylor)
* description: replicate figures and tables in Hansen 2015 AER
* last updated: december 5, 2021
********************************************************************************

* Install packages:
* ssc install estout
* net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
* ssc install rdrobust, replace
* net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
* net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace

* load the data from github
use "https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi.dta", clear

*-> 1.a. create dui treatment variable for bac1>=0.08
  gen dui = 0
  replace dui = 1 if bac1 >= 0.08 & bac1 ~= . 
  // Stata when it sees a period (missing) in a variable it thinks that the
  // observation is equal to positive infinity. And so since positive infinity
  // is greater than 0.08, it will assign dui = 1 for that missing value which 
  // can create major problems. 

*-> 1.b. Re-center our running variable at bac1=0.08
  rename bac1 bac1_orig
  gen bac1 = bac1_orig - 0.08


*-> 1.c. Find evidence for manipulation or heaping using histograms
  histogram bac1, discrete width(0.001) ytitle(Density) xtitle(Running variable (blood alcohol content)) xline(0.0) title(Density of observations across the running variable)

  * use the Cattaneo, et al. -rddensity-
  rddensity bac1, c(0.0) plot


*-> 2. Are the covariates balanced at the cutoff? 
  * Use two separate bandwidths (0.03 to 0.13; 0.055 to 0.105)
  * yi = Xi′γ + α1 DUIi + α2 BACi + α3 BACi × DUIi + ui
  eststo clear
  foreach y of varlist white male acc aged {
    eststo: quietly reg `y' i.dui##c.bac1 if bac1_orig >= 0.03 & bac1_orig <= 0.13, robust
  }
  esttab, keep(1.dui)

  eststo clear
  foreach y of varlist white male acc aged {
    eststo: quietly reg `y' dui##c.bac1 if bac1_orig >= 0.055 & bac1_orig <= 0.105, robust
  }
  esttab, keep(1.dui)
  

*-> 3. Estimate RD of DUI on Recidivism
  * Estimator first
  rdrobust recid bac1, c(0) covs(white male aged acc)

  * plot the data
  rdplot recid bac1, c(0)


*-> 4. "donut hole" dropping close to 0.08
  preserve
  drop if bac1_orig>=0.079 & bac1_orig<=0.081
  rdrobust recid bac1, c(0)
  restore


