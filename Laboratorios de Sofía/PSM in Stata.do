* Propensity Score Matching in Stata


/*
Este laboratorio está basado en el ejemplo encontrado en 
https://sites.google.com/site/econometricsacademy/econometrics-models/propensity-score-matching
*/

clear all
set more off

use "D:\ID005170\OneDrive - CIDE\CIDE\Lab microeconometría 2022\PSM\matching_earnings.dta" 

/*
-We want to study the effect of a training program on individuals' earnings.
-Data are from the National Supported Work project and Dehejia and Wahba (1999)
-Treatment is if a person received training (treatment)
-Independent variables are age, education, and married
*/

* Define treatment, outcome, and independent variables
global treatment TREAT
global ylist RE78
global xlist AGE EDUC MARR 

describe $treatment $ylist $xlist
summarize $treatment $ylist $xlist

bysort $treatment: summarize $ylist $xlist

* Regression with a dummy variable for treatment (t-test)
reg $ylist $treatment 

* Regression with a dummy variable for treatment controlling for x
reg $ylist $treatment $xlist

 /*
 -We need to find matches for the 185 treated observations and then compare outcomes
 -We could naively conclude that training programs are undesirable since they reduce the expected earnings
 */
 
* Propensity score matching using psmatch2 package

* Install psmatch2 package. Note that psmatch2 is being continuously improved and developed. Make sure to keep your version up-to-date as follows:
ssc install psmatch2, replace

* Propensity score matching
psmatch2 $treatment $xlist, outcome($ylist) ate 

/*
Interpretation: 
-Individuals who are older, more educated, or married are less likely to receive
training.
-We are saving the propensity scores (predicted probabilities) from the probit model and using
them to find matches for the treated observations.
-The balancing property (similar characteristics between treated and control observations) is
satisfied.
*/

* Propensity score matching with logit instead of probit model
psmatch2 $treatment $xlist, outcome($ylist) logit

* Propensity score matching with common support
psmatch2 $treatment $xlist, outcome($ylist) common

* Nearest neighbor matching - neighbor(number of neighbors)
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(1)

* Radius matching - caliper(distance)
psmatch2 $treatment $xlist, outcome($ylist) common radius caliper(0.1)

* Kernel matching
psmatch2 $treatment $xlist, outcome($ylist) common kernel


* Balancing - comparisons of treated and controls after matching
pstest

psgraph

