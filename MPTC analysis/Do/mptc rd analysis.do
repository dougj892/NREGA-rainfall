/*
Purpose: Perform rd analysis on mptc data
Files Used: NREGA-mptc-census_panchayat_level_manually_created
Files Created: none
Notes: You must download rdob.ado.  This ado file is not available via findit.  You must go
to Guido Imbens webpage and download it from there. This performs RD analysis using local
linear regression and an optimal kernel bandwidth calculated using a procedure devised by 
Imbens and Kalyanaraman.
*/


* set paths
macro drop all
global input = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\MPTC analysis\Clean"
global graphs = "\\betfilesrv02\redirected$\johnsonde\Documents\NREGA_main_folder_backup_280809\Data - reorganized\MPTC analysis\Graphs"
set more off

use "$input\NREGA-mptc-census_panchayat_level_manually_created.dta", clear
* RD analysis with full dataset for our two outcomes variables
/*
rdob amount_pc cong_win_margin, c(0)
rdob log_amount_pc cong_win_margin, c(0)

* RD analysis with only mptcs in mandals in which the MPP is Congress for our two outcomes variables
keep if congress_majority
rdob log_amount_pc cong_win_margin, c(0)
rdob amount_pc cong_win_margin, c(0)

* RD analysis with only mptcs in mandals in which the MPP is NOT Congress for our two outcomes variables
use "$input\NREGA-mptc-census_panchayat_level_manually_created.dta", clear
keep if !congress_majority
rdob log_amount_pc cong_win_margin, c(0)
rdob amount_pc cong_win_margin, c(0)
*/


* generate graphs 
use "$input\NREGA-mptc-census_panchayat_level_manually_created.dta", clear
cd "$graphs"

graph twoway (scatter amount_pc cong_win_margin, msize(small)) (lowess amount_pc cong_win_margin if cong_win_margin < 0) (lowess amount_pc cong_win_margin if cong_win_margin >= 0) , saving("Amount per cap vs cong win margin", replace)

graph twoway (scatter log_amount_pc cong_win_margin, msize(small)) (lowess log_amount_pc cong_win_margin if cong_win_margin < 0) (lowess log_amount_pc cong_win_margin if cong_win_margin >= 0), saving("Log amount per cap vs cong win margin", replace)

graph twoway (scatter log_amount_pc cong_win_margin if congress_majority, msize(small)) (lowess log_amount_pc cong_win_margin if cong_win_margin < 0 &  congress_majority) (lowess log_amount_pc cong_win_margin if cong_win_margin >= 0 &  congress_majority), saving("Log amount per cap vs cong win margin for cong majority", replace)


