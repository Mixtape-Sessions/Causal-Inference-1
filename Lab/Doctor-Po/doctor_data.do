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
gen 	y0 = rnormal(9.4,4)
replace y0 = 0 if y0<0

* Potential outcomes (Y1): life-span if assigned to vents
gen   	y1 = rnormal(10,4)
replace	y1 = 0 if y1<0

* Define individual treatment effect
gen delta = y1-y0

* Bad doctor assigns vents to first 50,000 ppl and no vents to second 50,000 ppl
gen 	d = 0
replace d = 1 in 1/50000

* Calculate all aggregate Causal Parameters (ATE, ATT, ATU)
egen ate = mean(delta)
egen att = mean(delta) if d==1
egen atu = mean(delta) if d==0

egen att_max = max(att)
egen atu_max = max(atu)

* Use the switching equation to select realized outcomes from potential outcomes based on treatment assignment given by the Bad Doctor
gen y = d*y1 + (1-d)*y0

* Calculate EY0 for vent group and no vent group (separately)
egen ey0_vent = mean(y0) if d==1
egen ey01 = max(ey0_vent)

egen ey0_novent = mean(y0) if d==0
egen ey00 = max(ey0_novent)


* Calculate selection bias based on the previous conditional expectations
gen selection_bias = ey01-ey00

* Calculate the share of units treated with vents (pi)
egen pi = mean(d)


* Manually calculate the simple difference in mean health outcomes between the vent and non-vent group
egen ey_vent = mean(y) if d==1
egen ey1 = max(ey_vent)

egen ey_novent = mean(y) if d==0
egen ey0 = max(ey_novent)

gen sdo = ey1 - ey0

* Calculate the simple difference in mean health outcomes between the vent and non-vent group using an OLS specification
reg y d, robust


* Fill out table with all this information
* SDO = ATE + selection bias + heterogenous treatment effect bias
gen sdo_decomp = ate + selection_bias + (1-pi)*(att_max - atu_max)


* Were you able to estimate the ATE, ATT or the ATU using the SDO?  Why/why not?

* No, because we have selection bias and we have heterogenous treatment effect both of which tilt the SDO away from the ATE
