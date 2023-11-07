******************************************************************
** name: lalonde.do 
** author: scott cunningham (baylor university)
** 
** description: Analysis of Lalonde (1986) using the Dehejia and Wahba (2002) subsample to illustrate problems with heterogenous treatment effects
******************************************************************
capture log close 
clear

* ssc install hettreatreg 

use "https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta", clear

* Estimate treatment effect using only the experimental samples
reg re78 i.treat, robust

* Append with CPS non-experimental control group
drop if treat==0
append using "https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta"

* Percent of new appended sample treated
su treat // 1.1% is treated bc there's 16,177 obs in control now

* Create variables
  gen agesq = age^2
  gen agecube = age^3
  gen edusq = educ^2
  gen u74 = (re74 == 0)
  gen u75 = (re75 == 0)
  
* Following Angrist and Pischke (p. 89, Table 3.3.3) and Tymon (Restat 2022, Table 1)

reg re78 treat, robust 

reg re78 age agesq educ black hisp nodegree marr treat, robust

reg re78 re75 treat, robust

reg re78 age agesq educ marr nodegree black hisp re75 treat, robust

reg re78 age agesq educ marr nodegree black hisp re74 re75 treat, robust

* Regression adjustment

teffects ra (re78 age agesq educ marr nodegree black hisp re74 re75) (treat), atet

* Heterogenous treatment effect diagnostics

hettreatreg age agesq educ marr nodegree black hisp re74 re75, o(re78) t(treat) noisily vce(robust)

capture log close
exit

* Run the regressions and store the results
reg re78 treat, robust 
estimates store M1

reg re78 age agesq educ black hisp nodegree marr treat, robust
estimates store M2

reg re78 re75 treat, robust
estimates store M3

reg re78 age agesq educ marr nodegree black hisp re75 treat, robust
estimates store M4

reg re78 age agesq educ marr nodegree black hisp re74 re75 treat, robust
estimates store M5

* Use estout to output the results to a LaTeX file
estout M1 M2 M3 M4 M5, ///
    style(tex) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    stats(N, labels("Observations")) ///
    varlabels(_cons Constant) ///
    prehead("\begin{tabular}{lccccc}" "\hline \hline" " & \multicolumn{5}{c}{Dependent variable: RE78} \\" "Variable & (1) & (2) & (3) & (4) & (5) \\" " & No controls & Demographics & RE75 Only & Demo and RE75 & Demo, RE74 and RE75 \\") ///
    posthead("\hline") ///
    postfoot("\hline \end{tabular}") ///
    label ///
    collabels(none) ///
    replace
