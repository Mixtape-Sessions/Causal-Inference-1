 *Example 1: Interventionist decomposition of income trajectories:

webuse set  http://xtoaxaca.uni-goettingen.de/
webuse xtoaxaca_example, clear

xtset id time

* Note that full factor-variable notation is used *
xtreg inc i.group##i.time##i.edu c.exp##i.group##i.time

est store control


xtoaxaca exp edu, groupvar(group) groupcat(0 1) timevar(time) times(4 2 1)  model(control) timeref(2) change(kim) 

 *Example 2: Contribution of an intervention to change in group differences:

webuse set  http://xtoaxaca.uni-goettingen.de/
webuse xtoaxaca_example2, clear

xtset id time

qui: eststo cont: xtreg dep i.time##i.group##i.int1 i.time##i.group##i.int2, i(id)

xtoaxaca int1 int2, groupvar(group) groupcat(0 1) timevar(time) times(1 2) ///
                    timeref(1)  model(cont) change(interventionist)

 *Example 3: Interactions of decomposition variables:

webuse set  http://xtoaxaca.uni-goettingen.de/
webuse xtoaxaca_example, clear

*** Create interaction term for a squared term
        replace exp = exp-10
        gen exp2 = exp*exp


*** for interactions among decomposition variables (squared experience)
*** a hand-made interaction-term is used
qui: eststo est3: xtreg inc i.group##i.time##c.(exp exp2) i.group##i.time##i.edu

xtoaxaca edu exp exp2, groupvar(group) groupcat(0 1) timevar(time) nolevels ///
         times(4 2 1) model(est3) timeref(2) change(kim) detail normalize(edu)
