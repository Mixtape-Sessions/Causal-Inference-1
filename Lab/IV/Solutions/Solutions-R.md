
# Fulton Fish Market Replication

First, we will use data from Graddy (1995) who observes daily fish
prices and quantities from the Fulton Fish Market in NYC. ![Fulton Fish
Market in
NYC](https://upload.wikimedia.org/wikipedia/commons/9/97/Fultonfishmarket.jpg)

The goal of this paper is to estimate the demand elasticity of fish
prices $$
Q = \alpha + \delta P + \gamma X + \varepsilon
$$ Since price and quantity are simultaneous equations, we need an
instrument that shocks $P$. Graddy (1995) uses the two-day lagged
weather which determines that day’s market price for fish.

Load the Fulton Fish Market data from
`https://raw.github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta`

``` r
library(fixest)
library(haven)

df <- haven::read_dta("../Fulton.dta")
# df <- haven::read_dta("https://raw.github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta")
```

1.  Run OLS of `q` on `p` controlling for indicators for day of the week
    (`Mon`, `Tue`, `Wed`, `Thu`).

``` r
df |> 
  feols(q ~ p + i(Mon) + i(Tue) + i(Wed) + i(Thu), vcov="hc1")
```

    ## OLS estimation, Dep. Var.: q
    ## Observations: 111 
    ## Standard-errors: Heteroskedasticity-robust 
    ##              Estimate Std. Error   t value   Pr(>|t|)    
    ## (Intercept)  8.606893   0.118317 72.744640  < 2.2e-16 ***
    ## p           -0.562550   0.152175 -3.696736 0.00034913 ***
    ## Mon::1       0.014316   0.205729  0.069589 0.94465312    
    ## Tue::1      -0.516242   0.189727 -2.720970 0.00762065 ** 
    ## Wed::1      -0.555373   0.193701 -2.867163 0.00500584 ** 
    ## Thu::1       0.081621   0.162036  0.503724 0.61551074    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 0.651867   Adj. R2: 0.183366

2.  Instrument for `p` using the variable `Stormy` which is an indicator
    for it being stormy in the past two days.

``` r
df |>
  feols(
    q ~ i(Mon) + i(Tue) + i(Wed) + i(Thu) | 0 | 
      p ~ Stormy,
    vcov = "hc1"
  )
```

    ## TSLS estimation, Dep. Var.: q, Endo.: p, Instr.: Stormy
    ## Second stage: Dep. Var.: q
    ## Observations: 111 
    ## Standard-errors: Heteroskedasticity-robust 
    ##              Estimate Std. Error   t value  Pr(>|t|)    
    ## (Intercept)  8.505911   0.152070 55.934327 < 2.2e-16 ***
    ## fit_p       -1.119417   0.443193 -2.525799 0.0130370 *  
    ## Mon::1      -0.025402   0.221438 -0.114715 0.9088904    
    ## Tue::1      -0.530769   0.202092 -2.626381 0.0099201 ** 
    ## Wed::1      -0.566351   0.206926 -2.736968 0.0072836 ** 
    ## Thu::1       0.109267   0.178439  0.612352 0.5416285    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 0.685042   Adj. R2: 0.09813
    ## F-test (1st stage), p: stat = 21.5   , p = 1.015e-5, on 1 and 105 DoF.
    ##            Wu-Hausman: stat =  2.2731, p = 0.134668, on 1 and 104 DoF.

3.  Argue for or against the validity of the instrument.

# Card Replication

Next, we will turn to the classical IV example of Card (1995). Card aims
to estimate the returns to college education, but is worried about
omitted variable bias when regressing wages on years of education. In
this case, the coefficient on education is likely biased upwards by
unobserved ability since it is plausibly positively correlated with
education and with wages.

Load the Card data from
`https://raw.github.com/scunning1975/mixtape/master/card.dta`

1.  Regress the log wage `lwage` on years of education `educ`
    controlling for experience (`exper`), an indicator for being Black
    (`black`), an indicator for being in the South (`south`), an
    indicator for being married (`married`), and an indicator for living
    in an urban area (`smsa`).

``` r
df <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/card.dta")
```

``` r
df |> 
  feols(
    lwage ~ educ + exper + black + south + married + smsa,
    vcov = "hc1"
  )
```

    ## NOTE: 7 observations removed because of NA values (RHS: 7).

    ## OLS estimation, Dep. Var.: lwage
    ## Observations: 3,003 
    ## Standard-errors: Heteroskedasticity-robust 
    ##              Estimate Std. Error   t value  Pr(>|t|)    
    ## (Intercept)  5.063317   0.066179  76.50992 < 2.2e-16 ***
    ## educ         0.071173   0.003614  19.69508 < 2.2e-16 ***
    ## exper        0.034152   0.002267  15.06625 < 2.2e-16 ***
    ## black       -0.166027   0.017398  -9.54305 < 2.2e-16 ***
    ## south       -0.131552   0.015201  -8.65431 < 2.2e-16 ***
    ## married     -0.035871   0.003573 -10.04012 < 2.2e-16 ***
    ## smsa         0.175787   0.015099  11.64198 < 2.2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 0.369818   Adj. R2: 0.303628

2.  Using the same set of controls, run an instrumental variables
    regression instrumenting `educ` by `nearc4` which is an indicator
    for being near a 4-year college/university.

``` r
df |> 
  feols(
    lwage ~ exper + black + south + married + smsa | 0 |
      educ ~ nearc4, 
    vcov = "hc1"
  )
```

    ## NOTE: 7 observations removed because of NA values (RHS: 7).

    ## TSLS estimation, Dep. Var.: lwage, Endo.: educ, Instr.: nearc4
    ## Second stage: Dep. Var.: lwage
    ## Observations: 3,003 
    ## Standard-errors: Heteroskedasticity-robust 
    ##              Estimate Std. Error  t value   Pr(>|t|)    
    ## (Intercept)  4.162476   0.835850  4.97993 6.7209e-07 ***
    ## fit_educ     0.124164   0.049215  2.52289 1.1691e-02 *  
    ## exper        0.055588   0.019891  2.79469 5.2279e-03 ** 
    ## black       -0.115686   0.049617 -2.33157 1.9789e-02 *  
    ## south       -0.113165   0.022974 -4.92570 8.8621e-07 ***
    ## married     -0.031975   0.005078 -6.29635 3.4931e-10 ***
    ## smsa         0.147707   0.030352  4.86637 1.1954e-06 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 0.383843   Adj. R2: 0.249808
    ## F-test (1st stage), educ: stat = 15.8    , p = 7.334e-5, on 1 and 2,996 DoF.
    ##               Wu-Hausman: stat =  1.21866, p = 0.269713, on 1 and 2,995 DoF.

3.  Compare the two results, does the IV estimate move in the direction
    we predicted above? Use the concept of LATE to describe why the
    coefficient moved in the direction it did.
