* Simple Directed Acyclic Graph (DAG) of college education on earnings
clear

set seed 1000
set obs 10000

gen background = rnormal()
gen pe = 1 + (1)*background + rnormal()
gen income = 1 + (5)*pe + rnormal()
gen college = 1 + (1)*background + (1)*pe + (1)*income + rnormal()
gen earnings = 1 + (2)*college + (1)*income + rnormal()

* We know the causal effect of college on earnings is 2
reg earnings college, robust // 2.76

* Only thing needed to satisfy the backdoor criterion is to control for family income, bc family income is a noncollider on all three backdoor paths from college to earnings

reg earnings college income, robust // 1.995 which is basically 2


* Testable implications. These variables should be conditionally uncorrelated according to Daggity.net

* The model implies the following conditional independences:
* Parental education ⊥ career earnings | college education, family income

reg pe earnings college income, robust
