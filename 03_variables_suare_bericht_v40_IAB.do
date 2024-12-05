/*------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  
  ******************************************************************************
  ******************************************************************************
  * Joint SUARE Report 2024  												****
  *																			****
  * IAB, BAMF, SOEP  														****
  *																			****
  * Date: 			19.08.2024												****
  * Last Modified: 	04.12.2024												****
  ******************************************************************************
  ******************************************************************************

  VARIABLE PREPERATION 

------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

capture log close
capture log using "$out_log/suare_v40_variablen_date${date}.log", replace

set more off
clear

********************************************************************************

use $out_data/suare_bericht_v40_data.dta, clear

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

gen age_arriv = arrival_yr- gebjahr
recode age_arriv (18/25=1 "18-25") (26/35=2 "26-35") (36/45=3 "36-45") (46/59 = 4 "46-59") (60/max = 5 "60+"), gen(age_arriv_cat2)
label var age_arriv_cat2 "Age at arrival Cat. 60+"



  * --------------------
    * Duration of stay
  * --------------------
 
* ----- Exact years -----

gen dur_stay_yr = end_year-arrival_yr 
replace dur_stay_yr=. if dur_stay_yr<0

label var dur_stay_yr "Aufenthaltsdauer in Jahren"

tab dur_stay_yr , m


 * ----- Months since arrival -----
tab arrival_date
gen mnth_s_arrival = intv_year_month - arrival_date
// br pid intv_year_month arrival_date mnth_s_arrival
recode mnth_s_arrival -3/2=1 3/6=2 7/9=3 10/12=4 13/16=5 17/19=6 20/23=7 24/max=8, gen(mnth_s_arvl_cat1)

tab mnth_s_arrival mnth_s_arvl_cat1

#delimit
	label define mnth_s_arvl_cat1  
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
label var mnth_s_arvl_cat1 "Months since arrival to Germany"
label values mnth_s_arvl_cat1
		
tab mnth_s_arvl_cat1, m

recode mnth_s_arvl_cat1 (min/4 = 1) (5 = 2) (6 = 3) (7/max = 4), ///
	gen(mnth_s_arvl_cat2)

#delimit
	label define mnth_s_arvl_cat2  
		1 "[1] 12 Monate oder weniger" 
		2 "[2] 13 bis 16 Monate"
		3 "[3] 17 bis 19 Monate"
		4 "[4] Mehr als 20 Monate"
		, replace;
#delimit cr
label var mnth_s_arvl_cat2 "Monate seit Ankunft in Deutschland"
label values mnth_s_arvl_cat2 mnth_s_arvl_cat2
		
tab mnth_s_arvl_cat2, m


recode  mnth_s_arrival (0/12 = 1) (13/18 = 2) (19/max = 3), ///
	gen(mnth_s_arvl_cat3)

#delimit
	label define mnth_s_arvl_cat3  
		1 "[1] bis 1 Jahr" 
		2 "[2] 13 bis 18 Monate"
		3 "[3] 19 bis 23 Monate"
		, replace;
#delimit cr
label var mnth_s_arvl_cat3 "Monate seit Ankunft in Deutschland"
label values mnth_s_arvl_cat3 mnth_s_arvl_cat3
		
tab mnth_s_arvl_cat3, m

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

recode settle_intent (1=1)(2=2)(3=2)(4=3), gen(bleibeabsichten) 
label var bleibeabsichten "Bleibeabsichten"
label define bleibeabsichten 1 "Für immer in Deutschland" 2"Vorübergehend in Deutschland" 3"Ungewiss"
label values bleibeabsichten bleibeabsichten 
fre bleibeabsichten 

 * ---------------------
  * Dummy für Kohorte
 * ---------------------

gen kohorte = .
replace kohorte = 1 if arrival_date < ym(2022,6)
replace kohorte = 2 if arrival_date >= ym(2022,6) & arrival_date!= .

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
label values east_g east

 * West Germany
gen west_g = 1 - east_g

tab bula west_g

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
	
save $out_data/temp.dta, replace	
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
 
foreach var of varlist voc1yr voc1m voc2yr voc2m voc3yr voc3m uni1yr uni1m uni2yr uni2m phd1yr phd1m voc4m voc4yr {
	replace `var' = 0 if inlist(`var', .b)
}

 * Temporary variables
replace voc1yr=voc1yr+voc1m/12 
replace voc2yr=voc2yr+voc2m/12 
replace voc3yr=voc3yr+voc3m/12 
replace voc4yr=voc4yr+voc4m/12 
replace uni1yr=uni1yr+uni1m/12 
replace uni2yr=uni2yr+uni2m/12 
replace phd1yr=phd1yr+phd1m/12 

foreach var of varlist voc1yr voc2yr voc3yr voc4yr uni1yr uni2yr phd1yr  {
	qui mvdecode `var', mv(0 = .b)
}

egen years_ausbhoch0 = rowtotal(voc1yr voc2yr voc3yr voc4yr uni1yr uni2yr phd1yr), m
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

replace qual_type_deg = 15 if qual_type == 6 & inlist(lm0643,1)
replace qual_type_deg = 11 if qual_type == 1 & inlist(lm0637,1)
replace qual_type_deg = 12 if qual_type == 2 & inlist(lm0638,1)
replace qual_type_deg = 13 if qual_type == 3 & inlist(lm0639,1)
replace qual_type_deg = 14 if qual_type == 4 & (inlist(lm0640,1) | inlist(lm0641,1))
replace qual_type_deg = 19 if qual_type == 5 & inlist(lm0642,1)

replace qual_type_deg = 5 if qual_type == 6 & inlist(lm0643,2,3)
replace qual_type_deg = 1 if qual_type == 1 & inlist(lm0637,2,3)
replace qual_type_deg = 2 if qual_type == 2 & inlist(lm0638,2,3)
replace qual_type_deg = 3 if qual_type == 3 & inlist(lm0639,2,3)
replace qual_type_deg = 4 if qual_type == 4 & (inlist(lm0640,2,3) | inlist(lm0641,2,3))
replace qual_type_deg = 9 if qual_type == 5 & inlist(lm0642,2,3)


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

replace school_aus_cert = 1 if lr3079 == 1
replace school_aus_cert = 2 if lr3079 == 2 
replace school_aus_cert = 3 if lr3079 == 3 | lr3079 == 4
replace school_aus_cert = 4 if lr3079 == 5 
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

*Berufsabschluss 1* 

recode beruf_aus_cert (0=1)(1=1)(2=2)(3=3)(4=1), gen(berufsabschl_a)
label var berufsabschl_a "Abschluss im Ausland"
label define berufsabschl 1"Ohne Berufsabschluss" 2"Mit Berufsabschluss" 3"Mit Hochschulabschluss"
label values berufsabschl_a berufsabschl
fre berufsabschl_a 


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
replace iabschlussa=2 if inlist(qual_type_deg,9)  // Promotionbesucht (unmöglich ohne Uni abschluss)
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
replace ausbildung_aus = 2 if inlist(qual_type_deg,2,3,6,12,13,16)
 * laengere Ausbildung/  berufsbildende Schule besucht
replace ausbildung_aus = 3 if inlist(qual_type_deg,5,15,18)
replace ausbildung_aus = 4 if inlist(qual_type_deg,4,7,8,14,17) // Hochschule
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

gen no_school = 1 if lr3076  == 2 | lb0183 == 2  
/* 37 persons answered lr3076, 28 persons answered lb0183 
   lb0183 == 2: possible answer to lb0182 (Jahr des letzten Schulbesuchs) 
   if person did not visit school abroad */

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



 * ---- Professional education Ausland, abschluess ---
	* Mehrfahrnennungen möglich!!!
* es kann passieren, dass ein person hat ausbildung gemacht und abgeschlossen
* unhd dann uni und nicht abgeschlossen
* durch kodierung wird dieser person als derjenige, der kein abschluss hat kodiert! nicht richtig
label def ausbildung 1 "Mit Abschlusszeugnis beendet" 2 "Ohne Abschlusszeugnis oder Vorzeitig abgebrochen", replace

gen in_betrieb_angl = . 
replace in_betrieb_angl = 1 if inlist(lm0637,1)
replace in_betrieb_angl = 2 if inlist(lm0637,2,3) | (inlist(lm0637,.) & lb0229==1)
label var in_betrieb_angl "Im Betrieb angelernt: mit/ohne Abschluss"
tab voc1yr in_betrieb_angl

gen in_betrieb_angl_lang = .
replace in_betrieb_angl_lang = 1 if inlist(lm0638,1)
replace in_betrieb_angl_lang = 2 if inlist(lm0638,2,3) | (inlist(lm0638,.) & lb0230==1)
label var in_betrieb_angl_lang "Im Betrieb laengere Ausbildung: mit/ohne Abschluss"
tab voc2yr in_betrieb_angl_lang

gen berufsbild = .
replace berufsbild = 1 if inlist(lm0639,1)
replace berufsbild = 2 if inlist(lm0639,2,3)  | (inlist(lm0639,.) & lb0231==1)
label var berufsbild "Besuch berufsbildender Schule: mit/ohne Abschluss"
tab voc3yr berufsbild

gen uni_prakt = .
replace uni_prakt = 1 if inlist(lm0640,1)
replace uni_prakt = 2 if inlist(lm0640,2,3)  | (inlist(lm0640,.) & lm0071i01==1)
label var uni_prakt "Hochschule mit praktischer Ausrichtung: mit/ohne Abschluss"

gen uni_theor = .
replace uni_theor = 1 if inlist(lm0641,1)
replace uni_theor = 2 if inlist(lm0641,2,3)  | (inlist(lm0641,.) & lm0071i02==1)
label var uni_theor "Hochschule mit theoretischer Ausrichtung: mit/ohne Abschluss"

gen promotion = .
replace promotion = 1 if inlist(lm0642,1)
replace promotion = 2 if inlist(lm0642,2,3)  | (inlist(lm0642,.) & lb1376==1)
label var promotion "Promotionsstudium: mit/ohne Abschluss"

gen sonst_ausbld = .
replace sonst_ausbld = 1 if inlist(lm0643,1)
replace sonst_ausbld = 2 if inlist(lm0643,2,3)  | (inlist(lm0643,.) & lb0233==1)
label var sonst_ausbld "Sonstige Ausbildung: mit/ohne Abschluss"

label val in_betrieb_angl in_betrieb_angl_lang berufsbild uni_prakt uni_theor promotion sonst_ausbld 

fre in_betrieb_angl in_betrieb_angl_lang berufsbild uni_prakt uni_theor promotion sonst_ausbld 
	
* now we define the highest attained education, considering that 
* if one got lower degree and visited higher withouth degree, he will be assigned lower but with degree instead of no
* degree at all

lab def prof_edu_YK  ///
	1 " [1] Keine"  ///
	2 "[2] Sonstiges: ohne Abschluss/vorzeitig abgebrochen"  /// 
	3 "[3] Sonstiges: mit Abschluss"  ///
	4 "[4] Betriebliche Ausb: ohne Abschluss/vorzeitig abgebrochen"  ///
	5 "[5] Betriebliche Ausb: mit Abschluss"  ///
	6 "[6] Betriebliche Ausb lang: ohne Abschluss/vorzeitig abgebrochen"  ///
	7 "[7] Betriebliche Ausb lang: mit Abschluss"  ///
	8 "[8] Berufsbildende Schule: ohne Abschluss/vorzeitig abgebrochen"  /// 
	9 "[9] Berufsbildende Schule: mit Abschluss"  ///
	10 "[10] Fach-Hochschule: ohne Abschluss/vorzeitig abgebrochen"  ///
	11 "[11] Fach-Hochschule: mit Abschluss"  ///
	12 "[12] Hochschule: ohne Abschluss/vorzeitig abgebrochen"  ///
	13 "[13] Hochschule: mit Abschluss"  ///
	14 "[14] Promotium: ohne Abschluss/vorzeitig abgebrochen"  ///
	15 "[15] Promotium: mit Abschluss" , replace 

capture drop prof_edu_YK
gen prof_edu_YK = .
label val prof_edu_YK prof_edu_YK

* abgeschlossenen mit Zeugnis
replace prof_edu_YK = 3 if sonst_ausbld == 1
replace prof_edu_YK = 5 if in_betrieb_angl == 1
replace prof_edu_YK = 7 if in_betrieb_angl_lang == 1
replace prof_edu_YK = 9 if berufsbild == 1
replace prof_edu_YK = 11 if uni_prakt == 1
replace prof_edu_YK = 13 if uni_theor == 1
replace prof_edu_YK = 15 if promotion == 1

* abgeschlossen ohne Zeugnis oder Abgebrochene
replace prof_edu_YK = 14 if promotion == 2 & prof_edu_YK >=.
replace prof_edu_YK = 12 if uni_theor == 2 & prof_edu_YK >=.
replace prof_edu_YK = 10 if uni_prakt == 2 & prof_edu_YK >=.
replace prof_edu_YK = 8 if berufsbild == 2 & prof_edu_YK >=.
replace prof_edu_YK = 6 if in_betrieb_angl_lang == 2 & prof_edu_YK >=.
replace prof_edu_YK = 4 if in_betrieb_angl == 2 & prof_edu_YK >=.
replace prof_edu_YK = 2 if sonst_ausbld == 2 & prof_edu_YK >=.

replace prof_edu_YK = 1 if lb0228 == 2

**** aggregieren
recode prof_edu_YK (1 = 1 "Keine Berufsbildung") ///
	(2 4 6 8 10 12 = 2 "Keinen Abschluss") ///
	(3 5 7 9 = 3 "Berufliche Ausbildung") ///
	(11 13 14 = 4 "Hochschule/Universität") ///
	(15 = 5 "Promotion"), gen(prof_edu_YK_aggr)
	
label var prof_edu_YK "Professional education"
label var prof_edu_YK_aggr "Professional education, abschluss"

tab1 prof_edu_YK prof_edu_YK_aggr , m

***************************************************
***************************************************
***************************************************
***************************************************

/*
preserve
ren (years_sch0 years_ausbhoch0 isceda11a isceda11a_aggr) =_ibs
drop lfd
* konkordanzliste
clonevar pid_7709 = pid
merge 1:m pid_7709 using $konkordanzliste/7786_7709_Konkordanzliste.dta
keep if _merge !=2
drop _merge

ren lfd_7786 lfd 
* merge with prepared data
merge m:1 lfd using  "N:\Ablagen\D01700-INTER\Projekte\Pilotstudie_Ukr_4172\08_Veröffentlichungen\Erster_Ergebnisbericht\0_analysis\savedata\pilot_ua_2022.dta", keepusing(years_sch0 school_a_cert further_edu voc tert_short higher_ba higher_ma post_grad edu_ausl beruf_a_cert isceda11a isceda11a_aggr)

keep if _merge ==3

tab isceda11a_ibs isceda11a  if lfd<., col

tab  in_betrieb_angl voc,m
tab  in_betrieb_angl_lang voc,m
tab  berufsbild voc,m

tab  in_betrieb_angl tert_short,m
tab  in_betrieb_angl_lang tert_short,m
tab  berufsbild tert_short,m

tab  uni_prakt tert_short,m
tab  uni_prakt tert_short,m
tab  uni_prakt tert_short,m

tab  in_betrieb_angl higher_ma,m
tab  in_betrieb_angl_lang higher_ma,m
tab  berufsbild higher_ma,m

tab school_a_cert school_degree,m

tab isceda11a_ibs higher_ma, m col
tab years_ausbhoch0_ibs higher_ma, m col

restore
*/
***************************************************
***************************************************
***************************************************
***************************************************


 * ----- ISCED A (Attained, abroad, YK) ----- 

capture drop isceda11a_yk
gen isceda11a_yk=.
label values isceda11a_yk isced_lab
label var isceda11a_yk "ISCED A 2011 vor Zuzug nach D"		

 * "(0) 0 Less than primary education/ No school":
replace isceda11a_yk=0 if no_school == 1 
replace isceda11a_yk=0 if schulbesuch_aus==1 & inlist(years_sch0,0,1,2,3,4,5)
replace isceda11a_yk=0 if schul_abschluss_aus==0 & inlist(years_sch0,0,1,2,3,4,5)
replace isceda11a_yk=0 if no_school == 1 
* Keine schule oder grundschule besucht und Bildungsjahre kleiner als 6 oder 
* kein schulabschluss und Bildungsjahre kleiner als 6

 * "(1) Primary education":
replace isceda11a_yk=1 if schul_abschluss_aus==0 & years_sch0>=6 & years_sch0 < .
replace isceda11a_yk=1 if schulbesuch_aus==1 & years_sch0>=6 & years_sch0 < .
replace isceda11a_yk=1 if inlist(schulbesuch_aus,2,3)
* Kein schulabschluss und Bildungsjahre größer/gleich 6 oder Grundschule 
* besucht und Bildungsjahre größer/gleich 6 oder besuchte Mittel- oder 
* weiterführende Schule

 * "(2) Lower secondary education":
replace isceda11a_yk=2 if schul_abschluss_aus==1 
replace isceda11a_yk=2 if inlist(schulbesuch_aus,3)
* Abschluss Mittelschule oder besuchte weiterführende Schule
replace isceda11a_yk=2 if inlist(in_betrieb_angl,2)
replace isceda11a_yk=2 if inlist(in_betrieb_angl_lang,2)
replace isceda11a_yk=2 if inlist(berufsbild,2)
* Besuchte beruflische Schule ohne Abschluss

 * "(3) Upper secondary education":
replace isceda11a_yk=3 if schul_abschluss_aus==2 
* Abschluss weiterführende Schule
replace isceda11a_yk=3 if inlist(uni_prakt,1,2)
replace isceda11a_yk=3 if inlist(uni_theor,1,2)
replace isceda11a_yk=3 if inlist(in_betrieb_angl_lang,1)
replace isceda11a_yk=3 if inlist(berufsbild,1)
* oder Abschluss/besucht Uni/Promotion
* oder Abschluss berufl. Bildung
tab isceda11a_yk, m

 * "(4) Post-secondary non-tertiary education:
replace isceda11a_yk=4 if schul_abschluss_aus==2 & in_betrieb_angl==1 
replace isceda11a_yk=4 if schul_abschluss_aus==2 & in_betrieb_angl_lang==1 
replace isceda11a_yk=4 if schul_abschluss_aus==2 & berufsbild==1 
* Abschluss berufl. Bildung und Abschluss weiterführende Schule 
replace isceda11a_yk=4 if uni1yr>=0 & uni1yr<2
replace isceda11a_yk=4 if uni2yr>=0 & uni2yr<2
* Besucht Uni < 2 Jahre

 * "(5) Short-cycle tertiary education:
replace isceda11a_yk=5 if uni1yr>=2 & uni1yr<.
replace isceda11a_yk=5 if uni2yr>=2 & uni2yr<.
* Besucht Uni/Promotion >= 2 Jahre

 *"(6,7) Bachelor's/ Master's or equivalent level":		
replace isceda11a_yk=6 if inlist(uni_prakt,1)
replace isceda11a_yk=6 if inlist(uni_theor,1)
replace isceda11a_yk=6 if inlist(promotion,1,2)
* Abschluss Uni oder Besuch Promotion

 *"(8) Doctoral or equivalent level":
replace isceda11a_yk=8 if promotion==1
* Abschluss Promotion

		
tab isceda11a_yk, m
tab isceda11a_yk schul_abschluss_aus
tab isceda11a_yk ausbildung_aus


tab isceda11a, m
tab isceda11a_yk, m


* HILFE UND BERATUNGEN
ren lr3595i01 sup_need_asyl
ren lr3595i02 sup_need_learng
ren lr3595i03 sup_need_jobsuch
ren lr3595i04 sup_need_kindbetr
ren lr3595i05 sup_need_bild
ren lr3595i06 sup_need_annerk
ren lr3595i07 sup_need_wohn
ren lr3595i08 sup_need_mediz
ren lr3595i09 sup_need_finanz
ren lr3595i10 sup_need_oth
tab1 sup*,m

egen sup_need_n = rowtotal(sup_need_asyl sup_need_learng sup_need_jobsuch sup_need_kindbetr sup_need_bild sup_need_annerk sup_need_wohn sup_need_mediz sup_need_finanz sup_need_oth)
tab sup_need_n lr3595i11,m
replace sup_need_n = 0 if lr3595i11 == 1
recode sup_need_n 0=. if lr3595i11 == .b
foreach var of varlist sup_need_asyl sup_need_learng sup_need_jobsuch sup_need_kindbetr sup_need_bild sup_need_annerk sup_need_wohn sup_need_mediz sup_need_finanz sup_need_oth {
	replace `var' = 0 if sup_need_n == 0
	recode `var' 0=. if sup_need_n >=.
}

lab var sup_need_n "Anzahl der benötigten Hilfebereiche"

#delimit;
lab def berat1
1 "Ja, habe ich auch schon in Anspruch genommen"
2 "Ja, habe ich aber noch nicht in Anspruch genommen"
3 "Nein, kenne ich nicht", replace;
#delimit cr

gen know_algba=plj0707 if plj0707 > 0 & plj0707 < . 
label var know_algba "Kennen Sie allgemeine Arbeitsmarktberatung bei der Agentur für Arbeit, dem Job center?"
label val know_algba berat1

gen algba2_dum = know_algba == 1 if know_algba > 0 & know_algba < . 
label var algba2_dum "Arbeitsmarktberatung in anspruch genommen"

tab know_algba algba2_dum, col

 * ----- Abschlussanerkennung ------
 * asked only if beendet with or without abschluess
* question about anerkennung is posed:
gen help_an_moeg = .
replace help_an_moeg = 1 if inlist(lm0637,1,2)
replace help_an_moeg = 1 if inlist(lm0638,1,2)
replace help_an_moeg = 1 if inlist(lm0639,1,2)
replace help_an_moeg = 1 if inlist(lm0640,1,2)
replace help_an_moeg = 1 if inlist(lm0641,1,2)
replace help_an_moeg = 1 if inlist(lm0642,1,2)
replace help_an_moeg = 1 if inlist(lm0643,1,2)

* beantragt:
egen help_an_ja = anymatch(lm0701l01 lm0701l02 lm0701l03 lm0701l04 lm0701l05 lm0701l06 lm0701l07), values(1)

gen abschl_anerkenn = .
replace abschl_anerkenn = 1 if help_an_ja == 1 & help_an_moeg == 1
replace abschl_anerkenn = 0 if help_an_ja == 0 & help_an_moeg == 1
drop help_an*

label define abschl_anerkenn_lab 0 "[0] Nein" 1 "[1] Ja"
label var abschl_anerkenn "Anerkennung eines Abschlusses beantragt"
label values abschl_anerkenn abschl_anerkenn_lab 

gen abschl_anerkenn_det = .
#delimit 
	label define abschl_anerkenn_det 
		1 "[1] Nein (ohne Ausbildung ohne Abschluss)" 
		2 "[2] Nein (mit Ausbildung ohne Abschluss)" 
		3 "[3] Nein (mit Ausbildung mit Abschluss)" 
		4 "[4] Ja (mit Ausbildung mit/ohne Abschluss)" 
		, replace;
#delimit cr
replace abschl_anerkenn_det = 1 if inlist(lb0228,2)
replace abschl_anerkenn_det = 1 if inlist(lm0637,3)
replace abschl_anerkenn_det = 1 if inlist(lm0638,3)
replace abschl_anerkenn_det = 1 if inlist(lm0639,3)
replace abschl_anerkenn_det = 1 if inlist(lm0640,3)
replace abschl_anerkenn_det = 1 if inlist(lm0641,3)
replace abschl_anerkenn_det = 1 if inlist(lm0642,3)
replace abschl_anerkenn_det = 1 if inlist(lm0643,3)
replace abschl_anerkenn_det = 2 if inlist(lm0637,2) & lm0701l01 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0638,2) & lm0701l02 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0639,2) & lm0701l03 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0640,2) & lm0701l04 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0641,2) & lm0701l05 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0642,2) & lm0701l06 == 2
replace abschl_anerkenn_det = 2 if inlist(lm0643,2) & lm0701l07 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0637,1) & lm0701l01 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0638,1) & lm0701l02 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0639,1) & lm0701l03 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0640,1) & lm0701l04 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0641,1) & lm0701l05 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0642,1) & lm0701l06 == 2
replace abschl_anerkenn_det = 3 if inlist(lm0643,1) & lm0701l07 == 2
replace abschl_anerkenn_det = 4 if inlist(lm0637,1,2) & lm0701l01 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0638,1,2) & lm0701l02 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0639,1,2) & lm0701l03 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0640,1,2) & lm0701l04 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0641,1,2) & lm0701l05 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0642,1,2) & lm0701l06 == 1
replace abschl_anerkenn_det = 4 if inlist(lm0643,1,2) & lm0701l07 == 1
label var abschl_anerkenn_det "Anerkennung eines Abschlusses beantragt"
label values abschl_anerkenn_det abschl_anerkenn_det 

tab abschl_anerkenn_det, m
tab abschl_anerkenn_det abschl_anerkenn, m


gen abschl_an_berufl_type = . 
replace abschl_an_berufl_type = 0 if inlist(lm0701l07,2)
replace abschl_an_berufl_type = 0 if inlist(lm0701l01,2)
replace abschl_an_berufl_type = 0 if inlist(lm0701l02,2)
replace abschl_an_berufl_type = 0 if inlist(lm0701l03,2)
replace abschl_an_berufl_type = 1 if inlist(lm0701l07,1)
replace abschl_an_berufl_type = 1 if inlist(lm0701l01,1)
replace abschl_an_berufl_type = 1 if inlist(lm0701l02,1)
replace abschl_an_berufl_type = 1 if inlist(lm0701l03,1)
label var abschl_an_berufl_type "Anerkennung beantragt: Beruflicher Abschluss"

gen abschl_an_hochsch_type = . 
replace abschl_an_hochsch_type = 0 if inlist(lm0701l04,2)
replace abschl_an_hochsch_type = 0 if inlist(lm0701l05,2)
replace abschl_an_hochsch_type = 0 if inlist(lm0701l06,2)
replace abschl_an_hochsch_type = 1 if inlist(lm0701l04,1)
replace abschl_an_hochsch_type = 1 if inlist(lm0701l05,1)
replace abschl_an_hochsch_type = 1 if inlist(lm0701l06,1)
label var abschl_an_hochsch_type "Anerkennung beantragt: Hoschulabschluss"

gen abschl_an_hochsch_type2 = . 
replace abschl_an_hochsch_type2 = 0 if inlist(lm0701l04,2)
replace abschl_an_hochsch_type2 = 0 if inlist(lm0701l05,2)
replace abschl_an_hochsch_type2 = 0 if inlist(lm0701l06,2)
replace abschl_an_hochsch_type2 = 1 if inlist(lm0701l04,1)
replace abschl_an_hochsch_type2 = 2 if inlist(lm0701l05,1)
replace abschl_an_hochsch_type2 = 3 if inlist(lm0701l06,1)
#delimit
	label define abschl_an_hochsch_type2
		0 "[0] Kein Anerkennungsantrag des Hochschulabschluss"
		1 "[1] Hochschulabschluss m. prakt. Ausr."
		2 "[2] Hochschulabschluss m. theor. Ausr."
		3 "[3] Promotionsabschluss"
		, replace;
#delimit cr
lab val abschl_an_hochsch_type2 abschl_an_hochsch_type2
label var abschl_an_hochsch_type2 "Anerkennung beantragt: Hoschulabschluss (Art)"

fre abschl_an_berufl_type abschl_an_hochsch_type abschl_an_hochsch_type2

 * -- Abschlussanerkennung vorgeschrieben --
gen an_vorgesch = .
replace an_vorgesch = lm0703l07 if lm0703l07<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l01 if lm0703l01<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l02 if lm0703l02<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l03 if lm0703l03<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l04 if lm0703l04<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l05 if lm0703l05<.  & an_vorgesch >=.
replace an_vorgesch = lm0703l06 if lm0703l06<.  & an_vorgesch >=.
label var an_vorgesch "Anerkennung vorgeschrieben (reglment.)"

#delimit
	label define an_vorgesch
		1   "Ja"
        2   "Nein"
        3   "Weß nicht"
		, replace;
#delimit cr
label values an_vorgesch an_vorgesch

tab an_vorgesch


 * -- Abschlussanerkennung Berufliche Tätigkeiten --

gen abschl_an_kldb = .
replace abschl_an_kldb = l_kldb2010_l7anerx if l_kldb2010_l7anerx <.
replace abschl_an_kldb = l_kldb2010_l1anerx if l_kldb2010_l1anerx <.
replace abschl_an_kldb = l_kldb2010_l2anerx if l_kldb2010_l2anerx <.
replace abschl_an_kldb = l_kldb2010_l3anerx if l_kldb2010_l3anerx <.
replace abschl_an_kldb = l_kldb2010_l4anerx if l_kldb2010_l4anerx <.
replace abschl_an_kldb = l_kldb2010_l5anerx if l_kldb2010_l5anerx <.
replace abschl_an_kldb = l_kldb2010_l6anerx if l_kldb2010_l6anerx <.
lab val abschl_an_kldb l_kldb2010_l1anerx
label var abschl_an_kldb "Anerkennung beantragt: KLDB des beantragten Berufs (höchste Qual.)"
tab abschl_an_kldb, sort

#delimit
	recode abschl_an_kldb
		(10000/19999 = 1 "Land-, Forst- und Tierwirtschaft und Gartenbau")
		(20000/29999 = 2 "Rohstoffgewinnung, Produktion und Fertigung")
		(30000/39999 = 3 "Bau, Architektur, Vermessung und Gebäudetechnik")
		(40000/49999 = 4 "Naturwissenschaft, Geografie und Informatik")
		(50000/59999 = 5 "Verkehr, Logistik, Schutz und Sicherheit")
		(60000/69999 = 6 "Kaufmännische Dienstleistungen, Warenhandel, Vertrieb, Hotel und Tourismus")
		(70000/79999 = 7 "Unternehmensorganisation, Buchhaltung, Recht und Verwaltung")
		(80000/89999 = 8 "Gesundheit, Soziales, Lehre und Erziehung")
		(90000/99999 = 9 "Sprach-, Literatur-, Geistes-, Gesellschafts- und Wirtschaftswissenschaften")
		(0000/9999 = 10 "Militär")
		,
		gen(abschl_an_berufgr)
		;
#delimit cr
label var abschl_an_berufgr "Anerkennung beantragt: Berufsgruppen (höchste Qual.)"


  * -- Abschlussanerkennungsverfahren: Anzahl --
  * Anzahl der Abschlueße
  recode lm0637 lm0638 lm0639 lm0640 lm0641 lm0642 lm0643 (2 3 = 1)
 
egen abschl_numb =  anycount(lm0637 lm0638 lm0639 lm0640 lm0641 lm0642 lm0643), values(1)
label var abschl_numb "Anzahl Berufsabschlüsse"

egen abschl_an_numb =  anycount(lm0701l0?), values(1)
label var abschl_an_numb "Anzahl Anerkennungsverfahren beantragt"

tab abschl_numb abschl_an_numb

 * Anerkennung abgelehnt oder im Prozess
 
gen abschl_an_result = .
label var abschl_an_result "Anerkennung beantragt: Ergebnis (mind. eine qual.)"
#delimit
	label define abschl_an_result_lab
		1 "[1] Der Abschluss wurde als gleichwertig anerkannt"
		2 "[2] Der Abschluss wurde als teilweise gleichwertig anerkannt"
		3 "[3] Der Abschluss wurde nicht anerkannt"
		4 "[4] Das Verfahren läuft noch"
		5 "[5] Ich habe den Antrag zurückgezogen"
		, replace;
#delimit cr
label values abschl_an_result abschl_an_result_lab

* start with any recognition
forvalues i=1/7 {
	capture replace abschl_an_result = 1 if lm0707l0`i'_v2 == 1
	capture replace abschl_an_result = 1 if lm0707l0`i' == 1
	}
forvalues i=1/7 {
	capture recode abschl_an_result .= 2 if lm0707l0`i'_v2 == 2
	capture recode abschl_an_result .= 2 if lm0707l0`i' == 2
	}
forvalues i=1/7 {
	capture recode abschl_an_result .= 3 if lm0707l0`i'_v2 == 3
	capture recode abschl_an_result .= 3 if lm0707l0`i' == 3
	}
forvalues i=1/7 {
	capture recode abschl_an_result .= 4 if lm0707l0`i'_v2 == 4
	capture recode abschl_an_result .= 4 if lm0707l0`i' == 4
	}
forvalues i=1/7 {
	recode abschl_an_result .= 4 if lm0704l0`i' == 2
	}
forvalues i=1/7 {
	capture recode abschl_an_result .= 5 if lm0704l0`i' == 1
	}

tab abschl_anerkenn_det abschl_an_result, m
tab  abschl_an_result if abschl_anerkenn_det ==4, m

 
 * Gründe nicht Anzuerkennen
gen kein_abschl_an = .
replace kein_abschl_an = lm0717l06 if lm0701l06 == 2
replace kein_abschl_an = lm0717l05_v3 if lm0701l05 == 2 & kein_abschl_an >=.
replace kein_abschl_an = lm0717l04_v3 if lm0701l04 == 2 & kein_abschl_an >=.
replace kein_abschl_an = lm0717l03_v3 if lm0701l03 == 2 & kein_abschl_an >=.
replace kein_abschl_an = lm0717l02_v3 if lm0701l02 == 2 & kein_abschl_an >=.
replace kein_abschl_an = lm0717l01 if lm0701l01 == 2 & kein_abschl_an >=.
replace kein_abschl_an = lm0717l07_v3 if lm0701l07 == 2 & kein_abschl_an >=.
label var kein_abschl_an "Keine Anerkennung beantragt: Gründe (höchste Qual.)"
replace kein_abschl_an=kein_abschl_an-1
#delimit
	label define kein_abschl_an_lab
		1   "[1] Ich weiß nicht, wo und wie der Antrag gestellt werden soll"
        2   "[2] Ich weiß nicht, wie ich die Anerkennung finanzieren soll"
        3   "[3] Mir fehlen wichtige Dokumente für die Anerkennung"
        4   "[4] Das Anerkennungsverfahren ist zu bürokratisch / nimmt zu viel Zeit in Anspruch"
        5   "[5] Ich habe keine Aussicht auf Anerkennung meines Abschlusses"
        6   "[6] Andere Gründe"
        7   "[7] Unwichtig, weil ich meinen erlernten Beruf aus rechtlicher Sicht auch so ausüben kann"
        8   "[8] Unwichtig, weil ich mir durch die Anerkennung keinen weiteren Nutzen auf dem Arbeitsmarkt verspreche"
		, replace;
#delimit cr
label values kein_abschl_an kein_abschl_an_lab

tab kein_abschl_an

gen an_dauer_s1 = ym(lm0702i02l01,lm0702i01l01)
gen an_dauer_e1 = ym(lm0705i02l01, lm0705i01l01)
gen an_dauer1 = an_dauer_e1-an_dauer_s1

gen an_dauer_s2 = ym(lm0726i01l02,lm0702i01l02) 
gen an_dauer_e2 = ym(lm0705i02l02, lm0705i01l02)
gen an_dauer2 = an_dauer_e2-an_dauer_s2

gen an_dauer_s3 = ym(lm0702i02l03, lm0702i01l03) 
gen an_dauer_e3 = ym(lm0705i02l03, lm0705i01l03)
gen an_dauer3 = an_dauer_e3-an_dauer_s3

gen an_dauer_s4 = ym(lm0702i02l04, lm0702i01l04) 
gen an_dauer_e4 = ym(lm0705i02l04, lm0705i01l04)
gen an_dauer4 = an_dauer_e4-an_dauer_s4

gen an_dauer_s5 = ym(lm0702i02l05, lm0702i01l05) 
gen an_dauer_e5 = ym(lm0705i02l05, lm0705i01l05)
gen an_dauer5 = an_dauer_e5-an_dauer_s5

gen an_dauer_s6 = ym(lm0702i02l06, lm0702i01l06) 
gen an_dauer_e6 = ym(lm0705i02l06, lm0705i01l06)
gen an_dauer6 = an_dauer_e6-an_dauer_s6

gen an_dauer_s7 = ym(lm0702i02l07, lm0702i01l07) 
gen an_dauer_e7 = ym(lm0705i02l07, lm0705i01l07)
gen an_dauer7 = an_dauer_e7-an_dauer_s7

* start with any recognition
fre an_dauer?
recode an_dauer? (-2/-1=0)

gen an_dauer = an_dauer7
replace an_dauer = an_dauer1 if an_dauer1<.
replace an_dauer = an_dauer2 if an_dauer2<.
replace an_dauer = an_dauer3 if an_dauer3<.
replace an_dauer = an_dauer4 if an_dauer4<.
replace an_dauer = an_dauer5 if an_dauer5<.
replace an_dauer = an_dauer6 if an_dauer6<.

gen an_dauer_s = an_dauer_s7
replace an_dauer_s = an_dauer_s1 if an_dauer_s1<.
replace an_dauer_s = an_dauer_s2 if an_dauer_s2<.
replace an_dauer_s = an_dauer_s3 if an_dauer_s3<.
replace an_dauer_s = an_dauer_s4 if an_dauer_s4<.
replace an_dauer_s = an_dauer_s5 if an_dauer_s5<.
replace an_dauer_s = an_dauer_s6 if an_dauer_s6<.
format an_dauer_s %tm

clonevar future_prof_edu = lb0238_v2 if lb0238_v2<.
clonevar future_school_edu = lb0195_v2 if lb0195_v2<.
gen future_any_edu = 0 if inlist(future_prof_edu,3) & inlist(future_school_edu,3)
replace future_any_edu = 1 if inlist(future_prof_edu,1,2) 
replace future_any_edu = 1 if inlist(future_school_edu,1,2) 
tab future_any_edu
label var future_any_edu "In der Zukunft Schul oder Berufsabschluss angestrebt"

clonevar edu_de_curr = plg0012_v2 if plg0012_v2 <.
recode edu_de_curr 2=0
clonevar edu_de_type_curr = plg0267_v2 if plg0267_v2<.

gen edu_de_ever = lb0197 == 1 if lb0197<.
replace edu_de_ever = 1 if lb0186_v3 == 1
replace edu_de_ever = 1 if plg0012_v2 == 1
lab var edu_de_ever "Bildungserwerb in DE"

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

 * ---------- Wage (Month) ----------

* Brutto
gen work_blohn = plc0013_v2  if plc0013_v2 >= 0 & plc0013_v2 < .
label var work_blohn "Bruttomonatslohn (letzter Monat)"
tab work_blohn, m

* Log Bruttoarbeitsverdienst

gen ln_work_blohn = ln(work_blohn) 
label var ln_work_blohn "Log Bruttomonatslohn (letzter Monat)"

* Netto
gen work_nlohn = plc0014_v2  if plc0014_v2 >= 0 & plc0014_v2 < .
label var work_nlohn "Nettomonatslohn (letzter Monat)"

tab work_nlohn, m

* Weniger als 520 Euro:
gen work_blohn_less520 = work_blohn < 520 if !missing(work_blohn) 
label var work_blohn_less520 "Bruttomonatslohn < 520 EUR" 
tab work_blohn work_blohn_less520 if work_blohn < 600, m 

 * ----- Working hours -----

gen work_hours_contract = plb0176_v5 if plb0176_v5 > 0 
label var work_hours_contract "Vertragliche Wochenarbeitszeit"
tab work_hours_contract work, m

gen work_hours_actual = plb0186_v3 if plb0186_v3 > 0
label var work_hours_actual "Tatsächliche Wochenarbeitszeit mit Überstunden"
tab work_hours_actual work, m

 * ----- Wage (Hour) -----

* Brutto
gen work_blohn_hour = work_blohn/(work_hours_contract*4.3) if 				 ///
					  (!missing(work_blohn) & !missing(work_hours_contract)) 
label var work_blohn_hour "Bruttoarbeitsverdienst pro Stunde (letzter Monat)"
tab work_blohn_hour, m

* Netto
gen work_nlohn_hour = work_nlohn/(work_hours_contract*4.3) if 				 ///
					  (!missing(work_nlohn) & !missing(work_hours_contract)) 
label var work_nlohn_hour "Nettoarbeitsverdienst pro Stunde (letzter Monat)"
tab work_nlohn_hour, m

 * ----- Employed in paid work -----

gen paid_work = work
replace paid_work = 0 if work_blohn == 0
label var paid_work "Employed in paid work"
label define paid_work_lab 0 "[0] Nein" 1 "[1] Ja"
label values paid_work paid_work_lab
tab work paid_work

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


 * ----- Job search / Not working -----
clonevar jobsearch = plb0424_v2 if plb0424_v2<.
recode jobsearch (2=0)
gen helpvar = .  
replace helpvar = 0 if plj0562 == 1
replace helpvar = -1 if plj0562 == .a
replace helpvar = 1 if plj0557 == 1
replace helpvar = 1 if plj0558 == 1
replace helpvar = 1 if plj0559 == 1
replace helpvar = 1 if plj0560 == 1
replace helpvar = 1 if plj0711 == 1
replace helpvar = 1 if plj0710 == 1

gen ne_jsearch_service = 1 if plj0557 == 1
replace ne_jsearch_service = 1 if plj0558 == 1
recode ne_jsearch_service . = 0 if helpvar <. & helpvar != -1
lab var ne_jsearch_service "Arbeits suche via Agentur für Arbeit, Job-Center, private Stellenvermittlung"
tab  work ne_jsearch_service,m
tab  plb0417_v2 ne_jsearch_service if work==0,m

gen ne_jsearch_ad = 1 if plj0559 == 1
replace ne_jsearch_ad = 1 if plj0558 == 1
recode ne_jsearch_ad . = 0 if helpvar <. & helpvar != -1
lab var ne_jsearch_ad "Arbeits suche via Stellenanzeige in der Zeitung, internet, social media"

gen ne_jsearch_fam_fr = 1 if plj0710== 1 | plj0711== 1
replace ne_jsearch_fam_fr = 1 if plj0711 == 1
replace ne_jsearch_fam_fr = 1 if plj0710 == 1
recode ne_jsearch_fam_fr . = 0 if helpvar <. & helpvar != -1
lab var ne_jsearch_fam_fr "Arbeits suche via Familienangehörige, Freunde, Bekannte"

egen ne_jsearch_n = rowtotal(plj0557 plj0558 plj0559 plj0560 plj0711 plj0710)
tab  work ne_jsearch_service,m
recode ne_jsearch_n 0= . if inlist(work,1,.) 
tab ne_jsearch_n plb0417_v2,m
recode ne_jsearch_n 0= . if inlist(plb0417_v2,1,.,.a) 
recode ne_jsearch_n 0= . if inlist(helpvar,-1) 
tab ne_jsearch_n plj0562,m
lab var ne_jsearch_n "Arbeits suche, Anzahl der Möglichkeiten"
drop helpvar

 * ----- Employed / Not/looking for work -----
		* detailed
  
gen lfs_status_dtl = .
recode lfs_status_dtl . = 1 if lfs_status == 1
recode lfs_status_dtl . = 2 if lfs_status == 2
recode lfs_status_dtl . = 3 if plg0012_v2 == 1 | inlist(plb0022_v11,3,7,11)
* In Ausbildung (plg0012_v2 & plb0022_v11 = 3), Sozialem Jahr (plb0022_v11 = 7) 
* oder Praktikum (plb0022_v11 = 11)
recode lfs_status_dtl . = 4 if plm736I01 == 1 | plm736I02 == 1 | 			 ///
							   plm736I03 == 1 | plm728i01I01 == 1 | 		 ///
							   plm728I02I02 == 1 | plm728I03I03 == 1 | 		 ///
							   (plj0654 == 1 & plj0659_v1 != 1)
/* Sprachkursteilnahme: 
Integrationskurs (plj0654 & plj0659_v1), anderer Sprachkurs (plm736l01, 
plm736l02, plm736l03), oder Berufsbezogener Sprachkurs (plm728i01l01, 
plm728i01l02, plm728i01l03)

ESF-BAMF (plj0499) und anderer Sprachkurs (plj0540) hier nicht enthalten, weil 
Fragen nur an Wiederbefragte gingen. Für Neubefragte ist diese Teilnahme über
plj0654 & plj0659_v1 sowie plm736l01, plm736l02, plm736l03 abgedeckt. */
recode lfs_status_dtl . = 5 if inlist(plb0019_v2,1,2) | plc0152_v1 == 1 | 	 ///
							  (plc0153_v2 > 0 & plc0153_v2 < .)
* In Elternzeit/Mutterschutz (plb0019_v2) oder Elterngeld (plc0152_v1, plc0153_v2)
recode lfs_status_dtl . = 6 if lfs_status == 3 
* Info from lfs_status if person is currently looking for work 

#delimit
label define lfs_status_dtl 
	1 "[1] Erwerbstätig (gegen Entgelt)" 
	2 "[2] Aktiv arbeitssuchend (letzte 4 Wochen)" 
	3 "[3] Nicht-aktiv arbeitssuchend: Bildungserwerb" 
	4 "[4] Nicht-aktiv arbeitssuchend: Spracherwerb" 
	5 "[5] Nicht-aktiv arbeitssuchend: Elternzeit" 
	6 "[6] Nicht-aktiv arbeitssuchend: Sonstiges", replace;
#delimit cr
label var lfs_status_dtl "Arbeitsmarktstatus, 6 cat."
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


*******************************************************************************
*** Starting the first job in Germany ***
*******************************************************************************

* ----- Stellensuche erster Job -----
tab plb0022_v11 lb1421,m
clonevar job1st = lb1421
recode job1st 2=0
gen job1st_yr = lm0607i01 if lm0607i01<.
gen job1st_m = lr3053 if lr3053<.

*first job based on info about current job
replace job1st = 1 if work == 1
replace job1st_yr = plb0036_v2 if plb0036_v2<. & job1st_yr >=.
replace job1st_m = plb0035 if plb0035<. & job1st_m >=.

gen job1st_date = ym(job1st_yr,job1st_m)
format job1st_date %tm
tab job1st_date job1st,m

* some jobs before arrival?
gen job1st_date_corrected = job1st_date if job1st_date>= arrival_date & job1st_date<. & arrival_date <.
format job1st_date_corrected %tm
tab job1st_date_corrected job1st_date,m
gen job1st_date_corrected_cens = job1st_date_corrected
replace job1st_date_corrected_cens = intv_year_month if job1st == 0

lab var job1st_yr "Jahr der ersten Erwerbstätigkeit in DE"
lab var job1st_m   "Monat der ersten Erwerbstätigkeit in DE"
lab var job1st_date  "Jahr/monat der ersten Erwerbstätigkeit in DE"
lab var job1st_date_corrected "Jahr/monat der ersten Erwerbstätigkeit in DE (nach zuzug)"
lab var job1st_date_corrected_cens "Jahr/monat der ersten Erwerbstätigkeit in DE (nach zuzug) censored at interview"

*******************************************************************************
*** Months from arrival until the 1st Job***
*******************************************************************************
gen mon_1job = job1st_date_corrected - arrival_date
label var mon_1job "Months until 1st job"
 * ----------------------------------------

clonevar search_first_job=lr2100 if lr2100<.
clonevar search_first_job2=lr2101 if lr2101<.

#delimit
label def jsearch_method
		1 "Agentur für Arbeit, Job-Center, private Stellenvermittlung" 
		2 "Stellenanzeige in der Zeitung, internet, social media" 
		3 "Familienangehörige" 
		4 "Freunde, Bekannte aus DE" 
		5 "Freunde, Bekannte aus HKL" 
		6 "Freunde, Bekannte aus Oth/miss" 
		7 "Nichts davon" 
	, replace;
#delimit cr
	
gen jb1_jsearch = .
lab var jb1_jsearch "1st job search method"
lab val jb1_jsearch jsearch_method
replace jb1_jsearch = 1 if inlist(search_first_job,1,2)
replace jb1_jsearch = 2 if inlist(search_first_job,3,4)
replace jb1_jsearch = 3 if inlist(search_first_job,5)
replace jb1_jsearch = 4 if inlist(search_first_job,6) & inlist(search_first_job2,1)
replace jb1_jsearch = 5 if inlist(search_first_job,6) & inlist(search_first_job2,2)
replace jb1_jsearch = 6 if inlist(search_first_job,6) & inlist(search_first_job2,3)
replace jb1_jsearch = 6 if inlist(search_first_job,6) & inlist(search_first_job2,.)
replace jb1_jsearch = 7 if inlist(search_first_job,7) 
tab jb1_jsearch job1st,m
tab jb1_jsearch if job1st==1,m




  * --------------------------------------
   * SES, LABOR MARKET BEFORE ARRIVAL 
  * --------------------------------------

 * ----- OWN RELATIVE POSITION BEFORE ARRIVAL -----

  * ----- Economic status before migration -----

gen ec_status0 = lr3046 if lr3046 > 0 & lr3046<.

#delimit
label define ec_status0_lab 
	1 "[1] Weit überdurchschnittlich" 
	2 "[2] Eher überdurchschnittlich" 
	3 "[3] Durchschnittlich" 
	4 "[4] Eher unterdurchschnittlich" 
	5 "[5] Weit unterdurchschnittlich" 
	, modify;
#delimit cr
label var ec_status0 "Wirtschaftliche Situation vor Zuzug"
label values ec_status0 ec_status0_lab

 * ----- Income status before migration -----

gen inc_status0 = lr3041 if lr3041 > 0 & lr3041 < .
recode inc_status0 . = 0 if lr3032 == 1

#delimit
label define inc_status0_lab 
	1 "[1] Weit überdurchschnittlich" 
	2 "[2] Eher überdurchschnittlich" 
	3 "[3] Durchschnittlich" 
	4 "[4] Eher unterdurchschnittlich" 
	5 "[5] Weit unterdurchschnittlich" 
	0 "[0] Noch nie Berufstätig"
, modify;
#delimit cr
label var inc_status0 "Höhe Ihres Nettoeinkommens vor Zuzug"
label values inc_status0 inc_status0_lab

tab inc_status0, m 
tab ec_status0,m

 * ----- EMPLOYMENT BEFORE ARRIVAL -----

gen empl0 = lm0632 if lm0632 > 0 & lm0632 < .
recode empl0 . = 0 if lr3032 == 1

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
label var empl0_aggr "Erwerbstätigkeit vor Zuzug nach Deutschland (aggr.)"

tab empl0_aggr

 * ----- Employed before migration (dummy) -----

gen work0 = empl0 > 0 if empl0 < .

label var work0 "Erwerbstätigkeit vor Zuzug nach Deutschland (Dummy)"
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
*reconstructed from biography
tab work0, m

* generate from spell data
recode gebjahr (-1 =.)
sum arrival_yr gebjahr

preserve
keep pid lkal4 lkal5 lb1359* lb1362* age_arriv work0
drop *_CON
fre lkal4 lkal5
drop if lkal4==.a
recode lkal4 lkal5 lb1359* lb1362* (.b = 0)
 
ren lb1359_* ft*
ren lb1362_* pt*

reshape long ft pt, i(pid) j(age)
drop lkal4 lkal5 work0
format * %5.0f

* identify last year of employment before arrival to Germany
egen work0_any = anymatch(pt ft), v(1)
gen tempvar = 1 if work0_any & age < age_arriv
bys pid (age): egen wexp0 = total(tempvar)
lab var wexp0 "work exp bef. leaving origin"
drop tempvar work0_any

egen work0_any = anymatch(ft), v(1)
gen tempvar = 1 if work0_any & age < age_arriv
bys pid (age): egen wexp0ft = total(tempvar)
lab var wexp0ft "full time work exp bef. leaving origin"
drop tempvar work0_any

egen work0_any = anymatch(pt), v(1)
gen tempvar = 1 if work0_any & age < age_arriv
bys pid (age): egen wexp0pt = total(tempvar)
lab var wexp0pt "part time work exp bef. leaving origin"

keep pid wexp0 wexp0ft wexp0pt
duplicates drop
isid pid
save $out_data/exp.dta, replace
restore

merge 1:1 pid using $out_data/exp.dta
* non-merge are those with missing on arrival year or on kalendar
drop _merge
erase $out_data/exp.dta

tab wexp0 work0, m
* in most cases fits; note that variable work0 captures working experience in the origing country, hence, could underestimate full work experience of the respondent (e.g.,in transit country)
recode wexp0 . = 0 if work0 == 0

clonevar work0_tot = work0
replace work0_tot = 1 if wexp0 > 0 & wexp0 < .
tab wexp0 work0_tot, m
replace wexp0 = . if work0 != 1

  * ----- LEVEL OF QUALIFICATION/JOB
  
  * ----- (TÄTIGKEITSNIVEAU) -----

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
lab var niveau0 "Anforderungsniveau (KLDB) vor Zuzug"

* Task (AUTOR)
  * -----------------------------------
gen kldb2010_3 = int(kldb0/100)
gen jahr = 2013

merge m:1 kldb2010_3 jahr using $do/tasks_kldb2010_3.dta, ///
	keepusing(haupttask)
keep if _merge != 2
tab kldb0 if _merge == 1,m
drop _merge
replace haupttask = . if kldb0 >=.
rename kldb2010_3 kldb0_2010_3 
drop jahr

ren haupttask haupttask0

/*
Herkunft: BIBB-FDZ
Stataversion: 14.2 MP
Quelle: Bundesagentur für Arbeit, 2013: Klassifikation der Berufe 2010 - Systematisches Verzeichnis
https://statistik.arbeitsagentur.de/Statischer-Content/Grundlagen/Klassifikation-der-Berufe/KldB2010/Systematik-Verzeichnisse/Generische-Publikationen/Systematisches-Verzeichnis-Berufsbenennung.xls 
*/

********************************************************************************
#delimit ;
label define kldb2010_3
111 "Landwirtschaft"
112 "Tierwirtschaft"
113 "Pferdewirtschaft"
114 "Fischwirtschaft"
115 "Tierpflege"
116 "Weinbau"
117 "Forst- und Jagdwirtschaft, Landschaftspflege"
121 "Gartenbau"
122 "Floristik"
211 "Berg-, Tagebau und Sprengtechnik"
212 "Naturstein- und Mineralaufbereitung und -verarbeitung und Baustoffherstellung"
213 "Industrielle Glasherstellung und -verarbeitung"
214 "Industrielle Keramikherstellung und -verarbeitung"
221 "Kunststoff- und Kautschukherstellung und -verarbeitung"
222 "Farb- und Lacktechnik"
223 "Holzbe- und -verarbeitung"
231 "Papier- und Verpackungstechnik"
232 "Technische Mediengestaltung"
233 "Fototechnik und Fotografie"
234 "Drucktechnik und -weiterverarbeitung, Buchbinderei"
241 "Metallerzeugung"
242 "Metallbearbeitung"
243 "Metalloberflächenbehandlung"
244 "Metallbau und Schweißtechnik"
245 "Feinwerk- und Werkzeugtechnik"
251 "Maschinenbau- und Betriebstechnik"
252 "Fahrzeug-, Luft-, Raumfahrt- und Schiffbautechnik"
261 "Mechatronik und Automatisierungstechnik"
262 "Energietechnik"
263 "Elektrotechnik"
271 "Technische Forschung und Entwicklung"
272 "Technisches Zeichnen, Konstruktion und Modellbau"
273 "Technische Produktionsplanung und -steuerung"
281 "Textiltechnik und -produktion"
282 "Textilverarbeitung"
283 "Leder-, Pelzherstellung und -verarbeitung"
291 "Getränkeherstellung"
292 "Lebensmittel- und Genussmittelherstellung"
293 "Speisenzubereitung"
311 "Bauplanung und -überwachung, Architektur"
312 "Vermessung und Kartografie"
321 "Hochbau"
322 "Tiefbau"
331 "Bodenverlegung"
332 "Maler- und Lackierer-, Stuckateurarbeiten, Bauwerksabdichtung, Holz- und Bautenschutz"
333 "Aus- und Trockenbau, Isolierung, Zimmerei, Glaserei, Rollladen- und Jalousiebau"
341 "Gebäudetechnik"
342 "Klempnerei, Sanitär-, Heizungs- und Klimatechnik"
343 "Ver- und Entsorgung"
411 "Mathematik und Statistik"
412 "Biologie"
413 "Chemie"
414 "Physik"
421 "Geologie, Geografie und Meteorologie"
422 "Umweltschutztechnik"
423 "Umweltmanagement und -beratung"
431 "Informatik"
432 "IT-Systemanalyse, IT-Anwendungsberatung und IT-Vertrieb"
433 "IT-Netzwerktechnik, IT-Koordination, IT-Administration und IT-Organisation"
434 "Softwareentwicklung und Programmierung"
511 "Technischer Betrieb des Eisenbahn-, Luft- und Schiffsverkehrs"
512 "Überwachung und Wartung der Verkehrsinfrastruktur"
513 "Lagerwirtschaft, Post und Zustellung, Güterumschlag"
514 "Servicekräfte im Personenverkehr"
515 "Überwachung und Steuerung des Verkehrsbetriebs"
516 "Kaufleute - Verkehr und Logistik"
521 "Fahrzeugführung im Straßenverkehr"
522 "Fahrzeugführung im Eisenbahnverkehr"
523 "Fahrzeugführung im Flugverkehr"
524 "Fahrzeugführung im Schiffsverkehr"
525 "Bau- und Transportgeräteführung"
531 "Objekt-, Personen-, Brandschutz, Arbeitssicherheit"
532 "Polizeivollzugs- und Kriminaldienst, Gerichts- und Justizvollzug"
533 "Gewerbe- und Gesundheitsaufsicht, Desinfektion"
541 "Reinigung"
611 "Einkauf und Vertrieb"
612 "Handel"
613 "Immobilienwirtschaft und Facility-Management"
621 "Verkauf (ohne Produktspezialisierung)"
622 "Verkauf von Bekleidung, Elektronik, Kraftfahrzeugen und Hartwaren"
623 "Verkauf von Lebensmitteln"
624 "Verkauf von drogerie- und apothekenüblichen Waren, Sanitäts- und Medizinbedarf"
625 "Buch-, Kunst-, Antiquitäten- und Musikfachhandel"
631 "Tourismus und Sport"
632 "Hotellerie"
633 "Gastronomie"
634 "Veranstaltungsservice und -management"
711 "Geschäftsführung und Vorstand"
712 "Angehörige gesetzgebender Körperschaften und leitende Bedienstete von Interessenorganisationen"
713 "Unternehmensorganisation und -strategie"
714 "Büro und Sekretariat"
715 "Personalwesen und -dienstleistung"
721 "Versicherungs- und Finanzdienstleistungen"
722 "Rechnungswesen, Controlling und Revision"
723 "Steuerberatung"
731 "Rechtsberatung, -sprechung und -ordnung"
732 "Verwaltung"
733 "Medien-, Dokumentations- und Informationsdienste"
811 "Arzt- und Praxishilfe"
812 "Medizinisches Laboratorium"
813 "Gesundheits- und Krankenpflege, Rettungsdienst und Geburtshilfe"
814 "Human- und Zahnmedizin"
815 "Tiermedizin und Tierheilkunde"
816 "Psychologie und nicht ärztliche Psychotherapie"
817 "Nicht ärztliche Therapie und Heilkunde"
818 "Pharmazie"
821 "Altenpflege"
822 "Ernährungs- und Gesundheitsberatung, Wellness"
823 "Körperpflege"
824 "Bestattungswesen"
825 "Medizin-, Orthopädie- und Rehatechnik"
831 "Erziehung, Sozialarbeit, Heilerziehungspflege"
832 "Hauswirtschaft und Verbraucherberatung"
833 "Theologie und Gemeindearbeit"
841 "Lehrtätigkeit an allgemeinbildenden Schulen"
842 "Lehrtätigkeit für berufsbildende Fächer, betriebliche Ausbildung und Betriebspädagogik"
843 "Lehr- und Forschungstätigkeit an Hochschulen"
844 "Lehrtätigkeit an außerschulischen Bildungseinrichtungen"
845 "Fahr- und Sportunterricht an außerschulischen Bildungseinrichtungen"
911 "Sprach- und Literaturwissenschaften"
912 "Geisteswissenschaften"
913 "Gesellschaftswissenschaften"
914 "Wirtschaftswissenschaften"
921 "Werbung und Marketing"
922 "Öffentlichkeitsarbeit"
923 "Verlags- und Medienwirtschaft"
924 "Redaktion und Journalismus"
931 "Produkt- und Industriedesign"
932 "Innenarchitektur, visuelles Marketing, Raumausstattung"
933 "Kunsthandwerk und bildende Kunst"
934 "Kunsthandwerkliche Keramik- und Glasgestaltung"
935 "Kunsthandwerkliche Metallgestaltung"
936 "Musikinstrumentenbau"
941 "Musik-, Gesangs- und Dirigententätigkeiten"
942 "Schauspiel, Tanz und Bewegungskunst"
943 "Moderation und Unterhaltung"
944 "Theater-, Film- und Fernsehproduktion"
945 "Veranstaltungs-, Kamera- und Tontechnik"
946 "Bühnen- und Kostümbildnerei, Requisite"
947 "Museumstechnik und -management"
011 "Offiziere"
012 "Unteroffiziere mit Portepee"
013 "Unteroffiziere ohne Portepee"
014 "Angehörige der regulären Streitkräfte in sonstigen Rängen"
, replace;
#delimit cr
******************************************************************************************

label value kldb0_2010_3 kldb2010_3 


* Berufsgruppen
#delimit
	recode kldb0
		(10000/19999 = 1 "Land-, Forst- und Tierwirtschaft und Gartenbau")
		(20000/29999 = 2 "Rohstoffgewinnung, Produktion und Fertigung")
		(30000/39999 = 3 "Bau, Architektur, Vermessung und Gebäudetechnik")
		(40000/49999 = 4 "Naturwissenschaft, Geografie und Informatik")
		(50000/59999 = 5 "Verkehr, Logistik, Schutz und Sicherheit")
		(60000/69999 = 6 "Kaufmännische Dienstleistungen, Warenhandel, Vertrieb, Hotel und Tourismus")
		(70000/79999 = 7 "Unternehmensorganisation, Buchhaltung, Recht und Verwaltung")
		(80000/89999 = 8 "Gesundheit, Soziales, Lehre und Erziehung")
		(90000/99999 = 9 "Sprach-, Literatur-, Geistes-, Gesellschafts- und Wirtschaftswissenschaften, Medien, Kunst, Kultur und Gestaltung  ")
		(0000/9999 = 10 "Militär")
		,
		gen(berufgr0)
		;
#delimit cr
tab berufgr0 if work0 == 1, m
label var berufgr0 "BERUFSGRUPPE (KLDB) vor zuzug"




  * ---------------------------------------------
    * VARIABLES: SES, LABOR MARKET AFTER ARRIVAL
  *  --------------------------------------------

 * ----- WORK ASPIRATION -----

gen future_empl = plb0417_v2 if plb0417_v2 > 0 & plb0417_v2 < . 
replace future_empl = 0 if inlist(actual_empl,1,2,3,4,5,10)

#delimit;
	label define future_empl_lab
		0 "[0] Bereits erwerbstätig" 
		1 "[1] Nein, ganz sicher nicht"
		2 "[2] Eher unwahrscheinlich"
		3 "[3] Wahrscheinlich"
		4 "[4] Ganz sicher"
		, replace;
#delimit cr
label var future_empl "Erwerbsabsichten"
label values future_empl future_empl_lab 

tab future_empl, m
tab actual_empl future_empl
tab plb0417_v2 future_empl

recode future_empl (0=.) (1=1) (2=2) (3=3) (4=4), gen(future_empl1)
#delimit
	lab define future_empl_lab
	1 "[1] Nein, ganz sicher nicht" 
	2 "[2] eher unwahrscheinlich" 
	3 "[3] Wahrscheinlich" 
	4 "[4]Ganz sicher"
	, replace;
#delimit cr
label var future_empl1 "Erwerbsaspirationen (nicht Beschäftigte)"
lab values future_empl1 future_empl_lab

tab future_empl future_empl1

rename plb0418 timing_future_empl
rename plb0240 type_future_empl

 * ----- DUMMY WORK ASPIRATION -----

recode future_empl (0 = .) (1 2 = 0) (3 4 = 1), gen(future_empl_dum)
label define future_empl_dum_lab 0 "Nein - unwahrscheinlich" 1 "Ja - Wahrscheinlich/ganz sicher"
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

* ISCO OF WORK
tab p_isco08, nol
	
clonevar isco_08 = p_isco08
recode isco_08 (-100/99 = .)
tab isco_08 if work == 1, m
	
****ISEI SCALE****
iscogen isei = isei(isco_08)
label var isei "Job Current: ISEI scale (international socio-economic index)"

iscogen isco_1dig = major(isco_08)
label var isco_1dig "ISCO curr, 1 digit"
	
iscogen isco_oesch5 = oesch5(isco_08)
tab isco_oesch5
recode isco_oesch5 (4=3) (5=4)

#delimit;
	label define isco_oesch5_lab 
	1 "Berufe mit Hochschulbildung" 
	2 "Berufe mit höhere Fachausbildung" 
	3 "Lehrberufe" 
	4 "An- und Ungelernte"
	, replace;
#delimit cr
label val isco_oesch5 isco_oesch5_lab	
label var isco_oesch5 "ISCO curr, Oesch 2006a"
	
gen isco_skilllev = .

#delimit;
	label define isco_skilllev 
	1 "Hilfsarbeitskräfte" 
	2 "Fachkräfte" 
	3 "Gehobene Fachkräfte/ Akademische Berufe"
	, replace;
#delimit cr
label val isco_skilllev isco_skilllev
label var isco_skilllev "ISCO curr, skill level"

replace isco_skilllev = 1 if inlist(isco_1dig,9)
replace isco_skilllev = 2 if inlist(isco_1dig,4,5,6,7,8)
replace isco_skilllev = 3 if inlist(isco_1dig,1,2,3)

	
**** KLDB ****
tab p_kldb2010
recode p_kldb2010 (-100/99 = .)

gen p_kldb2010_help = p_kldb2010 if p_kldb2010>0
clonevar kldb = p_kldb2010
recode kldb (-100/0 = .) (.b .c = .)
tab kldb if work == 1, m

tostring kldb, gen(helpvar)
replace helpvar = substr(helpvar,-1,.) 
destring helpvar, replace

#delimit
	recode helpvar
		(1 = 1 "Helfer")
		(2 = 2 "Fachkraft")
		(3 = 3 "Spezialist")
		(4 = 4 "Experte")
		, gen(niveau)
		;
#delimit cr

drop helpvar
tab niveau if work == 1, m
label var niveau "Anforderungsniveau (KLDB)"

* Task (AUTOR)
  * -----------------------------------
gen kldb2010_3 = int(p_kldb2010/100)
gen jahr = 2013

merge m:1 kldb2010_3 jahr using $do/tasks_kldb2010_3.dta, ///
	keepusing(haupttask)
keep if _merge != 2
tab p_kldb2010 if _merge == 1,m
drop _merge
replace haupttask = . if p_kldb2010 >=.

tab haupttask

ren kldb2010_3 kldb_2010_3 
label value kldb_2010_3 kldb2010_3 

* Berufsgruppen
#delimit
	recode kldb
		(10000/19999 = 1 "Land-, Forst- und Tierwirtschaft und Gartenbau")
		(20000/29999 = 2 "Rohstoffgewinnung, Produktion und Fertigung")
		(30000/39999 = 3 "Bau, Architektur, Vermessung und Gebäudetechnik")
		(40000/49999 = 4 "Naturwissenschaft, Geografie und Informatik")
		(50000/59999 = 5 "Verkehr, Logistik, Schutz und Sicherheit")
		(60000/69999 = 6 "Kaufmännische Dienstleistungen, Warenhandel, Vertrieb, Hotel und Tourismus")
		(70000/79999 = 7 "Unternehmensorganisation, Buchhaltung, Recht und Verwaltung")
		(80000/89999 = 8 "Gesundheit, Soziales, Lehre und Erziehung")
		(90000/99999 = 9 "Sprach-, Literatur-, Geistes-, Gesellschafts- und Wirtschaftswissenschaften, Medien, Kunst, Kultur und Gestaltung  ")
		(0000/9999 = 10 "Militär")
		,
		gen(berufgr)
		;
#delimit cr
tab berufgr if work == 1, m
label var berufgr "BERUFSGRUPPE (KLDB)"




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


* ---- Arbeitslos gemeldet -----
 
gen arbeitslos = plb0021 if plb0021 == 1
replace arbeitslos = 0 if plb0021 == 2
 
label define arbeitslos_lab 0 "Nein" 1 "Ja"
label var arbeitslos "Arbeitslos gemeldet"
label values arbeitslos arbeitslos_lab
 
 * ----- Leistungsbezug -----
 
 clonevar hh_leistungen = hlc0064_v3 
 recode hh_leistungen 2 = 0
 clonevar hh_leistungen_hoehe = hlc0065_v2

***********************************************.  new
* Temporary employment (Zeit-/ Leiharbeit):

	tab1 plb0041_v2
	tab plb0041_v2 work, m
	
	gen 	work_leih = 1 if ( plb0041_v2 == 1 | plb0041_v2 == 1 ) & work == 1 
	replace work_leih = 0 if ( plb0041_v2 == 2 | plb0041_v2 == 2 ) & work == 1 
	replace work_leih = 2 if ( inlist(plb0041_v2, -1, 3) | plb0041_v2 == -1 ) & work == 1 
	
	label var work_leih "Arbeitnehmerüberlassung" 
	label def work_leih 0 "Nicht in der AN-Überlassung" 1 "Arbeitnehmerüberlassung" 2 "Keine Angabe", modify 
	label val work_leih work_leih 
	tab work_leih 
	tab plb0041_v2 work_leih, m
	tab plb0041_v2 work_leih, m
	
	tab work_leih, m  


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

* ---------------------------------------------------------------------------- *
* Missmatch vorherige und jetzige Tätigkeit
* ---------------------------------------------------------------------------- *

gen match_work0 = .

#delimit
	label def match_work0_lab
		1 "unter dem Niveau der früher ausgeübten Tätigkeit" 
		2 "auf dem Niveau der früher ausgeübten Tätigkeit" 
		3 "über dem Niveau der früher ausgeübten Tätigkeit"
		, replace;
#delimit cr
label var match_work0 "Anforderungsniveau der aktuellen Beschäftigung ist..."
label val match_work0 match_work0_lab

replace match_work0 = 1 if niveau < niveau0 & niveau < . & niveau0 < .
replace match_work0 = 2 if niveau == niveau0 & niveau < . & niveau0 < .
replace match_work0 = 3 if niveau > niveau0 & niveau < . & niveau0 < .

recode isceda11a (0 1 2 = 1) (3 4 = 2) (5 6 = 3) (7 8 = 4), gen(niveau_vorh)

gen match_edu0 = .

#delimit
	label def match_edu0_lab
		1 "unter dem Niveau der beruflichen Abschlüsse" 
		2 "auf dem Niveau der beruflichen Abschlüsse" 
		3 "über dem Niveau der beruflichen Abschlüsse"
		, replace;
#delimit cr
label var match_edu0 "Anforderungsniveau der aktuellen Beschäftigung ist..."
label val match_edu0 match_edu0_lab

replace match_edu0 = 1 if niveau < niveau_vorh & niveau < . & niveau_vorh < .
replace match_edu0 = 2 if niveau == niveau_vorh & niveau < . & niveau_vorh < .
replace match_edu0 = 3 if niveau > niveau_vorh & niveau < . & niveau_vorh < .

  * --------------------
    * GERMAN LANGUAGE
  *  --------------------

 * ----- Speaking -----
 
gen speak_german = plj0071 

label var speak_german "German Language: Speaking"
#delimit
label define speak_german_lab 
		5 "[5] Sehr gut"
		4 "[4] Gut"
		3 "[3] Es geht"
		2 "[2] Eher schlecht"
		1 "[1] Gar nicht"
		, replace;
#delimit cr
label values speak_german speak_german_lab		
		
tab speak_german

 * ----- Writing -----

gen write_german = plj0072 

label var write_german "German Language: Writing"
#delimit
label define write_german_lab 
		5 "[5] Sehr gut"
		4 "[4] Gut"
		3 "[3] Es geht"
		2 "[2] Eher schlecht"
		1 "[1] Gar nicht"
		, replace;
#delimit cr
label values write_german write_german_lab	

tab write_german

 * ----- Reading -----

gen read_german = plj0073 

label var read_german "German Language: Reading"
#delimit
label define read_german_lab 
		5 "[5] Sehr gut"
		4 "[4] Gut"
		3 "[3] Es geht"
		2 "[2] Eher schlecht"
		1 "[1] Gar nicht"
		, replace;
#delimit cr
label values read_german read_german_lab	

tab read_german

 * ----- Language score -----

foreach var of varlist speak_german write_german read_german {
	recode `var' (1=5) (2=4) (3=3) (4=2) (5=1)  
	}

egen german_score=rowmean(speak_german read_german write_german)

label var german_score "German Language (Score)"

tab german_score, m

gen de_kenntnisse = .
replace de_kenntnisse = 1 if german_score>=1 & german_score<=2
replace de_kenntnisse = 2 if german_score>2 & german_score<4
replace de_kenntnisse = 3 if german_score>=4 & german_score<=5
label define de_kenntnisse 3 "Gut" 2 "Mittel" 1 "Schlecht"
label var de_kenntnisse "Selbstgeschätzte Deutschkenntnisse"
label values de_kenntnisse de_kenntnisse 
fre de_kenntnisse 

* vor zuzug
  
gen speak_german0 = lb1231 if lb1231<.
gen write_german0 = lb1232 if lb1232<.
gen read_german0 = lb1233 if lb1233<.

foreach var of varlist speak_german0 write_german0 read_german0 {
	recode `var' (1=5) (2=4) (3=3) (4=2) (5=1)  
	}

egen german_score0=rowmean(speak_german0 write_german0 read_german0)

label var german_score0 "German Language vor dem Zuzug (Score)"

tab german_score0, m


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
label var other_course_part "Teilgenommen oder Teilnahme derzeit in Anderem Deutschsprachkurs"
label values other_course_part

tab mnth_s_arvl_cat1 other_course_part, m

 * ----- Finished course -----

* coded as finished if participated, year of finishing is known, and course is not ongoing  
gen other_course_fin = 1 if plm735i01I01 > 0 & plm735i01I01 < . & plm736I01 != 1
recode  other_course_fin . = 0 if other_course_part == 0
recode  other_course_fin . = 0 if plm736I01 == 1

* Rest is missing information

label define other_course_fin 0 "[0] Nein" 1 "[1] Ja"
label var other_course_fin "Anderer Deutschsprachkurs: abgeschlossen"
label values other_course_fin other_course_fin

tab mnth_s_arvl_cat1 other_course_fin, m

 * ----- Current participation -----

gen other_course_aktl = .
replace other_course_aktl = 1 if other_course_part == 1 & other_course_fin == 0
replace other_course_aktl = 1 if plm736I01 == 1
replace other_course_aktl = 1 if plm736I02 == 1
replace other_course_aktl = 1 if plm736I03 == 1
recode  other_course_aktl . = 0 if other_course_fin == 1

label define other_course_aktl  0 "[0] Nein" 1 "[1] Ja"
label var other_course_aktl "Anderer Deutschsprachkurs: Teilnahme derzeit"
label values other_course_aktl other_course_aktl

tab other_course_aktl, m

  * ------------------------------
    * prof-german course
  * ------------------------------
 * ----- Participation -----
 
gen prof_course_part = 1 if plm723I02 == 1 
recode prof_course_part (. = 0) if plm723I02 == .b  

label define prof_course_part_lab 0 "[0] Nein" 1 "[1] Ja"
#delimit
label var prof_course_part "Teilgenommen oder Teilnahmen derzeit in berufsbezogenen Kurs";
#delimit cr
label values prof_course_part prof_course_part_lab

tab prof_course_part plm723I02, m

 * ----- Finished course -----

* coded as finished if participated, year of finishing is known, and course is not ongoing  
gen prof_course_finished = 0 if prof_course_part == 0
replace prof_course_finished = 0 if plm728i01I01 == 1 //ongoing
replace prof_course_finished = 0 if plm728I02I02 == 1 //ongoing
replace prof_course_finished = 0 if plm728I03I03 == 1 //ongoing
replace prof_course_finished = 1 if plm726I01 >0 & plm726I01 < . & plm728i01I01 != 1
replace prof_course_finished = 1 if plm726I02 >0 & plm726I02 < . & plm728I02I02 != 1
replace prof_course_finished = 1 if plm726I03 >0 & plm726I03 < . & plm728I03I03 != 1
label define prof_course_finished_lab 0 "[0] Nein" 1 "[1] Ja"
label var prof_course_finished "berufsbezogenen Kurs: abgeschlossen"
label values prof_course_finished prof_course_finishedlab

tab prof_course_finished, m


 * ----- Current participation -----

gen prof_course_curr = 1 if plm728i01I01 == 1
recode prof_course_curr .= 1 if plm728I02I02 == 1
recode prof_course_curr .= 1 if plm728I03I03 == 1
recode prof_course_curr .= 0 if prof_course_finished == 1
recode prof_course_curr .= 0 if prof_course_finished == 0

label define prof_course_curr_lab 0 "[0] Nein" 1 "[1] Ja"
label var prof_course_curr "berufsbezogenen Kurs: teilnahme derzeit"
label values prof_course_curr int_bamf_curr_lab

tab prof_course_curr, m

* inhalt, weitere Kenntnisse
gen prof_course_lang = 0 if prof_course_part == 0
replace prof_course_lang = 1 if plm728i02I01 == 1
replace prof_course_lang = 1 if plm728i02I02 == 1
replace prof_course_lang = 1 if plm728i02I03 == 1
recode prof_course_lang .= 0 if plm728i02I01 == .b
recode prof_course_lang .= 0 if plm728i02I02 == .b
recode prof_course_lang .= 0 if plm728i02I03 == .b
label var prof_course_lang "berufsbezogener Deutschsprachkurs: Sprachunterricht"
tab prof_course_lang prof_course_part, m

gen prof_course_cv = 0 if prof_course_part == 0
replace prof_course_cv = 1 if plm728i03I01 == 1
recode prof_course_cv .= 0 if plm728i03I01 == .b
replace prof_course_cv = 1 if plm728i03I02 == 1
recode prof_course_cv .= 0 if plm728i03I02 == .b
replace prof_course_cv = 1 if plm728i03I03 == 1
recode prof_course_cv .= 0 if plm728i03I03 == .b
label var prof_course_cv "berufsbezogener Deutschsprachkurs: Bewerbungstraining"
tab prof_course_cv prof_course_part, m

gen prof_course_praxis = 0 if prof_course_part == 0
replace prof_course_praxis = 1 if plm728i04I01 == 1
recode prof_course_praxis .= 0 if plm728i04I01 == .b
replace prof_course_praxis = 1 if plm728i04I02 == 1
recode prof_course_praxis .= 0 if plm728i04I02 == .b
replace prof_course_praxis = 1 if plm728i04I03 == 1
recode prof_course_praxis .= 0 if plm728i04I03 == .b
label var prof_course_praxis "berufsbezogener Deutschsprachkurs: Praxisphase"
tab prof_course_praxis prof_course_part, m

gen prof_course_berufo = 0 if prof_course_part == 0
replace prof_course_berufo = 1 if plm728i05I01 == 1
recode prof_course_berufo .= 0 if plm728i05I01 == .b
replace prof_course_berufo = 1 if plm728i05I02 == 1
recode prof_course_berufo .= 0 if plm728i05I02 == .b
replace prof_course_berufo = 1 if plm728i05I03 == 1
recode prof_course_berufo .= 0 if plm728i05I03 == .b
label var prof_course_berufo "berufsbezogener Deutschsprachkurs: Berufliche Orientierung"
tab prof_course_berufo prof_course_part, m

gen prof_course_festf = 0 if prof_course_part == 0
replace prof_course_festf = 1 if plm728i06I01 == 1
recode prof_course_festf .= 0 if plm728i06I01 == .b
replace prof_course_festf = 1 if plm728i06I02 == 1
recode prof_course_festf .= 0 if plm728i06I02 == .b
replace prof_course_festf = 1 if plm728i06I03 == 1
recode prof_course_festf .= 0 if plm728i06I03 == .b
label var prof_course_festf "berufsbezogener Deutschsprachkurs: Feststellung Fähigkeiten"
tab prof_course_festf prof_course_part, m

gen prof_course_oth = 0 if prof_course_part == 0
replace prof_course_oth = 1 if plm728i07I01 == 1
recode prof_course_oth .= 0 if plm728i07I01 == .b
replace prof_course_oth = 1 if plm728i07I02 == 1
recode prof_course_oth .= 0 if plm728i07I02 == .b
label var prof_course_oth "berufsbezogener Deutschsprachkurs: anderes"
tab prof_course_oth prof_course_part, m


 * --- BA measures (Maßnahme) ---
 
gen am_maßnahm_part = .
replace am_maßnahm_part = 0 if plm740I01 == 2
replace am_maßnahm_part = 1 if plm740I01 == 1

label define am_maßnahm_part 0 "[0] Nein" 1 "[1] Ja"
label var am_maßnahm_part "Arbeitsmarkt- und berufsbez. Maßnahmen"
label values am_maßnahm_part am_maßnahm_part

tab am_maßnahm_part work, m


* coded as finished if participated, year of finishing is known, and course is not ongoing  
gen am_maßnahm_finished = 0 if am_maßnahm_part == 0
replace am_maßnahm_finished = 0 if plm744I01 == 1 //ongoing
replace am_maßnahm_finished = 0 if plm744I02 == 1 //ongoing
replace am_maßnahm_finished = 0 if plm744I03 == 1 //ongoing
replace am_maßnahm_finished = 1 if plm743i01I01 >0 & plm743i01I01 < . & plm744I01 != 1
replace am_maßnahm_finished = 1 if plm743I02I02 >0 & plm743I02I02 < . & plm744I02 != 1
replace am_maßnahm_finished = 1 if plm743I03I03 >0 & plm743I03I03 < . & plm744I03 != 1
label define am_maßnahm_finished_lab 0 "[0] Nein" 1 "[1] Ja"
label var am_maßnahm_finished "arbeitsmarkmaßnahmen: abgeschlossen"
label values am_maßnahm_finished am_maßnahm_finishedlab

tab am_maßnahm_finished, m


 * ----- Current participation -----

gen am_maßnahm_curr = 1 if plm744I01 == 1
recode am_maßnahm_curr .= 1 if plm744I02 == 1
recode am_maßnahm_curr .= 1 if plm744I03 == 1
recode am_maßnahm_curr .= 0 if am_maßnahm_finished == 1
recode am_maßnahm_curr .= 0 if am_maßnahm_finished == 0

label define am_maßnahm_curr_lab 0 "[0] Nein" 1 "[1] Ja"
label var am_maßnahm_curr "arbeitsmarkmaßnahmen: teilnahme derzeit"
label values am_maßnahm_curr int_bamf_curr_lab

tab am_maßnahm_curr, m


* inhalt, weitere Kenntnisse
gen am_maßnahm_lang = 0 if am_maßnahm_part == 0
replace am_maßnahm_lang = 1 if plm745i01I01 == 1
replace am_maßnahm_lang = 1 if plm745I02I02 == 1
replace am_maßnahm_lang = 1 if plm745I03I03 == 1
recode am_maßnahm_lang .= 0 if plm745i01I01 == .b
recode am_maßnahm_lang .= 0 if plm745I02I02 == .b
recode am_maßnahm_lang .= 0 if plm745I03I03 == .b
label var am_maßnahm_lang "berufsbezogener Deutschsprachkurs: Sprachunterricht"
tab am_maßnahm_lang am_maßnahm_part, m

gen am_maßnahm_cv = 0 if am_maßnahm_part == 0
replace am_maßnahm_cv = 1 if plm745i02I01 == 1
recode am_maßnahm_cv .= 0 if plm745i02I01 == .b
replace am_maßnahm_cv = 1 if plm745i02I02 == 1
recode am_maßnahm_cv .= 0 if plm745i02I02 == .b
replace am_maßnahm_cv = 1 if plm745i02I03 == 1
recode am_maßnahm_cv .= 0 if plm745i02I03 == .b
label var am_maßnahm_cv "berufsbezogener Deutschsprachkurs: Bewerbungstraining"
tab am_maßnahm_cv am_maßnahm_part, m

gen am_maßnahm_praxis = 0 if am_maßnahm_part == 0
replace am_maßnahm_praxis = 1 if plm745i03I01 == 1
recode am_maßnahm_praxis .= 0 if plm745i03I01 == .b
replace am_maßnahm_praxis = 1 if plm745i03I02 == 1
recode am_maßnahm_praxis .= 0 if plm745i03I02 == .b
replace am_maßnahm_praxis = 1 if plm745i03I03 == 1
recode am_maßnahm_praxis .= 0 if plm745i03I03 == .b
label var am_maßnahm_praxis "berufsbezogener Deutschsprachkurs: Praxisphase"
tab am_maßnahm_praxis am_maßnahm_part, m

gen am_maßnahm_berufo = 0 if am_maßnahm_part == 0
replace am_maßnahm_berufo = 1 if plm745i04I01 == 1
recode am_maßnahm_berufo .= 0 if plm745i04I01 == .b
replace am_maßnahm_berufo = 1 if plm745i04I02 == 1
recode am_maßnahm_berufo .= 0 if plm745i04I02 == .b
replace am_maßnahm_berufo = 1 if plm745i04I03 == 1
recode am_maßnahm_berufo .= 0 if plm745i04I03 == .b
label var am_maßnahm_berufo "berufsbezogener Deutschsprachkurs: Berufliche Orientierung"
tab am_maßnahm_berufo am_maßnahm_part, m

gen am_maßnahm_festf = 0 if am_maßnahm_part == 0
replace am_maßnahm_festf = 1 if plm745i05I01 == 1
recode am_maßnahm_festf .= 0 if plm745i05I01 == .b
replace am_maßnahm_festf = 1 if plm745i05I02 == 1
recode am_maßnahm_festf .= 0 if plm745i05I02 == .b
replace am_maßnahm_festf = 1 if plm745i05I03 == 1
recode am_maßnahm_festf .= 0 if plm745i05I03 == .b
label var am_maßnahm_festf "berufsbezogener Deutschsprachkurs: Feststellung Fähigkeiten"
tab am_maßnahm_festf am_maßnahm_part, m

gen am_maßnahm_oth = 0 if am_maßnahm_part == 0
replace am_maßnahm_oth = 1 if plm745i06I01 == 1
recode am_maßnahm_oth .= 0 if plm745i06I01 == .b
replace am_maßnahm_oth = 1 if plm745i06I02 == 1
recode am_maßnahm_oth .= 0 if plm745i06I02 == .b
replace am_maßnahm_oth = 1 if plm745i06I03 == 1
recode am_maßnahm_oth .= 0 if plm745i06I03 == .b
label var am_maßnahm_oth "berufsbezogener Deutschsprachkurs: anderes"
tab am_maßnahm_oth am_maßnahm_part, m


  * ------------------------------
    * GERMAN COURSES AGGREGATED
  * ------------------------------

 * ----- Participation ----- 
 
* integrates all types of courses from generated variables and all persons who have participated in one regardless of finishing it; 
* job-related German courses are also included

gen deu_aggr_part = .
replace deu_aggr_part = 0 if other_course_part == 0
replace deu_aggr_part = 0 if int_bamf_part == 0 
replace deu_aggr_part = 0 if prof_course_part == 0 

replace deu_aggr_part = 1 if other_course_part == 1
replace deu_aggr_part = 1 if int_bamf_part ==1 
replace deu_aggr_part = 1 if prof_course_part == 1

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
replace deu_aggr_finished = 0 if prof_course_finished == 0
replace deu_aggr_finished = 0 if prof_course_curr == 1  
replace deu_aggr_finished = 1 if other_course_fin == 1
replace deu_aggr_finished = 1 if int_bamf_finished ==1 
replace deu_aggr_finished = 1 if prof_course_finished == 1

label define deu_aggr_finished_lab 0 "[0] Nein" 1 "[1] Ja"
label var deu_aggr_finished "Deutschkurs abgeschlossen (aggregiert)"
label values deu_aggr_finished deu_aggr_finished_lab

tab deu_aggr_finished, m 

 * ----- Curr course -----

* Finished courses from gen. variables and job-related German courses

gen deu_aggr_curr = .
replace deu_aggr_curr = 0 if other_course_fin == 0
replace deu_aggr_curr = 0 if int_bamf_finished == 0
replace deu_aggr_curr = 0 if prof_course_finished == 0
replace deu_aggr_curr = 0 if other_course_fin == 1
replace deu_aggr_curr = 0 if int_bamf_finished ==1 
replace deu_aggr_curr = 0 if prof_course_finished == 1
replace deu_aggr_curr = 1 if other_course_aktl == 1
replace deu_aggr_curr = 1 if int_bamf_curr == 1  
replace deu_aggr_curr = 1 if prof_course_curr == 1  

label define deu_aggr_curr 0 "[0] Nein" 1 "[1] Ja"
label var deu_aggr_curr "Deutschkurs current (aggregiert)"
label values deu_aggr_curr deu_aggr_curr


gen deu_finished_niv = 0 if deu_aggr_finished == 0

#delimit
	label define deu_finished_niv 
		0 "Keins" 
		1 "A1/A2" 
		2 "B1/B2" 
		3 "C1/C3" 
		4 "Kein/andere Besch."
		, replace
		;
#delimit cr

lab val deu_finished_niv deu_finished_niv 
* integrationssprachkurs
replace deu_finished_niv = 3 if inlist(plm731I01,5,6)	
replace deu_finished_niv = 3 if inlist(plm731I02,5,6)	
replace deu_finished_niv = 3 if inlist(plm731I03,5,6)	
replace deu_finished_niv = 3 if inlist(plm739I01,5,6)	
replace deu_finished_niv = 3 if inlist(plm739I02,5,6)	
replace deu_finished_niv = 3 if inlist(plm739I03,5,6)	

recode deu_finished_niv . = 2 if inlist(plm731I01,3,4)	
recode deu_finished_niv . = 2 if inlist(plm731I02,3,4)	
recode deu_finished_niv . = 2 if inlist(plm731I03,3,4)	
recode deu_finished_niv . = 2 if inlist(plm739I01,3,4)	
recode deu_finished_niv . = 2 if inlist(plm739I02,3,4)	
recode deu_finished_niv . = 2 if inlist(plm739I03,3,4)	
recode deu_finished_niv . = 2 if inlist(plj0661_v2,3,4)	

recode deu_finished_niv . = 1 if inlist(plm731I01,1,2)	
recode deu_finished_niv . = 1 if inlist(plm731I02,1,2)	
recode deu_finished_niv . = 1 if inlist(plm731I03,1,2)	
recode deu_finished_niv . = 1 if inlist(plm739I01,1,2)	
recode deu_finished_niv . = 1 if inlist(plm739I02,1,2)	
recode deu_finished_niv . = 1 if inlist(plm739I03,1,2)	
recode deu_finished_niv . = 1 if inlist(plj0661_v2,1,2)	
recode deu_finished_niv . = 1 if inlist(plj0661_v2,6) //A2 nicht erreicht	

recode deu_finished_niv . = 4 if inlist(plm731I01,7,8)	
recode deu_finished_niv . = 4 if inlist(plm731I02,7,8)	
recode deu_finished_niv . = 4 if inlist(plm731I03,7,8)	
recode deu_finished_niv . = 4 if inlist(plm739I01,7,8)	
recode deu_finished_niv . = 4 if inlist(plm739I02,7,8)	
recode deu_finished_niv . = 4 if inlist(plm739I03,7,8)	
recode deu_finished_niv . = 4 if inlist(plj0661_v2,5)	

tab deu_finished_niv deu_aggr_finished,m

lab var deu_finished_niv "höchstes besch. Niveua"

gen deu_finished_niv_det = 0 if deu_aggr_finished == 0
#delimit
	label define deu_finished_niv_det 
		0 "Keins" 
		1 "A1" 
		2 "A2" 
		3 "B1" 
		4 "B2" 
		5 "C1" 
		6 "C2" 
		7 "Kein/andere Besch."
		, replace
		;
#delimit cr

lab val deu_finished_niv_det deu_finished_niv_det 
replace deu_finished_niv_det = 7 if inlist(plm731I01,7,8)	
replace deu_finished_niv_det = 7 if inlist(plm731I02,7,8)	
replace deu_finished_niv_det = 7 if inlist(plm731I03,7,8)	
replace deu_finished_niv_det = 7 if inlist(plm739I01,7,8)	
replace deu_finished_niv_det = 7 if inlist(plm739I02,7,8)	
replace deu_finished_niv_det = 7 if inlist(plm739I03,7,8)	
replace deu_finished_niv_det = 7 if inlist(plj0661_v2,5)	
replace deu_finished_niv_det = 1 if inlist(plm731I01,1)	
replace deu_finished_niv_det = 1 if inlist(plm731I02,1)	
replace deu_finished_niv_det = 1 if inlist(plm731I03,1)	
replace deu_finished_niv_det = 1 if inlist(plm739I01,1)	
replace deu_finished_niv_det = 1 if inlist(plm739I02,1)	
replace deu_finished_niv_det = 1 if inlist(plm739I03,1)	
replace deu_finished_niv_det = 1 if inlist(plj0661_v2,1)	
replace deu_finished_niv_det = 1 if inlist(plj0661_v2,6) //A2 nicht erreicht	
replace deu_finished_niv_det = 2 if inlist(plm731I01,2)	
replace deu_finished_niv_det = 2 if inlist(plm731I02,2)	
replace deu_finished_niv_det = 2 if inlist(plm731I03,2)	
replace deu_finished_niv_det = 2 if inlist(plm739I01,2)	
replace deu_finished_niv_det = 2 if inlist(plm739I02,2)	
replace deu_finished_niv_det = 2 if inlist(plm739I03,2)	
replace deu_finished_niv_det = 2 if inlist(plj0661_v2,2)	
replace deu_finished_niv_det = 3 if inlist(plm731I01,3)	
replace deu_finished_niv_det = 3 if inlist(plm731I02,3)	
replace deu_finished_niv_det = 3 if inlist(plm731I03,3)	
replace deu_finished_niv_det = 3 if inlist(plm739I01,3)	
replace deu_finished_niv_det = 3 if inlist(plm739I02,3)	
replace deu_finished_niv_det = 3 if inlist(plm739I03,3)	
replace deu_finished_niv_det = 3 if inlist(plj0661_v2,3)	
replace deu_finished_niv_det = 4 if inlist(plm731I01,4)	
replace deu_finished_niv_det = 4 if inlist(plm731I02,4)	
replace deu_finished_niv_det = 4 if inlist(plm731I03,4)	
replace deu_finished_niv_det = 4 if inlist(plm739I01,4)	
replace deu_finished_niv_det = 4 if inlist(plm739I02,4)	
replace deu_finished_niv_det = 4 if inlist(plm739I03,4)	
replace deu_finished_niv_det = 4 if inlist(plj0661_v2,4)	
replace deu_finished_niv_det = 5 if inlist(plm731I01,5)	
replace deu_finished_niv_det = 5 if inlist(plm731I02,5)	
replace deu_finished_niv_det = 5 if inlist(plm731I03,5)	
replace deu_finished_niv_det = 5 if inlist(plm739I01,5)	
replace deu_finished_niv_det = 5 if inlist(plm739I02,5)	
replace deu_finished_niv_det = 5 if inlist(plm739I03,5)	
replace deu_finished_niv_det = 6 if inlist(plm731I01,6)	
replace deu_finished_niv_det = 6 if inlist(plm731I02,6)	
replace deu_finished_niv_det = 6 if inlist(plm731I03,6)	
replace deu_finished_niv_det = 6 if inlist(plm739I01,6)	
replace deu_finished_niv_det = 6 if inlist(plm739I02,6)	
replace deu_finished_niv_det = 6 if inlist(plm739I03,6)	
tab deu_finished_niv_det deu_aggr_finished,m

lab var deu_finished_niv_det "höchstes besch. Niveua"

tab deu_finished_niv_det,m


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

  * ------------------------------
    * Duration until first course
  * ------------------------------

 * ----- Help variables -----  

* Anderer Kurs 
gen helpdate1 = ym(plm734i01I01,plm734i02I01)	
format helpdate1 %tm
gen helpyr1 = plm734i01I01
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

//br pid helpdate2 helpyr2 plj0655 plj0656 arrival*

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
//br pid syear arrival_date arrival_yr day_interview date_1stcourse yr_1stcourse help* plj0655 plj0656
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

drop helpvar helpdate* helpyr* lang_course_miss

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
egen youngest_child_miss = rowmiss(help*) 
sort pid
//br pid youngest_child help*

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

 * ----- PARTNER IN HOUSEHOLD -----

gen partner_in_hh = partner_vorh == 0 
replace partner_in_hh = 1 if plj0627_v1 == 1 | plj0630 == 1
replace partner_in_hh = 2 if plj0627_v1 == 2 | plj0630 == 2	|				 ///
							 plj0627_v1 == 3 | plj0630 == 3
replace partner_in_hh = 3 if plj0627_v1 == 4 | plj0630 == 4	|				 ///
							 plj0627_v1 == 5 | plj0630 == 5

label var partner_in_hh "Partner im Haushalt"
#delimit
	label define partner_in_hh_lab 
		0 "[0] Kein Partner" 
		1 "[1] Partner im Haushalt" 
		2 "[2] Partner in Deutschland außerhalb des Haushalts" 
		3 "[3] Partner im Ausland"
		, replace;
#delimit cr
label values partner_in_hh partner_in_hh_lab

 * ----- HOUSEHOLD CONSTELATION -----

gen hh_const = .
replace hh_const = 1 if (partner_in_hh == 0 | partner_in_hh == 2 | partner_in_hh == 3 ) ///
						& (h_child_age == 1 | h_child_age == 5)
replace hh_const = 2 if partner_in_hh == 1 & (h_child_age == 1 | h_child_age == 5)

replace hh_const = 6 if (partner_in_hh == 0 | partner_in_hh == 2 | partner_in_hh == 3 ) ///
						& h_child_age == 4
replace hh_const = 4 if partner_in_hh == 1 & h_child_age == 4

replace hh_const = 5 if (partner_in_hh == 0 | partner_in_hh == 2 | partner_in_hh == 3 ) ///
						& (h_child_age == 2 | h_child_age == 3)
replace hh_const = 3 if partner_in_hh == 1 & (h_child_age == 2 | h_child_age == 3)
lab val hh_const hh_const

label var hh_const "Haushaltskonstellation: Kinder und Partner"
#delimit
label def hh_const_lab
	1 "Alleinstehend ohne Kinder"
	2 "Familie ohne Kinder"
	3 "Familie mit Kinder <=6"
	4 "Familie mit Kinder >6 & <16"
	5 "Alleinstehend mit Kinder <=6"
	6 "Alleinstehend mit Kinder >6 & <16"
		;
#delimit cr
label values hh_const hh_const_lab

*******************************************************************************
*** Willkommensgefühl ***
*******************************************************************************

recode plj0591 (1/2=3) (3=2) (4/5=1) (.a=.), gen(willkommen0)
label var willkommen0 "Willkommensgefühl bei der Ankunft nach DE"
label define willkommen 3 "Willkommen" 2 "Teilweise" 1 "Nicht willkommen"
label values willkommen0 willkommen
tab plj0591 willkommen0

clonevar willkommen0_det = plj0591 if plj0591 <.

recode plj0592 (1/2=3) (3=2) (4/5=1) (.a=.), gen(willkommen1)
label var willkommen1 "Willkommensgefühl jetzt"
label values willkommen1 willkommen
tab plj0592 willkommen1

clonevar willkommen1_det = plj0592 if plj0592 <.


*******************************************************************************
*** Kontakt zu Deutschen ***
*******************************************************************************

recode short006 (1/2=1)(3/5=2)(6=3)(.a=.), gen(kontakt_de)
label var kontakt_de "Wie oft verbringen Sie Zeit mit Deutschen?"
label define kontakt_de 1 "Oft" 2 "Selten" 3 "Nie" 
label values kontakt_de kontakt_de 
fre kontakt_de



  * --------------------
    * CLEAN VARIABLES
  * --------------------

#delimit
keep pid hid cid syear n N prev_stichprobe samplehh instrument_p_ref mode start* end*
day_interview intv_year_month female geb_year_mont age age_cat age_cat2 age1st age1stsq partnership
arrival_yr arrival_mth arrival_date mnth_s_arrival
forever_de_v40 settle_intent kohorte bula east_g west_g healthy health1
edu_asl years_sch0 total_years_edu0 school_type school_degree schul_abschluss_aus schulbesuch_aus no_school
qual_type qual_type_deg years_ausbhoch0 school_aus_cert beruf_aus_cert iabschlussa ausbildung_aus
isceda11a iscedp11a isceda11a_aggr iscedp11a_aggr 
abschl_anerkenn abschl_anerkenn_det
abschl_an_kldb abschl_numb abschl_an_numb abschl_an_result kein_abschl_an 
abschl_an_berufl_type abschl_an_hochsch_type abschl_an_hochsch_type2 
abschl_an_kldb abschl_numb abschl_an_numb abschl_an_result kein_abschl_an
actual_empl work paid_work empl_type lfs_status lfs_status_dtl lmactivity vollzeit geringf selfem work_befrist 
arbeitslos hh_leistungen /*timing_empl type_empl*/ hh_leistungen_hoehe  
work_blohn ln_work_blohn work_nlohn work_blohn_less520 work_hours_contract work_hours_actual work_blohn_hour work_nlohn_hour
job_search search_first_job search_first_job2 future_empl future_empl1 timing_future_empl type_future_empl future_empl_dum
ec_status0 inc_status0 empl0 empl0_aggr work0 branch0 branch0_vgr sektor0_aggr2
l_isco08_job09 isco0_08 isei0 isco0_1dig isco0_oesch5 isco0_skilllev l_kldb2010_job09 kldb0 niveau0 
p_isco08 isco_08 isei isco_1dig isco_oesch5 isco_skilllev p_kldb2010 kldb niveau
branch branch_vgr /*sektor_aggr*/ sektor_aggr2
speak_german write_german read_german german_score 
de_kenntnisse
speak_english write_english read_english english_score
int_bamf_part int_bamf_finished int_bamf_curr other_course_part other_course_fin other_course_aktl 
deu_aggr_part deu_aggr_finished deu_aggr_num date_1stcourse yr_1stcourse lang_course mths_kursstart yrs_kursstart
children h_child_hh hchild_N youngest_child h_child_age h_child_age_0_2 h_child_age_3_6 h_child_age_7_17 
partnr partner_vorh partner_in_hh 

phrf23vorab_SUARE hhrf23vorab_SUARE

mon_1job
willkommen0* willkommen1* algba2_dum
kontakt_de

kldb0_2010_3
kldb_2010_3

berufsabschl_a
bleibeabsichten
work_leih
future_prof_edu future_school_edu future_any_edu edu_de_curr edu_de_type_curr edu_de_ever
job1st job1st_yr job1st_m job1st_date job1st_date_corrected job1st_date_corrected_cens
search_first_job search_first_job2 jb1_jsearch
jobsearch
*jsearch*
match*
mnth_s*
dur_stay_*
mnth_s_arrival
haupttask haupttask0
prof_edu_YK prof_edu_YK_aggr
isced*
wexp0*
age_arriv*
know_algba
sup_*
an_vorgesch
*berufgr*
an_dauer an_dauer_s
intv_year_month
deu_finished_niv*
*algba*
deu_aggr*

*course*
*am_maßnahm*

hh_const
german*
;
#delimit cr

********************************************







**********************
* Kurs status 
**********************
	lab def kurs_stat_v1 1 "noch kein kurs" 2 "kursteilnahme ohne abschluss" 3 "kurs derzeit" 4 "kurs abgeschlossen" , replace
	gen kurs_stat_v1 = 1 if deu_aggr_part == 0
	replace kurs_stat_v1 = 2 if deu_aggr_part == 1
	replace kurs_stat_v1 = 3 if deu_aggr_curr == 1
	replace kurs_stat_v1 = 4 if deu_aggr_finished == 1 
	lab val kurs_stat_v1 kurs_stat_v1
	tab kurs_stat_v1 deu_aggr_part , m
	lab var kurs_stat_v1 "Kursteilnahme (abschluss uebergeordnet)"
	
	lab def kurs_stat_v2 1 "noch kein kurs" 2 "kursteilnahme ohne abschluss" 4 "kurs derzeit" 3 "kurs abgeschlossen" , replace
	gen kurs_stat_v2 = 1 if deu_aggr_part == 0
	replace kurs_stat_v2 = 2 if deu_aggr_part == 1
	replace kurs_stat_v2 = 3 if deu_aggr_finished == 1 
	replace kurs_stat_v2 = 4 if deu_aggr_curr == 1
	lab val kurs_stat_v2 kurs_stat_v2
	tab kurs_stat_v2 deu_aggr_part , m
	lab var kurs_stat_v2 "Kursteilnahme (derzeit teilnahme uebergeordnet)"
	
	
	

***************
* Monate des Interviews: 3 Gruppen 
***************

gen mon_int=1 if intv_year_month==762 | intv_year_month==763
replace mon_int=2 if intv_year_month==764 | intv_year_month==765
replace mon_int=3 if intv_year_month==766 | intv_year_month==767 | intv_year_month==768
label var mon_int "Months of interview: 3 categories"
label define mon_int 1 "Juli-August 2023" 2"September-Oktober 2023" 3"November 2023-Januar 2024"
label values mon_int mon_int

***************
* Monate des Interviews: 5 Kategorien
***************

gen mon_int5=1 if intv_year_month==762 | intv_year_month==763
replace mon_int5=2 if intv_year_month==764 
replace mon_int5=3 if intv_year_month==765
replace mon_int5=4 if intv_year_month==766 
replace mon_int5=5 if intv_year_month==767 | intv_year_month==768
label var mon_int5 "Months of interview: 5 categories"
label define mon_int5 1 "Juli-August 2023" 2"September" 3"Oktober 2023" 4"November" 5"Dezember 2023-Januar 2024"
label values mon_int5 mon_int5







































save $out_data/SOEP_v40_clean.dta, replace

capture log close

********************************************************************************
