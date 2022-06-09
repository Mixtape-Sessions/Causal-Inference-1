## hansen.R --------------------------------------------------------------------
## Kyle Butts, CU Boulder Economics
## 
## replicate figures and tables in Hansen 2015 AER

library(data.table)
library(fixest)
library(ggplot2)
library(rdrobust)
library(rddensity)
library(binsreg)

# load the data from github
df <- haven::read_dta("https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi.dta")
setDT(df)


# Q1: create some variables
df[, dui := (bac1 > 0.08)]
df[, bac1_sq := bac1^2]

# First, make it as a discrete variable (bac1), once as continuous (bac1).
ggplot(df) + 
  geom_histogram(
    aes(x = bac1), binwidth = 0.001,
    alpha = 0.8, color = "steelblue"
  ) + 
  labs(
    x = "Blood Alcohol Content",
    y = "Frequency",
    title = "Replicating Figure 1 of Hansen AER 2015"
  ) + 
  theme_bw()

# Second, make it as a continuous variable -- looks like there is heaping that is visible


# Third, use rddensity from Cattnaeo, Titunik and Farrell papers
rddensity::rddensity(X = df$bac1, c = 0.08) |> summary()


# Q2: Running regressions on covariates (white, male, age and accident) to see 
# if there is a jump in average values for each of these at the cutoff.
# yi = Xi' \gamma + \alpha_1 DUI_i + \alpha_2 BAC_i + \alpha_3 BAC_i x DUI_i + u_i

# not going to cluster on the running variable because of Kolesar and Rothe 
# (2018) AER that says clustering on the running variable has an extreme
# over-rejection problem. Technically they recommend honest confidence intervals
# but that's in R and I'm not going to do it.
feols(
  c(white, male, acc, aged) ~ dui + bac1 + i(dui, bac1), 
  df[bac1 >= 0.03 & bac1 <= 0.13, ], vcov = "hc1"
) |> 
  etable()



# Q4: Our main results. regression of recidivism onto the equation (1) model. 
feols(
  recidivism ~ dui + white + male + aged + acc + bac1 + i(dui, bac1, ref = F),
  df[bac1 >= 0.03 & bac1 <= 0.13, ], vcov = "hc1"
)
feols(
  recidivism ~ dui + white + male + aged + acc + bac1 + bac1_sq + i(dui, bac1, ref = F) + i(dui, bac1_sq, ref = F),
  df[bac1 >= 0.03 & bac1 <= 0.13, ], vcov = "hc1"
)

# Slightly smaller bandwidth of 0.055 to 0.105
feols(
  recidivism ~ dui + white + male + aged + acc + bac1 + i(dui, bac1, ref = F),
  df[bac1 >= 0.055 & bac1 <= 0.105, ], vcov = "hc1"
)
feols(
  recidivism ~ dui + white + male + aged + acc + bac1 + bac1_sq + i(dui, bac1, ref = F) + i(dui, bac1_sq, ref = F),
  df[bac1 >= 0.055 & bac1 <= 0.105, ], vcov = "hc1"
)

# Visual evidence 
df_summ <- df[
  bac1 >= 0.03 & bac1 <= 0.13, 
  .(recidivism = mean(recidivism)), 
  by = bac1
]
df_summ[, dui := bac1 >= 0.08]

ggplot(df_summ) + 
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red") +
  geom_point(
    aes(x = bac1, y = recidivism, color = dui)
  ) + 
  geom_smooth(
    aes(x = bac1, y = recidivism, by = dui, color = dui), 
    se = TRUE, method = "loess"
  ) + 
  labs(
    x = "Blood Alcohol Level", y = "Conditional Mean Recidivism Rate",
    color = "Received DUI"
  ) + 
  scale_color_manual(
    values = c("steelblue", "red"), 
    guide = "none"
  ) + 
  theme_bw()


# REMEMBER THOUGH: HEAPING. Replicate Q4 myself by running "donut hole 
# regressions". How do I run a donut hole regression? I simply drop the units 
# at the cutoff. 

df[, donut := (bac1 >= 0.079 & bac1 <= 0.081)]

feols(
  recidivism ~ dui + white + male + aged + acc + bac1 + i(dui, bac1, ref = F),
  df[bac1 >= 0.03 & bac1 <= 0.13 & !donut, ], vcov = "hc1"
)



# Local polynomial regressions with triangular kernel and bias correction


rdrobust(
  y = df$recidivism, x = df$bac1, c = 0.08, kernel = "tri",
  p = 2, masspoints = "off"
) |> 
  summary()

df_donut <- df[donut == FALSE,]

est <- rdrobust(
  y = df_donut$recidivism, x = df_donut$bac1, c = 0.08, kernel = "tri", 
  p = 2, masspoints = "off"
) |> 
  summary()

# Donut nonparameteric presentation
df_summ <- df_donut[
  bac1 >= 0.03 & bac1 <= 0.13, 
  .(recidivism = mean(recidivism)), 
  by = bac1
]
df_summ[, dui := bac1 >= 0.08]

ggplot(df_summ) + 
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red") +
  geom_point(
    aes(x = bac1, y = recidivism, color = dui)
  ) + 
  geom_smooth(
    aes(x = bac1, y = recidivism, by = dui, color = dui), 
    se = TRUE, method = "loess"
  ) + 
  labs(
    x = "Blood Alcohol Level", y = "Conditional Mean Recidivism Rate",
    color = "Received DUI"
  ) + 
  scale_color_manual(
    values = c("steelblue", "red"), 
    guide = "none"
  ) + 
  theme_bw()


# rdplot
df_trimmed <- df[bac1>=0.03 & bac1<=0.13, ]
rdrobust::rdplot(
  y = df_trimmed$recidivism, x = df_trimmed$bac1, c = 0.08, kernel = "tri", p = 4,
  masspoints = "off"
)





