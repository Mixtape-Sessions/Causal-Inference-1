# Hansen DWI Replication

**Directions:** Download `hansen_dwi.dta` from GitHub at the following address. Note these data are not exactly the same as his because of confidentiality issues (so he couldn’t share all of it).

https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi

The outcome variable is `recidivism` which is measuring whether the person showed back up in the data within 4 months. Use this data to answer the following questions.

1. We will only focus on the 0.08 BAC cutoff; not the 0.15 cutoff. Take the following steps.
  a. Create a treatment variable (`dui`) equaling 1 if `bac1 >= 0.08` and 0 otherwise in your do/R file.
  b. Store `bac1` into `bac1_orig` and then center the `bac1` variable, i.e. subtract $0.08$ so that the cutoff is now zero. 
  c. Replicate Hansen’s Figure 1 examining whether there is any evidence for manipulation on the running variable. Produce a raw histogram using `bac1`, then use the density test in Cattaneo, Titunik and Farrell’s `rddensity` package. Can you find any evidence for manipulation? What about heaping?

2. We are going to test for manipulation around the cutoff (following Table 2 Panel A). Run RD regressions using a local-linear estimator on `white`, `male`, age (`aged`) and accident (`acc`) as dependent variables. Are the covariates balanced at the cutoff? Use data in `bac1_orig` 0.03 to 0.13 (or `bac1` in -0.05 to 0.05). Check if the results are robust to a more narrow bandwidth of `bac1_orig` in 0.055 to 0.105. 

3. Now, we turn our main result, estimating the effect of getting a DUI on recidivism (`recid`).
  a. Run an RD estimate using the `rdrobust` command (from the `rdrobust` package in R)
  b. Like all RD applications, you need to include a plot of the underlying data. Plot the RD estimator using the `rdplot` command (from the `rdrobust` package in R).

4. Repeat but drop units in the close vicinity of 0.08 (0.079-0.081) (i.e., the "donut hole" regression). Do the results stay the same?
