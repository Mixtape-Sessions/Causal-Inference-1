******************************************************************************
* name: thornton_aer.do
* author: scott cunningham (baylor university)
* description: doing the mixtape sessions thornton coding lab part 1 "Experimental Analysis"
* 				https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/Thornton
* last updated: june 18, 2022
******************************************************************************

capture log close
use https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta, replace

/*
Rebecca Thornton's paper The Demand for, and Impact of, Learning HIV Status at AER evaluated an experiment in rural Malawi which gave cash incentives for people to follow-up and learn their HIV test result. Thornton's total sample was 2,901 participants. Of those, 2,222 received any incentive at all.

Variable descriptions are available in the codebook

The variable any is an indicator variable for if the participant received any incentive. The variable got denotes that the individual went and got their test result information.

Q1. Calculate by hand the simple difference in means of got based on treatment status any. Then use a simple linear regression to see if the result is the same.
*/

summarize got if any==1 // 0.789
summarize got if any==0 // 0.339

display 0.789 - 0.339  // estimated ATE is 0.45, or 45pp increase in "getting" results

reg got any, robust // estimated coefficient in our OLS model is 0.45 also! that's bc OLS is calculating differences in means

/*

Q2. Following Table 3, we are going to check if the baseline characteristics look the same, on average, between the treated and the control group. Test if the following varaibles differ significantly between treated and the control groups after controlling for tinc, under, rumphi, and balaka.

gender via male
baseline age via age
whether they had HIV in the baseline via hiv2004
the baseline level of years of education via educ2004
whether they owned any land in the baseline via land2004
whether they used condoms in the baseline via usecondom04. Interpret whether the results give you confidence in the experiment.

*/

de tinc under rumphi balaka

* If treatment is random, then the treatment should be independent (conditionally) of baseline covariates
reg male tinc under rumphi balaka, robust
reg age tinc under rumphi balaka, robust
reg hiv2004 tinc under rumphi balaka, robust
reg educ2004 tinc under rumphi balaka, robust
reg usecondom04 tinc under rumphi balaka, robust

* balance test to check whether randomization is plausible bc if it is random (independence) with respect to PO it should be independence of covariates highly correlated and predictive of PO, and those we can check.

/*

Q3. Interestingly, Thornton varied the amount of incentive individuals received (in the variable tinc). Let's try comparing treatment effects at different incentive amounts. This is called a dose response function. Let's attempt to learn about the dose response function in two ways:
a. Calculate a treatment effect using only individuals with tinc above 2 (the upper end of incentives). Calculate a treatment effect using indviduals who receive a positive tinc but less than 1. Does the treatment effect grow with incentive?

*/

* Nonlinearities in the treatment effect. SUTVA: "No hidden variation in treatment". Complicated given the treatment is a "dose". We're going to explore these "dose responses" a few different ways: with an indicator and separate regresions plus a linear modeling of the dose response function.

gen 	above2=0 if tinc==0
replace above2=1 if tinc>2 & tinc~=. // ALWAYS REMEMBER STATA THINKS MISSING VALUES IN YOUR DATA ARE WORTH POSITIVE INFINITY. SO IF YOU SAY "REPLACE VARIABLE=N IF ANOTHER VARIABLE>WHATEVER" AND THERE ARE MISSING OBSERVATIONS, THEN STATA WILL MAKE THOSE MISSING EQUAL TO N BECAUSE TO STATA MISSING = + INFINITY.

gen 	below1=0 if tinc==0
replace below1=1 if tinc>0 & tinc<1

reg got above2 under rumphi balaka, robust
reg got below1 under rumphi balaka, robust

/*

b. Calculate a linear dose response function by regression got on any and tinc. Note any represents the treatment effect at 0 cash incentive (the intercept) and tinc represents the marginal change in treatment effect from increasing tinc.

*/

reg got any tinc under rumphi balaka, robust

* Now let's look -bought- and -numcon-.  look at the any variable (randomized cash incentive to learn) on condom purchases and how many

* First regression: what is the effect of winning the lottery to get paid to learn your test results on buying condoms?

reg anycond any  , robust
reg numcon any  , robust


