
# Thornton HIV Replication

## Part 1: Experimental Analysis

Load data from the following url:
`https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta`

``` stata
* ssc install estout

use "https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta", clear
```

Rebecca Thornton’s paper [The Demand for, and Impact of, Learning HIV
Status](https://www.rebeccathornton.net/wp-content/uploads/2019/08/Thornton-AER2008.pdf)
at *AER* evaluated an experiment in rural Malawi which gave cash
incentives for people to follow-up and learn their HIV test result.
Thornton’s total sample was 2,901 participants. Of those, 2,222 received
any incentive at all.

Variable descriptions are available in the [codebook](codebook.pdf)

The variable `any` is an indicator variable for if the participant
received *any* incentive. The variable `got` denotes that the individual
went and *got* their test result information.

1.  Calculate by hand the simple difference in means of `got` based on
    treatment status `any`. Then use a simple linear regression to see
    if the result is the same.

``` stata
*-> 1.a. Calculate by hand
sum got if any == 0
local got0 = r(mean)
sum got if any == 1
local got1 = r(mean)
local te = `got1' - `got0'

disp "Treatment Effect Estimate: `te'"

*-> 1.b. Calculate using OLS
reg got i.any, vce(cluster villnum)
```

        Variable |        Obs        Mean    Std. Dev.       Min        Max
    -------------+---------------------------------------------------------
             got |        623    .3386838    .4736425          0          1

        Variable |        Obs        Mean    Std. Dev.       Min        Max
    -------------+---------------------------------------------------------
             got |      2,211    .7892356    .4079436          0          1



    Treatment Effect Estimate: .4505518518599183


    Linear regression                               Number of obs     =      2,830
                                                    F(1, 118)         =     396.94
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.1643
                                                    Root MSE          =      .4225

                                  (Std. Err. adjusted for 119 clusters in villnum)
    ------------------------------------------------------------------------------
                 |               Robust
             got |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.any |   .4519823    .022686    19.92   0.000     .4070578    .4969068
           _cons |   .3386838   .0236849    14.30   0.000     .2917813    .3855863
    ------------------------------------------------------------------------------

2.  Following Table 3, we are going to check if the baseline
    characteristics look the same, on average, between the treated and
    the control group. Test if the following varaibles differ
    significantly between treated and the control groups after
    controlling for `tinc`, `under`, `rumphi`, and `balaka`.

-   gender via `male`
-   baseline age via `age`
-   whether they had HIV in the baseline via `hiv2004`
-   the baseline level of years of education via `educ2004`
-   whether they owned any land in the baseline via `land2004`
-   whether they used condoms in the baseline via `usecondom04`.
    Interpret whether the results give you confidence in the experiment.

``` stata
*-> 2. "Check" the experimental design by looking at covariates
eststo clear
foreach y of varlist male age hiv2004 educ2004 land2004 usecondom04 {
  eststo: quietly reg `y' i.any tinc i.under i.rumphi i.balaka, vce(cluster villnum)
}
esttab, keep(1.any)
```

    (est1 stored)
    (est2 stored)
    (est3 stored)
    (est4 stored)
    (est5 stored)
    (est6 stored)


    ------------------------------------------------------------------------------------------------------------
                          (1)             (2)             (3)             (4)             (5)             (6)   
                         male             age         hiv2004        educ2004        land2004     usecondom04   
    ------------------------------------------------------------------------------------------------------------
    1.any             -0.0349           1.898**      -0.00785          -0.197         0.00833         -0.0311   
                      (-1.13)          (2.75)         (-0.45)         (-1.04)          (0.33)         (-1.46)   
    ------------------------------------------------------------------------------------------------------------
    N                    2897            2892            2830            2603            2669            2444   
    ------------------------------------------------------------------------------------------------------------
    t statistics in parentheses
    * p<0.05, ** p<0.01, *** p<0.001

*Comment:* Among the 6 covariates we tested, all but `age` are not
significantly different between the treated and the control
observations. For `age` the difference is only 1.9 years apart, which is
relatively small. These results give me confidence in the experimental
validity.

3.  Interestingly, Thornton varied the amount of incentive individuals
    received (in the variable `tinc`). Let’s try comparing treatment
    effects at different incentive amounts. This is called a
    `dose response` function. Let’s attempt to learn about the dose
    response function in two ways:

<!-- -->

1.  Calculate a treatment effect using only individuals with `tinc`
    above 2 (the upper end of incentives). Calculate a treatment effect
    using indviduals who receive a positive `tinc` but less than 1. Does
    the treatment effect grow with incentive?

``` stata
* high incentive (>= $2)
reg got i.any if tinc >= 2 | tinc == 0, vce(cluster villnum) 

* low incentive (<= $1)
reg got i.any if tinc <= 1 | tinc == 0, vce(cluster villnum)
```

    Linear regression                               Number of obs     =        994
                                                    F(1, 114)         =     312.67
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.2499
                                                    Root MSE          =     .43264

                                  (Std. Err. adjusted for 115 clusters in villnum)
    ------------------------------------------------------------------------------
                 |               Robust
             got |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.any |   .5157637   .0291682    17.68   0.000     .4579817    .5735456
           _cons |   .3386838   .0236961    14.29   0.000     .2917419    .3856256
    ------------------------------------------------------------------------------


    Linear regression                               Number of obs     =      1,760
                                                    F(1, 118)         =     266.50
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.1414
                                                    Root MSE          =     .45623

                                  (Std. Err. adjusted for 119 clusters in villnum)
    ------------------------------------------------------------------------------
                 |               Robust
             got |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.any |   .3869099   .0237007    16.32   0.000      .339976    .4338438
           _cons |   .3386838   .0236874    14.30   0.000     .2917762    .3855914
    ------------------------------------------------------------------------------

2.  Calculate a linear dose response function by regression `got` on
    `any` and `tinc`. Note `any` represents the treatment effect at 0
    cash incentive (the intercept) and `tinc` represents the marginal
    change in treatment effect from increasing `tinc`.

``` stata
* linear dose-response function
reg got i.any tinc, vce(cluster villnum)
```

    Linear regression                               Number of obs     =      2,830
                                                    F(2, 118)         =     208.69
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.1811
                                                    Root MSE          =     .41832

                                  (Std. Err. adjusted for 119 clusters in villnum)
    ------------------------------------------------------------------------------
                 |               Robust
             got |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           1.any |   .3452039   .0261198    13.22   0.000     .2934795    .3969283
            tinc |    .082769   .0122359     6.76   0.000     .0585385    .1069994
           _cons |   .3386838   .0236891    14.30   0.000      .291773    .3855946
    ------------------------------------------------------------------------------

## Part 2: Randomization Inference

1.  Estimate the treatment effect of any cash incentive on receiving
    test results. Perform randomization-based inference to calculate an
    approximate p-value for the estimate.

``` stata
*-> Randomization Inference
use https://github.com/scunning1975/mixtape/raw/master/thornton_hiv.dta, clear

tempfile hiv
save "`hiv'", replace

* Calculate true effect using absolute value of SDO
egen    te1 = mean(got) if any==1
egen    te0 = mean(got) if any==0

collapse (mean) te1 te0
gen     ate = te1 - te0
keep    ate
gen iteration = 1

tempfile permute1
save "`permute1'", replace

* Create a hundred datasets

forvalues i = 2/1000 {
  use "`hiv'", replace

  drop any
  set seed `i'
  qui gen random_`i' = runiform()
  sort random_`i'
  qui gen one=_n
  drop random*
  sort one

  qui gen any = 0
  qui replace any = 1 in 1/2222

  * Calculate test statistic using absolute value of SDO
  qui egen te1 = mean(got) if any==1
  qui egen te0 = mean(got) if any==0

  qui collapse (mean) te1 te0
  qui gen ate = te1 - te0
  keep ate

  qui gen   iteration = `i'
  tempfile permute`i'
  qui save "`permute`i''", replace
}

use "`permute1'", replace
forvalues i = 2/1000 {
  append using "`permute`i''"
}

tempfile final
save "`final'", replace

* Calculate exact p-value
* ascending order
sort ate  
gen rank = (_N + 1) - _n
su rank if iteration==1
gen pvalue = rank/_N
list if iteration==1
```

    (note: file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.000001 not found)
    file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.000001 saved

    (2598 missing values generated)

    (4141 missing values generated)






    (note: file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.000002 not found)
    file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.000002 saved





    (note: file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.0000tg not found)
    file /var/folders/m3/fzql5frx44nbt7v3j41h6l440000gn/T//S_59206.0000tg saved

        Variable |        Obs        Mean    Std. Dev.       Min        Max
    -------------+---------------------------------------------------------
            rank |          1           1           .          1          1

          +-------------------------------------+
          |      ate   iterat~n   rank   pvalue |
          |-------------------------------------|
    1000. | .4505519          1      1     .001 |
          +-------------------------------------+
