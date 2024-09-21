# Selection example in Python

import numpy as np
import statsmodels.api as sm

# Set seed and number of observations
np.random.seed(1500)
n = 10000

# Generate y0 and y1
y0 = np.random.normal(loc=5, scale=2, size=n)  # y0 will have a mean of 5 and std dev of 2
y1 = np.random.normal(loc=3, scale=3, size=n)  # y1 will have a mean of 3 and std dev of 3

# Generate delta
delta = y1 - y0

# Compute ATE
ate = np.mean(delta)
print(f"ATE: {ate}")

# Selection on y0. If a person's y0 is above 6.3, they get treated
d = (y0 >= 6.3).astype(int)  # Treatment assignment based on y0

# ATT
att = np.mean(delta[d == 1])
print(f"ATT: {att}")

# ATU
atu = np.mean(delta[d == 0])
print(f"ATU: {atu}")

# E[Y0|D=1]
ey01 = np.mean(y0[d == 1])
print(f"E[Y0|D=1]: {ey01}")

# E[Y0|D=0]
ey00 = np.mean(y0[d == 0])
print(f"E[Y0|D=0]: {ey00}")

# Selection Bias
selection_bias = ey01 - ey00
print(f"Selection Bias: {selection_bias}")

# Proportion treated
pi = np.mean(d)
print(f"Pi (Proportion treated): {pi}")

# Observed outcome y
y = d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo = ate + selection_bias + (1 - pi) * (att - atu)
print(f"SDO: {sdo}")

# Regression of y on d
X = sm.add_constant(d)
model1 = sm.OLS(y, X).fit()
print(model1.summary())

# Bias
bias = sdo - ate
print(f"Bias: {bias}")

# Clean up variables
del d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, X, model1

# Selection on y1. If a person's y1 is above 1, they get treated
d = (y1 >= 1).astype(int)  # Treatment assignment based on y1

# ATT
att = np.mean(delta[d == 1])
print(f"ATT: {att}")

# ATU
atu = np.mean(delta[d == 0])
print(f"ATU: {atu}")

# E[Y0|D=1]
ey01 = np.mean(y0[d == 1])
print(f"E[Y0|D=1]: {ey01}")

# E[Y0|D=0]
ey00 = np.mean(y0[d == 0])
print(f"E[Y0|D=0]: {ey00}")

# Selection Bias
selection_bias = ey01 - ey00
print(f"Selection Bias: {selection_bias}")

# Proportion treated
pi = np.mean(d)
print(f"Pi (Proportion treated): {pi}")

# Observed outcome y
y = d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo = ate + selection_bias + (1 - pi) * (att - atu)
print(f"SDO: {sdo}")

# Regression of y on d
X = sm.add_constant(d)
model2 = sm.OLS(y, X).fit()
print(model2.summary())

# Bias
bias = sdo - ate
print(f"Bias: {bias}")

# Clean up variables
del d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, X, model2

# Selection on gains. If treatment effects are positive, they'll get treated
d = (delta > 0).astype(int)

# ATT
att = np.mean(delta[d == 1])
print(f"ATT: {att}")

# ATU
atu = np.mean(delta[d == 0])
print(f"ATU: {atu}")

# E[Y0|D=1]
ey01 = np.mean(y0[d == 1])
print(f"E[Y0|D=1]: {ey01}")

# E[Y0|D=0]
ey00 = np.mean(y0[d == 0])
print(f"E[Y0|D=0]: {ey00}")

# Selection Bias
selection_bias = ey01 - ey00
print(f"Selection Bias: {selection_bias}")

# Proportion treated
pi = np.mean(d)
print(f"Pi (Proportion treated): {pi}")

# Observed outcome y
y = d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo = ate + selection_bias + (1 - pi) * (att - atu)
print(f"SDO: {sdo}")

# Regression of y on d
X = sm.add_constant(d)
model3 = sm.OLS(y, X).fit()
print(model3.summary())

# Bias
bias = sdo - ate
print(f"Bias: {bias}")

# Clean up variables
del d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, X, model3

# Independence case. (y0, y1) independent of d
error = np.random.uniform(0, 1, n)
d = (error >= 0.2).astype(int)

# ATT
att = np.mean(delta[d == 1])
print(f"ATT: {att}")

# ATU
atu = np.mean(delta[d == 0])
print(f"ATU: {atu}")

# E[Y0|D=1]
ey01 = np.mean(y0[d == 1])
print(f"E[Y0|D=1]: {ey01}")

# E[Y0|D=0]
ey00 = np.mean(y0[d == 0])
print(f"E[Y0|D=0]: {ey00}")

# Selection Bias
selection_bias = ey01 - ey00
print(f"Selection Bias: {selection_bias}")

# Proportion treated
pi = np.mean(d)
print(f"Pi (Proportion treated): {pi}")

# Observed outcome y
y = d * y1 + (1 - d) * y0  # Switching equation

# Structural Difference in Outcomes (sdo)
sdo = ate + selection_bias + (1 - pi) * (att - atu)
print(f"SDO: {sdo}")

# Regression of y on d
X = sm.add_constant(d)
model4 = sm.OLS(y, X).fit()
print(model4.summary())

# Bias
bias = sdo - ate
print(f"Bias: {bias}")

# Clean up variables
del d, att, atu, ey00, ey01, pi, selection_bias, y, sdo, bias, X, model4, error

# Clear all variables
del y0, y1, delta, ate, n
