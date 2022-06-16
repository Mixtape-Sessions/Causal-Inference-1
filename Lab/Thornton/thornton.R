## Thornton.R ------------------------------------------------------------------
## Kyle Butts, CU Boulder Economics
## 
## Analysis of Thornton (2008)

library(tidyverse)
library(fixest)
library(haven)

df <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta")

# ------------------------------------------------------------------------------
# Part 1
# ------------------------------------------------------------------------------

# ---- 1.a. Calculate by hand

# difference between the two means
with(df, {
  mean(got[any == 1], na.rm = TRUE) - mean(got[any == 0], na.rm = TRUE)
})

# ---- 1.b. Calculate using OLS
feols(got ~ i(any), data = df, cluster = ~villnum)


# ---- 2. "Check" the experimental design by checking covariates

feols(
  c(male, age, hiv2004, educ2004, land2004, usecondom04) ~ 
  i(any) + tinc + i(under) + i(rumphi) + i(balaka), 
  data = df, cluster = ~villnum
) |> 
  etable()


# ---- 3. Dose-response function

# high incentive (>= $2)
feols(
  got ~ i(any), 
  data = df |> filter(tinc >= 2 | tinc == 0), cluster = ~villnum
)

# low incentive (<= $1)
feols(
  got ~ i(any), 
  data = df |> filter(tinc <= 1 | tinc == 0), cluster = ~villnum
)

# linear dose-response curve
feols(
  got ~ i(any) + tinc, 
  data = df, cluster = ~villnum
)


# ------------------------------------------------------------------------------
# Part 2
# ------------------------------------------------------------------------------


# ---- 1. Randomization Inference

df <- df |> filter(!is.na(any))

permuteHIV <- function(df, random = TRUE) {
  # Shuffle `any`
  if(random == TRUE) {
    df$any <- sample(df$any, replace = FALSE)
  }
  
  # `with` lets you access variables in tb without doing tb$ a bunch
  ate <- with(df, {
    mean(got[any == 1], na.rm = TRUE) - mean(got[any == 0], na.rm = TRUE)
  })
  
  return(ate)
}

# Observed treatment effect
permuteHIV(df, random = FALSE)

n_iterations <- 1000

# Run iterations
ate <- c(permuteHIV(df, random = FALSE))
for(i in 1:(n_iterations - 1)) {
  ate <- c(ate, permuteHIV(df, random = TRUE))
}

# Histogram of placebo effects
hist(ate)

#calculating the p-value
ate = abs(ate)
obs_te = ate[1]

# `ecdf` gives us the empirical CDF of `ate`
empirical_cdf = ecdf(ate)

# percentile of obs_te
obs_percentile = empirical_cdf(obs_te)

# p-value 
1 - obs_percentile
