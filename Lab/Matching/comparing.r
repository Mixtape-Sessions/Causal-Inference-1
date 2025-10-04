# comparing.R - Simulated dataset with imbalance in age and gpa, both confounders

# Load required packages
library(MatchIt)
library(Matching)
library(cobalt)

# Clear workspace and set seed
rm(list = ls())
set.seed(5150)

# Create dataset
n <- 5000
treat <- c(rep(0, 2500), rep(1, 2500))  # equal proportions

# Poor pre-treatment fit (imbalance on covariates)
age <- ifelse(treat == 1, rnorm(n, 25, 2.5), rnorm(n, 30, 3))
gpa <- ifelse(treat == 0, rnorm(n, 2.3, 0.75), rnorm(n, 1.76, 0.5))

# Visualize the imbalance
par(mfrow = c(1, 2))
hist(age[treat == 1], col = rgb(0, 1, 0, 0.5), main = "Age Distribution", 
     xlab = "Age", xlim = range(age))
hist(age[treat == 0], col = rgb(0, 0, 0, 0.5), add = TRUE)
legend("topright", c("Treated", "Not treated"), fill = c("green", "gray"))

hist(gpa[treat == 1], col = rgb(0, 0, 1, 0.5), main = "GPA Distribution", 
     xlab = "GPA", xlim = range(gpa))
hist(gpa[treat == 0], col = rgb(0, 0, 0, 0.5), add = TRUE)
legend("topright", c("Treated", "Not treated"), fill = c("blue", "gray"))

# Estimate propensity score
pscore_model <- glm(treat ~ age + gpa, family = binomial(link = "logit"))
pscore <- predict(pscore_model, type = "response")

# Visualize propensity scores
hist(pscore[treat == 1], col = rgb(1, 0, 0, 0.5), main = "Propensity Score", 
     xlab = "Propensity Score", xlim = c(0, 1))
hist(pscore[treat == 0], col = rgb(0, 0, 0, 0.5), add = TRUE)
legend("topright", c("Treated", "Not treated"), fill = c("red", "gray"))

# Re-center the covariates
age <- age - mean(age)
gpa <- gpa - mean(gpa)

# Create quadratics and interaction
age_sq <- age^2
gpa_sq <- gpa^2
interaction <- gpa * age
e <- rnorm(n, 0, 5)

# Model potential outcomes
y0 <- 15000 + 10.25*age - 10.5*age_sq + 1000*gpa - 10.5*gpa_sq + 500*interaction + e
y1 <- y0 + 2500 + 100*age + 1100*gpa

# Calculate treatment effects
delta <- y1 - y0

cat("ATE:", mean(delta), "\n")
cat("ATT:", mean(delta[treat == 1]), "\n")
cat("ATU:", mean(delta[treat == 0]), "\n")

att <- mean(delta[treat == 1])
atu <- mean(delta[treat == 0])

# Create observed earnings
earnings <- treat*y1 + (1 - treat)*y0

# Create dataframe
df <- data.frame(earnings, age, gpa, age_sq, gpa_sq, interaction, treat, 
                 y0, y1, delta, pscore)

# 1) Standard regression assuming constant treatment effects
model1 <- lm(earnings ~ age + gpa + age_sq + gpa_sq + interaction + treat, data = df)
cat("\n1) Standard OLS (biased):\n")
print(coef(model1)["treat"])

# 2) Nearest neighbor matching without bias adjustment
match_nn <- Match(Y = df$earnings, 
                  Tr = df$treat, 
                  X = cbind(df$age, df$gpa, df$age_sq, df$gpa_sq, df$interaction),
                  estimand = "ATT",
                  M = 1,
                  Weight = 2)  # Weight=2 uses Mahalanobis distance

cat("\n2) NN matching without bias adjustment (biased):\n")
summary(match_nn)

# 3) Nearest neighbor matching with bias adjustment
match_nn_bias <- Match(Y = df$earnings, 
                       Tr = df$treat, 
                       X = cbind(df$age, df$gpa, df$age_sq, df$gpa_sq, df$interaction),
                       BiasAdjust = TRUE,
                       Z = cbind(df$age, df$age_sq, df$gpa, df$gpa_sq, df$interaction),
                       estimand = "ATT",
                       M = 1,
                       Weight = 2)

cat("\n3) NN matching with bias adjustment (unbiased):\n")
summary(match_nn_bias)


# 4) Regression adjustment - fully interacted model
model4 <- lm(earnings ~ treat * (age + age_sq + gpa + gpa_sq + age:gpa), data = df)

# Extract interaction coefficients
treat_coef <- coef(model4)["treat"]
age_treat_coef <- coef(model4)["treat:age"]
agesq_treat_coef <- coef(model4)["treat:age_sq"]
gpa_treat_coef <- coef(model4)["treat:gpa"]
gpasq_treat_coef <- coef(model4)["treat:gpa_sq"]
age_gpa_coef <- coef(model4)["treat:age:gpa"]

# Calculate means in treatment group
mean_age <- mean(df$age[df$treat == 1])
mean_agesq <- mean(df$age_sq[df$treat == 1])
mean_gpa <- mean(df$gpa[df$treat == 1])
mean_gpasq <- mean(df$gpa_sq[df$treat == 1])
mean_agegpa <- mean(df$interaction[df$treat == 1])

# Calculate ATT manually
att_manual <- treat_coef + 
  age_treat_coef * mean_age +
  agesq_treat_coef * mean_agesq +
  gpa_treat_coef * mean_gpa +
  gpasq_treat_coef * mean_gpasq +
  age_gpa_coef * mean_agegpa

cat("\n4) Regression adjustment (manual calculation):\n")
cat("ATT:", att_manual, "\n")

# Kitagawa-Oaxaca-Blinder method
model_treat <- lm(earnings ~ age + gpa + age_sq + gpa_sq + interaction, 
                  data = df[df$treat == 1, ])
model_control <- lm(earnings ~ age + gpa + age_sq + gpa_sq + interaction, 
                    data = df[df$treat == 0, ])

mu1 <- predict(model_treat, newdata = df)
mu0 <- predict(model_control, newdata = df)
te_hat <- mu1 - mu0

cat("\nKitagawa-Oaxaca-Blinder:\n")
cat("ATE:", mean(te_hat), "\n")
cat("ATT:", mean(te_hat[df$treat == 1]), "\n")
cat("ATU:", mean(te_hat[df$treat == 0]), "\n")

# Calculate ATU using formula: ATU = (ATE - p*ATT)/(1-p)
p_treated <- mean(df$treat)
atu_calc <- (mean(te_hat) - p_treated * mean(te_hat[df$treat == 1])) / (1 - p_treated)
cat("ATU (calculated):", atu_calc, "\n")

cat("\nTrue values for comparison:\n")
cat("True ATT:", att, "\n")
cat("True ATU:", atu, "\n")