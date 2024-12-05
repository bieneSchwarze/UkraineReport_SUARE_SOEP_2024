/*------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  
  ******************************************************************************
  ******************************************************************************
  * Joint SUARE Report 2024  												****
  *																			****
  * IAB, BAMF, SOEP  														****
  * -------------------------------------------------------------------------- *
  * Author: Silvia Schwanhäuser  											****
  * Last Modified: Yuliya Kosyakova  											****
  *																			****
  * Date: 			21.08.2024												****
  * Last Modified: 	04.12.2024												****
  ******************************************************************************

  ANALYSIS 
  
------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

capture log close
capture log using "$out_log/suare_v40_analysis_date${date}.log", replace

set more off
clear

global blabel_option format(%9.0f) size(medium) position(outside) color(black)	
global title_opt size(large) position(11) span
global subtitle_opt size(medlarge) position(11) span
global graphregion fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)
global plotregion fcolor(white) lcolor(white)

********************************************************************************


/*
use "/Users/yuliyakosyakova/Data/IAB-BAMF-SOEP/SOEP-CORE_v39/soepdata/ppathl.dta", clear
keep if syear == 2022
merge 1:1 pid syear using "/Users/yuliyakosyakova/Data/IAB-BAMF-SOEP/SOEP-CORE_v39/soepdata/pgen.dta"
keep if _merge == 3

gen age = 2022-gebjahr
keep if age > 17 & age <= 64
keep if inlist(migback,1,3)

recode pgpsbil (-10/-1 = .)
tab pgpsbil [aweight = phrf]

*Mittel-, Haupt- und Realschule: 15.62+32=47.62
*weiterführende Schule (Gymnasien, Fachoberschule u.Ä.): 10.22+38.75=48.93
*sonst: 1.02
*Schule ohne Abschluss verlassen: 0.98+1.26+0.15=2.39


tab pgpsbil if migback == 1 [aweight = phrf]


30,7
64,7
3,2
1,4


*/

use $out_data/SOEP_v40_clean.dta, clear

********************************************************************************
* Variablen für Analyse
********************************************************************************


********************************************************************************
* ANALYSIS SAMPLE
********************************************************************************

******** DROP IF ARRIVAL DATE earlier than Feb 2022 ********
drop if arrival_yr < 2022
drop if arrival_mth < 2 & arrival_yr == 2022	// 13 cases deleted 

********   NUR 18-64 J.a. *********
keep if age > 17 & age <= 64					// 341 cases deleted
drop if kohorte >=.								// 4 cases deleted
 
global weight phrf23vorab_SUARE
 
 
 
 
 
********************************************************************************
********************************************************************************
********************************************************************************

***** I. BILDUNG VOR ZUZUG
********************************************************************************
********************************************************************************
********************************************************************************
tab schul_abschluss_aus
replace schul_abschluss_aus = 3 if school_aus_cert == 4 

recode schul_abschluss_aus (1=1) (2=2) (3=3) (0=4)
#delimit
 label define schul_abschluss_aus 
4 "[4] keinen Schulabschluss"
1 "[1] Hauptschule/ Realschule/ Mittelschule" 
2 "[2] Abitur/Fachhochschulreife/ Weiterfuehrende Schule"
3 "[3] Sonstiges"
		, replace;
#delimit cr
lab val schul_abschluss_aus schul_abschluss_aus


tab prof_edu_YK_aggr
recode prof_edu_YK_aggr (1=4) (2=3) (3=1) (4 5 =2)
#delimit
 label define prof_edu_YK_aggr 
4 "[4] Keine Berufsbildung"
3 "[3] Keine Berufsbildungsabschluss" 
1 "[1] Berufliche Ausbildung"
2 "[2] Hochschule/Universität/Promotion"
		, replace;
#delimit cr
lab val prof_edu_YK_aggr prof_edu_YK_aggr

	
* nach Geschlecht
* ---------------------------------------------------------------------------- *
global var schul_abschluss_aus
#delimit
	table ($var) (female) [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(mean years_sch0) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr


global var prof_edu_YK_aggr
#delimit
	table (prof_edu_YK_aggr) (female) [aweight = $weight], 
		statistic(percent, across(prof_edu_YK_aggr)) 
		statistic(frequency) 
		statistic(mean years_ausbhoch0) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab prof_edu_YK_aggr [aweight = $weight]

* nach Kohorte
* ---------------------------------------------------------------------------- *

global var schul_abschluss_aus
#delimit
	table ($var) (kohorte) [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr


global var prof_edu_YK_aggr
#delimit
	table ($var) (kohorte) [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab female kohorte [aweight = $weight], col nof
tab age_arriv_cat2 kohorte [aweight = $weight], col nof
bys female: tab age_arriv_cat2 kohorte [aweight = $weight], col nof


#delimit
	table (age_cat2) (kohorte) [aweight = $weight], 
		statistic(percent, across(age_cat2)) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr




* 7) Ökonomischem Status vor Zuzug
* ---------------------------------------------------------------------------- *
global var ec_status0
#delimit
	table ($var) (female)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table ($var) (kohorte)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


********************************************************************************
********************************************************************************
********************************************************************************

* 2) Erwerbserfahrung  vor Zuzug
********************************************************************************
********************************************************************************
********************************************************************************

* Erwerbserfahrung
* ---------------------------------------------------------------------------- *
sum work0 wexp0ft wexp0pt wexp0

#delimit
	table () (female) [aweight = $weight], 
		statistic(frequency) 
		statistic(mean work0 wexp0ft wexp0pt wexp0) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (age_cat2) (female) [aweight = $weight], 
		statistic(frequency) 
		statistic(mean work0 wexp0ft wexp0pt wexp0) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


* 3) Art der Erwerbstätigkeit vor Zuzug
* ---------------------------------------------------------------------------- *
global var empl0
#delimit
	table ($var) (female) [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table ($var) (kohorte) [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Tasks
* ---------------------------------------------------------------------------- *
global var haupttask0
#delimit
	table ($var) (female)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table ($var) (kohorte)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


* Berufliche Stellung vor Zuzug - Detailiert
* ---------------------------------------------------------------------------- *
global var niveau0
#delimit
	table ($var) (female)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table ($var) (kohorte)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


** Sektor nach Volkswirtschaftlichen Gesamtrechnung (Aggr. 2)
* ---------------------------------------------------------------------------- *
global var sektor0_aggr2
#delimit
	table ($var) (female)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table ($var) (kohorte)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


********************************************************************************
********************************************************************************
********************************************************************************

***** I. Abschlussanerkennung
********************************************************************************
********************************************************************************
********************************************************************************
tab abschl_an_hochsch_type2, gen(abschl_an_hochsch_)
tab abschl_an_hochsch_type2 female

gen sup_need_annerk1 = sup_need_annerk if abschl_anerkenn <.
gen sup_need_annerk_wo_an = sup_need_annerk if abschl_anerkenn ==0
gen sup_need_annerk_with_an = sup_need_annerk if abschl_anerkenn ==1

#delimit
	table () (female) [aweight = $weight], 
		statistic(mean abschl_an_berufl_type)
		statistic(mean abschl_an_hochsch_2 abschl_an_hochsch_3 abschl_an_hochsch_4)
		statistic(mean abschl_an_hochsch_type)
		statistic(mean abschl_anerkenn)
		statistic(mean sup_need_annerk1)
		statistic(mean sup_need_annerk_wo_an)
		statistic(mean sup_need_annerk_with_an)
		statistic(frequency) 
		nformat(%9.3f) nformat(%9.0f frequency)
		;
#delimit cr
tab abschl_an_hochsch_4 female

reg abschl_an_berufl_type i.female [pweight = $weight]
reg abschl_an_hochsch_2 i.female [pweight = $weight]
reg abschl_an_hochsch_3 i.female [pweight = $weight]
reg abschl_an_hochsch_4 i.female [pweight = $weight]
reg abschl_an_hochsch_type i.female [pweight = $weight]
reg abschl_anerkenn i.female [pweight = $weight]


tab abschl_an_hochsch_type2 kohorte
#delimit
	table () (kohorte) [aweight = $weight], 
		statistic(mean abschl_an_berufl_type)
		statistic(mean abschl_an_hochsch_2 abschl_an_hochsch_3 abschl_an_hochsch_4)
		statistic(mean abschl_an_hochsch_type)
		statistic(mean abschl_anerkenn)
		statistic(mean sup_need_annerk)
		statistic(frequency) 
		nformat(%9.3f) nformat(%9.0f frequency)
		;
#delimit cr

* Bleibeabsichten
#delimit
	table () (settle_intent) [aweight = $weight], 
		statistic(mean sup_need_annerk)
		statistic(mean abschl_anerkenn)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

reg abschl_anerkenn i.settle_intent [aweight = $weight]



preserve

tab abschl_anerkenn, gen(abschl_anerkenn)
collapse abschl_anerkenn1 abschl_anerkenn2 [aw=$weight] , by(settle_intent)

replace abschl_anerkenn1 = abschl_anerkenn1*100
replace abschl_anerkenn2 = abschl_anerkenn2*100

#delimit
	label define settle_intent_lab 
	1 "Für immer in Deutschland" 
	2 "Noch einige Jahre"
	3 "Höchstens noch ein Jahr"
	4 "Unischer"
	, replace;
#delimit cr
label values settle_intent settle_intent_lab

#delimit
	graph hbar (asis) 
		abschl_anerkenn1 abschl_anerkenn2
		, 
		over(settle_intent, label(labsize(medium)) 
		axis(outergap(20))) 
		stack
		showyvars 
		blabel(bar, size(medium) color(white) position(inside) format(%9.1f)) 
		yscale(reverse)
		legend(order(
			1 "Kein Anerkennungsantrag gestellt"
			2 "Anerkennungsantrag gestellt"
			)
			size(medium)
			)
	name(Figure_1, replace)
		;
#delimit cr
graph export "$out_results/Figure_1.png", replace	

restore

** Anerkennung für welche berufe
* ---------------------------------------------------------------------------- *
global var an_vorgesch
#delimit
	table ($var) ()  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(mean sup_need_annerk)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


global var abschl_an_berufgr
#delimit
	table ($var) ()  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency)
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


splitvallabels abschl_an_berufgr, length(60) recode
#delimit
	catplot
		abschl_an_berufgr [aweight = $weight], 
		percent 
		blabel(bar, size(medium) color(white) position(inside) format(%9.1f))
		bar(1, fcolor("$iabg1") )
		var1opts(
			sort(1) descending
			label(labsize(medium) labcolor(black)) 
			relabel(`r(relabel)')
			)
		legend(off) 
		ytitle("") 
		graphregion($graphregion) 
		plotregion($plotregion)
		ylabel(0(10)40, labsize(medium) labcolor(black)) 
		yscale(r(0 40))
		l1title("")
		name(Figure_2, replace) 
		;
#delimit cr
graph export "$out_results/Figure_2.png", replace	
		
global var abschl_an_berufgr
#delimit
	table ($var) (female)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency)
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr
				
preserve

import delimited "$do/statistik_engpass_20241113223933.csv",  clear 
keep v1 v2 v3
ren v1 kldb4
ren v2 beruf
ren v3 bewertung

destring bewertung, replace force dpcomma
keep if bewertung <.
destring kldb4, replace 
save $out_data/engpass.dta, replace
restore

gen kldb4 = int(abschl_an_kldb/10)
merge m:1 kldb4 using $out_data/engpass.dta
keep if _merge != 2
gen engpass = _merge == 3 
replace engpass = . if abschl_an_kldb>=.

tab engpass [aweight = $weight]
tab engpass female [aweight = $weight], col


** Gründe für Nicht Anerkennungsbeantragung
* ---------------------------------------------------------------------------- *
global var abschl_anerkenn
#delimit
	table ($var) ()  [aweight = $weight], 
		statistic(mean sup_need_annerk) 
		statistic(frequency)
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

global var kein_abschl_an
lab var sup_need_annerk "Hilfe bei Anerk. benöt"
#delimit
	table ($var) ()  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(mean sup_need_annerk) 
		statistic(frequency)
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


#delimit
	label define kein_abschl_an_lab
		1   "Unklarheit über Antragsverfahren"
        2   "Finanzierungsprobleme"
        3   "Fehlende Dokumente"
        4   "Zu hoher Aufwand/Bürokratie"
        5   "Keine Aussicht auf Anerkennung"
        6   "Andere Gründe"
        7   "Berufsausübung ohne Anerkennung möglich"
        8   "Kein erwarteter Nutzen"
		, replace;
#delimit cr
label values kein_abschl_an kein_abschl_an_lab

splitvallabels kein_abschl_an, length(60) recode
#delimit
	catplot
		kein_abschl_an [aweight = $weight], 
		percent 
		blabel(bar, size(medium) color(white) position(inside) format(%9.1f))
		bar(1, fcolor("$iabg1") )
		var1opts(
			sort(1) descending
			label(labsize(medium) labcolor(black)) 
			relabel(`r(relabel)')
			)
		legend(off) 
		ytitle("") 
		graphregion($graphregion) 
		plotregion($plotregion)
		ylabel(0(10)40, labsize(medium) labcolor(black)) 
		yscale(r(0 45))
		l1title("")
		name(Figure_3, replace) 
		;
#delimit cr
graph export "$out_results/Figure_3.png", replace	





** Ergebniss der Anerkennung
* ---------------------------------------------------------------------------- *
recode abschl_an_result 5=1
global var abschl_an_result
#delimit
	table ($var) ()  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

sum an_dauer [aweight = $weight], d
tab an_dauer [aweight = $weight]

* censored cases?
gen an_dauer_cens = an_dauer
replace an_dauer_cens = intv_year_month - an_dauer_s if an_dauer_cens>=.
recode an_dauer_cens (-1=0) (100/max=.)

tab an_dauer_cens [aweight = $weight]



********************************************************************************
********************************************************************************
********************************************************************************

***** I. Bildungserwerb
********************************************************************************
********************************************************************************
********************************************************************************

***** I. Bildungsaspirationen
* ---------------------------------------------------------------------------- *
global var future_school_edu
#delimit
	table () ($var)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

global var future_prof_edu
#delimit
	table ()  ($var)  [aweight = $weight], 
		statistic(percent, across($var)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


recode future_school_edu future_prof_edu (1 2 = 1) (3=0)
label define edu_as 0 "Nein" 1 "Ja"
label values future_school_edu future_prof_edu edu_as

tab future_school_edu, gen(school_asp)
tab future_prof_edu, gen(profedu)
lab var school_asp2 "school, yes"
lab var school_asp1 "school, no"
lab var profedu2 "prof, yes"
lab var profedu1 "prof, no"

replace school_asp2 = school_asp2*100
replace school_asp1 = school_asp1*100
replace profedu2 = profedu2*100
replace profedu1 = profedu1*100

tab future_school_edu female
tab future_prof_edu female

#delimit
	table (female) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab future_school_edu age_cat
tab future_prof_edu age_cat
#delimit
	table (age_cat) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab schul_abschluss_aus future_school_edu 
tab schul_abschluss_aus future_prof_edu 
#delimit
	table (schul_abschluss_aus) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab prof_edu_YK_aggr future_school_edu 
tab prof_edu_YK_aggr future_prof_edu 

#delimit
	table (prof_edu_YK_aggr) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab settle_intent future_school_edu 
tab settle_intent future_prof_edu 
#delimit
	table (settle_intent) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab kohorte future_school_edu 
tab kohorte future_prof_edu 
#delimit
	table (kohorte) ( )  [aweight = $weight], 
		statistic(mean school_asp2) 
		statistic(mean school_asp1) 
		statistic(mean profedu2) 
		statistic(mean profedu1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr


reg future_school_edu i.female i.age_cat i.schul_abschluss_aus i.prof_edu_YK_aggr i.kohorte [aweight = $weight]
reg future_prof_edu i.female i.age_cat i.schul_abschluss_aus i.prof_edu_YK_aggr i.kohorte [aweight = $weight]




***** I. Bildungserwerb
* ---------------------------------------------------------------------------- *
replace edu_de_type_curr = 0 if edu_de_curr==0
tab edu_de_type_curr, gen(edu_de_type_curr)
lab var edu_de_type_curr2 "allg. schule"
lab var edu_de_type_curr3 "hochschule"
lab var edu_de_type_curr4 "beruf. schule"
lab var edu_de_type_curr5 "fort/weiterbildung"

tab female edu_de_curr
tab female edu_de_type_curr

reg edu_de_curr i.female [pweight = $weight]

replace edu_de_curr = edu_de_curr*100
replace edu_de_type_curr2 = edu_de_type_curr2*100
replace edu_de_type_curr3 = edu_de_type_curr3*100
replace edu_de_type_curr4 = edu_de_type_curr4*100
replace edu_de_type_curr5 = edu_de_type_curr5*100

#delimit
table (female) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr) 
		statistic(mean edu_de_type_curr2) 
		statistic(mean edu_de_type_curr3) 
		statistic(mean edu_de_type_curr4) 
		statistic(mean edu_de_type_curr5) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab edu_de_curr, gen(edu_de_curr)
replace edu_de_curr2 = edu_de_curr2*100
replace edu_de_curr1 = edu_de_curr1*100

tab edu_de_curr age_cat
#delimit
	table (age_cat) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab schul_abschluss_aus edu_de_curr 
#delimit
	table (schul_abschluss_aus) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab prof_edu_YK_aggr edu_de_curr 

#delimit
	table (prof_edu_YK_aggr) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab settle_intent edu_de_curr 
#delimit
	table (settle_intent) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab kohorte edu_de_curr 
#delimit
	table (kohorte) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr

tab kohorte edu_de_curr 
#delimit
	table (de_kenntnisse) ( )  [aweight = $weight], 
		statistic(mean edu_de_curr2 edu_de_curr1) 
		statistic(frequency) 
		nformat(%9.1f) nformat(%9.0f frequency)
		;
#delimit cr



reg edu_de_curr i.female i.age_cat i.schul_abschluss_aus i.prof_edu_YK_aggr i.kohorte i.settle_intent i.de_kenntnisse c.mnth_s_arvl_cat1 [aweight = $weight]


