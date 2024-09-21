# Selection example

# Clear workspace
rm(list = ls())

# Set seed and number of observations
set.seed(1500)
n <- 10000

# Generate y0 and y1
y0 <- rnorm(n, mean = 5, sd = 2)  # y0 will have a mean of 5 and std dev. of 2
y1 <- rnorm(n, mean = 3, sd = 3)  # y1 will have a mean of 3 and std dev. of 3

# Generate delta
delta <- y1 - y0

# Compute ATE
ate <- mean(delta)
cat("ATE:", ate, "\n")

# Selection on y0. If a person's y0 is above 6.3, they get treated
d <- as.numeric(y0 >= 6.3)  # Treatment assignment based on y0

# ATT
att <- mean(delta[d == 1])
cat("ATT:", att, "\n")

# ATU
atu <- mean(delta[d == 0])
cat("ATU:", atu, "\n")

# E[Y0|D=1]
ey01 <- mean(y0[d == 1])
cat("E[Y0|D=1]:", ey01, "\n")

# E[Y0|D=0]
ey00 <- mean(y0[d == 0])
cat("E[Y0|D=0]:", ey00, "\n")

# Selection Bias
selection_bias <- ey01 - ey00
cat("Selection Bias:", selection_bias, "\n")

# Proportion treated
pi <- mean(d)
cat("Pi (Proportion treated):", pi, "\n")

# Observed outcome y
y <- d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo <- ate + selection_bias + (1 - pi) * (att - atu)
cat("SDO:", sdo, "\n")

# Regression of y on d
model1 <- lm(y ~ d)
summary(model1)

# Bias
bias <- sdo - ate
cat("Bias:", bias, "\n")

# Clean up variables
rm(d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, model1)

# Selection on y1. If a person's y1 is above 1, they get treated
d <- as.numeric(y1 >= 1)  # Treatment assignment based on y1

# ATT
att <- mean(delta[d == 1])
cat("ATT:", att, "\n")

# ATU
atu <- mean(delta[d == 0])
cat("ATU:", atu, "\n")

# E[Y0|D=1]
ey01 <- mean(y0[d == 1])
cat("E[Y0|D=1]:", ey01, "\n")

# E[Y0|D=0]
ey00 <- mean(y0[d == 0])
cat("E[Y0|D=0]:", ey00, "\n")

# Selection Bias
selection_bias <- ey01 - ey00
cat("Selection Bias:", selection_bias, "\n")

# Proportion treated
pi <- mean(d)
cat("Pi (Proportion treated):", pi, "\n")

# Observed outcome y
y <- d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo <- ate + selection_bias + (1 - pi) * (att - atu)
cat("SDO:", sdo, "\n")

# Regression of y on d
model2 <- lm(y ~ d)
summary(model2)

# Bias
bias <- sdo - ate
cat("Bias:", bias, "\n")

# Clean up variables
rm(d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, model2)

# Selection on gains. If treatment effects are positive, they'll get treated
d <- as.numeric(delta > 0)

# ATT
att <- mean(delta[d == 1])
cat("ATT:", att, "\n")

# ATU
atu <- mean(delta[d == 0])
cat("ATU:", atu, "\n")

# E[Y0|D=1]
ey01 <- mean(y0[d == 1])
cat("E[Y0|D=1]:", ey01, "\n")

# E[Y0|D=0]
ey00 <- mean(y0[d == 0])
cat("E[Y0|D=0]:", ey00, "\n")

# Selection Bias
selection_bias <- ey01 - ey00
cat("Selection Bias:", selection_bias, "\n")

# Proportion treated
pi <- mean(d)
cat("Pi (Proportion treated):", pi, "\n")

# Observed outcome y
y <- d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo <- ate + selection_bias + (1 - pi) * (att - atu)
cat("SDO:", sdo, "\n")

# Regression of y on d
model3 <- lm(y ~ d)
summary(model3)

# Bias
bias <- sdo - ate
cat("Bias:", bias, "\n")

# Clean up variables
rm(d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, model3)

# Independence. (y0, y1) independent of d
error <- runif(n, min = 0, max = 1)
d <- as.numeric(error >= 0.2)

# ATT
att <- mean(delta[d == 1])
cat("ATT:", att, "\n")

# ATU
atu <- mean(delta[d == 0])
cat("ATU:", atu, "\n")

# E[Y0|D=1]
ey01 <- mean(y0[d == 1])
cat("E[Y0|D=1]:", ey01, "\n")

# E[Y0|D=0]
ey00 <- mean(y0[d == 0])
cat("E[Y0|D=0]:", ey00, "\n")

# Selection Bias
selection_bias <- ey01 - ey00
cat("Selection Bias:", selection_bias, "\n")

# Proportion treated
pi <- mean(d)
cat("Pi (Proportion treated):", pi, "\n")

# Observed outcome y
y <- d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo <- ate + selection_bias + (1 - pi) * (att - atu)
cat("SDO:", sdo, "\n")

# Regression of y on d
model4 <- lm(y ~ d)
summary(model4)

# Bias
bias <- sdo - ate
cat("Bias:", bias, "\n")

# Clean up variables
rm(list = ls())