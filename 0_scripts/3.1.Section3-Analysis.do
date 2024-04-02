
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
*		Section 3 transformed data
*	==========================================

* Load data
use "$root/2_data-toolkit/section3.dta", clear	

replace total_attempters = total_attempters - 10 if _n <=7
	/* note: for variation in example output */

	
*	==========================================
*	PART 3. - Define parameters : student population subset, chart colors 
*	==========================================


global color1 "51 34 136" //deep purple (cool and somewhat dark)
global color2 "68 170 153" //teal (mid-bright and cool)
global color3 "136 34 85" //mauve (leans towards warm and medium in brightness)
global color4 "204 153 0" //soft amber (warm, not too bright, but clear enough)



*	==========================================
*	PART 4. - Output graphs
*	==========================================

twoway (scatter prob_completer_diff proportion_failing if MathorEnglishGateway=="M" [w = total_attempters], msymbol(Oh) mcolor("$color1")) /// 
	   (scatter prob_completer_diff proportion_failing if MathorEnglishGateway!="M" [w = total_attempters], msymbol(Dh) mcolor("$color4")), ///
		title("Difference in Probability of Completion for those who Pass, Fail Course on first attempt", size(small)) ///
		subtitle("Pathway X", size(small)) ///
		ytitle("Difference in Predicted Probability of Completion", size(small)) ///
		xtitle("Proportion of Students who Failed Course During First Attempt", size(small)) ///
		legend(order(1 "Math Gateway Courses" 2 "Other Courses"))
graph export "4_output/s3-weighted.png", replace
	
	/* NOTE - labeling courses not compatible with weighting display */	
		
twoway (scatter prob_completer_diff proportion_failing if MathorEnglishGateway=="M" [w = total_attempters], msymbol(Oh) mcolor("$color1") mlabel(CourseName) mlabposition(6) mlabsize(vsmall)) /// 
	   (scatter prob_completer_diff proportion_failing if MathorEnglishGateway!="M" [w = total_attempters], msymbol(Dh) mcolor("$color4") mlabel(CourseName) mlabposition(6) mlabsize(vsmall)), ///
		title("Difference in Probability of Completion for those who Pass, Fail Course on first attempt", size(small)) ///
		subtitle("Pathway X", size(small)) ///
		ytitle("Difference in Predicted Probability of Completion", size(small)) ///
		xtitle("Proportion of Students who Failed Course During First Attempt", size(small)) ///
		legend(order(1 "Math Gateway Courses" 2 "Other Courses"))		
graph export "4_output/s3-labeled.png", replace
