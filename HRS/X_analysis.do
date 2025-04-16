
/* 

NOTE:

This script is intended to be run after all variables have been cleaned and analyses are pre-registered. 

For cross-sectional analyses, we can incorporate complex design features to make generalizations about the entire population
For longitudinal analyses, we cannot do the same thing unless we engage in some very complicated math

In this script we:
1) Set up our environment
2) Compare a model for one year of data with vs. without incorporating complex survey design features
3) Run a loop to analyze all cross-sectional waves of data for one model (CIDImde ~ wvcohort); includes visualizing prevalence estimates across all waves of HRS with CIDImde data
4) Run longitudinal mixed effects growth models

Variables:
sample: an indicator of respondents who are in our final sample and should be included in analyses as a subpopulation
CIDImde_`i': a wave-specific indicator of whether a respondent met criteria for Major Depressive Disorder in the past year based on the CIDI-sf
wvcohort_`i': a wave-specific indicator of which cancer group the respondent belongs to. 1 = No cancer ever, 2 = adult cancer (after joining HRS), 3 = AYA cancer survivor

*/

******************************************************************************
******************************************************************************
******************************************************************************
* Set-up
******************************************************************************
******************************************************************************
******************************************************************************

* Set your working directory
cd "/Users/emurbanw/University of Michigan Dropbox/MED-EFDC-DDC-internal/Tools_to_Share/HRS/"

* Open the wide file, which has 1 row per respondent
use AYA_cancer_HRS_wide.dta, replace

* Looking at our variable "sample", which indicates which observations will be included in our analysis
* This variable (sample == 1) will define our subpopulation for all analyses below
tab sample

******************************************************************************
******************************************************************************
******************************************************************************
* Comparing model with vs. without complex survey design features in 2018 (wave 14)
******************************************************************************
******************************************************************************
******************************************************************************

* First we set the up the survey design
* svyset: This command tells Stata how your survey data was collected so that subsequent svy: analyses can apply the right weights, stratification, and clustering.
* raehsamp: This is the primary sampling unit (PSU) variable — it identifies which cluster each observation belongs to.
* [pweight = wtresp_14]: This sets the probability weight for each respondent BASED ON SPECIFIC SURVEY WAVE. It adjusts for unequal probability of selection, nonresponse, and post-stratification to make estimates representative.
* strata(raestrat): This specifies the strata variable used in the sampling design — typically used to increase precision of estimates and account for design effects.
svyset raehsamp [pweight = wtresp_14], strata(raestrat)

* Prevalence estimates
* Note that the total number of subpopulation observations differs because people under 51 have a weight == 0, so they are not included in weighted analyses
tab CIDImde_14 wvcohort_14 if sample == 1, column chi2 // how many people within each wvcohort met MDD criteria?
svy, subpop(sample): tab CIDImde_14 wvcohort_14, count format(%15.0f) // how many people within each wvcohort met MDD criteria? (design-adjusted)
svy, subpop(sample): tab CIDImde_14 wvcohort_14, percent column // what percentage within each wvcohort met MDD criteria? (design-adjusted)

* Odds ratios
* Note that the i. tells Stata it is a categorical variable (the reference variable is whatever is coded as 1)
* Note that ib2. tells Stata it is a categorical variable and you want the reference variable to be whatever is coded as 2
* test gives you an adjusted Wald test to tell you if the overall term of the categorical variable is significant in the model (not just individual contrasts between categories)- leave one category out to run the test
* margins prints the prevalence rates of the outcome for the specified variables
logistic CIDImde_14 i.wvcohort_14
logistic CIDImde_14 ib2.wvcohort_14
svy, subpop(sample): logistic CIDImde_14 i.wvcohort_14
svy, subpop(sample): logistic CIDImde_14 ib2.wvcohort_14
test 1.wvcohort_14 3.wvcohort_14
margins ib2.wvcohort_14

* Odds ratios adjusting for covariates
logistic CIDImde_14 i.wvcohort_14 agec65_14 i.gender i.race
logistic CIDImde_14 ib2.wvcohort_14 agec65_14 i.gender i.race
svy, subpop(sample): logistic CIDImde_14 i.wvcohort_14 agec65_14 i.gender i.race
svy, subpop(sample): logistic CIDImde_14 ib2.wvcohort_14 agec65_14 i.gender i.race
test 1.wvcohort_14 3.wvcohort_14
margins ib2.wvcohort_14

*****************************************************************************
*****************************************************************************
*****************************************************************************
* Looping through all HRS waves that have CIDImde
*****************************************************************************
*****************************************************************************
*****************************************************************************

****************************************************************
* First step: No covariates

* Make sure we're using the wide data file
use AYA_cancer_HRS_wide.dta, replace

* Creating a loop that runs through waves 9 through 15, which are the waves that have CIDImde data
* The _`i' is a place holder for the wave number that is being looped through
forval i = 9/15 {
	svyset raehsamp [pweight = wtresp_`i'], strata(raestrat)
	svy, subpop(sample): tab CIDImde_`i' wvcohort_`i', count format(%15.0f) // counts in each cell
	svy, subpop(sample): logistic CIDImde_`i' i.wvcohort_`i' // no cancer group as the reference
	svy, subpop(sample): logistic CIDImde_`i' ib2.wvcohort_`i' // adult cancer group as the reference
	
	margins i.wvcohort_`i', saving(margins_CIDImde_`i', replace) // prevalence estimates for each grouping; here we save to later append all waves together
}

* Making a wave indicator for each row of the margins files	
forval i = 9/15 {
	use margins_CIDImde_`i', clear
	gen wave = `i'
	save margins_CIDImde_`i', replace
}

* Appending all margins
use margins_CIDImde_9
forval i = 10/15 {
	append using margins_CIDImde_`i'
}
save margins_CIDImde_all, replace

* Looking at all margins together
use margins_CIDImde_all, clear 
table wave, c(mean _margin mean _ci_lb mean _ci_ub) ///
       by(_m1) ///
	   format(%9.4f)

* Line graph to visualize cancer cohort differences in CIDImde by HRS wave
twoway (connected _margin wave if _m1 == 1, lcolor(blue) mcolor(blue)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 1, lcolor(blue)) ///
       (connected _margin wave if _m1 == 2, lcolor(red) mcolor(red)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 2, lcolor(red)) ///
	   (connected _margin wave if _m1 == 3, lcolor(gray) mcolor(gray)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 3, lcolor(gray)), ///
       legend(label(1 "No Cancer") label(3 "Adult Cancer") label(5 "AYA Cancer")) ///
       xtitle("Wave") ytitle("Estimated Prevalence Rate") title("Past Year Incidence of MDE by Cancer Cohort")

****************************************************************
* Second step: adjusting for age, gender, and race. 

* Make sure we're using the wide data file
use AYA_cancer_HRS_wide.dta, replace

forval i = 9/15 {
	svyset raehsamp [pweight = wtresp_`i'], strata(raestrat)
	svy, subpop (sample2): tab wvcohort_`i' if (!missing(CIDImde_`i')), count format(%15.0f)
	svy, subpop(sample2): tab CIDImde_`i' wvcohort_`i', count format(%15.0f) // counts in each cell
	svy, subpop(sample2): logistic CIDImde_`i' i.wvcohort_`i' agec65_`i' i.gender i.race // no cancer group as the reference
	svy, subpop(sample2): logistic CIDImde_`i' ib2.wvcohort_`i' agec65_`i' i.gender i.race // adult cancer group as the reference
	test 1.wvcohort_`i' 3.wvcohort_`i' // for testing the overall wvcohort_`i' grouping
	margins i.wvcohort_`i', saving(margins_CIDImde_adj_`i', replace) // prevalence estimates for each grouping
}

* Making a wave indicator for each row of the margins files	
forval i = 9/15 {
	use margins_CIDImde_adj_`i', clear
	gen wave = `i'
	save margins_CIDImde_adj_`i', replace
}

* Appending all margins
use margins_CIDImde_adj_9
forval i = 10/15 {
	append using margins_CIDImde_adj_`i'
}
save margins_CIDImde_adj_all, replace

* Looking at all margins together
use margins_CIDImde_adj_all, clear 
table wave, c(mean _margin mean _ci_lb mean _ci_ub) ///
       by(_m1) ///
	   format(%9.4f)

* Line graph to visualize cancer cohort differences in CIDImde by HRS wave
twoway (connected _margin wave if _m1 == 1, lcolor(blue) mcolor(blue)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 1, lcolor(blue)) ///
       (connected _margin wave if _m1 == 2, lcolor(red) mcolor(red)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 2, lcolor(red)) ///
	   (connected _margin wave if _m1 == 3, lcolor(gray) mcolor(gray)) ///
       (rcap _ci_lb _ci_ub wave if _m1 == 3, lcolor(gray)), ///
       legend(label(1 "No Cancer") label(3 "Adult Cancer") label(5 "AYA Cancer")) ///
       xtitle("Wave") ytitle("Estimated Prevalence Rate") title("Past Year Incidence of MDE by Cancer Cohort adjusted for demographics")

*****************************************************************************
*****************************************************************************
*****************************************************************************
* Longitudinal Analyses: Mixed Effects Growth Models
*****************************************************************************
*****************************************************************************
*****************************************************************************

* Make sure we're using the long data file (each respondent will have multiple rows, where each row is one wave per respondent)
use AYA_cancer_HRS_long.dta, replace

* There is no cesd for 1992, all are NAs; Also dropping if they are not part of our main sample AND if they are missing data for covariates
drop if year == 1992
drop if sample2 == 0 

* CESD sum ranges from 0 to 8, with a mean of 1.51
summarize cesd

* Number of waves with CESD data ranges from 1 to 14, mean of 9
bysort hhidpn: egen num_cesd_waves = total(sample) if !missing(cesd)
summarize num_cesd_waves

* MODEL 0: Unconditional means model; Gives the mean CESD score across all years for all respondents
* || hhidpn: indicates you want a random intercept for each individual, allowing each person to have their own baseline for cesd
* covariance(unstructured) assumes no specific pattern for how the random effects (intercepts) for each individual are correlated. 
mixed cesd || hhidpn: , covariance(unstructured)
estimates store model_0 // storing model information
estat icc // intraclass correlation; tells us the proportion of the variance in cesd that is due to differences between individuals (and the remainder is due to differences within individuals across measurements)
estat ic // model fit information

* MODEL 1: Unconditional growth model; In 1993 the mean CESD score was 1.51. For each consecutive year, CESD scores increased by .008 on average. 
* Models cesd across survey years (centered at 1993). 
* || hhidpn: yearc1993 allows for both a random intercept and random slope for year within each respondent (so each respondent can have a different intercept and a different slope across time)
mixed cesd yearc1993 || hhidpn: yearc1993, covariance(unstructured)
estimates store model_1 
estat ic
lrtest model_1 model_0 // comparing model fit between this model and the previous model

* MODEL 2: Conditional growth model (age and age^2)
* Age (centered at 65 and scaled) is entered as random effect with quadratic term; The intercept tells us the mean cesd score of 65 year olds in 1993.  
* Across the adult lifespan represented in the data, there is U-shape in relation to CESD, which is highest in the youngest and oldest years
* the twoway command below plots the predicted cesd score by for 1993 and 2018, showing mean levels of CESD have increased historically (in addition to U-shape age relationship)
mixed cesd yearc1993 agec65scaled agec65sqscaled || hhidpn: agec65scaled, covariance(unstructured) 
estimates store model_2
estat ic // 
lrtest model_2 model_1
predict cesd_predict2, xb
twoway (scatter cesd_predict2 agec65scaled if yearc1993 == 0, msymbol(circle) mcolor(blue) msize(small) ///
       ) (scatter cesd_predict2 agec65scaled if yearc1993 == 25, msymbol(square) mcolor(gs13) msize(small) ///
	   ), ///
	xlabel(-4 "25" -3 "35" -2 "45" -1 "55" 0 "65" 1 "75" 2 "85" 3 "95") ///
	legend(order(1 "1993" 2 "2018") cols(2)) ///
    title("Predicted CESD Scores by Age and Year")

* MODEL 3: Adding in wave-specific cancer cohort
mixed cesd yearc1993 agec65scaled agec65sqscaled ib1.wvcohort || hhidpn: agec65scaled, covariance(unstructured) 
mixed cesd yearc1993 agec65scaled agec65sqscaled ib3.wvcohort || hhidpn: agec65scaled, covariance(unstructured) 
estimates store model_3
estat ic
lrtest model_3 model_2
predict cesd_predict3, xb
twoway (line cesd_predict3 agec65scaled if wvcohort == 1 & yearc1993 == 25, msymbol(circle) mcolor(black) msize(small) ///
        ) (line cesd_predict3 agec65scaled if wvcohort == 2 & yearc1993 == 25, msymbol(square) mcolor(gs13) msize(small) ///
        ) (line cesd_predict3 agec65scaled if wvcohort == 3 & yearc1993 == 25, msymbol(triangle) mcolor(gray) msize(small) ///
        ), ///
        xlabel(-4 "25" -3 "35" -2 "45" -1 "55" 0 "65" 1 "75" 2 "85" 3 "95") ///
        legend(order(1 "No Cancer" 2 "Adult Cancer" 3 "AYA Cancer") cols(3)) ///
		ytitle("CES-D Depression Score", size(medium)) ///
        xtitle("Age", size(medium)) ///
		graphregion(color(white)) ///
		title("Predicted CESD Scores by Age and Cancer Group in 2018")

* MODEL 4: Adding in interaction between age and wave-specific cancer cohort
mixed cesd yearc1993 c.agec65scaled##ib3.wvcohort agec65sqscaled || hhidpn: agec65scaled, covariance(unstructured) 
estimates store model_4
estat ic 
lrtest model_4 model_3

* MODEL 5: Adding in covariates; Final model: No interaction but including covariates
mixed cesd yearc1993 c.agec65scaled ib3.wvcohort agec65sqscaled yrssincedx i.gender i.race || hhidpn: agec65scaled, covariance(unstructured) 
estimates store model_5
estat ic 
lrtest model_5 model_3

