* Stratification weighted estimates of the average causal effect of first class on surviving the Titanic sinking
clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/titanic.dta, clear

* Step 1: Stratify the data by sex and age


* Step 2: Calculate differences in mean survival rate for all four strata


* Step 3: Calculate weights for each causal parameter: ATE, ATT and ATU

* Step 3a: Display the number of observations. 


* Step 3b: Now construct the weights based on the counts for each parameter

* Strata counts for ATE
  // Counts of adult females

  // Counts of adult males

  // Counts of male children 

  // Counts of female children

  
* Construct weights for ATE by strata


* Strata counts for first class for ATT
// Counts of adult females in first class

// Counts of adult males in first class

// Counts of male children  in first class

// Counts of female children in first class


* Construct weights for ATT by strata


* Strata counts for non-first class for ATU
 // Counts of adult females in other classes

 // Counts of adult males in other classes

 // Counts of male children in other classes 

 // Counts of female children in other classes

 
* Construct weights for ATU by strata

* Step 4: Estimate aggregate parameters using corresponding weights and differences within strata

