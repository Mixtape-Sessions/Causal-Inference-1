library(fixest)
library(data.table)
library(MatchIt)
set.seed(10202)

N_obs = 3000

df = data.table(
  treat = c(rep(1, 750), rep(0, N_obs - 750))
)

df[treat == 1, age := rnorm(.N, 27.5, 1)]
df[treat == 0, age := rnorm(.N, 20, 0.5)]
df[, age := round(age)]

# Constant treatment effects
df[, 
  earnings := 9841 + 1607.50 * treat + 25 * age + rnorm(.N, 0, 1)
]

# OLS
feols(
  earnings ~ i(treat) + age, df,
  vcov = "hc1"
)

# Matching on age

match_obj1 <- matchit(
    treat ~ age,
    data = df,
    method = "nearest",
    distance = "mahalanobis"
)

# Get the matched dataset
match_df1 = match.data(match_obj)
match_df1

feols(
  earnings ~ treat + age, match_df1,
  vcov = "hc1"
)

# Technically can use the weights, but in NN-matching, weights are all 1
feols(
  earnings ~ treat + age, match_df1,
  weights = ~ weights, vcov = "hc1"
)

# Matching on age
match_obj <- matchit(
    treat ~ age,
    data = df,
    method = "nearest",
    distance = "mahalanobis"
)

# Get the matched dataset
match_df = match.data(match_obj)
match_df

# Regression in matched data
feols(
  earnings ~ i(treat), match_df,
  vcov = "hc1"
)

# Technically can use the weights, but in NN-matching, weights are all 1
feols(
  earnings ~ i(treat), match_df,
  weights = ~ weights, vcov = "hc1"
)

# Bias-adjustment 
feols(
  earnings ~ i(treat) + age, match_df,
  weights = ~ weights, vcov = "hc1"
)




