
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

use "2_data-toolkit/cohort-transformed.dta", clear	

	* Model: outcomes conditional only on initial pathway choice
	mlogit retention i.pathway_y1, robust 
	
	* Chart: pathway unadjusted margins
	margins, predict(outcome(1)) over(pathway_y1)
	marginsplot, noci recast(bar) plotopts(color(%70) barw(.6))
	
	/*
	{
	margins pathway, predict(outcome(1)) predict(outcome(2))
	matrix ans = (r(b))'
	cap frame drop working
	frame create working
	frame change working
	svmat2 ans, rnames(estimate_name)
	order estimate_name ans1
	rename ans1 prediction_
	gen outcome_level = ustrregexs(1) if ustrregexm(estimate_name, "^([0-9])")
	destring outcome_level, replace
	gen pathway_level = ustrregexs(1) if ustrregexm(estimate_name, "t.([0-9]+)")
	destring pathway_level, replace
	drop estimate_name
	order outcome_level pathway_level	
	reshape wide prediction_, i(pathway_level) j(outcome_level) 	
	label define pathway_vals 1 "Some Pathway" 2 "Another Pathway" 3 "One More Pathway" // please modify appropriately; unfortunately, value labels do not copy automatically into new frames
	label values pathway_level pathway_vals
	graph bar (asis) prediction_1 prediction_2, title("Probability of Completion First or Transferring First" "by Pathway") ytitle("Probability") b1("Pathway") over(pathway_level) ///
												stack ylabel(0(0.2)1) graphregion(fcolor(white)) legend(label(1 "Completion First") label(2 "Transfer First")) ///
												xsize(5.5) note("Note: Probabilities for each outcome are stacked.", size(vsmall)) bar(1, fcolor("51 34 136") lcolor(black)) bar(2, fcolor("68 170 153") ///
												lcolor(black)) // colors chosen for colorblindness accessibility
	graph export "${saved_graphs}/1_main.png", replace
	frame change default
	frame drop working		
	}
	*/
