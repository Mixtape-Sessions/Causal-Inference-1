# bad_doctor.R -----------------------------------------------------------------
# name: perfect_doctor.do
# author: Scott Cunningham (Baylor) and Kyle Butts (CU Boulder)
# description: simulation of a perfect doctor assigning the treatment

library(fixest)
library(data.table)
set.seed(20200403)

# 100,000 people with differing levels of covid symptoms
N_people = 100000
df = data.table(person = 1:N_people)

# Potential outcomes (Y0): life-span if no vent
df[, y0 := rnorm(N_people, 9.4, 4)]
df[y0 < 0, y0 := 0]

# Potential outcomes (Y1): life-span if assigned to vents
df[, y1 := rnorm(N_people, 10, 4)]
df[y1 < 0, y1 := 0]

# Define individual treatment effect
df[, delta := y1 - y0]

# Bad doctor assignment puts you on vents if you're the first 50000 people
df[, vents := (person <= 50000)]

# Calculate all aggregate Causal Parameters (ATE, ATT, ATU)
ate = df[, mean(delta)]
att = df[vents == TRUE, mean(delta)]
atu = df[vents == FALSE, mean(delta)]

cat(sprintf("ATE = %.03f\n", ate))
cat(sprintf("ATT = %.03f\n", att))
cat(sprintf("ATU = %.03f\n", atu))

# Use the switching equation to select realized outcomes from potential outcomes based on treatment assignment given by the Perfect Doctor
df[, y := vents * y1 + (1 - vents) * y0]

# Calculate EY0 for vent group and no vent group so we can calculate selection bias
ey01 = df[vents == TRUE, mean(y0)]  
ey00 = df[vents == FALSE, mean(y0)] 

# Calculate selection bias based on the previous conditional expectations
selection_bias = (ey01 - ey00)

cat(sprintf(
  "Selection Bias = %.03f - %.03f = %.03f \n", 
  ey01, ey00, selection_bias
))

# Calculate the share of units treated with vents (pi)
pi = mean(df$vents)

# Manually calculate the simple difference in mean health outcomes between the vent and non-vent group
ey1 = df[vents == TRUE, mean(y)]
ey0 = df[vents == FALSE, mean(y)]
sdo = ey1 - ey0
cat(sprintf(
  "Simple Difference-in-Outcomes = %.03f - %.03f = %.03f \n", 
  ey1, ey0, sdo
))


# Calculate the simple difference in mean health outcomes between the vent and non-vent group using an OLS specification
reg = feols(
  y ~ vents, data = df, 
  vcov = "hc1"
)
cat("\n")
print(reg)

# Fill out table with all this information

# Were you able to estimate the ATE, ATT or the ATU using the SDO?  Why/why not?
sdo_check = ate + selection_bias + (1 - pi) * (att - atu)




