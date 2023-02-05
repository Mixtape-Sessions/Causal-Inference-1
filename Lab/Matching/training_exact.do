* Exact matching using teffects
clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/training_exact.dta, clear

* Exact match on age for the ATET
teffects nnmatch (earnings) (treat), atet ematch(age) vce(iid)

* Exact match on age for the ATE
teffects nnmatch (earnings) (treat), ate ematch(age) osample(notmatched)
* 12 observations have no exact matches; they are identified in the osample() variable

