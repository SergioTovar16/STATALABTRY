
********************************************************
************ Primer ejemplo de código ******************
********************************************************

global folder="D:\Dropbox\Eco\Microeconometría\1. Introducción y repaso de conceptos\1b" 

cd "$folder"

use nsw_dw_new2.dta, clear

* generar las 100 variables a partir de age2000

forvalues i=1/9 { /*con este loop generamos las variables age2001 a age2009 */
	gen age200`i'=age2000+`i' 
}

forvalues i=10/99 { /*con este loop generamos las variables age2001 a age2009 */
	gen age20`i'=age2000+`i' 
}

gen age2100=age2000+100 /* finalmente, aquí generamos la variable age2100 */


* generar las 100 variables a partir de re2000

forvalues i=1/9 { /*con este loop generamos las variables re2001 a re2009 */
	gen re200`i'=re2000+`i' if treat==1
	replace re200`i'=re2000-`i' if treat==0
}

forvalues i=10/99 { /*con este loop generamos las variables re2010 a re2099 */
	gen re20`i'=re2000+`i' if treat==1
	replace re20`i'=re2000-`i' if treat==0
}

gen re2100=re2000+100 if treat==1 /* finalmente, aquí generamos la variable re2100 */
replace re2100=re2000-100 if treat==0

* hacer las regresiones

reg re2000 treat /* separamos la primera regresión del loop para generar el archivo que contiene la tabla con outreg */
outreg2 using regresiones_loop, excel replace ctitle(re2000) stats (coef se) dec(0) nor2 nodepvar /* cada que necesiten rehacer el archivo desde cero, corren este código */

forvalues i=2001/2100 { /* hacemos el resto de las regresiones con un loop sobre y exportamos los resultados con el archivo generado anteriormente */
	reg re`i' treat
	outreg2 using regresiones_loop, excel append ctitle(re`i') stats (coef se) dec(0) nor2 nodepvar
}



******************************************************************************************
*************** o alternativamente, pueden usar este código más corto: *******************
******************************************************************************************

global folder="PONER DIRECTORIO DONDE GUARDARON SU BASE DE DATOS" 

cd "$folder"

use nsw_dw_new2.dta, clear

reg re2000 treat
outreg2 using tablas2, excel replace ctitle(Modelo 2000) stats (coef se) dec(0) nor2 nodepvar

forvalues i=2001/2100 {
	gen age`i'=age2000+`i'-2000
	gen re`i'=re2000+`i'-2000 if treat==1
	replace re`i'=re2000-`i'+2000 if treat==0
	reg re`i' treat
	outreg2 using tablas2, excel append ctitle(Modelo `i') stats (coef se) dec(0) nor2 nodepvar
}


