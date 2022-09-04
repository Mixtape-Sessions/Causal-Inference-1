clear all 
set obs 10000 

* Half of the population is female. 
generate female = runiform()>=0.5 

* Innate ability is independent of gender. We are not assuming a kind of genetic hypothesis that men and women have different
* ability distributions (ie not even committing to Charles Murray type arguments)
generate ability = rnormal() 

* All women experience discrimination. 
generate discrimination = female 

* Data generating processes. We are not committing to the "females have different preferences" argument.
generate occupation = (1) + (2)*ability + (0)*female + (-2)*discrimination + rnormal() 
generate wage = (1) + (-1)*discrimination + (1)*occupation + 2*ability + rnormal() 

* Regressions

* 1. Total effect of discrimination on wages (includes occupational channels and the discrimination channels)
regress wage discrimination 

* 2. Now we control for a "bad control" (angrist and pischke language) or what we call a "collider"

regress wage discrimination occupation 

* 3.  Close the backdoor that we opened in #2 by controlling for ability
regress wage discrimination occupation ability


