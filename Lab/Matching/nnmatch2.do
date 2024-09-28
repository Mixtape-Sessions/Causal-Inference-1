* nearest neighbor match with two confounders

use "https://github.com/scunning1975/mixtape/raw/master/nnmatch.dta", clear

* Estimate ATT using nearest neighbor match
teffects nnmatch (earnings age gpa) (treat), atet gen(osample) metric(euclidean)

* Estimate ATT using nearest neighbor match with normalized Euclidean distance and Mahanalobis distance, respectively.
teffects nnmatch (earnings age gpa) (treat), atet metric(ivar)
teffects nnmatch (earnings age gpa) (treat), atet metric(maha)


