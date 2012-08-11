/*
Purpose: Perform reservations analysis
Files Used: NREGA-reservations_panchayat_level
Files Created: several graphs and regression tables
Notes: You must install estout and the estout ancillary files before running.  If you are using the 
cmp command you must install that as well.
*/


* set paths
macro drop all
estimates clear
global input = "F:\NREGA\Data - reorganized\Reservations analysis\Clean"
global tables = "F:\NREGA\Data - reorganized\Reservations analysis\Regression tables"
set more off



use "$input\NREGA-reservations_panchayat_level.dta", clear
* generate unique mandal id so that we can cluster errors at the mandal level in regression below
egen unique_mandal_id = group(district_id mandal_id)

gen segregation_inc = 1
replace segregation_inc =0 if segregation_index_caste ==.


regress segregation_index_caste gpsarpanchreservedfor_Women gpsarpanchreservedfor_BC gpsarpanchreservedfor_SC gpsarpanchreservedfor_ST pct_res_BC pct_res_mandal_BC pct_res_district_BC pct_res_SC pct_res_mandal_SC pct_res_district_SC  pct_res_ST pct_res_mandal_ST pct_res_district_ST, vce(cluster unique_mandal_id) noheader
estimates store segregation
regress prop_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC, vce(cluster unique_mandal_id) noheader
estimates store prop_BC
regress avg_days_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC, vce(cluster unique_mandal_id) noheader
estimates store avg_days_BC
regress avg_wage_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC, vce(cluster unique_mandal_id) noheader
estimates store avg_wage_BC
regress prop_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC, vce(cluster unique_mandal_id) noheader
estimates store prop_SC
regress avg_days_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC, vce(cluster unique_mandal_id) noheader
estimates store avg_days_SC
regress avg_wage_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC, vce(cluster unique_mandal_id) noheader
estimates store avg_wage_SC
regress prop_ST gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST, vce(cluster unique_mandal_id)noheader
estimates store prop_ST
regress avg_days_ST gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST, vce(cluster unique_mandal_id) noheader
estimates store avg_days_ST
regress avg_wage_ST gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST, vce(cluster unique_mandal_id) noheader
estimates store avg_wage_ST
regress segregation_index_sex gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store segregation_index_sex
regress prop_Women gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store prop_Women
regress avg_days_Women gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store avg_days_Women
regress avg_days_Men gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store avg_days_Men
regress avg_wage_Women gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store avg_wage_Women
regress avg_wage_Men gpsarpanchreservedfor_Women, vce(cluster unique_mandal_id) noheader
estimates store avg_wage_Men

estout *using "$tables\reservations_ind_regressions.txt", cells(b(star fmt(%9.3f)) p(par fmt(%9.8f)))  stats(r2) replace
 

sureg	(segregation_index_caste gpsarpanchreservedfor_Women gpsarpanchreservedfor_BC gpsarpanchreservedfor_SC gpsarpanchreservedfor_ST pct_res_BC pct_res_mandal_BC pct_res_district_BC pct_res_SC pct_res_mandal_SC pct_res_district_SC  pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(prop_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(avg_days_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(avg_wage_BC gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(prop_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(avg_days_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(avg_wage_SC gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(prop_ST = gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(avg_days_ST gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(avg_wage_ST gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///	
	(segregation_index_sex gpsarpanchreservedfor_Women) ///
	(prop_Women gpsarpanchreservedfor_Women) ///
	(avg_days_Women gpsarpanchreservedfor_Women) ///
	(avg_days_Men gpsarpanchreservedfor_Women) ///
	(avg_wage_Women gpsarpanchreservedfor_Women) ///
	(avg_wage_Men gpsarpanchreservedfor_Women) 

estimates store sureg_estimates
estout sureg_estimates using "$tables\reservations_sureg.txt", cells(b(star fmt(%9.3f)) p(par fmt(%9.8f)))  stats(r2) replace
 

/* The following commented out code is my first attempt at using David Roodman's cmp stata ado 
program to estimate these equations.  The syntax appears to be alright, but it takes forever to run.
(I have never gotten it to successfully complete.)  I think one of the major issues may be that there
is a high degree of collinearity in our the pct_res_mandal* and pct_res_district regressors though
I am not completely sure.  The help file for cmp contains tips and advice on how to get the 
maximum likelihood stuff to run more quickly.  */ 

/*
cmp	(segregation_index_caste = gpsarpanchreservedfor_Women gpsarpanchreservedfor_BC gpsarpanchreservedfor_SC gpsarpanchreservedfor_ST pct_res_BC pct_res_mandal_BC pct_res_district_BC pct_res_SC pct_res_mandal_SC pct_res_district_SC  pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(prop_BC = gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(avg_days_BC = gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(avg_wage_BC = gpsarpanchreservedfor_BC pct_res_BC pct_res_mandal_BC pct_res_district_BC) ///
	(prop_SC = gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(avg_days_SC = gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(avg_wage_SC = gpsarpanchreservedfor_SC pct_res_SC pct_res_mandal_SC pct_res_district_SC) ///
	(prop_ST = gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(avg_days_ST = gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///
	(avg_wage_ST = gpsarpanchreservedfor_ST pct_res_ST pct_res_mandal_ST pct_res_district_ST) ///	
	(segregation_index_sex = gpsarpanchreservedfor_Women) ///
	(prop_Women = gpsarpanchreservedfor_Women) ///
	(avg_days_Women = gpsarpanchreservedfor_Women) ///
	(avg_days_Men = gpsarpanchreservedfor_Women) ///
	(avg_wage_Women = gpsarpanchreservedfor_Women) ///
	(avg_wage_Men = gpsarpanchreservedfor_Women), ///
	indicators(segregation_inc 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1) vce(cluster unique_mandal_id) interactive

	
estimates store reservations_cmp
estout reservations_cmp using "F:\NREGA\Data\Graphs\reservations_cmp.txt", cells(b(star fmt(%9.3f)) p(par fmt(%9.8f)))  replace
*/


