clear all
set maxvar 10000
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

  * ------------------------- 
    * VARIABLES: EDUCATION 
  * ------------------------- 

 * --- Education years before arrival ---

gen edu_asl = lb0228 
 * Ausbildung outside Germany
label define edu_asl 1 "[1] Ja" 2 "[2] Nein"
label var edu_asl "Studium oder Ausbildung außerhalb von DE"
label values edu_asl edu_asl

 * ----- Education years -----
   
clonevar years_sch0 = lb0187 // years in school outside Germany

replace years_sch0 = 0 if lb0183 == 2  
 * currently in school
recode years_sch0 . = 0 if lr3076 == 2 
 * school outside Germany: nein
 
label var years_sch0 "Schule: Bildungsjahre vor dem Zuzug"

tab1 years_sch0 lb0187

 * In Betrieb angelernt: Jahre, Monate 
rename lm0076i01 voc1yr 
rename lm0076i08 voc1m
 * Laengere Ausbildung in Betrieb: Jahre, Monate
rename lm0076i02 voc2yr 
rename lm0076i09 voc2m
 * Berufsbildende Schule: Jahre, Monate
rename lm0076i03 voc3yr 
rename lm0076i10 voc3m
 * Sonstige Ausbildung: Jahre, Monate
rename lm0076i07 voc4yr 
rename lm0076i14 voc4m

 * Hochschule mit praktischer Ausrichtung: Jahre, Monate
rename lm0076i04 uni1yr 
rename lm0076i11 uni1m
 * Hochschule mit theoretischer Ausrichtung: Jahre, Monate
rename lm0076i05 uni2yr 
rename lm0076i12 uni2m
 * Promotionsstudium: Jahre, Monate
rename lm0076i06 phd1yr 
rename lm0076i13 phd1m


sum years_sch0 voc1yr voc1m voc2yr voc2m voc3yr voc3m uni1yr uni1m uni2yr uni2m phd1yr phd1m voc4m voc4yr 
 
foreach var of varlist voc1yr voc1m voc2yr voc2m voc3yr voc3m uni1yr uni1m 	uni2yr uni2m phd1yr phd1m voc4m voc4yr {
	replace `var' = 0 if inlist(`var', .b)
}

 * Temporary variables
gen temp1=voc1yr+voc1m/12 
gen temp2=voc2yr+voc2m/12 
gen temp3=voc3yr+voc3m/12 
gen temp4=voc4yr+voc4m/12 
gen temp5=uni1yr+uni1m/12 
gen temp6=uni2yr+uni2m/12 
gen temp7=phd1yr+phd1m/12 

foreach var of varlist temp* {
	qui mvdecode `var', mv(0 = .b)
}

egen years_ausbhoch0 = rowtotal(temp1 temp2 temp3 temp4 temp5 temp6 temp7), m
replace years_ausbhoch0 = 0 if edu_asl == 2
label var years_ausbhoch0 "Vocational/University education years abroad"

sum years_sch0 years_ausbhoch0 

 * Create educational years
capture drop total_years_edu0
egen total_years_edu0=rowtotal(years_sch0 years_ausbhoch0), missing

replace total_years_edu0 = . if years_sch0 >= .
replace total_years_edu0 = . if years_ausbhoch0 >= .

sum total_years_edu0 

label var total_years_edu0 "Bildungsjahre vor dem Zuzug"

drop temp* voc1yr voc1m voc2yr voc2m voc3yr voc3m uni1yr uni1m uni2yr uni2m phd1yr phd1m voc4m voc4yr

bys pid (syear): carryforward total_years_edu0, replace

sum total_years_edu0

 * ------- School outside Germany -------

gen school_type = . 
replace school_type = 1 if inlist(lr3078,1,2)
replace school_type = 2 if inlist(lr3078,3,4)
replace school_type = 3 if inlist(lr3078,5)

label var school_type "Schulbesuch im Ausland"
#delimit
	label define school_type_lab
		1 "[1] Pflichtschule"
		2 "[2] Weiterfuehrende Schule"
		3 "[3] Andere Schule"
		, replace;
#delimit cr
label values school_type school_type_lab

gen school_degree = . 
replace school_degree = 1 if school_type == 1 & (lr3079 == 1 | lr3079 >= .)
replace school_degree = 2 if school_type == 1 & lr3079 == 2 
replace school_degree = 3 if school_type == 2 
replace school_degree = 4 if inlist(lr3079, 3, 4)
replace school_degree = 5 if school_type == 3 | lr3079 == 5
label var school_degree "Schulabschluss im Ausland"

#delimit
 label define school_degree
1 "[1] Pflichtschule o. Abschl."
2 "[2] Pflichtschule m. Abschl."
3 "[3] Weiterfuehrende Schule"
4 "[4] Weiterfuehrende Schule im Ausland mit Abschluss"
5 "[5] Abschluss einer anderen Schule"
		, replace;
#delimit cr
label values school_degree school_degree

 * Check
tab school_degree school_type, m
tab lr3079 school_degree


 * ---- Professional education Ausland ---
 
gen qual_type = . 
replace qual_type = 1 if inlist(lb0229,1)
replace qual_type = 2 if inlist(lb0230,1)
replace qual_type = 3 if inlist(lb0231,1)
replace qual_type = 4 if lm0071i01 == 1 | lm0071i02 == 1
replace qual_type = 5 if inlist(lb1376,1)
replace qual_type = 6 if inlist(lb0233,1)

label var qual_type "Berufliche Bildung im Ausland (besucht)"
#delimit
	label define qual_type_lab
		1 "[1] Angelernt"
		2 "[2] Betr. Ausbildung"
		3 "[3] Beruf. Schule"
		4 "[4] Hochschule"
		5 "[5] Promotion"
		6 "[6] Sonstiges"
		, replace;
#delimit cr
label values qual_type qual_type_lab

gen qual_type_deg = .
replace qual_type_deg = 8 if inlist(edu_asl,1)
replace qual_type_deg = 5 if qual_type == 6 & inlist(lm0643,2,3)
replace qual_type_deg = 1 if qual_type == 1 & inlist(lm0637,2,3)
replace qual_type_deg = 2 if qual_type == 2 & inlist(lm0638,2,3)
replace qual_type_deg = 3 if qual_type == 3 & inlist(lm0639,2,3)
replace qual_type_deg = 4 if qual_type == 4 & (inlist(lm0640,2,3) | inlist(lm0641,2,3))
replace qual_type_deg = 9 if qual_type == 5 & inlist(lm0642,2,3)

replace qual_type_deg = 15 if qual_type == 6 & inlist(lm0643,1)
replace qual_type_deg = 11 if qual_type == 1 & inlist(lm0637,1)
replace qual_type_deg = 12 if qual_type == 2 & inlist(lm0638,1)
replace qual_type_deg = 13 if qual_type == 3 & inlist(lm0639,1)
replace qual_type_deg = 14 if qual_type == 4 & (inlist(lm0640,1) | inlist(lm0641,1))
replace qual_type_deg = 19 if qual_type == 5 & inlist(lm0642,1)

label var qual_type_deg "Berufliche Bildung im Ausland (Abschluss)"

#delimit
 label define qual_type_deg
1 "[1] Angelernt"
2 "[2] Betriebl. Ausbildung"
3 "[3] Berufsbild. Schule"
4 "[4] Hochschule"
5 "[5] Sonstiges"
6 "[6] Berufsabschluss[bbil01] im Ausland erworben"
7 "[7] Hochschulabschluss[bbil02] im Ausland erworben"
8 "[8] Berufs- od.Hochschulabschluss in anderem Land"
9 "[9] Promotion (Ausland)"
11 "[11] mit Zeugnis,Angelernt"
12 "[12] mit Zeugnis,Betriebl. Ausbildung"
13 "[13] mit Zeugnis,Berufsbild. Schule"
14 "[14] mit Zeugnis,Hochschule"
15 "[15] mit Zeugnis,Sonstiges"
16 "[16] mit Zeugnis,Berufsabschluss[bbil01] im Ausland erworben"
17 "[17] mit Zeugnis,Hochschulabschluss[bbil02] im Ausland erworben"
18 "[18] mit Zeugnis,Berufs- od.Hochschulabschluss in anderem Land"
19 "[19] mit Zeugnis,Promotion (Ausland)"
		, replace;
#delimit cr
label values qual_type_deg qual_type_deg

 * Check
tab qual_type, m
tab qual_type_deg, m
tab qual_type_deg qual_type


  * --------------------
    * EDUCATION LEVEL
  * --------------------
  
 * ----- Education outside Germany 
			* (with degree)  ----- 

gen school_aus_cert = .

replace school_aus_cert = 1 if qual_type_deg == 1 | qual_type_deg == 3
replace school_aus_cert = 2 if qual_type_deg == 2 
replace school_aus_cert = 3 if qual_type_deg == 4
replace school_aus_cert = 4 if qual_type_deg == 5 
replace school_aus_cert = 0 if lr3076 == 2 | lb0183 == 2

#delimit 
label define school_aus_cert  
	0 "[0] Keine Schule" 
	1 "[1] Schule ohne Abschluss verlassen" 
	2 "[2] Mittelschule" 
	3 "[3] Weiterführ. Schule" 
	4 "[4] Sonstiges"
	, replace;
#delimit cr

label var school_aus_cert "Schulabschluss in anderem Land"
label values school_aus_cert school_aus_cert

 * Check
tab school_aus_cert, m
tab qual_type_deg school_aus_cert

 * ----- Vocational qualification outside Germany (with degree)  ----- 

gen beruf_aus_cert = .
replace beruf_aus_cert = 1 if inlist(qual_type_deg,1,2,3,4,5,6,7,8,9)
replace beruf_aus_cert = 2 if inlist(qual_type_deg,11,12,13,16) 
replace beruf_aus_cert = 3 if inlist(qual_type_deg,14,17,19) 
replace beruf_aus_cert = 4 if inlist(qual_type_deg,15,18) 
replace beruf_aus_cert = 0 if edu_asl == 2

#delimit 
label define beruf_aus_cert
	0 "[0] Keine Berufsbildung" 
	1 "[1] Berufsbildung ohne Abschluss verlassen" 
	2 "[2] Berufliche Ausbildung" 
	3 "[3] Hochschule/Universität/Promotion" 
	4 "[4] Sonstiges"
	, replace;
#delimit cr

label var beruf_aus_cert "Beruflicher Abschluss in anderem Land"
label values beruf_aus_cert beruf_aus_cert

 * Check
tab beruf_aus_cert, m  
tab qual_type_deg beruf_aus_cert

  * ----------
    * ISCED
  * ---------- 
  
 * --------- ISCED before arrival --------

#delimit
 label define isced_lab	
0 "[0] 0 Less than primary education/ No school"		
1 "[1] Primary education"				
2 "[2] Lower secondary education"
3 "[3] Upper secondary education" 
4 "[4] Post-secondary non-tertiary education"	
5 "[5] Short-cycle tertiary education"
6 "[6] Bachelor's/ Master's or equivalent level"			
8 "[8] Doctoral or equivalent level"
		, replace;
#delimit cr

* Label will be used multiple times for ISCED variables

 * ---- School degree outside Germany ----

* School degree equals zero if there is no degree or no school visit. It takes values of one for finishing secondary school and two for finishing high school.

gen schul_abschluss_aus = .
replace schul_abschluss_aus = 0 if school_aus_cert == 1 
 * kein Schulabschluss
replace schul_abschluss_aus = 0 if school_aus_cert == 0 
 * kein Schulbesuch
replace schul_abschluss_aus = 1 if school_aus_cert == 2 
 * Hauptschule, Realschule, Mittelschule
replace schul_abschluss_aus = 2 if school_aus_cert == 3 
 * Abitur, Fachhochschulreife, Weiterfuehrende Schule

#delimit
 label define schul_abschluss_aus 
0 "[0] keinen Schulabschluss"
1 "[1] Hauptschule/ Realschule/ Mittelschule" 
2 "[2] Abitur/Fachhochschulreife/ Weiterfuehrende Schule"
		, replace;
#delimit cr

label var schul_abschluss_aus "Schulabschluss im Ausland"
label values schul_abschluss_aus schul_abschluss_aus

tab school_aus_cert schul_abschluss_aus 

 * ----- School visit outside Germany ----

gen schulbesuch_aus=.
replace schulbesuch_aus=1 if lr3078==1  
 * Grundschule
replace schulbesuch_aus=2 if lr3078==2 
 * Mittelschule
replace schulbesuch_aus=3 if inlist(lr3078,3,4)
 * weiterfuehrende Schule

#delimit
	label define schulbesuch_aus 
		1 "[1] Grundschule" 
		2 "[2] Mittelschule" 
		3 "[3] weiterfuehrende Schule"
		, replace;
#delimit cr

label var schulbesuch_aus "Schulbesuch im Ausland"
label values schulbesuch_aus schulbesuch_aus

tab schulbesuch_aus, m
tab lr3078 schulbesuch_aus

 * ----- Education outside Germany: 
			* Type of degree ----- 

gen iabschlussa=.
replace iabschlussa=1 if inlist(qual_type_deg,12,13)
 * beruflicher Abschluss; Betrieb angelernt zählt nicht: lab11a==1 
replace iabschlussa=2 if inlist(qual_type_deg,14)  // Hochschulabschluss
replace iabschlussa=3 if inlist(qual_type_deg,19) // Promotion

#delimit
 label define iabschlussa_lab 
1 "[1] laengere Ausbildung/ berufsbildende Schule besucht" 
2 "[2] Hochschule" 
3 "[3] Promotion"
		, replace;
#delimit cr

label var iabschlussa "Berufsabschluss im Ausland"
label values iabschlussa iabschlussa_lab

tab iabschlussa, m 
tab qual_type_deg iabschlussa

 * --- Education type outside Germany ---

gen ausbildung_aus=.
replace ausbildung_aus = 1 if inlist(qual_type_deg,1,11)
 * Betrieb angelernt
replace ausbildung_aus = 2 if inlist(qual_type_deg,2,3,12,13)
 * laengere Ausbildung/  berufsbildende Schule besucht
replace ausbildung_aus = 3 if inlist(qual_type_deg,5,8,15)
replace ausbildung_aus = 4 if inlist(qual_type_deg,4,14) // Hochschule
replace ausbildung_aus = 5 if inlist(qual_type_deg,9,19) // Promotion

#delimit
	label define ausbildung_aus 
		1 "[1] Betrieb angelernt" 
		2 "[2] laengere Ausbildung/ berufsbildende Schule besucht" 
		3 "[3] Sonstiges"
		4 "[4] Hochschule" 
		5 "[5] Promotion"
		, replace;
#delimit cr

label var ausbildung_aus "Ausbildungsart im Ausland"
label values ausbildung_aus ausbildung_aus

tab ausbildung_aus, m
tab qual_type_deg ausbildung_aus

 * ----- Did not visit school (Dummy) ----

* lb0183 == 2: possible answer to lb0182 (Jahr des letzten Schulbesuchs) if person did not visit school 

gen no_school = 1 if lr3076  == 2 | lb0183 == 2  

label define no_school_lab 1 "[1] Ja"
label var no_school "Kein Schulbesuch"
label values no_school no_school_lab

tab no_school, m

 * ----- ISCED A (Attained, abroad) ----- 

capture drop isceda11a
gen isceda11a=.

 * "(0) 0 Less than primary education/ No school":
replace isceda11a=0 if no_school == 1 | (schulbesuch_aus==1 & inlist(years_sch0,0,1,2,3,4,5)) | (schul_abschluss_aus==0 & inlist(years_sch0,0,1,2,3,4,5))
* Keine schule oder grundschule besucht und Bildungsjahre kleiner als 6 oder 
* kein schulabschluss und Bildungsjahre kleiner als 6

 * "(1) Primary education":
replace isceda11a=1 if (schul_abschluss_aus==0 & years_sch0>=6 & years_sch0 < .) | (schulbesuch_aus==1 & years_sch0>=6 & years_sch0 < .) | inlist(schulbesuch_aus,2,3) 
* Kein schulabschluss und Bildungsjahre größer/gleich 6 oder Grundschule 
* besucht und Bildungsjahre größer/gleich 6 oder besuchte Mittel- oder 
* weiterführende Schule

 * "(2) Lower secondary education":
replace isceda11a=2 if schul_abschluss_aus==1 | inlist(schulbesuch_aus,3) | (inlist(ausbildung_aus,1,2) & iabschlussa!= 1)
* Abschluss Mittelschule oder besuchte weiterführende Schule
* Besuchte beruflische Schule ohne Abschluss

 * "(3) Upper secondary education":
replace isceda11a=3 if schul_abschluss_aus==2 | iabschlussa==1 | inlist(ausbildung_aus,4,5)  
* Abschluss weiterführende Schule oder Abschluss berufl. Bildung oder besucht Uni/Promotion

 * "(4) Post-secondary non-tertiary education:
replace isceda11a=4 if (schul_abschluss_aus==2 | inlist(ausbildung_aus,4,5)) & iabschlussa==1 
* Abschluss berufl. Bildung und Abschluss weiterführende Schule 
* Abschluss berufl. Bildung und besucht Uni/Promotion

 *"(6,7) Bachelor's/ Master's or equivalent level":		
replace isceda11a=6 if iabschlussa==2 | ausbildung_aus==5
* Abschluss Uni oder Besuch Promotion

 *"(8) Doctoral or equivalent level":
replace isceda11a=8 if iabschlussa==3
* Abschluss Promotion

label values isceda11a isced_lab
label var isceda11a "ISCED A 2011 vor Zuzug nach D"		
		
tab isceda11a, m
tab isceda11a schul_abschluss_aus
tab isceda11a ausbildung_aus

 * --- ISCED P (Participated, abroad)  ---

capture drop iscedp11a
gen iscedp11a=.

label values iscedp11a isced_lab
label var iscedp11a "ISCED P 2011 vor Zuzug nach D"

 * "(0) 0 Less than primary education/ No school":
replace iscedp11a=0 if no_school == 1
* Keine Schule besucht 
		
 * "(1) Primary education":
replace iscedp11a=1 if schul_abschluss_aus==0 | schulbesuch_aus==1 
* Kein schulabschluss oder Grundschule besucht 
		
 * "(2) Lower secondary education":
replace iscedp11a=2 if schul_abschluss_aus==1 | inlist(schulbesuch_aus,2) 
* Abschluss Primary schule oder besuchte Mittelschule
		
 * "(3) Upper secondary education":
replace iscedp11a=3 if schul_abschluss_aus==2 | iabschlussa==1  | inlist(schulbesuch_aus,3) | inlist(ausbildung_aus,1,2)
* Abschluss Mittelschule oder Abschluss berufl. Bildung oder besuchte 
* weiterführende Schule oder besucht berufl. Bildung

 * "(4) Post-secondary non-tertiary education:
replace iscedp11a=4 if (schul_abschluss_aus==2 & iabschlussa==1) | (schul_abschluss_aus==2 & inlist(ausbildung_aus,1,2))
* Abschluss Mittelschule und Abschluss berufl. Bildung 
* Abschluss Mittelschule und besucht berufl. Bildung

 *"(6,7) Bachelor's/ Master's or equivalent level":		
replace iscedp11a=6 if  iabschlussa==2 | ausbildung_aus==4
* Abschluss berufliche Bildung oder Besuch Uni

 *"(8) Doctoral or equivalent level":
replace iscedp11a=8 if iabschlussa==3  | ausbildung_aus==5
* Abschluss Hochschule oder Besuch Promotion

label values iscedp11a isced_lab
label var iscedp11a "ISCED P 2011 vor Zuzug nach D"
	
tab iscedp11a, m
tab iscedp11a schul_abschluss_aus
tab iscedp11a ausbildung_aus 

 * ------- ISCED A (Aggregated) -------

 * Completed
recode isceda11a 0=0 1=1 2=2 3/4=3 6/8=4 ,gen(isceda11a_aggr)

#delimit
 label define isceda11a_aggr_lab 
0 "[0] ISCED 0 - Weniger als Primarbereich" 
1 "[1] ISCED 1 - Primarbereich" 
2 "[2] ISCED 2 - Sekundärbereich I" 
3 "[3] ISCED 3/4 - Sekundärbereich II/ Postsekundärer nichttertiärer Bereich" 
4 "[4] ISCED 5/6/7 - Bachelor oder Master bzw. gleichwertiges Bildungsprogramm, Promotion"
		, replace;
#delimit cr

label var isceda11a_aggr "Completed ISCED A 2011 vor Zuzug nach D"
label values isceda11a_aggr isceda11a_aggr_lab

 * Participated
recode  iscedp11a (0=0) (1=1) (2=2) (3 4 = 3) (6 8 = 4), gen(iscedp11a_aggr)

label var iscedp11a_aggr "Visited ISCED A 2011 vor Zuzug nach D"
label values iscedp11a_aggr isceda11a_aggr_lab

tab iscedp11a_aggr, m
tab isceda11a_aggr, m

 * save $out_data/suare_v40_variablen.dta, replace