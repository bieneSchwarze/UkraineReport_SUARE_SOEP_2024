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
			

		




	





 

	
