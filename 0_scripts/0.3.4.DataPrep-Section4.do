

/*******************************************************************************

		SECTION 4 - Data Prep
		
		
		This file takes your PDP data and puts it in the format appropriate
		to run Section 4 of the Toolkit on them.
		
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
*		Student-Year Dataset created for Section 2
*	==========================================

use "2_data-toolkit/s2-student-year.dta", clear	


*	==========================================
*	PART 3 - Clean PDP data 
*		Merge Outcomes from the PDP
* 		COURSE File
*	==========================================
 
preserve 

* Load the PDP COURSE data
import delimited "$root/1_data-pdp/students-fake.csv", clear case(preserve)

* Calculate credits attempted and credits earned for each student in each year
bys StudentID AcademicYear: egen credits_attempted = total(CreditsAttempted)
bys StudentID AcademicYear: egen credits_earned = total(CreditsEarned)

* Reshape at the student-year level
keep StudentID credits_attempted credits_earned AcademicYear
duplicates drop

* Create a student_year indicator
bys StudentID : gen student_year = _n

* Save dataset
tempfile credits
save `credits'

restore 
 
merge 1:1 StudentID student_year using `credits'
keep if _merge==3

	/* NOTE: Insert notes on merge diagnostics */	

	
*	==========================================
*	PART 4 - Clean PDP data 
*		Add Cumulative Outcomes
*	==========================================	

bys StudentID (student_year): gen cumu_creditsearned = sum(credits_earned)	

bys StudentID (student_year): gen cumu_creditsattempted = sum(credits_attempted)	
	
* ideal 

**TODO : make it a function of the type of institution/or starting degree?

gen ideal_creditsearned = 0
label var ideal_creditsearned "ideal number of credits a student would earn each term"
replace ideal_creditsearned = 60 if inrange(student_year, 1, 3)

bys StudentID (student_year): gen cumu_idealcreditsearned = sum(ideal_creditsearned)
label var cumu_idealcreditsearned "cumulative ideal number of credits a student would have earned each term"	
	
	/* make the ideal a function of the starting degree. Bachelor's: 6 years, 120 credits total. */
	
*	==========================================
*	PART 99. - Save transformed data   
*	========================================== 

save "2_data-toolkit/section4.dta", replace	
	
