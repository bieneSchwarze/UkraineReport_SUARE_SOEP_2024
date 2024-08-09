clear all
set maxvar 10000
capture log close

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023_Enddatenlieferung_REF_7709_20240227"

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $in\Methodendaten\soep-core-2023-instrumentation.dta", clear

 * ------------- new time var -------------
* (leave "end" in original format to compare)

gen end_year = substr(end, 1, 4)
gen end_month = substr(end, 6, 2)
gen end_day = substr(end, 9, 2)
gen end_time = substr(end, 12, 5)

 * br pid end*

destring end_year, replace
destring end_month, replace
destring end_day, replace

 * mdy %td format 
gen day_interview=mdy(end_month, end_day, end_year)
format day_interview %td
 
 * br pid end* day_interview
 
drop if day_interview==.
drop if pid<0

fre sample1
keep if sample1==44 | sample1==48
tab sample1

fre status

 * ---------- last interview date ----------

sort pid day_interview end_time

* new variable to tag the latest interview time per pid
by pid: gen last_interview = _n == _N

 * br pid instrument day_interview end_time last_interview

tab instrument last_interview

* keep only rows where latest_interview is 1
keep if last_interview

 * br pid instrument day_interview end_time last_interview end_month
tab day_interview

 * ----- instrument -----

rename instrument last_instrument
 label copy instrument instrument_original, replace
 label drop instrument
 label values last_instrument  instrument_original
 desc last_instrument

 * ---------- save ----------

save $out_data/suare_instr.dta, replace
