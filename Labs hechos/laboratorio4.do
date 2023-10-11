use "C:\Users\salon\Documents\Stata\lab4\nsw_dw_new.dta", clear


**# Bookmark #1
regress re78  treat
outreg2 using "tabla1.xls", replace stat(coef ci, se)  level (95) keep(treat)

global control1 age education married

regress re78 treat $control1
outreg2 using "tabla1.xls", append stat(coef ci, se) level (95)  keep(treat)

global control2 $control1 black hispanic nodegree re74 re75  

regress re78 treat $control2
outreg2 using "tabla1.xls", append stat(coef ci, se) level (95)  keep(treat)


**# BOOKMARK 2
use "C:\Users\salon\Documents\Stata\lab4\psid_controls_new.dta", clear

ttest re78, by(treat)
scalar pvalue=r(p)

psmatch2 treat age education married, outcome(re78) ate

psmatch2 treat age education married black hispanic nodegree re74 re75, outcome(re78)
pstest