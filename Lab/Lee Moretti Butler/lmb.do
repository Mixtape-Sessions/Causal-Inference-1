********************************************************************************
* name: lmb.do
* author: marcelo perraillon (uc denver) with modifications by scott cunningham (baylor)
* description: replication of Lee, Moretti and Butler with additional analysis and robustness
* last updated: january 15, 2022
********************************************************************************
clear
capture log close


* Load the raw data into memory
use https://github.com/scunning1975/mixtape/raw/master/lmb-data.dta, clear
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
ssc install rdrobust, replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace

* Replicating Table 1 of Lee, Moretti and Butler (2004) -- local linear regression (0.48 to 0.52 on the voteshare)
reg score lagdemocrat    if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg score democrat       if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg democrat lagdemocrat if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)

* Use all the data -- global linear regression
reg score lagdemocrat, cluster(id)
reg score democrat, cluster(id)
reg democrat lagdemocrat, cluster(id)


* Re-center the running variable (voteshare) controlling for the running variable (but not interacting it)
gen demvoteshare_c = demvoteshare - 0.5
gen lagdemvoteshare_c = lagdemvoteshare - 0.5
reg score lagdemocrat lagdemvoteshare_c, cluster(id)
reg score democrat demvoteshare_c, cluster(id)
reg democrat democrat demvoteshare_c, cluster(id)

* Use all the data but interact the treatment variable with the running variable
xi: reg score i.lagdemocrat*lagdemvoteshare_c, cluster(id)
xi: reg score i.democrat*demvoteshare_c, cluster(id)
xi: reg democrat i.lagdemocrat*demvoteshare_c, cluster(id)

* Use all the data but interact the treatment variable with the running variable and a quadratic
gen demvoteshare_sq = demvoteshare_c^2
gen lagdemvoteshare_sq = lagdemvoteshare_c^2
xi: reg score lagdemocrat##c.(lagdemvoteshare_c lagdemvoteshare_sq), cluster(id)
xi: reg score democrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
xi: reg democrat lagdemocrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)

* Use 5 points from the cutoff, control for the running variable x treatment, use quadratics
xi: reg score lagdemocrat##c.(lagdemvoteshare_c lagdemvoteshare_sq)   if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)
xi: reg score democrat##c.(demvoteshare_c demvoteshare_sq)       if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)
xi: reg democrat lagdemocrat##c.(demvoteshare_c demvoteshare_sq) if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)

* Nonparametric histograms using cmogram
ssc install cmogram
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) lfit
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) qfitci

* Note kernel-weighted local regression is a smoothing method.
lpoly score lagdemvoteshare if lagdemocrat == 0, nograph kernel(triangle) gen(x0 sdem0) bwidth(0.1)
lpoly score lagdemvoteshare if lagdemocrat == 1, nograph kernel(triangle) gen(x1 sdem1)  bwidth(0.1)
scatter sdem1 x1, color(red) msize(small) || scatter sdem0 x0, msize(small) ///
color(red) xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score")

* Local polynomial point estimators with bias correction
rdrobust score lagdemvoteshare, masspoints(off) p(1) c(0.5)
rdrobust score lagdemvoteshare, kernel(uniform) masspoints(off) p(2) c(0.5)
rdrobust score lagdemvoteshare, kernel(triangular) masspoints(off) p(2) c(0.5)
rdrobust score lagdemvoteshare, kernel(epanechnikov) masspoints(off) p(2) c(0.5)
rdrobust score lagdemvoteshare, masspoints(off) p(2) c(0.5)
rdrobust score lagdemvoteshare, masspoints(off) p(3) c(0.5)
rdrobust score lagdemvoteshare, masspoints(off) p(4) c(0.5)

* Data-driven RDD plots
rdplot score lagdemvoteshare, p(0) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))
rdplot score lagdemvoteshare, p(1) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))
rdplot score lagdemvoteshare, p(2) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))
rdplot score lagdemvoteshare, p(3) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))
rdplot score lagdemvoteshare, p(4) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))
rdplot score lagdemvoteshare, p(5) masspoints(off) c(0.5) graph_options(title(RD Plot for ADA Score and Voteshare))

* McCrary density test: remember it's a density test *on the running variable* (lagdemvoteshare)
rddensity lagdemvoteshare, c(0.5) plot

* Original McCrary density test: outdated, don't use it, but it's Justin McCrary's original 
* density test from that old Journal of Econometrics from 2008.
DCdensity demvoteshare_c if (demvoteshare_c>-0.5 & demvoteshare_c<0.5), breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
