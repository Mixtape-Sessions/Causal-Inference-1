# Load required libraries
library(tidyverse)
library(haven)
library(sandwich)
library(MatchIt)
library(Matching)
library(boot)
library(readstata13)

url <- "https://raw.githubusercontent.com/scunning1975/mixtape/master/"
nsw_data <- read.dta13(str_c(url, "nsw_mixtape.dta"))
cps_data <- read.dta13(str_c(url, "cps_mixtape.dta"))

# Initial analysis on experimental data
lm(re78 ~ treat, data = nsw_data) %>% summary()
lm(re75 ~ treat, data = nsw_data) %>% summary()

# Drop treated units from NSW and append CPS controls
nsw_subset <- nsw_data %>% filter(treat == 1)
combined_data <- bind_rows(nsw_subset, cps_data)

# Create new variables
combined_data <- combined_data %>%
  mutate(
    agesq = age^2,
    agecube = age^3,
    edusq = educ^2,
    u74 = ifelse(re74 == 0, 1, 0),
    u75 = ifelse(re75 == 0, 1, 0),
    interaction1 = educ * re74,
    re74sq = re74^2,
    re75sq = re75^2,
    interaction2 = u74 * hisp
  )

# Step 2: Summary statistics by treatment status
combined_data %>%
  group_by(treat) %>%
  summarise(across(c(age, educ, marr, nodegree, black, hisp, re74, re75, u74, u75), 
                   list(mean = mean, sd = sd)))

# Step 3: Estimate propensity score
ps_model <- glm(treat ~ age + agesq + agecube + educ + edusq + marr + nodegree + 
                  black + hisp + re74 + re75 + u74 + u75 + interaction1,
                family = binomial(link = "logit"),
                data = combined_data)

combined_data$pscore <- predict(ps_model, type = "response")

# Create histogram of propensity scores
ggplot(combined_data, aes(x = pscore, fill = factor(treat))) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 50) +
  labs(title = "Distribution of Propensity Score",
       x = "Propensity Score",
       fill = "Treatment") +
  theme_minimal()

# Step 4: Trim the sample
data_trimmed <- combined_data %>%
  filter(pscore >= 0.1 & pscore <= 0.9)

# Step 5(i): Inverse probability weighting
data_trimmed <- data_trimmed %>%
  mutate(ipw = case_when(
    treat == 1 ~ 1,
    treat == 0 ~ pscore/(1-pscore)
  ))

# Weighted regression with robust standard errors
ipw_model <- lm(re78 ~ treat, data = data_trimmed, weights = ipw)
robust_se <- sqrt(diag(vcovHC(ipw_model, type = "HC1")))
summary(ipw_model)
cat("\nRobust standard errors:", robust_se)

# Step 5(ii): Propensity Score Matching
match_out <- matchit(treat ~ age + agesq + agecube + educ + edusq + marr + 
                       nodegree + black + hisp + re74 + re75 + u74 + u75,
                     data = data_trimmed,
                     method = "nearest",
                     ratio = 1)

matched_data <- match.data(match_out)
match_result <- lm(re78 ~ treat, data = matched_data)
summary(match_result)

# Step 5(iii): Nearest neighbor matching without and with bias adjustment

# Create matrix of covariates
X <- as.matrix(data_trimmed[, c("age", "agesq", "agecube", "educ", "edusq", "marr",
                                "nodegree", "black", "hisp", "re74", "re75", "u74", "u75")])

# Without bias adjustment
nn_match <- Match(Y = data_trimmed$re78,
                  Tr = data_trimmed$treat,
                  X = X,
                  M = 1,
                  BiasAdjust = FALSE)

summary(nn_match)

# With bias adjustment
nn_match_bias <- Match(Y = data_trimmed$re78,
                       Tr = data_trimmed$treat,
                       X = X,
                       M = 1,
                       BiasAdjust = TRUE)

summary(nn_match_bias)

# Step 5(iv): Regression adjustment
# Function to calculate KOB ATT
calc_kob_att <- function(data) {
  # Fit separate models for treated and control
  kob_treated <- lm(re78 ~ age + agesq + agecube + educ + edusq + marr + 
                      nodegree + black + hisp + re74 + re75 + u74 + u75, 
                    data = data %>% filter(treat == 1))
  
  kob_control <- lm(re78 ~ age + agesq + agecube + educ + edusq + marr + 
                      nodegree + black + hisp + re74 + re75 + u74 + u75, 
                    data = data %>% filter(treat == 0))
  
  # Generate predictions
  data <- data %>%
    mutate(
      mu1 = predict(kob_treated, newdata = data),
      mu0 = predict(kob_control, newdata = data)
    )
  
  # Calculate ATT
  kob_att <- mean(data$mu1[data$treat == 1] - data$mu0[data$treat == 1])
  
  return(kob_att)
}

# Bootstrap function
boot_kob <- function(data, indices) {
  d <- data[indices,]
  return(calc_kob_att(d))
}

# Perform bootstrap
set.seed(123)
boot_results <- boot(data = data_trimmed, 
                     statistic = boot_kob,
                     R = 1000)

# Get point estimate and confidence intervals
kob_att <- calc_kob_att(data_trimmed)
kob_ci <- boot.ci(boot_results, type = "perc")

# Print results
cat("Regression Adjustment (KOB) Results:\n")
cat("ATT Estimate:", kob_att, "\n")
cat("Bootstrap SE:", sd(boot_results$t), "\n")
cat("Bootstrap 95% CI:", kob_ci$percent[4], "to", kob_ci$percent[5], "\n")


# Step 6: Falsifications
# New propensity score model
ps_model_fals <- glm(treat ~ age + agesq + agecube + educ + edusq + marr + 
                       nodegree + black + hisp + re74 + u74 + interaction1,
                     family = binomial(link = "logit"),
                     data = combined_data)

combined_data$new_pscore <- predict(ps_model_fals, type = "response")

# Trim based on new propensity score
data_fals <- combined_data %>%
  filter(new_pscore >= 0.1 & new_pscore <= 0.9)

# 6(i): IPW Falsification
data_fals <- data_fals %>%
  mutate(new_ipw = case_when(
    treat == 1 ~ 1,
    treat == 0 ~ new_pscore/(1-new_pscore)
  ))

ipw_fals <- lm(re75 ~ treat, data = data_fals, weights = new_ipw)
robust_se_fals <- sqrt(diag(vcovHC(ipw_fals, type = "HC1")))
summary(ipw_fals)
cat("\nRobust standard errors (falsification):", robust_se_fals)

# 6(ii): PS Matching Falsification
match_fals <- matchit(treat ~ age + agesq + agecube + educ + edusq + marr + 
                        nodegree + black + hisp + re74 + u74,
                      data = data_fals,
                      method = "nearest",
                      ratio = 1)

matched_fals <- match.data(match_fals)
match_result_fals <- lm(re75 ~ treat, data = matched_fals)
summary(match_result_fals)

# 6(iii): Abadie-Imbens NN Matching Falsification
# Create matrix of covariates for falsification
X_fals <- as.matrix(data_fals[, c("age", "agesq", "agecube", "educ", "edusq", "marr",
                                  "nodegree", "black", "hisp", "re74", "u74")])

# Without bias adjustment
nn_match_fals <- Match(Y = data_fals$re75,
                       Tr = data_fals$treat,
                       X = X_fals,
                       M = 1,
                       BiasAdjust = FALSE)

summary(nn_match_fals)

# With bias adjustment
nn_match_bias_fals <- Match(Y = data_fals$re75,
                            Tr = data_fals$treat,
                            X = X_fals,
                            M = 1,
                            BiasAdjust = TRUE)

summary(nn_match_bias_fals)

# 6(iv): Regression adjustment Falsification using KOB
# Function to calculate KOB ATT for falsification
calc_kob_att_fals <- function(data) {
  # Fit separate models for treated and control
  kob_treated <- lm(re75 ~ age + agesq + agecube + educ + edusq + marr + 
                      nodegree + black + hisp + re74 + u74, 
                    data = data %>% filter(treat == 1))
  
  kob_control <- lm(re75 ~ age + agesq + agecube + educ + edusq + marr + 
                      nodegree + black + hisp + re74 + u74, 
                    data = data %>% filter(treat == 0))
  
  # Generate predictions
  data <- data %>%
    mutate(
      mu1 = predict(kob_treated, newdata = data),
      mu0 = predict(kob_control, newdata = data)
    )
  
  # Calculate ATT
  kob_att <- mean(data$mu1[data$treat == 1] - data$mu0[data$treat == 1])
  
  return(kob_att)
}

# Bootstrap function
boot_kob_fals <- function(data, indices) {
  d <- data[indices,]
  return(calc_kob_att_fals(d))
}

# Perform bootstrap
set.seed(123)
boot_results_fals <- boot(data = data_fals, 
                          statistic = boot_kob_fals,
                          R = 1000)

# Get point estimate and confidence intervals
kob_att_fals <- calc_kob_att_fals(data_fals)
kob_ci_fals <- boot.ci(boot_results_fals, type = "perc")

# Print results
cat("Regression Adjustment (KOB) Falsification Results:\n")
cat("ATT Estimate:", kob_att_fals, "\n")
cat("Bootstrap SE:", sd(boot_results_fals$t), "\n")
cat("Bootstrap 95% CI:", kob_ci_fals$percent[4], "to", kob_ci_fals$percent[5], "\n")