clear

 use "C:\Users\salon\Downloads\nsw_dw_new2.dta" 
 
 forvalues i =2001/2100{
 gen age`i'=age2000+`i'-2000 
 gen re`i'=re2000+(`i'-2000)*((-1)^(treat+1))
 
 }
 
 //regress re2000 treat
 //outreg2 using regresiones1.xls replace 
 
 forvalues i=2000/2100{
 regress re`i' treat
 outreg2 using regresiones1.xls, append
 }
 
  //outreg2 
 
 