library(fixest)
library(data.table)
library(MatchIt)
set.seed(10202)

df = data.table(
  treat = c(rep(1, 750), rep(0, N_obs - 750))
)

# Overlap
df[treat == 1, age := runif(.N, 18, 32)]
df[treat == 0, age := rnorm(.N, 35, 3)]
df[treat == 1, gpa := rnorm(.N, 2.3, 0.5)]
df[treat == 0, gpa := rnorm(.N, 1.76, 0.45)]

# Constant treatment effects
df[, 
  earnings := 9841 + 1607.50 * treat + 25 * age + 1.25 * gpa + rnorm(.N, 0, 1)
]

# Multivariate regression
feols(
  earnings ~ i(treat) + age + gpa, df,
  vcov = "hc1"
)

# FWL auxilary regression
lm_treat = feols(
  treat ~ age + gpa, df,
  vcov = "hc1"
)
# Residualize
df[, treat_tilde := treat - predict(lm_treat)]
feols(
  earnings ~ treat_tilde, df,
  vcov = "hc1"
)


