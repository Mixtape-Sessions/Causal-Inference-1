lmb_data <- lmb_data %>% 
  mutate(demvoteshare_sq = demvoteshare_c^2)

lmb_data <- lmb_data %>% 
  mutate(lagdemvoteshare_c = lagdemvoteshare - 0.5)

lmb_data <- lmb_data %>% 
  mutate(lagdemvoteshare_sq = lagdemvoteshare_c^2)


lm_1 <- lm_robust(score ~ lagdemocrat*lagdemvoteshare_c + lagdemocrat*lagdemvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat*demvoteshare_c + democrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

