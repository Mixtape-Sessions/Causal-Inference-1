* Selection on y0 
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y0

gen 	d=0
replace d=1 if y0>=100

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



* selection on y1
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y1

gen 	d=0
replace d=1 if y1>=150

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


* selection on delta = y1-y0
clear
set obs 1000000

gen id = _n
gen y0 = 100 + rnormal(0,20)
gen y1 = 150 + rnormal(0,15)
gen delta = y1-y0

* selection based on y1

gen 	d=0
replace d=1 if delta>=50

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



