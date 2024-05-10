

/*******************************************************************************

		SECTION 2 - Data Analysis
		
		
		This file takes your transformed student-year dataset and makes it 
			into a Sankey diagram.
		
*******************************************************************************/

*	==========================================
*	PART 0. - Set Up 
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

adopath ++ "$root/0_scripts/ado" 

global pathwaytoplot 5

*	==========================================
*	PART 1. - Load Cleaned PDP data
*		Student-year data
*	==========================================

* Load data
use "$root/2_data-toolkit/section2_student-year.dta", clear	

decode(pathway_y), gen(pathway_y_label) 
order pathway_y_label, after(pathway_y)

reshape wide pathway_y pathway_y_label, i(StudentID) j(student_year)

local allvalues
foreach year in 1 2 3 4 {
	levelsof(pathway_y`year') if pathway_y1==$pathwaytoplot, local(values`year')
	local allvalues : list allvalues | values`year'
}
local uniquevalues : list uniq allvalues
local countvalues = wordcount("`uniquevalues'")
local countpathways = `countvalues' - 3
dis as err "There are `countpathways' distinct pathways in this chart."

sankeyplot pathway_y1 pathway_y2 pathway_y3 pathway_y4 if pathway_y1==$pathwaytoplot, ///
	xlabel(0 "Year 1" 1 "Year 2" 2 "Year3 " 3 "Year 4") ///
	blabel(vallabel) ///
	ylabel(,angle(0)) ytitle("Enrollment Numbers") ///
	title("Pathway 5 Over Time") subtitle("Enrollment Numbers") ///
	colors(pdporange1 pdpblue pdpteal pdpmauve) 

*	==========================================
*	PART 2. - Reshape at the student level (Wide)
*	==========================================

*	==========================================
*	PART 3. - Keep the Pathway of interest
*	==========================================

*	==========================================
*	PART 4. - Reshape the data for the Sankey diagram
*	==========================================

*	==========================================
*	PART 5. - Export the Sankey Diagram
*	==========================================
