/*
Purpose: Merge rainfall, nrega, and census data
Files Used: rainfall, nrega_mandal_level_by_season, 
Files Created: nrega-rainfall-census_mandal_level
Notes: 
*/


* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\Rainfall analysis\Temp"
global output = "F:\NREGA\Data - reorganized\Rainfall analysis\Clean"
global extra = "F:\NREGA\Data - reorganized\Extra"
set more off


use "$input\rainfall_coded.dta", clear
sort district_id mandal_id year season
merge district_id mandal_id year season using "$input\nrega_mandal_level_by_season.dta"
tab _merge
keep if _merge == 3
drop _merge


rename district_id nrega_district_id
rename mandal_id nrega_mandal_id
sort nrega_district_id nrega_mandal_id

merge nrega_district_id nrega_mandal_id using "$extra\NREGA census mandal matches.dta" 
tab _merge
keep if _merge ==3
drop _merge

tempfile temp
sort census_district_id census_mandal_id
save `temp'

* get census data into shape
use "$extra\AP Census_full.dta", clear
keep if level == "TEHSIL" & tru == "Rural"
rename district census_district_id
rename tahsil census_mandal_id
keep census_district_id census_mandal_id no_hh tot_p tot_work_p

sort census_district_id census_mandal_id
merge census_district_id census_mandal_id using `temp'
tab _merge
keep if _merge == 3


save "$output\nrega-rainfall-census_mandal_level.dta", replace




