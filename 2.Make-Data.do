
/*******************************************************************************

		MAKE DATA
		
		
		This dofile runs all the DataPrep files in order.
		
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
*	PART 2. - Pathway Data Entry and Labeling
*	==========================================

/* Insert notes/explanations on the pathway template */

*do "0.1.Pathway-Definition-Students.do"

*do "0.2.Pathway-Labeling.do"

*	==========================================
*	PART 3. - Make Data
*	==========================================

do "$root/0_scripts/0.3.1.DataPrep-Section1.do"
	
do "$root/0_scripts/0.3.2.DataPrep-Section2.do"
	
do "$root/0_scripts/0.3.3.DataPrep-Section3.do"
	
do "$root/0_scripts/0.3.4.DataPrep-Section4.do"
	