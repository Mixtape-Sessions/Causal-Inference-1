* Stratification weighted estimates of the average causal effect of first class on surviving the Titanic sinking

clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/titanic.dta, clear

* Step 1: Stratify the data by sex and age
gen 	adult_male = 0
replace adult_male = 1 if sex==1 & age==1

gen 	adult_female = 0
replace adult_female = 1 if sex==0 & age==1

gen 	child_male = 0
replace child_male = 1 if sex==1 & age==0

gen 	child_female = 0
replace child_female = 1 if sex==0 & age==0

gen 	first_class = 0
replace first_class = 1 if class==1

* Step 2: Calculate differences in mean survival rate for all four strata
su survived if adult_female==1 & first_class==1
gen ey11=r(mean)
label variable ey11 "Average survival for adult females in first class"
su survived if adult_female==1 & first_class==0
gen ey10=r(mean)
label variable ey10 "Average survival for adult females in other class cabins"
gen diff_af=ey11-ey10
label variable diff_af "Simple difference in survival rates for adult females"

su survived if adult_male==1 & first_class==1
gen ey21=r(mean)
label variable ey21 "Average survival rate for adult males in first class"
su survived if adult_male==1 & first_class==0
gen ey20=r(mean)
label variable ey20 "Average survival rate for adult males in other class cabins"
gen diff_am=ey21-ey20
label variable diff_am "Difference in survival rates for male adults"

su survived if child_male==1 & first_class==1
gen ey31=r(mean)
label variable ey31 "Average survival rate for male children in first class"
su survived if child_male==1 & first_class==0
gen ey30=r(mean)
label variable ey30 "Average survival rate for male children in other class cabins"
gen diff_cm=ey31-ey30 
label variable diff_cm "Difference in survival rates for male children"

su survived if child_female==1 & first_class==1
gen ey41=r(mean)
label variable ey41 "Average survival rate for female children in first class"
su survived if child_female==1 & first_class==0
gen ey40=r(mean)
label variable ey40 "Average survival rate for female children in other class cabins"
gen diff_cf=ey41-ey40
label variable diff_cf "Difference in survival rates for female children"

* Calculate weights for each causal parameter: ATE, ATT and ATU

* Step 3: Display the number of observations. Compare this with the chapter
bysort first_class: tab sex age, freq
bysort first_class: su survived if adult_male==1
bysort first_class: su survived if adult_female==1
bysort first_class: su survived if child_male==1
bysort first_class: su survived if child_female==1


* Step 3 (cont): Now construct the weights based on the counts for each parameter

* Strata counts for ATE
count if adult_female==1 // Counts of adult females
gen ate_af = `r(N)'
count if adult_male==1 // Counts of adult males
gen ate_am = `r(N)'
count if child_male==1  // Counts of male children 
gen ate_cm = `r(N)'
count if child_female==1 // Counts of female children
gen ate_cf = `r(N)'

count
gen ate_N = `r(N)'

* Construct weights for ATE by strata
gen 	wt_ate_af = ate_af/ate_N
gen 	wt_ate_am = ate_am/ate_N
gen 	wt_ate_cm = ate_cm/ate_N
gen 	wt_ate_cf = ate_cf/ate_N

su *ate* // Double check your work

* Strata counts for first class for ATT
count if adult_female==1 & first_class==1 // Counts of adult females in first class
gen att_af1 = `r(N)'
count if adult_male==1 & first_class==1 // Counts of adult males in first class
gen att_am1 = `r(N)'
count if child_male==1 & first_class==1 // Counts of male children  in first class
gen att_cm1 = `r(N)'
count if child_female==1 & first_class==1 // Counts of female children in first class
gen att_cf1 = `r(N)'

count if first_class==1
gen att_N = `r(N)'

* Construct weights for ATT by strata
gen 	wt_att_af = att_af/att_N
gen 	wt_att_am = att_am/att_N
gen 	wt_att_cm = att_cm/att_N
gen 	wt_att_cf = att_cf/att_N

su *att* // Double check your work

* Strata counts for non-first class for ATU
count if adult_female==1 & first_class==0 // Counts of adult females in other classes
gen atu_af0 = `r(N)'
count if adult_male==1 & first_class==0 // Counts of adult males in other classes
gen atu_am0 = `r(N)'
count if child_male==1 & first_class==0 // Counts of male children in other classes 
gen atu_cm0 = `r(N)'
count if child_female==1 & first_class==0 // Counts of female children in other classes
gen atu_cf0 = `r(N)'

count if first_class==0
gen atu_N = `r(N)'

* Construct weights for ATU by strata
gen 	wt_atu_af = atu_af/atu_N
gen 	wt_atu_am = atu_am/atu_N
gen 	wt_atu_cm = atu_cm/atu_N
gen 	wt_atu_cf = atu_cf/atu_N

su *atu* // Double check your work

* Step 4: Estimate aggregate parameters using corresponding weights and differences within strata

gen ate_strat = .
gen att_strat = .
gen atu_strat = .

replace	ate_strat = (wt_ate_af * diff_af) + (wt_ate_am * diff_am) + (wt_ate_cm * diff_cm) + (wt_ate_cf * diff_cf)
label variable ate_strat "Stratification weighted estimate of ATE"

replace	att_strat = (wt_att_af * diff_af) + (wt_att_am * diff_am) + (wt_att_cm * diff_cm) + (wt_att_cf * diff_cf)
label variable att_strat "Stratification weighted estimate of ATT"

replace	atu_strat = (wt_atu_af * diff_af) + (wt_atu_am * diff_am) + (wt_atu_cm * diff_cm) + (wt_atu_cf * diff_cf)
label variable atu_strat "Stratification weighted estimate of ATU"

sum *_strat // Double check your work
