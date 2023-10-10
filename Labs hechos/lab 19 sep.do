use "C:\Users\salon\Downloads\health.dta"

sum totexp

qplot totexp, recast(line) ylab(,angle(0)) ///
 xlab(0(0.1)1) xline(0.5) xline(0.95) xline(0.05) xline(0.99)
 
 reg totexp suppins totchr age female white

 
 

estimates store MCO
 foreach q in 10 25 50 75 90 {
qui bsqreg totexp suppins totchr age female white, quantile(`q') nodots reps(2)
estimates store Q`q'
}

estimates table MCO  Q10 Q25 Q50 Q75 Q90, b(%8.4f) se(%8.4f)

qreg totexp suppins totchr age female white
grqreg, cons ci ols olsci reps(2)

help grqreg