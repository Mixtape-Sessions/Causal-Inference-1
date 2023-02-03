## Lalonde.R -------------------------------------------------------------------
## Kyle Butts, CU Boulder Economics
## 
## replicate analysis of Lalonde (1986) and Dehejia and Wahba (2002)

library(tidyverse)
library(fixest)
library(haven)
library(MatchIt)


# Experimental data
df_exp <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/nsw_mixtape.dta")


# ------------------------------------------------------------------------------
# Part 1
# ------------------------------------------------------------------------------


# ---- 1. Experimental Analysis

# Baseline covariate balance
feols(
  c(re74, re75, marr, educ, age, black, hisp) ~ i(treat),
  data = df_exp, vcov = "hc1"
) |>
  etable()

# Estimate treatment effect
feols(re78 ~ i(treat), data = df_exp, vcov = "hc1")


# ---- 2. Non-experimental Analysis

df_cps <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/cps_mixtape.dta")

# Treated experimental units with CPS units as controls
df_nonexp <- bind_rows(df_exp |> filter(treat == 1), df_cps)

df_nonexp |> 
  feols(re78 ~ i(treat), vcov = "hc1")
  


# ------------------------------------------------------------------------------
# Part 2
# ------------------------------------------------------------------------------

df_nonexp <- df_nonexp |>
  mutate(
    agesq = age^2,
    agecube = age^3,
    educsq = educ^2,
    u74 = (re74 == 0),
    u75 = (re75 == 0)
  )

# ---- 1. Inverse propensity score weighting

logit_nsw <- feglm(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  family = binomial(link = "logit"),
  data = df_nonexp
)

df_nonexp$pscore <- predict(logit_nsw, type = "response")

# Poor propensity score match
# ggplot(df_nonexp) +
#   geom_histogram(
#     aes(
#       x = pscore, y = after_stat(density),
#       group = treat, fill = as.factor(treat)
#     ),
#   ) +
#   facet_grid(~ as.factor(treat)) +
#   labs(fill = "Treated", x = "Propensity Score")


# inverse propensity score weights
df_nonexp <- df_nonexp |> 
  mutate(
    # ATT
    inv_ps_weight = treat + (1-treat) * pscore/(1-pscore)
    # ATE
    # inv_ps_weight = treat / pscore + (1-treat) * 1/(1-pscore)
    # ATC
    # inv_ps_weight = treat * (1-pscore)/pscore - (1-treat)
  )

# Weights are implicitly normalized when using `feols`,
# plus it gives standard errors
df_nonexp |> 
  feols(re78 ~ i(treat),
    weights = ~inv_ps_weight, vcov = "hc1"
  )

# ---- 2. Inverse propensity score weighting with trimming

# Normalized weights
df_nonexp |> 
  filter(pscore > 0.1 & pscore < 0.9) |>
  feols(re78 ~ i(treat),
    weights = ~inv_ps_weight, vcov = "hc1"
  )

# ---- 3. Propensity Score Matching

# 1:1 nearest neighbor matching with replacement on
# the Mahalanobis distance
nn_out <- matchit(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  data = df_nonexp, distance = "mahalanobis",
  replace = TRUE, estimand = "ATT"
)

df_nonexp$nn_weights = nn_out$weights

feols(
  re78 ~ i(treat), weights = ~nn_weights,
  data = df_nonexp,  vcov = "hc1"
)


# Coarsened-Exact Matching

cem_out <- matchit(
  treat ~ age + agesq + agecube + educ + educsq +
    marr + nodegree + black + hisp + re74 +
    re75 + u74 + u75,
  data = df_nonexp,
  method = "cem", estimand = "ATT"
)

df_nonexp$cem_weights = cem_out$weights

feols(
  re78 ~ i(treat), weights = ~cem_weights,
  data = df_nonexp,  vcov = "hc1"
)

