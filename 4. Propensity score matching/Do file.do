
global folder="PONER AQUI EL DIRECTORIO DE LA CARPETA DONDE GUARDARON SU BASE DE DATOS"

cd "$folder"

use nsw_dw_new.dta, clear

* Hacer las regresiones de MCO para obtener el estimador de un experimento aleatorio.

reg re78 treat 
outreg2 using regresiones_rct, excel replace ctitle(sincontroles) stats (coef se ci) dec(0) nodepvar
reg re78 treat age education married 
outreg2 using regresiones_rct, excel append ctitle(concontroles1) stats (coef se ci) dec(0) nodepvar 
reg re78 treat treat age education married hispanic black nodegree re74 re75
outreg2 using regresiones_rct, excel append ctitle(concontroles2) stats (coef se ci) dec(0) nodepvar  


use psid_controls_new.dta, clear

* Obtener la diferencia de medias incondicional (y la desviación estándar de la diferencia de medias) entre los tratados y los no tratados.

ttest re78, by(treat) reverse
local diff=`r(mu_1)'-`r(mu_2)' /*guardar en un local la diferencia de medias */

mat A=[`diff' \ `r(se)'] /*poner en una matriz la diferencia de medias y su desviación estándar */
mat list A

mat drop A

* Calcular la diferencia de medias entre tratados y no tratados con el método de propensity score matching.

psmatch2 treat age education married, outcome(re78)  
local pval = 2*ttail(`e(df_r)', abs(`r(att)'/`r(seatt)'))
matrix A = ( `r(att)' \ `r(seatt)' \ `pval' ) /*guardar en una matriz el estimador de PSM, su desviación estandar y su p-value */
mat list A

psmatch2 treat age education married black hispanic nodegree re74 re75, outcome(re78)  
local pval = 2*ttail(`e(df_r)', abs(`r(att)'/`r(seatt)'))
matrix B = ( `r(att)' \ `r(seatt)' \ `pval' ) /*guardar en una matriz el estimador de PSM, su desviación estandar y su p-value */
mat list B

mat C = [A, B] /*hacer una matriz con los estimadores de PSM con las dos especificaciones */
mat list C
