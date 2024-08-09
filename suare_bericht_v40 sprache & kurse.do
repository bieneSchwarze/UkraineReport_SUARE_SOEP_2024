clear all
set maxvar 10000
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

 * ----- Interview date ----- 

tab end_month end_year,m
label var end_month "Interview month"

tab day_interview
label var day_interview "Interview date"

gen intv_year_month = ym(end_year, end_month)
format intv_year_month %tm

 * ---------- Arrival ----------
  
gen arrival_yr = .

/* replace arrival_yr = immiyear if immiyear>0 & immiyear<.
replace arrival_yr=imyear if imyear>0 & imyear<. & arrival_yr >=. */

replace arrival_yr=lr3130 if lr3130>0 & lr3130<. & arrival_yr>=.

replace arrival_yr = lb0019_v5 if lb0019_v5>0 & lb0019_v5<. & arrival_yr>= .

forvalues i = 5(-1)1 {
	replace arrival_yr=lm0029l0`i' if lm0029l0`i'>0 & lm0029l0`i'<. & arrival_yr >=.
	}

 * month
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

tab other_course_part, m

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

tab other_course_fin, m

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

  * ------------------------------
    * Duration until first course
  * ------------------------------

 * ----- Help variables -----  

* Anderer Kurs 
gen helpdate1 = ym(plj0536,plj0537)	
format helpdate1 %tm
gen helpyr1 = plj0536
tab1 plj0535 plj0536 plj0537 plj0538 plj0539 plj0540 plj0542

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
br pid syear day_interview date_1stcourse yr_1stcourse help* plj0655 plj0656
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

 * save $out_data/suare_v40_variablen.dta, replace