
/*******************************************************************************

		SECTION 3 - Analysis
		
		This file takes your transformed cohort PDP data and runs 
		Section 3 analyses of the toolkit.
		
*******************************************************************************/

*	==========================================
*	PART 1. - Set Up 
*	==========================================

* Stata set up
set more off

* INSTRUCTIONS : Define machine-specific file path 

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
*	PART 2. - Load PDP data
*		Section 3 transformed data
*	==========================================

* Load data
use "$root/2_data-toolkit/section3.dta", clear	

replace total_attempters = total_attempters - 10 if _n <=7
	/* note: for variation in example output */

	
*	==========================================
*	PART 3. - Define parameters : student population subset, chart colors 
*	==========================================

* Add the toolkit's ado folder to Stata's recognized ado paths to add the custom colors
adopath ++ "$root/0_scripts/ado" 


*	==========================================
*	PART 4. - Output graphs
*	==========================================

twoway (scatter prob_completer_diff proportion_failing if MathorEnglishGateway=="M" [w = total_attempters], msymbol(Oh) mcolor(pdpblue)) /// 
	   (scatter prob_completer_diff proportion_failing if MathorEnglishGateway!="M" [w = total_attempters], msymbol(Dh) mcolor(pdplavender)), ///
		title("Difference in Probability of Completion for those who Pass, Fail Course on first attempt", size(small)) ///
		subtitle("Pathway X", size(small)) ///
		ytitle("Difference in Predicted Probability of Completion", size(small)) ///
		xtitle("Proportion of Students who Failed Course During First Attempt", size(small)) ///
		legend(order(1 "Math Gateway Courses" 2 "Other Courses"))
graph export "4_output/s3-weighted.png", replace
	
	/* NOTE - labeling courses not compatible with weighting display */	
		
twoway (scatter prob_completer_diff proportion_failing if MathorEnglishGateway=="M" [w = total_attempters], msymbol(Oh) mcolor(pdpblue) mlabel(CourseName) mlabposition(6) mlabsize(vsmall)) /// 
	   (scatter prob_completer_diff proportion_failing if MathorEnglishGateway!="M" [w = total_attempters], msymbol(Dh) mcolor(pdplavender) mlabel(CourseName) mlabposition(6) mlabsize(vsmall)), ///
		title("Difference in Probability of Completion for those who Pass, Fail Course on first attempt", size(small)) ///
		subtitle("Pathway X", size(small)) ///
		ytitle("Difference in Predicted Probability of Completion", size(small)) ///
		xtitle("Proportion of Students who Failed Course During First Attempt", size(small)) ///
		legend(order(1 "Math Gateway Courses" 2 "Other Courses"))		
graph export "4_output/s3-labeled.png", replace
