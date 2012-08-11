/*
Purpose: Create cleaned reservations file from raw reservations file
Files Used: Reservations_raw
Files Created: Reservations
Notes: none
*/

* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\Reservations\Raw"
global output = "F:\NREGA\Data - reorganized\Reservations\Clean"
global extra = "F:\NREGA\Data - reorganized\Extra"
set more off

use "$input\reservations_raw.dta", clear

* drop useless vars and trim and rename other ones
drop sl_no col26 - _20
rename  name_of_the_district district_name
replace district_name = upper(trim(district_name))
rename  name_of_the_mandal mandal_name
replace mandal_name = upper(trim(mandal_name))
rename  name_of_the_gram_panchayat panchayat_name
replace panchayat_name = upper(trim(panchayat_name))
rename  gp__sarpanch__reserved_for gpsarpanchreservedfor

/* create dummies for whether or not sarpanch and ward seats are reserved for each group
Note: I spent a lot of time manually going through the data to make sure that this code
appropriately tags whether or not a ward or sarpanch seat is reserved for a group.  
There may be a very small percentage of races that are not being tagged correctly but I
tink it would take a huge amount of time to improve on this */
foreach var of varlist  gpsarpanchreservedfor-ward_reserved_20 {
	replace `var' = upper(`var')
	replace `var' = "" if `var' == "-" | `var' == "0" | `var' == "--" | `var' == "---" | `var' == ".."
	generate `var'_Women = (strmatch(`var', "*W*") & !strmatch(`var', "*M*"))
	generate `var'_ST = strmatch(`var', "*S*T*")
	generate `var'_SC = strmatch(`var', "*S*C*")
	generate `var'_BC = strmatch(`var', "*B*C*")
}

* generate variable for the total number of wards in the GP by looking at the number of ward_reserved* variables which are blank
egen temp = rowmiss(ward_reserved_1-ward_reserved_20)
generate num_wards = 20-temp
bysort district_name mandal_name: egen num_wards_mandal = total(num_wards)
gen dummy =1
bysort district_name mandal_name: egen total_gps = count(dummy)
drop dummy
bysort district_name : egen num_wards_district = total(num_wards)
drop temp


/* generate the following variables:
num_res_group = total number of ward seats in each GP that are reserved for group (not including sarpanch seat)
pct_res_group = proportion of ward seats in each GP that are reserved for group
pct_res_district_group = proportion of total ward seats in each district that are reserved for group
pct_res_mandal_group = proportion of sarpanch seats in each mandal that are reserved for group
*/
foreach group in "BC" "SC" "ST" {
	egen num_res_`group' = rowtotal(ward_reserved*`group')
	gen pct_res_`group' = num_res_`group' / num_wards
	/* bysort district_id mandal_id: egen dummy = total(num_res_`group')
	gen pct_res_mandal_`group' = dummy / num_wards_mandal	
	drop dummy
	*/
	bysort district_name: egen dummy2 = total(num_res_`group')
	gen pct_res_district_`group' = dummy2 / num_wards_district	
	drop dummy2
	
	bysort district_name mandal_name: egen total_gps_res_`group' = total(gpsarpanchreservedfor_`group')
	gen pct_res_mandal_`group' = total_gps_res_`group' / total_gps

}


save "$output\reservations.dta", replace


