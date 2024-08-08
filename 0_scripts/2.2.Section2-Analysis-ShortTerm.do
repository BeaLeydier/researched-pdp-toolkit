
/*******************************************************************************

		SECTION 1 - Analysis
		
		This file takes your transformed cohort PDP data and runs 
		Section 1 analyses of the toolkit.
		
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
*		Analysis ready COHORT file
*	==========================================

* Load data
use "$root/2_data-toolkit/cohort-AR-transformed.dta", clear	

* Save labels for the graphs later
label save using "$root/2_data-toolkit/pathwaylabels.do", replace
	
*	==========================================
*	PART 3. - Create combined outcome variable
*	==========================================
	
* Create one outcome variable
gen outcome = retention 
replace outcome = 2 if retention==0 & persistence==1

label define outcomes 0 "None" 1 "Y2 Retention" 2 "Y2 Persistence" 
lab values outcome outcomes


*	==========================================
*	PART 4. - Define parameters : student population subset, chart colors 
*	==========================================

// Colors 

* Add the toolkit's ado folder to Stata's recognized ado paths to add the custom colors
adopath ++ "$root/0_scripts/ado" 


// Student subset 

	/* Note : 
	
		For 2-year institutions, we keep stuednts who enrolled at least 3 years
			before the last PDP year. For 4-year institutions, we keep students
			who enrolled at least 6 years before the last PDP year.
	*/

if "$institutiontype" == "2year"	{
	keep if cohort_year <= latest_year_minus3	
}
if "$institutiontype" == "4year"	{
	keep if cohort_year <= latest_year_minus6
	
}	
	
*	==========================================
*	PART 5. - Define custom programs for margins regression and plot exports
*	==========================================
	
*** Export stacked margins plot program 

cap program drop mlogit_marginsplot_stacked
program define mlogit_marginsplot_stacked

	syntax varlist(fv) [using/] [if/], ///variables following mlogit, plus any optional if condition (without the "if")
	 margins(varlist) ///variable for the margins
	 [marginslabel(string) * ///margins label plus the wildcard of options to have all the graphing options already defined
	 outcome1label(string) ///
	 outcome2label(string) ///
	 ]
	 	 
	*retrieve the outcome (first variable of the varlist)	 
	local outcome = word("`varlist'",1) 	
	
	*define default
	if "`outcome1label'" == "" {
		local outcome1label "First Completion"
	}
	if "`outcome2label'" == "" {
		local outcome2label "First Transfer"
	}
	
	* run the mlogit regression and the margins command
	mlogit `varlist', robust 
	margins `margins', predict(outcome(1)) predict(outcome(2)) 
	
	* store the results in the data frame, reshape it, graph it
	preserve 
		matrix ans = (r(b))'
		svmat2 ans, rnames(estimate_name)
		gen outcome_level = ustrregexs(1) if ustrregexm(estimate_name, "^([0-9])")
		destring outcome_level, replace
		gen pathway_level = ustrregexs(1) if ustrregexm(estimate_name, "t.([0-9]+)")
		destring pathway_level, replace
		keep ans1 outcome_level pathway_level 
		rename ans1 prediction_
		drop if prediction_ == .
		reshape wide prediction_, i(pathway_level) j(outcome_level)
		do "$root/2_data-toolkit/pathwaylabels.do"
		label values pathway_level "`marginslabel'"
		graph bar prediction_1 prediction_2, stack over(pathway_level) ///
			bar(1, fcolor(pdpblue) lcolor(black)) bar(2, fcolor(pdpteal) lcolor(black)) ///
			ytitle("Probability") legend(label(1 "`outcome1label'") label(2 "`outcome2label'")) ///
			xsize(5.5) ///
			`options'
		graph export "`using'", replace
	restore
end

*** Export simple margin plots programs 

cap program drop marginplots_export 
program define marginplots_export 

	syntax varlist, ///
		at(string) ///
		atlabel(string) ///
		[file(string) * ///
		 outcome1label(string) ///
		 outcome2label(string) ///
		]

	*define default
	if "`outcome1label'" == "" {
		local outcome1label "First Completion"
	}
	if "`outcome2label'" == "" {
		local outcome2label "First Transfer"
	}
		
margins `varlist', at(`at') predict(outcome(1)) predict(outcome(2))
marginsplot, bydimension(`varlist') byopts(title("Adjusted Probability of Outcomes" "by `atlabel'") graphregion(fcolor(white)) imargin(medium)) ///
			 ytitle("Adjusted Probability") xtitle("`atlabel'") ylabel(0(0.2)1) noci legend(order(1 "`outcome1label'" 2 "`outcome2label'")) plotregion(margin(zero)) yline(0, lcolor(black)) ///
			 plot1opts(mcolor(pdpblue) lcolor(pdpblue)) plot2opts(mcolor(pdpteal) lcolor(pdpteal)) ///
			 `options'
graph export "`file'", replace


end

*** Export double margin plots programs 
cap program drop marginplots_double_export 
program define marginplots_double_export 

	syntax varlist, ///
		at(string) ///
		atlabel(string) ///
		file(string) ///
		plotdimension(varname) ///
		xlabel(string) ///
		[at1label(string) * /// includes wildcard for any other options
		 outcome1label(string) ///
		 outcome2label(string) ///
		]

* Check how many plotdimensions we have		
quiet unique `plotdimension'	
local ndims = `r(unique)'
if `ndims' == 1 {
	dis as err "The plotdimension() variable you chose takes only one value in the whole dataset (no variation). Please choose a plotdimension() variable taking between 2 and 4 unique values."
	exit
}
else if `ndims' == 2 {
	local plotopts `" plot1opts(mcolor(pdpblue) lcolor(pdpblue)) plot2opts(mcolor(pdpteal) lcolor(pdpteal)) "'
}
else if `ndims' == 3 {
	local plotopts `" plot1opts(mcolor(pdpblue) lcolor(pdpblue)) plot2opts(mcolor(pdpteal) lcolor(pdpteal)) plot3opts(mcolor(pdpmauve) lcolor(pdpmauve)) "'
}
else if `ndims' == 4 {
	local plotopts `" plot1opts(mcolor(pdpblue) lcolor(pdpblue)) plot2opts(mcolor(pdpteal) lcolor(pdpteal)) plot3opts(mcolor(pdpmauve) lcolor(pdpmauve)) plot4opts(mcolor(pdplavender) lcolor(pdplavender)) "'
}
else if `ndims' > 4 {
	dis as err "The plotdimension() variable you chose takes more than 4 unique values in the whole dataset. For readability, this tool doesn't allow more than four dimensions to be plotted at a time. Please choose (and, if needed, create) a plotdimension() variable taking between 2 and 4 unique values."
}

margins `varlist', at(`at') predict(outcome(1)) 
marginsplot, bydimension(`varlist') plotdimension(`plotdimension') noci byopts(graphregion(fcolor(white)) rows(1) imargin(medium) title("")) ytitle("`outcome1label'") xtitle("") ///
			 ylabel(0(0.2)1) xlabel(`xlabel') plotregion(margin(zero)) yline(0, lcolor(black)) `plotopts' ///
			 name(temp_a, replace)	
margins `varlist', at(`at') predict(outcome(2))
marginsplot, bydimension(`varlist') plotdimension(`plotdimension') noci byopts(graphregion(fcolor(white)) rows(1) imargin(medium) title("")) ytitle("outcome2label") xtitle("") ///
			 ylabel(0(0.2)1) xlabel(`xlabel') plotregion(margin(zero)) yline(0, lcolor(black)) `plotopts' ///
			 name(temp_b, replace)	
			 
grc1leg2 temp_a temp_b, title("Adjusted Probability of Outcomes" "by `atlabel'") rows(2) graphregion(fcolor(white)) ///
	  b1title("`at1label'") l1title("Adjusted Probability") position(6) symxsize(small) labsize(small) xsize(7) ///
	  `options'			 
graph export "`file'", replace

end


*	==========================================
*	PART 5. - Run the adjusted and unajusted models of outcomes by pathway
*	==========================================
	
* Unadjusted Outcomes by pathway of entry	
mlogit_marginsplot_stacked outcome i.pathway_y1 using "$root/4_output/s2_pathway_stacked.png", margins(pathway_y1) marginslabel(pathway_y1) ///
	title("Probability of Outcomes By Pathway at Entry") note("Note: Probabilities for each outcome are stacked.", size(vsmall)) ///
	outcome1label("Y2 Retention") outcome2label("Y2 Persistence")

* Adjusted Outcomes by pathway of entry with covariates
mlogit_marginsplot_stacked outcome i.pathway_y1 ///
	i.age i.age#i.pathway_y1 i.male i.male#i.pathway_y1 ///
	i.pell i.pell#i.pathway_y1 i.firstgen i.firstgen#i.pathway_y1 ///
	i.race i.race#i.pathway_y1 c.gpa_term1 c.gpa_term1#i.pathway_y1 ///
	i.cohort_year using "$root/4_output/s2_pathway_stacked_cond.png", ///
	margins(pathway_y1) marginslabel(pathway_y1) title("Adjusted Probability of Outcomes by Pathway at Entry")	///
	note("Note: Probabilities for each outcome are stacked." "A regression model adjusts probabilities to account for student demographic traits, institution, and cohort.", size(vsmall)) ///
	outcome1label("Y2 Retention") outcome2label("Y2 Persistence")
		
		/* Note : given the number of dimensions in this analysis, 
			you need enough data for the analysis to converge and produce a plot. */
	
*	==========================================
*	PART 6. - Export all combinations of margin plots by pathway from the adjusted model
*	==========================================
	
/* Note : you need to run one mlogit command before running the marginplot 
	programs below. The marginplot program will be based on the output of the 
	mlogit regression. */	
	
** GPA, overall
marginplots_export pathway_y1, at("gpa_term1 = (2(0.25)4)") atlabel("Term1 GPA") file("$root/4_output/pathway_gpa.png")

** GPA by gender		
marginplots_double_export pathway_y1, at(male = (0(1)1) gpa_term1 = (2(0.25)4)) plotdimension(male) atlabel("Gender and Term1 GPA") at1label("Term1 GPA") file("$root/4_output/pathway_gpa_gender.png") xlabel(2(0.5)4)

** GPA by firstgen status		
marginplots_double_export pathway_y1, at(firstgen = (0(1)1) gpa_term1 = (2(0.25)4)) plotdimension(firstgen) atlabel("FirstGen Status and Term1 GPA") at1label("Term1 GPA") file("$root/4_output/pathway_gpa_firstgen.png") xlabel(2(0.5)4)

** GPA by race
marginplots_double_export pathway_y1, at(race = (1 2 5 6) gpa_term1 = (2(0.25)4)) plotdimension(race) atlabel("Race and Term1 GPA") at1label("Term1 GPA") file("$root/4_output/pathway_gpa_race.png") xlabel(2(0.5)4)

** Age, overall
marginplots_export pathway_y1, at("age = (1(1)3)") atlabel("Age at Entry") file("$root/4_output/pathway_age.png")

 		
*	==========================================
*	PART 7. - Credentials at Entry 
*	==========================================

	
* Unadjusted outcomes by credentials
mlogit_marginsplot_stacked outcome i.credential_entry using "$root/4_output/creds_stacked.png", margins(credential_entry) marginslabel(creds) title("Outcome By Credential Sought at Entry") 

* Adjusted outcomes by credentials	
mlogit_marginsplot_stacked outcome i.credential_entry i.age i.age#i.credential_entry ///
	c.gpa_term1 c.gpa_term1#i.credential_entry i.male i.male#i.credential_entry ///
	i.pell i.pell#i.credential_entry i.firstgen i.firstgen#i.credential_entry ///
	i.race i.race#i.credential_entry ///
	i.cohort_year using "$root/4_output/creds_stacked_cond.png", ///
	margins(credential_entry) marginslabel(creds) title("Adjusted Probability of Outcomes by Credential Sought at Entry")
	
	
marginplots_double_export credential_entry, at(race = (1 2 5 6) gpa_term1 = (2(0.25)4)) plotdimension(race) atlabel("Race and Term1 GPA") at1label("Term1 GPA") file("$root/4_output/creds_gpa_race.png") xlabel(2(0.5)4)
	
	
	