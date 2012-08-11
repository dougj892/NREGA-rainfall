/*
Purpose: Perform rainfall analysis
Files Used: nrega-rainfall-census_mandal_level
Files Created: none
Notes: You must have estout and the estout ancillary files installed.
*/


* set paths
macro drop all
global input = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Clean"
global tables = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Regression tables"
global graphs = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Graphs"
global extra = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Extra"
set more off

* get stats on total rainfed / irrigated land area from village directory data
use "$extra\AP village directory data.dta", clear
rename dist_code census_district_id
rename thsil_code census_mandal_id
destring census_district_id, replace
destring census_mandal_id, replace
collapse (sum) total_irrigated=tot_irr total_rainfed=un_irr, by(census_district_id census_mandal_id)
tempfile temp
sort census_district_id census_mandal_id
save `temp'

* open dataset, merge with data on rainfed / irridate land, and xtset data
use "$input\nrega-rainfall-census_mandal_level.dta", clear
keep if season == 0
drop _merge
sort census_district_id census_mandal_id
merge census_district_id census_mandal_id using `temp'
egen unique_mandal_id = group(nrega_district_id nrega_mandal_id)
xtset unique_mandal_id year


**** generate variables (only some of which are used) *****
generate amount_per_worker = total_amount / tot_work_p
generate log_amount_per_worker = ln(amount_per_worker)
generate days_sq = dev_num_days_lag^2
generate days_cubed = dev_num_days_lag^3
generate deficit_sq = deficit_rain_lag^2
generate deficit_cubed = deficit_rain_lag^3
generate total_rainfall = excess_rain_lag
replace total_rainfall =  deficit_rain_lag if total_rainfall == 0
generate irrigated_to_rainfed = total_irrigated / total_rainfed
egen median_irr = pctile(irrigated_to_rainfed), p(50)
generate mostly_rainfed = (irrigated < median_irr)


* Create historgrams of average amount per worker
cd "$graphs"
* hist amount_per_worker if amount_per_worker < 1000 & year == 2006, by(year) saving("hist_amount_per_worker 2006", replace)
* hist amount_per_worker if amount_per_worker < 1000 & year != 2006, by(year) saving("hist_amount_per_worker wo 2006", replace)


*** 2006 INCLUDED
xtreg amount_per_worker dev_num_days_lag  deficit_rain_lag excess_rain_lag i.year, fe robust
estimates store amount

*** 2006 EXCLUDED
drop if year == 2006
xtreg amount_per_worker dev_num_days_lag  deficit_rain_lag excess_rain_lag i.year, fe robust
estimates store amount_2006_excluded


* dump using estout
cd "$tables"
estout amount amount_2006_excluded using "rainfall_regressions.txt", cells(b(star fmt(%9.3f)) p(par fmt(%9.8f)))  stats(r2) replace


* generate estimate of h1_hat
generate h1_hat = _b[dev_num_days_lag]*dev_num_days_lag + _b[deficit_rain_lag]*deficit_rain_lag + _b[excess_rain_lag]*excess_rain_lag
centile h1_hat, centile (10 25 75 90)

cd "$graphs"
* hist h1_hat, by(year) saving("empirical_dist_h1hat", replace)


* define program for bootstrapping estimates of the centiles of h1_hat
* bootstrap throws an error when using xtreg with xtset'ed data so used areg instead
capture program drop boot_centiles
program boot_centiles, rclass
	areg amount_per_worker dev_num_days_lag  deficit_rain_lag excess_rain_lag i.year, robust absorb(unique_mandal_id)
	capture drop h1_hat
	generate h1_hat = _b[dev_num_days_lag]*dev_num_days_lag + _b[deficit_rain_lag]*deficit_rain_lag + _b[excess_rain_lag]*excess_rain_lag
	centile h1_hat, centile(`0')
	return scalar cent = r(c_1) 
end

* run bootstrap program for each of several key centiles
xtset, clear
foreach i in 10 25 75 90 {
	bootstrap ratio=r(cent),rep(1000) seed(8675309) cluster(unique_mandal_id) dots: boot_centiles `i'
}



* replicate analysis with only most rainfed mandals
keep if mostly_rainfed
xtset unique_mandal_id year
xtreg amount_per_worker dev_num_days_lag  deficit_rain_lag excess_rain_lag i.year, fe robust
replace h1_hat = _b[dev_num_days_lag]*dev_num_days_lag + _b[deficit_rain_lag]*deficit_rain_lag + _b[excess_rain_lag]*excess_rain_lag
cd "$graphs"
* hist h1_hat, by(year) saving("empirical_dist_h1hat - rainfed mandals", replace)


