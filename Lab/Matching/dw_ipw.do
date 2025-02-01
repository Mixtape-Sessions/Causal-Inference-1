* dw_ipw.do
capture log close
clear

* Reload experimental group data
use https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta, clear
reg re78 treat // $1,794.34
reg re75 treat // Checking baseline differences

* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
drop if treat==0
append using https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta

* Dehejia and Wahba (2002) propensity score specification
gen agesq=age*age
gen agecube=age*age*age
gen edusq=educ*edu
gen u74 = 0 if re74!=.
replace u74 = 1 if re74==0
gen u75 = 0 if re75!=.
replace u75 = 1 if re75==0
gen interaction1 = educ*re74
gen re74sq=re74^2
gen re75sq=re75^2
gen interaction2 = u74*hisp

* Step 2. Sample Means and Standard Deviations
summarize age  educ  marr nodegree black hisp re74 re75 u74 u75  if treat==1
summarize age  educ  marr nodegree black hisp re74 re75 u74 u75  if treat==0

* Step 3: Estimate and plot propensity score 
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore
label variable pscore "Propensity Score"

* Now look at the propensity score distribution for treatment and control groups
twoway (histogram pscore if treat==1, color(green) lcolor(black)) ///
       (histogram pscore if treat==0, fcolor(none) lcolor(black)), ///
       legend(order(1 "NSW Sample" 2 "CPS Sample") size(small)) ///
       title("Distribution of Propensity Score") ///
       note("Male NSW Participants using DW sub-sample.") ///
       xtitle("Propensity Score")
	   
* Step 4. Trim (Crump, et al. 2009)
preserve
drop if pscore<0.1
drop if pscore>0.9

* Step 5. Estimation of target parameter (e.g., ATT)

*-> 5(i). Inverse probability weighting 
gen ipw = treat + (1-treat) * pscore/(1-pscore)

reg re78 i.treat [aw=ipw], robust

*-> 5(ii). Propensity Score Matching
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75, logit), atet gen(ps_cps) nn(1)

*-> 5(iii). Abadie and Imbens nearest neighbor matching without and with bias adjustment
teffects nnmatch (re78 age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75) (treat), atet nn(1) metric(maha) 
  
teffects nnmatch (re78 age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75) (treat), atet nn(1) metric(maha) biasadj(age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75)

*-> 5(iv). Regression adjustment
teffects ra (re78 age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75) (treat), atet

* Step 6. Falsifications
restore
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 u74 interaction1 
predict new_pscore
label variable new_pscore "Falsification Propensity Score"

*-> Trim
drop if new_pscore<0.1
drop if new_pscore>0.9

*-> 6(i). Inverse probability weighting 
gen new_ipw = treat + (1-treat) * new_pscore/(1-new_pscore)

reg re75 i.treat [aw=new_ipw], robust

*-> 6(ii). Propensity Score Matching
teffects psmatch (re75) (treat age agesq agecube educ edusq marr nodegree black hisp re74 u74, logit), atet gen(ps_cps3) nn(1)

*-> 6(iii). Abadie and Imbens nearest neighbor matching without and with bias adjustment
teffects nnmatch (re75 age agesq agecube educ edusq marr nodegree black hisp re74 u74) (treat), atet nn(1) metric(maha) 
  
teffects nnmatch (re75 age agesq agecube educ edusq marr nodegree black hisp re74 u74) (treat), atet nn(1) metric(maha) biasadj(age agesq agecube educ edusq marr nodegree black hisp re74 u74)

*-> 6(iv). Regression adjustment
teffects ra (re75 age agesq agecube educ edusq marr nodegree black hisp re74 u74) (treat), atet
