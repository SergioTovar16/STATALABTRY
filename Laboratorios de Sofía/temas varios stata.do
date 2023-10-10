
capture log close

********** OVERVIEW  **********

* Este laboratorio está basado en:
* copyright C 2010 by A. Colin Cameron and Pravin K. Trivedi 
* used for "Microeconometrics Using Stata, Revised Edition" 
* by A. Colin Cameron and Pravin K. Trivedi (2010)
* Stata Press

* Chapter 1
*** 1.3 COMMAND SYNTAX AND OPERATORS
*** 1.4 DO-FILE AND LOG FILE
*** 1.5 SCALARS AND MATRICES
*** 1.6 USING RESULTS
*** 1.7 MACROS: GLOBAL AND LOCAL
*** 1.8 LOOPS
*** 1.10 TEMPLATE DO-FILE
*** 1.11 USER-WRITTEN COMMANDS


* To run you need file access to file auto.dta 
* which is installed with Stata


* No Stata user-written command is needed

********** SETUP **********

cd "D:\ID005170\OneDrive - CIDE\CIDE\Lab microeconometría 2023\Lab 1 - 29 de agosto"

set more off 
version 11
clear all
set linesize 82
set scheme s1mono  /* Graphics scheme */

*** 1.3 COMMAND SYNTAX AND OPERATORS

sysuse auto
summarize

summarize mpg price weight, separator(1)
summarize mpg price weight, detail

regress mpg price weight
regress mpg price weight, robust // esta opción de robust no es confiable

by foreign: regress mpg price weight if weight < 4000, vce(robust)
by foreign: regress mpg price weight, vce(robust)

regress mpg price weight if foreign==1 , vce(robust)
regress mpg price weight if foreign==0 , vce(robust)

quietly regress mpg price weight

* Factor variable for rep78 - base category is omitted
summarize i.rep78

* Factor variable for rep78 - no category is omitted
summarize ibn.rep78

* Factor variables for interaction between two categorical variables
summarize i.rep78#i.foreign, allbaselevels

* Factor variables for interaction between categorical and continuous variables
summarize i.rep78#c.weight

* Factor variables for interaction between two continuous variables
regress mpg price c.weight c.weight#c.weight, noheader

generate weight2 = weight*weight

regress mpg price c.weight c.weight2, noheader

summarize t*

display -2*(9/(8+2-7))^(-2)

display 2/0


*** 1.5 SCALARS AND MATRICES

* Scalars: Example
scalar a = 2*3
scalar b = "2 times 3 = "
display b a

* Matrix commands: Example
matrix define A = (1,2,3 \ 4,5,6)
matrix list A
scalar c = A[2,3]
display c

*** 1.6 USING RESULTS

* Illustrate use of return list for r-class command summarize
summarize mpg
return list

* Illustrate use of r()
quietly summarize mpg
scalar range = r(max) - r(min)
display "Sample range = " range

* Save a result in r() as a scalar 
scalar mpgmean = r(mean)

regress mpg price weight

* ereturn list after e-class command regress
ereturn list

* Use of e() where scalar
scalar r2 = e(mss)/(e(mss)+e(rss))
display "r-squared = " r2

* Use of e() where matrix
matrix best = e(b)
scalar bprice = best[1,1]
matrix Vest = e(V)
scalar Vprice = Vest[1,1]
scalar tprice = bprice/sqrt(Vprice)
display "t statistic for H0: b_price = 0 is " tprice 

*** 1.7 MACROS: GLOBAL AND LOCAL

* Global macro definition and use
global xlist price weight
regress mpg $xlist, noheader       // $ prefix is necessary

* Local macro definition and use
local xlist "price weight"
regress mpg `xlist', noheader     // single quotes are necessary

* Local macro definition without double quotes
local y mpg           
regress `y' `xlist', noheader

* Local macro definition through function evaluation
local z = 2+2
display `z'

* Scalars disappear after clear all but macro does not
global b 3
local c 4
scalar d = 5
clear
display $b _skip(3) `c'   // display macros
display d                 // display the scalar
clear all  
display $b _skip(3) `c'   // display macros
display d                 // display the scalar

*** 1.8 LOOPS

* Make artificial dataset of 100 observations on 4 uniform variables
clear
set obs 100
set seed 10101
generate x1var = runiform()
generate x2var = runiform()
generate x3var = runiform()
generate x4var = runiform()

* Manually obtain the sum of four variables
generate sum = x1var + x2var + x3var + x4var
summarize sum

* foreach loop with a variable list
quietly replace sum = 0
foreach var of varlist x1var x2var x3var x4var {
    quietly replace sum = sum + `var'
}
summarize sum

// Not included in book
* foreach loop with a number list
quietly replace sum = 0
foreach i of numlist 1 2 3 4 {
    quietly replace sum = sum + x`i'var
}
summarize sum

* forvalues loop to create a sum of variables
quietly replace sum = 0
forvalues i = 1/4 {
    quietly replace sum = sum + x`i'var
}
summarize sum

* While loop and local macros to create a sum of variables
quietly replace sum = 0
local i 1
while `i' <= 4 {
    quietly replace sum = sum + x`i'var
    local i = `i' + 1
}
summarize sum


* Chapter 2
* 2.6: GRAPHICAL DISPLAY OF DATA

* To run you need files
*   mus02psid92m.dta
* in your directory

* No Stata user-written commands are used

************* 2.6: GRAPHICAL DISPLAY OF DATA

use mus02psid92m.dta, clear
twoway scatter lnearns hours
graph export mus02two1.eps, replace

* More advanced graphics command with two plots and with several options
graph twoway (scatter lnearns hours, msize(small))     ///
   (lfit lnearns hours, lwidth(medthick)),             ///
   title("Scatterplot and OLS fitted line")       
graph export mus02two2.eps, replace

use mus02psid92m.dta, clear
label define edtype 1 "< High School" 2 "High School" 3 "Some College" 4 "College Degree"
label values edcat edtype

* Box and whisker plot of single variable over several categories
graph box hours, over(edcat) scale(1.2) marker(1,msize(vsmall))   ///
  ytitle("Annual hours worked by education") yscale(titlegap(*5)) 
quietly graph export mus02boxfig.eps, replace

histogram lnearns

* Histogram with bin width and start value set
histogram lnearns, width(0.25) start(4.0)
graph export mus02hist.eps, replace

kdensity lnearns
* Kernel density plot with bandwidth set and fitted normal density overlaid
kdensity lnearns, bwidth(0.20) normal n(4000)
graph export mus02kd1.eps, replace

* Histogram and nonparametric kernel density estimate 
histogram lnearns if lnearns > 0, width(0.25) kdensity             ///
  kdenopts(bwidth(0.2) lwidth(medthick))                               ///
  plotregion(style(none)) scale(1.2)                                   ///
  title("Histogram and density for log earnings")                      ///
  xtitle("Log annual earnings", size(medlarge)) xscale(titlegap(*5))   ///
  ytitle("Histogram and density", size(medlarge)) yscale(titlegap(*5)) 
graph export mus02histdens.eps, replace

* Simple two-way scatterplot
scatter lnearns hours

* Two-way scatterplot and quadratic regression curve with 95% ci for y|x  
twoway (qfitci lnearns hours, stdf)  (scatter lnearns hours, msize(small))
graph export mus02scatter2.eps, replace


* Multiple scatterplots
label variable age "Age"
label variable lnearns "Log earnings"
label variable hours "Annual hours"
graph matrix lnearns hours age, by(edcat) msize(small) 


* Chapter 3
* 3.2: DATA: SUMMARY STATISTICS
* 3.4: BASIC REGRESSION ANALYSIS
* 3.5: SPECIFICATION ANALYSIS
* 3.6: PREDICTION
* 3.7: SAMPLING WEIGHTS


* To run you need files
*   mus03data.dta 
* in your directory
* Stata user-written commands esttab and estadd are used

********** SETUP **********

set more off
version 11
clear all
set linesize 82
set scheme s1mono  /* Graphics scheme */


************ 3.2: DATA SUMMARY STATISTICS

* Variable description for medical expenditure dataset
use mus03data.dta
describe totexp ltotexp posexp suppins phylim actlim totchr age female income

* Summary statistics for medical expenditure dataset
summarize totexp ltotexp posexp suppins phylim actlim totchr age female income

* Tabulate variable
tabulate income if income <= 0

* Detailed summary statistics of a single variable
summarize totexp, detail

* Two-way table of frequencies
table female totchr

* Two-way table with row and column percentages and Pearson chi-squared
tabulate female suppins, row col chi2

* Three-way table of frequencies
table female totchr suppins

* One-way table of summary statistics
table female, contents(N totchr mean totchr sd totchr p50 totchr)

* Two-way table of summary statistics
table female suppins, contents(N totchr mean totchr)

* Summary statistics obtained using command tabstat
tabstat totexp ltotexp, stat (count mean p50 sd skew kurt) col(stat)

* Kernel density plots with adjustment for highly skewed data
kdensity totexp if posexp==1, generate (kx1 kd1) n(500) 
graph twoway (line kd1 kx1) if kx1 < 40000, name(levels)
kdensity ltotexp if posexp==1, generate (kx2 kd2) n(500) 
graph twoway (line kd2 kx2) if kx2 < ln(40000), name(logs)
graph combine levels logs, iscale(1.0)
graph export mus03fig1.eps, replace

// NOT IN BOOK
/* El comando de asdoc nos permite extraer estadística descriptiva en formato 
tipo "paper" en word de manera muy sencilla */

asdoc sum totexp // exporta el summary de estadisticas descriptivas
asdoc tab female totchr // exporta la tabla entre x_1 y x_2
asdoc tab1 female suppins totchr // exporta tablas que tabulen cada una de las vars
asdoc corr totexp ltotexp // exporta tablas de correlacion

*********** 3.4: BASIC REGRESSION ANALYSIS

* Pairwise correlations for dependent variable and regressor variables
correlate ltotexp suppins phylim actlim totchr age female income

* OLS regression with heteroskedasticity-robust standard errors
regress ltotexp suppins phylim actlim totchr age female income, vce(robust)

* Display stored results and list available postestimation commands
ereturn list
help regress postestimation

* Wald test of equality of coefficients
quietly regress ltotexp suppins phylim actlim totchr age female ///
  income, vce(robust)
test phylim = actlim

*  Joint test of statistical significance of several variables
test phylim actlim totchr

* Store and then tabulate results from multiple regressions
quietly regress ltotexp suppins phylim actlim totchr age female income, vce(robust)
estimates store REG1
quietly regress ltotexp suppins phylim actlim totchr age female educyr, vce(robust)
estimates store REG2
estimates table REG1 REG2, b(%9.4f) se stats(N r2 F ll) keep(suppins income educyr)

* Tabulate results using user-written command esttab to produce cleaner output
esttab REG1 REG2, b(%10.4f) se scalars(N r2 F ll) mtitles ///
  keep(suppins income educyr) title("Model comparison of REG1-REG2")

* Write tabulated results to a file in latex table format
quietly esttab REG1 REG2 using mus03table.tex, replace b(%10.4f) se scalars(N r2 F ll) ///
   mtitles keep(suppins age income educyr _cons) title("Model comparison of REG1-REG2")

// NOT IN BOOK
*ssc install outreg2
quietly regress ltotexp suppins phylim actlim totchr
outreg2 using "reg1.doc", cttop(OLS) excel replace

quietly regress ltotexp suppins phylim actlim totchr age female income
outreg2 using "reg1.doc", cttop(OLS + controls) excel append

quietly regress ltotexp suppins phylim actlim totchr age female income, vce(robust)
outreg2 using "reg1.doc", cttop(OLS + controls + robust s.e.) excel append


********** 3.5: SPECIFICATION ANALYSIS

* Plot of residuals against fitted values
quietly regress ltotexp suppins phylim actlim totchr age female income, ///
  vce(robust)
rvfplot
graph export mus03fig2.eps, replace

* Details on the outlier residuals
predict uhat, residual
predict yhat, xb
list totexp ltotexp yhat uhat if uhat < -5, clean

******* 3.6 PREDICTION

* Change dependent variable to level of positive medical expenditures
use mus03data.dta, clear
keep if totexp > 0   
regress totexp suppins phylim actlim totchr age female income, vce(robust)

* Prediction in model linear in levels
predict yhatlevels
summarize totexp yhatlevels

* Compare median prediction and median actual value
tabstat totexp yhatlevels, stat (count p50) col(stat)

* Compute standard errors of prediction and forecast with default VCE
quietly regress totexp suppins phylim actlim totchr age female income
predict yhatstdp, stdp // standard error of the prediction
predict yhatstdf, stdf //standard error of the forecast
summarize yhatstdp yhatstdf

******* 3.7 SAMPLING WEIGHTS

* Create artificial sampling weights
use mus03data.dta, clear
generate swght = totchr^2 + 0.5
summarize swght

* Calculate the weighted mean
mean totexp [pweight=swght]

* Perform weighted regression 
regress totexp suppins phylim actlim totchr age female income [pweight=swght]

* Weighted prediction
quietly predict yhatwols
mean yhatwols [pweight=swght], noheader  
mean yhatwols, noheader      // unweighted prediction


* Chapter 5
* 5.3 MODELING HETEROSKEDASTIC DATA
* 5.5 SURVEY DATA: WEIGHTING, CLUSTERING, AND STRATIFICATION

* To run you need files
*   mus05surdata.dta
*   mus05nhanes2.dta  (same as http://www.stata-press.com/data/r10/nhanes2.dta)
* in your directory
* No Stata user-written commands are used

********** SETUP **********

version 11
clear all
set memory 10m
set more off
set scheme s1mono   /* Used for graphs */
  
********** 5.3 MODELING HETEROSKEDASTIC DATA

* This uses generated data
* Model is  y = 1 + 1*x2 + 1*x3 + u
* where     u = sqrt(exp(-1+0.2*x2))*e
*           x1 ~ N(0, 5^2)
*           x2 ~ N(0, 5^2)
*           e ~ N(0, 5^2)
* Errors are conditionally heteroskedastic with V[u|x]=exp(-1+1*x2)

* Generated data for heteroskedasticity example
set seed 10101
quietly set obs 500
generate double x2 = 5*rnormal(0)
generate double x3 = 5*rnormal(0)
generate double e  = 5*rnormal(0)
generate double u  = sqrt(exp(-1+0.2*x2))*e
generate double y  = 1 + 1*x2 + 1*x3 + u
summarize

* OLS regression with default standard errors
regress y x2 x3

* OLS regression with heteroskedasticity-robust standard errors
regress y x2 x3, vce(robust) 

* Heteroskedasticity diagnostic scatterplot
quietly regress y x2 x3
predict double uhat, resid
generate double absu = abs(uhat)
quietly twoway (scatter absu x2) (lowess absu x2, bw(0.4) lw(thick)), ///
  scale(1.2) xscale(titleg(*5)) yscale(titleg(*5))                    ///
  plotr(style(none)) name(gls1)
quietly twoway (scatter absu x3) (lowess absu x3, bw(0.4) lw(thick)), ///
  scale(1.2) xscale(titleg(*5)) yscale(titleg(*5))                    ///
  plotr(style(none)) name(gls2)
graph combine gls1 gls2
graph export mus05gls_fig1.eps, replace
drop uhat

* Test heteroskedasticity depending on x2, x3, and x2 and x3
estat hettest x2 x3, mtest

// Not included in book
* Separate tests of heteroskedasticity using iid version of hettest
estat hettest x2, iid
estat hettest x3, iid
estat hettest x2 x3, iid

******** 5.5 SURVEY DATA: WEIGHTING, CLUSTERING, AND STRATIFICATION

* Data from http://www.stata-press.com/data/r10/nhanes2.dta

* Survey data example: NHANES II data
clear all
use mus05nhanes2.dta
quietly keep if age >= 21 & age <= 65
describe sampl finalwgt strata psu
summarize sampl finalwgt strata psu

* Declare survey design
svyset psu [pweight=finalwgt], strata(strata)

* Describe the survey design
svydescribe

* Estimate the population mean using svy:
svy: mean hgb

* Estimate the population mean using no weights and no cluster
mean hgb

* Regression using svy:
svy: regress hgb age female

* Regression using weights and cluster on PSU
generate uniqpsu = 2*strata + psu  // make unique identifier for each psu
regress hgb age female [pweight=finalwgt], vce(cluster uniqpsu)

* Regression using no weights and no cluster
regress hgb age female
