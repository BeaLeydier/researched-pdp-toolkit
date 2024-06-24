
/*******************************************************************************

		PARAMETERS		
		
		This is where you define the parameters for your analysis, for example
			- Is this a 2 or 4 year college
			- The code of the pathway you want to look into in Section 2
		
*******************************************************************************/

*	==========================================
*	PART 1. - File path
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
*	PART 3. - Pathway Data Entry
*	==========================================

	/* INSTRUCTIONS:
		Replace the file names in quotes with the file names you are using.

		When two options are suggested for the same global, comment out 
		the option you are NOT using, by placing an asterix in front of it.
	*/

* Name of the file where you define the student pathways (once filled)
global studentpathwaysfile "Student_Pathways_Template_Years_Filled.xlsx"

* Temporal unit at which the pathway data entry is done 
global studentpathwaytimeline "Term"
global studentpathwaytimeline "Year"

* Name of the file where you define the pathway labels (once filled)
global pathwaylabelsfile "ProgramofStudy_Label_Template_Filled.xlsx"


*	==========================================
*	PART 4. - Institution Type
*	==========================================

	/* INSTRUCTIONS:
		Comment out the institution type that you are NOT, by placing an 
		asterix in front of it.
	*/

global institutiontype "2year"
global institutiontype "4year"

