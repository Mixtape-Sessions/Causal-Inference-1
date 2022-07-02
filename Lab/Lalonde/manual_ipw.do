********************************************************************************
* name: manual_ipw.do
* author: scott cunningham (baylor)
* description: illustrating the inverse probability weight manually
* last updated: july 2, 2022
********************************************************************************
capture log close
clear

* Reload experimental group data
use https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta, clear
drop if treat==0

* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
append using https://github.com/scunning1975/mixtape/raw/master/cps_mixtape.dta
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

* Now estimate the propensity score
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore

* Checking mean propensity scores for treatment and control groups
su pscore if treat==1, detail
su pscore if treat==0, detail

* Now look at the propensity score distribution for treatment and control groups
histogram pscore, by(treat) binrescale

* Manual with non-normalized weights using all the data
gen d1=treat/pscore
gen d0=(1-treat)/(1-pscore)
egen s1=sum(d1)
egen s0=sum(d0)

gen y1=treat*re78/pscore
gen y0=(1-treat)*re78/(1-pscore)
gen ht=y1-y0

* Manual with normalized weights
replace y1=(treat*re78/pscore)/(s1/_N)
replace y0=((1-treat)*re78/(1-pscore))/(s0/_N)
gen norm=y1-y0
su ht norm

* ATT under non-normalized weights is -$11,876
* ATT under normalized weights is -$7,238

drop d1 d0 s1 s0 y1 y0 ht norm

* Trimming the propensity score
drop if pscore <= 0.1 
drop if pscore >= 0.9

* Manual with non-normalized weights using trimmed data
gen d1=treat/pscore
gen d0=(1-treat)/(1-pscore)
egen s1=sum(d1)
egen s0=sum(d0)

gen y1=treat*re78/pscore
gen y0=(1-treat)*re78/(1-pscore)
gen ht=y1-y0

* Manual with normalized weights using trimmed data
replace y1=(treat*re78/pscore)/(s1/_N)
replace y0=((1-treat)*re78/(1-pscore))/(s0/_N)
gen norm=y1-y0
su ht norm

* ATT under non-normalized weights is $2,006
* ATT under normalized weights is $1,806

capture log close
exit

