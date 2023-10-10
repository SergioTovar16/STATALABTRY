global folder="PONER AQUÍ EL DIRECTORIO DE LA CARPETA DONDE GUARDARON LA BASE DE DATOS" 

cd "$folder" /* Indicamos que lo que se use y se guarde se va a ubicar en esta carpeta */

use restaurant_inspections2.dta, clear

by business_name, sort: gen  NumberofLocations = _N /*Crear una variable que contenga el número de sucursales por cada cadena de restaurantes */

regress inspection_score NumberofLocations /*regresion de la calificacion con el número de sucursales */
estimates store m1 /* guardamos los resultados de la regresión en el local m1 */

regress inspection_score NumberofLocations year /*añadimos la variable de control "año" a la regresión" */
estimates store m2 /* guardamos los resultados de la regresión en el local m2 */

reg inspection_score c.NumberofLocations##c.NumberofLocations /* incluimos un polinomio de segundo orden c. indica que la variable "número de sucursales" es continua*/
estimates store m3 /* guardamos los resultados de la regresión en el local m3 */

reg inspection_score c.NumberofLocations##i.weekend /* incluimos la interacción del numero de restaurantes con "fin de semana" i. indica que la variable "fin de semana" es binaria*/
estimates store m4 /* guardamos los resultados de la regresión en el local m4 */

esttab m1 m2 m3 m4 using regression_table.csv, se replace /*creamos una tabla con las cuatro regresiones guardadas, la opción se da la indicación de guardar los errores estándar de estimador */
