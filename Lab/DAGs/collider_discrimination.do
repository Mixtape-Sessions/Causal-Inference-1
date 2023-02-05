* code from Erin Hengel

clear all 
set obs 10000 

* Half of the population is female. 
generate female = runiform()>=0.5 

* Innate ability is independent of gender. We are not assuming any kind of genetic differences that would create differences in underlying ability.
generate ability = rnormal() // random draw from the standard normal and not different by female

* All females experience discrimination. 
generate discrimination = female 

* Data generating processes. We are not committing to the "females have different preferences" argument.
generate occupation = (1) + (2)*ability + (0)*female + (-2)*discrimination + rnormal() // iid
generate wage 		= (1) + (-1)*discrimination + (1)*occupation + 2*ability + rnormal() // iid

* Regressions

* 1. Total effect of discrimination on wages (includes occupational channels and the discrimination channels)

regress wage discrimination // total effect (don't control for anything)

* 2. Now we control for a "bad control" (angrist and pischke language) or what we call a "collider"

regress wage discrimination occupation 

* 3.  Close the backdoor that we opened in #2 by controlling for ability

regress wage discrimination occupation ability




