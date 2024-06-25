/*******************************************************************************

		CREATE TEMPLATE TO LABEL PATHWAY DATA		
				
			This dofile takes you through the steps to labeling your student
			pathway data in a way that will make it convenient to display.
				
*******************************************************************************/

/* 
	This dofile creates a pre-filled template of student pathways for 
	you to define labels for, and saves it under 2_data-toolkit. 
	
	The template consists of the list of pathways included either in your PDP 
	AR files (under the Program of Study variable) or in the student pathway 
	information you have filled out in the previous step. 
	
	For each unique pathway present in your data, it exports the ProgramofStudy
	number. It also creates a unique ID for each pathway in a numeric sequence
	starting from 1, which will make it easier to display pathways side by 
	side in graphs.
	
	For each pathway, you should fill in the ProgramofStudy_Label column with 
	the name of the pathway you want displayed on your graphs.
				
*/


*	==========================================
*	PART 1. - Set Up 
*	==========================================

* Stata set up
set more off

* INSTRUCTIONS: Define machine-specific file path 

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

* Load the paramaters 
quietly { //quietly ensures the code is run in the background without displaying any output
	do "$root/1.Add-PDP-Data.do"
	do "$root/2.3.Add-Pathway-Data.do"
	do "$root/3.Define-Institution-Parameters.do"
}

*	==========================================
*	PART 2. - Create a list of unique
*		pathways present in PDP data
*	==========================================

* Load PDP AR cohort file
import excel "$root/1_data-pdp/$arcohortfile", firstrow clear

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

* Add in Student Pathways entered from the Excel template

preserve 
	* INSTRUCTIONS: change the name below to the name of your file with student pathways (including extension)
	import excel using "$root/2_data-toolkit/insert-name-of-student-pathway-file.xlsx", firstrow clear
	
	* keep only the pathway variable
		/* Note : capture ignores a line of code if it returns an error.
			Here, if the pathway file is at the Year level, line 77 will 
			return an error and be ignored; and vice versa, if the pathway
			file is at the Term level, line 78 will return an error and be 
			ignored. */
	capture keep ProgramofStudyTerm_input
	capture keep ProgramofStudyYear_input
	
	* reshape at the unique program of study value 
	duplicates drop
	
	* rename 
	capture rename ProgramofStudyTerm_input program 
	capture rename ProgramofStudyYear_input program 		
	
	* save as temp datafile for merging back with the other dataset
	tempfile userpathways
	save `userpathways'
restore		



*	==========================================
*	PART 4. - Combine Lists of Pathways
*	==========================================

* Load pathway lists
use `pdppathways', clear
capture append using `userpathways'

* Drop duplicates
duplicates drop

* Drop missing values 
drop if program == .

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

export excel using "$root/2_data-toolkit/ProgramofStudy_Label_Template.xlsx", first(variable) replace	

	