/*
Purpose: Create dataset of nrega mandal level statistics by season
Files Used: mandal_stats_by_month
Files Created: nrega_mandal_level_by_season
Notes: 
*/


* set paths
macro drop all
global input = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\NREGA\Raw\Mandal level"
global output = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Temp"
global extra = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Extra"
set more off

use "$input\mandal_stats_by_month.dta", clear

****** UNCOMMENT FOLLOWING LINE ONLY IF YOU WANT TO USE INDIRAMMA DATA! *****
* use "$input\mandal_3200_stats_by_month.dta", clear

gen season = -999
replace season = 0 if month == 12 | (month >=1 & month <=5)
replace season = 1 if month >= 6 & month <=11
replace year = year + 1 if month == 12
drop if year > 2008 | year < 2006


collapse (sum) total_days (sum) total_amount (sum) num_workers, by(district_id mandal_id year season)
rename district_id nrega_district_id
sort nrega_district_id 
merge nrega_district_id using "$extra\district_rollout_stages.dta"
tab _merge 
drop _merge 
keep if rollout ==1
rename nrega_district_id district_id

sort district_id mandal_id year season
save "$output\nrega_mandal_level_by_season.dta", replace


