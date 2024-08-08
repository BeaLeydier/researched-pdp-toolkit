

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

* INSTRUCTIONS : Define machine-specific file path 
	/* Note : In order to define your own file path, enter your machine 
		username where it says "INSERT-MACHINE-USERNAME" and enter the file 
		path of your local toolkit folder where it says "INSERT MACHINE SPECIFIC
		FILEPATH". 
		
		If you do not know what is your machine username, you can run the 
		following command into Stata:
			dis "`c(username)'"
			
		What is displayed in response is your machine username. To see all the
		other computer and system parameters stored by Stata, you can run
			creturn list 
			
		For more details on how the following chunk of code works (in particular
		the if conditions and the global), see the extensive comment in the
		dofile 0.Set-Up.do.
	*/
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
	//the command do in Stata calls a dofile and runs it
quietly { //quietly ensures the code is run in the background without displaying any output
	do "$root/1.Add-PDP-Data.do"
	do "$root/2.3.Add-Pathway-Data.do"
	do "$root/3.Define-Institution-Parameters.do"
}

*	==========================================
*	PART 1. - Define Parameters
*	==========================================

** Add the ado file path to load the custom colors
adopath ++ "$root/0_scripts/ado" 

** Define the pathway to create the graphs for 
	/* INSTRUCTIONS: Change the pathway number here to produce a graph for 
		a different pathway. Use the pathway ID from the labeling template. 
	*/
global pathwaytoplot 5

*	==========================================
*	PART 2. - Load Cleaned PDP data
*		Student-year data
*	==========================================

* Load data
use "$root/2_data-toolkit/section2_student-year.dta", clear	

* Add pathway labels (names) in a different variable
decode(pathway_y), gen(pathway_y_label) 
order pathway_y_label, after(pathway_y)

* Reshape data at the student level (wide)
reshape wide pathway_y pathway_y_label, i(StudentID) j(student_year)


*	==========================================
*	PART 3. - Count Numbers of Pathways in the Chart 
*	==========================================

* Count and display the number of pathways in the chart
local allvalues
foreach year in 1 2 3 4 {
	levelsof(pathway_y`year') if pathway_y1==$pathwaytoplot, local(values`year')
	local allvalues : list allvalues | values`year'
}
local uniquevalues : list uniq allvalues
local countvalues = wordcount("`uniquevalues'")
local countpathways = `countvalues' - 3
dis as err "There are `countpathways' distinct pathways in this chart."


*	==========================================
*	PART 5. - Export the Sankey Diagram
*	==========================================

sankeyplot pathway_y1 pathway_y2 pathway_y3 pathway_y4 if pathway_y1==$pathwaytoplot, ///
	xlabel(0 "Year 1" 1 "Year 2" 2 "Year3 " 3 "Year 4") xtitle("") ///
	blabel(vallabel) ///
	ylabel(,angle(0)) ytitle("Enrollment Numbers") ///
	title("Pathway 5 Over Time") subtitle("Enrollment Numbers") ///
	colors(pdporange1 pdpblue pdpteal pdpmauve) 
