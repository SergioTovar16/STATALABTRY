clear

use "C:\Users\salon\Downloads\restaurant_inspections2.dta"

sort business_name

egen holder = group(business_name)

gen hold_2 = holder^2

gen inter = holder * weekend

regress inspection_score holder
estimates

regress inspection_score holder year
estimates

regress inspection_score hold_2
estimates

regress inspection_score inter
estimates

estimates table

//Interpretación:
// La calidad del negocio no está relacionada con la cantidad de sucursales, podría deberse a la falta de controles. Lo mismo para la segunda regresión, el año no cambia la estimación en control. El modelo no lineal no es mejor para explicar la calidad del negocio. La interacción tampoco.
