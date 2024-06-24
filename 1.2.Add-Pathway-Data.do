/*******************************************************************************

		ADD PATHWAY DATA		
				
			This dofile takes you through the steps to adding your student
			pathway data in a way that can be read by the toolkit.
				
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
*	PART 2. - Pathway Data Entry
*	==========================================

/* 
	The following dofile creates a pre-filled template of student pathways for 
	you to fill, and saves it under 2_data-toolkit. 
	
	The template consists of the list of students included in your PDP Course
	File, with the following information about the student :
		FirstName MiddleName LastName StudentID Cohort CohortTerm 
	
	The dofile creates two templates, one at the student-year level and 
	one at the student-term level. In the student-year level template, each row 
	corresponds to one particular student in one particular academic year. In the
	student-term level, each row corresponds to one particular at the 
	
	The year and term information is stored in the following variables :  
		AcademicTerm AcademicYear
		
	You can choose which template to use based on what level of details you
	want in your analysis (year or term level), and what level of details you
	have in your data. Note that most student outcomes in the PDP data files are
	recorded in the year level only, so we recommend using the year level as a 
	start. This means you will need to fill in the pathway for each student and 
	each year.
	
	Instead of using this template, you can extract your student pathway
	information from your registrar or other database, and make sure they include
	the following variables
		StudentID containing the unique student identification (the same you 
			use in the PDP)
		ProgramofStudyYear_input containing the unique pathway code for that
			
	
*/

do "0.1.Pathway-Definition-Students.do"


*	==========================================
*	PART 3. - Pathway Data Labeling
*	==========================================


do "0.2.Pathway-Labeling.do"
