clear all

use "C:\Users\salon\Downloads\LabMalaria\MalariaData_reduced.dta" 


//summarize B_knowledge_correct if act40==1
//scalar m40= r(mean)

//summarize B_knowledge_correct if act60==1
//scalar m60= r(mean)


//summarize B_knowledge_correct if act100==1
//scalar m100= r(mean)


//summarize B_knowledge_correct if control==1
//scalar mc= r(mean)


//gen d40 = B_knowledge_correct if act40==1
//gen d60 = B_knowledge_correct if act60==1
//gen d100 = B_knowledge_correct if act100==1
//gen dc = B_knowledge_correct if control==1


//ttest d40==dc, unpaired
//ttest d60==dc, unpaired
//ttest d100==dc, unpaired


foreach i in B_knowledge_correct B_head_edu B_head_age_imputed B_dist_km{
foreach j in "know" "head" "imputed" "km"{

summarize `i' if act40==1
scalar m`j'40`i'= r(mean)

summarize `i' if act60==1
scalar m`j'60`i'= r(mean)


summarize `i' if act100==1
scalar m`j'100`i'= r(mean)


summarize `i' if control==1
scalar m`j'c`i'= r(mean)

// 
//Código que reune todos los numeritos en una matriz aquí
//

gen d`j'40`i' = B_knowledge_correct if act40==1
gen d`j'60`i' = B_knowledge_correct if act60==1
gen d`j'100`i' = B_knowledge_correct if act100==1
gen d`j'c`i' = B_knowledge_correct if control==1


ttest d`j'40`i'==d`j'c`i', unpaired
ttest d`j'60`i'==d`j'c`i', unpaired
ttest d`j'100`i'==d`j'c`i', unpaired


}
}

matrix define 

help matrix (mB,,,\,,,\,,,\,,,)


reg m_care_nothing act40
reg m_care_nothing act60
reg m_care_nothing act100
reg m_care_nothing control

reg m_took_act act40
reg m_took_act act60
reg m_took_act act100
reg m_took_act control

reg m_took_maltest act40
reg m_took_maltest act60
reg m_took_maltest act100
reg m_took_maltest control

// 
//Código que reune todos los numeritos en una matriz aquí
//