 *****************************************************
 * name: perfect_doctor.do
 * author: scott cunningham (baylor)
 * description: simulation of a perfect doctor assigning the treatment
 * last update: december 21, 2022
 *****************************************************
 clear
 capture log close
 set seed 20200403
 
 * 100,000 people with differing levels of covid symptoms
 
 set obs 100000
 gen person = _n
 
 * Potential outcomes (Y0): life-span if no vent
 gen 	 y0 = rnormal(9.4,4)
 replace y0=0 if y0<0
 
 * Potential outcomes (Y1): life-span if  assigned to vents
 gen 	 y1 = rnormal(10,4)
 replace y1=0 if y1<0
 
 * Defined individual treatment effect
 gen delta = y1-y0
 su delta // ATE is 0.59
 
 * Perfect doctor assigns vents only to those who need it
 gen 		vents=0
 replace 	vents=1 if delta>0
 label variable vents "Perfect Doctor Assigns vents"
 
 * Aggregate Causal Parameters
 egen ate0 = mean(delta) 				// 0.59
 egen att0 = mean(delta) if vents==1	// 4.73
 egen atu0 = mean(delta) if vents==0	// -4.32
 egen ate=max(ate0)
 egen att=max(att0)
 egen atu=max(atu0)
 
 * Switching equation is Y = DY1 + (1-D)Y0 which gives us realized outcomes
 gen y=vents*y1 + (1-vents)*y0
 
 * Calculate EY0 for vent group and no vent group so we can calculate selection bias
 egen ey0_y1		= mean(y0) if vents==1 // 7.35
 egen ey0_y0		= mean(y0) if vents==0 // 11.97
 egen ey01			= max(ey0_y1)
 egen ey00			= max(ey0_y0)
 gen selection_bias = ey01 - ey00 			// -4.49
 
 * Share of units treated with vents
 egen pi = mean(vents) // 0.54215
 
 * Two equivalent ways to calculate a simple difference in means: OLS and SDO
 reg y vents, robust // 0.24 vs. ate of 0.24
 bysort vents: su y
  
gen sdo = ate + selection_bias + (1-pi)*(att-atu)
di .5877381 + -4.486844 + (1-.54215 )*(4.72941 - -4.316504)
su
