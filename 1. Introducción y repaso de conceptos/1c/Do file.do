
global folder="D:\Dropbox\Eco\Microeconometría\1. Introducción y repaso de conceptos\1c"

cd "$folder"

use NatNeighCrimeStudy2.dta, clear


foreach var of varlist T_* { /* generar las variables en tasa por cada 1000 hab. */
	gen R`var'=`var'/POPULATION
}

global crimes RT_MURDER RT_RAPE RT_ROBB RT_ASSLT RT_BURG RT_LARC RT_MVTHFT /* hacer un global que enlista a las vars. de interés */


* se hacen locales para darle etiquetas a cada una de las variables de interés
local t_RT_MURDER "Tasa de homicidio por cada 1000 habitantes"
local t_RT_RAPE "Tasa de violaciones por cada 1000 habitantes"
local t_RT_ROBB "Tasa de robos con violencia por cada 1000 habitantes"
local t_RT_ASSLT "Tasa de agresiones físicas por cada 1000 habitantes"
local t_RT_BURG "Tasa de robo a propiedad por cada 1000 habitantes"
local t_RT_LARC "Tasa de hurtos por cada 1000 habitantes"
local t_RT_MVTHFT "Tasa de robo de vehiculos por cada 1000 habitantes"


foreach var in $crimes { /*este loop hace los histogramas */
hist `var', percent ytitle("Porcentaje de observaciones") xtitle("`t_`var''")
graph export hist_`var'.png, replace
}


global crimes2 RT_RAPE RT_ROBB RT_ASSLT RT_BURG RT_LARC RT_MVTHFT /* hacer un global que enlista a las vars. de interés */

foreach var in $crimes2 { /*este loop hace los scatters */
twoway (scatter RT_MURDER `var') (lfit RT_MURDER `var'), by(REGION) ytitle("Tasa de homicidio por cada 1000 habitantes") xtitle("`t_`var''") legend(label(1 "Observación real") label(2 "Regresión de MCO")) 
graph export scatter_`var'.png, replace
}


