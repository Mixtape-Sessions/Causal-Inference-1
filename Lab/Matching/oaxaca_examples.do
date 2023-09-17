global dofile   "oaxaca_examples"
version 10.0
clear all
discard
qui set memory 10m
set more off
set rmsg off

sjlog using oaxaca_ex1, replace
use oaxaca, clear
oaxaca lnwage educ exper tenure, by(female) noisily
sjlog close, replace

sjlog using oaxaca_ex2, replace
oaxaca lnwage educ exper tenure, by(female) pooled
sjlog close, replace

sjlog using oaxaca_ex3, replace
oaxaca, eform
sjlog close, replace

sjlog using oaxaca_ex4, replace
svyset [pw=wt]
oaxaca lnwage educ exper tenure, by(female) pooled svy
sjlog close, replace

oaxaca lnwage educ exper tenure [pw=wt], by(female) pooled


sjlog using oaxaca_ex5, replace
oaxaca lnwage educ exper tenure, by(female) model2(heckman, twostep ///
    select(lfp = age agesq married divorced kids6 kids714))
sjlog close, replace

if 0 {
sjlog using oaxaca_ex6, replace
probit lfp age agesq married divorced kids6 kids714 if female==1
predict xb if e(sample), xb
generate mills = normalden(-xb) / (1 - normal(-xb))
replace mills = 0 if female==0
oaxaca lnwage educ exper tenure mills, by(female) adjust(mills)
sjlog close, replace
}

sjlog using oaxaca_ex7, replace
tabulate isco, nofreq generate(isco)
oaxaca lnwage educ exper tenure isco2-isco9, by(female) pooled ///
    detail(exp_ten: exper tenure, isco: isco?) categorical(isco?)
sjlog close, replace

