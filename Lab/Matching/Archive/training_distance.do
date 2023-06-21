* Nearest neighbor matching using teffects
clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/training_inexact.dta, clear


* Minimized euclidean distance with usual variance and robust 
teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(eucl) vce(iid)

teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(eucl) generate(match1)

* Minimized Maha distance with usual variance and robust 
teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) vce(iid)

teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) generate(match2)

