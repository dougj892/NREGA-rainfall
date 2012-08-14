/*
Purpose: Create tables of rainfall statistics
Files Used: nrega-rainfall-census_mandal_level
Files Created: none
Notes: 
*/


* set paths
macro drop all
global input = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Clean"
global tables = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Regression tables"
global graphs = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Rainfall analysis\Graphs"
global extra = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\Extra"
set more off

use "$input\nrega-rainfall-census_mandal_level.dta", clear

* generate single variable for excess / deficit
generate rainfall_lag =  excess_rain_lag
replace rainfall_lag = -deficit_rain_lag if rainfall_lag == 0

cd "$graphs"
hist rainfall_lag if rainfall_lag <= 50 & rainfall_lag >= -50, by(year) saving("hist of rainfall lag", replace)
hist  dev_num_days_lag if  dev_num_days_lag >= -20 &  dev_num_days_lag <= 20, by (year) saving("hist of days rain lag", replace)


cd "$tables"

