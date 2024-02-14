
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

use "$root/2_data-toolkit/cohort-AR-transformed.dta", clear	

label save using "$root/2_data-toolkit/pathwaylabels.do", replace
	
	* Gen fake outcome and creds data for testing
	gen outcome = 0 if retention==0 & Persistence==0
	replace outcome = 1 if retention==1 
	replace outcome = 2 if Persistence==1
	replace outcome=2 if outcome==0
	
	replace credential_entry = 6 if _n <=2 
	
	*** margins plot : stacking program
	cap program drop mlogit_marginsplot_stacked
	program define mlogit_marginsplot_stacked
	
		syntax varlist(fv) [using/] [if/], ///variables following mlogit, plus any optional if condition (without the "if")
		 margins(varlist) ///variable for the margins
		 [marginslabel(string) ///
		 title(string) ///
		 subtitle(string) ///
		 ]
		 
		*retrieve the outcome (first variable of the varlist)	 
		local outcome = word("`varlist'",1) 	
		
		* run the mlogit regression and the margins command
		mlogit `varlist', robust 
		margins `margins', predict(`outcome'(1)) predict(`outcome'(2))
		
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
				bar(1, fcolor("51 34 136") lcolor(black)) bar(2, fcolor("68 170 153") lcolor(black)) ///
				title("`title'") subtitle("`subtitle'")
			graph export "`using'", replace
		restore
	end

	mlogit_marginsplot_stacked outcome i.pathway_y1 using "$root/4_output/outcome_stacked.png", margins(pathway_y1) marginslabel(pathway_entry) title("Outcome By Pathway")
	
	mlogit_marginsplot_stacked outcome i.credential_entry, margins(credential_entry) marginslabel(creds)
	
	exit
	
	
	/**
	
	*** margins plot : no stacking
	mlogit outcome i.pathway_y1, robust 
	margins pathway_y1, predict(outcome(1)) predict(outcome(2))
	marginsplot, noci recast(bar) plotopts(color(%70)) 
	
	* predict + graph bar : stacking (this works for NO interaction)
	mlogit outcome i.pathway_y1, robust 
	predict p1, outcome(1)
	predict p2, outcome(2)
	graph bar (mean) p1 p2, stack over(pathway_y1) 
	
	
	*/	
		
		
	
	
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
