/*
Purpose: Calculate caste and gender segregation index 
Files Used: worksite_stats_by_caste, worksite_stats_by_sex 
Files Created: caste_segregation_index_panchayat, sex_segregation_index_panchayat
Notes: For a description of how this calculation was performed see the document "Notes on creating the segregation index"
located in the "Reservations analysis" folder.  Currently, the segregation index is calculated using total_amount as the key 
variable but this can be changed.
*/

* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\NREGA\Raw\Worksite level"
global output = "F:\NREGA\Data - reorganized\Reservations analysis\Temp"
cd "$output"

local key_var total_amount

foreach group in caste sex {
	use "$input\worksite_stats_by_`group'.dta", clear
	keep  district_id mandal_id panchayat_id village_id workid `group' `key_var'
	drop if `group' == ""

	* get rid of blanks in the middle of the workid variable and then collapse on workid and group
	replace workid = regexr(workid, " ", "")
	destring workid, force replace
	format workid %20.0f
	drop if workid == .
	collapse (sum) `key_var', by(district_id mandal_id panchayat_id workid `group')

	* generate a bunch of variables at the worksite level and panchayat level
	bysort district_id mandal_id panchayat_id workid `group': egen t_j_m = total(`key_var')
	bysort district_id mandal_id panchayat_id workid: egen t_j = total(`key_var')
	bysort district_id mandal_id panchayat_id `group': egen t_m = total(`key_var')
	bysort district_id mandal_id panchayat_id: egen T = total(`key_var')

	generate pi_j_m = t_j_m / t_j
	generate pi_m = t_m  / T
	generate r_j_m = pi_j_m / pi_m
	generate rhs = t_j*r_j_m*ln(r_j_m)/T

	
	collapse (sum) rhs (mean) pi_m, by(district_id mandal_id panchayat_id `group')
	generate rhs2 = rhs*pi_m

	generate lhs = pi_m*ln(1/pi_m)
	collapse (sum) E=lhs (sum) rhs2, by(district_id mandal_id panchayat_id)

	generate segregation_index_`group' = rhs2/E

	keep district_id mandal_id panchayat_id segregation_index_`group'
	duplicates drop
	sort district_id mandal_id panchayat_id
	save `group'_segregation_index_panchayat.dta, replace
}

	