

/*******************************************************************************

		PATHWAY DEFINTION
		
		
		This file helps you define and load the pathways
		your students (as reported in the PDP) are in on a
		term by term basis.
		
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
*	PART 2. - Generate Student List  
*	==========================================

import excel "$root/1_data-pdp/T Draft Cohort_analysis_ready_file_template_4-7-23", firstrow clear

* Remove records without a StudentID
drop if StudentID == .

* Keep student information
keep FirstName MiddleName LastName StudentID 

* Generate unique student records
duplicates drop StudentID, force

* Check that student ID is a unique identifier of records
unique StudentID
	/*Note: this will return an error if StudentID doesn't uniquely identify record.
	
	Discuss with Harvard how much we want to troubleshoot ahead of time, we could
	do some programming to anticipate issues like :
		- missing studentID
		- multiple rows with different name spellings
		
	Alternatively, we can force the uniqueness by StudentID above, at the risk of
	losing information.
	*/
	
* Add the pathway variable information
gen ProgramofStudyYear1_input = ""
gen ProgramofStudyYear2_input = ""
gen ProgramofStudyYear3_input = ""
gen ProgramofStudyYear4_input = ""

* Export student list
export excel "$root/2_data-toolkit/Student_Pathways_Template.xlsx", firstrow(var) replace


*	==========================================
*	PART 3. - Fill
*	==========================================

/* Insert instructions on how to open the Excel file we generated 
	and fill the student pathway information. */

