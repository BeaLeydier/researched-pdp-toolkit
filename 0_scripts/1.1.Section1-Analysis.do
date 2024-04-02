
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
*		Analysis ready COHORT file
*	==========================================

* Load data
use "$root/2_data-toolkit/cohort-AR-transformed.dta", clear	
	
*	==========================================
*	PART 3. - Create combined outcome variable
*	==========================================
	
* Create one outcome variable
gen outcome = graduate 
replace outcome = 2 if graduate==0 & transfer==1

* Verify consistency
tab outcome no_creds, m 

label define outcomes 0 "None" 1 "First Completion" 2 "First Transfer" 
lab values outcome outcomes


*	==========================================
*	PART 4. - Define parameters : student population subset, chart colors 
*	==========================================

// Colors 

	/* Note : the color palette below is optimized for color-blindedness. */

global color1 "51 34 136" //deep purple (cool and somewhat dark)
global color2 "68 170 153" //teal (mid-bright and cool)
global color3 "136 34 85" //mauve (leans towards warm and medium in brightness)
global color4 "204 153 0" //soft amber (warm, not too bright, but clear enough)


// Student subset 

	/* Note on commenting on/off depending on type of institution. */

* For 2-year institutions : keep students who enrolled at least 3 years before the last PDP year
*keep if cohort_year <= latest_year_minus3

* For 4-year institutions : keep students who enrolled at least 6 years before the last PDP year
*keep if cohort_year <= latest_year_minus6
	
*	==========================================
*	PART 5. - Define custom programs for margins regression and plot exports
*	==========================================
	
*** Export stacked margins plot program 

cap program drop mlogit_marginsplot_stacked
program define mlogit_marginsplot_stacked

	syntax varlist(fv) [using/] [if/], ///variables following mlogit, plus any optional if condition (without the "if")
	 margins(varlist) ///variable for the margins
	 [marginslabel(string) * ///margins label plus the wildcard of options to have all the graphing options already defined
	 ]
	 	 
	*retrieve the outcome (first variable of the varlist)	 
	local outcome = word("`varlist'",1) 	
	
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
			bar(1, fcolor("$color1") lcolor(black)) bar(2, fcolor("$color2") lcolor(black)) ///
			ytitle("Probability") legend(label(1 "First Completion") label(2 "First Transfer")) ///
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
		]

margins `varlist', at(`at') predict(outcome(1)) predict(outcome(2))
marginsplot, bydimension(`varlist') byopts(title("Adjusted Probability of Outcomes" "by `atlabel'") graphregion(fcolor(white)) imargin(medium)) ///
			 ytitle("Adjusted Probability") xtitle("`atlabel'") ylabel(0(0.2)1) noci legend(order(1 "First Completion" 2 "First Transfer")) plotregion(margin(zero)) yline(0, lcolor(black)) ///
			 plot1opts(mcolor("$color1") lcolor("$color1")) plot2opts(mcolor("$color2") lcolor("$color2")) ///
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
		]

* Check how many plotdimensions we have		
quiet unique `plotdimension'	
local ndims = `r(unique)'
if `ndims' == 1 {
	dis as err "The plotdimension() variable you chose takes only one value in the whole dataset (no variation). Please choose a plotdimension() variable taking between 2 and 4 unique values."
	exit
}
else if `ndims' == 2 {
	local plotopts `" plot1opts(mcolor("$color1") lcolor("$color1")) plot2opts(mcolor("$color2") lcolor("$color2")) "'
}
else if `ndims' == 3 {
	local plotopts `" plot1opts(mcolor("$color1") lcolor("$color1")) plot2opts(mcolor("$color2") lcolor("$color2")) plot3opts(mcolor("$color3") lcolor("$color3")) "'
}
else if `ndims' == 4 {
	local plotopts `" plot1opts(mcolor("$color1") lcolor("$color1")) plot2opts(mcolor("$color2") lcolor("$color2")) plot3opts(mcolor("$color3") lcolor("$color3")) plot4opts(mcolor("$color4") lcolor("$color4")) "'
}
else if `ndims' > 4 {
	dis as err "The plotdimension() variable you chose takes more than 4 unique values in the whole dataset. For readability, this tool doesn't allow more than four dimensions to be plotted at a time. Please choose (and, if needed, create) a plotdimension() variable taking between 2 and 4 unique values."
}

margins `varlist', at(`at') predict(outcome(1)) 
marginsplot, bydimension(`varlist') plotdimension(`plotdimension') noci byopts(graphregion(fcolor(white)) rows(1) imargin(medium) title("")) ytitle("First Completion") xtitle("") ///
			 ylabel(0(0.2)1) xlabel(`xlabel') plotregion(margin(zero)) yline(0, lcolor(black)) `plotopts' ///
			 name(temp_a, replace)	
margins `varlist', at(`at') predict(outcome(2))
marginsplot, bydimension(`varlist') plotdimension(`plotdimension') noci byopts(graphregion(fcolor(white)) rows(1) imargin(medium) title("")) ytitle("First Transfer") xtitle("") ///
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
mlogit_marginsplot_stacked outcome i.pathway_y1 using "$root/4_output/pathway_stacked.png", margins(pathway_y1) marginslabel(pathway_y1) ///
	title("Probability of Outcomes By Pathway at Entry") note("Note: Probabilities for each outcome are stacked.", size(vsmall))

* Adjusted Outcomes by pathway of entry with covariates
mlogit_marginsplot_stacked outcome i.pathway_y1 ///
	i.age i.age#i.pathway_y1 i.male i.male#i.pathway_y1 ///
	i.pell i.pell#i.pathway_y1 i.firstgen i.firstgen#i.pathway_y1 ///
	i.race i.race#i.pathway_y1 c.gpa_term1 c.gpa_term1#i.pathway_y1 ///
	i.cohort_year using "$root/4_output/pathway_stacked_cond.png", ///
	margins(pathway_y1) marginslabel(pathway_y1) title("Adjusted Probability of Outcomes by Pathway at Entry")	///
	note("Note: Probabilities for each outcome are stacked." "A regression model adjusts probabilities to account for student demographic traits, institution, and cohort.", size(vsmall))
		
		/* Insert note on convergence */
			
	
*	==========================================
*	PART 6. - Export all combinations of margin plots by pathway from the adjusted model
*	==========================================
	
/* Insert note on running a mlogit program before these marginplot programs */	
	
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
	
	
	