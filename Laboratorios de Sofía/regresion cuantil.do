 *******************************************************************************
****************** LABORATORIO 2 DE MICROECONOMETRIA ***************************
********************** 12 DE SEPTIEMBRE DEL 2023 *******************************
************************** REGRESIÓN CUANTIL ***********************************
********************************************************************************

clear all

********* SETUP **********

cd "D:\ID005170\OneDrive - CIDE\CIDE\Lab microeconometría 2023\Lab 2 - 12 de septiembre"

use "salarios_mlb.dta", clear

global X atbat hits hmrun walks years putouts

gen lsalary=log(salary)

set seed 1119

/*
Inspección gráfica

Instalar:

qplot (nombre gr42_8.pkg en Stata)

grqreg
*/

**CDF del salario
sum lsalary, d

qplot lsalary, recast(line) ylab(,angle(0)) ///
 xlab(0(0.1)1) xline(0.5) xline(0.1) xline(0.9)
 
**MCO:
reg lsalary $X
 
**Regresión en la mediana, errores iid

qreg lsalary $X

**Con errores robustos

qreg lsalary $X, vce(robust)

**Bootstrap
bsqreg lsalary $X, reps(100)

**Calculamos la regresión cuantil en los cuantiles 0.10, 0.25, 0.50, 0.75 y 0.90
reg lsalary $X
estimates store MCO

foreach q in 10 25 50 75 90 {
qui bsqreg lsalary $X, quantile(`q') nodots reps(100)
estimates store Q`q'
}

estimates table MCO  Q10 Q25 Q50 Q75 Q90, b(%8.4f) se(%8.4f)

**Una gráfica muy útil compara los efectos en cada cuantil con el de MCO
**Se debe ejectur después de qreg
*ssc install grqreg 
grqreg, cons ci ols olsci reps(100)
 
 
**Finalmente, podría ser de interés comparar el coeficiente estimado
**en dos distintos cuantiles:

sqreg lsalary $X, nolog q(0.1 0.25 0.5 0.75 0.9)

test [q25=q50=q75]: hmrun



********* Ejemplo de Simulación ********** 

**Generamos datos con heterocedasticidad
clear all
set more off
set obs 100
set seed 1119

egen x=seq()
gen sigma=0.1+(0.05*x)
gen b0=6
gen b1=0.1
gen e=rnormal(0,sigma)
gen y=b0+(b1*x)+e

**Vemos cómo lucen los datos
twoway (lfitci y x) (scatter y x) 

**Ajustemos regresión cuantil para el cuantil 0.9
qreg y x, quantile(90)
predict yhat_q90

twoway (lfitci y x) (scatter y x)  (line yhat_q90 x)

**Estimamos la relación para varios cuantiles
foreach q in 10 20 30 40 50 60 70 80 {
cap noi qui qreg y x, quantile(`q') nolog
predict yhat_q`q'
}

twoway (lfitci y x, lpattern(dash)) (scatter y x) ///
 (line yhat_q20 x, lcolor(balck)) ///
 (line yhat_q30 x, lcolor(balck)) ///
 (line yhat_q40 x, lcolor(balck)) ///
 (line yhat_q50 x, lcolor(balck)) ///
 (line yhat_q60 x, lcolor(balck)) ///
 (line yhat_q70 x, lcolor(balck)) ///
 (line yhat_q80 x, lcolor(balck)) ///
 (line yhat_q90 x, lcolor(balck)), legend(order(1 "CI" 2 "MCO"))


grqreg, ci ols olsci quantile(10 20 30 40 50 60 70 80 90)