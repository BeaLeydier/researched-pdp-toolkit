
/*******************************************************************************

		PATHWAY LABELING
		
		
		This file helps you define labels for all the pathways (programs of
		study) listed in your PDP data.
		
*******************************************************************************/

*	==========================================
*	PART 1. - Set Up 
*	==========================================

* Stata set up
set more off

* Define machine-specific file path 

if c(username)=="bl517" {
	global root "C:/Users/bl517/Documents/Github/researched-pdp-toolkit"
}
else if c(username)=="INSERT-MACHINE-USERNAME" {
	global root "INSERT MACHINE-SPECIFIC FILEPATH"
}
else {
	di as err "Please enter machine-specific path information"
	exit
}

*	==========================================
*	PART 2. - Create a list of unique
*		pathways present in PDP data
*	==========================================

* Load PDP AR cohort file
import excel "$root/1_data-pdp/T Draft Cohort_analysis_ready_file_template_4-7-23", firstrow clear

* Remove records without a StudentID
drop if StudentID == .

* Keep program of study variables
keep ProgramofStudyTerm1 ProgramofStudyYear1

* Reshape at the program of study unique value level
rename ProgramofStudyTerm1 program1
rename ProgramofStudyYear1 program2 
gen id = _n 
reshape long program, i(id) j(j)
drop id j

duplicates drop
drop if program == .

* Save temp file
tempfile pdppathways
save `pdppathways'

*	==========================================
*	PART 3. - Create a list of unique
*		pathways present in user-imputed data
*	==========================================

* Add in Pathway labels from the Excel template

if fileexists("$root/2_data-toolkit/Student_Pathways_Template_Filled.xlsx") {
	preserve 
		* update the name (and file path) of the xlsx file you just created with labels info.
		import excel using "$root/2_data-toolkit/Student_Pathways_Template_Filled.xlsx", firstrow clear
		
		* keep pathway variables
		keep ProgramofStudyTerm*_input
		
		* reshape at the unique program of study value 
		forvalues t=1/8 {
		    rename ProgramofStudyTerm`t'_input program`t'
		}
		gen id = _n
		reshape long program, i(id) j(j)
		drop id j
		duplicates drop
		
		* save as temp datafile for merging back with the other dataset
		tempfile userpathways
		save `userpathways'
	restore		
} 
else {
	dis as err "No user-entered pathway information at the student level."
}



*	==========================================
*	PART 4. - Combine Lists of Pathways
*	==========================================

* Load pathway lists
use `pdppathways', clear
append using `userpathways'

* Drop duplicates
duplicates drop

* Add ordered unique identifier for pathway
rename program ProgramofStudy
sort ProgramofStudy
gen ProgramofStudy_ID = _n

* Add label column to fill out
gen ProgramofStudy_Label = ""


*	==========================================
*	PART 3. - Export Data to Fill out
*	==========================================

* Reorder columns 
order ProgramofStudy_ID ProgramofStudy ProgramofStudy_Label, first

export excel using "$root/2_data-toolkit/ProgramofStudy_Template.xlsx", first(variable) replace	

	