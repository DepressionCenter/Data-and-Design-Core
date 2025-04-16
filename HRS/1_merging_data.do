
/* 

NOTE:

Author: Emily Urban-Wojcik, emurbanw@med.umich.edu
Date: April 2025

RAND-cleaned HRS data for this script can be downloaded (after registration with HRS) from: https://hrsdata.isr.umich.edu/data-products/rand?_gl=1*13qxjg3*_ga*ODE2NTc1MzUxLjE3NDAxNDkwNTI.*_ga_FF28MW3MW2*MTc0NDcyMjAxOS45LjAuMTc0NDcyMjAxOS4wLjAuMA..

In this script we:
1) Set up our environment
2) Open the RAND HRS longitudinal file, trim to the variables we need, and save a trimmed version
3) Open each RAND HRS fat file, trim to the variables we need, and save a trimmed version
4) Merge the longitudinal and fat files, and save the merged file


*/

******************************************************************************
******************************************************************************
******************************************************************************
* Set-up
******************************************************************************
******************************************************************************
******************************************************************************

* Set your working directory
cd "/Users/emurbanw/OneDrive-MichiganMedicine/OneDriveDocuments/Datasets/HRS"

* There are 17k+ variables in the 2020 longidutindal file, but by default stata only allows 5,000
* Can change maxvar all the up to 32,767 using Stata/SE
set maxvar 20000

******************************************************************************
******************************************************************************
******************************************************************************
* Longitudinal File
******************************************************************************
******************************************************************************
******************************************************************************

* Open the longitudinal file
use HRS_RAND_1992_2020/randhrs1992_2020v2.dta, clear

* list variables we want to keep in our trimmed file
keep hhidpn ragender raedyrs raeduc raracem rahispan hacohort racohbyr rabyear rabmonth rabdate rahrsamp /// demographics and sample cohort variables
raestrat raehsamp r1wtresp r2wtresp r3wtresp r4wtresp r5wtresp r6wtresp r7wtresp r8wtresp r9wtresp r10wtresp r11wtresp r12wtresp r13wtresp r14wtresp r15wtresp /// strata, cluster, and weight variables
r1agey_e r2agey_e r3agey_e r4agey_e r5agey_e r6agey_e r7agey_e r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e r15agey_e /// age at interview end
r1iwend r2iwend r3iwend r4iwend r5iwend r6iwend r7iwend r8iwend r9iwend r10iwend r11iwend r12iwend r13iwend r14iwend r15iwend /// date at interview end
r2cesd r3cesd r4cesd r5cesd r6cesd r7cesd r8cesd r9cesd r10cesd r11cesd r12cesd r13cesd r14cesd r15cesd r1cesdm r2cesdm r3cesdm r4cesdm r5cesdm r6cesdm r7cesdm r8cesdm r9cesdm r10cesdm r11cesdm r12cesdm r13cesdm r14cesdm r15cesdm /// cesd score; number missing items in cesd scale
r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre r9cancre r10cancre r11cancre r12cancre r13cancre r14cancre r15cancre /// ever had cancer
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat r10iwstat r11iwstat r12iwstat r13iwstat r14iwstat r15iwstat /// interview status (responded, no response, etc.)
r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche r9psyche r10psyche r11psyche r12psyche r13psyche r14psyche r15psyche /// ever had psychological problems

* Sort by respondent ID
sort hhidpn

* Save the trimmed data
save "trimmed_files/HRS_RAND_1992_2020_trimmed.dta", replace

******************************************************************************
******************************************************************************
******************************************************************************
* Trimming the fat files to contain only necessary variables
******************************************************************************
******************************************************************************
******************************************************************************

* In each of the below, we first open the wave-specific fatfile, keep variables of interest, sort by respondent ID, and save the trimmed file

use HRS_RAND_2020/h20e2a.dta, clear
keep hhidpn rc018 rc019 rc020 rc021m1 rc021m2 rc021m3 rc021m4 rc021m5 rc021m6 rc021m7 rc023 rc024 rc028 rc029 rz103 rc150 rc151 rc152 rc153 ///
rc154 rc155 rc156 rc157 rc158 rc159 rc160 rc161 rc162 rc163 rc164 rc165 rc166 rc167 rc168 rc169 rc170 rc171 rc172 rc173 rc174 rc175 rc176 /// 
rc177 rc178 rc179 rc180 rc181 rc182 rlb035c1 rlb035c2 rlb035c3 rlb035c4 rlb035c5 rn175 rn365 rc065 /// 
rlb018l rlb018m rlb018n rlb018o rlb054 rlb034_5 rlb035 rlb035a5
sort hhidpn
save "trimmed_files/HRS_RAND_2020_trimmed.dta", replace

use HRS_RAND_2018/h18f2b.dta, clear
keep hhidpn qc018 qc019 qc020 qc021m1 qc021m2 qc021m3 qc021m4 qc021m5 qc021m6 qc021m7 qc023 qc024 qc028 qc029 qz103 qc150 qc151 qc152 qc153 ///
qc154 qc155 qc156 qc157 qc158 qc159 qc160 qc161 qc162 qc163 qc164 qc165 qc166 qc167 qc168 qc169 qc170 qc171 qc172 qc173 qc174 qc175 qc176 ///
qc177 qc178 qc179 qc180 qc181 qc182 qlb035c1 qlb035c2 qlb035c3 qlb035c4 qlb035c5 qn175 qn365 qc065 ///
qlb018g	qlb018h	qlb018i	qlb018j	qlb076	qlb034e	qlb035 qlb035a_5 
sort hhidpn
save "trimmed_files/HRS_RAND_2018_trimmed.dta", replace

use HRS_RAND_2016/h16f2c.dta, clear
keep hhidpn pc018 pc019 pc020 pc021m1 pc021m2 pc021m3 pc021m4 pc021m5 pc021m6 pc021m7 pc023 pc024 pc028 pc029 pz103 pc150 pc151 pc152 pc153 pc154 ///
pc155 pc156 pc157 pc158 pc159 pc160 pc161 pc162 pc163 pc164 pc165 pc166 pc167 pc168 pc169 pc170 pc171 pc172 pc173 pc174 pc175 pc176 pc177 ///
pc178 pc179 pc180 pc181 pc182 pn175 pn365 pc065 ///
plb018g	plb018h	plb018i	plb018j	plb076	plb034e	plb035 plb035a_5
sort hhidpn 
save "trimmed_files/HRS_RAND_2016_trimmed.dta", replace

use HRS_RAND_2014/h14f2b.dta, clear
keep hhidpn oc018 oc019 oc020 oc021m1 oc021m2 oc021m3 oc021m4 oc021m5 oc021m6 oc021m7 oc023 oc024 oc028 oc029 oz103 oc150 oc151 oc152 oc153 ///
oc154 oc155 oc156 oc157 oc158 oc159 oc160 oc161 oc162 oc163 oc164 oc165 oc166 oc167 oc168 oc169 oc170 oc171 oc172 oc173 oc174 oc175 oc176 ///
oc177 oc178 oc179 oc180 oc181 oc182 on175 on365 oc065 ov351 ov352 ///
olb018g	olb018h	olb018i	olb018j olb034e olb035 olb076 olb035a_5
sort hhidpn
save "trimmed_files/HRS_RAND_2014_trimmed.dta", replace

use HRS_RAND_2012/h12f3a.dta, clear
keep hhidpn nc018 nc019 nc020 nc021m1 nc021m2 nc021m3 nc021m4 nc021m5 nc021m6 nc023 nc024 nc028 nc029 nz103 nc150 nc151 nc152 nc153 nc154 ///
nc155 nc156 nc157 nc158 nc159 nc160 nc161 nc162 nc163 nc164 nc165 nc166 nc167 nc168 nc169 nc170 nc171 nc172 nc173 nc174 nc175 nc176 nc177 ///
nc178 nc179 nc180 nc181 nc182 nlb041a nlb041b nlb041c nlb041d nlb041e nn175 nn365 nc065 ///
nlb019l	nlb019m	nlb019n	nlb019o	nlb039e	nlb040	nlb084a nlb084b nlb084c nlb084d nlb084e nlb084f nlb084g nlb084h nlb084i nlb084j nlb084k nlb084l nlb084m nlb084n nlb084o ///
nlb083a nlb083b nlb083c nlb083d nlb083e nlb083f nlb040a_e
sort hhidpn
save "trimmed_files/HRS_RAND_2012_trimmed.dta", replace

use HRS_RAND_2010/hd10f6a.dta, clear
keep hhidpn mc018 mc019 mc020 mc021m1 mc021m2 mc021m3 mc021m4 mc021m5 mc021m6 mc023 mc024 mc028 mc029 mz103 mc150 mc151 mc152 mc153 mc154 ///
mc155 mc156 mc157 mc158 mc159 mc160 mc161 mc162 mc163 mc164 mc165 mc166 mc167 mc168 mc169 mc170 mc171 mc172 mc173 mc174 mc175 mc176 mc177 ///
mc178 mc179 mc180 mc181 mc182 mlb041a mlb041b mlb041c mlb041d mlb041e mn175 mn365 mc065 ///
mlb019l	mlb019m	mlb019n	mlb019o	mlb039e	mlb040 mlb050a mlb050b mlb050c mlb050d mlb050e mlb050f mlb050g mlb050h mlb050i mlb050j mlb050k mlb050l mlb050m mlb050n mlb050o ///
mlb049a mlb049b mlb049c mlb049d mlb049e mlb049f mlb040a_e 
sort hhidpn
save "trimmed_files/HRS_RAND_2010_trimmed.dta", replace

use HRS_RAND_2008/h08f3a.dta, clear
keep hhidpn lc018 lc019 lc020 lc021m1 lc021m2 lc021m3 lc021m4 lc023 lc024 lc028 lc029 lz103 lc150 lc151 lc152 lc153 lc154 lc155 lc156 lc157 ///
lc158 lc159 lc160 lc161 lc162 lc163 lc164 lc165 lc166 lc167 lc168 lc169 lc170 lc171 lc172 lc173 lc174 lc175 lc176 lc177 lc178 lc179 lc180 ///
lc181 lc182 llb041a llb041b llb041c llb041d llb041e ln175 ln365 lc065 ///
llb019l	llb019m	llb019n	llb019o	llb039e	llb040	llb050a llb050b llb050c llb050d llb050e llb050f llb050g llb050h llb050i llb050j llb050k llb050l llb050m llb050n llb050o ///
llb049a llb049b llb049c llb049d llb049e llb049f
sort hhidpn
save "trimmed_files/HRS_RAND_2008_trimmed.dta", replace

use HRS_RAND_2006/h06f4a.dta, clear
keep hhidpn kc018 kc019 kc020 kc021m1 kc021m2 kc021m3 kc021m4 kc021m5 kc021m6 kc023 kc024 kc028 kc029 kz103 kc150 kc151 kc152 kc153 kc154 ///
kc155 kc156 kc157 kc158 kc159 kc160 kc161 kc162 kc163 kc164 kc165 kc166 kc167 kc168 kc169 kc170 kc171 kc172 kc173 kc174 kc175 kc176 kc177 ///
kc178 kc179 kc180 kc181 kc182 klb041a klb041b klb041c klb041d klb041e kn175 kn365 kc065 ///
klb019l	klb019m	klb019n	klb019o	klb039a	klb039b	klb050a klb050b klb050c klb050d klb050e klb050f klb050g klb050h klb050i klb050j klb050k klb050l klb050m klb050n klb050o ///	
klb049a klb049b klb049c klb049d klb049e klb049f klb040e	
sort hhidpn
save "trimmed_files/HRS_RAND_2006_trimmed.dta", replace

use HRS_RAND_2004/h04f1c.dta, clear
keep hhidpn jc018 jc019 jc020 jc021m1 jc021m2 jc021m3 jc021m4 jc023 jc024 jc028 jc029 jz103 jc150 jc151 jc152 jc153 jc154 jc155 jc156 jc157 ///
jc158 jc159 jc160 jc161 jc162 jc163 jc164 jc165 jc166 jc167 jc168 jc169 jc170 jc171 jc172 jc173 jc174 jc175 jc176 jc177 jc178 jc179 jc180 jc181 ///
jc182 jc065 ///
jlb506j	jlb506k	jlb506l	jlb506m	jlb529a	jlb529b	///
jlb523a jlb523b jlb523c jlb523d jlb523e jlb523f jlb523g jlb523h jlb523i jlb523j jlb523k jlb523l jlb523m jlb523n jlb523o jlb530e	
sort hhidpn
save "trimmed_files/HRS_RAND_2004_trimmed.dta", replace

use HRS_RAND_2002/h02f2c.dta, clear
keep hhidpn hc018 hc019 hc020 hc021m1 hc021m2 hc021m3 hc021m4 hc021m5 hc023 hc024 hc025 hc027 hc028 hc029 hz103 hc150 hc151 hc152 hc153 hc154 ///
hc155 hc156 hc157 hc158 hc159 hc160 hc161 hc162 hc163 hc164 hc165 hc166 hc167 hc168 hc169 hc170 hc171 hc172 hc173 hc174 hc175 hc176 hc177 hc178 ///
hc179 hc180 hc181 hc182 hc065
sort hhidpn
save "trimmed_files/HRS_RAND_2002_trimmed.dta", replace

use HRS_RAND_2000/h00f1d.dta, clear
keep hhidpn g1262 g1263 g1264 g1265m1 g1265m2 g1265m3 g1265m4 g1266 g1267 g1268 g1273 g1274 g1275 g232 g1456 g1457 g1458 g1459 g1460 g1461 g1462 ///
g1463 g1464 g1465 g1466 g1467 g1468 g1470 g1471 g1472 g1474 g1478 g1479 g1480 g1481 g1482 g1483 g1484 g1485 g1486 g1487 g1488 g1489 g1491 g1492 ///
g1493 g1495 g1322
sort hhidpn
save "trimmed_files/HRS_RAND_2000_trimmed.dta", replace

use HRS_RAND_1998/hd98f2c.dta, clear
keep hhidpn f1129 f1130 f1131 f1132m1 f1132m2 f1132m3 f1132m4 f1133 f1134 f1135 f1140 f1141 f1142 f232 f1323 f1324 f1325 f1326 f1327 f1328 f1329 ///
f1330 f1331 f1332 f1333 f1334 f1335 f1337 f1338 f1339 f1341 f1345 f1346 f1347 f1348 f1349 f1350 f1351 f1352 f1353 f1354 f1355 f1356 f1358 f1359 ///
f1360 f1362 f1189
sort hhidpn
save "trimmed_files/HRS_RAND_1998_trimmed.dta", replace

use HRS_RAND_1996/h96f4a.dta, clear
keep hhidpn e801 e802 e803 e804m1 e804m2 e804m3 e804m4 e805 e806 e807 e812 e813 e814 e111 e1006 e1007 e1008 e1009 e1010 e1011 e1012 e1013 e1014 ///
e1015 e1016 e1017 e1018 e1020 e1021 e1022 e1024 e1028 e1029 e1030 e1031 e1032 e1033 e1034 e1035 e1036 e1037 e1038 e1039 e1041 e1042 e1043 e1045 e861
sort hhidpn
save "trimmed_files/HRS_RAND_1996_trimmed.dta", replace

use AHEAD_RAND_1995/ad95f2b.dta, clear
keep hhidpn d189 d801 d802 d803 d804m1 d804m2 d804m3 d804m4 d805 d806 d807 d812 d813 d814 d111 d1006 d1007 d1008 d1009 d1010 d1011 d1012 d1013 ///
d1014 d1015 d1016 d1017 d1018 d1020 d1021 d1022 d1024 d1028 d1029 d1030 d1031 d1032 d1033 d1034 d1035 d1036 d1037 d1038 d1039 d1041 d1042 d1043 ///
d1045 d861
sort hhidpn
save "trimmed_files/AHEAD_RAND_1995_trimmed.dta", replace

use HRS_RAND_1994/h94f1a.dta, clear
keep hhidpn w53 w343 w339 w344 w345 w346 w347 w348 w349 w340 w341 w342 w353 w354 w355 w356 w357 w358 w359 w352 
sort hhidpn
save "trimmed_files/HRS_RAND_1994_trimmed.dta", replace

use AHEAD_RAND_1993/ad93f2a.dta, clear
keep hhidpn b231 b225 b232a1 b232a2 b232a3 b232a4
sort hhidpn
save "trimmed_files/AHEAD_RAND_1993_trimmed.dta", replace

use HRS_RAND_1992/hd92f1b.dta, clear
keep hhidpn v337 v338 v339 
sort hhidpn
save "trimmed_files/HRS_RAND_1992_trimmed.dta", replace

******************************************************************************
******************************************************************************
******************************************************************************
* Merging trimmed files
******************************************************************************
******************************************************************************
******************************************************************************

* Now changing working directory to where the trimmed files live
cd "/Users/emurbanw/OneDrive-MichiganMedicine/OneDriveDocuments/Datasets/HRS/trimmed_files"

* Starting off with the longitidunal data
use HRS_RAND_1992_2020_trimmed.dta, clear
sort hhidpn

* Now merging each fatfile with the longitudinal data; _merge is a variable that is created to show which file the data came from after the merge; we rename this to keep track of each wave of data
merge 1:1 hhidpn using "HRS_RAND_2020_trimmed.dta" 
rename _merge merge2020
merge 1:1 hhidpn using "HRS_RAND_2018_trimmed.dta"
rename _merge merge2018
merge 1:1 hhidpn using "HRS_RAND_2016_trimmed.dta"
rename _merge merge2016
merge 1:1 hhidpn using "HRS_RAND_2014_trimmed.dta"
rename _merge merge2014
merge 1:1 hhidpn using "HRS_RAND_2012_trimmed.dta"
rename _merge merge2012
merge 1:1 hhidpn using "HRS_RAND_2010_trimmed.dta"
rename _merge merge2010
merge 1:1 hhidpn using "HRS_RAND_2008_trimmed.dta"
rename _merge merge2008
merge 1:1 hhidpn using "HRS_RAND_2006_trimmed.dta"
rename _merge merge2006
merge 1:1 hhidpn using "HRS_RAND_2004_trimmed.dta"
rename _merge merge2004
merge 1:1 hhidpn using "HRS_RAND_2002_trimmed.dta"
rename _merge merge2002
merge 1:1 hhidpn using "HRS_RAND_2000_trimmed.dta"
rename _merge merge2000
merge 1:1 hhidpn using "HRS_RAND_1998_trimmed.dta"
rename _merge merge1998
merge 1:1 hhidpn using "HRS_RAND_1996_trimmed.dta"
rename _merge merge1996
merge 1:1 hhidpn using "AHEAD_RAND_1995_trimmed.dta"
rename _merge merge1995
merge 1:1 hhidpn using "HRS_RAND_1994_trimmed.dta"
rename _merge merge1994
merge 1:1 hhidpn using "AHEAD_RAND_1993_trimmed.dta"
rename _merge merge1993
merge 1:1 hhidpn using "HRS_RAND_1992_trimmed.dta"
rename _merge merge1992

* Saving the merged data
save "HRS_RAND_allyears_trimmed_merged.dta", replace

