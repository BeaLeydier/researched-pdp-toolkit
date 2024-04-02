

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

* Parameter : Display Summers as separate terms y/n
global summer "no"

	/*NOTE : Add user centered explanation.*/

*	==========================================
*	PART 2. - Generate Unique Student List  
*	==========================================

import excel "$root/1_data-pdp/T Draft Cohort_analysis_ready_file_template_4-7-23", firstrow clear

* Remove records without a StudentID
drop if StudentID == .

* Keep student information
keep FirstName MiddleName LastName StudentID Cohort CohortTerm

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
	
*	==========================================
*	PART 3. - Label Terms for Each Student  
*	==========================================
	
* Create a numeric indicator for term to sort terms in chronological order
label define terms 1 "SPRING" 2 "SUMMER" 3 "FALL"
encode CohortTerm, gen(CohortTerm_Num) label(terms)
order CohortTerm_Num, after(CohortTerm)

* Derive Year from Cohort
gen CohortYear = regexs(0) if regexm(Cohort, "20[0-9][0-9]")
	/* NOTE: alternative code
		gen CohortYear = substr(Cohort, 1, 4)
	*/
	
* Define Term 1
gen StudentTerm1 = CohortYear + "_" + string(CohortTerm_Num) + "." + CohortTerm

* Define Subsequent terms 

*** If the institution wants to plot SPRING - FALL terms (default)

if "$summer" == "no" {

	forvalues term = 2/8 {

	local prev = `term' - 1

	gen prevyear = regexs(0) if regexm(StudentTerm`prev', "20[0-9][0-9]") //extract year
	destring(prevyear), replace
	gen prevterm = substr(StudentTerm`prev', strpos(StudentTerm`prev', "_") + 1, 1) //extract term (1 character after _)

	gen prevyearplusone = prevyear + 1

	gen StudentTerm`term' =  string(prevyearplusone) + "_" + "1." + "SPRING" if prevterm == "3" //Spring of Year+1 follows Fall
	replace StudentTerm`term' = string(prevyear) + "_" + "3." + "FALL" if prevterm == "2" //Fall follows Summer
	replace StudentTerm`term' = string(prevyear) + "_" + "3." + "FALL" if prevterm == "1" //Fall follows Spring

	drop prevyear prevterm prevyearplusone

		
	}

}

*** If the institution wants to plot SPRING - SUMMER - FALL terms

if "$summer" == "yes" {
    
	forvalues term = 2/8 {

	local prev = `term' - 1

	gen prevyear = regexs(0) if regexm(StudentTerm`prev', "20[0-9][0-9]") //extract year
	destring(prevyear), replace
	gen prevterm = substr(StudentTerm`prev', strpos(StudentTerm`prev', "_") + 1, 1) //extract term (1 character after _)

	gen prevyearplusone = prevyear + 1

	gen StudentTerm`term' =  string(prevyearplusone) + "_" + "1." + "SPRING" if prevterm == "3" // Spring of Year+1 follows Fall
	replace StudentTerm`term' = string(prevyear) + "_" + "3." + "FALL" if prevterm == "2" //Fall follows Summer
	replace StudentTerm`term' = string(prevyear) + "_" + "2." + "SUMMER" if prevterm == "1" //Summer follows Spring

	drop prevyear prevterm prevyearplusone

		
	}

}



*	==========================================
*	PART 4. - Add Variables for Input
*	==========================================	
	
* Add the pathway variable information
gen ProgramofStudyTerm1_input = ""
gen ProgramofStudyTerm2_input = ""
gen ProgramofStudyTerm3_input = ""
gen ProgramofStudyTerm4_input = ""
gen ProgramofStudyTerm5_input = ""
gen ProgramofStudyTerm6_input = ""
gen ProgramofStudyTerm7_input = ""
gen ProgramofStudyTerm8_input = ""

* Export student list
export excel "$root/2_data-toolkit/Student_Pathways_Template.xlsx", firstrow(var) replace


*	==========================================
*	PART 5. - Fill
*	==========================================

/* Insert instructions on how to open the Excel file we generated 
	and fill the student pathway information. */

