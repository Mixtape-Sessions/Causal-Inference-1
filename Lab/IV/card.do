* card.do.  This uses Dave Card's original study estimating the effect of schooling on earnings using as an instrumental variable whether the survey respondent lives in the same county as a 4-year college.  We will focus on the Wald estimator again for illustrative purposes. 

clear
capture log close

use https://raw.github.com/scunning1975/mixtape/master/card.dta, clear

* Calculate the Wald estimator manually as the ratio fo two covariances, then 2SLS, then appropriate tests on weak instrument first stage.

* 1. Wald IV as a ratio of two covariances: Cov(lwage,nearc4)/Cov(educ,nearc4)
* Cov(Y,Z) = E[YZ] - E[Y]E[Z]
* Cov(S,Z) = E[SZ] - E[S]E[Z]

egen mean_wage = mean(lwage)
egen mean_iv = mean(nearc4)
egen mean_educ = mean(educ)
gen yz_product = mean_wage*mean_iv
gen sz_product = mean_educ*mean_iv

gen yz = lwage*nearc4
gen sz = educ*nearc4

egen mean_yz = mean(yz)
egen mean_sz = mean(sz)

* Wald estimator: Cov(Y,Z) / Cov(S,Z)

gen cov_yz = mean_yz - yz_product
gen cov_sz = mean_sz - sz_product

gen wald_iv = cov_yz/cov_sz // notice that in the wald estimator, you are dividing by a covariance measuring the statistical correlation between schooling and the instrument. If schooling and the instrument are not correlated (say they are independent), then Wald is undefined because you can't divide by a zero.

* 2. Wald IV as Twostage least squares

* 1st stage: regress schooling onto the instrument

** two stage least squares
regress educ  nearc4, robust
predict shat

regress lwage  shat, robust
summarize wald_iv

* ratio of RF coeff on Z and FS coeff on Z
regress lwage nearc4, robust // reduced form
regress educ nearc4, robust // first stage

* OLS model is a regression of lwage onto educ. but if educ is endogenous (meaning there is some unknown variable, like ability, that causes people to go to school and causes them to make different amounts of money) then the coefficient on schooling is biased. Neverhtelss here it is:

regress lwage educ, robust // 0.05.  

* 3. Test for weak first stage and calculate robust confidence intervals (AR CI)
ivregress 2sls lwage (educ=nearc4), first robust

weakivtest // Olea-Pflueger effective F statistic
twostepweakiv 2sls lwage (educ = nearc4), robust // Anderson-Rubin confidence intervals


