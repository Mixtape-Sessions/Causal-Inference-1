*****************************************************
* name: perfect_doctor.do
* author: scott cunningham (baylor)
* description: simulation of a perfect doctor assigning the treatment
*****************************************************
clear
capture log close
set seed 20200403

* 100,000 people with differing levels of covid symptoms

set obs 100000
gen person = _n

* Potential outcomes (Y0): life-span if no vent
gen 	  y0 = rnormal(9.4,4)
replace y0=0 if y0<0

* Potential outcomes (Y1): life-span if assigned to vents
gen 	  y1 = rnormal(10,4)
replace y1=0 if y1<0

* Define individual treatment effect


* Perfect doctor assigns vents (the treatment) only to those who benefit


* Calculate all aggregate Causal Parameters (ATE, ATT, ATU)


* Use the switching equation to select realized outcomes from potential outcomes based on treatment assignment given by the Perfect Doctor


* Calculate EY0 for vent group and no vent group (separately)


* Calculate selection bias based on the previous conditional expectations


* Calculate the share of units treated with vents (pi)


* Manually calculate the simple difference in mean health outcomes between the vent and non-vent group


* Calculate the simple difference in mean health outcomes between the vent and non-vent group using an OLS specification


* Fill out table with all this information


* Were you able to estimate the ATE, ATT or the ATU using the SDO?  Why/why not?
