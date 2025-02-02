* weakiv.do.  

clear
capture log close

use https://raw.github.com/scunning1975/mixtape/master/card.dta, clear

ivregress 2sls lwage (educ=nearc4), first robust

weakivtest // Olea-Pflueger effective F statistic
twostepweakiv 2sls lwage (educ = nearc4), robust // Anderson-Rubin confidence intervals

