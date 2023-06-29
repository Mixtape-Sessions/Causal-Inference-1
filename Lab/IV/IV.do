** IV.do ***********************************************************************
** Kyle Butts, CU Boulder Economics
** scott cunningham, baylor
** replicate figures and tables in card and Graddy 1995

* ssc install ivreg2
* ssc install weakivtest
* ssc install twostepweakiv
* ssc install moremata


*-> 1. Fulton Fish Market `Stormy' instrument
  use "https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta", clear

  reg q p i.Mon i.Tue i.Wed i.Thu, r
  ivregress 2sls q i.Mon i.Tue i.Wed i.Thu (p = Stormy), r first
  weakivtest
  twostepweakiv 2sls q (p = Stormy ) i.Mon i.Tue i.Wed i.Thu, robust
  

*-> 2. Card College instrument
  use "https://raw.github.com/scunning1975/mixtape/master/card.dta", clear

  reg lwage educ exper i.black i.south i.married i.smsa, r
  ivregress 2sls lwage exper i.black i.south i.married i.smsa (educ = i.nearc4), r first
  weakivtest
  twostepweakiv 2sls lwage (educ = i.nearc4 ) exper i.black i.south i.married i.smsa, robust


*-> 2.a. Describing the compliers
  * gen sinmom14_x_enroll = sinmom14 * enroll
  * ivreg2 sinmom14_x_enroll exper i.black i.south i.married i.smsa (enroll = i.nearc4)
