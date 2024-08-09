clear all
set maxvar 10000
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

  * ------------------------------------------
	* EMPLOYMENT, LABOR MARKET PARTICIPATION 
  * ------------------------------------------

 * ---------- EMPLOYMENT ----------

 * ----- Persons in paid work -----
	#delimit
	label def employment
		1 "vollzeit"
		2 "teilzeit"
		3 "Ausbildung/Lehre/Umschulung"
		4 "geringfügig/unregelmäßig"
		5 "Kurzarbeit"
		10 "betriebliches Praktikum"
		9 "Nicht erwerbstätig", replace;
	#delimit cr

g actual_empl = .
label var actual_empl "Derzeit: Erwerbstätigkeitsstatus"
label val actual_empl employment
	
replace actual_empl = 1 if inlist(plb0022_v11,1) 
replace actual_empl = 2 if inlist(plb0022_v11,2) 
replace actual_empl = 3 if inlist(plb0022_v11,3) 
replace actual_empl = 4 if inlist(plb0022_v11,4) 
replace actual_empl = 5 if inlist(plb0022_v11,12) 
replace actual_empl = 10 if inlist(plb0022_v11,10)  
replace actual_empl = 9 if inlist(plb0022_v11,5,7,9,11) 

tab actual_empl syear, m row
tab plb0022_v11 actual_empl
	
 * ---------- Erwerbstätig ----------
gen work = .
replace work = 1 if inlist(plb0022_v11,1,2,3,4,5,7,10,11)
replace work = 0 if inlist(plb0022_v11,9)
label var work "Derzeit: Erwerbstätigkeit"
tab plb0022_v11 work, m	

 * ----- Employed in paid work -----
gen paid_work = .
replace paid_work = 1 if inlist(plb0022_v11,1,2,3,4,5,7,10,11)
replace paid_work = 0 if inlist(plb0022_v11,9)
replace paid_work = 0 if plc0013_v2 == 0 & plc0014_v2 == 0
label var paid_work "Employed in paid work"
tab work paid_work

 * ----- Employed / Not/looking for work -----
gen lfs_status = .
recode lfs_status .= 1 if paid_work == 1
recode lfs_status .= 2 if plb0424_v2 == 1
recode lfs_status .= 3 if plb0424_v2 == 2
recode lfs_status .= 3 if paid_work == 0

label define lfs_status 1 "[1] Erwerbstätig (gegen Entgelt)" 2 "[2] Aktiv arbeitssuchend (letzte 4 Wochen)" 3 "[3] Nicht arbeitssuchend", replace
label var lfs_status "Arbeitsmarktstatus, 3 cat."
label values lfs_status lfs_status

 * ----- Employed / Not/looking for work -----
		* detailed
  
* in vocational training (Ausbildung) 
* (plg0012_v2 and plb0022_v11 = 3) or in Kurzarbeit
  
gen lfs_status_dtl = .
recode lfs_status_dtl .= 1 if lfs_status == 1
recode lfs_status_dtl .= 2 if lfs_status == 2
recode lfs_status_dtl .= 3 if plg0012_v2 == 1 | inlist(plb0022_v11,3,10)

* Information if still in ESF-BAMF-COURSE (plj0499), Integrationskurs (plj0654 & 
* plj0659_v1), other German course (plj0540, plm736l01, plm736l02, plm736l03), 
* or job-related German course (plm728i01l01, plm728i01l02, plm728i01l03)

recode lfs_status_dtl .= 4 if plj0499 == 1 | plj0540 == 1 | plm736I01 == 1 | plm736I02 == 1 | plm736I03 == 1 | plm728i01I01 == 1 | plm728I02I02 == 1 | plm728I03I03 == 1 | (plj0654 == 1 & plj0659_v1 != 1)

* Information if person is in parental leave (plb0019_v2) and
* if person received parental leave benefit in last month (plc0152_v1, 
* plc0153_v2)

recode lfs_status_dtl .= 5 if inlist(plb0019_v2,1,2) | plc0152_v1 == 1 | (plc0153_v2 > 0 & plc0153_v2 < .)

* Info from lfs_status if person is currently looking for work 

recode lfs_status_dtl .= 6 if lfs_status == 3 

label var lfs_status_dtl "Arbeitsmarktstatus, 6 cat."
label define lfs_status_dtl 1 "[1] Erwerbstätig (gegen Entgelt)" 2 "[2] Aktiv arbeitssuchend (letzte 4 Wochen)" 3 "[3] Nicht-aktiv arbeitssuchend: Bildungserwerb" 4 "[4] Nicht-aktiv arbeitssuchend: Spracherwerb" 5 "[5] Nicht-aktiv arbeitssuchend: Elternzeit" 6 "[6] Nicht-aktiv arbeitssuchend: Sonstiges", replace
label values lfs_status_dtl lfs_status_dtl

tab lfs_status_dtl lfs_status

 * ----- Employment (Dummy) -----

gen lmactivity = lfs_status <= 2 if lfs_status <.

label define lmactivity_lab 0 "[0] Nein" 1 "[1] Ja"
label var lmactivity "Erwerbsbeteiligung"
label values lmactivity lmactivity_lab

tab lmactivity 

 * save $out_data/suare_v40_variablen.dta, replace
 
  * --------------------------------------
    * VARIABLES:
   * SES, LABOR MARKET BEFORE ARRIVAL 
  * --------------------------------------

* OWN RELATIVE POSITION BEFORE ARRIVAL

  * ----- Economic status before migration -----

gen ec_status0 = lr3046 if lr3046 > 0 & lr3046<.

label var ec_status0 "Wirtschaftliche Situation vor Zuzug"
#delimit
	label define soz_status0_lab 
	1 "[1] Weit überdurchschnittlich" 
	2 "[2] Eher überdurchschnittlich" 
	3 "[3] Durchschnittlich" 
	4 "[4] Eher unterdurchschnittlich" 
	5 "[5] Weit unterdurchschnittlich" 
	0 "[0] Noch nie Berufstätig"
	, modify;
#delimit cr
label values ec_status0 soz_status0_lab

 * ----- Income status before migration -----

gen inc_status0 = lr3041 if lr3041 > 0 & lr3041<.
recode inc_status0 . = 0 if lr3032 == 1 | lr3033_v1 == 1 

label var inc_status0 "Höhe Ihres Nettoeinkommens vor Zuzug"
label values inc_status0 soz_status0_lab

tab inc_status0, m 
tab ec_status0,m

 * ----- EMPLOYMENT BEFORE ARRIVAL -----

gen empl0 = lm0632 if lm0632 > 0 & lm0632 < .
recode empl0 . = 0 if lr3032 == 1 | lr3033_v1 == 1 

#delimit;
 label define empl0_lab
0 "[0] Noch nie berufstätig im Inland oder Ausland"
1 "[1] Arbeiter ohne Führungsaufgaben, auch in der Landwirtschaft"
2 "[2] Arbeiter mit Führungsaufgaben, auch in der Landwirtschaft"
3 "[3] Selbstständige, auch mithelfende Familienangehörige"
4 "[4]Angestellte ohne Führungsaufgaben"
5 "[5] Angestellte mit Führungsaufgaben"
6 "[6] Beamte/Staatsverwaltung ohne Führungsaufgaben, auch Richter und Berufssoldaten"
7 "[7] Beamte/Staatsverwaltung mit Führungsaufgaben, auch Richter und Berufssoldaten"
 , replace;
#delimit cr
label var empl0 "Employment before arrival to Germany"
label values empl0 empl0_lab 

 * ----- Type of employment -----
#delimit
	recode empl0 
		(0 = 0 "Nie berufstätig")
		(1 2 = 1 "Arbeiter") 
		(3 = 2 "Selbstständige") 
		(4 5 = 3 "Angestellte") 
		(6 7 = 4 "Beamte") 
		, gen(empl0_aggr);
#delimit cr
label var empl0_aggr "Employed bef. Migr"

tab empl0_aggr

 * ----- Employed before migration (dummy) -----

gen work0 = empl0 > 0 if empl0 < .

label var work0 "Employed bef. Migr"
label define work0_lab 0 "[0] Nein" 1 "[1] Ja"
label values work0 work0_lab

tab empl0, m
tab work0, m 

 * ----- BRANCH BEFORE ARRIVAL -----

 * ----- Branches -----

gen branch0 = .
replace branch0 = 1	if lr3035 == 14
replace branch0 = 2	if lr3035 == 3
replace branch0 = 3	if lr3035 == 17
replace branch0 = 4	if lr3035 == 4
replace branch0 = 5	if lr3035 == 19
replace branch0 = 6	if lr3035 == 1
replace branch0 = 7	if lr3035 == 9
replace branch0 = 8	if lr3035 == 18
replace branch0 = 9	if lr3035 == 2
replace branch0 = 10 if	lr3035 == 11
replace branch0 = 11 if	lr3035 == 12
replace branch0 = 12 if	lr3035 == 10
replace branch0 = 13 if	lr3035 == 7
replace branch0 = 14 if	lr3035 == 20
replace branch0 = 15 if	lr3035 == 15
replace branch0 = 16 if	lr3035 == 5
replace branch0 = 17 if	lr3035 == 8
replace branch0 = 18 if	lr3035 == 13
replace branch0 = 19 if	lr3035 == 21
replace branch0 = 20 if	lr3035 == 16
replace branch0 = 21 if	lr3035 == 6

 * Label
#delimit
label define wz_lab
1 "[1] A. Land- und Forstwirtschaft, Fischerei" 
2 "[2] B. Bergbau und Gewinnung von Steinen und Erden"
3 "[3] C. Verarbeitendes Gewerbe"
4 "[4] D. Energieversorgung"
5 "[5] E. Wasserversorgung; Abwasser- und Abfallentsorgung und Beseitigung von Umweltverschmutzungen"
6 "[6] F. Baugewerbe"
7 "[7] G. Handel; Instandhaltung und Reparatur von Fahrzeugen"
8 "[8] H. Verkehr und Lagerei"
9 "[9] I. Gastgewerbe"
10 "[10] J. Information und Kommunikation"
11 "[11] K. Erbringung von Finanz- und Versicherungsdienstleistungen"
12 "[12] L. Grundstücks- und Wohnungswesen"
13 "[13] M. Erbringung von freiberuflichen, wissenschaftlichen und technischen Dienstleistungen"
14 "[14] N. Erbringung von sonstigen wirtschaftlichen Dienstleistungen"
15 "[15] O. Öffentliche Verwaltung, Verteidigung; Sozialversicherung"
16 "[16] P. Erziehung und Unterricht"
17 "[17] Q. Gesundheits- und Sozialwesen"
18 "[18] R. Kunst, Unterhaltung und Erholung"
19 "[19] S. Erbringung von sonstigen Dienstleistungen"
20 "[20] T. Private Haushalte mit Hauspersonal; Herstellung von Waren und Erbringung von Dienstleistungen durch private Haushalte für den Eigenbedarf ohne ausgeprägten Schwerpunkt"
21 "[21] U. Exterritoriale Organisationen und Körperschaften"
,modify;
#delimit cr

label values branch0 wz_lab
label var branch0 "Industry before migration"

tab branch0 work0, m
tab lr3035 branch0

 * ----- Classification of branches -----

gen branch0_vgr =. 
replace branch0_vgr =1 if inlist(branch0,1)
replace branch0_vgr =2 if inlist(branch0,2,3,4,5)
replace branch0_vgr =3 if inlist(branch0,6)
replace branch0_vgr =4 if inlist(branch0,7,8,9)
replace branch0_vgr =5 if inlist(branch0,10)
replace branch0_vgr =6 if inlist(branch0,11)
replace branch0_vgr =7 if inlist(branch0,12)
replace branch0_vgr =8 if inlist(branch0,13,14)
replace branch0_vgr =9 if inlist(branch0,15,16,17)
replace branch0_vgr =10 if inlist(branch0,18,19,20,21)

#delimit
	label define branch_vgr_lab 	 
1 "[1] Landwirtschaft, Forstwirtschaft und Fischerei" 	
2 "[2] Verarbeitendes Gewerbe, Bergbau und Gewinnung von Steinen und Erden,	sonstige Industrie" 	
3 "[3] Baugewerbe" 	
4 "[4] Handel, Verkehr und Lagerei" 	
5 "[5] Information und Kommunikation" 	
6 "[6] Erbringung von Finanz- und Versicherungsdienstleistungen" 	
7 "[7] Grundstücks- und Wohnungswesen*"
8 "[8] Erbringung von freiberuflichen, wissenschaftlichen und technischen Dienstleistungen sowie von sonstigen wirtschaftlichen Dienstleistungen" 	
9 "[9] Öffentliche Verwaltung, Verteidigung; Sozialversicherung, Erziehung und Unterricht, Gesundheits- und Sozialwesen" 	
10 "[10] Sonstige Dienstleistungen" 
	, replace;
#delimit cr

label var branch0_vgr "Vor Zuzug, Volkswirtschaftlichen Gesamtrechnungen (grobes SNA/ISIC-Aggregat A*10/11)"
label values branch0_vgr branch_vgr_lab

tab branch0_vgr
tab branch0 branch0_vgr

 * ----- Labor market sectors -----

recode branch0 ///
(1 2 = 1 "Primär Sektor (Agrar & Bergbau)") ///
(3 4 5 6 = 2 "Sekundär Sektor (Industrie)") ///
(7 8 9 12 14 15 19 20 21 = 3 "Sonstige Dienstleistungen") ///
(10 = 4 "Telekommunikation und Information") ///
(11 = 5 "Finanz- und Versicherungs") ///
(13 = 6 "Freiberufler, Wissenschaftler und Ingenieure") ///
(16 = 7 "Bildung") ///
(17 = 8 "Gesundheitsdienste") ///
(18 = 9 "Kreative und künstlerische Tätigkeiten") ///
,gen(sektor0_aggr2)

#delimit
 label define sektor0_aggr2_lab
1 "[1] Primär Sektor (Agrar & Bergbau)" 
2 "[2] Sekundär Sektor (Industrie)" 
3 "[3] Sonstige Dienstleistungen" 
4 "[4] Telekommunikation und Information" 
5 "[5] Finanz- und Versicherungs" 
6 "[6] Freiberufler, Wissenschaftler und Ingenieure" 
7 "[7] Bildung" 
8 "[8] Gesundheitsdienste" 
9 "[9] Kreative und künstlerische Tätigkeiten"
 , replace;
#delimit cr 

label values sektor0_aggr2 sektor0_aggr2_lab

label var sektor0_aggr2 "Aggr2: Vor Zuzug, Volkswirtschaftlichen Gesamtrechnungen (grobes SNA/ISIC-Aggregat A*10/11)"

tab sektor0_aggr2
tab branch0 sektor0_aggr2

  * ----------------------------------------
    * WORKING EXPERIENCE IN ORIGIN COUNTRY
  *  ---------------------------------------

* SPELLS KOMMEN NOCH 

  * ----- LEVEL OF QUALIFICATION/JOB
			* (TÄTIGKEITSNIVEAU) -----

tab l_isco08_job09, m
tab l_kldb2010_job09, m


  * ---------------------------------------------
    * VARIABLES: SES, LABOR MARKET AFTER ARRIVAL
  *  --------------------------------------------

 * ----- WORK ASPIRATION -----

gen future_empl = plb0417_v2 if plb0417_v2 > 0 & plb0417_v2 < . 
replace future_empl = 0 if inlist(actual_empl,1,2,3,4,10)

#delimit;
	label define future_empl_lab
		0 "[0] Bereits erwerbstätig" 
		1 "[1] Nein, ganz sicher nicht"
		2 "[2] Eher unwahrscheinlich"
		3 "[3] Wahrscheinlich"
		4 "[4] Ganz sicher"
		, replace;
#delimit cr
label var future_empl "Aspiration about Future Employment"
label values future_empl future_empl_lab 

tab future_empl, m
tab actual_empl future_empl
tab plb0417_v2 future_empl

 * ----- BERUFLICHE STELLUNG (OCCUPATIONAL POSITION?) -----

gen empl_type = .

tab empl_type if work == 1, m

replace empl_type = 1 if inlist(plb0568_v1,1)
replace empl_type = 2 if inlist(plb0568_v1,2)
replace empl_type = 3 if inlist(plb0568_v1,3)
replace empl_type = 4 if inlist(plb0568_v1,4)
replace empl_type = 5 if inlist(plb0568_v1,5)

#delimit;
	label define empl_type_lab					
		1 "[1] Selbstständige"
		2 "[2] Arbeiter"
		3 "[3] Beamte"							
		4 "[4] Azubi/Praktikanten"
		5 "[5] Angestellte", replace;
#delimit cr
label var empl_type "Berufliche Stellung"         
label values empl_type empl_type_lab

tab empl_type work, m
tab empl_type plb0568_v1

  * -----------------------------------
    * FURTHER WORK RELATED VARIABLES
  *  ----------------------------------

 * ----- Working contract (temporary/unlimited) -----

gen work_befrist = plb0037_v3 if plb0037_v3 > 0 & plb0037_v3 < .	

#delimit 
	label define work_befrist_lab
	1 "[1] Unbefristeter Arbeitsvertrag"
	2 "[2] Befristeter Arbeitsvertrag"
	3 "[3] Trifft nicht zu / habe keinen Arbeitsvertrag"
	,replace;
#delimit cr
label var work_befrist "Befristung des Arbeitsvertrags"
label values work_befrist work_befrist_lab

tab work_befrist work, m
tab plb0037_v3 work_befrist

 * --- Currently in Mini-job or BA course (Maßnahme) ---

* plb0038_v4 is not included
* There is plm0518i05 (no participation at BA courses), pm740I01 (Participation;
* This one has the most cases (3410) compared to the others)
* and plm741I01 (Number of job related courses/Maßnahmen)

gen work_maßnahm = .
replace work_maßnahm = 0 if plm0518i05 == 1
replace work_maßnahm = 0 if plm740I01 == 2
replace work_maßnahm = 1 if plm740I01 == 1
replace work_maßnahm = 1 if plm741I01 > 0 & plm741I01 < . 
replace work_maßnahm = 1 if actual_empl == 4 

label define work_maßnahm 0 "[0] Nein" 1 "[1] Ja"
label var work_maßnahm "Maßnahme der Agentur für Arbeit oder 1-Euro-Job"
label values work_maßnahm work_maßnahm

tab work_maßnahm work, m

 * ----- Wage (Month) -----

 *Brutto
gen work_blohn = plc0013_v2  if plc0013_v2 >= 0 & plc0013_v2 < .
label var work_blohn "Bruttoarbeitsverdienst (letzter Monat)"

tab work_blohn, m

 *Netto
gen work_nlohn = plc0014_v2  if plc0014_v2 >= 0 & plc0014_v2 < .
label var work_nlohn "Nettoarbeitsverdienst (letzter Monat)"

tab work_nlohn, m

 * ----- Working hours -----

gen work_hours_contract = plb0176_v5 if plb0176_v5 > 0 
label var work_hours_contract "Vertragliche Wochenarbeitszeit"

tab work_hours_contract work, m

gen work_hours_actual = plb0186_v3 if plb0186_v3 > 0
label var work_hours_actual "Tatsächliche Wochenarbeitszeit mit Überstunden"

tab work_hours_actual work, m

 * ----- Wage (Hour) -----

 *Brutto
gen work_blohn_hour = work_blohn / work_hours_contract / 4
label var work_blohn_hour "Bruttoarbeitsverdienst pro Stunde (letzter Monat)"

tab work_blohn_hour, m

 *Netto
gen work_nlohn_hour = work_nlohn / work_hours_contract / 4
label var work_nlohn_hour "Nettoarbeitsverdienst pro Stunde (letzter Monat)"

tab work_nlohn_hour, m

 * ----- Branch (Help variables) -----

gen branch = .
replace branch = 1	if inlist(p_nace2,	1,2,3)
replace branch = 2	if inlist(p_nace2,	5,6,7,8,9)
replace branch = 3	if p_nace2>=10 & p_nace2 <=33	
replace branch = 4	if inlist(p_nace2,	35)
replace branch = 5	if inlist(p_nace2,	36,37,38,39)
replace branch = 6	if inlist(p_nace2,	41,42,43,53)
replace branch = 7	if p_nace2>=45 & p_nace2 <=47	
replace branch = 8	if p_nace2>=49 & p_nace2 <=53	
replace branch = 9	if p_nace2>=55 & p_nace2 <=56	
replace branch = 10	if p_nace2>=58 & p_nace2 <=63	
replace branch = 11	if p_nace2>=64 & p_nace2 <=66	
replace branch = 12	if p_nace2==68 	
replace branch = 13	if p_nace2>=69 & p_nace2 <=75	
replace branch = 14	if p_nace2>=77 & p_nace2 <=82	
replace branch = 15	if p_nace2==84	
replace branch = 16	if p_nace2==85
replace branch = 17	if p_nace2>=86 & p_nace2 <=88	
replace branch = 17	if p_nace2==34
replace branch = 18	if p_nace2>=90 & p_nace2 <=93	
replace branch = 19	if p_nace2>=94 & p_nace2 <=96	
replace branch = 20	if p_nace2>=97 & p_nace2 <=98	
replace branch = 21	if p_nace2==99	

label var branch "Industry currently"

tab branch work, m

foreach var of varlist branch {
 gen `var'_vgr =. 
replace `var'_vgr =1 if inlist(branch,1)
replace `var'_vgr =2 if inlist(branch,2,3,4,5)
replace `var'_vgr =3 if inlist(branch,6)
replace `var'_vgr =4 if inlist(branch,7,8,9)
replace `var'_vgr =5 if inlist(branch,10)
replace `var'_vgr =6 if inlist(branch,11)
replace `var'_vgr =7 if inlist(branch,12)
replace `var'_vgr =8 if inlist(branch,13,14)
replace `var'_vgr =9 if inlist(branch,15,16,17)
replace `var'_vgr =10 if inlist(branch,18,19,20,21)
		}

label var branch_vgr "Derzeit, Volkswirtschaftlichen Gesamtrechnungen (grobes SNA/ISIC-Aggregat A*10/11)"
label values branch_vgr branch_vgr_lab

tab branch_vgr work, m
tab branch branch_vgr 

 * ---------- Sectors ----------
 
#delimit
 recode branch 
(1 2 = 1 "Primär Sektor (Agrar & Bergbau)") 
(3 4 5 6 = 2 "Sekundär Sektor (Industrie)") 
(7 8 9 12 14 15 19 20 21 = 3 "Sonstige Dienstleistungen") 
(10 = 4 "Telekommunikation und Information") 
(11 = 5 "Finanz- und Versicherungs") 
(13 = 6 "Freiberufler, Wissenschaftler und Ingenieure") 
(16 = 7 "Bildung") 
(17 = 8 "Gesundheitsdienste") 
(18 = 9 "Kreative und künstlerische Tätigkeiten") 
 , gen(sektor_aggr2);
#delimit cr

#delimit
 label define sektor_aggr2_lab
1 "[1] Primär Sektor (Agrar & Bergbau)" 
2 "[2] Sekundär Sektor (Industrie)" 
3 "[3] Sonstige Dienstleistungen" 
4 "[4] Telekommunikation und Information" 
5 "[5] Finanz- und Versicherungs" 
6 "[6] Freiberufler, Wissenschaftler und Ingenieure" 
7 "[7] Bildung" 
8 "[8] Gesundheitsdienste" 
9 "[9] Kreative und künstlerische Tätigkeiten"
 , replace;
#delimit cr

label var sektor_aggr2 "Aggr2: Derzeit, Volkswirtschaftlichen Gesamtrechnungen (grobes SNA/ISIC-Aggregat A*10/11)"
label values sektor_aggr2 sektor_aggr2_lab

tab sektor_aggr2 work, m 
tab branch sektor_aggr2 

 /* log close

save $out_data/suare_v40_variablen.dta, replace */



