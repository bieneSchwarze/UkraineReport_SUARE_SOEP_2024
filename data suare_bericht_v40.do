clear all
set maxvar 10000
capture log close

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023_Enddatenlieferung_REF_7709_20240227"

global in_Stichprobendaten"\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023_Enddatenlieferung_REF_7709_20240227\Stichprobendaten"

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

 * log using $out_log/data_suare_v40.log, text replace
	
use $in\Stichprobendaten\soep-core-2023-hbrutto.dta, clear
 count
 rename sample1 samplehh

merge 1:m hid cid syear using$in\Stichprobendaten\soep-core-2023-hhmatrix.dta
	keep if _merge==3
	drop _merge
	rename staat staat_hhmatrix 

merge 1:1 pid hid syear using $in\Befragungsdaten\Netto_geprueft\soep-core-2023-p-ref.dta
	keep if _merge==3
	drop _merge
	isid pid syear

merge 1:1 pid hid syear using $in\Stichprobendaten\soep-core-2023-pbrutto.dta
	keep if _merge==3
	drop _merge
	codebook pid	//  unique 8,555
	isid pid syear
	tab samplehh sample1, m

tab1 iyear syear

merge 1:1 pid hid using $in\Befragungsdaten\Netto_geprueft\soep-core-2023-ll-ref.dta
	keep if _merge==3
	drop _merge
	isid pid syear
	tab syear iyear
	
merge m:1 hid syear using $in\Befragungsdaten\Netto_geprueft\soep-core-2023-hh-ref.dta
	keep if _merge==3
	drop _merge

codebook pid	//  unique 6,499

/* --------------------------------------   
    Ukraine-Stichprobe und Ankunftsjahr 
  --------------------------------------- */
  
tab prev_stichprobe
keep if prev_stichprobe==1
fre sample1 samplehh

codebook pid	// double, 3438 unique

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
merge 1:1 pid using "I:\MA\fsuettmann\Vorabgewichte_v40_IAB_BAMF_SOEP_1.0\Vorabgewichte_M34569_v40_P_1.0.dta"
	keep if _merge==3
	drop _merge
	isid pid syear
	codebook pid

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
-8	Question not part of the survey program this year*

 --------------------------------------------------------- */

 * Identifying string variables:
   
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if _rc {
        di "Variable `var' is not numeric."
    }
}

qui ds, not(type string)
local nostring = "`r(varlist)'"

foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
* Define / label missings:

local numlist = 1
foreach var of varlist `nostring' {
	qui mvdecode `var', mv(-1 = .a \ -2 = .b \ -3 = .c \ -4 = .d \ -5 = .e \ -6 = .f \ -8 = .g)
	label define miss_lab`numlist' ///
	.a "No information / Don't know" .b "Does not apply" ///
	.c "Implausible value" .d "Inadmissable multiple response" /// 
	.e "Not included in this version of the questionnaire" ///
	.f "Version of questionnaire with modified filtering" ///
	.g "Question not part of the survey program this year" , replace
	label values `var' miss_lab`numlist++'
}
  
	save "${dataout}/SOEP_v40.dta", replace 

*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

	
clear
exit	
	
	


