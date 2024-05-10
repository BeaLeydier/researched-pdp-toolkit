
/*******************************************************************************

		SECTION 2 - Data Prep
		
		
		This file takes your PDP data and puts it in the format appropriate
		to run Section 2 of the Toolkit.
		
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
*	PART 2. - Load PDP data
*		Analysis ready COURSE file
*	==========================================

use "$root/2_data-toolkit/section1_student.dta", clear	

* Keep relevant data
keep StudentID pathway_y1 pathway_y2 pathway_y3 pathway_y4 graduate graduate_other transfer no_creds cohort_year years_to_cred years_to_cred_otherinst latest_year latest_year_minus6 latest_year_minus3 credential_entry enroll_type YearofLastEnrollmentcohort YearofLastEnrollmentotheri pathway_entry pathway_entry_label

*	==========================================
*	PART 3. - Clean PDP data
*		Add the year-specific outcomes
*	==========================================

* Reshape long at the student-year level 
reshape long pathway_y, i(StudentID) j(student_year)

* Replace pathway by outcome in years post enrollment
replace pathway_y = . if student_year > YearofLastEnrollmentcohort

* Save the pathway largest value across all four years for all students
egen max = max(pathway_y)

	/* max+10 = non enrollment
	   max+11 = completion
	   max+12 = transfer
	 */ 

quiet sum max 
local max = `r(mean)'
local max10 = `max' + 10
local max11 = `max' + 11
local max12 = `max' + 12
	 
label define pathway_entry `max10' "Non-Enrollment" `max11' "Completion" `max12' "Transfer", add
label values pathway_y pathway_entry
	 
replace pathway_y = max+10 if pathway_y==. & graduate==0 & transfer==0
replace pathway_y = max+11 if pathway_y==. & graduate==1 & years_to_cred<=student_year
replace pathway_y = max+12 if pathway_y==. & graduate==0 & transfer==1 & YearofLastEnrollmentotheri>=student_year

/* Explain/troubleshoot missing cases */


*	==========================================
*	PART 99. - Save
*	==========================================

save "$root/2_data-toolkit/section2_student-year.dta", replace	

* Add to the saved labels for the graphs 
label save using "$root/2_data-toolkit/pathwaylabels_plusoutcomes.do", replace	