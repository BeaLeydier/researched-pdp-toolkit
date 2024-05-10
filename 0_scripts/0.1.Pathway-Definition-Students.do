

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
*	PART 2. - Create a Student-Term Level 
*		Dataset from the PDP Course File
*	==========================================

import delimited "$root/1_data-pdp/$arcoursefile", clear case(preserve)	
	/* Note : the option case(preserve) ensures the variable names are read
		into Stata with the same case as in the original file. */

* Keep student-term information only
keep FirstName MiddleName LastName StudentID Cohort CohortTerm AcademicYear AcademicTerm

* Make the dataset at the student-term level by dropping any duplicate rows
	/* Note : the previous dataset was at the course level, so we expect the 
		same student to be observed multiple times in the same academic term. 
		After removing all the course specific variables and dropping the 
		duplicate rows, we should obtain a Student-Term dataset. */
duplicates drop

* Check that the dataset is unique at the StudentID-AcademicYear-AcademicTerm level
unique StudentID AcademicYear AcademicTerm

	/*Note: This will return an error if student-term do not uniquely identify record.
	
	If you are having an error at this stage, consider the following
		- missing or erraneous studentIDs
		- same student with different name spellings
		- same student with different cohort/term of record
		
	You can clean any redundant information at this stage. Alternatively, you
	can force the uniqueness of records by StudentID AcademicYear AcademicTerm 
	by running the following command, at the risk of losing information :

		duplicates drop StudentID AcademicYear AcademicTerm, force
	*/

* Create a numeric value for the AcademicTerm to allow for sorting
label define term 1 "SPRING" 2 "SUMMER" 3 "FALL"
encode(AcademicTerm), gen(AcademicTerm_Num) label(term)

* Sort by StudentID and AcademicTerm 
sort StudentID AcademicYear AcademicTerm_Num
	
	/* Note : Ideas for data quality checks.
	
		At this stage, you may want to check this student list is complete
		and consistent. For example, you can check 
		
			>> Does the first term that a student is observed in this dataset 
			   correspond to their cohort term? You should expect it to be the 
			   case. 
			   
				* store the first (minimum) year for each student
				bys StudentID: egen min_year = min(AcademicYear)
				
				* store the first (minimum) term for each student, and label it
				bys StudentID: egen min_term_num = min(AcademicTerm_Num)
				label values min_term_num term 
				decode min_term_num, gen(min_term)
				
				* extract the start year from the Cohort variable
				gen cohort_year = ustrregexs(0) if ustrregexm(Cohort, "20([0-9]+)")
				destring(cohort_year), replace
				
				* browse cases where the Cohort start term is different from the first term
				browse if cohort_year != min_year & CohortTerm != min_term
			   
			>> How many distinct terms a given student is observed?
			
				* count distinct year-terms by student
				unique(AcademicYear AcademicTerm), by(StudentID) gen(unique_terms)
				
				* carryforward that value on all the rows of a given student
				bys StudentID: egen n_terms = min(unique_terms)
				drop unique_terms
				
				* tabulate number of terms 
				tab n_terms 
					/* Note : at this stage, if you have kept additional variables 
						from your Course file (e.g. student characteristics), you 
						can tabulate the numebr of terms by characteristics.
					*/
	*/ 


*	==========================================
*	PART 3. - Add Variables for Term-Level Pathway Input
*	==========================================	
	
* Add the pathway variable where the pathway information will be entered
gen ProgramofStudyTerm_input = ""

* Export student-term list template to fill
drop AcademicTerm
export excel "$root/2_data-toolkit/Student_Pathways_Template_Terms.xlsx", firstrow(var) replace


*	==========================================
*	PART 4. - Collapse Data at the Student-Year Level
*	==========================================	

* Keep student-year information only
keep FirstName MiddleName LastName StudentID Cohort CohortTerm AcademicYear

* Make the dataset at the student-year level by dropping any duplicate rows
duplicates drop

* Check that the dataset is unique at the StudentID-AcademicYear-AcademicTerm level
unique StudentID AcademicYear 	

	/* Note : Similar quality checks as above can be run here.

	*/ 

*	==========================================
*	PART 5. - Add Variables for Year-Level Pathway Input
*	==========================================	
	
* Add the pathway variable where the pathway information will be entered
gen ProgramofStudyYear_input = ""

* Export student-year list template to fill
export excel "$root/2_data-toolkit/Student_Pathways_Template_Years.xlsx", firstrow(var) replace
	
	
*	==========================================
*	PART 6. - Fill
*	==========================================

/* You can now navigate to the 2_data-toolkit folder of your repository and fill
out of of the templates we generated, by entering the PathwayID information for 
each student in the corresponding column for each Term or Year that you are 
entering data for this student for. */

