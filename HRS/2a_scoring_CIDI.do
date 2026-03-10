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
2) Loop through four sets of HRS data years (depending on variable name roots) that covers 1995-2020 HRS waves
3) For each HRS wave, creates a numeric Depressive symptoms (DepBranchSum_*), Anhedonia symptoms (AnhedBranchSum_*), and Total Symptom sum score (CIDIsum_*)
4) And for each HRS wave, creates a binary classifier for whether Major Depressive Disorder criteria were met (CIDImde_*)  


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
* Composite International Diagnostic Interview (CIDI) for depression
******************************************************************************
******************************************************************************
******************************************************************************


/* 

The CIDI asks two branches of questions based on a) dysphoria symptoms and b) anhedonia symptoms
Each of these branches first screens for dysphoria or anhedonia
If the respondent meets certain criteria they are screened into the CIDI-SF module and asked additional questions

To be screened into the CIDI-SF module, they have to report:
(c150 == 1; depressed) feeling depressed for 2 weeks or more in a row during the last year;
(c151 == 1 | 2; portion) feeling this way at least most of the day during that time;
(c152 == 1 | 2; frequency) feeling this way almost every day of those 2+ weeks
then they answer the questions c153-c161
if they do not meet these criteria, then they are asked the quesitons about anhedonia

To be screened into the CIDI-SF module for anhedonia, they have to report:
(c167 == 1; anhedonia) losing interest in most things that usually give them pleasure for 2 weeks or more in a row during the last year;
(c168 == 1 | 2; portion) feeling this way at least most of the day during that time;
(c169 == 1 | 2; frequency) feeling this way almost every day of those 2+ weeks
then they answer the questions c170-c177
if they do not meet these criteria, they are screened out completely

The final sum score is based on the presence of a total of 8 symptoms (inclulding dysphoria and anhedonia).
This is meant to mirror how MDD is assessed in the DSM-5, which states that "five (or more) of the following [9] symptoms
have been present during the same two-week period and represent a change from previous functioning; at least one of the
symptoms is either (1) depressed mood or (2) loss of interest or pleasure. 
IMPORTANTLY, HRS does not ask about psychomotor agitation/retardation, which is one of the 9 symptoms
So our score will be based on a total of 8 symptoms.

The scoring of the CIDI here diverges from the recommendations from HRS, where the sum can range from 0 to 7.
Reference: https://hrs.isr.umich.edu/sites/default/files/biblio/dr-005.pdf
"The summary variable for the CIDI-SF ranges from zero to seven... For those who did endorse one
of these screen questions with the appropriate frequency/duration, the summary variable is the
count of the number of symptoms endorsed out of the seven. Note that the possible score for
respondents endorsing the second screen question only ranges from zero to six, because
anhedonia is counted as an additional symptom for those with depressed mood."

******************************************************************************

The following syntax is based off syntax shared by Linh Dang (Dang, Dong, & Mezuk, 2020), 
but edited to fit this project's needs; Most notably, the below now has loops to score multiple years
of CIDI-SF depression variables. 

There are four sets of loops: the first covers waves 2002-2020, all of which
have the same root for variables (`wave'c150 through `wave'c177). The next covers waves 1995-1996 which have
the same root for variables (`wave'1006 through `wave'1038). The third covers wave 1998 (f1323-f1355), 
the fourth covers 2000 (g1456-g1488).

Note that the ONLY difference in the loops below is the bit in the loop setup section that specifies the 
relevant variable name that is to be looped through (i.e., the loop setup section). 
The CIDI screening and CIDI sum score are computed exactly the same.

*/

******************************************************************************
******************************************************************************
* Wave 1995 (d) and 1996 (e)

* here we replace the root of the symptom variables, as they were different in these waves from 2002-2020
* We keep the locally defined variable name, though, so the code beyond defining variable names is the same across waves and doesn't need to be edited

******************************************************************************
* Loop Setup

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in d e {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* dep screen questions
	local c150 = "`wave'1006" // felt depressed in past yr - dep screen
	local c151 = "`wave'1007" // depressed what portion of day - dep screen
	local c152 = "`wave'1008" // depressed every day - dep screen
	
	* dep branch questions
	local c153 = "`wave'1009" // loss of interest - dep branch
	local c154 = "`wave'1010" // feeling tired - dep branch
	local c155 = "`wave'1011" // lose appetite - dep branch
	local c156 = "`wave'1012" // appetite increase - dep branch
	local c157 = "`wave'1013" // trouble fall asleep - dep branch
	local c158 = "`wave'1014" // freq of trouble falling asleep - dep branch
	local c159 = "`wave'1015" // trouble concentrating - dep branch
	local c160 = "`wave'1016" // feeling down on yourself - dep branch
	local c161 = "`wave'1017" // thoughts about death - dep branch
	
	* anhed screen questions
	local c167 = "`wave'1028" // lose interest - anhed screen
	local c168 = "`wave'1029" // lose interest often - anhed screen
	local c169 = "`wave'1030" // lose interest dysfunction - anhed screen
	
	* anhed branch questions
	local c170 = "`wave'1031" // feeling tired - anhed branch
	local c171 = "`wave'1032" // lost appetite - anhed branch
	local c172 = "`wave'1033" // appetite increase - anhed branch
	local c173 = "`wave'1034" // trouble falling asleep - anhed branch
	local c174 = "`wave'1035" // frequency of sleep trouble - anhed branch
	local c175 = "`wave'1036" // trouble concentrate - anhed branch
	local c176 = "`wave'1037" // feeliing down on oneself - anhed branch
	local c177 = "`wave'1038" // interest in death - anhed branch
	
	* screening indicator variables
	local CIDIDepScreen = "CIDIDepScreen_`wave'"
	local CIDIAnhedScreen = "CIDIAnhedScreen_`wave'"
	local CIDIScreen = "CIDIScreen_`wave'"
	
	* presence of symptom recode variables
	local c150recode = "`wave'c150recode"
	local c153recode = "`wave'c153recode"
	local c154recode = "`wave'c154recode"
	local c155recode = "`wave'c155recode"
	local c157recode = "`wave'c157recode"
	local c159recode = "`wave'c159recode"
	local c160recode = "`wave'c160recode"
	local c161recode = "`wave'c161recode"
	local c167recode = "`wave'c167recode"
	local c170recode = "`wave'c170recode"
	local c171recode = "`wave'c171recode"
	local c173recode = "`wave'c173recode"
	local c175recode = "`wave'c175recode"
	local c176recode = "`wave'c176recode"
	local c177recode = "`wave'c177recode"
	
	* summing symptom score variables
	local DepBranchSum = "DepBranchSum_`wave'"
	local AnhedBranchSum = "AnhedBranchSum_`wave'"
	local CIDIsum_check = "CIDIsum_check_`wave'"
	local CIDIsum = "CIDIsum_`wave'"
	local CIDImde = "CIDImde_`wave'"
	
	******************************************************************************
	* CIDI Screening

	* Whether they met criteria for further symptom questions in cidi
	* Must meet EITHER depressed mood or anhedonia screening criteria
	* If meet depressed mood screening criteria, not screened for anhedonia (but are asked a question if they felt anhedonia) 

	* how many cases should we expect for the CIDIDepScreen? 
	count if `c150' == 1 & (`c151' == 1 | `c151' == 2) & (`c152' == 1 | `c152' == 2) // this number should match CIDIDepScreen == 1

	* Depressed mood screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	generate `CIDIDepScreen' = .
	replace `CIDIDepScreen' = 1 if (`c150' == 1) & inlist(`c151',1,2) & inlist(`c152',1,2) // = 1 if they report depressed mood for 2+ weeks in past year (`c150') for at least most of the day (`c151') at least almost every day (`c152')
	replace `CIDIDepScreen' = 0 if (`c150' != . & `c150' != 1) // = 0 if their response is not missing to whether they felt depressed mood in the past year and their response is not "yes"
	replace `CIDIDepScreen' = 0 if (`c151' != .) & !inlist(`c151',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIDepScreen' = 0 if (`c152' != .) & !inlist(`c152',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIDepScreen' == 1

	* how many cases should we expect for the CIDIAnhedScreen? 
	count if `c167' == 1 & (`c168' == 1 | `c168' == 2) & (`c169' == 1 | `c169' == 2) // this number should match CIDIAnhedScreen == 1

	* Anhedonia screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	* Only screened for this if did not meet critera in the depressed mood screener
	generate `CIDIAnhedScreen' = .
	replace `CIDIAnhedScreen' = 1 if (`c167' == 1) & inlist(`c168',1,2) & inlist(`c169',1,2) // = 1 if they report anhedonia for 2+ weeks in past year (`c167') for at least most of the day (`c168') at least almost every day (`c169')
	replace `CIDIAnhedScreen' = 0 if (`c167' != . & `c167' != 1) // = 0 if their response is not missing to whether they felt anhedonia in the past year and their response is not "yes"
	replace `CIDIAnhedScreen' = 0 if (`c168' != .) & !inlist(`c168',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIAnhedScreen' = 0 if (`c169' != .) & !inlist(`c169',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIAnhedScreen' == 1

	* Making sure nobody is in BOTH screening groups
	count if `CIDIDepScreen' == 1 & `CIDIAnhedScreen' == 1 // should = 0

	* Overall variable to indiciate whether they met screening criteria in either of the modules
	generate `CIDIScreen' = .
	replace `CIDIScreen' = 1 if (`CIDIDepScreen' == 1 | `CIDIAnhedScreen' == 1)
	replace `CIDIScreen' = 0 if (`CIDIDepScreen' == 0 & `CIDIAnhedScreen' == 0)
	count if `CIDIScreen' == 1 // should = CIDIDepScreen + CIDIAnhedScreen

	******************************************************************************
	* CIDI sum score

	* Recode c153-161: FIRST BRANCH OF QUESTIONS 
	* first branch of questions for those who got them; that is those who met the depressed mood screening criteria
	* the conditional `CIDIDepScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	gen `c150recode' = (`c150' == 1) if `CIDIDepScreen' == 1 // Depressed mood
	gen `c153recode' = (`c153' == 1) if `CIDIDepScreen' == 1 // Anhedonia 
	gen `c154recode' = (`c154' == 1) if `CIDIDepScreen' == 1 // Feel tired 
	gen `c155recode' = (`c155' == 1 | `c156' == 1) if `CIDIDepScreen' == 1 // Appetite symptom: either lose appetite (`c155) or increase appetite (`c156)
	gen `c157recode' = (`c157' == 1 & inlist(`c158',1,2)) if `CIDIDepScreen' == 1 // Trouble sleep: "Yes" to probing question (`c157) AND frequency (`c158) is nearly every night or every night
	gen `c159recode' = (`c159' == 1) if `CIDIDepScreen' == 1 // Trouble concentrating
	gen `c160recode' = (`c160' == 1) if `CIDIDepScreen' == 1 // Feel down on yourself 
	gen `c161recode' = (`c161' == 1) if `CIDIDepScreen' == 1 // Thoughts of death 

	* Recode c170-177: SECOND BRANCH OF QUESTIONS 
	* second branch of questions for those who got them; that is those who met the anhedonia screening criteria
	* the conditional `CIDIAnhedScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	replace `c150recode' = 0 if `CIDIAnhedScreen' == 1 // Depressed mood; ALWAYS 0 for those in the anhedonia branch, they are in that branch because they did not meet the depressed mood criteria
	gen `c167recode' = (`c167' == 1) if `CIDIAnhedScreen' == 1 // Anhedonia 
	gen `c170recode' = (`c170' == 1) if `CIDIAnhedScreen' == 1 // Feel tired 
	gen `c171recode' = (`c171' == 1 | `c172' == 1) if `CIDIAnhedScreen' == 1 // Appetite symptom: either lose appetite (`c171) or increase appetite (`c172)
	gen `c173recode' = (`c173' == 1 & inlist(`c174',1,2)) if `CIDIAnhedScreen' == 1 // Trouble sleep: "Yes" to probing question (`c173) AND frequency (`c174) is nearly every night or every night
	gen `c175recode' = (`c175' == 1) if `CIDIAnhedScreen' == 1 // Trouble concentrating
	gen `c176recode' = (`c176' == 1) if `CIDIAnhedScreen' == 1 // Feel down on yourself 
	gen `c177recode' = (`c177' == 1) if `CIDIAnhedScreen' == 1 // Thoughts of death 

	* Find sum for each branch of questions
	* This includes the same 8 symptoms for each branch
	* Note that those in the anhed_branch should NEVER get a score of 8, their max should be 7; they are in the anhed_branch BECAUSE they didn't meet the screening criteria for depressed mood so got a 0 on that
	egen `DepBranchSum' = rowtotal(`c150recode' `c153recode' `c154recode' `c155recode' `c157recode' `c159recode' `c160recode' `c161recode') if `CIDIDepScreen' == 1
	egen `AnhedBranchSum' = rowtotal(`c150recode' `c167recode' `c170recode' `c171recode' `c173recode' `c175recode' `c176recode' `c177recode') if `CIDIAnhedScreen' == 1

	* CIDI Sumscore (`CIDIsum')
	gen `CIDIsum' = .
	replace `CIDIsum' = `DepBranchSum' if `CIDIDepScreen' == 1
	replace `CIDIsum' = `AnhedBranchSum' if `CIDIAnhedScreen' == 1

	* Anyone who doesn't meet screening criteria gets a score of 0
	replace `CIDIsum' = 0 if `CIDIScreen' == 0

	* Final CIDIsum variable
	tab `CIDIsum'
	tab `CIDIsum' if `CIDIScreen' == 1
	count if `CIDIsum' > 0 & `CIDIsum' < 9

	* Major Depressive Episode indicator variable
	gen `CIDImde' = .
	replace `CIDImde' = 1 if `CIDIsum' >= 5 & `CIDIsum' < 9
	replace `CIDImde' = 0 if `CIDIsum' < 5
	tab `CIDImde'

}

******************************************************************************
******************************************************************************
* Wave 1998 (f)

* here we replace the root of the symptom variables, as they were different in these waves from 2002-2020
* We keep the locally defined variable name, though, so the code beyond defining variable names is the same across waves and doesn't need to be edited

******************************************************************************
* Loop Setup

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in f {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* dep screen questions
	local c150 = "`wave'1323" // felt depressed in past yr - dep screen
	local c151 = "`wave'1324" // depressed what portion of day - dep screen
	local c152 = "`wave'1325" // depressed every day - dep screen
	
	* dep branch questions
	local c153 = "`wave'1326" // loss of interest - dep branch
	local c154 = "`wave'1327" // feeling tired - dep branch
	local c155 = "`wave'1328" // lose appetite - dep branch
	local c156 = "`wave'1329" // appetite increase - dep branch
	local c157 = "`wave'1330" // trouble fall asleep - dep branch
	local c158 = "`wave'1331" // freq of trouble falling asleep - dep branch
	local c159 = "`wave'1332" // trouble concentrating - dep branch
	local c160 = "`wave'1333" // feeling down on yourself - dep branch
	local c161 = "`wave'1334" // thoughts about death - dep branch
	
	* anhed screen questions
	local c167 = "`wave'1345" // lose interest - anhed screen
	local c168 = "`wave'1346" // lose interest often - anhed screen
	local c169 = "`wave'1347" // lose interest dysfunction - anhed screen
	
	* anhed branch questions
	local c170 = "`wave'1348" // feeling tired - anhed branch
	local c171 = "`wave'1349" // lost appetite - anhed branch
	local c172 = "`wave'1350" // appetite increase - anhed branch
	local c173 = "`wave'1351" // trouble falling asleep - anhed branch
	local c174 = "`wave'1352" // frequency of sleep trouble - anhed branch
	local c175 = "`wave'1353" // trouble concentrate - anhed branch
	local c176 = "`wave'1354" // feeliing down on oneself - anhed branch
	local c177 = "`wave'1355" // interest in death - anhed branch
	
	* screening indicator variables
	local CIDIDepScreen = "CIDIDepScreen_`wave'"
	local CIDIAnhedScreen = "CIDIAnhedScreen_`wave'"
	local CIDIScreen = "CIDIScreen_`wave'"
	
	* presence of symptom recode variables
	local c150recode = "`wave'c150recode"
	local c153recode = "`wave'c153recode"
	local c154recode = "`wave'c154recode"
	local c155recode = "`wave'c155recode"
	local c157recode = "`wave'c157recode"
	local c159recode = "`wave'c159recode"
	local c160recode = "`wave'c160recode"
	local c161recode = "`wave'c161recode"
	local c167recode = "`wave'c167recode"
	local c170recode = "`wave'c170recode"
	local c171recode = "`wave'c171recode"
	local c173recode = "`wave'c173recode"
	local c175recode = "`wave'c175recode"
	local c176recode = "`wave'c176recode"
	local c177recode = "`wave'c177recode"
	
	* summing symptom score variables
	local DepBranchSum = "DepBranchSum_`wave'"
	local AnhedBranchSum = "AnhedBranchSum_`wave'"
	local CIDIsum_check = "CIDIsum_check_`wave'"
	local CIDIsum = "CIDIsum_`wave'"
	local CIDImde = "CIDImde_`wave'"
		
	******************************************************************************
	* CIDI Screening

	* Whether they met criteria for further symptom questions in cidi
	* Must meet EITHER depressed mood or anhedonia screening criteria
	* If meet depressed mood screening criteria, not screened for anhedonia (but are asked a question if they felt anhedonia) 

	* how many cases should we expect for the CIDIDepScreen? 
	count if `c150' == 1 & (`c151' == 1 | `c151' == 2) & (`c152' == 1 | `c152' == 2) // this number should match CIDIDepScreen == 1

	* Depressed mood screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	generate `CIDIDepScreen' = .
	replace `CIDIDepScreen' = 1 if (`c150' == 1) & inlist(`c151',1,2) & inlist(`c152',1,2) // = 1 if they report depressed mood for 2+ weeks in past year (`c150') for at least most of the day (`c151') at least almost every day (`c152')
	replace `CIDIDepScreen' = 0 if (`c150' != . & `c150' != 1) // = 0 if their response is not missing to whether they felt depressed mood in the past year and their response is not "yes"
	replace `CIDIDepScreen' = 0 if (`c151' != .) & !inlist(`c151',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIDepScreen' = 0 if (`c152' != .) & !inlist(`c152',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIDepScreen' == 1

	* how many cases should we expect for the CIDIAnhedScreen? 
	count if `c167' == 1 & (`c168' == 1 | `c168' == 2) & (`c169' == 1 | `c169' == 2) // this number should match CIDIAnhedScreen == 1

	* Anhedonia screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	* Only screened for this if did not meet critera in the depressed mood screener
	generate `CIDIAnhedScreen' = .
	replace `CIDIAnhedScreen' = 1 if (`c167' == 1) & inlist(`c168',1,2) & inlist(`c169',1,2) // = 1 if they report anhedonia for 2+ weeks in past year (`c167') for at least most of the day (`c168') at least almost every day (`c169')
	replace `CIDIAnhedScreen' = 0 if (`c167' != . & `c167' != 1) // = 0 if their response is not missing to whether they felt anhedonia in the past year and their response is not "yes"
	replace `CIDIAnhedScreen' = 0 if (`c168' != .) & !inlist(`c168',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIAnhedScreen' = 0 if (`c169' != .) & !inlist(`c169',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIAnhedScreen' == 1

	* Making sure nobody is in BOTH screening groups
	count if `CIDIDepScreen' == 1 & `CIDIAnhedScreen' == 1 // should = 0

	* Overall variable to indiciate whether they met screening criteria in either of the modules
	generate `CIDIScreen' = .
	replace `CIDIScreen' = 1 if (`CIDIDepScreen' == 1 | `CIDIAnhedScreen' == 1)
	replace `CIDIScreen' = 0 if (`CIDIDepScreen' == 0 & `CIDIAnhedScreen' == 0)
	count if `CIDIScreen' == 1 // should = CIDIDepScreen + CIDIAnhedScreen

	******************************************************************************
	* CIDI sum score

	* Recode c153-161: FIRST BRANCH OF QUESTIONS 
	* first branch of questions for those who got them; that is those who met the depressed mood screening criteria
	* the conditional `CIDIDepScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	gen `c150recode' = (`c150' == 1) if `CIDIDepScreen' == 1 // Depressed mood
	gen `c153recode' = (`c153' == 1) if `CIDIDepScreen' == 1 // Anhedonia 
	gen `c154recode' = (`c154' == 1) if `CIDIDepScreen' == 1 // Feel tired 
	gen `c155recode' = (`c155' == 1 | `c156' == 1) if `CIDIDepScreen' == 1 // Appetite symptom: either lose appetite (`c155) or increase appetite (`c156)
	gen `c157recode' = (`c157' == 1 & inlist(`c158',1,2)) if `CIDIDepScreen' == 1 // Trouble sleep: "Yes" to probing question (`c157) AND frequency (`c158) is nearly every night or every night
	gen `c159recode' = (`c159' == 1) if `CIDIDepScreen' == 1 // Trouble concentrating
	gen `c160recode' = (`c160' == 1) if `CIDIDepScreen' == 1 // Feel down on yourself 
	gen `c161recode' = (`c161' == 1) if `CIDIDepScreen' == 1 // Thoughts of death 

	* Recode c170-177: SECOND BRANCH OF QUESTIONS 
	* second branch of questions for those who got them; that is those who met the anhedonia screening criteria
	* the conditional `CIDIAnhedScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	replace `c150recode' = 0 if `CIDIAnhedScreen' == 1 // Depressed mood; ALWAYS 0 for those in the anhedonia branch, they are in that branch because they did not meet the depressed mood criteria
	gen `c167recode' = (`c167' == 1) if `CIDIAnhedScreen' == 1 // Anhedonia 
	gen `c170recode' = (`c170' == 1) if `CIDIAnhedScreen' == 1 // Feel tired 
	gen `c171recode' = (`c171' == 1 | `c172' == 1) if `CIDIAnhedScreen' == 1 // Appetite symptom: either lose appetite (`c171) or increase appetite (`c172)
	gen `c173recode' = (`c173' == 1 & inlist(`c174',1,2)) if `CIDIAnhedScreen' == 1 // Trouble sleep: "Yes" to probing question (`c173) AND frequency (`c174) is nearly every night or every night
	gen `c175recode' = (`c175' == 1) if `CIDIAnhedScreen' == 1 // Trouble concentrating
	gen `c176recode' = (`c176' == 1) if `CIDIAnhedScreen' == 1 // Feel down on yourself 
	gen `c177recode' = (`c177' == 1) if `CIDIAnhedScreen' == 1 // Thoughts of death 

	* Find sum for each branch of questions
	* This includes the same 8 symptoms for each branch
	* Note that those in the anhed_branch should NEVER get a score of 8, their max should be 7; they are in the anhed_branch BECAUSE they didn't meet the screening criteria for depressed mood so got a 0 on that
	egen `DepBranchSum' = rowtotal(`c150recode' `c153recode' `c154recode' `c155recode' `c157recode' `c159recode' `c160recode' `c161recode') if `CIDIDepScreen' == 1
	egen `AnhedBranchSum' = rowtotal(`c150recode' `c167recode' `c170recode' `c171recode' `c173recode' `c175recode' `c176recode' `c177recode') if `CIDIAnhedScreen' == 1

	* CIDI Sumscore (`CIDIsum')
	gen `CIDIsum' = .
	replace `CIDIsum' = `DepBranchSum' if `CIDIDepScreen' == 1
	replace `CIDIsum' = `AnhedBranchSum' if `CIDIAnhedScreen' == 1

	* Anyone who doesn't meet screening criteria gets a score of 0
	replace `CIDIsum' = 0 if `CIDIScreen' == 0

	* Final CIDIsum variable
	tab `CIDIsum'
	tab `CIDIsum' if `CIDIScreen' == 1
	count if `CIDIsum' > 0 & `CIDIsum' < 9

	* Major Depressive Episode indicator variable
	gen `CIDImde' = .
	replace `CIDImde' = 1 if `CIDIsum' >= 5 & `CIDIsum' < 9
	replace `CIDImde' = 0 if `CIDIsum' < 5
	tab `CIDImde'

}

******************************************************************************
******************************************************************************
* Wave 2000 (g)

* here we replace the root of the symptom variables, as they were different in these waves from 2002-2020
* We keep the locally defined variable name, though, so the code beyond defining variable names is the same across waves and doesn't need to be edited

******************************************************************************
* Loop Setup

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in g {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* dep screen questions
	local c150 = "`wave'1456" // felt depressed in past yr - dep screen
	local c151 = "`wave'1457" // depressed what portion of day - dep screen
	local c152 = "`wave'1458" // depressed every day - dep screen
	
	* dep branch questions
	local c153 = "`wave'1459" // loss of interest - dep branch
	local c154 = "`wave'1460" // feeling tired - dep branch
	local c155 = "`wave'1461" // lose appetite - dep branch
	local c156 = "`wave'1462" // appetite increase - dep branch
	local c157 = "`wave'1463" // trouble fall asleep - dep branch
	local c158 = "`wave'1464" // freq of trouble falling asleep - dep branch
	local c159 = "`wave'1465" // trouble concentrating - dep branch
	local c160 = "`wave'1466" // feeling down on yourself - dep branch
	local c161 = "`wave'1467" // thoughts about death - dep branch
	
	* anhed screen questions
	local c167 = "`wave'1478" // lose interest - anhed screen
	local c168 = "`wave'1479" // lose interest often - anhed screen
	local c169 = "`wave'1480" // lose interest dysfunction - anhed screen
	
	* anhed branch questions
	local c170 = "`wave'1481" // feeling tired - anhed branch
	local c171 = "`wave'1482" // lost appetite - anhed branch
	local c172 = "`wave'1483" // appetite increase - anhed branch
	local c173 = "`wave'1484" // trouble falling asleep - anhed branch
	local c174 = "`wave'1485" // frequency of sleep trouble - anhed branch
	local c175 = "`wave'1486" // trouble concentrate - anhed branch
	local c176 = "`wave'1487" // feeliing down on oneself - anhed branch
	local c177 = "`wave'1488" // interest in death - anhed branch
	
	* screening indicator variables
	local CIDIDepScreen = "CIDIDepScreen_`wave'"
	local CIDIAnhedScreen = "CIDIAnhedScreen_`wave'"
	local CIDIScreen = "CIDIScreen_`wave'"
	
	* presence of symptom recode variables
	local c150recode = "`wave'c150recode"
	local c153recode = "`wave'c153recode"
	local c154recode = "`wave'c154recode"
	local c155recode = "`wave'c155recode"
	local c157recode = "`wave'c157recode"
	local c159recode = "`wave'c159recode"
	local c160recode = "`wave'c160recode"
	local c161recode = "`wave'c161recode"
	local c167recode = "`wave'c167recode"
	local c170recode = "`wave'c170recode"
	local c171recode = "`wave'c171recode"
	local c173recode = "`wave'c173recode"
	local c175recode = "`wave'c175recode"
	local c176recode = "`wave'c176recode"
	local c177recode = "`wave'c177recode"
	
	* summing symptom score variables
	local DepBranchSum = "DepBranchSum_`wave'"
	local AnhedBranchSum = "AnhedBranchSum_`wave'"
	local CIDIsum_check = "CIDIsum_check_`wave'"
	local CIDIsum = "CIDIsum_`wave'"
	local CIDImde = "CIDImde_`wave'"
	
	******************************************************************************
	* CIDI Screening

	* Whether they met criteria for further symptom questions in cidi
	* Must meet EITHER depressed mood or anhedonia screening criteria
	* If meet depressed mood screening criteria, not screened for anhedonia (but are asked a question if they felt anhedonia) 

	* how many cases should we expect for the CIDIDepScreen? 
	count if `c150' == 1 & (`c151' == 1 | `c151' == 2) & (`c152' == 1 | `c152' == 2) // this number should match CIDIDepScreen == 1

	* Depressed mood screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	generate `CIDIDepScreen' = .
	replace `CIDIDepScreen' = 1 if (`c150' == 1) & inlist(`c151',1,2) & inlist(`c152',1,2) // = 1 if they report depressed mood for 2+ weeks in past year (`c150') for at least most of the day (`c151') at least almost every day (`c152')
	replace `CIDIDepScreen' = 0 if (`c150' != . & `c150' != 1) // = 0 if their response is not missing to whether they felt depressed mood in the past year and their response is not "yes"
	replace `CIDIDepScreen' = 0 if (`c151' != .) & !inlist(`c151',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIDepScreen' = 0 if (`c152' != .) & !inlist(`c152',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIDepScreen' == 1

	* how many cases should we expect for the CIDIAnhedScreen? 
	count if `c167' == 1 & (`c168' == 1 | `c168' == 2) & (`c169' == 1 | `c169' == 2) // this number should match CIDIAnhedScreen == 1

	* Anhedonia screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	* Only screened for this if did not meet critera in the depressed mood screener
	generate `CIDIAnhedScreen' = .
	replace `CIDIAnhedScreen' = 1 if (`c167' == 1) & inlist(`c168',1,2) & inlist(`c169',1,2) // = 1 if they report anhedonia for 2+ weeks in past year (`c167') for at least most of the day (`c168') at least almost every day (`c169')
	replace `CIDIAnhedScreen' = 0 if (`c167' != . & `c167' != 1) // = 0 if their response is not missing to whether they felt anhedonia in the past year and their response is not "yes"
	replace `CIDIAnhedScreen' = 0 if (`c168' != .) & !inlist(`c168',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIAnhedScreen' = 0 if (`c169' != .) & !inlist(`c169',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIAnhedScreen' == 1

	* Making sure nobody is in BOTH screening groups
	count if `CIDIDepScreen' == 1 & `CIDIAnhedScreen' == 1 // should = 0

	* Overall variable to indiciate whether they met screening criteria in either of the modules
	generate `CIDIScreen' = .
	replace `CIDIScreen' = 1 if (`CIDIDepScreen' == 1 | `CIDIAnhedScreen' == 1)
	replace `CIDIScreen' = 0 if (`CIDIDepScreen' == 0 & `CIDIAnhedScreen' == 0)
	count if `CIDIScreen' == 1 // should = CIDIDepScreen + CIDIAnhedScreen

	******************************************************************************
	* CIDI sum score

	* Recode c153-161: FIRST BRANCH OF QUESTIONS 
	* first branch of questions for those who got them; that is those who met the depressed mood screening criteria
	* the conditional `CIDIDepScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	gen `c150recode' = (`c150' == 1) if `CIDIDepScreen' == 1 // Depressed mood
	gen `c153recode' = (`c153' == 1) if `CIDIDepScreen' == 1 // Anhedonia 
	gen `c154recode' = (`c154' == 1) if `CIDIDepScreen' == 1 // Feel tired 
	gen `c155recode' = (`c155' == 1 | `c156' == 1) if `CIDIDepScreen' == 1 // Appetite symptom: either lose appetite (`c155) or increase appetite (`c156)
	gen `c157recode' = (`c157' == 1 & inlist(`c158',1,2)) if `CIDIDepScreen' == 1 // Trouble sleep: "Yes" to probing question (`c157) AND frequency (`c158) is nearly every night or every night
	gen `c159recode' = (`c159' == 1) if `CIDIDepScreen' == 1 // Trouble concentrating
	gen `c160recode' = (`c160' == 1) if `CIDIDepScreen' == 1 // Feel down on yourself 
	gen `c161recode' = (`c161' == 1) if `CIDIDepScreen' == 1 // Thoughts of death 

	* Recode c170-177: SECOND BRANCH OF QUESTIONS 
	* second branch of questions for those who got them; that is those who met the anhedonia screening criteria
	* the conditional `CIDIAnhedScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	replace `c150recode' = 0 if `CIDIAnhedScreen' == 1 // Depressed mood; ALWAYS 0 for those in the anhedonia branch, they are in that branch because they did not meet the depressed mood criteria
	gen `c167recode' = (`c167' == 1) if `CIDIAnhedScreen' == 1 // Anhedonia 
	gen `c170recode' = (`c170' == 1) if `CIDIAnhedScreen' == 1 // Feel tired 
	gen `c171recode' = (`c171' == 1 | `c172' == 1) if `CIDIAnhedScreen' == 1 // Appetite symptom: either lose appetite (`c171) or increase appetite (`c172)
	gen `c173recode' = (`c173' == 1 & inlist(`c174',1,2)) if `CIDIAnhedScreen' == 1 // Trouble sleep: "Yes" to probing question (`c173) AND frequency (`c174) is nearly every night or every night
	gen `c175recode' = (`c175' == 1) if `CIDIAnhedScreen' == 1 // Trouble concentrating
	gen `c176recode' = (`c176' == 1) if `CIDIAnhedScreen' == 1 // Feel down on yourself 
	gen `c177recode' = (`c177' == 1) if `CIDIAnhedScreen' == 1 // Thoughts of death 

	* Find sum for each branch of questions
	* This includes the same 8 symptoms for each branch
	* Note that those in the anhed_branch should NEVER get a score of 8, their max should be 7; they are in the anhed_branch BECAUSE they didn't meet the screening criteria for depressed mood so got a 0 on that
	egen `DepBranchSum' = rowtotal(`c150recode' `c153recode' `c154recode' `c155recode' `c157recode' `c159recode' `c160recode' `c161recode') if `CIDIDepScreen' == 1
	egen `AnhedBranchSum' = rowtotal(`c150recode' `c167recode' `c170recode' `c171recode' `c173recode' `c175recode' `c176recode' `c177recode') if `CIDIAnhedScreen' == 1

	* CIDI Sumscore (`CIDIsum')
	gen `CIDIsum' = .
	replace `CIDIsum' = `DepBranchSum' if `CIDIDepScreen' == 1
	replace `CIDIsum' = `AnhedBranchSum' if `CIDIAnhedScreen' == 1

	* Anyone who doesn't meet screening criteria gets a score of 0
	replace `CIDIsum' = 0 if `CIDIScreen' == 0

	* Final CIDIsum variable
	tab `CIDIsum'
	tab `CIDIsum' if `CIDIScreen' == 1
	count if `CIDIsum' > 0 & `CIDIsum' < 9

	* Major Depressive Episode indicator variable
	gen `CIDImde' = .
	replace `CIDImde' = 1 if `CIDIsum' >= 5 & `CIDIsum' < 9
	replace `CIDImde' = 0 if `CIDIsum' < 5
	tab `CIDImde'

}

******************************************************************************
******************************************************************************
* Wave 2002 (h) through 2020 (r) (there is no wave i)

******************************************************************************
* Loop Setup

* Starting the loop; wave is denoted by the prefix (e.g., "r" is 2020)
foreach wave in h j k l m n o p q r {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	* Defining each variable that will be looped through; 
	* dep screen questions
	local c150 = "`wave'c150" // felt depressed in past yr - dep screen
	local c151 = "`wave'c151" // depressed what portion of day - dep screen
	local c152 = "`wave'c152" // depressed every day - dep screen

	* dep branch questions
	local c153 = "`wave'c153" // loss of interest - dep branch
	local c154 = "`wave'c154" // feeling tired - dep branch
	local c155 = "`wave'c155" // lose appetite - dep branch
	local c156 = "`wave'c156" // appetite increase - dep branch
	local c157 = "`wave'c157" // trouble fall asleep - dep branch
	local c158 = "`wave'c158" // freq of trouble falling asleep - dep branch
	local c159 = "`wave'c159" // trouble concentrating - dep branch
	local c160 = "`wave'c160" // feeling down on yourself - dep branch
	local c161 = "`wave'c161" // thoughts about death - dep branch

	* anhed screen questions
	local c167 = "`wave'c167" // lose interest - anhed screen
	local c168 = "`wave'c168" // lose interest what portion of day - anhed screen
	local c169 = "`wave'c169" // lose interest every day - anhed screen

	* anhed branch questions
	local c170 = "`wave'c170" // feeling tired - anhed branch
	local c171 = "`wave'c171" // lost appetite - anhed branch
	local c172 = "`wave'c172" // appetite increase - anhed branch
	local c173 = "`wave'c173" // trouble falling asleep - anhed branch
	local c174 = "`wave'c174" // frequency of sleep trouble - anhed branch
	local c175 = "`wave'c175" // trouble concentrate - anhed branch
	local c176 = "`wave'c176" // feeliing down on oneself - anhed branch
	local c177 = "`wave'c177" // interest in death - anhed branch

	* screening indicator variables
	local CIDIDepScreen = "CIDIDepScreen_`wave'"
	local CIDIAnhedScreen = "CIDIAnhedScreen_`wave'"
	local CIDIScreen = "CIDIScreen_`wave'"

	* presence of symptom recode variables
	local c150recode = "`wave'c150recode"
	local c153recode = "`wave'c153recode"
	local c154recode = "`wave'c154recode"
	local c155recode = "`wave'c155recode"
	local c157recode = "`wave'c157recode"
	local c159recode = "`wave'c159recode"
	local c160recode = "`wave'c160recode"
	local c161recode = "`wave'c161recode"
	local c167recode = "`wave'c167recode"
	local c170recode = "`wave'c170recode"
	local c171recode = "`wave'c171recode"
	local c173recode = "`wave'c173recode"
	local c175recode = "`wave'c175recode"
	local c176recode = "`wave'c176recode"
	local c177recode = "`wave'c177recode"

	* summing symptom score variables
	local DepBranchSum = "DepBranchSum_`wave'"
	local AnhedBranchSum = "AnhedBranchSum_`wave'"
	local CIDIsum_check = "CIDIsum_check_`wave'"
	local CIDIsum = "CIDIsum_`wave'"
	local CIDImde = "CIDImde_`wave'"
		
	******************************************************************************
	* CIDI Screening

	* Whether they met criteria for further symptom questions in cidi
	* Must meet EITHER depressed mood or anhedonia screening criteria
	* If meet depressed mood screening criteria, not screened for anhedonia (but are asked a question if they felt anhedonia) 

	* how many cases should we expect for the CIDIDepScreen? 
	count if `c150' == 1 & (`c151' == 1 | `c151' == 2) & (`c152' == 1 | `c152' == 2) // this number should match CIDIDepScreen == 1

	* Depressed mood screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	generate `CIDIDepScreen' = .
	replace `CIDIDepScreen' = 1 if (`c150' == 1) & inlist(`c151',1,2) & inlist(`c152',1,2) // = 1 if they report depressed mood for 2+ weeks in past year (`c150') for at least most of the day (`c151') at least almost every day (`c152')
	replace `CIDIDepScreen' = 0 if (`c150' != . & `c150' != 1) // = 0 if their response is not missing to whether they felt depressed mood in the past year and their response is not "yes"
	replace `CIDIDepScreen' = 0 if (`c151' != .) & !inlist(`c151',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIDepScreen' = 0 if (`c152' != .) & !inlist(`c152',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIDepScreen' == 1

	* how many cases should we expect for the CIDIAnhedScreen? 
	count if `c167' == 1 & (`c168' == 1 | `c168' == 2) & (`c169' == 1 | `c169' == 2) // this number should match CIDIAnhedScreen == 1

	* Anhedonia screen; 1 =  met criteria to continue; 0 = did not meet criteria; NA = did not get screened (or didn't respond)
	* Only screened for this if did not meet critera in the depressed mood screener
	generate `CIDIAnhedScreen' = .
	replace `CIDIAnhedScreen' = 1 if (`c167' == 1) & inlist(`c168',1,2) & inlist(`c169',1,2) // = 1 if they report anhedonia for 2+ weeks in past year (`c167') for at least most of the day (`c168') at least almost every day (`c169')
	replace `CIDIAnhedScreen' = 0 if (`c167' != . & `c167' != 1) // = 0 if their response is not missing to whether they felt anhedonia in the past year and their response is not "yes"
	replace `CIDIAnhedScreen' = 0 if (`c168' != .) & !inlist(`c168',1,2) // = 0 if their response to portion of day question is not missing and their response is not "all day" or "most of the day"
	replace `CIDIAnhedScreen' = 0 if (`c169' != .) & !inlist(`c169',1,2) // = 0 if their response to frequency question is not missing and their response is not "every day" or "almost every day"
	count if `CIDIAnhedScreen' == 1

	* Making sure nobody is in BOTH screening groups
	count if `CIDIDepScreen' == 1 & `CIDIAnhedScreen' == 1 // should = 0

	* Overall variable to indiciate whether they met screening criteria in either of the modules
	generate `CIDIScreen' = .
	replace `CIDIScreen' = 1 if (`CIDIDepScreen' == 1 | `CIDIAnhedScreen' == 1)
	replace `CIDIScreen' = 0 if (`CIDIDepScreen' == 0 & `CIDIAnhedScreen' == 0)
	count if `CIDIScreen' == 1 // should = CIDIDepScreen + CIDIAnhedScreen

	******************************************************************************
	* CIDI sum score

	* Recode c153-161: FIRST BRANCH OF QUESTIONS 
	* first branch of questions for those who got them; that is those who met the depressed mood screening criteria
	* the conditional `CIDIDepScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	gen `c150recode' = (`c150' == 1) if `CIDIDepScreen' == 1 // Depressed mood
	gen `c153recode' = (`c153' == 1) if `CIDIDepScreen' == 1 // Anhedonia 
	gen `c154recode' = (`c154' == 1) if `CIDIDepScreen' == 1 // Feel tired 
	gen `c155recode' = (`c155' == 1 | `c156' == 1) if `CIDIDepScreen' == 1 // Appetite symptom: either lose appetite (`c155) or increase appetite (`c156)
	gen `c157recode' = (`c157' == 1 & inlist(`c158',1,2)) if `CIDIDepScreen' == 1 // Trouble sleep: "Yes" to probing question (`c157) AND frequency (`c158) is nearly every night or every night
	gen `c159recode' = (`c159' == 1) if `CIDIDepScreen' == 1 // Trouble concentrating
	gen `c160recode' = (`c160' == 1) if `CIDIDepScreen' == 1 // Feel down on yourself 
	gen `c161recode' = (`c161' == 1) if `CIDIDepScreen' == 1 // Thoughts of death 

	* Recode c170-177: SECOND BRANCH OF QUESTIONS 
	* second branch of questions for those who got them; that is those who met the anhedonia screening criteria
	* the conditional `CIDIAnhedScreen' == 1 is likely unnecessary but doesn't hurt to include
	* this recodes into 1 if the symptom is present, 0 if it is not
	replace `c150recode' = 0 if `CIDIAnhedScreen' == 1 // Depressed mood; ALWAYS 0 for those in the anhedonia branch, they are in that branch because they did not meet the depressed mood criteria
	gen `c167recode' = (`c167' == 1) if `CIDIAnhedScreen' == 1 // Anhedonia 
	gen `c170recode' = (`c170' == 1) if `CIDIAnhedScreen' == 1 // Feel tired 
	gen `c171recode' = (`c171' == 1 | `c172' == 1) if `CIDIAnhedScreen' == 1 // Appetite symptom: either lose appetite (`c171) or increase appetite (`c172)
	gen `c173recode' = (`c173' == 1 & inlist(`c174',1,2)) if `CIDIAnhedScreen' == 1 // Trouble sleep: "Yes" to probing question (`c173) AND frequency (`c174) is nearly every night or every night
	gen `c175recode' = (`c175' == 1) if `CIDIAnhedScreen' == 1 // Trouble concentrating
	gen `c176recode' = (`c176' == 1) if `CIDIAnhedScreen' == 1 // Feel down on yourself 
	gen `c177recode' = (`c177' == 1) if `CIDIAnhedScreen' == 1 // Thoughts of death 

	* Find sum for each branch of questions
	* This includes the same 8 symptoms for each branch
	* Note that those in the anhed_branch should NEVER get a score of 8, their max should be 7; they are in the anhed_branch BECAUSE they didn't meet the screening criteria for depressed mood so got a 0 on that
	egen `DepBranchSum' = rowtotal(`c150recode' `c153recode' `c154recode' `c155recode' `c157recode' `c159recode' `c160recode' `c161recode') if `CIDIDepScreen' == 1
	egen `AnhedBranchSum' = rowtotal(`c150recode' `c167recode' `c170recode' `c171recode' `c173recode' `c175recode' `c176recode' `c177recode') if `CIDIAnhedScreen' == 1

	* CIDI Sumscore (`CIDIsum')
	gen `CIDIsum' = .
	replace `CIDIsum' = `DepBranchSum' if `CIDIDepScreen' == 1
	replace `CIDIsum' = `AnhedBranchSum' if `CIDIAnhedScreen' == 1

	* Anyone who doesn't meet screening criteria gets a score of 0
	replace `CIDIsum' = 0 if `CIDIScreen' == 0

	* Final CIDIsum variable
	tab `CIDIsum'
	tab `CIDIsum' if `CIDIScreen' == 1
	count if `CIDIsum' > 0 & `CIDIsum' < 9

	* Major Depressive Episode indicator variable
	gen `CIDImde' = .
	replace `CIDImde' = 1 if `CIDIsum' >= 5 & `CIDIsum' < 9
	replace `CIDImde' = 0 if `CIDIsum' < 5
	tab `CIDImde'

}

******************************************************************************
******************************************************************************
* How many respondents were screened for CIDI-SF depression in each year?

local CIDIScreen_variables CIDIScreen_d CIDIScreen_e CIDIScreen_f CIDIScreen_g CIDIScreen_h CIDIScreen_j CIDIScreen_k CIDIScreen_l CIDIScreen_m CIDIScreen_n CIDIScreen_o CIDIScreen_p CIDIScreen_q CIDIScreen_r

foreach var of local CIDIScreen_variables {
	tabulate `var'
}

* These waves are off because before 2008, the CIDI was only given to respondents when they entered HRS, not every year. 
* 1998 (wave f) seems off: there were 21,384 respondents in the file but only 4,745 were screened
* 2000 (wave g) seems off: there were 19,578 respondents in the file but only 204 were screened
* 2002 (wave h) seems off: there were 18,165 respondents in the file but only 191 were screened
* 2004 (wave j) seems off: there were 20,129 respondents in the file but only 3,261 were screened
* 2006 (wave k) seems off: there were 18,469 respondents in the file but only 179 were screened

local CIDImde_variables CIDImde_d CIDImde_e CIDImde_f CIDImde_g CIDImde_h CIDImde_j CIDImde_k CIDImde_l CIDImde_m CIDImde_n CIDImde_o CIDImde_p CIDImde_q CIDImde_r

foreach var of local CIDImde_variables {
	tabulate `var'
}

******************************************************************************
******************************************************************************
* Now, recoding variables into the RAND suffix format (where a number takes place of the wave letter and early waves are combined)

* looping through each variable and each wave (starting at wave e and 3)
foreach var in CIDIDepScreen CIDIAnhedScreen CIDIScreen DepBranchSum AnhedBranchSum CIDIsum CIDImde {
	local counter = 3
	foreach wave in e f g h j k l m n o p q r {
		display "variable `var' and wave 'wave'"
		gen `var'_`counter' = `var'_`wave'
		local counter = `counter' + 1
	}
}

* Now, replacing the third wave of data with the wave denoted by a _d IF the third wave wasn't populated already (in the case data was pulled from e) and if there is data for wave d
foreach var in CIDIDepScreen CIDIAnhedScreen CIDIScreen DepBranchSum AnhedBranchSum CIDIsum CIDImde {
	replace `var'_3 = `var'_d if missing(`var'_3) & !missing(`var'_d)	
}

* checking that this all worked
tab CIDIDepScreen_d
tab CIDIDepScreen_e
tab CIDIDepScreen_3

tab CIDImde_d
tab CIDImde_e
tab CIDImde_3

tab CIDIDepScreen_m
tab CIDIDepScreen_10

tab CIDImde_m
tab CIDImde_10

tab CIDIDepScreen_r
tab CIDIDepScreen_15

tab CIDImde_r
tab CIDImde_15


******************************************************************************
******************************************************************************
******************************************************************************

save "HRS_RAND_allyears_trimmed_merged_CIDI.dta", replace
