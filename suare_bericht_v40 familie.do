clear all
set maxvar 10000
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

  * ------------------------------
    * VARIABLES: FAMILY
  * ------------------------------

 * ----- CHILDREN IN HOUSEHOLD -----

 * ----- Children (dummy) -----

gen children = lr3192
recode children 2 = 0 

label define children_lab 0 "[0] Nein" 1 "[1] Ja"
label var children "Kinder (Ja/Nein)"
label values children children_lab 

tab lr3192 children, m 

 * ----- Children under 16 in household (dummy) -----

* PROPOSAL:
gen h_child_hh = prev_hlk0044_v2
recode h_child_hh 2 = 0
replace h_child_hh = 1 if prev_nrkid > 0 & prev_nrkid < .
replace h_child_hh = 0 if lr3192 == 2 

label define h_child_hh_lab 0 "[0] Nein" 1 "[1] Ja"
label var h_child_hh "Kinder im Haushalt (Ja/Nein)"
label values h_child_hh h_child_hh_lab

tab prev_nrkid prev_hlk0044_v2
tab h_child_hh
	
 * Übereinstimmung aber nicht 100% ?

 * ----- Number of children in household -----
 
gen hchild_N = prev_nrkid 
replace hchild_N = 0 if h_child_hh == 0

label var hchild_N "Anzahl der Kinder im Haushalt" 

tab prev_nrkid hchild_N, m

 * ----- children age in household -----

forvalues i = 1/10 {
    gen age_hh_k_`i' = 2023 - prev_k_birthy_v2_`i'
}
tab1 age_hh_k*

 * ----- children born in Germany -----

gen child_in_G = 0

foreach var of varlist prev_k_birthy* {
    replace child_in_G = 1 if inlist(`var', 2022, 2023) & `var' >= lr3130
}

tab child_in_G

duplicates report pid if child_in_G > 1

sort pid
 * browse pid prev_k_birthy* if prev_k_birthy_v2_1 > 2021 | prev_k_birthy_v2_2 > 2021 | prev_k_birthy_v2_3 > 2021 | prev_k_birthy_v2_4 > 2021 | prev_k_birthy_v2_5 > 2021 | prev_k_birthy_v2_6 > 2021 | prev_k_birthy_v2_7 > 2021 | prev_k_birthy_v2_8 > 2021 | prev_k_birthy_v2_9 > 2021 | prev_k_birthy_v2_10 > 2021

 * ----- youngest child in hh: age group -----

foreach var of varlist age_hh_k* {
	replace `var' = . if `var'<0
}

egen youngest_child = rowmin(age_hh_k*) 
sort pid
br pid youngest_child age_hh_k*

gen h_child_age=.
recode h_child_age .=1 if h_child_hh == 0
recode h_child_age .=2 if youngest_child < 3
recode h_child_age .=3 if youngest_child >= 3 & youngest_child < 7
recode h_child_age .=4 if youngest_child >= 7 & youngest_child < 17
recode h_child_age .=5 if youngest_child >= 17 & youngest_child < .
recode h_child_age .=6 if youngest_child == . 

#delimit
	label define h_child_age_lab
		1 "[1] Keine Kinder " 
		2 "[2] Kind jünger als 3 " 
		3 "[3] Kind zwischen 3 und 6 " 
		4 "[4] Kind 7 bis 16" 
		5 "[5] Kind älter als 16"
		6 "[6] Miss info"
		, replace;
#delimit cr

label var h_child_age "Kind im Haushalt, nach Altersgruppe"
label values h_child_age h_child_age_lab

tab youngest_child h_child_age, m

 * ----- children in the household (separate dummies, based on youngest) -----

gen h_child_age_0_2 = 0 if h_child_hh == 0 
replace h_child_age_0_2 = 1 if h_child_age == 2

gen h_child_age_3_6 = 0 if h_child_hh == 0 
replace h_child_age_3_6 = 1 if h_child_age == 3

gen h_child_age_7_17 = 0 if h_child_hh == 0 
replace h_child_age_7_17 = 1 if h_child_age == 4

label define child_age_dummy_lab 0 "[0] Nein" 1 "[1] Ja"

label var h_child_age_0_2 "Kind im Haushalt, jünger als 3 Jahre"
label values h_child_age_0_2 child_age_dummy_lab

label var h_child_age_3_6 "Kind im Haushalt, 3 bis 6 Jahre"
label values h_child_age_3_6 child_age_dummy_lab

label var h_child_age_7_17 "Kind im Haushalt, 7 bis 17 Jahre"
label values h_child_age_7_17 child_age_dummy_lab

tab h_child_age h_child_age_0_2, m
tab h_child_age h_child_age_3_6, m
tab h_child_age h_child_age_7_17, m

 * ----- age groups, children in hh (separate dummies, not just youngest) -----
 
* any child younger than 3
gen child_under_3 = 0
forval i = 1/10 {
    replace child_under_3 = 1 if age_hh_k_`i' < 3 & age_hh_k_`i' != .
}
	tab child_under_3

* any child between 3 and 6
gen child_3_to_6 = 0
forval i = 1/10 {
    replace child_3_to_6 = 1 if age_hh_k_`i' >= 3 & age_hh_k_`i' <= 6 & age_hh_k_`i' != .
}
	tab child_3_to_6

* any child between 7 and 16
gen child_7_to_16 = 0
forval i = 1/10 {
    replace child_7_to_16 = 1 if age_hh_k_`i' >= 7 & age_hh_k_`i' <= 16 & age_hh_k_`i' != .
}
	tab child_7_to_16


* any child older than 16
gen child_over_16 = 0
forval i = 1/10 {
    replace child_over_16 = 1 if age_hh_k_`i' > 16 & age_hh_k_`i' != .
}
	tab child_over_16

 * ----- children age: 
	* nicht nur in household -----

gen age_k_1 = 2023 - lb0287_v2
gen age_k_2 = 2023 - lb0290_v2
gen age_k_3 = 2023 - lb0293_v2
gen age_k_4 = 2023 - lb0296_v2
gen age_k_5 = 2023 - lb0299_v2
gen age_k_6 = 2023 - lb0302_v2
gen age_k_7 = 2023 - lb0305_v2
gen age_k_8 = 2023 - lb0308_v2
gen age_k_9 = 2023 - lb1139
gen age_k_10 = 2023 - lb1138

sort pid hid
br pid hid age_* lr3192 lb0285 prev_hlk0044_v2 prev_nrkid lb0289_v6 lb0292_v6 lb0295_v6 lb0298_v6 lb0301_v6

  * ----------
    * PARTNER
  * ----------

gen partnr = ppnamlpnr if ppnamlpnr > 0 & ppnamlpnr < . 
replace partnr = ppnamepnr if ppnamepnr > 0 & ppnamepnr < .

gen partnerindicator = 1 if partnr > 0 & partnr < .
tab partnerindicator

gen partner_vorh = plj0629 
replace partner_vorh = 0 if plj0629 == 2
replace partner_vorh = 1 if pld0131_v3 == 1 | pld0131_v3 == 2 & partnerindicator == 1
replace partner_vorh = 2 if partnerindicator != 1 & partner_vorh == 1
replace partner_vorh = 3 if plj0627_v1 == 4 | plj0627_v1 == 5
replace partner_vorh = 3 if plj0630 == 4 | plj0630 == 5

drop partnerindicator 

label var partner_vorh "Partner vorhanden"
#delimit
	label define partner_vorh_lab 
		0 "[0] Kein Partner" 
		1 "[1] Partner vorhanden mit info" 
		2 "[2] Partner vorhanden ohne info" 
		3 "[3] Partner im Ausland"
		, replace;
#delimit cr
label values partner_vorh partner_vorh_lab

tab partner_vorh plj0629

 /* ----- Robustness Checks:
		Death of relatives ----- */

tab1 pld0146 pld0160 pld0163 pld0166 
 * all missing
 
* ------------------------------------------
 
 * save $out_data/suare_v40_variablen.dta, replace
