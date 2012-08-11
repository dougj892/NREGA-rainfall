/*
Purpose: Append yearly rainfall files
Files Used: rainfall files for each year
Files Created: rainfall
Notes: 
*/


* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\Rainfall\Raw"
global output = "F:\NREGA\Data - reorganized\Rainfall\Clean"
set more off



cd "$input"
use Rainfall-2001
foreach file in  "Rainfall-2002" "Rainfall-2003" "Rainfall-2004" "Rainfall-2005" "Rainfall-2006" "Rainfall-2007" "Rainfall-2008" {
	append using `file'
}

generate year = year(rdate)
generate month = month(rdate)
generate day = day(rdate)

destring dcode, replace force
destring mcode, replace force
drop if dcode ==. | mcode ==.

cd "$output"
save rainfall, replace


