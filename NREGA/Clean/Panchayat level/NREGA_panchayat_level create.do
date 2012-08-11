/*
Purpose: Create cleaned NREGA_panchayat_level file by collapsing NREGA_village_level
Files Used: NREGA_village_level, screw_up_panchayats
Files Created: NREGA_village_level
Notes: Some of the IDs / names of panchayats were screwed up in the AP web portal.  We delete these panchayats
*/

* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\NREGA\Clean\Village level"
global output = "F:\NREGA\Data - reorganized\NREGA\Clean\Panchayat level"
global extra = "F:\NREGA\Data - reorganized\Extra"
set more off


use "$input\NREGA_village_level.dta", clear


foreach var of varlist num_worksites- num_3200_payments_ST {
	replace `var' = 0 if `var' ==.
}

collapse (sum) num_worksites (sum)total_days_Men_BC (sum) total_amount_Men_BC (sum) num_workers_Men_BC (sum) total_days_Women_BC (sum) total_amount_Women_BC (sum) num_workers_Women_BC (sum) total_days_Men_Min (sum) total_amount_Men_Min (sum) num_workers_Men_Min (sum) total_days_Women_Min (sum) total_amount_Women_Min (sum) num_workers_Women_Min (sum) total_days_Men_OTH (sum) total_amount_Men_OTH (sum) num_workers_Men_OTH (sum) total_days_Women_OTH (sum) total_amount_Women_OTH (sum) num_workers_Women_OTH (sum) total_days_Men_SC (sum) total_amount_Men_SC (sum) num_workers_Men_SC (sum) total_days_Women_SC (sum) total_amount_Women_SC (sum) num_workers_Women_SC (sum) total_days_Men_ST (sum) total_amount_Men_ST (sum) num_workers_Men_ST (sum) total_days_Women_ST (sum) total_amount_Women_ST (sum) num_workers_Women_ST (sum) num_hhs_BC (sum) num_hhs_Min (sum) num_hhs_OTH (sum) num_hhs_SC (sum) num_hhs_ST (sum) num_3200_payments_BC (sum) num_3200_payments_Min (sum) num_3200_payments_OTH (sum) num_3200_payments_SC (sum) num_3200_payments_ST, by(nrega_district_id nrega_mandal_id nrega_panchayat_id)

rename nrega_district_id district_id
rename nrega_mandal_id mandal_id
rename nrega_panchayat_id panchayat_id
sort district_id mandal_id panchayat_id

* drop the panchayats which I screwed up
sort district_id mandal_id panchayat_id
merge district_id mandal_id panchayat_id using "$extra\screwed_up_panchayats.dta" 
tab _merge
drop if _merge == 3
drop _merge



* create NREGA totals 
egen num_hhs = rowtotal(num_hhs*)
egen total_days = rowtotal(total_days*)
egen num_workers = rowtotal(num_workers*)
egen total_amount  = rowtotal(total_amount*)

* create NREGA totals by group
foreach group in "Men" "Women" "BC" "OTH" "SC" "ST" {
	egen total_days_`group' = rowtotal(total_days*`group'*)
	egen total_amount_`group' = rowtotal(total_amount*`group'*)
	egen num_workers_`group' = rowtotal(num_workers*`group'*)
	gen avg_wage_`group' = total_amount_`group' / total_days_`group'
	gen avg_days_`group' = total_days_`group' / num_workers_`group'
	gen prop_`group' = num_workers_`group' / num_workers
}


sort district_id mandal_id panchayat_id
save "$output\NREGA_panchayat_level.dta", replace



