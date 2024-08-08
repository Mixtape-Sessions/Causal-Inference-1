* Data is from the NSLY, a panel dataset of young men who were followed every year from youth to adulthood. Card wants to know the causal effect of schooling on earnings. Card uses an instrument and his instrument is "do you live in the same county as a 4-year college?"

clear
capture log close

use https://raw.github.com/scunning1975/mixtape/master/card.dta, clear

* Calculate the Wald estimator and estimate the effect of schooling (educ) on earnings (lwage). 

* Wald = Cov(lwage,nearc4)/Cov(educ,nearc4)
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

* But, this is not always super easy to detect. In a dataset, any two variables are always somewhat correlated even if they are completely independent in the infinite sample

gen a = rnormal()
gen b = rnormal()

regress a b



* Twostage least squares

* 1st stage: regress schooling onto the instrument

regress educ  nearc4, robust
predict shat

regress lwage  shat, robust
summarize wald_iv

regress lwage nearc4, robust // reduced form
regress educ nearc4, robust // first stage

* OLS model is a regression of lwage onto educ. but if educ is endogenous (meaning there is some unknown variable, like ability, that causes people to go to school and causes them to make different amounts of money) then the coefficient on schooling is biased. Neverhtelss here it is:

regress lwage educ, robust // 0.05.  How do I interpret this number? The way you interpret every OLS coefficient is to imagine changing the variable educ by 1 unit.  The coefficient measures the change in the outcome associated with that 1-unit change.  You just have to remember what the units are of the variable on the left hand side. LOG wage. So every additional year of schooling is associated with 0.052 additional log wage points. Log wage goes up by 0.052 with every year of schooling. BUT, that can be interpreted as approximately equal to a percentage change.  For every additional year of schooling, since wage is measured as log wage, that 0.052 is equal to 5.2%. Every additional year of school is associated with 5.2% higher wages. 

* Our IV estimate was 0.188.  Our IV estimate says every additional year of schooling CAUSES log wage to increase by 0.188 log points which is equal to 18.8% higher wages for every year of schooling. 

* The actual twostage least squares model requires some additional steps that are too complicated to do manually to get the correct standard error. If you are using IV, you shouldn't use this two step manual method. It's good to do it because in my experience, the more you code manually, the less intimidated you are by the methods. You need to use a statistical package in STata, R or python. In Stata, that package is called -ivregress- (there's also ivreg2, ivreg28, etc.). 

ivregress 2sls lwage (educ=nearc4), first robust

ivregress 2sls lwage age black (educ=nearc4), first robust

ivreg2 lwage (educ = nearc4) exper black south married smsa, first robust

condivreg (lwage = educ) (educ = nearc4) exper black south married smsa, ar




