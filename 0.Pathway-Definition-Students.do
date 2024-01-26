

/*******************************************************************************

		PATHWAY DEFINTION
		
		
		This file helps you define and load the pathways
		your students (as reported in the PDP) are in.
		
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

import excel "$root/1_data-pdp/AR-file_cohort.xlsx", firstrow clear

* Remove records without a StudentID
drop if StudentID == ""

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
gen PathwayID = ""
gen PathwayName = ""

* Export student list
export excel "$root/2_data-toolkit/Student_Pathways_Template.xlsx", firstrow(var)


*	==========================================
*	PART 3. - Fill
*	==========================================

/* Insert instructions on how to open the Excel file we generated 
	and fill the student pathway information. */


*	==========================================
*	PART 4. - Add the Student Pathway Information to the AR Cohort file
*	==========================================

import excel "$root/2_data-toolkit/Student_Pathways_Template_Filled.xlsx", firstrow clear

	/* Option to give some diagnostics on pathway info at this stage. */
	
preserve 
	import excel "$root/1_data-pdp/AR-file_cohort.xlsx", firstrow clear
	
	tempfile arcohort
	save `arcohort'
restore
	
merge 1:m StudentID using `arcohort', nogen
	

/* Note

	This dofile could be converted into an .ado file whereby the person
	just downloads a new Stata command, specifies the name/filepath
	for their AR file, for their filled template file, and generates it
	
	More or less scalable depending on how clean we think the StudentID
	data is
	
*/