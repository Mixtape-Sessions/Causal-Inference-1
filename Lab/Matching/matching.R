library(fixest)
library(data.table)
library(MatchIt)
library(ggplot2)
set.seed(10202)

N_obs = 5000

df = data.table(
  treat = c(rep(1, 750), rep(0, N_obs - 750))
)

# Overlap
df[treat == 1, age := runif(.N, 18, 32)]
df[treat == 0, age := rnorm(.N, 35, 3)]
df[treat == 1, gpa := rnorm(.N, 2.3, 0.5)]
df[treat == 0, gpa := rnorm(.N, 1.76, 0.45)]

df[, interaction := age * gpa]
df[, age_sq := age * age]
df[, gpa_sq := gpa * gpa]

# Make's heterogeneous part have mean 0
df[, het := age - mean(age)]

df[, 
  earnings1 := 15000 + 2500 * treat + 100 * treat * het + 
    10.25 * age + 25000 * gpa + rnorm(.N, 0, 5)
]
df[, 
  earnings2 := 15000 + 2500 * treat + 100 * treat * het + 
    10.25 * age + - 0.5 * age_sq + 25000 * gpa + 
    -0.5 * gpa_sq + 500 * interaction + rnorm(.N, 0, 5)
]

# OLS on linear model -- BLUE
feols(
  earnings1 ~ i(treat), df, 
  vcov = "hc1"
)
feols(
  earnings1 ~ i(treat) + age + gpa, df, 
  vcov = "hc1"
)
feols(
  earnings1 ~ i(treat) + i(treat, age) + age, df, 
  vcov = "hc1"
)
feols(
  earnings1 ~ i(treat) + i(treat, age) + i(treat, gpa), df, 
  vcov = "hc1"
)

# OLS with square terms
feols(
  earnings2 ~ i(treat), df, 
  vcov = "hc1"
)
feols(
  earnings2 ~ i(treat) + age + gpa, df, 
  vcov = "hc1"
)
feols(
  earnings2 ~ i(treat) + i(treat, age) + age, df, 
  vcov = "hc1"
)
feols(
  earnings2 ~ i(treat) + i(treat, age) + i(treat, gpa), df, 
  vcov = "hc1"
)

# Nearest neighbor match on age and high school gpa for the ATET using euclidean distance

match_obj1 <- matchit(
    treat ~ age + gpa,
    data = df,
    method = "nearest", estimand = "ATT",
    distance = "euclidean"
)

# Get the matched dataset
match_df1 = match.data(match_obj1)

# Earnings 1
feols(
  earnings1 ~ i(treat), match_df1,
  vcov = "hc1"
)

# Earnings 1 - Bias adjustment
feols(
  earnings1 ~ i(treat) + age + gpa, match_df1,
  vcov = "hc1"
)

# Earnings 2
feols(
  earnings2 ~ i(treat), match_df1,
  vcov = "hc1"
)

# Earnings 2 - Bias adjustment
feols(
  earnings2 ~ i(treat) + age + gpa, match_df1,
  vcov = "hc1"
)

# Nearest neighbor match on age and high school gpa for the ATET using Maha distance
match_obj2 <- matchit(
    treat ~ age + gpa,
    data = df,
    method = "nearest", estimand = "ATT",
    distance = "mahalanobis"
)

# Get the matched dataset
match_df2 = match.data(match_obj2)

# Earnings 1
feols(
  earnings1 ~ i(treat), match_df2,
  vcov = "hc1"
)

# Earnings 1 - Bias adjustment
feols(
  earnings1 ~ i(treat) + age + gpa, match_df2,
  vcov = "hc1"
)

# Earnings 2
feols(
  earnings2 ~ i(treat), match_df2,
  vcov = "hc1"
)

# Earnings 2 - Bias adjustment
feols(
  earnings2 ~ i(treat) + age + gpa, match_df2,
  vcov = "hc1"
)


# Nearest neighbor match on age and high school gpa for the ATET using Maha distance
match_obj3 <- matchit(
    treat ~ age + gpa,
    data = df,
    method = "nearest", estimand = "ATT",
    distance = "scaled_euclidean"
)

# Get the matched dataset
match_df3 = match.data(match_obj3)

# Earnings 1
feols(
  earnings1 ~ i(treat), match_df3,
  vcov = "hc1"
)

# Earnings 1 - Bias adjustment
feols(
  earnings1 ~ i(treat) + age + gpa, match_df3,
  vcov = "hc1"
)

# Earnings 2
feols(
  earnings2 ~ i(treat), match_df3,
  vcov = "hc1"
)

# Earnings 2 - Bias adjustment
feols(
  earnings2 ~ i(treat) + age + gpa, match_df3,
  vcov = "hc1"
)


# Potential outcomes expressions
df[, 
  y0 := 15000 + 10.25 * age + - 0.5 * age_sq + 25000 * gpa + 
    -0.5 * gpa_sq + 500 * interaction + rnorm(.N, 0, 5)
]
df[, y1 := y0 + 2500 * treat + 100 * treat * het]
df[, delta := y1 - y0]

# Sample te
df[treat == 1, mean(delta)]
df[, earnings3 := y1 * treat + y0 * (1 - treat)]

feols(
  earnings3 ~ treat + age + gpa, df,
  vcov = "hc1"
)
feols(
  earnings3 ~ treat + age + age_sq + gpa + gpa_sq, df,
  vcov = "hc1"
)

logit_model = feglm(
  treat ~ age + gpa + age_sq + gpa_sq, df,
  vcov = "hc1", family = "logit"
)
df[, pscore := predict(logit_model)]
df[, treat_label := ifelse(treat == 1, "Treated", "Comparison")]

ggplot(df) + 
  geom_histogram(
    aes(x = pscore, fill = treat_label, color = treat_label),
    alpha = 0.7
  ) + 
  facet_wrap(~ treat_label) +
  scale_fill_manual(values = c("grey40", "green")) + 
  scale_color_manual(values = c("grey40", "green")) 
