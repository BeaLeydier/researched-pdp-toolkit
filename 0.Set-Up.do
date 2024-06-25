
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

* INSTRUCTIONS: Define machine-specific file path 

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
*	PART 2. - Install custom user-written commands
*	==========================================

* Unique (data entry, pathway definition)
ssc install unique

* Sankey diagram program (analysis, section 2)
ssc install sankeyplot 

*	==========================================
*	PART 3. - Add custom ado path and colors
*	==========================================

* Add the toolkit's ado folder to Stata's recognized ado paths
adopath ++ "$root/0_scripts/ado" 

	/* Note : The ado folders are folders where Stata looks for programs, 
		styles, and other Stata-specific parameters. You can create your own
		programs and styles by adding them to an ado folder recognized by Stata,
		and following the appropriate Stata syntax.
		
		The adopath ++ command adds a particular folder in your machine to the
		list of folders where Stata looks for programs and styles. Here, we 
		are adding our own toolkit's ado folder to your Stata-recognized ado 
		folders, in order to add our custom colors to the Stata colors
		repertoire.
		
		We repeat that line of code at the top of every file that exports graphs, 
		in order to ensure that Stata always recognizes the custom colors.
	*/

* Print the custom colorpalette
colorpalette pdpblue pdpteal pdpmauve pdplavender pdporange1 pdporange2 pdporange3 pdporange4, rows(4) title("Custom PDP Palette") 
graph export "$root/4_output/custom-palette.png", as(png) 

	/* Note : We have printed below the RGB codes of the colors we use in this 
		toolkit, for information. The main colors are optimized for color-
		blindness. The pathway colors are different shades of orange, which is 
		not a shade present among the main colors, which makes the outcomes by 
		pathway visualizations easier to combine.
		
		If you want to change these default colors, to make them fit your own 
		color scheme or preferences, you can open the .styles files under the 
		ado subfolder, and update the RGB codes. If you update the color names, 
		you will also have to update them in the dofiles where the colors are 
		used to export graphs.
		
		-- Main colors 
			pdpblue : "51 34 136" //deep blue (cool and somewhat dark)
			pdpteal : "68 170 153" //teal (mid-bright and cool)
			pdpmauve : "136 34 85" //mauve (leans towards warm and medium in brightness)
			pdplavender : "170 136 187" //soft lavender (cool and mid-bright)
			
		-- Pathway colors 
			pdporange1 "187 119 85" // Burnt Orange (warm and mid-bright)
			pdporange2 "204 136 68" // Rust Orange (warm and mid-dark)
			pdporange3 "221 153 19" // Terracotta (warm and medium in brightness)
			pdporange4 "238 187 153" // Coral (warm and bright)
	*/

