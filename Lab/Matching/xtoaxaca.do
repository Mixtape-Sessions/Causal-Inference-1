
sjlog using xtoaxaca4, replace
use xtoaxaca_example2, clear
quietly eststo m: xtreg dep i.time##i.group##i.int1 i.time##i.group##i.int2, i(id)
xtoaxaca int1 int2, groupvar(group) groupcat(0 1) timevar(time) times(1 2) timeref(1) model(m) change(interventionist)
sjlog close, replace

sjlog using xtoaxaca5, replace
use xtoaxaca_example, clear
xtset id
* Create interaction term for a squared term
replace exp = exp-10
generate exp2 = exp*exp
* for interactions among decomposition variables (squared experience)
* a hand-made interaction-term is used
quietly eststo est3: xtreg inc i.group##i.time##c.(exp exp2) i.group##i.time##i.edu
xtoaxaca edu exp exp2, groupvar(group) groupcat(0 1) timevar(time) nolevels times(4 2 1) model(est3) timeref(2) change(interventionist) detail normalize(edu)
sjlog close, replace


