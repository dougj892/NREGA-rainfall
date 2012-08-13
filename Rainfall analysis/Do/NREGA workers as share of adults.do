/*
Purpose: calculate total workers divided by total working population by year
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

* open dataset, merge with data on rainfed / irridate land, and xtset data
use "$input\nrega-rainfall-census_mandal_level.dta", clear

foreach i in 2006 2007 2008 {
	preserve
	keep if year == `i'
	disp as error "results for `i'"
	quietly sum num_workers
	scalar workers = r(sum)
	quietly sum tot_work_p
	scalar adults = r(sum)
	disp workers/adults
	restore
}
