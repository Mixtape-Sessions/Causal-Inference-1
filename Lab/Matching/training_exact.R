library(fixest)
library(data.table)
library(MatchIt)
library(haven)

df = haven::read_dta("https://github.com/scunning1975/mixtape/raw/master/training_exact.dta")

# Exact match on age for the ATT
match_obj_att <- matchit(
  treat ~ age,
  data = df,
  method = "exact", estimand = "ATT"
)

# Get the matched dataset
match_df_att = match.data(match_obj_att)

# Earnings 1
feols(
  earnings ~ i(treat), match_df_att,
  vcov = "hc1"
)

# Exact match on age for the ATE
match_obj_ate <- matchit(
  treat ~ age,
  data = df,
  method = "exact", estimand = "ATE"
)

# Get the matched dataset
match_df_ate = match.data(match_obj_ate)

# Earnings 1
feols(
  earnings ~ i(treat), match_df_ate,
  vcov = "hc1"
)





