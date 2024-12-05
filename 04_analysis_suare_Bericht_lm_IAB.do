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
capture log using "$out_log/suare_v40_analysis_lm_date${date}.log", replace

set more off
clear

********************************************************************************

use $out_data/SOEP_v40_clean.dta, clear  

********************************************************************************
* ANALYSIS SAMPLE
********************************************************************************

******** DROP IF ARRIVAL DATE earlier than Feb 2022 ********
drop if arrival_yr < 2022
drop if arrival_mth < 2 & arrival_yr == 2022	// 13 cases deleted 

********   NUR 18-64 J.a. *********
keep if age > 17 & age <= 64					// 341 cases deleted
 
 
 
********************************************************************************
***** Erwerbstätigenquote nach dem Monat des Interviews und Geschlecht *
******************************************************************************** 
 ******************************************************************************* 
 
bysort mon_int: tab paid_work female [aweight = phrf23vorab_SUARE] , col row
 
********************************************************************************
* Befristet/unbefristet und Arbeitnehmerüberlassung nach dem Zuzug
********************************************************************************
 
fre work_befrist work_leih [aweight = phrf23vorab_SUARE] 
 
********************************************************************************
***** I. ERWERB UND BILDUNG VOR ZUZUG
********************************************************************************
* 1) Erwerbstätigkeit vor Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table female [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work0) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr    /*im Text, ohne Grafik*/


* Viel höherer Anteil an Personen mit Erwerbserfahrung? Können wir uns das 
* irgendwie erklären, oder stimmt etwas mit der Kodierung nicht?

#delimit
	table (empl0) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr /*im Text, ohne Grafik*/


* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *
/*nicht verwendet*/
#delimit
	table kohorte [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work0) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (empl0) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr



* ---------------------------------------------------------------------------- *
* Tätigkeitsniveau vor Zuzug 
* ---------------------------------------------------------------------------- *

tab niveau0 [aweight = phrf23vorab_SUARE]
tab niveau0 female [aweight = phrf23vorab_SUARE], col row   /*eine Grafik*/
tab niveau0 kohorte [aweight = phrf23vorab_SUARE], col row
bysort female: tab niveau0 kohorte [aweight = phrf23vorab_SUARE], col row



* ---------------------------------------------------------------------------- *
*  Tätigkeit nach Autor
* ---------------------------------------------------------------------------- *

tab haupttask0 [aweight = phrf23vorab_SUARE]
tab haupttask0 female [aweight = phrf23vorab_SUARE], col row
tab haupttask0 kohorte [aweight = phrf23vorab_SUARE], col row
bysort female: tab haupttask0 kohorte [aweight = phrf23vorab_SUARE], col row

* ---------------------------------------------------------------------------- *
* Berufsgruppe 
* ---------------------------------------------------------------------------- *

tab berufgr0 [aweight = phrf23vorab_SUARE]
tab berufgr0 female [aweight = phrf23vorab_SUARE], col row
fre berufgr0 [aweight = phrf23vorab_SUARE] if kohorte==1
fre berufgr0 [aweight = phrf23vorab_SUARE] if kohorte==2

* ---------------------------------------------------------------------------- *
* 10 häufigsten Berufe nach Geschlecht
* ---------------------------------------------------------------------------- *

tab kldb0 if female==1 [aweight = phrf23vorab_SUARE], sort
tab kldb0  if female==0 [aweight = phrf23vorab_SUARE], sort

tab kldb0_2010_3 if female==1 [aweight = phrf23vorab_SUARE], sort
tab kldb0_2010_3 if female==0 [aweight = phrf23vorab_SUARE], sort
* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit vor Zuzug nach Bildung 
* ---------------------------------------------------------------------------- *

#delimit
	table isceda11a [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work0)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr
* Verteilung sehr ähnlich zu ersten Ergebnissen aus Welle 1 und 2, aber auch hier
* westentlich höher. 

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit vor Zuzug nach Familienstand
* ---------------------------------------------------------------------------- *

#delimit
	table partnership [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work0) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr
* Ergebnisse sehr ähnlich zu Welle 1 und 2 aber auch hier wesentlich höherere 
* Erwerbsquote.

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit vor Zuzug nach Kind/Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (children) (female) [aweight = phrf23vorab_SUARE],
		statistic(mean work0)
		statistic(percent, across(children)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 2) Bildung  vor Zuzug
********************************************************************************

********************************************************************************
** ISCED A 2011 vor Zuzug
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (isceda11a) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(isceda11a)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (isceda11a) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(isceda11a)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Berufliche Bildung (besucht)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (qual_type) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(qual_type)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (qual_type) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(qual_type)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Berufliche Bildung (mit Zeugnis)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (beruf_aus_cert) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(beruf_aus_cert)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (beruf_aus_cert) (kohorte) [aweight=phrf23vorab_SUARE], 
		statistic(percent, across(beruf_aus_cert)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 3) Art der Erwerbstätigkeit vor Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (empl0_aggr) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl0_aggr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (empl0_aggr) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl0_aggr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 4) Branche/Sektor der Erwerbstätigkeit vor Zuzug
********************************************************************************

********************************************************************************
** Sektor nach Volkswirtschaftlichen Gesamtrechnung (Aggr. 1)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (branch0_vgr) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(branch0_vgr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (branch0_vgr) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(branch0_vgr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Sektor nach Volkswirtschaftlichen Gesamtrechnung (Aggr. 2)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (sektor0_aggr2) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(sektor0_aggr2)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (sektor0_aggr2) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(sektor0_aggr2)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 5) Berufliche Stellung vor Zuzug - Detailiert
********************************************************************************

tab l_isco08_job09 [aweight = phrf23vorab_SUARE]

********************************************************************************
* 6) Tätigkeitsniveau vor Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (niveau0) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(niveau0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (niveau0) (kohorte)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(niveau0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 7) Ökonomischem Status vor Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (ec_status0) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(ec_status0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (inc_status0) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(inc_status0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
***** II. ERWERB NACH ZUZUG
********************************************************************************
* 1) Erwerbsquote nach Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* Erwerbsquote allgemein
* ---------------------------------------------------------------------------- *

tab work [aweight = phrf23vorab_SUARE]
tab paid_work [aweight = phrf23vorab_SUARE]


********************************************************************************
** 51 % der Frauen mit Kindern wohnen ohne Partner im Haushalt
********************************************************************************

tab partner_in_hh if h_child_hh==1 & female==1  [aweight = phrf23vorab_SUARE]


* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table female [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table female [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean paid_work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table kohorte [aweight = phrf23vorab_SUARE], 
		statistic(percent)
		statistic(mean work)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table kohorte [aweight = phrf23vorab_SUARE], 
		statistic(percent)
		statistic(mean paid_work)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


* ---------------------------------------------------------------------------- *
* nach Geschlecht und Partner im Haushalt
* ---------------------------------------------------------------------------- *

#delimit
	table female partner_in_hh [aweight = phrf23vorab_SUARE], 
		statistic(percent)
		statistic(mean paid_work)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

bysort female: tab partner_in_hh paid_work [aweight = phrf23vorab_SUARE], col row

* ---------------------------------------------------------------------------- *
* nach Geschlecht und Aufenthaltsdauer
* ---------------------------------------------------------------------------- *

#delimit
	table (mnth_s_arvl_cat2) (female) [aweight = phrf23vorab_SUARE], 
		statistic(mean work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Geschlecht und Aufenthaltsdauer
* ---------------------------------------------------------------------------- *

#delimit
	table (mnth_s_arvl_cat2) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(mean work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit nach Bildung 
* ---------------------------------------------------------------------------- *

#delimit
	table isceda11a [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr 

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit nach Familienstand
* ---------------------------------------------------------------------------- *

#delimit
	table partnership [aweight = phrf23vorab_SUARE], 
		statistic(percent) 
		statistic(mean work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit nach Kind/Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (children) (female) [aweight = phrf23vorab_SUARE],
		statistic(mean work)
		statistic(percent, across(children)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (h_child_age) (female) [aweight = phrf23vorab_SUARE],
		statistic(mean work)
		statistic(percent, across(h_child_age)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit nach Kind/Familienstand
* ---------------------------------------------------------------------------- *

#delimit
	table (partner_in_hh) (h_child_age) if female == 1 [aweight = phrf23vorab_SUARE],
		statistic(percent, across(h_child_age)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (partner_in_hh) (h_child_age) if female == 0 [aweight = phrf23vorab_SUARE],
		statistic(percent, across(h_child_age)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (partner_in_hh) (children) [aweight = phrf23vorab_SUARE],
		statistic(mean paid_work)
		statistic(percent, across(children)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Erwerbstätigkeit nach Zuzug nach Haushaltskonstellation
* ---------------------------------------------------------------------------- *

#delimit
	table (hh_const) (female)  [aweight = phrf23vorab_SUARE], 
		statistic(mean paid_work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 5) Erwerbstätigkeit nach Geschlecht und Alter der Kinder im Haushalt
********************************************************************************

recode h_child_age (1=1)(2=2)(3=3)(4 5=4), gen(h_child_age4)
lab var h_child_age4 "Kinder im Haushalt nach Alter - 4 Kategorien"
lab define h_child_age4 1"Keine Kinder" 2"Kind 0-3" 3"Kind 3-6" 4"Kind 7-17"
label values h_child_age4  h_child_age4 
tab h_child_age h_child_age4 

#delimit
	table female h_child_age4 [aweight = phrf23vorab_SUARE] if age>=18 & age<=64 & kohorte==1, 
		statistic(percent) 
		statistic(mean work) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


********************************************************************************
* Derzeitiger Status (nach Zuzug)
********************************************************************************

tab lfs_status_dtl kohorte [aweight = phrf23vorab_SUARE], col row



********************************************************************************
* 2) Art der Erwerbstätigkeit nach Zuzug
********************************************************************************

#delimit
	table (actual_empl) if actual_empl != 9 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(actual_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (actual_empl) (female) if actual_empl != 9 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(actual_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (actual_empl) (kohorte) if actual_empl != 9 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(actual_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 3) Berufliche Stellung nach Zuzug
********************************************************************************

#delimit
	table (empl_type) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl_type)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr



********************************************************************************
* Sektor nach Zuzug - nach kldb 10 Sektoren
********************************************************************************
fre berufgr [aweight = phrf23vorab_SUARE]
fre berufgr [aweight = phrf23vorab_SUARE] if kohorte==1
fre berufgr [aweight = phrf23vorab_SUARE] if kohorte==2


* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (empl_type) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl_type)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (empl_type) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(empl_type)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 4) Berufliches Tätigkeitsniveau nach Zuzug
********************************************************************************
** Niveau der Erwerbstätigkeit nach ISCO
* ---------------------------------------------------------------------------- *

#delimit
	table isco_oesch5 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(isco_oesch5)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (isco_oesch5) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(isco_oesch5)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (isco_oesch5) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(isco_oesch5)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* 5 häufigsten Berufe nach Geschlecht
* ---------------------------------------------------------------------------- *

tab kldb if female==1 [aweight = phrf23vorab_SUARE], sort
tab kldb  if female==0 [aweight = phrf23vorab_SUARE], sort

tab kldb_2010_3 if female==1 [aweight = phrf23vorab_SUARE], sort
tab kldb_2010_3 if female==0 [aweight = phrf23vorab_SUARE], sort

*10 häufigsten Berufsgruppen nach dem Zuzug - ohne Geschlecht

tab kldb_2010_3 [aweight = phrf23vorab_SUARE], sort

********************************************************************************
** Niveau der Erwerbstätigkeit nach KLDB
* ---------------------------------------------------------------------------- *

#delimit
	table niveau [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(niveau)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


fre niveau [aweight = phrf23vorab_SUARE]

tab niveau female [aweight = phrf23vorab_SUARE], col row


* ---------------------------------------------------------------------------- *
* nach Bleibeabsichten
* ---------------------------------------------------------------------------- *
recode niveau (1=1) (2=2) (3/4=3), gen(niveau_3)
label var niveau_3 "Tätigkeits Niveau 3 Kategorien"
label define niveau_3 1 "Helfer" 2"Fachkraft" 3"Experte/Spezialist"
label values niveau_3 niveau_3 

* new
gen bleib = bleibeabsichten == 1 if bleibeabsichten<.

tab bleib niveau_3 [aweight = phrf23vorab_SUARE], col row

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (niveau) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(niveau)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

*** Tätigkeitsniveau nach Autor nach dem Zuzug ***

tab haupttask [aweight = phrf23vorab_SUARE]
tab haupttask female [aweight = phrf23vorab_SUARE], col row
tab haupttask kohorte [aweight = phrf23vorab_SUARE], col row
bysort female: tab haupttask kohorte [aweight = phrf23vorab_SUARE], col row


* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (niveau) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(niveau)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Berufe nach KLDB
* ---------------------------------------------------------------------------- *
* nach Geschlecht und Kohorte
* ---------------------------------------------------------------------------- *

tab kldb if kohorte == 1 & female == 1 [aweight = phrf23vorab_SUARE], sort
tab kldb if kohorte == 1 & female == 0 [aweight = phrf23vorab_SUARE], sort
tab kldb if kohorte == 2 & female == 1 [aweight = phrf23vorab_SUARE], sort
tab kldb if kohorte == 2 & female == 0 [aweight = phrf23vorab_SUARE], sort

********************************************************************************
* 5) Branche/Sektor der Erwerbstätigkeit nach Zuzug
********************************************************************************

********************************************************************************
** Sektor nach Volkswirtschaftlichen Gesamtrechnung (Aggr. 1)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (branch_vgr) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(branch_vgr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (branch_vgr) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(branch_vgr)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Sektor nach Volkswirtschaftlichen Gesamtrechnung (Aggr. 2)
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (sektor_aggr2) (female)[aweight = phrf23vorab_SUARE], 
		statistic(percent, across(sektor_aggr2)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (sektor_aggr2) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(sektor_aggr2)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 6) Match / Missmatch der Erwerbstätigkeit nach Zuzug
********************************************************************************

* ---------------------------------------------------------------------------- *
* relativ zu früheren Erwerbstätigkeit nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (match_work0) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(match_work0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

bysort female: tab match_work0 kohorte [aweight = phrf23vorab_SUARE], col row

#delimit
	table (match_work0) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(match_work0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

*Grafik alle

tab match_work0 female [aweight = phrf23vorab_SUARE], col row


* ---------------------------------------------------------------------------- *
* relativ zu früheren Bildung nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (match_edu0) (female) [aweight=phrf23vorab_SUARE], 
		statistic(percent, across(match_edu0)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr
* Ich glaube hier stimmt etwas nicht, weil Differenz zu groß ist

********************************************************************************
* 7) Löhne
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (female) [aweight = phrf23vorab_SUARE], 
		statistic(median work_blohn) 
		statistic(median work_nlohn) 
		statistic(median work_blohn_hour) 
		statistic(median work_nlohn_hour) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

*tabelle Löhne und Sozialleistungsempfang

*Bruttomonatslohn, female
sum work_blohn if work_blohn >0 & work_blohn <. [aweight = phrf23vorab_SUARE], detail

bysort female: sum work_blohn if work_blohn >0 & work_blohn <. [aweight = phrf23vorab_SUARE], detail


*Bruttomonatslohn Vollzeit, female
sum work_blohn if work_blohn >0 & work_blohn <. & vollzeit==1 [aweight = phrf23vorab_SUARE], detail

bysort female: sum work_blohn if work_blohn >0 & work_blohn <. & vollzeit==1 [aweight = phrf23vorab_SUARE], detail


*Bruttostundenlohn, female
sum work_blohn_hour if work_blohn_hour >0 & work_blohn_hour <. [aweight = phrf23vorab_SUARE], detail

bysort female: sum work_blohn_hour if work_blohn_hour >0 & work_blohn_hour <. [aweight = phrf23vorab_SUARE], detail


*Bruttostundenlohn Vollzeit, female
sum work_blohn_hour if work_blohn_hour >0 & work_blohn_hour <. & vollzeit==1 [aweight = phrf23vorab_SUARE], detail

bysort female: sum work_blohn_hour if work_blohn_hour >0 & work_blohn_hour <. & vollzeit==1 [aweight = phrf23vorab_SUARE], detail


*Sozialleistungsempfang

tab hh_leistungen [aweight = phrf23vorab_SUARE]

bysort female: tab hh_leistungen [aweight = phrf23vorab_SUARE]

*Sozialleistungsempfang unter erwerbstätigen

tab hh_leistungen if paid_work==1 [aweight = phrf23vorab_SUARE]

bysort female: tab hh_leistungen if paid_work==1 [aweight = phrf23vorab_SUARE]


* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(median work_blohn) 
		statistic(median work_nlohn) 
		statistic(median work_blohn_hour) 
		statistic(median work_nlohn_hour) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Geschlecht und Beschäftungsart
* ---------------------------------------------------------------------------- *

#delimit
	table (female) (vollzeit) [aweight = phrf23vorab_SUARE] 
		if work_blohn > 0 & empl_type != 1 & work_blohn <., 
		statistic(median work_blohn) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Evtl. hier noch etwas zu Level unter Mindeslohn oder mehr Info zu Stunden?
* Überstunden work_hours_contract work_hours_actual

********************************************************************************
* 8) Qualität der Arbeit
********************************************************************************

********************************************************************************
** Berfistung
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (work_befrist) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(work_befrist)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (work_befrist) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(work_befrist)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
***** III. ERWERBSLOSIGKEIT NACH ZUZUG
********************************************************************************
* 1) Arbeitssuchenden- und Arbeitslosenquote
********************************************************************************

********************************************************************************
** Anteil Arbeitssuchender/Nicht-Arbeitssuchender
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (lfs_status) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (lfs_status) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Anteil arbeitslos gemeldeter
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (arbeitslos) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(arbeitslos)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (arbeitslos) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(arbeitslos)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 2) Erwerbsorientierung und -aspirationen
********************************************************************************

tab future_empl kohorte [aweight = phrf23vorab_SUARE], col row
tab future_empl1 kohorte [aweight = phrf23vorab_SUARE], col row

********************************************************************************
** Erwerbsabsichten
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (future_empl) (female) if future_empl > 0 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (future_empl) (kohorte) if future_empl > 0 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Zeitpunkt der Erwerbsabsichten
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (timing_future_empl) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(timing_future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (timing_future_empl) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(timing_future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
** Gewünschte Erwerbsform
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (type_future_empl) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(type_future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (type_future_empl) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(type_future_empl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
* 3) Leistungsempfang und Trägerkontakte
********************************************************************************

********************************************************************************
** Leistungsempfang
* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (hh_leistungen) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(hh_leistungen)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (hh_leistungen) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(hh_leistungen)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Aufenthaltsdauer
* ---------------------------------------------------------------------------- *

#delimit
	table (hh_leistungen) (mnth_s_arvl_cat2) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(hh_leistungen)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

**** andere Kriterien

tab hh_leistungen children [aweight = phrf23vorab_SUARE], col row
tab hh_leistungen berufgr0 [aweight = phrf23vorab_SUARE], col row
tab hh_leistungen de_kenntnisse [aweight = phrf23vorab_SUARE], col row
tab hh_leistungen niveau0 [aweight = phrf23vorab_SUARE], col row
tab hh_leistungen paid_work [aweight = phrf23vorab_SUARE], col row

* Hier auch noch höhe der Leistungen? Müsste dann aber durch die Anzahl der
* Haushaltsmitglieder gerechnet werden, da auf der HH Ebene

********************************************************************************
** Leistungsempfang pro Haushalt
* ---------------------------------------------------------------------------- *

preserve
keep hid h_child_hh hh_leistungen hhrf23vorab_SUARE
duplicates drop

tab hh_leistungen h_child_hh [aweight = hhrf23vorab_SUARE], col row
restore

********************************************************************************
* 4) Jobsuche
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

#delimit
	table (job_search) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(job_search)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

#delimit
	table (job_search) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(job_search)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Soll hier noch mehr zu den Suchwegen kommen bzw. zu Trägerkontakten?

********************************************************************************
* 5) Verschiedene Arbeitsmarktrelevante Ergebnisse
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

* Aktuell erwerbstätig
#delimit
	table (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean work)
		statistic(mean lmactivity)
		statistic(mean paid_work)
		statistic(mean vollzeit)
		statistic(mean geringf) 
		statistic(mean selfem)
		statistic(mean work_befrist) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Aktuell erwerbslos
#delimit
	table (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean job_search)
		statistic(mean future_empl_dum)
		statistic(mean arbeitslos)
		statistic(mean hh_leistungen)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Abschlussanerkennung
#delimit
	table (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean sup_need_annerk)
		statistic(mean abschl_anerkenn)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Nach Geschlecht und Aufenthaltsdauer
* ---------------------------------------------------------------------------- *

* Aktuell erwerbstätig
#delimit
	table (female) (mnth_s_arvl_cat2) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean work)
		statistic(mean lmactivity)
		statistic(mean paid_work)
		statistic(mean vollzeit)
		statistic(mean geringf) 
		statistic(mean selfem)
		statistic(mean work_befrist) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Aktuell erwerbslos
#delimit
	table (female) (mnth_s_arvl_cat2) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean job_search)
		statistic(mean future_empl_dum)
		statistic(mean arbeitslos)
		statistic(mean hh_leistungen)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Abschlussanerkennung
#delimit
	table (female) (mnth_s_arvl_cat2) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(female)) 
		statistic(mean sup_need_annerk)
		statistic(mean abschl_anerkenn)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* Nach Kohorte
* ---------------------------------------------------------------------------- *

* Aktuell erwerbstätig
#delimit
	table (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(kohorte)) 
		statistic(mean work)
		statistic(mean lmactivity)
		statistic(mean paid_work)
		statistic(mean vollzeit)
		statistic(mean geringf) 
		statistic(mean selfem)
		statistic(mean work_befrist) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Aktuell erwerbslos
#delimit
	table (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(kohorte)) 
		statistic(mean job_search)
		statistic(mean future_empl_dum)
		statistic(mean arbeitslos)
		statistic(mean hh_leistungen)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Abschlussanerkennung
#delimit
	table (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(kohorte)) 
		statistic(mean sup_need_annerk)
		statistic(mean abschl_anerkenn)
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

********************************************************************************
***** IV. WEITERE AKTIVITÄTEN NACH ZUZG
********************************************************************************
* 1) Aktivitätsarten
********************************************************************************

* ---------------------------------------------------------------------------- *
* nach Geschlecht
* ---------------------------------------------------------------------------- *

* Ohne Erwerbstätige
#delimit
	table (lfs_status_dtl) (female) if lfs_status_dtl != 1 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status_dtl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Mit Erwerbstätigen
#delimit
	table (lfs_status_dtl) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status_dtl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* ---------------------------------------------------------------------------- *
* nach Kohorte
* ---------------------------------------------------------------------------- *

* Ohne Erwerbstätige
#delimit
	table (lfs_status_dtl) (kohorte) if lfs_status_dtl != 1 [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status_dtl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

* Mit Erwerbstätigen
#delimit
	table (lfs_status_dtl) (kohorte) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(lfs_status_dtl)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr



********************************************************************************
*** Aktiv arbeitssuchende
********************************************************************************

tab1 female age_cat2 bleibeabsichten kohorte berufgr0 [aweight = phrf23vorab_SUARE] if job_search==1

tab1 ne_jsearch_service ne_jsearch_ad ne_jsearch_fam_fr ne_jsearch_n if job_search==1 [aweight = phrf23vorab_SUARE]

global suchevar "ne_jsearch_service ne_jsearch_ad ne_jsearch_fam_fr ne_jsearch_n"

* Unterschiede nach Geschlecht
foreach suche of varlist $suchevar { 
#delimit
		table (`suche') (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(`suche')) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr
}

********************************************************************************
*** Sozialleistungsempfänger: Unterstützungsbedarfe
********************************************************************************
fre sup_need* [aweight = phrf23vorab_SUARE] if hh_leistungen ==1 
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==1  & h_child_age_0_2==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==1  & h_child_age_3_6==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==1  & (h_child_age==4 | h_child_age==5)


fre sup_need* [aweight = phrf23vorab_SUARE] if hh_leistungen ==0 
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==0  & h_child_age_0_2==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==0  & h_child_age_3_6==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if hh_leistungen ==0  & (h_child_age==4 | h_child_age==5)

tab hh_leistungen lfs_status_dtl [aweight = phrf23vorab_SUARE], col row


********************************************************************************
*** Unterstützungsbedarfe der nicht-erwerbstätigen
********************************************************************************

fre sup_need* [aweight = phrf23vorab_SUARE] if paid_work!=1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if paid_work!=1 & h_child_age_0_2==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if paid_work!=1 & h_child_age_3_6==1
fre sup_need_kindbetr [aweight = phrf23vorab_SUARE] if paid_work!=1 & (h_child_age==4 | h_child_age==5)



********************************************************************************
* ---------------------------------------------------------------------------- *
* Übergang zum Job: nach Kohorte und Geschlecht
* ---------------------------------------------------------------------------- *
********************************************************************************


*stset paid_work or job1st

gen sample_job1st = 1 if job1st <.
replace sample_job1st =. if phrf23vorab_SUARE== 0
replace sample_job1st =. if arrival_date>= .
replace sample_job1st =. if job1st_date_corrected_cens>= .

gen tf = job1st_date_corrected_cens-arrival_date
recode tf 0=0.5
fre tf
stset tf if sample_job1st == 1 [iweight=phrf23vorab_SUARE], failure(job1st)  id(pid) 

**Kaplan-Meier**

*kohorte*
#delimit 
sts graph, failure 
	by(kohorte) 
	//tmin(740) tmax(770) 
	ylabel(0.30 (0.05) 0, nogrid) 
	legend(position(6) rows(1) 
		order(
		1 "Zuzug vom Ferbuar bis Mai 2022" 
		2 "Zuzug nach Juni 2022"
		))
	//xlabel(, format(%tm))
	;
#delimit cr
sts test kohorte

preserve
*for excel
sts list, failure by(kohorte) saving($AVZ/results/kaplan-meier2023-kohorte.dta, replace)
use $AVZ/results/kaplan-meier2023-kohorte.dta, clear
export excel using $AVZ/results/kaplan-meier2023-kohorte, replace firstrow(variables)
erase $AVZ/results/kaplan-meier2023-kohorte.dta
restore


*female*
#delimit
	sts graph, failure 
	by(female) 
	//tmin(740) tmax(770) 
	ylabel(0.35 (0.05) 0, nogrid) 
	legend(position(6) rows(1) 
		order(
			1 "Männer" 
			2 "Frauen"
			)) 
	//xlabel(, format(%tm))
	;
#delimit cr
sts test female

preserve
*for excel
sts list, failure by(female) saving($AVZ/results/kaplan-meier2023-female.dta, replace)
use $AVZ/results/kaplan-meier2023-female.dta, clear
export excel using $AVZ/results/kaplan-meier2023-female, replace firstrow(variables)
erase $AVZ/results/kaplan-meier2023-female.dta
restore

*female + kohorte*

gen female_kohorte= 1 if female==1 & kohorte==1
replace female_kohorte=2 if female==1 & kohorte==2
replace female_kohorte=3 if female==0 & kohorte==1
replace female_kohorte=4 if female==0 & kohorte==2
label var female_kohorte "Geschlecht und Kohorte"
#delimit 
label define female_kohorte 
	1 "Frauen, Zuzug Ferbuar-Mai 2022"
	2 "Frauen, Zuzug nach Juni 2022"
	3 "Männer, Zuzug Februar-Mai 2022"
	4 "Männer, Zuzug nach Juni 2022"
;
#delimit cr
label values female_kohorte female_kohorte
fre female_kohorte 

*sts graph
#delimit
	sts graph, failure 
	by(female_kohorte) 
	//tmin(745) tmax(770) 
	ylabel(0.35 (0.05) 0, nogrid) 
	scheme(plotplain)
	plot1opts(recast(line) c(l) lpattern(dash) lcolor(gs10)) 
	plot2opts(recast(line) c(l) lpattern(solid) lcolor(black))
	legend(position(6) rows(4) 
			order(
			1 "Frauen, Zuzug Ferbuar-Mai 2022"
			2 "Frauen, Zuzug nach Juni 2022"
			3 "Männer, Zuzug Februar-Mai 2022"
			4 "Männer, Zuzug nach Juni 2022"
			)) 
	//xlabel(, format(%tm))
	;
#delimit cr


preserve
*for excel
sts list, failure by(female_kohorte) saving($AVZ/results/kaplan-meier2023.dta, replace)
use $AVZ/results/kaplan-meier2023.dta, clear
export excel using $AVZ/results/kaplan-meier2023-1, replace firstrow(variables)
erase $AVZ/results/kaplan-meier2023.dta
restore

********************************************************************************
* 9) Jobfindung
********************************************************************************

#delimit
	table (jb1_jsearch) (female) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(jb1_jsearch)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr

#delimit
	table (search_first_job2) [aweight = phrf23vorab_SUARE], 
		statistic(percent, across(search_first_job2)) 
		statistic(frequency) 
		nformat(%9.2f) nformat(%9.0f frequency)
		;
#delimit cr


********************************************************************************
********************************************************************************
********************************************************************************

***** V. MULTIVARIATE ERGEBNISSE ZU BESCHÄFTUNG UND LÖHNEN
********************************************************************************
********************************************************************************
********************************************************************************
drop if phrf23vorab_SUARE>=.
drop if phrf23vorab_SUARE==0
drop if paid_work>=.

gen niveau0_new = niveau0
replace niveau0_new = 0 if work0 == 0

recode partner_in_hh (1=1) (0=0) (2/3=0), gen(partner_dummy)
label var partner_dummy "Partner im Haushalt: (1)ja/(0)nein"

clonevar kontakt_de_s=kontakt_de

gen willk1 = willkommen1_det <=2 if willkommen1_det<.
label var willk1 "Willkommensgefühl jetzt: (0) Nein / (1) ja"
gen willk0 = willkommen0_det <=2 if willkommen0_det<.
label var willk0 "Willkommensgefühl jetzt: (0) Nein / (1) ja"

recode prof_edu_YK_aggr (1/2=1)(3=2)(4/5=3), gen(edu_yk_3)
lab var edu_yk_3 "Berufsabschluss 3 Kategorien"
lab define edu_yk_3 1"Keine Berufsbildung/Abschluss" 2 "Berufliche Ausbildung" 3"Hochschule/Uni/Promotion"
label values edu_yk_3 edu_yk_3 

gen child_less6 = 1 if inlist(h_child_age,2,3)
recode child_less6 .= 0 if h_child_age<.
tab h_child_age child_less6,m


gen mnth_s_arrival_sq=mnth_s_arrival*mnth_s_arrival

replace am_maßnahm_cv = 1 if prof_course_cv == 1
replace am_maßnahm_praxis = 1 if prof_course_praxis == 1
replace am_maßnahm_berufo = 1 if prof_course_berufo == 1
replace am_maßnahm_festf = 1 if prof_course_festf == 1
replace am_maßnahm_oth = 1 if prof_course_oth == 1


	lab def kurs_stat 1 "noch kein abschluss" 2 "kursteilnahme derzeit" 3 "kurs abgeschlossen" , replace
gen int_bamf = 1 if int_bamf_part == 0
replace int_bamf = 1 if int_bamf_part == 1
replace int_bamf = 2 if int_bamf_curr == 1
replace int_bamf = 3 if int_bamf_finished == 1 
lab val int_bamf kurs_stat
lab var int_bamf "Kursteilnahme (abschluss uebergeordnet)"
 
gen prof_course = 1 if prof_course_part == 0
replace prof_course = 1 if prof_course_part == 1
replace prof_course = 2 if int_bamf_curr == 1
replace prof_course = 3 if prof_course_finished == 1 
lab val prof_course kurs_stat
lab var prof_course "Kursteilnahme (abschluss uebergeordnet)"

gen oth_course = 1 if other_course_part == 0
replace oth_course = 1 if other_course_part == 1
replace oth_course = 2 if other_course_aktl == 1
replace oth_course = 3 if other_course_fin == 1 
lab val oth_course kurs_stat
lab var oth_course "Kursteilnahme (abschluss uebergeordnet)"

tab deu_finished_niv deu_aggr_curr, col

tab abschl_anerkenn abschl_an_result, m
gen abschl_anerkannt_voll_teil = abschl_an_result <= 2 if abschl_an_result <.

count


gen byte health2=(healthy<=2) & !missing(healthy)
	label def health2 1 "niedrig bis schlecht" 0 "Gut bis mittelmäßig", modify
	label values health2 health2	

recode age_arriv (18/30=1 "18-30") (31/44=2 "31-44") (45/64=3 "45-64"), gen(age_arriv_cat3)
label var age_arriv_cat3 "Age at arrival Cat. 41+"

gen german_good = de_kenntnisse >=3 if de_kenntnisse<.

* missings
capture drop mi_*

*independent variables of interest - a list for treating missings
#delimit
global indepvars 
	willk1
	kohorte 
	mnth_s_arrival
	partner_dummy 
	//partner_in_hh
	english_score 
	german_score
	deu_aggr_finished
	deu_aggr_part
	work0
	//niveau0
	edu_yk_3  
	//bleib
	forever_de_v40
	abschl_anerkenn
	abschl_anerkannt_voll_teil
	//deu_aggr_num
	health2
;
#delimit cr

sum $vars1

*missings (including kontakt_de)
foreach var of varlist $indepvars {
	capture drop mi_`var'
	gen mi_`var'=`var'==.
	sum `var'
	replace `var' = r(min) if `var'>=.
	}


* vars 1: list of independent variables including kontakt_de
* reduced sample because not everyone answered this questions in 2023
#delimit
global vars1 
	i.female 
	ib1.age_arriv_cat3 
	ib1.kohorte
	c.mnth_s_arrival 
	//ib1.h_child_age 
	i.child_less6
	i.partner_dummy 
	//i.partner_in_hh
	i.work0
	//i.niveau0
	ib1.edu_yk_3
	i.abschl_anerkenn
	i.abschl_anerkannt_voll_teil
	c.german_score
	c.english_score
	i.deu_aggr_part
	i.deu_aggr_finished
	//ib0.bleib
	i.forever_de_v40	
	i.willk1
	i.health2
	;
#delimit cr




********************************************************************************
* Beschäftigung
********************************************************************************

*Für alle

reg paid_work mi_* $vars1  [pweight = phrf23vorab_SUARE], vce(robust)
estimates store ohne_kontakt

reg paid_work mi_* $vars1 if female == 0 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store ohne_kontakt_M

reg paid_work mi_* $vars1 if female == 1 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store ohne_kontakt_F

reg paid_work mi_* $vars1 ib3.kontakt_de if kontakt_de<. [pweight = phrf23vorab_SUARE], vce(robust)
estimates store mit_kontakt

reg paid_work mi_* $vars1 ib3.kontakt_de if kontakt_de<. & female == 0 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store mit_kontakt_M

reg paid_work mi_* $vars1 ib3.kontakt_de if kontakt_de<. & female == 1 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store mit_kontakt_F



********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

#delimit;
	global keeporder
		2.kohorte
		mnth_s_arrival
		1.age_arriv_cat3
		2.age_arriv_cat3
		3.age_arriv_cat3
		1.female
		1.child_less6
		1.partner_dummy
		1.work0
		1.edu_yk_3
		2.edu_yk_3
		3.edu_yk_3
		1.abschl_anerkenn
		1.abschl_anerkannt_voll_teil
		german_score
		english_score
		1.deu_aggr_part
		1.deu_aggr_finished
		3.kontakt_de
		2.kontakt_de
		1.kontakt_de
		1.forever_de_v40
		1.willk1
		1.health2
		_cons
	;
#delimit cr
		
#delimit;
		global coef
			2.kohorte "Nach Juni 2022 zugezogen"
			mnth_s_arrival "Monate seit dem Zuzug"
			1.age_arriv_cat3 "Alter bei dem Zuzug: Ref. 18-30"
			2.age_arriv_cat3 "31-44"
			3.age_arriv_cat3 "45-64"
			1.female "Frau"
			1.child_less6 "Kinder 0-6 Jahre"
			1.partner_dummy "Partner in HH"
			1.work0 "Erwerbstätig vor dem Zuzug"
			1.edu_yk_3 "Bildungsabschluss (Referenz: ohne Berufsabschluss)"
			2.edu_yk_3  "	mit Berufsabschluss"
			3.edu_yk_3 "	Hochschulabschluss (incl. Promotion)"
			1.abschl_anerkenn "Anerkennungsantrag gestellt"
			1.abschl_anerkannt_voll_teil "Voll-Teilweise anerkannter Abschluss"
			german_score "Deutschkenntnisse"
			english_score "Englischkenntnisse"
			1.deu_aggr_part "In Sprachkurs teilgenommen oder teilnahme derzeit"
			1.deu_aggr_finished "Sprachkurs abgeschlossen"
			3.kontakt_de "Kontakte mit Deuschten: Ref. nie"
			2.kontakt_de "		Mindestens monatlich"
			1.kontakt_de "		Mehrmals pro Woche oder häufiger"
			1.forever_de_v40 "Bleibeabsichten: fuer immer in DE"
			1.willk1 "Fühlt sich willkommen"
			1.health2 "(Sehr) schlechter Gesundheitszustand"
		_cons
	;
#delimit cr

#delimit;	
esttab ohne_kontakt mit_kontakt ohne_kontakt_F mit_kontakt_F ohne_kontakt_M mit_kontakt_M 
	using "$out_results/1_manuscript", replace
	scsv 
		order(
			$keeporder
		)
		keep(
			$keeporder
		)
		coef(
			$coef
			_cons "Constant"
		)
		scalars(N df_m )   
		sfmt(%9.0f %9.0f)
		varwidth(30)
		mtitles(
		"Insgesamt"
		" Kontakte"
		"Frau"
		" Kontakte"
		"Mann"
		" Kontakte"
		)
		title(
		"Wahrscheinlichkeit des Erwerbstaetigkeit, in Prozentpunkten"
		)
	wide 
	b(%9.1f) not
	transform(@*100 ) 
	starlevels(* 0.1 ** 0.05 *** 0.01) 
	compress nogaps label noomitted 
	;
#delimit cr





* options for graphs

* IAB colors
global iabg1  "0 63 125"
global iabg2  "206 215 45"
global iabg3  "84 189 191"
global iabg4  "12 127 167"
global iabg5  "237 150 86"       
global iabg6  "130 192 116"       
global iabg7  "240 173 38"
global iabg8  "189 158 188"


********************************************************************************
global	line_opt fintensity(inten100) lpattern(solid)
global	ciline_opt lwidth(*0.2) lpattern(solid)
global	opt_plot1 label("total") $line_opt lcol("$iabg1")  mcol("$iabg1") msym(S) ciopt(lcol("$iabg1") $line_opt)
global	opt_plot2 label("women") $line_opt lcol("$iabg2")  mcol("$iabg2") msym(D) ciopt(lcol("$iabg2") $line_opt)
global	opt_plot3 label("men") $line_opt lcol("$iabg3")  mcol("$iabg3") msym(O) ciopt(lcol("$iabg3") $line_opt)
global	opt_xlabel xlabel(-20(10)20, grid) grid(between glpattern(dot) glwidth(*2)) xtitle("AME in p.p., with CIs",size(small)) xscale(range(-25 25) fextend)
global	opt_mlabel mlabel(cond(@pval<.01, "***", cond(@pval<.05, "**", cond(@pval<.1, "*", ""))))


	#delimit
	global coefplot_vars
			2.kohorte
			mnth_s_arrival
			1.age_arriv_cat3
			2.age_arriv_cat3
			3.age_arriv_cat3
			1.female
			1.child_less6
			1.partner_dummy
			1.work0
			1.edu_yk_3
			2.edu_yk_3
			3.edu_yk_3
			1.abschl_anerkenn
			1.abschl_anerkannt_voll_teil
			german_score
			english_score
			1.deu_aggr_finished
			//1.deu_aggr_part
			3.kontakt_de
			2.kontakt_de
			1.kontakt_de
			1.forever_de_v40
			1.willk1
			1.health2
		;
	#delimit cr

	#delimit
	global coeflabels
			2.kohorte = "Nach Juni 2022 zugezogen"
			mnth_s_arrival  = "Monate seit dem Zuzug"
			1.age_arriv_cat3  = "Alter bei dem Zuzug: Ref. 18-30"
			2.age_arriv_cat3  = "31-44"
			3.age_arriv_cat3  = "45-64"
			1.female =  "Frau"
			1.child_less6  = "Kinder 0-6 Jahre"
			1.partner_dummy =  "Partner in Haushalt"
			1.work0  =  "Erwerbstätig vor dem Zuzug"
			1.edu_yk_3  = "Bildungsabschluss (Referenz: ohne Berufsabschluss)"
			2.edu_yk_3  =  "	mit Berufsabschluss"
			3.edu_yk_3 =  "	Hochschulabschluss (inkl. Promotion)"
			1.abschl_anerkenn =  "Anerkennungsantrag gestellt"
			1.abschl_anerkannt_voll_teil  = "Voll-/teilweise anerkannter Abschluss"
			german_score  = "Deutschkenntnisse"
			english_score =  "Englischkenntnisse"
			//1.deu_aggr_part  = "In Sprachkurs teilgenommen oder teilnahme derzeit"
			1.deu_aggr_finished  = "Sprachkurs abgeschlossen"
			3.kontakt_de  = "Kontakte mit Deuschten: Ref. nie"
			2.kontakt_de =  "		Mindestens monatlich"
			1.kontakt_de =  "		Mehrmals pro Woche oder häufiger"
			1.forever_de_v40  = "Bleibeabsichten fuer immer in Deutschland"
			1.willk1  = "Fühlt sich willkommen"
			1.health2  = "(Sehr) schlechter Gesundheitszustand"
		;
	#delimit cr

	#delimit
	global headings
			2.age_arriv_cat3 = 	`"{it: Alter bei dem Zuzug} (Ref.: 18-30 Jahre)"'
			2.edu_yk_3 = 	`"{it: Bildungsabschluss} (Ref.: ohne Berufsabschluss)"'
			2.kontakt_de = 	`"{it: Kontakte mit Deuschten} (Ref.: nie)"'
		;
	#delimit cr

				
				
********************************************************************************
	* total

	#delimit
		coefplot 
			(ohne_kontakt, $opt_plot1 )
			(mit_kontakt, $opt_plot1 keep(*kontakt_de*))
			,
			fintensity(inten100) lpattern(solid)
				xline(0, lwidth(*.2) lpattern(solid)) 
				xlabel(-40(10)40, grid) grid(between glpattern(dot) glwidth(*2)) 
				xtitle("Durchschnittlicher Effekt in Prozentpunkten," "95%-Konfidenzintervalle",size(small)) xscale(range(-45 45) fextend)
				$opt_mlabel
				$opt_legend
			scheme(plotplain)
			  rescale(100)
			name(coefplot, replace)
			keep($coefplot_vars)
			order($coefplot_vars)
			coeflabels($coeflabels, labsize(vsmall))
			headings($headings, angle(0) labsize(vsmall) nogap)
			title("")
		legend(
		on order(
			2 "Insgesamt" 
			)
		pos(6) row(1) ring(1) size(*1) symx(*.75) symy(*.75) forcesize) 
		;
	#delimit cr

graph export "$out_results/coefplot_$date.png", as(png) replace
graph export "$out_results/coefplot_$date.pdf", as(pdf) replace


	********************************************************************************
	* gendered

	#delimit
		coefplot 
			(ohne_kontakt_F, $opt_plot2) 
			(mit_kontakt_F, $opt_plot2 keep(*kontakt_de*)) 
			(ohne_kontakt_M, $opt_plot3) 
			(mit_kontakt_M, $opt_plot3 keep(*kontakt_de*)) 
			,
			fintensity(inten100) lpattern(solid)
				xline(0, lwidth(*.2) lpattern(solid)) 
				xlabel(-40(10)40, grid) grid(between glpattern(dot) glwidth(*2)) 
				xtitle("Durchschnittlicher Effekt in Prozentpunkten," "95%-Konfidenzintervalle",size(small)) xscale(range(-45 45) fextend)
				$opt_mlabel
			scheme(plotplain)
			  rescale(100)
			name(coefplot_gender, replace)
			keep($coefplot_vars)
			order($coefplot_vars)
			coeflabels($coeflabels, labsize(vsmall))
			headings($headings, angle(0) labsize(vsmall) nogap)
			title("")
		legend(
		on order(
			2 "Frauen" 
			6 "Männer" 
			)
		pos(6) row(1) ring(1) size(*1) symx(*.75) symy(*.75) forcesize) 
		yscale(off) 
		;
	#delimit cr

graph export "$out_results/coefplot_gender_$date.png", as(png) replace
graph export "$out_results/coefplot_gender_$date.pdf", as(pdf) replace




#delimit ;
	graph combine coefplot coefplot_gender, altshrink 
		;
#delimit cr
	
	
graph export "$out_results/coefplot_all_$date.png", as(png) replace
graph export "$out_results/coefplot_all_$date.pdf", as(pdf) replace






/*
********************************************************************************
* Löhne
********************************************************************************

*Für alle

reg isei mi_* $vars1 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store ohne_kontakt


#delimit;	
esttab ohne_kontakt mit_kontakt 
	using "$out_results/2_manuscript", replace
	scsv 
		order(
			$keeporder
			1.vollzeit
		)
		keep(
			$keeporder
			1.vollzeit
		)
		coef(
			$coef
			1.vollzeit "Vollzeit"
			_cons "Constant"
		)
		scalars(N df_m )   
		sfmt(%9.0f %9.0f)
		varwidth(30)
		mtitles(
		"Insgesamt"
		" Kontakte"
		)
		title(
		"Bruttolöhne, in Prozent"
		)
	wide 
	b(%9.1f) not
	starlevels(* 0.1 ** 0.05 *** 0.01) 
	compress nogaps label noomitted 
	;
#delimit cr



*Für alle

reg ln_work_blohn mi_* $vars1  [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lohne_kontakt

reg ln_work_blohn mi_* $vars1 if female == 0 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lohne_kontakt_M

reg ln_work_blohn mi_* $vars1 if female == 1 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lohne_kontakt_F

reg ln_work_blohn mi_* $vars1 ib3.kontakt_de if kontakt_de<. [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lmit_kontakt

reg ln_work_blohn mi_* $vars1 ib3.kontakt_de if kontakt_de<. & female == 0 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lmit_kontakt_M

reg ln_work_blohn mi_* $vars1 ib3.kontakt_de if kontakt_de<. & female == 1 [pweight = phrf23vorab_SUARE], vce(robust)
estimates store lmit_kontakt_F

* total Löhne

	#delimit
		coefplot 
			(lohne_kontakt, $opt_plot1 )
			(lmit_kontakt, $opt_plot1 keep(*kontakt_de*))
			,
			fintensity(inten100) lpattern(solid)
				xline(0, lwidth(*.2) lpattern(solid)) 
				xlabel(-30(10)30, grid) grid(between glpattern(dot) glwidth(*2)) 
				xtitle("Durchschnittlicher Effekt in Prozentpunkten," "95%-Konfidenzintervalle",size(small)) xscale(range(-35 35) fextend)
				$opt_mlabel
				$opt_legend
			scheme(plotplain)
			  rescale(100)
			name(coefplot, replace)
			keep($coefplot_vars)
			order($coefplot_vars)
			coeflabels($coeflabels, labsize(vsmall))
			headings($headings, angle(0) labsize(vsmall) nogap)
			title("")
		legend(off) 
		;
	#delimit cr

graph export "$out_results/coefplot_l_$date.png", as(png) replace
graph export "$out_results/coefplot_l_$date.pdf", as(pdf) replace


	********************************************************************************
	* gendered Löhne

	#delimit
		coefplot 
			(lohne_kontakt_F, $opt_plot2) 
			(lmit_kontakt_F, $opt_plot2 keep(*kontakt_de*)) 
			(lohne_kontakt_M, $opt_plot3) 
			(lmit_kontakt_M, $opt_plot3 keep(*kontakt_de*)) 
			,
			fintensity(inten100) lpattern(solid)
				xline(0, lwidth(*.2) lpattern(solid)) 
				xlabel(-30(10)30, grid) grid(between glpattern(dot) glwidth(*2)) 
				xtitle("Durchschnittlicher Effekt in Prozentpunkten," "95%-Konfidenzintervalle",size(small)) xscale(range(-35 35) fextend)
				$opt_mlabel
			scheme(plotplain)
			  rescale(100)
			name(coefplot_gender, replace)
			keep($coefplot_vars)
			order($coefplot_vars)
			coeflabels($coeflabels, labsize(vsmall))
			headings($headings, angle(0) labsize(vsmall) nogap)
			title("")
		legend(
		on order(
			2 "Frauen" 
			6 "Männer" 
			)
		pos(3) row(3) ring(0) size(*1) symx(*.75) symy(*.75) forcesize) 
		;
	#delimit cr

graph export "$out_results/coefplot_l_gender_$date.png", as(png) replace
graph export "$out_results/coefplot_l_gender_$date.pdf", as(pdf) replace

*/


********************************************************************************

capture log close

********************************************************************************
