********************************************************************************
* name: selection_examples.do
* author: scott cunningham (baylor)
* description: illustrating three forms of selection plus an RCT 
* last updated: tuesday march 21, 2024
********************************************************************************

* y0: happiness if you don't go to college
* y1: happiness if you go to college
* y1-y0: causal effect of going to college on happiness
* d: college dummy variable
* each row is a person

* Selection on y0: independence of y1 with respect to d, y1 _||_ d
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y0: y1 _||_ D

gen 	d=0
replace d=1 if y0>=100

* Create the aggregate conditional causal effects
egen ate = mean(delta)
egen att = mean(delta) if d==1
egen atu = mean(delta) if d==0
su ate-atu

* Check for independence with respect to y0
summarize y0 if d==0
summarize y0 if d==1 

* check for independence with respect to y1

summarize y1 if d==0
summarize y1 if d==1

* check for independence with respect to treatment effects
summarize delta if d==0
summarize delta if d==1

* switching equation
gen y=d*y1 + (1-d)*y0

egen temp_1 = mean(y) if d==1
egen temp_0 = mean(y) if d==0

egen y_1 = min(temp_1)
egen y_0 = min(temp_0)

gen sdo = y_1-y_0

su sdo ate att atu // when treatment is independent of y1, SDO = ATU
reg y d // sdo is the coefficient on treatment


* selection on y1: independnece of y0 with respect to d, y0 _||_ d
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y1: 

gen 	d=0
replace d=1 if y1>=150

* Create the aggregate conditional causal effects
egen ate = mean(delta)
egen att = mean(delta) if d==1
egen atu = mean(delta) if d==0
su ate-atu


* Check for independence with respect to y0
summarize y0 if d==0
summarize y0 if d==1 

* check for independence with respect to y1

summarize y1 if d==0
summarize y1 if d==1

* check for independence with respect to treatment effects
summarize delta if d==0
summarize delta if d==1

* switching equation
gen y=d*y1 + (1-d)*y0

egen temp_1 = mean(y) if d==1
egen temp_0 = mean(y) if d==0

egen y_1 = min(temp_1)
egen y_0 = min(temp_0)

gen sdo = y_1-y_0

su sdo ate att atu
reg y d // sdo is coefficient on treatment



* selection on delta = y1-y0, no independence (selection on treatment gains)
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y1

gen 	d=0
replace d=1 if delta>=50

* Create the aggregate conditional causal effects
egen ate = mean(delta)
egen att = mean(delta) if d==1
egen atu = mean(delta) if d==0
su ate-atu

* Check for independence with respect to y0
summarize y0 if d==0
summarize y0 if d==1 

* check for independence with respect to y1

summarize y1 if d==0
summarize y1 if d==1

* check for independence with respect to treatment effects
summarize delta if d==0
summarize delta if d==1

* switching equation
gen y=d*y1 + (1-d)*y0

egen temp_1 = mean(y) if d==1
egen temp_0 = mean(y) if d==0

egen y_1 = min(temp_1)
egen y_0 = min(temp_0)

gen sdo = y_1-y_0

su sdo ate att atu
reg y d // sdo is coefficient on treatment





* randomized experiment: no selection
clear
set obs 1000000

* no selection: (Y0,Y1) _||_ D "independence of treatment"

gen 	d=0
replace d=1 in 1/500000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* Create the aggregate conditional causal effects
egen ate = mean(delta)
egen att = mean(delta) if d==1
egen atu = mean(delta) if d==0
su ate-atu

* Check for independence with respect to y0
summarize y0 if d==0
summarize y0 if d==1 

* check for independence with respect to y1

summarize y1 if d==0
summarize y1 if d==1

* check for independence with respect to treatment effects
summarize delta if d==0
summarize delta if d==1

* switching equation
gen y=d*y1 + (1-d)*y0

egen temp_1 = mean(y) if d==1
egen temp_0 = mean(y) if d==0

egen y_1 = min(temp_1)
egen y_0 = min(temp_0)

gen sdo = y_1-y_0

su sdo ate att atu
reg y d // sdo is coefficient on treatment


