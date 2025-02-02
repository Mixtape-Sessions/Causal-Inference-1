# Install and load required package
install.packages("ivDiag")
library(ivDiag)
library(haven)

# Read the Card data
card <- read_dta("https://raw.github.com/scunning1975/mixtape/master/card.dta")

# 1. Calculate the Olea-Pflueger effective F statistic
effF <- eff_F(data = card,
              Y = "lwage",
              D = "educ",
              Z = "nearc4",
              cl = NULL,  # No clustering
              weights = NULL)  # No weights

# 2. Perform Anderson-Rubin test with confidence intervals
ar_results <- AR_test(data = card,
                      Y = "lwage",
                      D = "educ",
                      Z = "nearc4",
                      controls = NULL,
                      CI = TRUE,  # Calculate confidence interval
                      alpha = 0.05)  # 5% significance level

# 3. For a complete analysis, you can use the omnibus function ivDiag
iv_results <- ivDiag(data = card,
                     Y = "lwage",
                     D = "educ",
                     Z = "nearc4",
                     bootstrap = TRUE,
                     run.AR = TRUE)

# View results
print(effF)  # Effective F statistic
print(ar_results)  # AR test results and confidence interval

# Plot the results
plot_coef(iv_results)
