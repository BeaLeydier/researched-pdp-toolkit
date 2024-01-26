

/*******************************************************************************

		SECTION 1 - Data Prep
		
		
		This file takes your PDP data and puts it in the format appropriate
		to run Section 1 of the Toolkit on them.
		
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
*		Analysis ready COHORT file
*	==========================================

import excel "$root/1_data-pdp/AR-file_cohort.xlsx", firstrow clear

*	==========================================
*	PART 3.1 - Clean PDP data 
*		Verify uniqueness of student records 
*	==========================================

	/* Note : the analysis ready cohort file is supposed to be
		unique at the student-level. StudentID is used to uniquely
		identify student records. We verify here that it is the case as it
		will be a requirement for the rest of the analysis.
		If it is not the case, we first clean the duplicates.
	*/	
	
duplicates tag StudentID, gen(dup)
tab dup

duplicates drop StudentID, force	
	
isid StudentID 

*	==========================================
*	PART 3.2 - Clean PDP data 
*		Create attributes of interest 
*	==========================================

*** Gender

* Create one male variable with takes values 1 for males and 0 for females
gen male = .
replace male = 1 if strpos(Gender, "M")>0
replace male = 0 if strpos(Gender, "F")>0

	/* Note : in Stata, strpos(var, "string") returns the position in the variable
	var where the string "string" appears. For example, strpos(Gender, "M") will
	return 1 for the observations where Gender starts with M. If the string is not
	present in the variable, strpos returns 0. In the PDP data, the variable
	Gender takes value M for males, F for females and NA for not applicable. 
	However, because of possibly inconsistent formatting like leading or trailing 
	blanks, using a simple equality (replace male = 1 if Gender == "M") may not 
	identify all the cases where the variable takes the value M appropriately. 
	One approach would be to clean the Gender variable by removing leading and 
	trailing blanks before using the equality equation. Another approach is to use 
	strpos() which will return a strictly positive number if M is present in the 
	variable, no matter its position; and will return 0 if M is not present in 
	the variable (ie. either F or NA). */
	
* Check that the male variable correctly maps the Gender variable	
tab Gender male, m

* Apply value labels
label define male_vals 0 "Female" 1 "Male"
label values male male_vals

*** Race

* Remove leading and trailing blanks in the Race variable
replace Race = strtrim(Race)

* Collapse multiple consecutive internal blanks into one blank
replace Race = stritrim(Race)

* Create the race variable based on PDP values
gen race = . 
replace race = 1 if strpos(Race, "White") >0
replace race = 2 if strpos(Race, "Hispanic") >0
replace race = 3 if strpos(Race, "American Indian") >0
replace race = 3 if strpos(Race, "Alaska Native") >0
replace race = 4 if strpos(Race, "Native Hawaiian") >0
replace race = 4 if strpos(Race, "Pacific Islander") >0
replace race = 5 if strpos(Race, "Black") >0
replace race = 6 if strpos(Race, "Asian") >0
replace race = 97 if strpos(Race, "Two") >0
replace race = 98 if strpos(Race, "Nonresident") >0
replace race = 99 if strpos(Race, "Unknown") >0


	/* Note : we use strpos() for similar reasons as above. For the race
	categories that are combined (eg. American Indian or Alaska Native) we
	check the two phrases separately - and assign them the same value - in case
	the PDP data doesn't contain the full phrase but only one of the two.
	
	Below are the possible values according to the data dictionary:
		White
		Hispanic
		American Indian or Alaska Native
		Native Hawaiian or Other Pacific Islander
		Two or More Races
		Black or African American
		Nonresident alien
		Asian
		Unknown
		
	We reorder the categories to have the values Two or More Races, Nonresident
	alien and Unknown appear at the end of the list for more clarity in the outputs.
	*/
	
* Apply value labels
label define race_vals 1 "White" 2 "Hispanic" 3 "American Indian" 4 "Native Hawaiian" 5 "Black" 6 "Asian" 97 "Two or More" 98 "Nonresident alien" 99 "Unknown"
label values race race_vals 

* Check
tab Race race, m	
	
*** Parents Education Level 

* Create a categorical variable
gen parents_postsecondaryed = . 
replace parents_postsecondaryed = 0 if strpos(FirstGen, "N")>0
replace parents_postsecondaryed = 1 if strpos(FirstGen, "P")>0
replace parents_postsecondaryed = 2 if strpos(FirstGen, "C")>0
replace parents_postsecondaryed = 3 if strpos(FirstGen, "A")>0
replace parents_postsecondaryed = 4 if strpos(FirstGen, "B")>0

		/* Note :
		N = No parent has attended post-secondary
		P = At least one parent has attended post-secondary but earned no credential or degree
		C = At least one parent has a certificate
		A = At least one parent has an Associate’s degree
		B = At least one parent has a Bachelor’s degree or higher
		*/
		
* Apply value labels
label define ed_vals 0 "Never Attended" 1 "Attended, No Degree" 2 "Certificate" 3 "Associate's" 4 "Bachelor's or more"
label values parents_postsecondaryed ed_vals

* Check
tab FirstGen parents_postsecondaryed, m

*** FirstGen 

* Create an indicator
gen firstgen = . 
replace firstgen = 0 if strpos(FirstGen,"N")==0 & FirstGen != ""
replace firstgen = 1 if strpos(FirstGen,"N")>0 

* Labels
label define first 0 "At least one parent attended post-secondary" 1 "First-generation post-secondary student"
label values firstgen first


*	==========================================
*	PART 4. - Merge in Pathway data   
*	==========================================

*** 

*** Open the pathway data into a temp dataset 

preserve 

	import excel "$root/2_data-toolkit/Student_Pathways_Template_Filled.xlsx", firstrow clear

	* Check that StudentID uniquely identifies the records
	isid StudentID 
	
	tempfile pathways
	save `pathways'
restore 

merge 1:1 StudentID using `pathways'