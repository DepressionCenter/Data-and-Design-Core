/* 

NOTE:

Author: Emily Urban-Wojcik, emurbanw@med.umich.edu
Date: March 10, 2026

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
2) Stack RAND-cleaned UCLA loneliness scores from 2014 and 2016 (given 1/2 sample assessment at each wave)
3) Loop through two waves of HRS data (2014 and 2016) to create an objective Isolation / Disconnection index
4) Stack new Isolation index scores from 2014 and 2016

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

tab r12lbcomp // n that completed 2014 leave behind
tab r13lbcomp // n that completed 2016 leave behind

******************************************************************************
******************************************************************************
******************************************************************************
* Stack UCLA Loneliness scale (11 item)
******************************************************************************
******************************************************************************
******************************************************************************

/* 

Computing new loneliness variable stacking 2014 & 2016 data
Scores range from 1-3; This is the average of the 11 items. Final score is missing if more than 5 items were missing. 
Higher scores = more loneliness

*/

* renaming leave behind completed var to match RAND naming conventions
rename r12lbcomp olbcomp
rename r13lbcomp plbcomp

summarize r13lblonely11 if plbcomp == 1 
summarize r12lblonely11 if (missing(r13lblonely11) & olbcomp == 1) 

generate lonely = .
replace lonely = r13lblonely11 if plbcomp == 1
summarize lonely 

replace lonely = r12lblonely11 if missing(lonely) & olbcomp == 1
summarize lonely 

* Creating an indicator of which wave loneliness data came from (0 = 2014, 1 = 2016)
generate lonely_wv = 1 if (!missing(r13lblonely11) & plbcomp == 1)
replace lonely_wv = 0 if (missing(r13lblonely11) & !missing(r12lblonely11) & olbcomp == 1)
tab lonely_wv

******************************************************************************
******************************************************************************
******************************************************************************
* Computing Social Isolation / Disconnection Index
******************************************************************************
******************************************************************************
******************************************************************************

* renaming number of children to match RAND naming conventions
rename h12child ochild
rename h13child pchild

* renaming num household residents to match RAND naming conventions
rename h12hhres ohhres
rename h13hhres phhres

* renaming marital status to match RAND naming conventions
rename r12mstat omstat
rename r13mstat pmstat

* Looping through waves o (2014) and p (2016)
foreach wave in o p {

	* Print which wave we're working on
	display "Looping through wave `wave'"

	*************************************
	* Defining each variable that will be looped through; 
	
	local lbcomp = "`wave'lbcomp" // whether they completed the leave-behind portion of the wave
	
	* Social ties
	local children = "`wave'child" // have any living children
	local family = "`wave'lb010" // have any other immediate family
	local friends = "`wave'lb014" // have any friends	
	local mstat = "`wave'mstat" // current marital status
	local num_ppl_hh = "`wave'hhres" // number of people in household
	
	* Activities
	local activity1 = "`wave'lb001b" // activities w/ younger generation
	local activity2 = "`wave'lb001c" // volunteer with children
	local activity3 = "`wave'lb001d" // volunteer/charity work
	local activity4 = "`wave'lb001e" // attend courses
	local activity5 = "`wave'lb001f" // go to sport, social, other club
	local activity6 = "`wave'lb001g" // attend meeting of non-religious interest group
	local activity7 = "`wave'lb001u" // participate in community art group
	local activity8 = "`wave'b082" // participate in religious event
	
	* Communication with children
	local meetchild = "`wave'lb008a" // how often do you meet up with child
	local phonechild = "`wave'lb008b" // how often do you speak on phone with child
	local writechild = "`wave'lb008c" // how often do you write or email child
	local socmedchild = "`wave'lb008d" // how often do you communicate by skype, facebook, or other social media with child

	* Communication with other family
	local meetfamily = "`wave'lb012a" // how often do you meet up with other family
	local phonefamily = "`wave'lb012b" // how often do you speak on phone with other family
	local writefamily = "`wave'lb012c" // how often do you write or email with other family
	local socmedfamily = "`wave'lb012d" // how often do you communicate by skype, facebook, or other social media with other family

	* Communication with friends
	local meetfriends = "`wave'lb016a" // how often do you meet up with friends
	local phonefriends = "`wave'lb016b" // how often do you speak on phone with friends
	local writefriends = "`wave'lb016c" // how often do you write or email friends
	local socmedfriends = "`wave'lb016d" // how often do you communicate by skype, facebook, or other social media with friends

	*************************************
	* Wave-specific OUTPUT variable names

	* Social ties (binary indicators)
	local no_children        "no_children_`wave'"
	local no_family          "no_family_`wave'"
	local no_friends         "no_friends_`wave'"
	local no_partner         "no_partner_`wave'"
	local lives_alone		 "lives_alone_`wave'"

	* Activities (binary participation indicators)
	local yes_activity1      "yes_activity1_`wave'"
	local yes_activity2      "yes_activity2_`wave'"
	local yes_activity3      "yes_activity3_`wave'"
	local yes_activity4      "yes_activity4_`wave'"
	local yes_activity5      "yes_activity5_`wave'"
	local yes_activity6      "yes_activity6_`wave'"
	local yes_activity7      "yes_activity7_`wave'"
	local yes_activity8      "yes_activity8_`wave'"
	
	* Activities (binary participation indicators)
	local num_social_activities     "num_social_activities_`wave'"
	local few_activities		    "low_social_activities_`wave'"

	* Median scalars
	local p50_child_con      "p50_child_con_`wave'"
	local p50_family_con     "p50_family_con_`wave'"
	local p50_friends_con    "p50_friends_con_`wave'"

	* Communication summaries
	local mean_child_con	"mean_child_con_`wave'"
	local mean_family_con	"mean_family_con_`wave'"
	local mean_friends_con	"mean_friends_con_`wave'"
	local n_child_items		"n_child_items_`wave'"
	local n_family_items	"n_family_items_`wave'"
	local n_friends_items	"n_friends_items_`wave'"

	* Low contact indicators (Median level)
	local p50_low_child_con      "p50_low_child_con_`wave'"
	local p50_low_family_con     "p50_low_family_con_`wave'"
	local p50_low_friends_con    "p50_low_friends_con_`wave'"

	* Final isolation score
	local n_isolation_items	 "n_isolation_items_`wave'"
	local isolation_sum		 "isolation_sum_`wave'"
	local isolation          "isolation_`wave'"
	local alt_isolation_sum	 "alt_isolation_sum_`wave'"
	local alt_isolation      "alt_isolation_`wave'"
	
	*************************************
	*************************************
	*************************************
	
	tab `lbcomp'
	
	* Recoding each item
	* No_children: re-coding to 0 = yes children, 1 = no children
	* Originally 1 = yes have children, 5 = no children; 
	tab `children'
	generate `no_children' = .
	replace `no_children' = 0 if `children' > 0 & !missing(`children')
	replace `no_children' = 1 if `children' == 0 
	tab `no_children'
	
	* No_family: re-coding to 0 = yes other, 1 = no other family
	* Originally 1 = yes have other family, 5 = no other family; 
	tab `family'
	generate `no_family' = .
	replace `no_family' = 0 if `family' == 1
	replace `no_family' = 1 if `family' == 5
	tab `no_family'

	* No_friends: re-coding to 0 = yes friends, 1 = no friends
	* Originally 1 = yes have friends, 5 = no friends;
	tab `friends'
	generate `no_friends' = .
	replace `no_friends' = 0 if `friends' == 1
	replace `no_friends' = 1 if `friends' == 5
	tab `no_friends'
	
	* Not partnered: 0 = married or partnered; 1 = other status
	* Originally 1 = married/partnered, 2 = married spouse absent, 3 = partnered, 4 = separated, 5 = divorced, 6 = separated/divorced, 7 = widowed 8 = never married
	tab `mstat' if `lbcomp' == 1
	generate `no_partner' = .
	replace `no_partner' = 0 if inlist(`mstat', 1, 2, 3) & `lbcomp' == 1
	replace `no_partner' = 1 if inlist(`mstat', 4, 5, 6, 7, 8) & `lbcomp' == 1
	tab `no_partner'
	
	* Lives alone: 0 = 2 or more residents; 1 = 1 resident
	tab `num_ppl_hh' if `lbcomp' == 1
	generate `lives_alone' = .
	replace `lives_alone' = 1 if `num_ppl_hh' == 1 & `lbcomp' == 1
	replace `lives_alone' = 0 if `num_ppl_hh' > 1 & !missing(`num_ppl_hh') & `lbcomp' == 1
	tab `lives_alone'
	
	*************************************
	
	* For each acitivity, if they participate in each activity at least ONCE A MONTH, they get a 1
	* Originally 1 = daily, 2 = several times a week, 3 = once a week, 4 = several times a month, 5 = at least once a month, 6 = not in the last month, 7 = never/not relevant
	tab `activity1'
	generate `yes_activity1' = .
	replace `yes_activity1' = 0 if inlist(`activity1', 6, 7)
	replace `yes_activity1' = 1 if inlist(`activity1', 1, 2, 3, 4, 5)
	tab `yes_activity1'
	
	tab `activity2'
	generate `yes_activity2' = .
	replace `yes_activity2' = 0 if inlist(`activity2', 6, 7)
	replace `yes_activity2' = 1 if inlist(`activity2', 1, 2, 3, 4, 5)
	tab `yes_activity2'
	
	tab `activity3'
	generate `yes_activity3' = .
	replace `yes_activity3' = 0 if inlist(`activity3', 6, 7)
	replace `yes_activity3' = 1 if inlist(`activity3', 1, 2, 3, 4, 5)
	tab `yes_activity3'
	
	tab `activity4'
	generate `yes_activity4' = .
	replace `yes_activity4' = 0 if inlist(`activity4', 6, 7)
	replace `yes_activity4' = 1 if inlist(`activity4', 1, 2, 3, 4, 5)
	tab `yes_activity4'
	
	tab `activity5'
	generate `yes_activity5' = .
	replace `yes_activity5' = 0 if inlist(`activity5', 6, 7)
	replace `yes_activity5' = 1 if inlist(`activity5', 1, 2, 3, 4, 5)
	tab `yes_activity5'
	
	tab `activity6'
	generate `yes_activity6' = .
	replace `yes_activity6' = 0 if inlist(`activity6', 6, 7)
	replace `yes_activity6' = 1 if inlist(`activity6', 1, 2, 3, 4, 5)
	tab `yes_activity6'
	
	tab `activity7'
	generate `yes_activity7' = .
	replace `yes_activity7' = 0 if inlist(`activity7', 6, 7)
	replace `yes_activity7' = 1 if inlist(`activity7', 1, 2, 3, 4, 5)
	tab `yes_activity7'
	
	* Because activity 8 came from the core interview, we have to score it a bit differently than the other activities.
	* More poeple in our sample will have a score for this variable because it was in the core interview
	* We only want scores for people who took these measures, so requiring them to have `lbcomp' == 1
	* For activity8, 1 = more than once a week, 2 = once a week, 3 = 2-3x/month, 4= one or more times a year, 5 = not at all, 8 = Don't know/NA, 9 = Refused
	tab `activity8' if `lbcomp' == 1
	generate `yes_activity8' = .
	replace `yes_activity8' = 0 if inlist(`activity8', 4, 5, 8, 9) & `lbcomp' == 1
	replace `yes_activity8' = 1 if inlist(`activity8', 1, 2, 3) & `lbcomp' == 1
	tab `yes_activity8'
	
	* Now summing number of activities (of 8 activities) they participate in at least once a month
	egen `num_social_activities' = rowtotal(`yes_activity1' `yes_activity2' `yes_activity3' `yes_activity4' `yes_activity5' `yes_activity6' `yes_activity7' `yes_activity8') if `lbcomp' == 1
	tab `num_social_activities'
	
	* Now creating a variable that is 1 if they didn't participate in any of the 8 activities at least once a month
	generate `few_activities' = .
	replace `few_activities' = 0 if `num_social_activities' > 0 & !missing(`num_social_activities') & `lbcomp' == 1
	replace `few_activities' = 1 if `num_social_activities' == 0 & `lbcomp' == 1
	tab `few_activities'
	
	*************************************
	
	* Low contact: Defined as the worst median compared to the rest of the sample
	
	* Because higher mean score = less contact, set low_*_con = 1 if mean score is at or above the 50th percentile (worse contact), else 0.
	* Mean scores are set to missing if they are missing more than one of the four contact items (must have at least 3 of 4 to have a valid score)
	* Originally 1 = 3 or more times per week, 2 = once or twice a week, 3 = once or twice a month, 4 = every few months, 5 = once or twice a year, 6 = less than once a year or never
	* Because original scores higher = less contact, new variable (of having low contact) is 1 if mean score is at or above the 50th percentile
	* Participants who reported having no ties (e.g., no child, no other family, no friends) get a 1 for the new variable because they don't have that form of contact
	tab `meetchild'
	tab `phonechild'
	tab `writechild'
	tab `socmedchild'
	tab `no_children' if `lbcomp' == 1, missing
	egen `n_child_items'= rownonmiss(`meetchild' `phonechild' `writechild' `socmedchild') if (`lbcomp'==1 & `no_children'==0)
	tab `n_child_items'
	egen `mean_child_con' = rowmean(`meetchild' `phonechild' `writechild' `socmedchild') if (`lbcomp'==1 & `no_children'==0)
	summarize `mean_child_con' if `no_children' == 0 & `lbcomp'==1, detail
	scalar `p50_child_con' = r(p50) // top half = worst (least frequent) contact
	display "50th percentile (worst half) child contact (`wave'): " scalar(`p50_child_con')
	generate `p50_low_child_con' = .
	* Has children + LB complete: 1 if worst half (>= p50), else 0
	replace `p50_low_child_con' = 0 if `mean_child_con' < `p50_child_con' & !missing(`mean_child_con')
	replace `p50_low_child_con' = 1 if `mean_child_con' >= `p50_child_con' & !missing(`mean_child_con')
	* No children -> low contact = 1
	replace `p50_low_child_con' = 1 if `no_children' == 1 & `lbcomp' == 1
	tab `p50_low_child_con'
	tab `p50_low_child_con' if `no_children' == 1 & `lbcomp' == 1 // all should be 1
	tab `p50_low_child_con' if `no_children' == 0 & `lbcomp' == 1
	summ `mean_child_con' if `p50_low_child_con'==0 & `no_children'==0 & `lbcomp' == 1
	summ `mean_child_con' if `p50_low_child_con'==1 & `no_children'==0 & `lbcomp' == 1
	
	tab `meetfamily'
	tab `phonefamily'
	tab `writefamily'
	tab `socmedfamily'
	tab `no_family'
	egen `n_family_items'= rownonmiss(`meetfamily' `phonefamily' `writefamily' `socmedfamily') if (`lbcomp'==1 & `no_family'==0)
	tab `n_family_items'
	egen `mean_family_con' = rowmean(`meetfamily' `phonefamily' `writefamily' `socmedfamily') if (`lbcomp'==1 & `no_family'==0)
	summarize `mean_family_con' if `no_family' == 0 & `lbcomp' == 1, detail
	scalar `p50_family_con' = r(p50) // top half = worst (least frequent) contact
	display "50th percentile (worst half) family contact (`wave'): " scalar(`p50_family_con')
	generate `p50_low_family_con' = .
	* Has family + LB complete: 1 if worst half (>= p50), else 0
	replace `p50_low_family_con' = 0 if `mean_family_con' < `p50_family_con' & !missing(`mean_family_con')
	replace `p50_low_family_con' = 1 if `mean_family_con' >= `p50_family_con' & !missing(`mean_family_con')
	* No family -> low contact = 1
	replace `p50_low_family_con' = 1 if `no_family' == 1 & `lbcomp' == 1
	tab `p50_low_family_con'
	tab `p50_low_family_con' if `no_family' == 1 & `lbcomp' == 1 // all should be 1
	tab `p50_low_family_con' if `no_family' == 0 & `lbcomp' == 1
	summ `mean_family_con' if `p50_low_family_con'==0 & `no_family'==0 & `lbcomp' == 1
	summ `mean_family_con' if `p50_low_family_con'==1 & `no_family'==0 & `lbcomp' == 1
	
	tab `meetfriends'
	tab `phonefriends'
	tab `writefriends'
	tab `socmedfriends'
	tab `no_friends'
	egen `n_friends_items'= rownonmiss(`meetfriends' `phonefriends' `writefriends' `socmedfriends') if (`lbcomp'==1 & `no_friends'==0)
	tab `n_friends_items'
	egen `mean_friends_con' = rowmean(`meetfriends' `phonefriends' `writefriends' `socmedfriends') if (`lbcomp'==1 & `no_friends'==0)
	summarize `mean_friends_con' if `no_friends' == 0 & `lbcomp' == 1, detail
	scalar `p50_friends_con' = r(p50) // top half = worst (least frequent) contact
	display "50th percentile (worst half) friends contact (`wave'): " scalar(`p50_friends_con')
	generate `p50_low_friends_con' = .
	* Has friends + LB complete: 1 if worst half (>= p50), else 0
	replace `p50_low_friends_con' = 0 if `mean_friends_con' < `p50_friends_con' & !missing(`mean_friends_con')
	replace `p50_low_friends_con' = 1 if `mean_friends_con' >= `p50_friends_con' & !missing(`mean_friends_con')
	* No friends -> low contact = 1
	replace `p50_low_friends_con' = 1 if `no_friends' == 1 & `lbcomp' == 1
	tab `p50_low_friends_con'
	tab `p50_low_friends_con' if `no_friends' == 1 & `lbcomp' == 1 // all should be 1
	tab `p50_low_friends_con' if `no_friends' == 0 & `lbcomp' == 1
	summ `mean_friends_con' if `p50_low_friends_con'==0 & `no_friends'==0 & `lbcomp' == 1
	summ `mean_friends_con' if `p50_low_friends_con'==1 & `no_friends'==0 & `lbcomp' == 1
		
	*************************************
	* Finally, summing each indicator of isolation, then dividing by the total number of indicators they have data for
	tab `no_partner'
	tab `lives_alone'
	tab `p50_low_child_con'
	tab `p50_low_family_con'
	tab `p50_low_friends_con'
	tab `few_activities'
	
	egen `n_isolation_items'= rownonmiss(`no_partner' `lives_alone' `p50_low_child_con' `p50_low_family_con' `p50_low_friends_con' `few_activities') if (`lbcomp'==1)
	tab `n_isolation_items'
	
	* Summing all available isolation indicators
	egen `isolation_sum' = rowtotal(`no_partner' `lives_alone' `p50_low_child_con' `p50_low_family_con' `p50_low_friends_con' `few_activities') if `lbcomp' == 1
	tab `isolation_sum'

	* Final isolation variable (proportion 0-1); must have at least half of isolation indicators (3 or more)
	gen `isolation' = .
	replace `isolation' = `isolation_sum' / `n_isolation_items' if `lbcomp' == 1
	replace `isolation' = . if `lbcomp'==1 & `n_isolation_items' < 3
	summ `isolation'
	
}


******************************************************************************
******************************************************************************
******************************************************************************
* Stacking Social Isolation / Disconnection Index score between 2014 and 2016
******************************************************************************
******************************************************************************
******************************************************************************

* Creating a single n_isolation_items variable
generate n_isolation_items = .
replace n_isolation_items = n_isolation_items_p if plbcomp == 1
summarize n_isolation_items 
replace n_isolation_items = n_isolation_items_o if missing(n_isolation_items) & olbcomp == 1
summarize n_isolation_items 

* Creating an indicator of whether a respondent is missing any items on the isolation index (FOR COVARIATE IN ANALYSIS)
generate missing_iso_items = .
replace missing_iso_items = 1 if n_isolation_items < 6
replace missing_iso_items = 0 if n_isolation_items == 6
tab missing_iso_items
tab n_isolation_items if missing_iso_items == 1 // check that everyone has at least 3 of the 6 items

* Creating a single isolation_sum variable
summarize isolation_sum_p if plbcomp == 1 
summarize isolation_sum_o if (missing(isolation_sum_p) & olbcomp == 1) 
generate isolation_sum = .
replace isolation_sum = isolation_sum_p if plbcomp == 1
summarize isolation_sum 
replace isolation_sum = isolation_sum_o if missing(isolation_sum) & olbcomp == 1
summarize isolation_sum 

* Creating a single isolation variable (THIS IS THE MAIN VARIABLE FOR ANALYSIS AND IS BASED ON THE PROPORTION OF NON-MISSING ITEMS)
summarize isolation_p if plbcomp == 1 
summarize isolation_o if (missing(isolation_p) & olbcomp == 1) 
generate isolation = .
replace isolation = isolation_p if plbcomp == 1
summarize isolation 
replace isolation = isolation_o if missing(isolation) & olbcomp == 1
summarize isolation 

*************************************
* Comparing proportion scores between group without and group with any missing items on isolation index
* The group with any missing items have LOWER isolation scores than the group without missing items

summ isolation
tabstat isolation, by(missing_iso_items) ///
    stats(n mean sd p25 median p75 min max)
ttest isolation, by(missing_iso_items)
ranksum isolation, by(missing_iso_items)
ksmirnov isolation, by(missing_iso_items)

*************************************

* Creating an indicator of which wave isolation data came from (0 = 2014, 1 = 2016)
generate isolation_wv = 1 if (!missing(isolation_p) & plbcomp == 1)
replace isolation_wv = 0 if (missing(isolation_p) & !missing(isolation_o) & olbcomp == 1)
tab isolation_wv

******************************************************************************
******************************************************************************
******************************************************************************

save "HRS_RAND_allyears_trimmed_merged_LonelyIsolation.dta", replace


























