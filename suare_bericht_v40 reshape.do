clear all
capture log close

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $out_data/suare_bericht_v40_data.dta, clear

tab prev_stichprobe
tab lr3130

 * age 

gen age = syear-gebjahr

 * ----- children 
   * age: nicht nur in household -----

gen age_k_1 = 2023 - lb0287_v2
gen age_k_2 = 2023 - lb0290_v2
gen age_k_3 = 2023 - lb0293_v2
gen age_k_4 = 2023 - lb0296_v2
gen age_k_5 = 2023 - lb0299_v2
gen age_k_6 = 2023 - lb0302_v2
gen age_k_7 = 2023 - lb0305_v2
gen age_k_8 = 2023 - lb0308_v2
gen age_k_9 = 2023 - lb1139
gen age_k_10 = 2023 - lb1138
	tab1 age_k*
	
 * children gender

rename lb0288_v2 sex_k_1
rename lb0291_v1 sex_k_2
rename lb0294_v1 sex_k_3
rename lb0297_v1 sex_k_4
rename lb0300_v1 sex_k_5
rename lb0303_v1 sex_k_6
rename lb0306_v1 sex_k_7
rename lb0309_v1 sex_k_8
rename lb1166_v1 sex_k_9
rename lb1165 sex_k_10
	tab1 sex_k*
	
 * children wohnort
 
rename lb0289_v6 wohnort_k_1
rename lb0292_v6 wohnort_k_2
rename lb0295_v6 wohnort_k_3
rename lb0298_v6 wohnort_k_4
rename lb0301_v6 wohnort_k_5
rename lb0304_v6 wohnort_k_6
rename lb0307_v6 wohnort_k_7
rename lb0310_v6 wohnort_k_8
rename lb1167 wohnort_k_9
rename lb1271 wohnort_k_10
	tab1 wohnort*

sort hid pid age
br pid hid stell age sex lr3192 age_k* sex_k* wohnort_k*

 * weighting
gen khrf = hhrf23vorab_SUARE / prev_nrkid

 * ----- reshape ----- 

reshape long plan_k_ age_k_ sex_k_ wohnort_k_, i(pid) j(child_id)

sort hid pid child_id
br pid hid sex age child_id age_k_ sex_k_ wohnort_k_ 

drop if missing(age_k_) & missing(sex_k_)

sort hid child_id age_k_ sex_k_
  duplicates tag hid child_id age_k_ sex_k_ wohnort_k_, gen(dup)
  br pid hid sex age child_id age_k_ sex_k_ wohnort_k_ dup
  duplicates drop hid child_id age_k_ sex_k_ wohnort_k_, force
  drop if missing(age_k_) | missing(sex_k_)
 
 
save $out_data/suare_bericht_reshape_kinder.dta, replace
