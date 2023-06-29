 *****************************************************
 * name: bad_doctor.do
 * author: scott cunningham (baylor)
 * description: simulation of a bad doctor assigning the treatment
 * last update: december 21, 2022
 *****************************************************
 clear
 capture log close
 set seed 20200403
 
 * 100,000 people with differing levels of covid symptoms
 
 set obs 100000
 gen person = _n
 
 * make half the sample male
 
 gen male = runiform(0,1)
 replace male = 1 if male>0.5
 replace male = 0 if male<=0.5
 
  * Potential outcomes (Y0): life-span if no vent
 gen 	 y0 = rnormal(9.4,4)
 replace y0=0 if y0<0
 
 * Potential outcomes (Y1): life-span if  assigned to vents
 gen 	 y1 = rnormal(10,4)
 replace y1=0 if y1<0
 
 * Defined individual treatment effect
 gen delta = y1-y0
 su delta // ATE is 0.59
 
 * Bad doctor assignment puts you on vents if you're the first 50000 people
 gen 		vents=0
 replace 	vents=1 in 1/50000
 label variable vents "Bad Doctor Assigns vents"
 
 * Aggregate Causal Parameters
 egen ate0 = mean(delta) 				// 0.59
 egen att0 = mean(delta) if vents==1	// 0.59
 egen atu0 = mean(delta) if vents==0	// 0.59
 egen ate=max(ate0)
 egen att=max(att0)
 egen atu=max(atu0)
 
 * Switching equation is Y = DY1 + (1-D)Y0 which gives us realized outcomes
 gen y=vents*y1 + (1-vents)*y0
 
 * Calculate EY0 for vents group and no vents group so we can calculate selection bias
 egen ey0_y1		= mean(y0) if vents==1 // 9.394
 egen ey0_y0		= mean(y0) if vents==0 // 9.412
 egen ey01			= max(ey0_y1)
 egen ey00			= max(ey0_y0)
 gen selection_bias = ey01 - ey00 // -0.02
 
 * Share of units treated with vents
 egen pi = mean(vents) // 0.5
 
 * Two equivalent ways to calculate a simple difference in means: OLS and SDO
 reg y vents, robust // 0.56 vs. ate of 0.56
 bysort vents: su y
  
 gen sdo = ate + selection_bias + (1-pi)*(att-atu)
 display 0.5877381 + -.0234346 + (1-.5)*(0.585681 - 0.5897952)
 su
