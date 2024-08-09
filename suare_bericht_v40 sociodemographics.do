clear all
set maxvar 10000
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

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
 
gen age = syear-gebjahr 
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

 * ----- Arrival -----
  
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

* save $out_data/suare_v40_variablen.dta, replace
