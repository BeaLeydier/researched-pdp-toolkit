
/*******************************************************************************

		SECTION 4 - Analysis
		
		This file takes your transformed cohort PDP data and runs 
		Section 4 analyses of the toolkit.
		
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
*		Section 4 transformed data
*	==========================================

* Load data
use "$root/2_data-toolkit/section4.dta", clear	

	
*	==========================================
*	PART 3. - Define parameters : student population subset, chart colors 
*	==========================================


global color1 "51 34 136" //deep purple (cool and somewhat dark)
global color2 "68 170 153" //teal (mid-bright and cool)
global color3 "136 34 85" //mauve (leans towards warm and medium in brightness)
global color4 "204 153 0" //soft amber (warm, not too bright, but clear enough)

global pathwaylist "1, 3, 4, 5"

*	==========================================
*	PART 4. - Cumulative credit graphs
*	==========================================

preserve 

keep if inlist(pathway_entry, $pathwaylist)
collapse (mean) cumu_*, by(pathway_entry student_year)

twoway (line cumu_creditsearned student_year, lcolor("$color1")) /// // colors specifically chosen to be colorblind accessible
	   (line cumu_creditsattempted student_year, lcolor("$color2") lpattern(dash)) ///
		(line cumu_idealcreditsearned student_year, lcolor("$color3")), ///
	   by(pathway_entry, graphregion(fcolor(white)) imargin(medium) title("Average Cumulative Credits" "Attempted vs. Earned")) ///
	   legend(label(1 "Earned") label(2 "Attempted") label(3 "On-Track")) yline(0, lcolor(black)) plotregion(margin(zero)) ytitle("Avg. Cumulative Credits") ///
	   xtitle("Year") 
		graph export "4_output/s4-cumu.png", replace
	   //ylabel(0(15)60) xlabel(1(1)${max_term})
		   
restore		   
		   
	