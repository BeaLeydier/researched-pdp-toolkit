
/*******************************************************************************

		SET UP
		
		
		This dofile installs all the user written progams and reads the custom 
			Stata colors required for generating the program.
		
*******************************************************************************/

*	==========================================
*	PART 1. - File path
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
*	PART 2. - Custom ado path and colors
*	==========================================

* Add the local ado folder to Stata's ado paths
adopath ++ "$root/0_scripts/ado" 

	/* Note : insert explanation of ado file/folder.*/

* Print the custom colorpalette
colorpalette pdpblue pdpteal pdpmauve pdplavender pdporange1 pdporange2 pdporange3 pdporange4, rows(4) title("Custom PDP Palette") 
graph export "$root/4_output/custom-palette.png", as(png) 

	/* Note : insert instructions on custom colors.
			// main pdp colors 
			global color1 "51 34 136" //deep blue (cool and somewhat dark)
			global color2 "68 170 153" //teal (mid-bright and cool)
			global color3 "136 34 85" //mauve (leans towards warm and medium in brightness)
			global color4 "170 136 187" //soft lavender (cool and mid-bright)

			// pathway colors 
			global pathwaycolor1 "187 119 85" // Burnt Orange (warm and mid-bright)
			global pathwaycolor2 "204 136 68" // Rust Orange (warm and mid-dark)
			global pathwaycolor3 "221 153 19" // Terracotta (warm and medium in brightness)
			global pathwaycolor4 "238 187 153" // Coral (warm and bright)
	*/

*	==========================================
*	PART 3. - Custom User Written Commands
*	==========================================

* Unique (data entry, pathway definition)
ssc install unique

* Sankey diagram program (analysis, section 2)
ssc install sankeyplot 
