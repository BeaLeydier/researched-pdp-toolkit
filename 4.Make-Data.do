
/*******************************************************************************

		MAKE DATA
		
		
		This dofile runs all the DataPrep files in order.
		
*******************************************************************************/

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
*	PART 2. - Make Data
*	==========================================

do "$root/0_scripts/0.1.DataPrep-Section1.do"
	
do "$root/0_scripts/0.2.DataPrep-Section2.do"
	
do "$root/0_scripts/0.3.DataPrep-Section3.do"
	
do "$root/0_scripts/0.4.DataPrep-Section4.do"
	