/*
Purpose: Create dataset of rainfall variables by year and season
Files Used: rainfall
Files Created: rainfall_coded
Notes: 
*/


* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\Rainfall\Clean"
global output = "F:\NREGA\Data - reorganized\Rainfall analysis\Temp"
set more off



use "$input\rainfall.dta", clear

local rain_threshold 15
local start_month 6
local moving_total_thresh 70


generate moving_total = rfall[_n+1]*(rdate[_n+1]<=rdate[_n]+14) ///
	+ rfall[_n+2]*(rdate[_n+2]<=rdate[_n]+14) ///
	+ rfall[_n+3]*(rdate[_n+3]<=rdate[_n]+14) ///
	+ rfall[_n+4]*(rdate[_n+4]<=rdate[_n]+14) ///
	+ rfall[_n+5]*(rdate[_n+5]<=rdate[_n]+14) ///
	+ rfall[_n+6]*(rdate[_n+6]<=rdate[_n]+14) ///
	+ rfall[_n+7]*(rdate[_n+7]<=rdate[_n]+14) ///
	+ rfall[_n+8]*(rdate[_n+8]<=rdate[_n]+14) ///
	+ rfall[_n+9]*(rdate[_n+9]<=rdate[_n]+14) ///
	+ rfall[_n+10]*(rdate[_n+10]<=rdate[_n]+14) ///
	+ rfall[_n+11]*(rdate[_n+11]<=rdate[_n]+14) ///
	+ rfall[_n+12]*(rdate[_n+12]<=rdate[_n]+14) ///
	+ rfall[_n+13]*(rdate[_n+13]<=rdate[_n]+14) ///
	+ rfall[_n+14]*(rdate[_n+14]<=rdate[_n]+14) ///

	
generate monsoon_day = .
replace monsoon_day = 1 if rfall >= `rain_threshold' & month >= `start_month' & moving_total >= `moving_total_thresh'

collapse (first) monsoon_start = rdate if monsoon_day ==1, by(dcode mcode year)

replace monsoon_start = monsoon_start - mdy(1,1,year)
bysort dcode mcode: egen median_monsoon_start = median(monsoon_start)
generate dev_monsoon_start = (monsoon_start - median_monsoon_start) 
bysort dcode mcode: egen std_dev_monsoon_start = sd(monsoon_start)
generate dev_monsoon_start_std = dev_monsoon_start / std_dev_monsoon_start

generate early_monsoon = 0
* replace early_monsoon = dev_monsoon_start_std if dev_monsoon_start_std > 0
replace early_monsoon = dev_monsoon_start_std if dev_monsoon_start > 0
generate late_monsoon = 0
* replace late_monsoon = dev_monsoon_start_std if dev_monsoon_start_std < 0
replace late_monsoon = -dev_monsoon_start_std if dev_monsoon_start < 0

tempfile temp
sort dcode mcode year
save `temp'

use "$input\rainfall.dta", clear

* generate variable for wet and dry seasons
gen season = -999
replace season = 0 if month == 12 | (month >=1 & month <=5)
replace season = 1 if month >= 6 & month <=11
replace year = year + 1 if month == 12
drop if year < 2000 | year > 2008

* generate var for average rainfall in each mandal in each season
collapse (mean) avg_rain = rfall (count) num_days_rain = rfall, by(dcode mcode year season)
bysort dcode mcode season: egen median_of_avg_rain = median(avg_rain)
* generate deviation_rain_std = (avg_rain - median_of_avg_rain) / median_of_avg_rain
generate deviation_rain_std = avg_rain - median_of_avg_rain
generate excess_rain = 0
replace excess_rain = deviation_rain_std if deviation_rain_std > 0
generate deficit_rain = 0
replace deficit_rain = -deviation_rain_std if deviation_rain_std < 0

bysort dcode mcode season: egen median_of_num_days = median(num_days_rain)
generate dev_num_days = num_days_rain - median_of_num_days

sort dcode mcode year season
generate excess_rain_lag = excess_rain[_n-1]
generate deficit_rain_lag = deficit_rain[_n-1]
generate dev_num_days_lag = dev_num_days[_n-1]


sort dcode mcode year
merge dcode mcode year using `temp'
tab _merge 
drop _merge

sort dcode mcode year season
foreach var of varlist early_monsoon late_monsoon dev_monsoon_start_std {
	replace `var' = `var'[_n-1] if season == 0
}	

rename dcode district_id
rename mcode mandal_id
drop if year > 2008 | year < 2006
sort district_id mandal_id year season


save "$output\rainfall_coded.dta", replace




