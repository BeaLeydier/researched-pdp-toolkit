

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

* INSTRUCTIONS: Define machine-specific file path 
	/* Note : In order to define your own file path, enter your machine 
		username where it says "INSERT-MACHINE-USERNAME" and enter the file 
		path of your local toolkit folder where it says "INSERT MACHINE SPECIFIC
		FILEPATH". 
		
		If you do not know what is your machine username, you can run the 
		following command into Stata:
			dis "`c(username)'"
			
		What is displayed in response is your machine username. To see all the
		other computer and system parameters stored by Stata, you can run
			creturn list 
			
		For more details on how the following chunk of code works (in particular
		the if conditions and the global), see the extensive comment in the
		dofile 0.Set-Up.do.
	*/
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
*	PART 2. - Load PDP data
*		Analysis ready COURSE file
*	==========================================

import delimited "$root/1_data-pdp/$arcoursefile", clear case(preserve)

*	==========================================
*		PART 3 - Clean PDP data 
*
*	==========================================
 
**  Merge with Outcomes and Pathway Data Defined and Created in Section 1 
merge m:1 StudentID using "2_data-toolkit/section1_student.dta", assert(2 3) keep(3) nogen

** Create a numeric indicator for term to sort terms in chronological order
label define terms 1 "FALL" 2 "SPRING" 3 "SUMMER"
encode AcademicTerm, gen(AcademicTerm_Num) label(terms)
order AcademicTerm_Num, after(AcademicTerm)

	/* Note : this assumes that within a given AcademicYear, the Fall is the 
		first term, followed by Spring and by Summer. For example, 
			AcademicYear 2017-18 would refer to the following terms
				FALL : Fall of the calendar year 2017 
				SPRING : Spring of the calendar year 2018
				SUMMER : Summer of the calendar year 2018
		If in your data, AcademicYear is coded differently, or if at your 
			institution, Fall is not the first term of the AcademicYear, you 
			will want to change the order in the label defined below, so that 
			your pathway data entry is correctly sequentially ordered.
	*/

	
*	==========================================
*	PART 4 - Create Outcomes of Interest 
*		Student-Course level
*	==========================================

** Outcome for a student for one given course
gen course_fail = 0
replace course_fail = 1 if (Grade=="W")
replace course_fail = 1 if CreditsEarned==0

gen course_pass = 0
replace course_pass = (CreditsAttempted == CreditsEarned)

** Indicator for whether a course is a student's first attempt
sort StudentID CourseNumber AcademicYear AcademicTerm_Num 
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
*	PART 5 - Create outcomes of interest
*		Course level
*	==========================================

** Total Attempters for one course
codebook CourseNumber StudentID

	/* NOTE: Check for any missing values. */

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
*	PART 6. - Save transformed data   
*	========================================== 
	
* Keep the pathway-course level variables only
keep CourseNumber CourseName MathorEnglishGateway total_attempters proportion_failing prob_completer_fail prob_completer_pass prob_completer_diff
duplicates drop	
	
save "2_data-toolkit/section3.dta", replace	
	
