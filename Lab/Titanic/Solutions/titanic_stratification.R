# Load necessary libraries
library(dplyr)
library(readstata13)

# Step 0: Load the data
df <- read.dta13("https://github.com/scunning1975/mixtape/raw/master/titanic.dta")

# Step 1: Stratify the data by sex and age
df <- df %>%
  mutate(adult_male = if_else(sex == 1 & age == 1, 1, 0),
         adult_female = if_else(sex == 0 & age == 1, 1, 0),
         child_male = if_else(sex == 1 & age == 0, 1, 0),
         child_female = if_else(sex == 0 & age == 0, 1, 0),
         first_class = if_else(class == 1, 1, 0))

# Step 2: Calculate differences in mean survival rate for all four strata
means <- df %>%
  group_by(adult_male, adult_female, child_male, child_female, first_class) %>%
  summarise(mean_survival = mean(survived, na.rm = TRUE), .groups = 'drop')

# Creating variables for differences in means
diff_af <- with(means, mean_survival[adult_female == 1 & first_class == 1] - mean_survival[adult_female == 1 & first_class == 0])
diff_am <- with(means, mean_survival[adult_male == 1 & first_class == 1] - mean_survival[adult_male == 1 & first_class == 0])
diff_cm <- with(means, mean_survival[child_male == 1 & first_class == 1] - mean_survival[child_male == 1 & first_class == 0])
diff_cf <- with(means, mean_survival[child_female == 1 & first_class == 1] - mean_survival[child_female == 1 & first_class == 0])

# Step 3: Display the number of observations and construct weights
# For ATE
ate_counts <- df %>%
  summarise(ate_af = sum(adult_female == 1),
            ate_am = sum(adult_male == 1),
            ate_cm = sum(child_male == 1),
            ate_cf = sum(child_female == 1))
ate_N <- nrow(df)

# For ATT
att_counts <- df %>%
  filter(first_class == 1) %>%
  summarise(att_af = sum(adult_female == 1),
            att_am = sum(adult_male == 1),
            att_cm = sum(child_male == 1),
            att_cf = sum(child_female == 1))
att_N <- sum(df$first_class == 1)

# For ATU
atu_counts <- df %>%
  filter(first_class == 0) %>%
  summarise(atu_af = sum(adult_female == 1),
            atu_am = sum(adult_male == 1),
            atu_cm = sum(child_male == 1),
            atu_cf = sum(child_female == 1))
atu_N <- sum(df$first_class == 0)

# Calculate weights
weights <- mutate(ate_counts, wt_ate_af = ate_af / ate_N,
                  wt_ate_am = ate_am / ate_N,
                  wt_ate_cm = ate_cm / ate_N,
                  wt_ate_cf = ate_cf / ate_N) %>%
  bind_rows(mutate(att_counts, wt_att_af = att_af / att_N,
                   wt_att_am = att_am / att_N,
                   wt_att_cm = att_cm / att_N,
                   wt_att_cf = att_cf / att_N)) %>%
  bind_rows(mutate(atu_counts, wt_atu_af = atu_af / atu_N,
                   wt_atu_am = atu_am / atu_N,
                   wt_atu_cm = atu_cm / atu_N,
                   wt_atu_cf = atu_cf / atu_N))

# Step 4: Estimate aggregate parameters using corresponding weights and differences within strata
ate_strat <- with(weights, wt_ate_af * diff_af + wt_ate_am * diff_am + wt_ate_cm * diff_cm + wt_ate_cf * diff_cf)
att_strat <- with(weights, wt_att_af * diff_af + wt_att_am * diff_am + wt_att_cm * diff_cm + wt_att_cf * diff_cf)
atu_strat <- with(weights, wt_atu_af * diff_af + wt_atu_am * diff_am + wt_atu_cm * diff_cm + wt_atu_cf * diff_cf)

# Display results
print(paste("ATE Stratification Weighted Estimate:", ate_strat))
print(paste("ATT Stratification Weighted Estimate:", att_strat))
print(paste("ATU Stratification Weighted Estimate:", atu_strat))
