* nnmatch_bc1.do.  Implements the five step procedure called bias corrected nearest neighbor matching both manually as well as using the nnmatch command in teffects. 

* Part 1. Load in the simulated data.
clear

* Manually input the data
input str5 person str5 y1 str5 y0 d age
"Andy"  "200"    "."     1 23
"Betty" "250"    "."     1 27
"Chad"  "150"    "."     1 29
"Doug"  "300"    "."     1 22
"Edith" "."      "225"   0 27
"Fred"  "."      "500"   0 32
"Gina"  "."      "200"   0 26
"Hank"  "."      "190"   0 26
"Inez"  "."      "180"   0 28
"Janet" "."      "140"   0 29
end

* Display the data
list

destring y1 y0 d age, force replace

* Number them
gen unit=_n

* Switching equation
gen earnings = d*y1 if d==1
replace earnings = (1-d)*y0 if d==0

* Display the table in Stata's browser
list, noobs sep(0)

* Step 1. Find each treated units nearest neighbor and save as match11 and match12. 
teffects nnmatch (earnings age) (d), nn(1) atet gen(match1) // get matches

* Then impute each treated units' missing counterfactual using only the treated units. 
gen y0_match = .

* Loop over each observation to assign y0_match for treatment group based on match11 and match12
forvalues i = 1/`=_N' {
    * If the observation is a treated unit
    if d[`i'] == 1 {
        * Get the match ids
        local match_id1 = match11[`i']
        local match_id2 = match12[`i']
        
        * Check if match12 is missing
        if !missing(`match_id2') {
            * Assign y0_match as the average of y0 of the matched control units
            replace y0_match = (y0[`match_id1'] + y0[`match_id2']) / 2 if _n == `i'
        }
        else {
            * Assign y0_match based on y0 of the single matched control unit
            replace y0_match = y0[`match_id1'] if _n == `i'
        }
    }
}

* Display the data
list

* Estimate individual treatment effects
gen te = y1 - y0_match if d==1

* Part 2: Bias correction with only matched units in outcome regression. In this example, we will use the imputation method with linear outcome regression.

* Perform nearest neighbor matching to find matched pairs
teffects nnmatch (earnings age) (d), nn(1) atet gen(match)

* Verify the matched pairs
list unit match1 match2 if d == 1

* Step 2: Identify the matched control units and create a variable identifying those units who were matched.
cap n drop matched_control
gen matched_control = 0

* Record the matched control units explicitly
levelsof match1 if d == 1, local(match11_units)
levelsof match2 if d == 1, local(match12_units)

foreach u in `match11_units' `match12_units' {
    replace matched_control = 1 if unit == `u'
}

* Verify matched control units
list unit matched_control match11 match12 if matched_control == 1

* Regress earnings onto age for the matched control units.
reg earnings age if matched_control == 1

* Step 3.  Impute muhat01 for the treated units and muhat00 for the control units.
predict muhat0

gen muhat01 = muhat0 if d == 1

gen muhat00 = .
forvalues i = 1/`=_N' {
    if d[`i'] == 1 {
        local match_id1 = match11[`i']
        local match_id2 = match12[`i']

        if !missing(`match_id1') {
            replace muhat00 = muhat0[`match_id1'] if _n == `i'
        }
        if !missing(`match_id2') {
            replace muhat00 = muhat0[`match_id2'] if _n == `i'
        }
    }
}


* Step 4. Correct for each treated unit's treatment effect by deleting the selection bias for that unit.
gen te_bc_matched1 = te - (muhat01 - muhat00)

* Summarize the bias corrected treatment effects to get the bias corrected ATT
teffects nnmatch (earnings age) (d), nn(1) atet biasadj(age) // 4.167
su te_bc_matched1 // 4.167


