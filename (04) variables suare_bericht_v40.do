clear all
set maxvar 10000
capture log close

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023-Enddaten_REF_7709_Update_1_20240904"

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

 * log using $out_log/suare_v40_variablen.log, text replace

 * ----- Observation numbers -----

bys pid (syear): gen n = _n
bys pid (syear): gen N = _N

tab N

 * ----- Interview date ----- 

tab end_month end_year,m
label var end_month "Interview month"

tab day_interview
label var day_interview "Interview date"

gen intv_year_month = ym(end_year, end_month)
format intv_year_month %tm

  * --------------------------------
    * VARIABLES: SOCIODEMOGRAPHICS 
  * --------------------------------
  
 * ----- Gender -----
          
gen female = sex == 2 if sex < .

label define female 0 "[0] Nein" 1 "[1] Ja"
label var female "Female"
label values female female

tab female sex, m

 * ----- Age -----
 
gen geb_year_mont = ym(birthy, birthm)
format geb_year_mont %tm
 
gen age = trunc((intv_year_month-geb_year_mont)/12)
label var age "Current Age"
tab sex, sum(age)

recode age (18/25=1 "18-25") (26/35=2 "26-35") (36/max=3 "36+"), gen(age_cat)
label var age_cat "Age Cat. 36+"

recode age (18/25=1 "18-25") (26/35=2 "26-35") (36/45=3 "36-45") (46/59 = 4 "46-59") (60/max = 5 "60+"), gen(age_cat2)
label var age_cat2 "Age Cat. 60+"

tab age_cat sex, col m
tab age_cat2 sex, col m

* Age first interview

bys pid (syear): egen age1st = min(age) 
gen age1stsq = age1st*age1st

label var age1st "Alter bei erstem Interview"
label var age1stsq "Alter bei erstem Interview, sq."

tab age1st age_cat2,m

 * ----- Familienstand -----
 
gen partnership = . 
replace partnership = 0 if pld0131_v3 == 3 | plj0629 == 2
replace partnership = 1 if pld0131_v3 == 1 | pld0131_v3 == 2 | plj0629 == 1
replace partnership = 2 if pld0131_v3 == 4 | pld0131_v3 == 5
replace partnership = 3 if pld0131_v3 == 6 | pld0131_v3 == 7
 
label var partnership "Familienstand"

#delimit
label define partnership_lab 
	0 "Kein Partner" 
	1 "Partner/Verheiratet" 
	2 "Geschieden" 
	3 "Verwitwet"
	, replace;
#delimit cr
 lab val partnership partnership_lab

 * ---------- Arrival ----------
  
gen arrival_yr = .
	/* replace arrival_yr = immiyear if immiyear>0 & immiyear<.
replace arrival_yr=imyear if imyear>0 & imyear<. & arrival_yr >=. */

	replace arrival_yr=lr3130 if lr3130>0 & lr3130<. & arrival_yr>=.
	replace arrival_yr = lb0019_v5 if lb0019_v5>0 & lb0019_v5<. & arrival_yr>= .

forvalues i = 5(-1)1 {
	replace arrival_yr=lm0029l0`i' if lm0029l0`i'>0 & lm0029l0`i'<. & arrival_yr >=.
	}
	
gen arrival_mth=lr3131 if lr3131>0 & lr3131<.
	replace arrival_mth=lm22I99 if lm22I99>0 & lm22I99<. & arrival_mth >=.

forvalues i = 5(-1)1 {
	replace arrival_mth=lm0030l0`i' if lm0030l0`i'>0 & lm0030l0`i'<. & arrival_mth >=.
	}
	
label var arrival_yr "Arrival Year"
label var arrival_mth "Arrival Month"

gen arrival_date=ym(arrival_yr,arrival_mth)
format arrival_date %tm

label var arrival_date "Date of Arrival"

	tab arrival_yr prev_stichprobe 
	tab arrival_date prev_stichprobe 

  * --------------------
    * Duration of stay
  * --------------------
 
/* ----- Exact years -----

gen dur_stay_yr = end_year-arrival_yr 
replace dur_stay_yr=. if dur_stay_yr<0

label var dur_stay_yr "Aufenthaltsdauer in Jahren"

tab dur_stay_yr welle, m */

 * ----- Months since arrival -----

tab arrival_date
gen mnth_s_arrival = intv_year_month - arrival_date
 * br pid intv_year_month arrival_date mnth_s_arrival
recode mnth_s_arrival -3/2=1 3/6=2 7/9=3 10/12=4 13/16=5 17/19=6 20/23=7 24/max=8, gen(mnth_s_arvl_cat)

tab mnth_s_arrival mnth_s_arvl_cat

#delimit
	label define mnth_s_arvl_cat  
		1 "[1] Weniger als 3 Monate" 
		2 "[2] 3 bis 6 Monate" 
		3 "[3] 7 bis 9 Monate" 
		4 "[4] 10 bis 12 Monate" 
		5 "[5] 13 bis 16 Monate"
		6 "[6] 17 bis 19 Monate"
		7 "[7] 20 bis 23 Monate"
		8 "[8] Mehr als 24 Monate"
		, replace;
#delimit cr
label var mnth_s_arvl_cat "Months since arrival to Germany"
label values mnth_s_arvl_cat
		
tab mnth_s_arvl_cat, m

 * ----- für immer in DE ---- 
gen forever_de_v40 = plj0085_v1 == 1 if plj0085_v1>0 & plj0085_v1<.
 lab var forever_de_v40 "für immer in DE"

* ----- Bleibeabsichten ---- 

gen settle_intent = 1 if forever_de_v40 == 1
replace settle_intent = 4 if plj0086_v1 == .a & plj0087 == .a
replace settle_intent = 3 if plj0086_v1 == 1 | (plj0087 >= 1 & plj0087 < .)
replace settle_intent = 2 if plj0086_v1 == 2 

#delimit
	label define settle_intent_lab 
	1 "[1] Für immer in DE" 
	2 "[2] Noch einige Jahre"
	3 "[3] Höchstens noch ein Jahr"
	4 "[4] Unischer"
	, replace;
#delimit cr
label var settle_intent "Bleibeabsichten"
label values settle_intent settle_intent_lab

 * ---------------------
  * Dummy für Kohorte
 * ---------------------

gen kohorte = .
replace kohorte = 1 if arrival_date < ym(2022,6)
replace kohorte = 2 if arrival_date => ym(2022,6) & arrival_date!= .

label define kohorte_lab 1 "Zuzug bis Juni 2022" 2 "Zuzug nach Juni 2022"
label var kohorte "Zuzugskohorte"
label values kohorte kohorte_lab

  * ---------------------
    * Region in Germany
  * ---------------------

tab bula

 * East Germany
gen east_g= (bula>=12) & !missing(bula)
label def east 1 "East" 0 "West", modify
label values east east

 * West Germany
gen west_g = 1 - east

tab bula west

  * ----------
    * HEALTH
  * ----------

 * ----- Self-rated health -----
 mvdecode ple0008, mv(-1/-9)
  gen healthy = 6-ple0008 
  lab def healthy 1 "very bad" 5 "very good"
  lab val healthy healthy
  lab var healthy "self-rated health"
  tab healthy, m
	
 * ----- two categories -----

gen byte health1=(healthy>=4) & !missing(healthy)
	label def health1 0 "niedrig bis mittelmäßig" 1 "Gut bis sehr gut", modify
	label values health1 health1	
	tab healthy health1
	
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
	6 "Freiwilliges soziales Jahr"
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
replace actual_empl = 5 if inlist(plb0022_v11,10)
replace actual_empl = 6 if inlist(plb0022_v11,7)
replace actual_empl = 10 if inlist(plb0022_v11,11)
replace actual_empl = 9 if inlist(plb0022_v11,5,9)

tab actual_empl syear, m row
tab plb0022_v11 actual_empl
	
 * ---------- Erwerbstätig ----------
 
gen work = .
replace work = 1 if inlist(plb0022_v11,1,2,3,4,5,7,10,11)
replace work = 0 if inlist(plb0022_v11,9) 
label var work "Derzeit: Erwerbstätig"
label define work_lab 0 "[0] Nein" 1 "[1] Ja"
label values work work_lab
tab plb0022_v11 work, m	

 * ----- Employed in paid work -----
gen paid_work = .
replace paid_work = 1 if inlist(plb0022_v11,1,2,3,4,5,7,10,11)
replace paid_work = 0 if inlist(plb0022_v11,9)
replace paid_work = 0 if plc0013_v2 == 0 & plc0014_v2 == 0
label var paid_work "Employed in paid work"
tab work paid_work

 * ---------- Dummy für Vollzeit ----------

gen vollzeit = .
replace vollzeit = 1 if actual_empl == 1
replace vollzeit = 0 if actual_empl > 1 & actual_empl != . 

label define vollzeit_lab 0 "nicht Vollzeit" 1 "Vollzeit"
label var vollzeit "Vollzeitbeschäftigung"
label values vollzeit vollzeit_lab

 * ---------- Dummy für geringfügige Beschäftigung ----------

gen geringf = actual_empl == 4 if actual_empl < .
label define geringf_lab 0 "Nein" 1 "Ja"
label var geringf "geringfügige Beschäftigung"
label values geringf geringf_lab

 * ----------  Dummy für Selbstständige ----------

gen selfem = plb0568_v1 == 1 if plb0568_v1 < .
label define selfem_lab 0 "Nein" 1 "Ja"
label var selfem "Selbständige"
label values selfem selfem_lab

 * ----- Employed / Not/looking for work -----
gen lfs_status = .
recode lfs_status .= 1 if paid_work == 1
recode lfs_status .= 2 if plb0424_v2 == 1
recode lfs_status .= 3 if plb0424_v2 == 2
recode lfs_status .= 3 if paid_work == 0

#delimit
label define lfs_status 
	1 "[1] Erwerbstätig (gegen Entgelt)" 
	2 "[2] Aktiv arbeitssuchend (letzte 4 Wochen)" 
	3 "[3] Nicht arbeitssuchend", replace;
#delimit cr
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

 * ----- Dummy für aktive Arbeitssuche -----

gen job_search = lfs_status == 2 if lfs_status < .
label define job_search_lab 0 "Nein" 1 "Ja"
label var job_search "aktiv Arbeitssuchend"
label values job_search job_search_lab

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

  * ----- LEVEL OF QUALIFICATION/JOB -----
  
  * ----- (TÄTIGKEITSNIVEAU) -----

tab l_isco08_job09, m
tab l_kldb2010_job09, m

  * ----- ISCO OF WORK  -----

clonevar isco0_08 = l_isco08_job09
recode isco0_08 (0/99 = .)
tab isco0_08 if work0 == 1, m
	
****ISEI SCALE****
iscogen isei0 = isei(isco0_08)
label var isei0 "Job Current: ISEI scale (international socio-economic index)"

iscogen isco0_1dig = major(isco0_08)
label var isco0_1dig "ISCO vor Zuzug, 1 digit"

iscogen isco0_oesch5 = oesch5(isco0_08)
tab isco0_oesch5
recode isco0_oesch5 (4=3) (5=4)

#delimit;
	label define isco0_oesch5_lab 
	1 "Berufe mit Hochschulbildung" 
	2 "Berufe mit höhere Fachausbildung" 
	3 "Lehrberufe" 
	4 "An- und Ungelernte"
	, replace;
#delimit cr
label val isco0_oesch5 isco0_oesch5_lab	
label var isco0_oesch5 "ISCO curr, Oesch 2006a"

gen isco0_skilllev = .

#delimit;
	label define isco0_skilllev_lab
	1 "Hilfsarbeitskräfte" 
	2 "Fachkräfte" 
	3 "Gehobene Fachkräfte/ Akademische Berufe"
	, replace;
#delimit cr
label val isco0_skilllev isco0_skilllev_lab
label var isco0_skilllev "ISCO curr, skill level"

replace isco0_skilllev = 1 if inlist(isco0_1dig,9)
replace isco0_skilllev = 2 if inlist(isco0_1dig,4,5,6,7,8)
replace isco0_skilllev = 3 if inlist(isco0_1dig,1,2,3)

**** KILDB ****
tab l_kldb2010_job09
recode l_kldb2010_job09 (-10/99 = .)

clonevar kldb0 = l_kldb2010_job09
recode kldb0 (-10/0 = .) (.b .c .e = .)
tab kldb0 if work0 == 1, m

tostring kldb0, gen(helpvar0)
replace helpvar0 = substr(helpvar0,-1,.) 
destring helpvar0, replace

#delimit
	recode helpvar0
		(1 = 1 "Helfer")
		(2 = 2 "Fachkraft")
		(3 = 3 "Spezialist")
		(4 = 4 "Experte")
		, gen(niveau0)
		;
#delimit cr

drop helpvar0
tab niveau0 if work0 == 1, m
lab var niveau0 "Anforderungsniveau (KLDB) vor zuzug"

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

 * ----- DUMMY WORK ASPIRATION -----

recode future_empl (0 = .) (1 2 = 0) (3 4 = 1), gen(future_empl_dum)
label define future_empl_dum_lab 0 "Nein" 1 "Ja"
label var future_empl_dum "Erwerbsaspiration"
label values future_empl_dum future_empl_dum_lab

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

 * ----- Abschlussanerkennung ------
 
clonevar hilfe_anerkennung = lr3595i06
 
egen help_an_moeg = anymatch(lb0229 lb0230 lb0231 lm0071i0? lb1376 lb0233), values(1)
egen help_an_ja = anymatch(lm0701l0*), values(1)
 
gen abschl_anerkenn = .
replace abschl_anerkenn = 1 if help_an_ja == 1 & help_an_moeg == 1
replace abschl_anerkenn = 0 if help_an_ja == 0 & help_an_moeg == 1
drop help_an*

label define abschl_anerkenn_lab 0 "[0] Nein" 1 "[1] Ja"
label var abschl_anerkenn "Anerkennung eines Abschlusses beantragt"
label values abschl_anerkenn abschl_anerkenn_lab 

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

save $out_data/suare_v40_variablen.dta, replace

log using $out_log/suare_v40_variablen.log, append */

  * --------------------
    * GERMAN LANGUAGE
  *  --------------------

 * ----- Speaking -----
 
gen speak_german = plj0071 

label var speak_german "German Language: Speaking"
#delimit
label define speak_german_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values speak_german speak_german_lab		
		
tab speak_german

 * ----- Writing -----

gen write_german = plj0072 

label var write_german "German Language: Writing"
#delimit
label define write_german_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values write_german write_german_lab	

tab write_german

 * ----- Reading -----

gen read_german = plj0073 

label var read_german "German Language: Reading"
#delimit
label define read_german_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values read_german read_german_lab	

tab read_german

 * ----- Language score -----

foreach var of varlist speak_german write_german read_german {
	recode `var' (1=5) (2=4) (3=3) (4=2) (5=1)  
	label val `var' language
	}

egen german_score=rowmean(speak_german read_german write_german)

label var german_score "German Language (Score)"

tab german_score, m

  * --------------------
    * ENGLISH LANGUAGE
  *  --------------------

 * ----- Speaking -----
 
gen speak_english = plj0698

label var speak_english "English Language: Speaking"
#delimit
label define speak_english_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values speak_english speak_english_lab	

tab speak_english

 * ----- Writing -----

gen write_english = plj0699 

label var write_english "English Language: Writing"
#delimit
label define write_english_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values write_english write_english_lab	

tab write_english

 * ----- Reading -----

gen read_english = plj0700

label var read_english "English Language: Reading"
#delimit
label define read_english_lab 
		1 "[1] Sehr gut"
		2 "[2] Gut"
		3 "[3] Es geht"
		4 "[4] Eher schlecht"
		5 "[5] Gar nicht"
		, replace;
#delimit cr
label values read_english read_english_lab	

tab read_english

 * ----- Language score -----

foreach var of varlist speak_english write_english read_english {
	recode `var' (1=5) (2=4) (3=3) (4=2) (5=1)  
	label val `var' language
	}

egen english_score=rowmean(speak_english read_english write_english)

label var english_score "English Language (Score)"

tab english_score, m

  * -------------------------
    * INTEGRATION COURSE BAMF
  *  -------------------------

 * ----- Participation -----
 
gen int_bamf_part = 1 if plj0654 == 1 
recode int_bamf_part (. = 0) if plj0654 == .b  

label define int_bamf_part_lab 0 "[0] Nein" 1 "[1] Ja"
#delimit
label var int_bamf_part "Teilgenommen oder Teilnahmen derzeit in Integrationskurs des BAMF";
#delimit cr
label values int_bamf_part int_bamf_part_lab

tab int_bamf_part plj0654, m

 * ----- Finished course -----

* coded as finished if participated, year of finishing is known, and course is not ongoing  
gen int_bamf_finished = 1 if plj0657 >0 & plj0657 < . & plj0659_v1 != 1
recode  int_bamf_finished . = 0 if int_bamf_part == 0
* plj0659_v1 is labelled as "end of course" but was always "course ongoing" in previous waves
recode  int_bamf_finished . = 0 if plj0659_v1 == 1
* Rest is missing information

label define int_bamf_finished_lab 0 "[0] Nein" 1 "[1] Ja"
label var int_bamf_finished "Integrationskurs: abgeschlossen"
label values int_bamf_finished int_bamf_finished_lab

tab int_bamf_finished plj0659_v1, m

 * ----- Current participation -----

gen int_bamf_curr = 1 if plj0659_v1 == 1
recode int_bamf_curr .= 0 if int_bamf_finished == 1
recode int_bamf_curr .= 0 if int_bamf_finished == 0

label define int_bamf_curr_lab 0 "[0] Nein" 1 "[1] Ja"
label var int_bamf_curr "Integrationskurs: teilnahme derzeit"
label values int_bamf_curr int_bamf_curr_lab

tab int_bamf_curr plj0659_v1, m

  * ------------------------------
    * OTHER GERMAN LANGUAGE COURSE
  *  ------------------------------

 * ----- Participation -----

gen other_course_part = 1 if plj0535 == 1
replace other_course_part = 1 if plm733 > 0 & plm733 < .
replace other_course_part = 1 if plm735i01I01 > 0 & plm735i01I01 < .
recode other_course_part (. = 0) if plj0535 == .b

label define other_course_part  0 "[0] Nein" 1 "[1] Ja"
#delimit ;
label var other_course_part "Teilgenommen oder Teilnahme derzeit in Anderem 
	Deutschsprachkurs";
#delimit cr
label values other_course_part

tab mnth_s_arvl_cat other_course_part, m

 * ----- Finished course -----

* coded as finished if participated, year of finishing is known, and course is not ongoing  
gen other_course_fin = 1 if plj0538 >0 & plj0538 < . & plj0540 != 1
recode  other_course_fin . = 0 if other_course_part == 0
recode  other_course_fin . = 0 if plj0540 == 1
replace other_course_fin = 1 if plm735i01I01 > 0 & plm735i01I01 < . 

* Rest is missing information

label define other_course_fin 0 "[0] Nein" 1 "[1] Ja"
label var other_course_fin "Anderer Deutschsprachkurs: abgeschlossen"
label values other_course_fin other_course_fin

tab mnth_s_arvl_cat other_course_fin, m

 * ----- Current participation -----

gen other_course_aktl = .
replace other_course_aktl = 1 if other_course_part == 1 & other_course_fin == 0
replace other_course_aktl = 1 if plm736I01 == 1
replace other_course_aktl = 1 if plm736I02 == 1
recode  other_course_aktl . = 0 if other_course_fin == 1

label define other_course_aktl  0 "[0] Nein" 1 "[1] Ja"
label var other_course_aktl "Anderer Deutschsprachkurs: Teilnahme derzeit"
label values other_course_aktl other_course_aktl

tab other_course_aktl, m

  * ------------------------------
    * GERMAN COURSES AGGREGATED
  * ------------------------------

 * ----- Participation ----- 
 
* integrates all types of courses from generated variables and all persons who have participated in one regardless of finishing it; 
* job-related German courses are also included

gen deu_aggr_part = .
replace deu_aggr_part = 0 if other_course_part == 0
replace deu_aggr_part = 0 if int_bamf_part == 0 
replace deu_aggr_part = 0 if plm733 == 0 

replace deu_aggr_part = 1 if other_course_part == 1
replace deu_aggr_part = 1 if int_bamf_part ==1 
replace deu_aggr_part = 1 if plm733 >= 1 & plm733 < .
replace deu_aggr_part = 1 if plm723I02 == 1
replace deu_aggr_part = 1 if plm724I02 >= 1 & plm724I02 < .
replace deu_aggr_part = 1 if plm729I01 == 1

label define deu_aggr_part_lab 0 "[0] Nein" 1 "[1] Ja"
label var deu_aggr_part "Teilnahme an Deutschkurs (aggregiert)"
label values deu_aggr_part deu_aggr_part_lab

tab deu_aggr_part, m 

 * ----- Finished course -----

* Finished courses from gen. variables and job-related German courses

gen deu_aggr_finished = .
replace deu_aggr_finished = 0 if other_course_fin == 0
replace deu_aggr_finished = 0 if other_course_aktl == 1
replace deu_aggr_finished = 0 if int_bamf_finished == 0
replace deu_aggr_finished = 0 if int_bamf_curr == 1  

replace deu_aggr_finished = 1 if other_course_fin == 1
replace deu_aggr_finished = 1 if int_bamf_finished ==1 
replace deu_aggr_finished = 1 if plm726I01 >= 1 & plm726I01 < .

label define deu_aggr_finished_lab 0 "[0] Nein" 1 "[1] Ja"
label var deu_aggr_finished "Deutschkurs abgeschlossen (aggregiert)"
label values deu_aggr_finished deu_aggr_finished_lab

tab deu_aggr_finished, m 

 * ----- Number of courses -----

* Number of all German courses a person has ever participated in; refers only to participation, not finishing

gen deu_aggr_num = 0	
foreach var of varlist int_bamf_part plm733 plm724I02 {
	gen help = 0
	replace help = `var' if !inlist(`var',.a, .b, .c, .d, .e, .f, .g) 
	replace deu_aggr_num = deu_aggr_num + help 
	drop help
}

label var deu_aggr_num "Anzahl Deutschkurse (teilgenommen)"
	
tab deu_aggr_num, m 

log close
save $out_data/suare_v40_variablen.dta, replace

use $out_data/suare_v40_variablen.dta, clear
log using $out_log/suare_v40_variablen.log, append

  * ------------------------------
    * Duration until first course
  * ------------------------------

 * ----- Help variables -----  

* Anderer Kurs 
gen helpdate1 = ym(plj0536,plj0537)	
format helpdate1 %tm
gen helpyr1 = plj0536
tab1 help*

* Integrationskurs
gen helpdate2 = ym(plj0655,plj0656)  
format helpdate2 %tm
gen helpyr2 = plj0655
tab1 helpdate2 helpyr2 plj0655 plj0656

foreach var of varlist helpdate?  {
	replace `var'  = . if `var' < arrival_date
}

foreach var of varlist helpyr?  {
	replace `var'  = . if `var' < arrival_yr
}

br pid helpdate2 helpyr2 plj0655 plj0656 arrival*

 * ----- Date (yr, mth) first course -----

capture drop date_1stcourse
egen temp_date = rowmin(helpdate?)
format %tm  temp_date
bys pid (syear): egen date_1stcourse = min(temp_date)
format %tm date_1stcourse
drop temp_date

tab date_1stcourse, m

 * ----- Year first course -----

capture drop temp_date
egen temp_date = rowmin(helpyr?)
bys pid (syear): egen yr_1stcourse = min(temp_date)
format %tm yr_1stcourse
drop temp_date

* check
sort pid syear
br pid syear arrival_date arrival_yr day_interview date_1stcourse yr_1stcourse help* plj0655 plj0656
capture drop helpvar
gen helpvar = 1 if date_1stcourse < = intv_year_month

tab date_1stcourse, m

* ---- Months between arrival and start of first course ----

egen lang_course_miss = rownonmiss(int_bamf_part other_course_part)
egen lang_course = anymatch(int_bamf_part other_course_part),v(1)
replace lang_course = . if lang_course_miss != 4

capture drop mths_kursstart
gen mths_kursstart = date_1stcourse - arrival_date if helpvar == 1
bys pid (syear): carryforward mths_kursstart, replace
replace mths_kursstart = intv_year_month-arrival_date if lang_course == 0 & mths_kursstart >= .

label var mths_kursstart "Monate bis zum ersten Kurs"	
	
tab mths_kursstart, m

 * ----- Years between arrival and start of first course -----

capture drop yrs_kursstart
drop helpvar
gen helpvar = 1 if yr_1stcourse < = syear
gen yrs_kursstart = yr_1stcourse - arrival_yr if helpvar == 1
bys pid (syear): carryforward yrs_kursstart, replace
replace yrs_kursstart = syear -arrival_yr if lang_course == 0 & yrs_kursstart >= .

drop helpvar helpdate* helpyr* date_1stcourse yr_1stcourse lang_course lang_course_miss

recode yrs_kursstart (-1 = 0)

label var yrs_kursstart "Jahre bis zum ersten Kurs"

su *kursstart 
tab yrs_kursstart, m

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

 * ----- Youngest child: age group -----

gen help1 = prev_k_birthy_v2_1
gen help2 = prev_k_birthy_v2_2
gen help3 = prev_k_birthy_v2_3
gen help4 = prev_k_birthy_v2_4
gen help5 = prev_k_birthy_v2_5
gen help6 = prev_k_birthy_v2_6
gen help7 = prev_k_birthy_v2_7
gen help8 = prev_k_birthy_v2_8
gen help9 = prev_k_birthy_v2_9
gen help10 = prev_k_birthy_v2_10

foreach var of varlist help* {
	replace `var' = . if `var'<0
}

foreach var of varlist help* {
	replace `var' = (2023 - `var')
}

egen youngest_child = rowmin(help*) 
sort pid
br pid youngest_child help*

drop help* 

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

 * ----- Children in the household (separate dummies) -----

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

 * ----------------------------------------

log close
save $out_data/suare_v40_variablen.dta, replace

use $out_data/suare_v40_variablen.dta, clear
log using $out_log/suare_v40_variablen.log, append

  * --------------------
    * CLEAN VARIABLES
  * --------------------

#delimit
keep pid hid cid syear n N prev_stichprobe samplehh instrument mode start* end* 
day_interview intv_year_month actual_empl work paid_work lfs_status 
lfs_status_dtl lmactivity female age age1st age1stsq age_cat age_cat2 
arrival_yr arrival_mth arrival_date mnth_s_arrival mnth_s_arvl_cat
edu_asl years_sch0 years_ausbhoch0 total_years_edu0 school_type school_degree 
qual_type qual_type_deg school_aus_cert beruf_aus_cert schul_abschluss_aus 
schulbesuch_aus iabschlussa ausbildung_aus no_school
isceda11a iscedp11a isceda11a_aggr iscedp11a_aggr ec_status0 inc_status0 empl0 
empl0_aggr work0 branch0 branch0_vgr sektor0_aggr2 l_isco08_job09 
l_kldb2010_job09 actual_empl work future_empl empl_type work_befrist 
work_maßnahm work_blohn work_nlohn work_hours_contract work_hours_actual 
work_blohn_hour work_nlohn_hour branch branch_vgr sektor_aggr
speak_german write_german read_german german_score speak_english write_english 
read_english english_score int_bamf_part int_bamf_finished int_bamf_curr 
other_course_part other_course_fin other_course_aktl deu_aggr_part 
deu_aggr_finished deu_aggr_num mths_kursstart yrs_kursstart children h_child_hh 
hchild_N youngest_child h_child_age h_child_age_0_2 h_child_age_3_6 
h_child_age_7_17 partnr partner_vorh partnership forever_de_v40 bula
p_isco08 isco_1dig isco_oesch5 isco_skilllev p_kldb2010 kldb niveau
isco0_08 isco0_1dig isco0_oesch5 isco0_skilllev kldb0 niveau0 arbeitslos
timing_empl type_empl hh_leistungen hh_leistungen_hoehe
hilfe_anerkennung abschl_anerkenn phrf23vorab_SUARE job_search
settle_intent kohorte vollzeit geringf selfem job_search;
#delimit cr

********************************************

save $dataout/SOEP_v40_clean.dta, replace



capture log close

********************************************************************************
