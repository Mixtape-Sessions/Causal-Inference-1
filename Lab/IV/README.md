# Fulton Fish Market Replication

First, we will load data from Graddy (1995) who observes daily fish prices and quantities from the Fulton Fish Market in NYC.
![Fulton Fish Market in NYC](https://upload.wikimedia.org/wikipedia/commons/9/97/Fultonfishmarket.jpg)

The goal of this paper is to estimate the demand elasticity of fish prices
$$
Q = \alpha + \delta P + \gamma X + \varepsilon
$$
Since price and quantity are simultaneous equations, we need an instrument that shocks $P$. Graddy (1995) uses the two-day lagged weather which determines that day's market price for fish.

Load the Fulton Fish Market data from `https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta`


1. Run OLS of `q` on `p` controlling for indicators for day of the week (`Mon`, `Tue`, `Wed`, `Thu`).  Interpret the elasticity.  

2. Instrument for `p` using the variable `Stormy` which is an indicator for it being stormy in the past two days.  Interpret the elasticity. 

3. Calculate the Olea and Pfleuger effective F-statistic and interpret the strength of the instrument.

4. Calculate the Anderson-Rubin confidence intervals. 


# Card Replication

Next, we will turn to the classical IV example of Card (1995). Card aims to estimate the returns to college education, but is worried about omitted variable bias when regressing wages on years of education. In this case, the coefficient on education is likely biased upwards by unobserved ability since it is plausibly positively correlated with education and with wages. 

Load the Card data from `https://raw.github.com/scunning1975/mixtape/master/card.dta`

1. Regress the log wage `lwage` on years of education `educ` controlling for experience (`exper`), an indicator for being Black (`black`), an indicator for being in the South (`south`), an indicator for being married (`married`), and an indicator for living in an urban area (`smsa`).  Interpret the coefficient on schooling. 

2. Using the same set of controls, run an instrumental variables regression instrumenting `educ` by `nearc4` which is an indicator for being near a 4-year college/university.  Interpret the coefficient on schooling

3.  Calculate the strength of the first stage using the Olea and Pfleuger effective F statistic. Interpret the result.

4. Calculate the Anderson-Rubin confidence intervals and interpret your result.

5. Compare the two results, does the IV estimate move in the direction we predicted above? Use the concept of LATE to describe why the coefficient moved in the direction it did.  

6. If your schooling result is a LATE, then what do the five assumptions mean in the context of this study?  


*Note: for Stata, you can use `-weakivtest-` for the Olea and Pfleuger effective F and `-twostepweakiv-` for the Anderson-Rubin confidence intervals. For R, you can use the `{}` and `{}` packages*



