clear all
set maxvar 10000
capture log close

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\CORE-REF-2023_7707-7709_Enddaten-Update-2_2024-10-18\REF-2023_7707_Enddaten-Update-2_2024-10-18"

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

 * log using $out_log/data_suare_v40.log, text replace
	
use $in\Stichprobendaten\soep-core-2023-hbrutto.dta, clear
 count
 rename sample1 samplehh

merge 1:m hid cid syear using $in\Stichprobendaten\soep-core-2023-hhmatrix.dta
	keep if _merge==3
	drop _merge
	rename staat staat_hhmatrix 

merge 1:1 pid hid syear using $out_data\p-ref_non-missing
	keep if _merge==3
	drop _merge
	isid pid syear

merge 1:1 pid hid syear using $in\Stichprobendaten\soep-core-2023-pbrutto.dta
	keep if _merge==3
	drop _merge
	codebook pid	//  unique 8,553
	isid pid syear
	tab samplehh sample1, m

tab1 iyear syear

merge 1:1 pid hid using $in\Befragungsdaten\geprüft\soep-core-2023-ll-ref.dta
	keep if _merge==3
	drop _merge
	isid pid syear
	tab syear iyear
	
merge m:1 hid syear using $in\Befragungsdaten\geprüft\soep-core-2023-hh-ref.dta
	keep if _merge==3
	drop _merge

codebook pid	//  unique 6,499

/* --------------------------------------   
    Ukraine-Stichprobe und Ankunftsjahr 
  --------------------------------------- */
  
tab prev_stichprobe
keep if prev_stichprobe==1
fre sample1 samplehh

codebook pid		// double, 3438 unique

tab lr3130 						
drop if lr3130<2022				 
tab lr3130 		// 3403 Fälle 
 /* tab lr3131 if lr3130==2022
tab lr3131 if lr3130==2023 */

 * save $out_data/suare_bericht_v40_data.dta, replace 

/* -------------------------------
    merge with $instrumentation
  -------------------------------- */

rename instrument instrument_p_ref
desc instrument_p_ref
label values instrument

merge 1:1 pid syear using $out_data/suare_instr.dta
 keep if _merge==3
 drop _merge
 isid pid syear
 codebook pid
 tab syear iyear
 tab instrument
	
save $out_data/suare_bericht_v40_data.dta, replace 

/* ----------
    weights
  ----------- */
global weights "x\Vorabgewichte_v40_IAB_BAMF_SOEP_1.0"
 
merge 1:1 pid using $weights\Vorabgewichte_M34569_v40_P_1.0.dta
	keep if _merge==3
	drop _merge
	isid pid syear

merge m:1 hid using $weights\Vorabgewichte_M34569_v40_H_1.0.dta
	keep if _merge==3
	drop _merge
	isid pid syear
	codebook pid hid

save $out_data/suare_bericht_v40_data.dta, replace 

/* ----------------------------
    Recoding of missing values
  ----------------------------- 

http://about.paneldata.org/soep/dtc/data-structure.html
  Code	Meaning
-1	no answer / don't know
-2	does not apply
-3	implausible value
-4	Inadmissable multiple response
-5	Not included in this version of the questionnaire
-6	Version of questionnaire with modified filtering
-8	Question not part of the survey program this year
-9	Missing due to a terminated interview *

 --------------------------------------------------------- */

 * identifying string variables:
   
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if _rc {
        di "Variable `var' is not numeric."
    }
}

 * define, label missing values
label define miss_lab .a "No information / Don't know" .b "Does not apply" ///
.c "Implausible value" .d "Inadmissable multiple response" /// 
.e "Not included in this version of the questionnaire" ///
.f "Version of questionnaire with modified filtering" ///
.g "Question not part of the survey program this year" ///
.h "Missing due to a terminated interview", replace

 * non-string variables
qui ds, not(type string)
local nostring = "`r(varlist)'"

foreach var of varlist `nostring' {
  capture confirm numeric variable `var'
    if !_rc {
	local labelname : value label `var'      
	qui gen `var'_temp = `var'
    * decode missing values 
	qui recode `var'_temp (-1 = .a) (-2 = .b) (-3 = .c) (-4 = .d) (-5 = .e) (-6 = .f) (-8 = .g) (-9 = .h)
        
    label values `var'_temp miss_lab
        
    * replace missing values 
	foreach mv of numlist .a .b .c .d .e .f .g .h {
    	qui replace `var' = `mv' if `var'_temp == `mv'
        }
        
    label values `var' `labelname'
        
    drop `var'_temp
    }
}	

save $out_data/suare_bericht_v40_data.dta, replace 

 * optional: drop other variables with only missing values
 
qui ds, has(type numeric)
local numeric_vars `r(varlist)'

foreach var of local numeric_vars {
    quietly summarize `var', detail
    local min = r(min)
    local max = r(max)

    if (`min' == . & `max' == .) {
        display "`var'"
		drop `var'
    }
}

 *#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

clear
exit	
	
	


