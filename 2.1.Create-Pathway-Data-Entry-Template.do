/*******************************************************************************

		CREATE TEMPLATES TO ADD PATHWAY DATA		
				
			This dofile takes you through the steps to adding your student
			pathway data in a way that can be read by the toolkit.
				
*******************************************************************************/

/* 
	This dofile creates a pre-filled template of student pathways for 
	you to fill, and saves it under 2_data-toolkit. 
	
	The template consists of the list of students included in your PDP Course
	File, with the following information about the student :
		FirstName MiddleName LastName StudentID Cohort CohortTerm 
	
	This dofile creates two templates, one at the student-year level and 
	one at the student-term level. In the student-year level template, each row 
	corresponds to one particular student in one particular academic year. In the
	student-term level, each row corresponds to one particular student in one 
	particular term. 
	
	The year and term information is stored in the following variables :  
		AcademicTerm AcademicYear
		
	The AcademicTerm variable isn't present in the yearly template, given there
	is only one row per year. The AcademicTerm variable takes the values SPRING,
	SUMMER and FALL. The AcademicYear variable takes values of the form 2017-18.
	For example, in the term-level template, the term Spring 2022 is identified
	with the values SPRING for AcademicTerm and 2021-22 for AcademicYear.
		
	You can choose which template to use based on what level of details you
	want in your analysis (year or term level), and what level of details you
	have in your data. Note that most student outcomes in the PDP data files are
	recorded in the year level only, so we recommend using the year level as a 
	start. This means you will need to fill in the pathway for each student and 
	each year, using the year level template.
	
	Instead of using one of these templates, you can extract your student pathway
	information from your registrar or other database, and make sure they include
	the following variables, for the year level data entry :
		StudentID containing the unique student identification (the same you 
			use in the PDP) for the student in that row
		AcademicYear containing the academic year corresponding to the pathway 
			information for in that row, formatted as 2017-18  
		ProgramofStudyYear_input containing the student's pathway code for that 
			year, using the same codes as the Program of Study codes you use 
			in the PDP files (if you use this field in the PDP)
			
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
label define term 1 "FALL" 2 "SPRING" 3 "SUMMER"
encode(AcademicTerm), gen(AcademicTerm_Num) label(term)

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


* Sort by StudentID and AcademicTerm 
sort StudentID AcademicYear AcademicTerm_Num
	
	/* Note : Ideas for data quality checks.
	
		At this stage, you may want to check this student list is complete
		and consistent. For example, you can check 
		
			>> Does the first term that a student is observed in this dataset 
			   correspond to their cohort term? You should expect it to be the 
			   case. 
			   
			   * convert AcademicYear into a numeric year, extracting the first 
			   year listed in the 20XX-YY format
				gen academic_year = ustrregexs(0) if ustrregexm(AcademicYear, "20([0-9]+)")
				destring(academic_year), replace
			   
				* store the first (minimum) year for each student
				bys StudentID: egen min_year = min(academic_year)
				
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
						can tabulate the number of terms by characteristics.
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


