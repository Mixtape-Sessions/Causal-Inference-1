library(tidyverse)
library(fixest)
library(haven)

df <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/thornton_hiv.dta")

# ------------------------------------------------------------------------------
# Part 1
# ------------------------------------------------------------------------------

# ---- 1.a. Calculate by hand
avgs <- df |> 
  filter(!is.na(any)) |> 
  group_by(any) |> 
  summarize(mean_got = mean(got, na.rm = TRUE)) 

# difference between the two means
avgs[avgs$any == 1, ]$mean_got - avgs[avgs$any == 0, ]$mean_got

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

# high incentive
feols(
  got ~ i(any), 
  data = df |> filter(tinc >= 2 | tinc == 0), cluster = ~villnum
)

# low incentive
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

tb <- NULL

permuteHIV <- function(df, random = TRUE){
  tb <- df
  # Number of treated in dataset
  n_treated <- 2222
  n_control <- nrow(tb) - n_treated
  
  if(random == TRUE){
    tb <- tb %>%
      sample_frac(1) %>%
      mutate(any = c(rep(1, n_treated), rep(0, n_control)))
  }
  
  te1 <- tb %>%
    filter(any == 1) %>%
    pull(got) %>%
    mean(na.rm = TRUE)
  
  te0 <- tb %>%
    filter(any == 0) %>%
    pull(got) %>% 
    mean(na.rm = TRUE)
  
  ate <-  te1 - te0
  
  return(ate)
}

permuteHIV(hiv, random = FALSE)

iterations <- 1000

permutation <- tibble(
  iteration = c(seq(iterations)), 
  ate = as.numeric(
    c(permuteHIV(hiv, random = FALSE), map(seq(iterations-1), ~permuteHIV(hiv, random = TRUE)))
  )
)

#calculating the p-value

permutation <- permutation %>% 
  arrange(-ate) %>% 
  mutate(rank = seq(iterations))

p_value <- permutation %>% 
  filter(iteration == 1) %>% 
  pull(rank)/iterations





