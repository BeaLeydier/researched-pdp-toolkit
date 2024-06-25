
/*******************************************************************************

		SECTION 0 - Summary Statistics
		
		This file takes your transformed cohort PDP data and runs 
		Section 1 analyses of the toolkit.
		
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

* Load the paramaters 
quietly { //quietly ensures the code is run in the background without displaying any output
	do "$root/1.Add-PDP-Data.do"
	do "$root/2.3.Add-Pathway-Data.do"
	do "$root/3.Define-Institution-Parameters.do"
}

* Add the toolkit's ado folder to Stata's recognized ado paths to add the custom colors
adopath ++ "$root/0_scripts/ado" 

*	==========================================
*	PART 2. - Load PDP data
*		Analysis ready COHORT file
*	==========================================

* Load data
use "$root/2_data-toolkit/section1_student.dta", clear	

*	==========================================
*	PART 3. - Explore Data
*	==========================================

graph bar if race < 10, over(credential_entry) over(race) asyvars ///
	bar(1, fcolor(pdpblue) lcolor(black)) bar(2, fcolor(pdpteal) lcolor(black)) /// 
	bar(3, fcolor(pdpmauve) lcolor(black)) bar(4, fcolor(pdplavender) lcolor(black)) ///
	title("Credentials at Entry by Race")
graph export "$root/4_output/sec0_credsbyrace.png", replace