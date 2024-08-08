
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
*	PART 2. - Make Report
*	==========================================

/* Note : the command do in Stata calls a dofile and runs it. Thus, if you 
	run this whole dofile, it will call the dofiles listed below one by one
	and run them. */

do "$root/0_scripts/1.1.Section1-Analysis.do"
	
do "$root/0_scripts/2.1.Section2-Analysis-OnePathway.do"

do "$root/0_scripts/2.2.Section2-Analysis-ShortTerm.do"
	
do "$root/0_scripts/3.1.Section3-Analysis"
	
do "$root/0_scripts/4.1.Section4-Analysis"
	
	
	