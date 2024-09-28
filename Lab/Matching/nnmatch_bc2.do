* nnmatch_bc2.do.  Implements the five step procedure called bias corrected nearest neighbor matching both manually as well as using the nnmatch command in teffects. Method will augment the age difference with a regression coefficient on and replace the original matched Y0 with this "augmented" Y0.

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

gen matched_control = 0

levelsof match11 if d == 1, local(match11_units)
levelsof match12 if d == 1, local(match12_units)

foreach u in `match11_units' `match12_units' {
    replace matched_control = 1 if unit == `u'
}

* Method 2.  Augmenting the bias using regression on the matched units.  

* Step 2. Regress earnings onto age for the matched control group units only.

reg earnings age if matched_control == 1
local age_coef = _b[age]

cap drop y0_match_adj
cap drop age_diff

* Step 3. Replace original matched Y0 with augmented Y0.
gen y0_match_adj = .
gen age_diff = .

forvalues i = 1/`=_N' {
    if d[`i'] == 1 {
        local match_id1 = match11[`i']
        local match_id2 = match12[`i']

        if !missing(`match_id2') {
            local y0_avg = (y0[`match_id1'] + y0[`match_id2']) / 2
            local age_avg = (age[`match_id1'] + age[`match_id2']) / 2
            local age_diff = age[`i'] - `age_avg'
            replace y0_match_adj = `y0_avg' + `age_coef' * `age_diff' if _n == `i'
        } 
		
		else {
            local age_diff = age[`i'] - age[`match_id1']
            replace y0_match_adj = y0[`match_id1'] + `age_coef' * `age_diff' if _n == `i'
        }
        replace age_diff = age[`i'] - age[`match_id1'] if _n == `i'

        * Debug: Display intermediate results for each treated unit
        di "Treated unit: `i', y0_match_adj: " y0_match_adj[_n] ", age_diff: " age_diff[_n]
    }
}

* Step 4. Calculate the bias corrected treatment effect and bias corrected ATT using the augmented Y0
gen te_bc = y1 - y0_match_adj if d == 1

* Display comparison
list person y1 y0_match_adj  te_bc if d == 1

* Summarize and compare results
teffects nnmatch (earnings age) (d), nn(1) atet biasadj(age) // 4.167
su te_bc // 4.167


