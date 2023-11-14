clear all
set seed 5150
set obs 5000

* Create treatment and control groups
gen treat = 0 
replace treat = 1 in 2501/5000

* Generate covariates
gen age = rnormal(25, 2.5) if treat == 1
replace age = rnormal(30, 3) if treat == 0
gen gpa = rnormal(2.3, 0.75) if treat == 0
replace gpa = rnormal(1.76, 0.5) if treat == 1

* Center the covariates
egen mean_age = mean(age)
replace age = age - mean_age
egen mean_gpa = mean(gpa)
replace gpa = gpa - mean_gpa

* Generate additional variables
gen age_sq = age^2
gen gpa_sq = gpa^2
gen interaction = gpa * age

* Generate potential outcomes
gen y0 = 15000 + 10.25*age - 10.5*age_sq + 1000*gpa - 10.5*gpa_sq + 500*interaction + rnormal(0, 5)
gen y1 = y0 + 2500 + 100 * age + 1100 * gpa
gen delta = y1-y0

su delta // ATE = 2500
su delta if treat==1 // ATT = 1962
local att = r(mean)
scalar att = `att'
gen att = `att'

* Generate observed outcome
gen earnings = treat * y1 + (1 - treat) * y0

* Regress treatment on covariates to get propensity score
reg treat age gpa age_sq gpa_sq interaction
predict pscore

* Calculate squared propensity score
gen pscore_sq = pscore^2

* Calculate E[p(X)^2] and E[p(X)]^2 for the treated group
summarize pscore_sq if treat == 1, meanonly
local E_pscore_sq_1 = r(mean)
summarize pscore if treat == 1, meanonly
local mean_pscore_1 = r(mean)
local E_pscore_1_sq = (`mean_pscore_1')^2

* Variance of the propensity score for the treated group
local var_pscore_1 = `E_pscore_sq_1' - `E_pscore_1_sq'

* Repeat the process for the control group
summarize pscore_sq if treat == 0, meanonly
local E_pscore_sq_0 = r(mean)
summarize pscore if treat == 0, meanonly
local mean_pscore_0 = r(mean)
local E_pscore_0_sq = (`mean_pscore_0')^2

local var_pscore_0 = `E_pscore_sq_0' - `E_pscore_0_sq'

* Display the variances
di "Variance of propensity score for treated: " `var_pscore_1'
di "Variance of propensity score for control: " `var_pscore_0'

* Calculate rho, the share of units treated
su treat, meanonly
local rho = r(mean)
gen rho = `rho'

* Calculate the weights
gen weight1 = ((1 - `rho') * `var_pscore_0') / (`rho' * `var_pscore_1' + (1 - `rho') * `var_pscore_0')

gen weight0 = 1 -  weight1

* 1. Obtain the OLS regression coefficient directly 
reg earnings age gpa age_sq gpa_sq interaction treat
di "Coefficient of treat from OLS: " _b[treat]

* 2. Obtain the OLS regression coefficient using Tymon's theorem
* For treated group (d = 1)
reg earnings pscore if treat == 1
scalar alpha_1 = _b[_cons]
scalar gamma_1 = _b[pscore]

* For control group (d = 0)
reg earnings pscore if treat == 0
scalar alpha_0 = _b[_cons]
scalar gamma_0 = _b[pscore]

* Expected value of the propensity score for each group
su pscore if treat == 1, meanonly
scalar E_pscore_1 = r(mean)

su pscore if treat == 0, meanonly
scalar E_pscore_0 = r(mean)

scalar APLE_1 = (alpha_1 - alpha_0) + (gamma_1 - gamma_0) * E_pscore_1
scalar APLE_0 = (alpha_1 - alpha_0) + (gamma_1 - gamma_0) * E_pscore_0

scalar tau_hat = weight1 * APLE_1 + weight0 * APLE_0
di "Calculated treatment coefficient using weighted APLEs: " tau_hat

