clear all
set maxvar 10000
capture log close

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023_Enddatenlieferung_REF_7709_20240227"

global AVZ ""
global do "$AVZ/do/"
global out_log "$AVZ/log"
global out_data "$AVZ/output/"
global out_temp "$AVZ/temp/"

use $in\Befragungsdaten\Netto_geprueft\soep-core-2023-p-ref.dta, clear

qui ds, has(type numeric)
local vars `r(varlist)'

local count 0

foreach var of local vars {
    quietly summarize `var' if prev_befstat == 1

    // check if all values missing 
    local min_val = r(min)
    local max_val = r(max)

    if inrange(`min_val', -8, -1) & inrange(`max_val', -8, -1) {
        qui display "`var'"
        local count = `count' + 1
        
        // Drop the variable
        drop `var'
    }
}

// Display the total count of variables that were dropped
display "number of variables with all missing values if prev_befstat == 1 and dropped: `count'"

save $out_data\p-ref_non-missing, replace
