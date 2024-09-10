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

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023-Enddaten_REF_7709_Update_1_20240904"
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


* generating basi socio-demographic variables
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

	* generating a variable numering pids by HH present in dataset
	bysort hid (pid): gen n_hid_HH = _n
	

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
	
	* how many unique hids and pids are in dataset cosnidering the total numebr of
bys n_pid_HH: distinct hid pid

/* -> n_pid_HH = 1  (hid==pid==539)

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        539        539
   pid |        539        539         "single parent (alleinerziehend)"

-----------------------------------------
-> n_pid_HH = 2     (pid/2==hid==494)

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        988        494
   pid |        988        988         "two persons in HH (>=16 y.o.) (not necessarily both parents)"

-----------------------------------------
-> n_pid_HH = 3     (pid/3==hid==73)

       |        Observations
       |      total   distinct
-------+----------------------
   hid |        219         73
   pid |        219        219         "three persons in HH (>=16)"  

-----------------------------------------
-> n_pid_HH = 4     (pid/4==hid==15)

       |        Observations
       |      total   distinct
-------+----------------------
   hid |         60         15
   pid |         60         60          "four persons in HH (>=16)"

-----------------------------------------
-> n_pid_HH = 6      (pid/6==hid==1)

       |        Observations
       |      total   distinct
-------+----------------------
   hid |          6          1
   pid |          6          6          "six persons in HH (>=16)"
*/

* how many unique hid and pid are in dataset considering the total number of pids ind HH and the number of children <16 in HH?
bys n_pid_HH prev_nrkid : distinct hid pid 		// Verteilung hid und pid nach Anzahl pids im HH und nach Anzahl der Kinder <16 im HH
	
	  
* how old are they? which gender? how many children (<16) in HH? how many children generally?
sort hid pid
br hid pid sex age prev_nrkid lr3192 lb0285 n_pid_HH

* Saving new dataset
save $out_temp/suare_bericht_v40_Bildung_cleaned.dta, replace

* exploring
order hid pid sex_bin age lb0285 lr3192 prev_nrkid hknr_1 hknr_2 lb0288_v2 lb0291_v1 lb0294_v1 lb0287_v2 lb0290_v2 lb0293_v2
br hid pid sex_bin age lb0285 lr3192 prev_nrkid hknr_1 hknr_2 lb0288_v2 lb0291_v1 lb0294_v1 lb0287_v2 lb0290_v2 lb0293_v2

		
* Which is the gender situation of households?

tab sex_bin
tab sex_bin [aw= hhrf23vorab_SUARE]
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

/*preserve
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


	* controlling
	
	br hid pid n_hid_HH n_pid_HH
	keep if n_hid_HH==1
	tab prev_nrkid
	restore

*/

* How old are children (general variable-all children)
 * ----- children 
   * age: nicht nur in household -----

mvdecode lb0287_v2 lb0290_v2 lb0293_v2 lb0296_v2 lb0299_v2 lb0302_v2 lb0305_v2 lb0308_v2 lb1139 lb1138, mv(-9/-1)

gen age_k_1 = syear - lb0287_v2
gen age_k_2 = syear - lb0290_v2
gen age_k_3 = syear - lb0293_v2
gen age_k_4 = syear - lb0296_v2
gen age_k_5 = syear - lb0299_v2
gen age_k_6 = syear - lb0302_v2
gen age_k_7 = syear - lb0305_v2
gen age_k_8 = syear - lb0308_v2
gen age_k_9 = syear - lb1139
gen age_k_10 = syear - lb1138
	tab1 age_k_*

* How hold are children (<16 in HH)? exploring vars prev_k_birthy_v2_*
mvdecode prev_k_birthy_v2_*, mv(-8/-1)

forvalues i = 1/10 {
    gen age_k_HH_`i' = 2023 - prev_k_birthy_v2_`i'
}
tab1 age_k_HH_*

forvalues i = 1/10 {
	clonevar age_k_categ_`i' = age_k_HH_`i'
}


* Which gender have children?
* ----- children gender
mvdecode lb0288_v2 lb0291_v1 lb0294_v1 lb0297_v1 lb0300_v1 lb0303_v1 lb0306_v1 lb0309_v1 lb1166_v1 lb1165, mv(-9/-1)

rename lb0288_v2 sex_k_1
rename lb0291_v1 sex_k_2
rename lb0294_v1 sex_k_3
rename lb0297_v1 sex_k_4
rename lb0300_v1 sex_k_5
rename lb0303_v1 sex_k_6
rename lb0306_v1 sex_k_7
rename lb0309_v1 sex_k_8
rename lb1166_v1 sex_k_9
rename lb1165 sex_k_10
	tab1 sex_k_*

sort hid pid
br hid pid sex_bin age lr3192 lb0285 prev_nrkid age_k_* age_k_HH_* sex_k_*

* something is not working!!!!!!
order hid pid sex_bin age hknr_* lr3192 lb0285 prev_nrkid age_k_* age_k_HH_* sex_k_*
br hid pid sex_bin age hknr_* lr3192 lb0285 prev_nrkid age_k_* age_k_HH_* sex_k_* if hid == 6509440 | hid==6509470

*##########################################

* starting analysis of single parents (pid==hid==539)
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_HH_* if n_pid_HH==1

* organizing children (<16 in HH) in age groups to cluster eligibility for institutional childcare/school attendance
br hid pid n_pid_HH n_hid_HH prev_nrkid age_k_HH_* if n_pid_HH==1 


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
			
			* alternative categorization of eligibity for isntitutional childcare/schhol attendance by children age groups
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
				

				* Generating household-weights for children<16 in HH: RULE: Household-weights / number of children <16 in HH

gen gewicht_kinder= hhrf23vorab_SUARE/prev_nrkid
lab var gewicht_kinder "HH-Weights/n. children in HH"
tab bula [aw= gewicht_kinder]			
				 								
sort hid pid				
br hid pid n_pid_HH n_hid_HH prev_nrkid hhrf23vorab_SUARE gewicht_kinder 

**** Inspecting data: indentifying parents of children <16 in HH and other relatives non-parent present in HH

* browsing small set of vars
br hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_HH_*

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


/*

****** INSPECTING - randomly chosen hid and data-trasfromation from wide to long *********

br hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
order hid pid sex_bin age n_hid_HH n_pid_HH lr3192 lb0285 prev_nrkid hknr_* lkvpid* age_k_*

* hid(list): 6508500, 6509200, 6508880, 6509080, 6508930, 6509590, 6509710, 6510000


* --> 4 persons in HH 

* hid==6508500
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6508500
br
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore


* hid==6509200   
preserve 
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6509200
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
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
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6508880
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore

* hid==6509080
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6509080
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore


* hid==6508930
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6508930
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore


* --> 2 persons in HH

* hid==6509590  /// four children: 3/4 seem to be children of the couple, while the first is unclear?
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6509590
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore
	
* --> 3 persons in HH	
	
* hid==6509710 /// mother, father?, daughter + 1 child <16 in HH
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6509710
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore	


* hid==6510000 
preserve
keep hid pid sex_bin age n_hid_HH n_pid_HH prev_nrkid lr3192 lb0285 hknr_* lkvpid* age_k_*
keep if hid==6510000
reshape long hknr_ age_k_ age_k_categ_ lkvpid, i(pid) j(new_var)
br
restore
*/	

* save dataset
save $out_temp/suare_bericht_v40_Bildung_cleaned.dta, replace

/* --------------------------------------   
         PREPARING DATA OF RELMATRIX
    --------------------------------------- */

***** Identifying parents and other relative of children <16, using relmatrix

use $in/Stichprobendaten\soep-core-2023-relmatrix.dta, clear

* inspecting data:

sort hid pid 
* keep only Ukr-respondents M9
keep if inlist(sample1, 44, 48)
			// n==7,100
			
br hid pid pid2 relation pairrelation relationor pairrelationor korrektur korrektur_open sample1

			// vars "relation; relationor": relation of pid to pid2. --> "relationor" is the relation of pid to pid2 before checking data (vor Datenprüfung)
			// vars "pairrelation; pairrelationor": relation of pid2 to pid. --> "pairrelationor" is the relation of pid2 to pid before checking data (vor Datenprüfung)
			
* preparing dataset to be merged with ukr_massterdata
			
keep hid pid pid2 relation pairrelation relationor pairrelationor korrektur korrektur_open
br
* considering the information pairrelation pairrelatioor, as relation of pid2, cosidered as pid in the HH, to pid, cosidered as children_ID <16 in HH

* rename identifiers to be matched with master dataset:

	* pid --> Children_HD (vars hknr_1, _2, ..., _10) in our datatset in wide format
rename pid hknr_
	* pid2 --> pid in our dataset
rename pid2 pid

* save relmatrix dataset in working directory-temporary outcome folder:
save $out_temp/suare_relmatrix_relative_identifiers.dta, replace


*** ----------------------------------------

/* --------------------------------------   
         RECALLING THE MASTER DATASET
    --------------------------------------- */ 
	
* recall of master dataset and trasforming it from wide to long to have the children ID_number in long form before matching with relmatrix	
use $out_temp/suare_bericht_v40_Bildung_cleaned.dta, clear	

* memo:
distinct hid pid
		// unique hid= 1,122
		// unique pid= 1,812
		
* reshape from wide to long, including variables for Kinderbetreeung und Prävalenz

	/* variables:
	- ks_pre_v6_*      --> "Kinder (<16) im HH: Besuch Betreuungseinrichtung (1-10)"
	- kc_kindbetr_*    --> "Kinder (<16) im HH: Besuch Betreuungseinrichtung (Std./Woche) (1-10)"
	- ks_hasc_*        --> "Kinder (<16) im HH: Wochenstunden Schulbetreuung (1-10)"
	- ks_asc_v2_*      --> "Kinder (<16) im HH: Hortbesuch (1-10)"
	- kc_wselbst_*     --> "Kinder (<16) im HH: Eigene Betreuung (1-10)"
	- kc_wpart_*       --> "Kinder (<16) im HH: Partner betreut (1-10)"
	- kc_weltern_*     --> "Kinder (<16) im HH: Elternteil des Kindes betreut (1-10)"
	- kc_wgeltern_*    --> "Kinder (<16) im HH: Großeltern des Kindes betreuen (1-10)"
	- kc_wgesch_*      --> "Kinder (<16) im HH: Ältere Geschwister betreuen (1-10)"
	- kc_wverw_*       --> "Kinder (<16) im HH: Andere Verwandte betreuen (1)"
	- kc_wtagm_*       --> "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut außerhalb des HH (1-10)"
	- kc_wbezb_*       --> "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut im HH (1-10)"
	- kc_wfreund_*     --> "Kinder (<16) im HH: Freunde/Bekannte/Nachbarn betreuen (1-10)"
	- kc_wnone_*       --> "Kinder (<16) im HH: Keine Betreuung (1-10)"
	     
		 / - - - /
		 
	- ks_gen_v8_*      --> "Kinder (<16) im HH: Schule (1-10)"
	- ks_spe_*         --> "Kinder (<16) im HH: Schule mit speziellem Konzept (1-10)"
	- kd_time_v2_*     --> "Kinder (<16) im HH: Schule ganzttags (1-10)"
	- ks_stufe_*       --> "Kinder (<16) im HH: Klassenstufe (1-10)"
	- ks_none_v3_*     --> "Kinder (<16) im HH: Kein Schulbesuch (1-10)"
	- ks_usch1_*       --> "Kinder (<16) im HH: Onlineunterricht ukrainische Schule (1-10)"
	- ks_usch2_*       --> "Kinder (<16) im HH: Besuch ukrainische Schule online (1-10)"
	  
		 / - - - /
		 
	- kc_vorsch_*      --> "Kinder (<16) im HH: Geht gerne in Betreuungseinrichtung (1-10)"
	- ka16_slang_v1_*  --> "Kinder (<16) im HH: Spezielle Sprachförderung in Schule (1-10)"
	- ka16_lang_v1_ *  --> "Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (1-10)"
	- ka16_hlang_v3_*  --> " Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (Std./Woche) (1-10)"
   	*/

reshape long hknr_ age_k_ sex_k_ age_k_HH_ age_k_categ_ lkvpid ks_pre_v6_ kc_kindbetr_ ks_hasc_ ks_asc_v2_ kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ kc_wnone_ ks_gen_v8_ ks_spe_ ks_stufe_ kd_time_v2_ kc_vorsch_ ks_none_v3_ ks_usch1_ ks_usch2_ ka16_slang_v1_ ka16_lang_v1_ ka16_hlang_v3_, i(pid) j(new_var)
		// obs=18,120 (1,812 pid X 10max children obs.)
		
		
* inspecting data long
order hid pid age sex_bin hknr_ age_k_ sex_k_ prev_nrkid lkvpid
br hid pid age sex_bin hknr_ age_k_ sex_k_ prev_nrkid lkvpid		
		
		
* hom many unique pid, hid and children are in dataset?

distinct hid pid hknr_		
		// hid   = 1,122
		// pid   = 1,812
		// hknr_ = 1,723
		
		
* if we shift the perspective from pid to children, including all information of every pid each child, we generate a dataset with 1723 (children)*1812(pid in HH) = 3,122,076 obs 
		di 1723*1812
			// n= 3,122,076
			

* merge with relmatrix to indentify parents (mother and father) and other relative non-parent present in HH

merge m:1 hid pid hknr_ using $out_temp/suare_relmatrix_relative_identifiers.dta
		// _merge==1 (not match, master) n=15,346
		// _merge==2 (not match, using)  n= 4,326
		// _merge==3 (matched)           n= 2,774
		
br hid pid sex_bin age age_k_ sex_k_ lr3192 lb0285 prev_nrkid hknr_ lkvpid relation pairrelation relationor pairrelationor _merge

br hid pid sex_bin age age_k_ sex_k_ lr3192 lb0285 prev_nrkid hknr_ lkvpid relation pairrelation relationor pairrelationor _merge if hid == 6508500 | hid==6509470 | hid==6509440

rename _merge relmatrix_merge

save $out_temp/suare_bericht_v40_Bildung_relmatrix_incomplete.dta, replace

* create a dataset and keep only:
* lkvpid --> hknr_
* age_k_ --> age_k_new
* sex_k_ --> sex_k_new

keep lkvpid sex_k_ age_k_
drop if inlist(lkvpid, .a, .b, .c, .d, .e, .f, .g, .h, .)
rename lkvpid hknr_
rename age_k_ age_k_new
rename sex_k_ sex_k_new

distinct hknr_
	// n unique = 1774

sort hknr_	
order hknr_ age_k_new sex_k_new
br

bysort hknr_: gen n= _n
br

keep if n==1
drop n

save $out_temp/suare_bericht_v40_Bildung_k_age_sex_mergen.dta, replace





/*#################################################################
  #################################################################
  #################################################################
  #################################################################
  #################################################################
  #################################################################
  #################################################################
  #################################################################
 	*/

*** ----------------------------------------

/* --------------------------------------   
         RECALLING THE MASTER DATASET fpr merging by sex and age of children
    --------------------------------------- */ 	
	
use $out_temp/suare_bericht_v40_Bildung_relmatrix_incomplete.dta, clear

merge m:1 hknr_ using $out_temp/suare_bericht_v40_Bildung_k_age_sex_mergen.dta

br hid pid sex_bin age age_k_ age_k_new sex_k_ sex_k_new prev_nrkid hknr_ lkvpid relation pairrelation relationor pairrelationor relmatrix_merge _merge

sort hid pid 
order hid pid sex_bin age hknr_ lkvpid age_k_ age_k_new sex_k_ sex_k_new prev_nrkid pairrelation relmatrix_merge _merge
br hid pid sex_bin age hknr_ lkvpid age_k_ age_k_new sex_k_ sex_k_new prev_nrkid pairrelation relmatrix_merge _merge
		
* dropping observation without information about relatives (_merge= 1; 2)		
bys relmatrix_merge: distinct hid pid hknr_ _merge
keep if relmatrix_merge==3		
drop relmatrix_merge



* * hom many unique pid, hid and children are in dataset after merging with relmatrix?

distinct hid pid hknr_		
		// hid   = 1,121    -   originally 1,122 (-1)
		// pid   = 1,758    -   originally 1,812 (-54)
		// hknr_ = 1,719    -   originally 1,723 (-4)


		* missing information on gender (Kinder) and age (kinder), use of biogr. survey.. Missing information of age could be replace by values of var "age_k_HH_", but no further information about gender in HH-survey level
		fre age_k_new sex_k_new
			// age_k_new missings = 338
			// sex_k_new missings = 314

* replacing values of age_k_new with values of age_k_HH_ if age_k_new != age_k_HH_ (if missing and if different values, n=368 
sort hid pid
br hid pid age sex_bin hknr_ age_k_new age_k_HH_ sex_k_ sex_k_new prev_nrkid if age_k_new!=age_k_HH_
			
replace age_k_new = age_k_HH_ if age_k_new!=age_k_HH_			
			

* gen variable parents
fre sex_bin pairrelation
		// pairrelation (values): 31. liebliche Mutt/Vat; 32. Stiefmuut/-vater; 33. Adoptivmutt/-vat; 34. Pflegemutt/-vat.; 

		// pairrelation (values): 11. Ehegatt; 36. Großmutt/--vat; 37. Uhrgroßeletrnteil; 41. 42. 44. 45. Geschwister; 51. Schwanger?; 61. 63. 64. 71. Andere Verwandte/Sonstiges
gen parents=.
replace parents=1 if sex_bin==1 & inlist(pairrelation, 31, 32, 33, 34)
replace parents=2 if sex_bin==0 & inlist(pairrelation, 31, 32, 33, 34)
replace parents=3 if inlist(pairrelation, 36, 37, 41, 42, 44, 45, 61, 63, 64, 71)
		// mi=29: kein information bei pairrelation, oder ehegatt; schwanger?
		
lab var parents "Related to child as"
lab def parents 1 "mother/same role" 2 "fahter/same role" 3 "other relatives/other"		
lab values parents parents

save $out_temp/suare_bericht_v40_Bildung_relmatrix.dta, replace

capture log close
