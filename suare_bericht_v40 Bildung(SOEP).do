*** UKR-BILDUNG. Bericht für Ukrainische Geflüchteten aus der ersten SUARE-Welle 2023 (in SOEP-Core integriert)
* # Sabine Zinn, Andrea Marchitto, Jaques Matteo Büsche 
 
/*
- THEMEN

1) Kinderbetreuungsbedarfe und Prävalenz
2) Verteilung Kinder Schultypen (Schulsystem/Bundeslandgruppe)
3) Weiterführende Bildung und Bildungsbeteiligung: Ausbildung / Uni


- VERWENDETE ITEMS

HH-Fragebogen (Betreeuungsbatterie / Schultyp)
Personenfragebogen (Weiterführende Bildung, Soziodemoghraphische Infos über Eltern)

- STATISTISCHER ANSATZ

Deskriptive, gewichtete Auswertung
Stratifizierung nach 
	- Alter, Geschlecht Kind,
	- Region (DEU) [auch Herkunftsregion in Ukriane?]
	- Familienstand Eltern bzw. Angehörige Vorort
	- Erwerbsstatus und Bildung Eltern
*/
* ------------------------------------------------------------------------------

	/* --------------------------------------   
               PRELIMINARY SETTINGS
    --------------------------------------- */

clear all
set maxvar 10000
capture log close
	
* setting globals for working directory and log_files

global in "Z:\consolidate\soep-core\v40\Enddaten\SOEP-2023_Enddatenlieferung_REF_7709_20240227\"
global AVZ "I:\MA\amarchitto\SUARE\Bericht_finale_dataset"
global do "$AVZ\do"
global out_log "$AVZ\log"
global out_data "$AVZ\output"
global out_temp "$AVZ\temp"

log using $out_log\suare_bericht_v40_Bildung_SOEP.log, text replace
* ------------------------------------------------------------------------------

	/* --------------------------------------   
                 UPLOADING DATA
    --------------------------------------- */

* Uploading Data [running stata do.files "suare_instrumentation.do" and "data_suare_bericht_v40.do", from: https://github.com/bieneSchwarze/UkraineReport_SUARE_SOEP_2024] saved in my directory

use $out_data\suare_bericht_v40_data.dta, clear
* ------------------------------------------------------------------------------


/* --------------------------------------   
             SAMPLE AND DATA CLEANING
    --------------------------------------- */

* exploring: how many unique HH and pids are in the dtatset?

codebook hid pid //n(hid)= 2,219; n(pid)= 3,403


* generating basic socio-demographic variables
	* age

gen age = syear-geburt	
tab age age_g

	* gender
recode sex (1=0 "male") (2=1 "female"), gen(sex_bin)
lab var sex_bin "Gender"	

* exploring: varibles in dataset indicating if pids and hids have/don't have children and how many.

tab lr3192 // [Children] yes= 2,590; no= 792; missings= 21
tab lb0285 // [how many children?] 1-more = 2,579; missings = 824
tab prev_hlk0044_v2 // [Children (<16 y.o.) in HH] yes= 1,812; no= 1,591
tab prev_nrkid // [how many children (<16) in HH] 0=1,591, 1-more=1,812





* isolating only his/pids with children (<16) in HH

fre prev_hlk0044_v2
keep if prev_hlk0044_v2==1
		// n= 1,812

		
* how many unique pids/hids are in the dataset (having children <15 in HH)?
distinct hid pid
		// pid= 1,812 (unique)
		// hid= 1,122 (unique)
		
		
* how many persons are in HHs, considering only HH with children <16?

sort hid pid 
br hid pid prev_nrkid lr3192 lb0285 age

	* generating a variable counting how many pids by hid are present in dataset
bysort hid (pid): gen n_pid_HH = _N

tab n_pid_HH
lab var n_pid_HH "Total number of persons in household"
	// considering only HH with children (<16)

/* n_pid_HH |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        539       29.75       29.75
          2 |        988       54.53       84.27
          3 |        219       12.09       96.36
          4 |         60        3.31       99.67
          6 |          6        0.33      100.00
------------+-----------------------------------
      Total |      1,812      100.00          */
	
	* how many unique hids and pids are in dataset considering the total number of persons in HH? 
bys n_pid_HH: distinct hid pid

/* -> n_pid_HH = 1

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        539        539
   pid |        539        539        "single parent (alleinerziehend)"

-----------------------------------------
-> n_pid_HH = 2

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        988        494
   pid |        988        988         "two persons in HH (>=16 y.o.) (not necessarily both parents)"

-----------------------------------------
-> n_pid_HH = 3

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        219         73
   pid |        219        219         "three persons in HH (>=16)"  

-----------------------------------------
-> n_pid_HH = 4

       |        Observations
       |      total   distinct
-------+----------------------
   hid |         60         15
   pid |         60         60          "four persons in HH (>=16)"

-----------------------------------------
-> n_pid_HH = 6

       |        Observations
       |      total   distinct
-------+----------------------
   hid |          6          1
   pid |          6          6          "six persons in HH (>=16)"
*/
	
	  
* how old are they? which gender? how many children (<16) in HH? how many children generally?
sort hid pid
br hid pid sex age prev_nrkid lr3192 lb0285 n_pid_HH

* Saving new dataset
save $out_temp/suare_bericht_v40_Bildung_cleaned.dta, replace

* Which is the gender situation of households?

tab sex_bin
tab sex_bin [aw= hrf23enum_vorab]
tab sex_bin [aw= phrf23vorab_SUARE]
tab sex_bin n_pid_HH [aw= hrf23enum_vorab]
br hid
distinct hid



* how many children (<16 in HH) are present by hid? 

bys prev_nrkid: distinct hid pid

duplicates report hid if prev_nrkid==1
duplicates report hid if prev_nrkid==2
duplicates report hid if prev_nrkid==3
duplicates report hid if prev_nrkid==4
duplicates report hid if prev_nrkid==5
duplicates report hid if prev_nrkid==6
duplicates report hid if prev_nrkid==9

preserve
collapse prev_nrkid, by(hid)

/*
 prev_nrkid |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        675       60.16       60.16
          2 |        333       29.68       89.84
          3 |         90        8.02       97.86
          4 |         16        1.43       99.29
          5 |          4        0.36       99.64
          6 |          3        0.27       99.91
          9 |          1        0.09      100.00
------------+-----------------------------------
      Total |      1,122      100.00
*/
restore

	* controlling
	
	preserve
	br hid pid n_hid_HH n_pid_HH
	keep if n_hid_HH==1
	tab prev_nrkid
	restore

* How hold are children (<16 in HH)? exploring vars prev_k_birthy_v2_*
mvdecode prev_k_birthy_v2_*, mv(-8/-1)

forvalues i = 1/10 {
    gen age_k_`i' = 2023 - prev_k_birthy_v2_`i'
}
tab1 age_k*

forvalues i = 1/10 {
	clonevar age_k_categ_`i' = age_k_`i'
}

*##########################################

* starting analysis of single parents (pid==hid==539)
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* if n_pid_HH==1

* organizing children (<16 in HH) in age groups to cluster eligibility for institutional childcare/school attendance
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* if n_pid_HH==1 


* how many children are in the age of eligibility for institutional childcare? (0-6 y.o.)
foreach var of varlist age_k_categ_* {
	replace `var' = 1 if `var' <6
	replace `var' = 2 if `var' >=6 & `var' <=17
}

label define children_care 1 "[1] Age 0-5. Children eligible for institutional childcare" 2 "[2] Age 6-17. Children eligible for school attendace"

foreach var of varlist age_k_categ_* {
	label values `var' children_care
}
			
*##########################################

* starting analysis of single parents (pid==hid==539)
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* if n_pid_HH==1

* organizing children (<16 in HH) in age groups to cluster eligibility for institutional childcare/school attendance
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* if n_pid_HH==1 


* how many children are in the age of eligibility for institutional childcare? (0-6 y.o.)
/* foreach var of varlist age_k_categ_* {
	replace `var' = 1 if `var' <6
	replace `var' = 2 if `var' >=6 & `var' <=17
}

label define children_care 1 "[1] Age 0-5. Children eligible for institutional childcare" 2 "[2] Age 6-17. Children eligible for school attendace"

foreach var of varlist age_k_categ_* {
	label values `var' children_care
}

*/			
			
			* alternative categorigation of eligibity for isntitutional childcare/schhol attendance by children age groups
			foreach var of varlist age_k_categ_* {
				replace `var' = 1 if `var' <3
				replace `var' = 2 if `var'  >=3 & `var'<6
				replace `var' = 3 if `var'  >=6 & `var'<=9
				replace `var' = 4 if `var'  >9 & `var'<=17
			}
			
			label define children_care_altern ///
				1 "[1] Age 0-3 (excl.). Children eligible for intensive childcare (Parents/Relatives; Tagesmutter; Kitas)" ///
				2 "[2] Age 3-6 (excl.). Children eligible for institutional childcare" ///
				3 "[3] Age 6-12. Children eligible for Grundschule" ///
				4 "[4] Age 13-16,17. Pupils eligible for Haupt-, Real-, Gesamt-, Berufs- und Fachoberschule, or Gymnasium"
				
			foreach var of varlist age_k_categ_* {
				label values `var' children_care_altern
			}
				
				
sort hid pid				
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* age_k_categ_*

* searching for pointers indicating mother/father of children <16 in HH
br hid pid n_pid_HH n_hid_HH hknr_1 hknr_2 hknr_3 hknr_4 hknr_5 hknr_6 hknr_7 hknr_8 hknr_9 hknr_10 prev_nrkid kindfb_proxy_pid ppnamepnr ppnamlpnr sd_anker pid2 intid age lr3192 lb0285 // nothing found



* single parent HH and age and sex of partents
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* age sex_bin if n_pid_HH>1

* more person in HH and age and sex
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_* age sex_bin if n_pid_HH>1


bysort n_pid_HH: tab sex_bin


* are observation regarding children <16 in HH identical for every pid in HH (if more than 1)? ex hid=6508500 (n_pid_HH==4)
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* age_k_* age_k_categ_* lr3595i04 ks_hasc_* ks_pre_v6_* kc_kindbetr_* kc_vorsch_* kc_wselbst_* kc_wtagm_* kc_wbezb_* kc_wnone_* ks_none_v3_* ks_gen_v8_* ks_usch1_* ks_usch2_* ks_spe_* kd_time_v2_* ka16_slang_v1_* ka16_lang_v1_* ka16_hlang_v3_* if hid==6508500 // identical observation for every pids in HH

order hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* age_k_* age_k_categ_* lr3595i04 ks_hasc_* ks_pre_v6_* kc_kindbetr_* kc_vorsch_* kc_wselbst_* kc_wtagm_* kc_wbezb_* kc_wnone_* ks_none_v3_* ks_gen_v8_* ks_usch1_* ks_usch2_* ks_spe_* kd_time_v2_* ka16_slang_v1_* ka16_lang_v1_* ka16_hlang_v3_* if hid==6508500 // identical observation for every pids in HH


mvdecode lkvpid* age_k_* age_k_categ_* lr3595i04 ks_hasc_* ks_pre_v6_* kc_kindbetr_* kc_vorsch_* kc_wselbst_* kc_wtagm_* kc_wbezb_* kc_wnone_* ks_none_v3_* ks_gen_v8_* ks_usch1_* ks_usch2_* ks_spe_* kd_time_v2_* ka16_slang_v1_* ka16_lang_v1_* ka16_hlang_v3_*, mv(-8/-1)

br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* age_k_* age_k_categ_* lr3595i04 ks_hasc_* ks_pre_v6_* kc_kindbetr_* kc_vorsch_* kc_wselbst_* kc_wtagm_* kc_wbezb_* kc_wnone_* ks_none_v3_* ks_gen_v8_* ks_usch1_* ks_usch2_* ks_spe_* kd_time_v2_* ka16_slang_v1_* ka16_lang_v1_* ka16_hlang_v3_* if hid==6508500 // identical observation for every pids in HH 


* not single parent: 2 persons in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* age_k_* age_k_categ_* lr3595i04 ks_hasc_* ks_pre_v6_* kc_kindbetr_* kc_vorsch_* kc_wselbst_* kc_wtagm_* kc_wbezb_* kc_wnone_* ks_none_v3_* ks_gen_v8_* ks_usch1_* ks_usch2_* ks_spe_* kd_time_v2_* ka16_slang_v1_* ka16_lang_v1_* ka16_hlang_v3_* if n_pid_HH==2


* transfroming our dataset from wide to long to gain the children perspective
	* keeping the first pids-observation of every HH
	
preserve
keep if n_hid_HH==1 // 1,122 unique hid

reshape long age_k_ age_k_categ_ ks_hasc_ ks_pre_v6_ kc_kindbetr_ kc_vorsch_ kc_wselbst_ kc_wtagm_ kc_wbezb_ kc_wnone_ ks_none_v3_ ks_gen_v8_ ks_usch1_ ks_usch2_ ks_spe_ kd_time_v2_ ka16_slang_v1_ ka16_lang_v1_ ka16_hlang_v3_, i(hid) j(kid_nr)


keep hid pid kid_nr prev_nrkid age_k_ age_k_categ_ ks_hasc_ ks_pre_v6_ kc_kindbetr_ kc_vorsch_ kc_wselbst_ kc_wtagm_ kc_wbezb_ kc_wnone_ ks_none_v3_ ks_gen_v8_ ks_usch1_ ks_usch2_ ks_spe_ kd_time_v2_ ka16_slang_v1_ ka16_lang_v1_ ka16_hlang_v3_
		// n= 11,220 kinder <16 im HH


drop if kid_nr>prev_nrkid
		// n=1,722 Total Ukr-Children in dataset 
		
		
* 1. counting
lab var ks_gen_v8_ "Kind (<16) im Schule" 
lab var ks_usch1_ "Kind (<16) Onlineunterricht Ukr Schule"
lab var ks_usch2_ "Kind (<16) Besuch Ukr schule Online"
lab var ks_none_v3_ "Welche Schule besucht <Name des Kindes> derzeit?"
lab var ka16_slang_v1_ "Bekommt das Kind eine spezielle Sprachförderung in der Schule?"
lab var ks_hasc_ "Besucht das Kind derzeit einen Schulhort oder eine vergleichbare Betreuung in der Schule?"
lab var ks_pre_v6_ "Besucht das Kind derzeit eine Kinderkrippe, einen Kindergarten oder eine Kindertageseinrichtung"
lab var kc_kindbetr_ " Stunden pro Woche: Kidenrkrippe, Kindergarten, Kidertagseinrichtung"
lab var kc_vorsch_ "Das Kind geht gerne in die Krippe/Kidergarten/Kindertagseinr"
lab var kc_wselbst_ "Wer übernimmt die Betreuung des Kindes? sie selbst"
lab var kc_wtagm_ "Wer übernimmt die Betreuung des Kindes?: Tagesmutter"
lab var kc_wbezb_ "Wer übernimmt die Betreuung des Kindes?: Bezhalte Betreuungsperson des HHs"
lab var kc_wnone_ "Wer übernimmt die Betreuung des Kindes?: keine Person"
lab var ka16_lang_v1_ "Bekommt das Kind eine spezielle Sprachförderung außerhalb der Schule?"
lab var ka16_hlang_v3_ "Wie viele Stunden pro Woche erhält das Kind eine Sprachförderung außerhalb der Schule?"		

bys age_k_categ: tab1 ks_none_v3_ ks_gen_v8_ ks_usch1_ ks_usch2_ ks_spe_ kd_time_v2_ ka16_slang_v1_ ka16_lang_v1_ ka16_hlang_v3_ ks_hasc_ ks_pre_v6_ kc_kindbetr_ kc_vorsch_ kc_wselbst_ kc_wtagm_ kc_wbezb_ kc_wnone_



****** ELTERN VERANKERN

* inserire anche lr3192 lb0285 "kinder: Ja/Nein" e "Kinder: Anzahl"
* gen
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid*

* 1 person in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* if n_pid_HH==1

* 2 persons in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* if n_pid_HH==2

* 3 persons in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* if n_pid_HH==3

* 4 persons in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* if n_pid_HH==4

* 5 persons in HH // no obs.

* 6 persons in HH
br hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid lkvpid* if n_pid_HH==6



****** INSPECTING *********

preserve
keep if inlist(hid, 6508500, 6509200, 6508880, 6509080, 6508930, 6509590, 6509710, 6510000)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*


* --> 4 persons in HH (randomly chosen)

* hid==6508500
keep if hid==6508500
br
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
order pid sex_bin hknr_ age_k_ lkvpid
br
restore


* hid==6509200   
preserve 
keep if hid==6509200
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
gen parents=.
tab sex_bin
fre sex_bin
replace parents= 1 if sex_bin==0 & hknr_ ==lkvpid & hknr_!=. & lkvpid!=.
replace parents= 2 if sex_bin==1 & hknr_==lkvpid & hknr_!=. & lkvpid!=.
replace parents= 3 if hknr_!=lkvpid & hknr_!=.
lab def parents 1 "fahter" 2 "mother" 3 "other person in HH, not parents"
lab values parents parents
tab parents
keep if parents!=.
sort hknr_
br if parents==2
restore


* --> single parents "alleinerziehend" 

* hid==6508880
preserve
keep if hid==6508880
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore

* hid==6509080
preserve
keep if hid==6509080
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore


* hid==6508930
preserve
keep if hid==6508930
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore


* --> 2 persons in HH

* hid==6509590  /// four children: 3/4 seem to be children of the couple, while the first is unclear?
preserve
keep if hid==6509590
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore
	
* --> 3 persons in HH	
	
* hid==6509710 /// mother, father?, daughter + 1 child <16 in HH
preserve
keep if hid==6509710
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore	


* hid==6510000 
preserve
keep if hid==6510000
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
keep hid pid sex_bin age n_pid_HH n_hid_HH prev_nrkid age_k_* hknr_* lkvpid*
order pid sex_bin hknr_ age_k_ lkvpid
br
restore	


* merging with dataset with HH-wights
merge m:1 hid syear using "I:\MA\fsuettmann\Vorabgewichte_v40_IAB_BAMF_SOEP_1.0\Vorabgewichte_M34569_v40_H_1.0.dta"
keep if _merge==3
sort hid pid
br hid pid phrf23vorab_SUARE hhrf23vorab_SUARE
tab bula
tab bula [aw= phrf23vorab_SUARE ]
tab bula [aw= hhrf23vorab_SUARE ]
fre phrf23vorab_SUARE
di 1812-1725 // n=87 with value "0", individual level

br hid pid phrf23vorab_SUARE hhrf23vorab_SUARE prev_nrkid

	* generating weights for children: HH-weights/number of children in HH <16
gen gewicht_kinder= hhrf23vorab_SUARE/prev_nrkid
tab bula [aw= gewicht_kinder]




*###############################################################################
* case by case connecting parents to children* 
* 1 step: looking at 1 person HH (alleinerziehend)
preserve
keep if n_pid_HH==1
br hid pid sex_bin age prev_nrkid lr3192 lb0285 hknr_* lkvpid*
order hid pid sex_bin age lr3192 lb0285
mvdecode hknr_* lkvpid*, mv(-8/-1)
order hid pid sex_bin age lr3192 lb0285 hknr_* lkvpid*
mvdecode lr3192 lb0285, mv(-8/-1)
tab lr3192
	// n[Ja] = 519
	// n[Nein] = 18
	
gen parents=. 
replace parents =3 if lr3192==2	// value "3" is other relative in HH, not parents

tab parents
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
drop if hknr_==. & lkvpid==.

		




	





 

	
