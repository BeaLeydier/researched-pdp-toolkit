
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
*	PART 2. - Institution Type
*	==========================================

	/* INSTRUCTIONS:
		Comment out the institution type that you are NOT, by placing an 
		asterix in front of it.
	*/

global institutiontype "2year"
global institutiontype "4year"


*	==========================================
*	PART 3. - Number of Credits for Completion
*	==========================================

