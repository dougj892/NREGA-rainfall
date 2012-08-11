/*
Purpose: Create NREGA-reservations_panchayat_level dataset for analysis
Files Used: NREGA_panchayat_level, NREGA-reservations_panchayat_match, reservations, caste_segregation_index_panchayat, sex_segregation_index_panchayat
Files Created: NREGA-reservations_panchayat_level
Notes: In addition to merging all of these files, the do file also calculates stats to compare merged and unmerged files which
are used in the paper.
*/


* set paths
macro drop all
global input_nrega = "F:\NREGA\Data - reorganized\NREGA\Clean\Panchayat level"
global input_reservations = "F:\NREGA\Data - reorganized\Reservations\Clean"
global input_temp = "F:\NREGA\Data - reorganized\Reservations analysis\Temp"
global output = "F:\NREGA\Data - reorganized\Reservations analysis\Clean"
global extra = "F:\NREGA\Data - reorganized\Extra"
set more off




* merge reservations data with match list
use "$input_reservations\reservations.dta", clear
sort district_name mandal_name panchayat_name
merge district_name mandal_name panchayat_name using "$extra\NREGA-reservations_panchayat_match.dta"
tab _merge

* compare merged and unmerged reservations data
tabstat num_wards  gpsarpanchreservedfor_Women gpsarpanchreservedfor_BC gpsarpanchreservedfor_SC gpsarpanchreservedfor_ST  pct_res*, by(_merge) statistics(mean sd)
ttest num_wards, by(_merge)
ttest pct_res_BC, by(_merge)
ttest pct_res_SC, by(_merge)
ttest pct_res_ST, by(_merge)


keep if _merge ==3
drop _merge

* merge with NREGA panchayat level stats
sort district_id mandal_id panchayat_id
merge district_id mandal_id panchayat_id using "$input_nrega\NREGA_panchayat_level.dta"
tab _merge

* compare merged and unmerged NREGA data
tabstat prop_* total_amount, by(_merge) statistics(mean sd)
ttest prop_Women, by(_merge)
ttest prop_BC, by(_merge)
ttest prop_SC, by(_merge)
ttest prop_ST, by(_merge)

keep if _merge ==3
drop _merge

* merge with segregation index files
sort district_id mandal_id panchayat_id
merge district_id mandal_id panchayat_id using "$input_temp\sex_segregation_index_panchayat"
tab _merge
keep if _merge == 3
drop _merge

sort district_id mandal_id panchayat_id
merge district_id mandal_id panchayat_id using "$input_temp\caste_segregation_index_panchayat"
tab _merge
keep if _merge == 3
drop _merge

save "$output\NREGA-reservations_panchayat_level", replace








