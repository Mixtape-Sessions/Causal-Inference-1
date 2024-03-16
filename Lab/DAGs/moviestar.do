clear all 
set seed 3444 

* 2500 independent draws from standard normal distribution 
set obs 2500 
generate beauty=rnormal()  // indepedent identical draw from standard normal distribution
generate talent=rnormal()  // indepedent identical draw from standard normal distribution

* No correlation between beauty and talent
twoway (scatter beauty talent, mcolor(black) msize(small) msymbol(smx)), ytitle(Beauty) xtitle(Talent) subtitle(All people) 

reg beauty talent

* Creating the collider variable (star) 
gen score=(beauty+talent) 
egen c85=pctile(score), p(85)   
gen star=(score>=c85) 
label variable star "Movie star" 

* Conditioning on the top 85\% 
twoway (scatter beauty talent, mcolor(black) msize(small) msymbol(smx)), ytitle(Beauty) xtitle(Talent) subtitle(Aspiring actors and actresses) by(star, total)

* Regressions

reg beauty talent 				// uncorrelated
reg beauty talent if star==1 	// correlated
reg beauty talent if star==0 	// correlated

* It is not just caused by sample selection; it's caused by collider

reg beauty talent // uncorrelated
reg beauty talent star // correlated

* Star is a ``bad control'' (Angrist and Pischke 2009)

