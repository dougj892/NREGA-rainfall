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
set more off


use "$input\nrega-rainfall-census_mandal_level.dta", clear
keep if season == 0

egen unique_mandal_id = group(nrega_district_id nrega_mandal_id)
xtset unique_mandal_id year

generate amount_per_worker = total_amount / tot_work_p
generate log_amount_per_worker = ln(amount_per_worker)


* Regressions and parameter test for amount per worker and log amount per worker with 2006 data included
xi: xtreg amount_per_worker early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag i.year, fe robust
estimates store amount_pc_2006
testparm early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag

xi: xtreg log_amount_per_worker early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag i.year, fe robust
estimates store log_amount_pc_2006
testparm early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag


* Regressions and parameter test for amount per worker and log amount per worker with 2006 data not included
drop if year == 2006
xi: xtreg amount_per_worker early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag i.year, fe robust
estimates store amount_pc
testparm early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag
predict amount_pc_hat_full

* generate predicted values from a regression of amount per worker in mandal and year dummies
* so that i can determine how much of the change in per capita wages can be attributed to 
* rainfall related factors.
xi: xtreg amount_per_worker i.year, fe robust
predict amount_pc_hat

xi: xtreg log_amount_per_worker early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag i.year, fe robust
estimates store log_amount_pc
testparm early_monsoon late_monsoon dev_num_days_lag excess_rain_lag deficit_rain_lag


generate amount_pc_dif = (amount_pc_hat_full - amount_pc_hat)
label variable amount_pc_dif "Change in Wages per Worker Explained by Rainfall"

hist amount_pc_dif, by(year) title("Dist of Amount in Wage Change Explained by Rain") saving("$graphs\Hist of Amount in Wage Change Explained by Rain", replace)
distplot  amount_pc_dif, by(year) saving("$graphs\CDF of Amount in Wage Change Explained by Rain", replace)


estout amount_pc_2006 log_amount_pc_2006 amount_pc log_amount_pc using "$tables\rainfall_regressions.txt", cells(b(star fmt(%9.3f)) p(par fmt(%9.8f)))  stats(r2) replace

keep nrega_district_id nrega_mandal_id amount_per_worker year
reshape wide amount_per_worker, i(nrega_district_id nrega_mandal_id) j(year)

scatter  amount_per_worker2008 amount_per_worker2007 if amount_per_worker2008 <= 2000 & amount_per_worker2007 <= 1000, msize(tiny) title("Lean Season Wages per Capita in 2008 vs 2007*") saving("$graphs\Scatter of 2008 wages per capita vs 2007", replace) note("*Sub-districts with greater than 1000 rs wages per worker in 2007" "or 2000 rs per worker in 2008 excluded") 



