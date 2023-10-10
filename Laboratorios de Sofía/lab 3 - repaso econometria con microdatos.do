************** Econometrics With Microdata*****************

/* 
This exercise uses dataset mus06data.dta

To download the data either run:

net from http://www.stata-press.com/data/musr
net install musr
net get musr

Or download the data from https://www.stata-press.com/data/mus.html

*/

********************************************************************************
clear
set more off, perm
********************************************************************************



********************************************************************************
* 						Question 1: Inspecting the Data
********************************************************************************

/* 
i. Use the summarize command to calculate:
	a. the average number of chronic conditions;
	b. average age;
	c. fraction of the sample that are female;
	d. fraction of the sample that are black or Hispanic;
	e. and the average income.
	
ii. Use the summarize, detail command to calculate:
	a. the mean and median medication expenditure;
	b. the highest and lowest medication expenditure.
	
iii. Repeat this for Income. How many individuals have zero income? How many have negative income?
*/

**Load Dataset
use "C:\Users\idex2559\OneDrive - CIDE\CIDE\Lab microeconometría 2022\Lab 3 - 7 de sept\mus06data.dta" , clear

**Sumarise Key Variables
sum totchr age female blhisp income
tab totchr

* Summarise Drug Expenditure and Income in Detail
sum drugexp income, de

* Individuals With Non Positive Income
count if income == 0

* Individuals With Negative Income
count if income < 0


********************************************************************************
* 					Question 2: Regressions
********************************************************************************
/*
i. Run a bivariate regression of ldrugexp on hi_empunion. What is the interpretation of the estimated coefficient? Is it what you expected?

ii. Further include totchr as a regressor. What is the interpretation of the coefficient? Is it statistically different from 0?

iii. Further include female, blhisp as regressors. What is the interpretation of both coefficients?

iv. Further include linc-the log of income-as a regressor. What is the interpretation of the estimated coefficient?

v. Further include age as a regressor. It the coefficient on age what you expected?

vi. Further include age2-age squared-as a regressor. Based on this regression, at what age is the impact of medical expenditure on age maximised?

vii. Rerun the last regression with heteroskedastic robust standard errors, using the vce(robust) option. Comment on any changes in the standard errors.
*/

***Regressions
eststo clear
* Reg 1: Univariate Regression
regress ldrugexp hi_empunion 
eststo Reg1

* Reg 2: Adding Chronic Conditions
regress ldrugexp hi_empunion totchr 
eststo Reg2  

* Reg 3: Adding Female and Black/Hispanic
regress ldrugexp hi_empunion totchr female blhisp
eststo Reg3  

* Reg 4: Adding Log Income
regress ldrugexp hi_empunion totchr female blhisp linc
eststo Reg4  

* Reg 5: Adding Age
regress ldrugexp hi_empunion totchr female blhisp linc age
eststo Reg5  

* Reg 6: Adding Age2
regress ldrugexp hi_empunion totchr female blhisp linc age age2
eststo Reg6  
* Reg 7: Heteroskedastic Robust Standard Errors
regress ldrugexp hi_empunion totchr female blhisp linc age age2, vce(robust)
eststo Reg7  

***Present Result in Table
esttab Reg1 Reg2 Reg3 Reg4 Reg5 Reg6 Reg7, se stats(N r2)


********************************************************************************
* 				Question 3: Testing Linear Restrictions
********************************************************************************

/*
This question tests a number of linear restrictions. We do this on the regression of Question 2 (vii).

i. Can you reject at the 5% level that the coefficient on totchr is 0.5? Do this using the test command. Looking at the regression output, what is the maximum coefficient for totchr that you can reject at the 5% level?

ii. Test the null hypothesis that the estimated coefficents on female and linc are both zero. You can do this with the testparm command.

iii. Test the null hypothesis that the estimated coefficient on female is 0.1 and the estimated coefficient on linc is 0.02. 

iv. Test the null hypothesis that the estimated coefficient on totchr is 10 times greater than that on female.
*/

***Regression
regress ldrugexp hi_empunion totchr female blhisp linc age age2, vce(robust)

* Test 1: Single Linear Restriction
test totchr = 0.5

* Test 2: Multiple Linear Restrictions
testparm female linc

* Test 3: Multiple Non-Zero Linear Restrictions
test (female = 0.1) (linc = 0.02) 

* Test 4: Linear Relationship Between Parameters
test totchr = 10*female


********************************************************************************
* 						Question 4: Interactions 
********************************************************************************

/*
This question involves running a number of regressions to explore how the number of chronic conditions affects drug expenditure for women. Generate a table to store the output, following the same method as Question 2.

i. Run a regression of ldrugexp on hi_empunion, totchr and female, using heteroskedastic robust standard errors.

ii. Rerun the regression for women only. How does the estimated coefficient on totchr change?

iii. Using the whole sample, formally test if the impact of totchr on ldrugexp is different for women by generating an interaction variable.

iv. Separately estimate the impact of totchr on ldrugexp for men and women in one regression. Do this using the categorical variable syntax. Compare the difference between the estimated coefficients for men and women to the results from iii. Is the difference statistically significant?

v. Is the estimated coefficient on totchr for women in iv the same as in the sample for women only from ii? If not, use the categorical variable syntax to run a regression on the full sample which has the same estimated totchr coefficient for women as the sample estimated on the sample of women only.
*/

***Regressions

* Reg 1: Baseline
eststo clear
regress ldrugexp hi_empunion totchr female, vce(robust) 
eststo Reg1

* Reg 2: Female Sample
regress ldrugexp hi_empunion totchr if female == 1, vce(robust)
eststo Reg2

* Reg 3: Generated Interaction Term for Female
cap drop totchr_female
gen totchr_female = totchr*female

regress ldrugexp hi_empunion totchr totchr_female female, vce(robust) 
eststo Reg3
test totchr_female

* Reg 4: Categorical Variables For Female Interaction
regress ldrugexp hi_empunion i.female#c.totchr female, vce(robust)
eststo Reg4
test 0.female#c.totchr = 1.female#c.totchr // test equality of coeffs

* Reg 5: Interaction for All Variables
regress ldrugexp i.female#c.hi_empunion i.female#c.totchr female, vce(robust)
eststo Reg5

***Present Result in Table
esttab Reg1 Reg2 Reg3 Reg4 Reg5, se stats(N r2)

