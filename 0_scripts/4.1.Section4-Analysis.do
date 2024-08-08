
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
*	PART 2. - Load PDP data
*		Section 4 transformed data
*	==========================================

* Load data
use "$root/2_data-toolkit/section4.dta", clear	

	
*	==========================================
*	PART 3. - Define parameters : student population subset, chart colors 
*	==========================================

* Add the toolkit's ado folder to Stata's recognized ado paths to load custom colors
adopath ++ "$root/0_scripts/ado" 

* Define list of pathways to display on the chart

	/* INSTRUCTIONS : Change the following list based on the pathways you 
		want to display on the chart. Use the Pathway IDs generated in the 
		labeling template.
	*/

global pathwaylist "1, 3, 4, 5"

 
*	==========================================
*	PART 4. - Cumulative credit graphs
*	==========================================

preserve 

keep if inlist(pathway_entry, $pathwaylist)

collapse (mean) cumu_*, by(pathway_entry student_year)

twoway (line cumu_creditsearned student_year, lcolor(pdpblue)) /// // colors specifically chosen to be colorblind accessible
	   (line cumu_creditsattempted student_year, lcolor(pdpteal) lpattern(dash)) ///
		(line cumu_idealcreditsearned student_year, lcolor(pdpmauve)), ///
	   by(pathway_entry, graphregion(fcolor(white)) note("") imargin(medium) title("Average Cumulative Credits" "Attempted vs. Earned")) ///
	   legend(label(1 "Earned") label(2 "Attempted") label(3 "On-Track")) yline(0, lcolor(black)) plotregion(margin(zero)) ytitle("Avg. Cumulative Credits") ///
	   xtitle("Year") 
		graph export "4_output/s4-cumu.png", replace
	   //ylabel(0(15)60) xlabel(1(1)${max_term})
		   
restore		   
		   
	