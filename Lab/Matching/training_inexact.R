library(fixest)
library(data.table)
library(MatchIt)
set.seed(10202)

N_obs = 30

df = data.table(
  treat = c(rep(1, 10), rep(0, N_obs - 10))
)

# Overlap
df[treat == 1, age := runif(.N, 25, 50)]
df[treat == 0, age := runif(.N, 18, 33)]
df[, age := round(age)]
df[, age_sq := age^2]

# Heterogeneous TEs
df[, het := age - mean(age)]

df[, 
  earnings := 9841 + 1607.50 * treat + 100 * treat * het + 
    500 * age + 10.5 * age_sq + rnorm(.N, 0, 5) 
]
df[, earnings := round(earnings)]



match_obj <- matchit(
    treat ~ age,
    data = df,
    method = "nearest", estimand = "ATT",
    distance = "euclidean"
)

# Get the matched dataset
match_df = match.data(match_obj)

# ATT Estimate
feols(
  earnings ~ i(treat), match_df,
  vcov = "hc1"
)

# Bias adjustment
feols(
  earnings ~ i(treat) + age, match_df,
  vcov = "hc1"
)

# Regression
feols(
  earnings ~ i(treat) + age, df,
  vcov = "hc1"
)
feols(
  earnings ~ i(treat) + age + age_sq, df,
  vcov = "hc1"
)

