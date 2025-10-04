library(tidyverse)
library(sandwich)
library(lmtest)

# Set seed for reproducibility
set.seed(5150)

# Initialize results dataframe
n_trials <- 1000
results <- data.frame(
  trial = 1:n_trials,
  att = NA_real_,
  ate = NA_real_,
  ra_att = NA_real_,
  ra_ate = NA_real_,
  canonical_ols = NA_real_
)

# Simulation loop
for(trial in 1:n_trials) {
  # Generate data
  n <- 5000
  df <- data.frame(
    treat = c(rep(0, n/2), rep(1, n/2))
  )
  
  # Generate covariates
  df$age <- ifelse(df$treat == 1, 
                   rnorm(n/2, mean = 25, sd = 2.5),
                   rnorm(n/2, mean = 30, sd = 3))
  df$gpa <- ifelse(df$treat == 1,
                   rnorm(n/2, mean = 1.76, sd = 0.5),
                   rnorm(n/2, mean = 2.3, sd = 0.75))
  
  # Center covariates
  df$age <- df$age - mean(df$age)
  df$gpa <- df$gpa - mean(df$gpa)
  
  # Create transformed variables
  df$age_sq <- df$age^2
  df$gpa_sq <- df$gpa^2
  df$interaction <- df$age * df$gpa
  df$e <- rnorm(n, mean = 0, sd = 250)
  
  # Generate potential outcomes
  df$y0 <- 15000 + 10.25 * df$age - 10.5 * df$age_sq + 
    1000 * df$gpa - 10.5 * df$gpa_sq + 
    500 * df$interaction + df$e
  
  df$y1 <- df$y0 + 2500 + 100 * df$age + 1100 * df$gpa
  
  # Observed outcome
  df$earnings <- df$treat * df$y1 + (1 - df$treat) * df$y0
  
  # Calculate true effects
  df$y_diff <- df$y1 - df$y0
  true_att <- mean(df$y_diff[df$treat == 1])
  true_ate <- mean(df$y_diff)
  
  # Canonical OLS
  canonical_model <- lm(earnings ~ age + gpa + age_sq + gpa_sq + interaction + treat,
                        data = df)
  canonical_ols <- coef(canonical_model)["treat"]
  
  # Regression adjustment
  ra_model <- lm(earnings ~ treat * (age + age_sq + gpa + gpa_sq + interaction),
                 data = df)
  ra_ate <- coef(ra_model)["treat"]
  
  # Calculate RA ATT
  treated_means <- df %>%
    filter(treat == 1) %>%
    summarise(across(c(age, age_sq, gpa, gpa_sq, interaction), mean))
  
  ra_att <- coef(ra_model)["treat"] +
    coef(ra_model)["treat:age"] * treated_means$age +
    coef(ra_model)["treat:age_sq"] * treated_means$age_sq +
    coef(ra_model)["treat:gpa"] * treated_means$gpa +
    coef(ra_model)["treat:gpa_sq"] * treated_means$gpa_sq +
    coef(ra_model)["treat:interaction"] * treated_means$interaction
  
  # Store results
  results$att[trial] <- true_att
  results$ate[trial] <- true_ate
  results$ra_att[trial] <- ra_att
  results$ra_ate[trial] <- ra_ate
  results$canonical_ols[trial] <- canonical_ols
}

# Create density plot
ggplot(results) +
  geom_density(aes(x = ra_ate, color = "RA Estimate", fill = "RA Estimate"), alpha = 0.3) +
  geom_density(aes(x = canonical_ols, color = "Canonical OLS", fill = "Canonical OLS"), alpha = 0.3) +
  geom_vline(xintercept = mean(results$ate), linetype = "dashed") +
  labs(title = "Distribution of Coefficient Estimates",
       subtitle = "RA vs Canonical OLS",
       x = "Estimate",
       y = "Density",
       caption = paste("True ATE is vertical dashed line equalling $", 
                       round(mean(results$ate)), 
                       ", RA is centered at $", 
                       round(mean(results$ra_ate)),
                       " and Canonical OLS is centered at $",
                       round(mean(results$canonical_ols)))) +
  scale_color_manual(name = "", 
                     values = c("RA Estimate" = "blue", "Canonical OLS" = "red")) +
  scale_fill_manual(name = "", 
                    values = c("RA Estimate" = "blue", "Canonical OLS" = "red")) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("kernel_density_plot.png", width = 10, height = 6)