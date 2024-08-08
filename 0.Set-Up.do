
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
			
		The lines of code below store the root of the local folder where this
		tool is saved in a global called root. As a reminder on globals in Stata, 
		they allow you to store once something that the code refers to 
		frequently. The global works as a placeholder in the rest of the code.
		To call a global in Stata, you use the global name preceded by $.
		In this case, we are using the global root to refer to your local 
		machine filepath where this tool is saved. In the toolkit code, each
		time we are calling a file in the tool, it will be called from $root,
		which will be automatically replaced by your own local filepath. This 
		ensures you only need to define the filepath once at the top of each 
		dofile, and not each time a file is read or exported.
		
		The local filepath typically changes from one user to the next. The if 
		condition below ensures that this file can be run on multiple machines 
		at once, which is particularly useful if you are collaborating on this 
		tool with multiple people, for example using github or a shared cloud 
		storage like Dropbox. In Stata, when we use an "if" condition followed 
		by brackets, the code inside the brackets is run only if the "if" 
		condition is true. Otherwise, that code is ignored, and Stata moves on 
		to the next lines of code after the brackets. The "else if" works the 
		same way : if the condition is true, it runs the code inside the 
		brackets that follow it, if not, it ignores it.
		
		Here, the first "if" condition will be true if the machine you are 
		running this file from has bl517 as its username (FYI this is the username of
		the developper of this tool), and if that is the case, the contents of 
		the code inside the brackets that follow the "if" will be run. 
		In this case, this code defines the global root, which is the 
		placeholder for the filepath of the root of the code folder 
		(this placeholder is used in all of this tool's code). Here, it is 
		defined as the filepath the user bl517 defined for their own machine. 
		When you are running the file on your own machine, that first "if" 
		condition will be false and that code ignored. 
		
		You can use the first "else if" condition to add your own username in the
		if condition (which will then return true when the file is run from 
		your own machine), and define your own local filepath as the global root.
		If you are collaborating on this tool with other people, you can add 
		another else if block of code (with subsequent brackets) for them to 
		add their username and define their own filepath in the global root.
		
		The final else condition returns an error message in red and exits the
		script (i.e stops the execution of the code) if none of the previous
		conditions returned true. That is, as long as you haven't added your 
		machine-specific username in the "else if" command, the script will 
		return an error. This functions as a reminder to do it, given none 
		of the subsequent code will work if you haven't defined the global root
		as you local machine-specific filepath.
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

