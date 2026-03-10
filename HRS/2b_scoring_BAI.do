/* 

NOTE:

Author: Emily Urban-Wojcik, emurbanw@med.umich.edu
Date: April 2025

Copyright © 2026 The Regents of the University of Michigan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License along
with this program. If not, see <https:#www.gnu.org/licenses/>.

**********

This script follows the 1_merging_data.do file

In this script we:
1) Set up our environment
2) Loop through two sets of HRS data years (depending on variable name roots) that covers 2006-2020 (but not 2014 or 2016) HRS waves
3) For each HRS wave with BAI data, creates an average BAI score (BAIavg_*)

*/

******************************************************************************
******************************************************************************
******************************************************************************
* Set-up
******************************************************************************
******************************************************************************
******************************************************************************

cd "/Users/emurbanw/OneDrive-MichiganMedicine/OneDriveDocuments/Datasets/HRS/trimmed_files"

use "HRS_RAND_allyears_trimmed_merged.dta", replace

******************************************************************************
******************************************************************************
******************************************************************************
* Beck Anxiety Inventory (BAI)
******************************************************************************
******************************************************************************
******************************************************************************

/*

The Beck Anxiety Inventory typically has 21 questions. The HRS uses 5 of those items.

In the HRS there are 5 BAI items scored on a scale of (1) Never, (2) Hardly ever, 
(3) Some of the time, (4) Most of the time. 

The time frame asked about is the past WEEK. 

Responses to the 5 items are averaged to form an index of anxiety ranging from 1-4. 
Set the final score to missing if more than two of the items have missing values. 

The BAI was given between 2006 and 2020, but was not asked in 2014 or 2016. 

*/


******************************************************************************
******************************************************************************
* Wave 2006 (k) through 2012 (n)

******************************************************************************
/* First, a check to compare one year in our loop to for sake of QA

egen BAImissing_k = rowmiss(klb041a klb041b klb041c klb041d klb041e)
tab BAImissing_k if BAImissing_k < 5
count if BAImissing_k < 5 // 7561 with some BAI items
count if BAImissing_k < 3 // 7529 with fewer than 3 missing items (and should be our final n with data)

egen BAIavg_k = rowmean(klb041a klb041b klb041c klb041d klb041e)
tab BAIavg_k
count if BAIavg_k >= 1 & BAIavg_k <=4 // 7561

replace BAIavg_k = . if BAImissing_k > 2 & BAImissing_k < 6
tab BAIavg_k
count if BAIavg_k >= 1 & BAIavg_k <=4 // 7529

drop BAImissing_k BAIavg_k

*/

******************************************************************************

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in k l m n {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* BAI symptoms
	local fear_worst = "`wave'lb041a" // I had fear of the worst happening.
	local nervous = "`wave'lb041b" // I was nervous.
	local hands_trembling = "`wave'lb041c" // I felt my hands trembling.
	local fear_dying = "`wave'lb041d" // I had a fear of dying. 
	local feel_faint = "`wave'lb041e" // I felt faint. 
	
	* BAI summary variables
	local BAImissing = "BAImissing_`wave'"
	local BAIavg = "BAIavg_`wave'"
	
	* Creating a sum of missing variables and checking
	egen `BAImissing' = rowmiss(`fear_worst' `nervous' `hands_trembling' `fear_dying' `feel_faint')
	tab `BAImissing'
	count if `BAImissing' < 5 
	count if `BAImissing' < 3	
	
	* Creating an average and checking counts
	egen `BAIavg' = rowmean(`fear_worst' `nervous' `hands_trembling' `fear_dying' `feel_faint')
	tab `BAIavg'
	count if `BAIavg' >= 1 & `BAIavg' <= 4
	
	* Replacing score if respondent has more than 2 missing responses (capping at < 6 so it doesn't count NAs, which are valued at +inf)
	replace `BAIavg' = . if `BAImissing' > 2 & `BAImissing' < 6
	
	* Checking scores
	tab `BAIavg'
	count if `BAIavg' >= 1 & `BAIavg' <= 4

}

******************************************************************************
******************************************************************************
* Wave 2018 (q) through 2020 (r)

* here we replace the root of the symptom variables, as they were different in these waves from 2006-2012
* We keep the locally defined variable name, though, so the code beyond defining variable names is the same across waves and doesn't need to be edited

******************************************************************************
/* First, a check to compare one year in our loop to for sake of QA

egen BAImissing_q = rowmiss(qlb035c1 qlb035c2 qlb035c3 qlb035c4 qlb035c5)
tab BAImissing_q if BAImissing_q < 5
count if BAImissing_q < 5 // 5605 with some BAI items
count if BAImissing_q < 3 // 5593 with fewer than 3 missing items (and should be our final n with data)

egen BAIavg_q = rowmean(qlb035c1 qlb035c2 qlb035c3 qlb035c4 qlb035c5)
tab BAIavg_q
count if BAIavg_q >= 1 & BAIavg_q <=4 // 5605

replace BAIavg_q = . if BAImissing_q > 2 & BAImissing_q < 6
tab BAIavg_q
count if BAIavg_q >= 1 & BAIavg_q <=4 // 5593

drop BAImissing_q BAIavg_q

*/
******************************************************************************

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in q r {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* BAI symptoms
	local fear_worst = "`wave'lb035c1" // I had fear of the worst happening.
	local nervous = "`wave'lb035c2" // I was nervous.
	local hands_trembling = "`wave'lb035c3" // I felt my hands trembling.
	local fear_dying = "`wave'lb035c4" // I had a fear of dying. 
	local feel_faint = "`wave'lb035c5" // I felt faint. 
	
	* BAI summary variables
	local BAImissing = "BAImissing_`wave'"
	local BAIavg = "BAIavg_`wave'"
	
	* Creating a sum of missing variables and checking
	egen `BAImissing' = rowmiss(`fear_worst' `nervous' `hands_trembling' `fear_dying' `feel_faint')
	tab `BAImissing'
	count if `BAImissing' < 5 
	count if `BAImissing' < 3	
	
	* Creating an average and checking counts
	egen `BAIavg' = rowmean(`fear_worst' `nervous' `hands_trembling' `fear_dying' `feel_faint')
	tab `BAIavg'
	count if `BAIavg' >= 1 & `BAIavg' <= 4
	
	* Replacing score if respondent has more than 2 missing responses (capping at < 6 so it doesn't count NAs, which are valued at +inf)
	replace `BAIavg' = . if `BAImissing' > 2 & `BAImissing' < 6
	
	* Checking scores
	tab `BAIavg'
	count if `BAIavg' >= 1 & `BAIavg' <= 4

}

******************************************************************************
******************************************************************************
* How many respondents were screened for BAI in each year?

local bai_variables BAIavg_k BAIavg_l BAIavg_m BAIavg_n BAIavg_q BAIavg_r

foreach var of local bai_variables {
	count if `var' >= 1 & `var' <= 4
}

* 2006: 7,529
* 2008: 6,919
* 2010: 8,168
* 2012: 7,200
* 2018: 5,593
* 2020: 4,609

******************************************************************************
******************************************************************************
* Now, recoding variables into the RAND suffix format (where a number takes place of the wave letter and early waves are combined)

* looping through each variable and each wave (starting at wave k and 8)
foreach var in BAIavg BAImissing {
	local counter = 8
	foreach wave in k l m n {
		display "variable `var' and wave 'wave'"
		gen `var'_`counter' = `var'_`wave'
		local counter = `counter' + 1
	}
}

* looping through each variable and each wave (starting at wave k and 3)
foreach var in BAIavg BAImissing {
	local counter = 14
	foreach wave in q r {
		display "variable `var' and wave 'wave'"
		gen `var'_`counter' = `var'_`wave'
		local counter = `counter' + 1
	}
}



* checking that this all worked
tab BAIavg_k
tab BAIavg_8

tab BAIavg_r
tab BAIavg_15

tab BAImissing_k
tab BAImissing_8

tab BAImissing_r
tab BAImissing_15


******************************************************************************
******************************************************************************
******************************************************************************

save "HRS_RAND_allyears_trimmed_merged_BAI.dta", replace
