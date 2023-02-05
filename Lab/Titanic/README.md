# Titanic stratification

## Directions: 

Complete the code in either R or Stata for the stratification assignment then fill out the following information.  Your code should create all of these and be replicable. 

Table 1: Differences in female and adult passengers by treatment status on the Titanic
|    **Variable name**     | **First class**    | **All other classes** |
|--------------------------|--------------------|-----------------------|
|                          |  Obs      Mean     |  Obs       Mean       |
|--------------------------|--------------------|-----------------------|
| Percent adult            |                    |                |
| Percent female           |                    |                       |
|--------------------------|--------------------|-----------------------|


0. **Count the number of people and percentages for adult and female category separately**. This is just to start and illustrate how stratification differs from simply having the variables separately.

1. **Stratify the confounders**: Fill out TalOur age and sex variables are both binary, so we can only create four strata: male children, female children, male adults, female adults. Place in Table 2.


Table 2: Counts and Titanic survival rates by strata and treatment status
|    **Strata**            | **First class**    | **All other classes** |          |
|--------------------------|--------------------|-----------------------|----------|
|                          |  Obs      Mean     |  Obs       Mean       |   Total  |
|--------------------------|--------------------|-----------------------|----------|
| Male adult               |                    |                       |          | 
| Female adult             |                    |                       |          | 
| Male child               |                    |                       |          | 
| Female child             |                    |                       |          | 
|--------------------------|--------------------|-----------------------|----------|
| Total obs                |                    |                       |          |
|--------------------------|--------------------|-----------------------|----------|


2. **Calculate the differences within strata**: Calculate average survival rates for each group within each of the four strata and difference within strata. (Table 3)
3. **Calculate probability weights**: Count the number of people in each strata and divide by the total number of people aboard (crew and passengers). (Table 3)
4. **Aggregate differences across strata using weights**: Estimate the ATE by aggregating the difference in survival rates over the four strata with each strata-specific difference weighted by that strata's weight. (Table 3)
5.  **Compare that result to a simple difference in mean outcomes**. You can do this manually or with a regression (but don't control for women and children). (Table 3)


Table 3: Counts and Titanic survival rates by strata and treatment status on the Titanic

|  **Strata**      | **Differences** | **ATE-weight  ATT-Weight  ATU-Weight** |
|------------------|-----------------|----------------------------------------|
| Male adult       |                 |                                        | 
| Female adult     |                 |                                        | 
| Male child       |                 |                                        | 
| Female child     |                 |                                        | 
|------------------|-----------------|----------------------------------------|
|                  | **SDO**         |  **ATE**        **ATT**      **ATU**   |
|------------------|-----------------|----------------------------------------|
| Est coefficient  |                 |                                        |
|------------------|-----------------|----------------------------------------|




## Discussion: 

1. Interpret your coefficients.  What do they mean?
2. Was the SDO biased upward or downward?  
3. How do the ATE, ATU and ATT differ?




