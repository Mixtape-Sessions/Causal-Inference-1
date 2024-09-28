* nnmatch1.do. Estimates ATT using nearest neighbor matching both manually and with nnmatch.

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

* Just check I'm doing this all correct by first manually estimating the ATT without bias adjustment.

teffects nnmatch (earnings age) (d), nn(1) atet gen(match1) // get matches

* Initialize y0_match
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

* Check results
teffects nnmatch (earnings age) (d), nn(1) atet  // 36.25
predict te_nnmatch, te
predict y0_nnmatch, po
list unit person y1 y0 d age earnings match11 match12 y0_match y0_nnmatch te te_nnmatch if d==1
su te // Estimated ATT is 36.25 same as nnmatch package


