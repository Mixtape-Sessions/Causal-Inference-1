## hansen.R --------------------------------------------------------------------
## Kyle Butts, CU Boulder Economics
## 
## replicate figures and tables in Hansen 2015 AER

library(fixest)
library(ggplot2)
library(rdrobust)
library(rddensity)
library(binsreg)

# load the data from github
df <- haven::read_dta("https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi.dta")


# 1.a. create dui treatment variable for bac1>=0.08
df$dui = (df$bac1 > 0.08)

# 1.b. Re-center our running variable at bac1=0.08
df$bac1_orig = df$bac1
df$bac1 = df$bac1 - 0.08

# 1.c. Find evidence for manipulation or heaping using histograms
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

# Use rddensity from Cattnaeo, Titunik and Farrell papers
rddensity::rddensity(X = df$bac1, c = 0.08) |> summary()

# 2. Are the covariates balanced at the cutoff? 
# Use two separate bandwidths (0.03 to 0.13; 0.055 to 0.105)
# yi = Xi′γ + α1 DUIi + α2 BACi + α3 BACi × DUIi + ui
feols(
  c(white, male, acc, aged) ~ dui + bac1 + i(dui, bac1), 
  df[df$bac1_orig >= 0.03 & df$bac1_orig <= 0.13, ], vcov = "hc1"
) |> 
  etable()

feols(
  c(white, male, acc, aged) ~ dui + bac1 + i(dui, bac1), 
  df[df$bac1_orig >= 0.055 & df$bac1_orig <= 0.105, ], vcov = "hc1"
) |> 
  etable()


# 3. Estimate RD of DUI on Recidivism
rdrobust(
  y = df$recidivism, x = df$bac1, c = 0
)
rdplot(
  y = df$recidivism, x = df$bac1, c = 0
)

# 4. "donut hole" dropping close to 0.08
df_donut <- df[df$bac1_orig <= 0.79 | df$bac1_orig >= 0.081, ]
rdrobust(
  y = df_donut$recidivism, x = df_donut$bac1, c = 0
)

