
/*******************************************************************************

		MAKE Report
		
		
		This dofile runs all the Analysis dofiles.
		
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

/* Insert notes/explanations on having run Make Data before. */


*	==========================================
*	PART 2. - Make Report
*	==========================================

do "$root/0_scripts/1.1.Section1-Analysis.do"
	
do "$root/0_scripts/2.1.Section2-Analysis-OnePathway.do"

do "$root/0_scripts/2.2.Section2-Analysis-ShortTerm.do"
	
do "$root/0_scripts/3.1.Section3-Analysis"
	
do "$root/0_scripts/4.1.Section4-Analysis"
	
	
	