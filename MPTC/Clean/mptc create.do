/*
Purpose: Consolidate various mptc district files and standardize spellings of parties
Files Used: all of the mptc district level files
Files Created: mptc
Notes: 
*/


* set paths
macro drop all
global input = "F:\NREGA\Data - reorganized\MPTC\Raw"
global output = "F:\NREGA\Data - reorganized\MPTC\Clean"
set more off



set more off
cd "$input"
clear
gen district_name2 = ""
gen mptc_mandal_name = ""
gen mptc_const = "" 
gen candidate = ""
gen party = ""
gen cand_votes = ""
save mptc_consolidated_temp, replace

foreach district in "Adilabad" "Ananthapur" "Chittoor" "East_Godavari" "Guntur" "Kadapa" "Karimnagar" "Khammam" "Krishna" "Kurnool" "Mahabubnagar" "Medak" "Nalgonda" "Nizamabad" "Prakasam" "Ranga_Reddy" "Srikakulam"  "Visakhapatnam" "Vizianagaram" "Warangal" "West_Godavari" {
	use `district', clear
	disp as error "Doing stuff for `district':"
	replace mptc_const = trim(mptc_const)
	replace mptc_const = "" if mptc_const == "-DO-" | mptc_const == "-do-" | mptc_const == `"""'
	foreach var in mptc_mandal_name mptc_const {
		replace `var' = `var'[_n-1] if `var' == ""
	}
	capture confirm string variable invalid
	if !_rc {
		destring invalid, replace force
	}
	replace invalid = 0 if invalid == .
	capture drop district_name2
	capture confirm string variable cand_votes
	if _rc {
		capture generate dummy = string(cand_votes)
		drop cand_votes
		rename dummy cand_votes
	}
	generate district_name2 = "`district'"
	drop if candidate == ""
	bysort district mptc_mandal mptc_const: egen invalid2 = max(invalid)
	keep district_name2 mptc_mandal_name mptc_const candidate party cand_votes invalid2 winner
	tempfile temp
	save `temp'
	use mptc_consolidated_temp, clear
	append using `temp'
	save mptc_consolidated_temp, replace
}

* STANDARDIZE PARTY NAMES *
replace party = trim(party)
drop if party == "8"
drop if party == "9"
drop if strmatch(party, "Party Aff*")
replace party ="AIMIM" if party == "A.I.M.I.M"
replace party ="BC" if party == "B.C.UNITED FRONT"
replace party ="BJP" if party == "B.J.P"
replace party ="BJP" if party == "B.J.P."
replace party ="BJP" if party == "B.JP"
replace party ="BSP" if party == "B.S.P"
replace party ="BSP" if party == "B.S.P."
replace party ="BC" if party == "BC"
replace party ="BJP" if party == "Bharatiya Janata Party"
replace party ="BJP" if party == "BJP"
replace party ="BSP" if party == "BSP"
replace party ="CPI" if party == "C P I"
replace party ="CPI (M)" if party == "C P I  ( M )"
replace party ="CPI (M)" if party == "C P I (M)"
replace party ="CPI" if party == "C.P.I"
replace party ="CPI (M)" if party == "C.P.I (M)"
replace party ="CPI (M)" if party == "C.P.I(M)"
replace party ="CPI (M)" if party == "C.P.I-(M)"
replace party ="CPI (M)" if party == "C.P.I,(M)"
replace party ="CPI" if party == "C.P.I."
replace party ="CPI (M)" if party == "C.P.I. (M)"
replace party ="CPI (M)" if party == "C.P.I.(M)"
replace party ="CPI (M)" if party == "C.P.I.M"
replace party ="CPI (M)" if party == "C.P.M"
replace party ="CPI (M)" if party == "C.P.M."
replace party ="CPI (M)" if party == "CIP(M)"
replace party ="INC" if party == "CONG"
replace party ="INC" if party == "Cong.I"
replace party ="INC" if party == "Cong.I"
replace party ="INC" if party == "Congress"
replace party ="INC" if party == "Congress-1"
replace party ="INC" if party == "Congress-I"
replace party ="INC" if party == "Congresss"
replace party ="INC" if party == "Contress"
replace party ="INC" if party == "Coongress"
replace party ="CPI" if party == "CPI"
replace party ="CPI" if party == "CPI"
replace party ="CPI (M)" if party == "CPI ( M )"
replace party ="CPI (M)" if party == "CPI (M)"
replace party ="CPI (ML)" if party == "CPI (ML)"
replace party ="CPI (ML)" if party == "CPI (ML)(L)"
replace party ="CPI (M)" if party == "CPI M"
replace party ="CPI (M)" if party == "CPI M"
replace party ="CPI (M)" if party == "CPI(M)"
replace party ="CPI (M)" if party == "CPI(M)"
replace party ="CPI (M)" if party == "CPI(m)"
replace party ="CPI (M)" if party == "CPI-(M)"
replace party ="CPI (ML)" if party == "CPI(ML)"
replace party ="CPI (ML)" if party == "CPI(ML)LIB"
replace party ="CPI (M)" if party == "CPIM"
replace party ="CPI (M)" if party == "CPI-M"
replace party ="CPI (ML)" if party == "CPIML"
replace party ="CPI (M)" if party == "CPM"
replace party ="INC" if party == "I N C"
replace party ="INC" if party == "I.N.C"
replace party ="INC" if party == "I.N.C."
replace party ="INC" if party == "I.N.Congress"
replace party ="IND" if party == "I.N.D.P"
replace party ="INC" if party == "IINC"
replace party ="INC" if party == "IN C"
replace party ="INC" if party == "INC"
replace party ="INC" if party == "INC"
replace party ="IND" if party == "IND"
replace party ="IND" if party == "IND"
replace party ="IND" if party == "Ind"
replace party ="IND" if party == "IND (Aero Plane)"
replace party ="IND" if party == "IND (Axe)"
replace party ="IND" if party == "IND (Goddali)"
replace party ="IND" if party == "IND (Iron safe)"
replace party ="IND" if party == "IND (Vimanam)"
replace party ="IND" if party == "Indendepent"
replace party ="IND" if party == "INDEP"
replace party ="IND" if party == "Indep"
replace party ="IND" if party == "Indepandance"
replace party ="IND" if party == "Independent"
replace party ="IND" if party == "INDEPENDENT"
replace party ="IND" if party == "Independent"
replace party ="IND" if party == "Independet"
replace party ="IND" if party == "Independnet"
replace party ="IND" if party == "INDI"
replace party ="IND" if party == "Indi.,"
replace party ="IND" if party == "Indipend"
replace party ="IND" if party == "Indipendant"
replace party ="IND" if party == "Indipenden"
replace party ="IND" if party == "INDIPENDENT"
replace party ="IND" if party == "Indipendent"
replace party ="IND" if party == "Indipendent."
replace party ="IND" if party == "Indipendents"
replace party ="IND" if party == "Indipenditent"
replace party ="IND" if party == "INDIPENTENT"
replace party ="IND" if party == "INDP"
replace party ="IND" if party == "Indp("
replace party ="IND" if party == "INDP."
replace party ="IND" if party == "Indp."
replace party ="IND" if party == "Inepenedent"
replace party ="IND" if party == "Inidpendent"
replace party ="IND" if party == "Inndependent"
replace party ="TDP" if party == "T D P"
replace party ="TRS" if party == "T R S"
replace party ="TDP" if party == "T..D.P."
replace party ="TDP" if party == "T.D :P"
replace party ="TDP" if party == "T.D.P"
replace party ="TDP" if party == "T.D.P."
replace party ="TDP" if party == "T.DP"
replace party ="TRS" if party == "T.R.S"
replace party ="TRS" if party == "T.R.S."
replace party ="TDP" if party == "TDP"
replace party ="TDP" if party == "TDP"
replace party ="TRS" if party == "Telangana Rashta Samithi"
replace party ="TDP" if party == "Telugudesham"
replace party ="TDP" if party == "Telugudesham Party"
replace party ="TDP" if party == "Telugudesham party"
replace party ="TRS" if party == "TRS"

replace party = "OTH" if party != "INC"  & party != "TDP" & party != "IND" & party != "BJP" & party != "CPI (M)" & party != "TRS" & party != "CPI" & party != "BSP"


* DESTRING CAND_VOTES *
destring cand_votes, replace force
gen dummy =1
bysort district_name2 mptc_mandal_name mptc_const: egen num_cands = count(dummy)
drop dummy
replace cand_votes = 0 if cand_votes ==. & num_cands >1

duplicates drop
sort district_name2 mptc_mandal_name mptc_const

* GENERATE VARIABLES FOR ANALYSIS 
gen phase_one = 0
replace phase_one =1 if district == "Adilabad" | district == "Ananthapur" | district == "Chittoor" | district == "Kadapa" | district == "Karimnagar" | district == "Khammam"  | district == "Mahabubnagar"  | district == "Medak"  | district == "Nalgonda"  | district == "Nizamabad"  | district == "Ranga_Reddy"  | district == "Vizianagaram"  | district == "Warangal"

sort district mptc_mandal mptc_const
egen unique_mptc_id = group(district mptc_mandal mptc_const)
gen neg_votes = -cand_votes
sort unique_mptc_id neg_votes
by unique_mptc_id: gen won = (-neg_votes == -neg_votes[1])
by unique_mptc_id: egen num_winners = sum(won)
replace won = 0 if num_winners > 1 & candidate != winner
drop if num_winners != 1


* the following line generates a variable which is equal to the share of votes won by the Congress candidate minus the share of votes
* won by the winner, or, in the case that the Congress candidate won, the share of votes that was won by the runner up
sort unique_mptc_id neg_votes
by unique_mptc_id: egen total_votes = sum(cand_votes)
generate share_votes = cand_votes / total_votes
by unique_mptc_id: generate tmp_congress_margin = share_votes - share_votes[1+(_n==1)] if party == "INC"
by unique_mptc_id: egen congress_margin = max(tmp_congress_margin)
by unique_mptc_id: replace congress_margin = -share_votes[1] if congress_margin ==.
* for cases where there was only one candidate, set the margin of victor equal to 1 or -1 depending on whether Congress was the sole candidate 
replace congress_margin = 1 if congress_margin ==. & party == "INC"
replace congress_margin = -1 if congress_margin ==.


duplicates drop
generate priority = 0
replace priority = 1 if phase_one & abs(congress_margin) < .02

gen congress_win = 0
replace congress_win = 1 if congress_margin > 0

compress 

cd "$output"
save mptc, replace




