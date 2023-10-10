
global folder="PONER AQUÍ DIRECTORIO DONDE GUARDASTE LA BASE DE DATOS"

cd "$folder" /* Indicamos que lo que se use y se guarde se va a ubicar en esta carpeta */

use health.dta, clear

summarize totexp, d
local per5 `r(p5)' /*guardamos en locals los varoles de la variable totexp en cada para los percentiles requeridos */
local med `r(p50)'
local per95 `r(p95)'
local per99 `r(p99)'
qplot totexp, recast(line) xlab(0(0.1)1) yline(`per5') yline(`med') yline(`per95') yline(`per99') /*graficamos la dist. acumulada de la var. totexp con los respectivos valores de los percentiles requeridos  */
graph export dist_gastos.png, replace

eststo clear
eststo, ti("OLS"): reg totexp suppins totchr age female white, robust /*hacemos la regresión por MCO y guardamos los estimadores respectivos */

foreach q in 0.10 0.25 0.50 0.75 0.90 { /*hacemos las regresiones por cuantiles y guardamos estimadores respectivos */
	eststo, ti("Q(`q')"): qreg totexp suppins totchr age female white, q(`q') nolog
}

esttab using resultados.csv, replace se nonum nodep mti drop(_cons) ti("Models of log total medical expenditure via OLS and QR") /*creamos la tabla con los estimadores por MCO y reg. cuantil  */

qreg totexp suppins totchr age female white, nolog
grqreg, ci ols olsci reps(40) /*hacemos la gráfica de estimadores MCO y por cuantil para cada variable */
graph export MCO_cuantil.png, replace