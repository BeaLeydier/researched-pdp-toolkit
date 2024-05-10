

/*******************************************************************************

		SECTION 3 - Data Prep
		
		
		This file takes your PDP data and puts it in the format appropriate
		to run Section 3 of the Toolkit.
		
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

import delimited "$root/1_data-pdp/students-fake.csv", clear case(preserve)

	/* NOTE: note on harmonizing variable names/data inputs, and limiting
	this data import to the course specific vars.*/


*	==========================================
*	PART 3.1 - Clean PDP data 
*		Merge with Outcomes and Pathway Data
*		Defined and Created in Section 1 
*	==========================================
 
merge m:1 StudentID using "2_data-toolkit/cohort-AR-transformed.dta", assert(2 3) keep(3) nogen

	/* NOTE: Insert notes on merge diagnostics */	

*	==========================================
*	PART 3.2 - Clean PDP data 
*		Limit to Pathway of Interest 
*	==========================================	
		
	
*	==========================================
*	PART 3.3 - Clean PDP data 
*		Create outcomes of interest : term level
*	==========================================
	
** Create a numeric indicator for term to sort terms in chronological order
label define terms 1 "SPRING" 2 "SUMMER" 3 "FALL"
encode AcademicTerm, gen(AcademicTerm_Num) label(terms)
order AcademicTerm_Num, after(AcademicTerm)

gen AcademicYearTerm = AcademicYear * 100 + AcademicTerm_Num
order AcademicYearTerm, after(AcademicTerm_Num)	
	
*	==========================================
*	PART 3.4 - Clean PDP data 
*		Create outcomes of interest : student-course level
*	==========================================

** Outcome for a student for one given course
gen course_fail = 0
replace course_fail = 1 if (Grade=="W")
replace course_fail = 1 if CreditsEarned==0

gen course_pass = 0
replace course_pass = (CreditsAttempted == CreditsEarned)

** Indicator for whether a course is a student's first attempt
sort StudentID CourseNumber AcademicYearTerm 
by StudentID CourseNumber: gen studcourse_attempt = _n

gen studcourse_attemptfirst = (studcourse_attempt == 1)

** Indicator for failing a course on first attempt
gen studcourse_attemptfirstfail = studcourse_attemptfirst * course_fail

** Indicator for passing a course on first attempt
gen studcourse_attemptfirstpass = studcourse_attemptfirst * course_pass

** Indicator for graduating AND failing a course on first attempt
gen studcourse_attemptfirstfail_grad = studcourse_attemptfirstfail * graduate

** Indicator for graduating AND passing a course on first attempt
gen studcourse_attemptfirstpass_grad = studcourse_attemptfirstpass * graduate


*	==========================================
*	PART 3.5 - Clean PDP data 
*		Create outcomes of interest : course level
*	==========================================

** Total Attempters for one course
codebook CourseNumber StudentID
	/* NOTE: Note on unicity, missing values */

unique StudentID, by(CourseNumber) gen(total_attempters_temp)
bys CourseNumber : egen total_attempters = max(total_attempters_temp)
drop total_attempters_temp

** Proportion Failing on First Attempt 
bys CourseNumber: egen n_firstattempts = total(studcourse_attemptfirst)
bys CourseNumber: egen n_firstattemptsfail = total(studcourse_attemptfirstfail)

gen proportion_failing = n_firstattemptsfail / n_firstattempts
	
	/* NOTE : verify in your data that n_firstattempts = total_attempters */
	
** Proportion of Completer Having Failed on First Attempt
bys CourseNumber : egen n_completerfail = total(studcourse_attemptfirstfail_grad)	
	
gen prob_completer_fail = n_completerfail / n_firstattemptsfail
	
** Proportion of Completer Having Passed on First Attempt	
bys CourseNumber: egen n_firstattemptspass = total(studcourse_attemptfirstpass)
bys CourseNumber : egen n_completerpass = total(studcourse_attemptfirstpass_grad)	

gen prob_completer_pass = n_completerpass / n_firstattemptspass

** Difference in probability 
gen prob_completer_diff = prob_completer_pass - prob_completer_fail

** Drop temporary variables
drop n_firstattempts n_firstattemptsfail n_completerfail n_firstattemptspass n_completerpass

** Data construction checks
sum course_fail course_pass studcourse_attemptfirstfail studcourse_attemptfirstpass studcourse_attemptfirstfail_grad studcourse_attemptfirstpass_grad 
	//should all be 0/1 indicators
sum proportion_failing prob_completer_fail prob_completer_pass prob_completer_diff 
	//should all be continuous proportions between 0-1


*	==========================================
*	PART 99. - Save transformed data   
*	========================================== 
	
* Keep the pathway-course level variables only
keep CourseNumber CourseName MathorEnglishGateway total_attempters proportion_failing prob_completer_fail prob_completer_pass prob_completer_diff
duplicates drop	
	
save "2_data-toolkit/section3.dta", replace	
	
