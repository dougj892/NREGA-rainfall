Organization of data and do files
===============================
I’ve included some notes on how the data in this archive is organized.  Please note that data and docs (Word, Excel, etc.) are not tracked in the repository. 

* The sub-folders “NREGA”, “BPL Census”, “MPTC”, “Rainfall”, and “Reservations” contains raw and cleaned versions of the original datasets.
* Everything in the “NREGA\raw” folder has been extracted from the SQL Server database.  Instructions on how to extract this data are included in the “NREGA\raw” folder
* Folders with “analysis” at the end include do files and stuff for specific lines of analysis.  Within these folders, final analysis is performed on the single file in the “clean” folder.  Output from the analysis is stored in the “graphs” and “regression tables” folders.
* Do files which create new Stata files are named the same as the Stata files they create but have “create” at the end of the name.
* Everything required to replicate the results in the papers from scratch using the raw data is in here except for a few things:
* I haven’t included the stuff related to Indiramma payments (the last regression files in the rainfall paper)
* I haven’t included all the do files I used to create the file “NREGA-mptc-census_panchayat_level_manually_created”.  This got really messy and there were a lot of manual steps involved.  
