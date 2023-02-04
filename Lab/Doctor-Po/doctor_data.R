# perfect_doctor.R -------------------------------------------------------------
# name: perfect_doctor.do
# author: Scott Cunningham (Baylor) and Kyle Butts (CU Boulder)
# description: simulation of a perfect doctor assigning the treatment

library(fixest)
set.seed(20200403)

# 100,000 people with differing levels of covid symptoms
N_people = 100000
df = data.frame(person = 1:N_people)

# Potential outcomes (Y0): life-span if no vent
df$y0 = rnormal(N_people, 9.4, 4)
df$y0 = max(df$y0, 0)

# Potential outcomes (Y1): life-span if assigned to vents
df$y1 = rnormal(N_people, 10, 4)
df$y1 = max(df$y1, 0)

# Define individual treatment effect


# Perfect doctor assigns vents (the treatment) only to those who benefit


# Calculate all aggregate Causal Parameters (ATE, ATT, ATU)

# Use the switching equation to select realized outcomes from potential outcomes based on treatment assignment given by the Perfect Doctor


# Calculate EY0 for vent group and no vent group so we can calculate selection bias


# Calculate selection bias based on the previous conditional expectations


# Calculate the share of units treated with vents (pi)


# Manually calculate the simple difference in mean health outcomes between the vent and non-vent group


# Calculate the simple difference in mean health outcomes between the vent and non-vent group using an OLS specification


# Fill out table with all this information


# Were you able to estimate the ATE, ATT or the ATU using the SDO?  Why/why not?





