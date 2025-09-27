## Fulton.R --------------------------------------------------------------------
## Kyle Butts, CU Boulder Economics
## 
## replicate figures and tables in Hansen 2015 AER and Graddy 1995

library(haven)
library(fixest)
library(tidyverse)


# ---- 1. Fulton Fish Market `Stormy` instrument

df <- haven::read_dta("https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta")

# OLS
df |> 
  feols(q ~ p + i(Mon) + i(Tue) + i(Wed) + i(Thu), vcov="hc1")

# IV with `Stormy`
df |>
  feols(
    q ~ i(Mon) + i(Tue) + i(Wed) + i(Thu) | 0 | 
      p ~ Stormy,
    vcov = "hc1"
  )



# ---- 2. Card College instrument

df <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/card.dta")

# OLS
df |> 
  feols(
    lwage ~ educ + exper + black + south + married + smsa,
    vcov = "hc1"
  )

# IV with `nearc4` for being near a 4-year college
df |> 
  feols(
    lwage ~ exper + black + south + married + smsa | 0 |
      educ ~ nearc4, 
    vcov = "hc1"
  )

# Describing the compliers
# df |> 
#   feols(I(sinmom14 * enroll) ~ exper + black + south + married + smsa | 0 | enroll ~ nearc4,
#     vcov = "hc1"
#   )










