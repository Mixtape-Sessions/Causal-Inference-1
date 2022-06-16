** IV.do ***********************************************************************
** Kyle Butts, CU Boulder Economics
** 
** replicate figures and tables in Hansen 2015 AER and Graddy 1995

* ssc install ivreg2

*-> 1. Fulton Fish Market `Stormy' instrument

use "https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta", clear

reg q p i.Mon i.Tue i.Wed i.Thu, r
ivreg2 q i.Mon i.Tue i.Wed i.Thu (p = Stormy), r


*-> 2. Card College instrument
use "https://raw.github.com/scunning1975/mixtape/master/card.dta", clear

reg lwage educ exper i.black i.south i.married i.smsa, r
ivreg2 lwage exper i.black i.south i.married i.smsa (educ = i.nearc4), r


*-> 2.a. Describing the compliers
* gen sinmom14_x_enroll = sinmom14 * enroll
* ivreg2 sinmom14_x_enroll exper i.black i.south i.married i.smsa (enroll = i.nearc4)
