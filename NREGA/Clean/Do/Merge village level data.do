* Reshape and merge the three village level datasets

use "F:\NREGA\Data\Muster roll data - village level\Raw\totals_by_village_caste_sex.dta", clear
drop if distr == 0
replace sex = "_Men_" if sex =="M"
replace sex = "_Women_" if sex =="F"
reshape wide total_days total_amount num_workers, i(district_id mandal_id panchayat_id village_id caste) j(sex) string
reshape wide total_days_Men_ total_amount_Men_ num_workers_Men_ total_days_Women_ total_amount_Women_ num_workers_Women_, i(district_id mandal_id panchayat_id village_id ) j(caste) string

tempfile temp1
sort district_id mandal_id panchayat_id village_id
save `temp1'

use "F:\NREGA\Data\Muster roll data - village level\Raw\num_hhs_per_village_caste.dta", clear
drop if distr == 0
replace caste = "_" + caste
reshape wide num_hhs, i(district_id mandal_id panchayat_id village_id) j(caste) string

tempfile temp2
sort district_id mandal_id panchayat_id village_id
save `temp2'

* merge with 3200 data
use "F:\NREGA\Data\Muster roll data - village level\Raw\3200.dta", clear
drop if distr == 0
* drop sum_3200_payments to keep things simple
drop sum_3200_payments
replace caste = "OTH" if caste == "OT"
replace caste  = "Min" if caste  == "Mi"
replace caste = "_" + caste
collapse (sum) num_3200_payments , by( district_id mandal_id panchayat_id village_id caste )
reshape wide num_3200_payments , i( district_id mandal_id panchayat_id village_id ) j( caste ) string

tempfile temp3
sort district_id mandal_id panchayat_id village_id
save `temp3'



use "F:\NREGA\Data\Muster roll data - village level\Raw\num_worksites_per_village.dta", clear
drop if distr == 0
sort district_id mandal_id panchayat_id village_id

merge district_id mandal_id panchayat_id village_id using `temp1'
tab _merge
drop _merge

sort district_id mandal_id panchayat_id village_id
merge district_id mandal_id panchayat_id village_id using `temp2'
tab _merge
drop _merge

sort district_id mandal_id panchayat_id village_id
merge district_id mandal_id panchayat_id village_id using `temp3'
tab _merge
drop _merge


* merge with census data
rename district_id nrega_district_id 
rename mandal_id nrega_mandal_id 	
rename panchayat_id nrega_panchayat_id 
rename village_id nrega_village_id

/* sort nrega_district_id nrega_mandal_id nrega_panchayat_id nrega_village_id
merge nrega_district_id nrega_mandal_id nrega_panchayat_id nrega_village_id using "F:\NREGA\Data\Muster roll data - village level\Raw\VillageCrossMatch.dta", sort
tab _merge
keep if _merge == 3
drop _merge

sort census_district_id census_mandal_id census_village_id
merge census_district_id census_mandal_id census_village_id using "F:\NREGA\Data\Census Data\AP village directory data.dta"
tab _merge
keep if _merge ==3
drop _merge
*/

* merge with rollout stages file
sort nrega_district_id
merge nrega_district_id using "F:\NREGA\Data\Extra Data\district_rollout_stages.dta"
tab _merge 
drop _merge

compress
save "F:\NREGA\Data\Muster roll data - village level\Clean\village_stats_no_census_data.dta", replace



