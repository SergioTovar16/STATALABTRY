global folder= "PONER AQUI EL DIRECTORIO DE LA CARPETA DONDE GUARDARON SU BASE DE DATOS"

cd "$folder" /* Indicamos que lo que se haga se use y se guarde se va a ubicar en esta carpeta */

use MalariaData_reduced.dta, clear

************************************************************
***** Para obtener las medias se proponen dos formas *******
************************************************************

********** 1. Guardar las medias en una matriz *************

* Ejemplo de obtener la media para una variable y un grupo 

summarize B_head_edu if control==1
scalar prom_edad_control=`r(mean)'
display prom_edad_control


* Loop para obtener las medias de más de una variable a través de todos los grupos 

foreach var in B_knowledge_correct B_head_edu B_head_age_imputed B_dist_km  { /* primer loop: variables */

if ("`var'"=="B_knowledge_correct") local vars `"1"' /* crear un local numerico para los textos en el loop */
if ("`var'"=="B_head_edu") local vars `"2"' 
if ("`var'"=="B_head_age_imputed") local vars `"3"' 
if ("`var'"=="B_dist_km") local vars `"4"' 

foreach group in control act40 act60  act100 { /* segundo loop: grupos */

if ("`group'"=="control") local groups `"1"' /* crear un local numerico para los textos en el loop */
if ("`group'"=="act40") local groups `"2"' 
if ("`group'"=="act60") local groups `"3"' 
if ("`group'"=="act100") local groups `"4"' 

summarize `var' if `group'==1 /* obtener la media */
local mean=`r(mean)' /* guardarla como un local */

matrix C= nullmat(C) \ (`vars', `groups', `mean') /* en esta matriz se guardan todas las medias */

}
}

mat list C /*Mostrar los valores de la matriz */

/*Alternativamente, podemos guardar la matriz como una archivo .dta */

preserve /* Este comando deja la base en pausa, para que cuando se restaure no se pierda la informacion*/
matrix colnames C = variable group mean /* crear los nombres de las columnas */
drop _all /* quitar toda la informacion en la base de datos */
svmat double C, n(col)	/* la matriz C se convierte a una base de datos */
tostring variable group, replace
replace variable="conocimiento" if variable=="1"
replace variable="educacion" if variable=="2"
replace variable="edad" if variable=="3"
replace variable="distancia" if variable=="4"
replace group="control" if group=="1"
replace group="tratamiento40" if group=="2"
replace group="tratamiento60" if group=="3"
replace group="tratamiento100" if group=="4"
export delimited means_matriz.csv, replace
restore /*restaurar la base datos que se habia creado */

mat drop C /* eliminar la matriz que tenia las medias */ 


********** 2. Utilizar el comando estimates store *************

eststo clear
foreach group in control act40 act60 act100 { 

mean B_knowledge_correct B_head_edu B_head_age_imputed B_dist_km if `group' == 1
estimates store mean_`group'
}

esttab mean_control mean_act40 mean_act60 mean_act100 using means_estto.csv, replace not nostar noobs mtitles label



******************************************************************
* Para saber si las medias son diferentes se proponen dos formas *
******************************************************************

****************** 1. Usar el comando ttest **********************

foreach var in B_knowledge_correct B_head_edu B_head_age_imputed B_dist_km  { /* primer loop: variables */
foreach group in control act40 act60  act100 { /* segundo loop: grupos */
gen `var'_`group'= `var' if `group'==1 /* generamos variables por cada uno de los grupos, solo con la información de ese grupo */
}
}

foreach var in B_knowledge_correct B_head_edu B_head_age_imputed B_dist_km  { /* primer loop: variables */
foreach group in act40 act60  act100 { /* segundo loop: grupos */
ttest `var'_`group'= `var'_control, unpaired  /* hacemos un test que tiene como hip. nula que la media de cada una de las variables por grupo de tratamiento es igual a la media de cada una de las variables en el grupo de control, si obtenemos Pr(|T| > |t|) con valores altos (mayores a 0.1), aceptamos la hipotesis nula */
}
}

****************** 1. Hacer regresiones **************************


gen groups=. /* creamos una variable que va a categorizar a todas las observaciones por su grupo en el experimento aleatorio */
replace groups=0 if control==1
replace groups=1 if act40==1 
replace groups=2 if act60==1 
replace groups=3 if act100==1


reg B_knowledge_correct i.groups /* Var dep: variable para la cual comparamos las medias. */ 
outreg2 using regs_testmedias, excel replace ctitle(conocimiento) stats (coef se) dec(3) nor2 nodepvar nocons noobs

foreach var in B_head_edu B_head_age_imputed B_dist_km {

if ("`var'"=="B_head_edu") local vars `"educacion"' 	
if ("`var'"=="B_head_age_imputed") local vars `"edad"' 
if ("`var'"=="B_dist_km") local vars `"distancia"' 

reg `var' i.groups /* Var dep: variable para la cual comparamos las medias. */ 
outreg2 using regs_testmedias, excel append ctitle(`vars') stats (coef se) dec(3) nor2 nodepvar nocons noobs
}

* Si el coeficiente asociado a X grupo de tratamiento no es estadísticamente diferente de cero, la esperanza condicional de ese gpo. de trat. X no es diferente a la esp. condicional del grupo de control (el grupo de referencia en las regresiones para variable groups es el grupo control).


******************************************************
****** regresiones sobre las vars. de interés ********
******************************************************

reg m_took_act i.groups
outreg2 using regs_causal, excel replace ctitle(tomarmedicina) stats (coef se ci) dec(3) nocons nodepvar
reg m_care_nothing i.groups
outreg2 using regs_causal, excel append ctitle(hacernada) stats (coef se ci) dec(3) nocons nodepvar
reg m_took_maltest i.groups
outreg2 using regs_causal, excel append ctitle(tomartest) stats (coef se ci) dec(3) nocons nodepvar

* Si el coeficiente asociado a X grupo de tratamiento es estadísticamente diferente diferente de cero, la esperanza condicional de ese gpo. de trat. X es diferente a la esp. condicional del grupo de control (el grupo de referencia en las regresiones para variable groups es el grupo control).




