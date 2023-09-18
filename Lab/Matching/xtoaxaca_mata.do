version 14.1
clear mata 

***********************************
*** MATA functions             ****
***********************************

*** NORMALIZE CATEGORICAL VARIABLES ****
cap mata: mata drop xtoaxaca_mata_normalize()
mata:
void xtoaxaca_mata_normalize(                  ///
    string scalar mname,
    numeric scalar colrange1,
    numeric scalar colrange2,
    numeric scalar n_decvars
)
{
    real matrix    x
    
    x  = st_matrix(mname)
    
    x[,n_decvars+1] = x[,n_decvars+1] + rowsum(x[,colrange1..colrange2])/(colrange2-colrange1+1)	
    x[,colrange1..colrange2] = x[,colrange1..colrange2]:-rowsum(x[,colrange1..colrange2])/(colrange2-colrange1+1)
    st_matrix(mname, x)
    
}
end


cap  mata: mata drop xtoaxaca_mata_levels()
mata:
    void xtoaxaca_mata_levels(                  ///
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,
        string scalar E,
        string scalar C,
        string scalar CE,
        string scalar PE,
        string scalar PC,
        string scalar PCE,
        string scalar basediff,
        string scalar twofold,
        real   scalar weight,
        string scalar means_A_SD,
        string scalar means_B_SD,
        string scalar U,
        string scalar PU,
		string scalar refmat,
		string scalar prefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix Em,PEm, basediffm, refmatm, prefmatm, total2
        real matrix Cm,CEm,PCm,PCEm

        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		refmatm = st_matrix(refmat)[2,]
	
        if (twofold != "") {
            real matrix W, I
            real matrix Um, PUm
			
            if (twofold == "pooled") {	 
                    real matrix meansA_SD, meansB_SD
                    meansA_SD = st_matrix(means_A_SD)
                    meansB_SD = st_matrix(means_B_SD)
                    W = meansA_SD:/(meansA_SD + meansB_SD)
            }
            else if (twofold == "weight") {
                    W = J(rows(meansA),cols(meansA),weight)
            }
			    
            I = J(rows(meansA),cols(meansA),1)
			
            Em =   (meansA:-meansB) :* (W:*coefsA' + (I-W):*coefsB') 
            Um =   ((I-W):*meansA + W:*meansB ):* (coefsA' :- coefsB')
            
			
			total = colsum(Em) +colsum(Um)  + refmatm
			
            Em  = Em \ colsum(Em)
            Um  = Um \ colsum(Um)
			
			
			
            
            PEm  = (Em  :/ total):*100
            PUm  = (Um  :/ total):*100
			prefmatm =  (refmatm :/ total):*100
            

            st_matrix(E,Em)
            st_matrix(U,Um)
            st_matrix(prefmat,prefmatm)
            st_matrix(PE,PEm)
            st_matrix(PU,PUm)
            
        }
        else if (twofold == "") {
            meansA = st_matrix(means_A)
            meansB = st_matrix(means_B)
            coefsA = st_matrix(coefs_A)
            coefsB = st_matrix(coefs_B)
            basediffm = st_matrix(basediff)
			refmatm = st_matrix(refmat)[2,]

            Em =  (meansA:-meansB ) :* coefsB' 
            Cm =   meansB :* (coefsA' :- coefsB')
            CEm = (meansA:-meansB ) :* (coefsA' :- coefsB')
            
			
			total2 = Em +Cm + CEm 
			total = colsum(Em) +colsum(Cm) + colsum(CEm) + refmatm
			
            Em  = Em \ colsum(Em)
            Cm  = Cm \ colsum(Cm) 
            CEm = CEm \ colsum(CEm) 
            
			
			
            PEm  = (Em  :/ total):*100
            PCm  = (Cm  :/ total):*100
            PCEm = (CEm :/ total):*100
			prefmatm =  (refmatm :/ total):*100

	    
            
			st_matrix(prefmat,prefmatm)
            st_matrix(E,Em)
            st_matrix(C,Cm)
            st_matrix(CE,CEm)
            st_matrix(PE,PEm)
            st_matrix(PC,PCm)
            st_matrix(PCE,PCEm)
        }
    }
end

cap  mata: mata drop xtoaxaca_mata_hart2fold()
mata:
void xtoaxaca_mata_hart2fold(                  ///
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,	  
        string scalar dE,
        string scalar dC,
        string scalar dCE,
        string scalar PdE,
        string scalar PdC,
        string scalar PdCE,
        numeric scalar posofreftime,
        string scalar basediff,
		string scalar basechange,
		string scalar twofold,
        real   scalar weight,
        string scalar means_A_SD,
        string scalar means_B_SD,
        string scalar dU,
		string scalar PdU,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix dEm,dUm, basediffm, PdEm, PdUm, refmatm, prefmatm, drefmatm, pdrefmatm, coefs_star
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
        basechangem = st_matrix(basechange)
		refmatm = st_matrix(refmat)
		
		if (twofold == "pooled") {	 
                    real matrix meansA_SD, meansB_SD
                    meansA_SD = st_matrix(means_A_SD)
                    meansB_SD = st_matrix(means_B_SD)
                    W = meansA_SD:/(meansA_SD + meansB_SD)
         }
         else if (twofold == "weight") {
                    W = J(rows(meansA),cols(meansA),weight)
         }
		 
		 I = J(rows(meansA),cols(meansA),1)
		 
		coefs_star = (W :* coefsA' + (I-W) :* coefsB')
			
        dEm =   ((meansA :- meansA[,posofreftime]) :- (meansB :- meansB[,posofreftime])) :* coefs_star[,posofreftime]
        dUm =   (meansA :* coefsA') :- (meansB :* coefsB') :+ ((meansB[,posofreftime] :* W :* coefsB'[,posofreftime]) :- (meansA[,posofreftime] :* (I-W) :* coefsA'[,posofreftime])) :+ ((meansB :- meansB[,posofreftime] :- meansA) :* W :* coefsA'[,posofreftime]) :+ ((meansA[,posofreftime] :+ meansB :- meansA) :* (I-W) :* coefsB'[,posofreftime])
		drefmatm = refmatm :- refmatm[,posofreftime]
		
		total = colsum(dEm) +colsum(dUm)  +  drefmatm[2,]
			
        dEm  = dEm \ colsum(dEm)
        dUm  = dUm \ colsum(dUm)

		pdrefmatm =  (drefmatm :/ total):*100
		
		
        PdEm  = (dEm  :/ total):*100
        PdUm  = (dUm  :/ total):*100
     
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
        st_matrix(dE,dEm)
        st_matrix(dU,dUm)
        st_matrix(PdE,PdEm)
        st_matrix(PdU,PdUm)
         
		
    }
end

cap  mata: mata drop xtoaxaca_mata_hartmann()
mata:
void xtoaxaca_mata_hartmann(                  ///
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,	  
        string scalar dE,
        string scalar dC,
        string scalar dCE,
        string scalar PdE,
        string scalar PdC,
        string scalar PdCE,
        numeric scalar posofreftime,
        string scalar basediff,
		string scalar basechange,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix dEm,dCm,dCEm, basediffm, PdEm, PdCm, PdCEm, refmatm, prefmatm, drefmatm, pdrefmatm
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
        basechangem = st_matrix(basechange)
		refmatm = st_matrix(refmat)
		
        dEm  = ((meansA:-meansA[,posofreftime]) :* coefsA'[,posofreftime]) :- ((meansB:-meansB[,posofreftime]) :* coefsB'[,posofreftime]) 
		dCm  = ((coefsA':-coefsA'[,posofreftime]) :* meansA[,posofreftime]) :- ((coefsB':-coefsB'[,posofreftime]) :* meansB[,posofreftime]) 	  
		dCEm = ((meansA:-meansA[,posofreftime]):* (coefsA':-coefsA'[,posofreftime])) :- ((meansB:-meansB[,posofreftime]):* (coefsB':-coefsB'[,posofreftime]))			
		
		drefmatm = refmatm :- refmatm[,posofreftime]
		
		
		total = colsum(dEm) + colsum(dCm) + colsum(dCEm) + drefmatm[2,]
		
        dEm  = dEm \ colsum(dEm)
        dCm  = dCm \ colsum(dCm)
        dCEm = dCEm \ colsum(dCEm)
		
		
		
		pdrefmatm =  (drefmatm :/ total):*100
		
		
        PdEm  = (dEm  :/ total):*100
        PdCm  = (dCm  :/ total):*100
        PdCEm = (dCEm :/ total):*100
        
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
        st_matrix(dE,dEm)
        st_matrix(dC,dCm)
        st_matrix(dCE,dCEm)
        st_matrix(PdE,PdEm)
        st_matrix(PdC,PdCm)
        st_matrix(PdCE,PdCEm)
    }
end


cap  mata: mata drop xtoaxaca_mata_kim()
mata:
void xtoaxaca_mata_kim(                  
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,	  
        string scalar kim_D1,
        string scalar kim_D2,
        string scalar kim_D3,
        string scalar kim_D4,
        string scalar kim_D5,
        string scalar Pkim_D1,
        string scalar Pkim_D2,
        string scalar Pkim_D3,
        string scalar Pkim_D4,
        string scalar Pkim_D5,
        numeric scalar posofreftime,
        numeric scalar n_decvars,
        string scalar basediff,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB 
        real matrix kim_D1m,kim_D2m,kim_D3m,kim_D4m,kim_D5m, basediffm, refmatm, prefmatm, drefmatm, pdrefmatm
        real matrix Pkim_D1m,Pkim_D2m,Pkim_D3m,Pkim_D4m,Pkim_D5m
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		refmatm = st_matrix(refmat)
    
        kim_D1m = (coefsA'[n_decvars+1,]   :- coefsA'[n_decvars+1,posofreftime])    -   (coefsB'[n_decvars+1,]  :- coefsB'[n_decvars+1,posofreftime])
        kim_D2m = ((coefsA'[1..n_decvars,] :- coefsA'[1..n_decvars,posofreftime])   -   (coefsB'[1..n_decvars,] :- coefsB'[1..n_decvars,posofreftime]))     :* ((meansA[1..n_decvars,]  :+ meansA[1..n_decvars,posofreftime])     +   (meansB[1..n_decvars,] :+ meansB[1..n_decvars,posofreftime])):/4
        kim_D3m = ((coefsA'[1..n_decvars,] :+ coefsA'[1..n_decvars,posofreftime]):/2 -   (coefsB'[1..n_decvars,] :+ coefsB'[1..n_decvars,posofreftime]):/2) :* ((meansA[1..n_decvars,]  :- meansA[1..n_decvars,posofreftime])     +   (meansB[1..n_decvars,]  :- meansB[1..n_decvars,posofreftime])):/2
        kim_D4m = ((meansA[1..n_decvars,]  :- meansA[1..n_decvars,posofreftime])    -   (meansB[1..n_decvars,]  :- meansB[1..n_decvars,posofreftime]))      :*  ((coefsA'[1..n_decvars,] :+ coefsA'[1..n_decvars,posofreftime])   +   (coefsB'[1..n_decvars,] :+ coefsB'[1..n_decvars,posofreftime])):/4
        kim_D5m = ((meansA[1..n_decvars,]  :+ meansA[1..n_decvars,posofreftime]):/2 -   (meansB[1..n_decvars,] :+ meansB[1..n_decvars,posofreftime]):/2)    :* ((coefsA'[1..n_decvars,] :- coefsA'[1..n_decvars,posofreftime])   +   (coefsB'[1..n_decvars,] :- coefsB'[1..n_decvars,posofreftime])):/2
		
		drefmatm = refmatm :- refmatm[,posofreftime]
		
		total = colsum(kim_D1m)  + colsum(kim_D2m) + colsum(kim_D3m) + colsum(kim_D4m) + colsum(kim_D5m) + drefmatm[2,]
		
		
        kim_D2m = kim_D2m  \ J(1, cols(kim_D2m),0) \ colsum(kim_D2m)
        kim_D3m = kim_D3m  \ J(1, cols(kim_D3m),0) \ colsum(kim_D3m)
        kim_D4m = kim_D4m  \ J(1, cols(kim_D4m),0) \ colsum(kim_D4m)
        kim_D5m = kim_D5m  \ J(1, cols(kim_D5m),0) \ colsum(kim_D5m)
		
		
        
        Pkim_D1m  = (kim_D1m  :/ total):*100
        Pkim_D2m  = (kim_D2m  :/ total):*100
        Pkim_D3m  = (kim_D3m  :/ total):*100
        Pkim_D4m  = (kim_D4m  :/ total):*100
        Pkim_D5m  = (kim_D5m  :/ total):*100
		pdrefmatm = (drefmatm :/ total):*100
		
        st_matrix(kim_D1,kim_D1m)
        st_matrix(kim_D2,kim_D2m)
        st_matrix(kim_D3,kim_D3m)
        st_matrix(kim_D4,kim_D4m)
        st_matrix(kim_D5,kim_D5m)
        
        st_matrix(Pkim_D1,Pkim_D1m)
        st_matrix(Pkim_D2,Pkim_D2m)
        st_matrix(Pkim_D3,Pkim_D3m)
        st_matrix(Pkim_D4,Pkim_D4m)
        st_matrix(Pkim_D5,Pkim_D5m)
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
    }

end

cap  mata: mata drop xtoaxaca_mata_mpjd()
    mata:
    void xtoaxaca_mata_mpjd(                  
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,		  
        string scalar mpjd_E_pure,
        string scalar mpjd_E_price,
        string scalar mpjd_E_total,
        string scalar mpjd_U_pure,
        string scalar mpjd_U_price,
        string scalar mpjd_U_total,
        string scalar Pmpjd_E_pure,
        string scalar Pmpjd_E_price,
        string scalar Pmpjd_E_total,
        string scalar Pmpjd_U_pure,
        string scalar Pmpjd_U_price,
        string scalar Pmpjd_U_total,
        numeric scalar posofreftime,
        numeric scalar n_decvars,
        string scalar basediff,
		string scalar basechange,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix mpjd_E_purem, mpjd_E_pricem, mpjd_E_totalm, mpjd_U_purem, mpjd_U_pricem, mpjd_U_totalm, basediffm, basechangem, refmatm, prefmatm
        real matrix Pmpjd_E_purem, Pmpjd_E_pricem, Pmpjd_E_totalm, Pmpjd_U_purem, Pmpjd_U_pricem, Pmpjd_U_totalm, drefmatm, pdrefmatm
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		basechangem = st_matrix(basechange)
		refmatm = st_matrix(refmat)
		
		drefmatm = refmatm :- refmatm[,posofreftime]
                
        mpjd_E_purem  = ((meansA :- meansA[,posofreftime])   :-   (meansB :- meansB[,posofreftime])) :* coefsA'  
        mpjd_E_pricem = (meansA[,posofreftime] :- meansB[,posofreftime])   :*   (coefsA' :- coefsA'[,posofreftime])
        mpjd_E_totalm = mpjd_E_purem :+ mpjd_E_pricem

        mpjd_U_purem  =  meansB   :*   ((coefsA' :- coefsA'[,posofreftime]) :- (coefsB' :- coefsB'[,posofreftime])) 
        mpjd_U_pricem =  (meansB   :- meansB[,posofreftime])   :*   (coefsA'[,posofreftime] :- coefsB'[,posofreftime])
        mpjd_U_totalm   =  mpjd_U_purem :+ mpjd_U_pricem 
        
		
		total = colsum(mpjd_E_purem) + colsum(mpjd_E_pricem) + colsum(mpjd_U_purem) + colsum(mpjd_U_pricem) +  drefmatm[2,]
		
        mpjd_E_purem   = mpjd_E_purem  \ colsum(mpjd_E_purem)
        mpjd_E_pricem  = mpjd_E_pricem \ colsum(mpjd_E_pricem)
        mpjd_E_totalm  = mpjd_E_totalm \ colsum(mpjd_E_totalm)
        mpjd_U_purem   = mpjd_U_purem  \ colsum(mpjd_U_purem)
        mpjd_U_pricem  = mpjd_U_pricem \ colsum(mpjd_U_pricem)
        mpjd_U_totalm  = mpjd_U_totalm \ colsum(mpjd_U_totalm)
        
        
		
        Pmpjd_E_purem    = (mpjd_E_purem  :/ total):*100
        Pmpjd_E_pricem   = (mpjd_E_pricem :/ total):*100
        Pmpjd_E_totalm   = (mpjd_E_totalm :/ total):*100
        Pmpjd_U_purem    = (mpjd_U_purem  :/ total):*100
        Pmpjd_U_pricem   = (mpjd_U_pricem :/ total):*100
        Pmpjd_U_totalm   = (mpjd_U_totalm :/ total):*100
		
		pdrefmatm =  (drefmatm :/ total):*100
                
        st_matrix(mpjd_E_pure,mpjd_E_purem)
        st_matrix(mpjd_E_price,mpjd_E_pricem)
        st_matrix(mpjd_E_total,mpjd_E_totalm)
        st_matrix(mpjd_U_pure,mpjd_U_purem)
        st_matrix(mpjd_U_price,mpjd_U_pricem)
        st_matrix(mpjd_U_total,mpjd_U_totalm)
        st_matrix(Pmpjd_E_pure,Pmpjd_E_purem)
        st_matrix(Pmpjd_E_price,Pmpjd_E_pricem)
        st_matrix(Pmpjd_E_total,Pmpjd_E_totalm)
        st_matrix(Pmpjd_U_pure,Pmpjd_U_purem)
        st_matrix(Pmpjd_U_price,Pmpjd_U_pricem)
        st_matrix(Pmpjd_U_total,Pmpjd_U_totalm)
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
    }
end

cap  mata: mata drop xtoaxaca_mata_ssm()
mata:
    void xtoaxaca_mata_ssm(
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,
        string scalar dE,
        string scalar dC,
        string scalar dCE,
        string scalar PdE,
        string scalar PdC,
        string scalar PdCE,
        numeric scalar posofreftime,
        string scalar basediff,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix dEm, dCm, dCEm, Em, Cm, CEm,PdEm, PdCm, PdCEm, refmatm, prefmatm, drefmatm, pdrefmatm
        real matrix meansA, meansB, coefsA, coefsB
        real matrix  basediffm
            
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		refmatm = st_matrix(refmat)
		
		drefmatm = refmatm :- refmatm[,posofreftime]

        Em =  (meansA:-meansB ) :* coefsB' 
        Cm =   meansB :* (coefsA' :- coefsB')
        CEm = (meansA:-meansB ) :* (coefsA' :- coefsB')
		
		
        dEm     = Em  :- Em[,posofreftime]
        dCm     = Cm  :- Cm[,posofreftime]
        dCEm    = CEm :- CEm[,posofreftime]

        total = colsum(dEm) + colsum(dCm) + colsum(dCEm) + drefmatm[2,]
		
        dEm  = dEm \ colsum(dEm)
        dCm  = dCm \ colsum(dCm)
        dCEm = dCEm \ colsum(dCEm)
		
		
		
		pdrefmatm =  (drefmatm :/ total):*100
		
		
        PdEm  = (dEm  :/ total):*100
        PdCm  = (dCm  :/ total):*100
        PdCEm = (dCEm :/ total):*100
            
        st_matrix(dE,dEm)
        st_matrix(dC,dCm)
        st_matrix(dCE,dCEm)
        st_matrix(PdE,PdEm)
        st_matrix(PdC,PdCm)
        st_matrix(PdCE,PdCEm)
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
    }
end

cap  mata: mata drop xtoaxaca_mata_sw()
mata:
void xtoaxaca_mata_sw(                  
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,		  
        string scalar sw_i,
        string scalar sw_ii,
        string scalar sw_iii,
        string scalar sw_iv,
        string scalar Psw_i,
        string scalar Psw_ii,
        string scalar Psw_iii,
        string scalar Psw_iv,
        numeric scalar posofreftime,
        numeric scalar n_decvars,
        string scalar basediff,
		string scalar basechange,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix sw_im, sw_iim, sw_iiim, sw_ivm, basediffm, basechangem, refmatm, prefmatm
        real matrix Psw_im, Psw_iim, Psw_iiim, Psw_ivm, drefmatm, pdrefmatm
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		basechangem = st_matrix(basechange)
		refmatm = st_matrix(refmat)
        
        sw_im   = ((meansA :- meansB)   :-   (meansA[,posofreftime] :- meansB[,posofreftime]))   :*   coefsB'[,posofreftime]
        sw_iim  = (meansA :- meansA[,posofreftime])   :*   (coefsA'[,posofreftime] :- coefsB'[,posofreftime])
        sw_iiim = (meansA :- meansB)   :*   (coefsB' :- coefsB'[,posofreftime])
        sw_ivm  =  meansA   :*   ((coefsA' :- coefsB')   :-   (coefsA'[,posofreftime] :- coefsB'[,posofreftime]))
		
		drefmatm = refmatm :- refmatm[,posofreftime]
		
		total = colsum(sw_im) + colsum(sw_iim) + colsum(sw_iiim) + colsum(sw_ivm) + drefmatm[2,]
		
        sw_im   = sw_im  \ colsum(sw_im)
        sw_iim  = sw_iim \ colsum(sw_iim)
        sw_iiim = sw_iiim \ colsum(sw_iiim)
        sw_ivm  = sw_ivm  \ colsum(sw_ivm)
    
	    
		
        Psw_im   = (sw_im   :/ total):*100
        Psw_iim  = (sw_iim  :/ total):*100
        Psw_iiim = (sw_iiim :/ total):*100
        Psw_ivm  = (sw_ivm  :/ total):*100
		
		pdrefmatm =  (drefmatm :/ total):*100
            
        st_matrix(sw_i,sw_im)
        st_matrix(sw_ii,sw_iim)
        st_matrix(sw_iii,sw_iiim)
        st_matrix(sw_iv,sw_ivm)
        st_matrix(Psw_i,Psw_im)
        st_matrix(Psw_ii,Psw_iim)
        st_matrix(Psw_iii,Psw_iiim)
        st_matrix(Psw_iv,Psw_ivm)
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
    }
end

cap  mata: mata drop xtoaxaca_mata_wl()
mata:
    void xtoaxaca_mata_wl(                  
        string scalar means_A,
        string scalar means_B,
        string scalar coefs_A,
        string scalar coefs_B,	  
        string scalar wl_1,
        string scalar wl_2,
        string scalar Pwl_1,
        string scalar Pwl_2,
        numeric scalar posofreftime,
        numeric scalar n_decvars,
        string scalar basediff,
		string scalar basechange,
		string scalar refmat,
		string scalar prefmat,
		string scalar drefmat,
		string scalar pdrefmat
    )
    {
        real matrix meansA, meansB, coefsA, coefsB
        real matrix wl_1m, wl_2m, basediffm, basechangem, drefmatm, pdrefmatm
        real matrix Pwl_1m, Pwl_2m
        
        meansA = st_matrix(means_A)
        meansB = st_matrix(means_B)
        coefsA = st_matrix(coefs_A)
        coefsB = st_matrix(coefs_B)
        basediffm = st_matrix(basediff)
		basechangem = st_matrix(basechange)
		refmatm = st_matrix(refmat)
		
		drefmatm = refmatm :- refmatm[,posofreftime]
        
        wl_1m    = (meansA:-meansA[,posofreftime]):*coefsA'                :- (meansB:-meansB[,posofreftime]):*coefsB'
        wl_2m    = (coefsA':-coefsA'[,posofreftime]):*meansA[,posofreftime] :- (coefsB':-coefsB'[,posofreftime]):*meansB[,posofreftime]
        
		total = colsum(wl_1m) + colsum(wl_2m) + drefmatm[2,]
		
        wl_1m    = wl_1m  \ colsum(wl_1m)
        wl_2m    = wl_2m  \ colsum(wl_2m)
        
		pdrefmatm =  (drefmatm :/ total):*100
		
        Pwl_1m    = (wl_1m :/ total):*100
        Pwl_2m    = (wl_2m :/ total):*100
        
        st_matrix(wl_1,wl_1m)
        st_matrix(wl_2,wl_2m)
        st_matrix(Pwl_1,Pwl_1m)
        st_matrix(Pwl_2,Pwl_2m)
		st_matrix(drefmat,drefmatm)
		st_matrix(pdrefmat,pdrefmatm)
    }
end

mata: mata mlib create lxtoaxaca, replace 
 
mata: mata mlib add lxtoaxaca   xtoaxaca_mata_wl() xtoaxaca_mata_sw() xtoaxaca_mata_ssm() xtoaxaca_mata_normalize() xtoaxaca_mata_mpjd() xtoaxaca_mata_levels() xtoaxaca_mata_kim() xtoaxaca_mata_hart2fold()  xtoaxaca_mata_hartmann()
