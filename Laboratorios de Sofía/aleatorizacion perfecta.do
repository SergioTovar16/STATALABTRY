***************************************************************************************
*************************** 26 de septiembre de 2023 **********************************
************* EFECTOS DE TRATAMIENTO CON ALEATORIZACION PERFECTA **********************
***************************************************************************************

clear all
set more off

/*
I. GENERAR LAS VARIABLES
*/

* Simulando la poblacion
set obs 30000
gen id=_n

* Generando tres regiones diferentes
generate auxiliar = 3*runiform()
sum auxiliar

gen region = .
replace region = 1 if (auxiliar < 1)
replace region = 2 if (1 < auxiliar & auxiliar < 2)
replace region = 3 if (2 < auxiliar & auxiliar < 3)
drop auxiliar

* Generando la variable dependiente 
* (contrafactual si es que las cosas no cambian antes y despues del tratamiento)
gen salud_0 = rnormal(10,1)
sum salud_0

replace salud_0 = salud_0 + 1 if region==1
replace salud_0 = salud_0 + 2 if region==2
replace salud_0 = salud_0 + 5 if region==3

* La distribucion de salud antes del tratamiento
kdensity salud_0 if region==1, lcolor(green) lpattern(dash) plot(kdensity salud_0 ///
if region==2, lcolor(navy)) addplot(kdensity salud_0 if region==3, lcolor(red) ///
lpattern(dash_dot)) legend(label(1 "Region 1") label(2 "Region 2") label(3 "Region 3") ///
region(lcolor(white))) title("Efecto del tratamiento", color(black) size(5)) ///
graphregion(fcolor(white)) xtitle("Salud") 

/*
II. TRATAMIENTO ALEATORIZADO PERFECTAMENTE
*/

* Asignando el tratamiento
generate auxiliar = runiform()
gen asign1 = round(auxiliar)
drop auxiliar

* Cumplimiento perfecto
gen tratado1 = asign1

* No hay diferencias ex ante entre los grupos
reg tratado1 i.region

bysort tratado1: summ salud_0

kdensity salud_0 if tratado1==0, lcolor(green) lpattern(dash) plot(kdensity salud_0 ///
if tratado1==1, lcolor(navy)) legend(label(1 "No tratados") label(2 "Tratados") ///
region(lcolor(white))) title("Efecto del tratamiento", color(black) size(5)) ///
graphregion(fcolor(white)) xtitle("Salud") 

* Genera la variable dependiente despues del tratamiento
gen salud_1 = salud_0 + 2*tratado1

* La distribucion de ambos grupos despues del tratamiento
kdensity salud_1 if tratado1==0, lcolor(green) lpattern(dash) plot(kdensity salud_1 ///
if tratado1==1, lcolor(navy)) legend(label(1 "No tratados") label(2 "Tratados") ///
region(lcolor(white))) title("Efecto del tratamiento", color(black) size(5)) ///
graphregion(fcolor(white)) xtitle("Salud") 

* Calcular el efecto del tratamiento
summ salud_1 if tratado1 == 1
	scalar salud_1_T = r(mean)
summ salud_1 if tratado1 == 0
	scalar salud_1_C = r(mean)
scalar ate_1 = `=scalar(salud_1_T)' - `=scalar(salud_1_C)'

**********************************************************************
di in red "El ATE estimado es de `=scalar(ate_1)'"
**********************************************************************
	
* Calcular el efecto con una regresion *
reg salud_1 tratado1

/*
III. TRATAMIENTO ALEATORIZADO IMPERFECTAMENTE
*/

* Asignando el tratamiento
generate auxiliar = runiform()
gen asign2 = 0
replace asign2 = 1 if (region == 3 & auxiliar < 0.25 )
replace asign2 = 1 if (region == 2 & auxiliar < 0.5 )
replace asign2 = 1 if (region == 1 & auxiliar < 1 )
drop auxiliar

* Cumplimiento perfecto
gen tratado2 = asign2

* Hay diferencias ex ante entre los grupos
reg tratado2 i.region

bysort tratado2: summ salud_0

kdensity salud_0 if tratado2==0, lcolor(green) lpattern(dash) plot(kdensity salud_0 ///
if tratado2==1, lcolor(navy)) legend(label(1 "No tratados") label(2 "Tratados") ///
region(lcolor(white))) title("Efecto del tratamiento", color(black) size(5)) ///
graphregion(fcolor(white)) xtitle("Salud") 

* Genera la variable dependiente despues del tratamiento
gen salud_2 = salud_0 + 2*tratado2

* La distribucion de ambos grupos despues del tratamiento
kdensity salud_2 if tratado2==0, lcolor(green) lpattern(dash) plot(kdensity salud_2 ///
if tratado2==1, lcolor(navy)) legend(label(1 "No tratados") label(2 "Tratados") ///
region(lcolor(white))) title("Efecto del tratamiento", color(black) size(5)) ///
graphregion(fcolor(white)) xtitle("Salud") 

* Calcular el efecto del tratamiento (sesgado)
summ salud_2 if tratado2 == 1
	scalar salud_2_T = r(mean)
summ salud_2 if tratado2 == 0
	scalar salud_2_C = r(mean)
scalar ate_2 = `=scalar(salud_2_T)' - `=scalar(salud_2_C)'

**********************************************************************
di in red "El ATE (sesgado) estimado es de `=scalar(ate_2)'"
**********************************************************************
	
* Calcular el efecto (sesgado) con una regresion *
reg salud_2 tratado2

* Controlar por el efecto de la region en una regresion *
reg salud_2 tratado2 i.region
