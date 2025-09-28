## Thornton.R ------------------------------------------------------------------
## Scott Cunningham (Baylor University)
## Analysis of Thornton (2008) study of the demand for learning one's HIV status
## and its effects on a variety of health and behavioral outcomes

# You will ned to remove the hashtag (#) on these and just confirm you've
# installed them.  But once you install them once, they belong to your computer
# and all you then have to do is load them in using the library() command.  

# install.packages("stargazer")
# install.packages("tidyverse")
# install.packages("fixest")
# install.packages("haven")
# install.packages("ggplot2")
# install.packages("modelsummary")

library(stargazer)
library(tidyverse)
library(fixest)
library(haven)
library(ggplot2)
library(modelsummary)

# Load data
df <- haven::read_dta("https://raw.githubusercontent.com/scunning1975/mixtape/master/thornton_hiv.dta")

# ---- 1. Simple Difference in Outcomes (SDO). Treatment is "any" (any payment from lottery) 
# and outcome is "got" (picked up, or "got", their test results from VCT). "any" is 
# equal to 1 if they did receive any money and 0 if they did not.


df %>%
  group_by(any) %>%
  summarize(
    mean_got = mean(got, na.rm = TRUE),
    n = n()
  ) %>%
  mutate(group = ifelse(any == 1, "Incentive", "No incentive")) %>%
  select(any, mean_got, n, group)

# Simple Difference in mean outcomes:
sdo <- with(df, mean(got[any == 1], na.rm = TRUE) - mean(got[any == 0], na.rm = TRUE))
sdo

# ---- 2. Visualization of Simple Difference in Outcomes ----

# Create a summary table for plotting
sdo_summary <- df %>%
  filter(!is.na(any)) %>%                    # Remove rows where treatment assignment is missing
  group_by(any) %>%                          # Group by treatment assignment: 0 (control) or 1 (incentive)
  summarize(
    mean_got = mean(got, na.rm = TRUE),     # Calculate group mean for picking up results
    n = n()                                  # Count number of observations per group
  ) %>%
  mutate(group = ifelse(any == 1,            # Create readable group labels
                        "Incentive", 
                        "No incentive"))

# Plot the means using ggplot
ggplot(sdo_summary, aes(x = group, y = mean_got, fill = group)) +  # Set up plot with group on x-axis, mean on y
  geom_col(width = 0.6, show.legend = FALSE) +                      # Use bar chart with no legend
  geom_text(aes(label = round(mean_got, 2)),                        # Add text labels above bars
            vjust = -0.5, size = 5) + 
  labs(
    title = "Effect of Incentives on Picking Up HIV Results",       # Title and axis labels
    x = "", 
    y = "Mean: Picked Up HIV Test Result"
  ) +
  ylim(0, 1) +                                                      # Set y-axis range to (0,1) for consistency
  theme_minimal(base_size = 14)                                     # Use minimal theme with readable font size


# Or plot the means and also the difference labeled

# Define the coordinates of the midpoint between bars
mid_x <- 1.5
y1 <- sdo_summary$mean_got[sdo_summary$group == "Incentive"]
y2 <- sdo_summary$mean_got[sdo_summary$group == "No incentive"]

ggplot(sdo_summary, aes(x = group, y = mean_got, fill = group)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = round(mean_got, 2)), vjust = -0.5, size = 5) +
  
  # Draw vertical line showing the difference
  geom_segment(aes(x = mid_x, xend = mid_x, y = y2, yend = y1), 
               color = "black", linetype = "dashed", linewidth = 1.2) +
  
  # Add label for difference
  annotate("text", x = mid_x + 0.05, y = (y1 + y2)/2, 
           label = "0.45", size = 5, hjust = 0, vjust = -0.3) +
  
  labs(
    title = "Effect of Incentives on Picking Up HIV Results",
    x = "",
    y = "Mean: Picked Up HIV Test Result"
  ) +
  ylim(0, 1) +
  theme_minimal(base_size = 14)


# ---- 3. Comparing SDO to OLS ---- 

# OLS regression
ols_model <- feols(got ~ any, data = df)
ols_est <- coef(ols_model)[["any"]]

# Build a comparison table
comparison <- data.frame(
  `Estimated effect of any money` = "Treatment (any)",
  SDO = round(sdo, 3),
  OLS = round(ols_est, 3)
)

# Print it nicely
knitr::kable(comparison,
             caption = "Estimating the effect of payment on getting test results")


# ---- 4. Baseline covariates. ---- 
# How different are the two groups on pre-treatment characteristics

df %>%
  group_by(any) %>%
  summarize(
    mean_age = mean(age, na.rm = TRUE),
    mean_male = mean(male, na.rm = TRUE),
    mean_educ = mean(educ2004, na.rm = TRUE),
    mean_hiv2004 = mean(hiv2004, na.rm = TRUE),
    # add others
  )


# ---- 5. Picking another outcome ----
# We will pick two of the following four outcomes and repeat the previous material.  
# The variables are `hiv_got` (Learned they were HIV+ post-treatment), `numsex_fo`
# (Number of partners post-treatment), `anycond` (Purchased any condoms
# post-treatment) and `bought` (Bought condoms independently at follow-up).

# I'll do one of these: anycond.  We will calculate the SDO for the outcome "anycond" 
# (any condoms purchased) for the treatment group (any=1) and the control group (any=0)

df %>%
  group_by(any) %>%
  summarize(
    mean_anycond = mean(anycond, na.rm = TRUE),
    n = n()
  ) %>%
  mutate(group = ifelse(any == 1, "Incentive", "No incentive")) %>%
  select(any, mean_anycond, n, group)

# Simple Difference in mean outcomes (SDO) for buying any condoms:
sdo_anycond <- with(df, mean(anycond[any == 1], na.rm = TRUE) - mean(anycond[any == 0], na.rm = TRUE))
sdo_anycond # 0.07528374 or 7.5 percentage points more for the treatment group than the control group. 


# Now we will use ggplot again to calculate the pretty picture of the average 
# "any condoms bought (anycond) for our treatment group (any=1) versus our control
# group (any=0) using the code above. 

# First, I'll create a summary table for plotting
sdo_summary2 <- df %>%
  filter(!is.na(any)) %>%                    # Remove rows where treatment assignment is missing
  group_by(any) %>%                          # Group by treatment assignment: 0 (control) or 1 (incentive)
  summarize(
    mean_anycond = mean(anycond, na.rm = TRUE),     # Calculate group mean for picking up results
    n = n()                                  # Count number of observations per group
  ) %>%
  mutate(group = ifelse(any == 1,            # Create readable group labels
                        "Incentive", 
                        "No incentive"))

# Compute SDO for anycond (already done earlier, but make sure it's in the environment)
sdo_anycond <- with(df, mean(anycond[any == 1], na.rm = TRUE) - mean(anycond[any == 0], na.rm = TRUE))
sdo_anycond

# Define midpoint between bars
mid_x <- 1.5
y1 <- sdo_summary2$mean_anycond[sdo_summary2$group == "Incentive"]
y2 <- sdo_summary2$mean_anycond[sdo_summary2$group == "No incentive"]

# Plot the difference in means with a vertical line showing the gap using 
# a y-axis that goes from 0 to 1.  Notice all the white space. 
ggplot(sdo_summary2, aes(x = group, y = mean_anycond, fill = group)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = round(mean_anycond, 2)), vjust = -0.5, size = 5) +
  
  # Draw vertical line showing the difference
  geom_segment(aes(x = mid_x, xend = mid_x, y = y2, yend = y1), 
               color = "black", linetype = "dashed", linewidth = 1.2) +
  
  # Add label for actual SDO
  annotate("text", x = mid_x + 0.05, y = (y1 + y2)/2, 
           label = round(sdo_anycond, 3), size = 5, hjust = 0, vjust = -0.3) +
  
  labs(
    title = "Effect of Incentives on Any Condom Purchases",
    x = "",
    y = "Mean: Any Condoms Purchased"
  ) +
  ylim(0, 1) +
  theme_minimal(base_size = 14)


# Zoomed-in version.  Now it goes from 0 to 0.4.  What's your opinion?
ggplot(sdo_summary2, aes(x = group, y = mean_anycond, fill = group)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = round(mean_anycond, 2)), vjust = -0.5, size = 5) +
  
  # Draw vertical line showing the difference
  geom_segment(aes(x = mid_x, xend = mid_x, y = y2, yend = y1), 
               color = "black", linetype = "dashed", linewidth = 1.2) +
  
  # Add label for actual SDO
  annotate("text", x = mid_x + 0.05, y = (y1 + y2)/2, 
           label = round(sdo_anycond, 3), size = 5, hjust = 0, vjust = -0.3) +
  
  labs(
    title = "Effect of Incentives on Any Condom Purchases (Zoomed In)",
    x = "",
    y = "Mean: Any Condoms Purchased"
  ) +
  ylim(0, 0.4) +   # zoom in
  theme_minimal(base_size = 14)

