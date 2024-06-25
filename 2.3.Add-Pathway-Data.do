
/*******************************************************************************

		ADD PATHWAY DATA NAME		
				
*******************************************************************************/

*	==========================================
*	PART 1. - Add your PDP Analysis Ready Files to the 1_data-pdp subolder
*	==========================================

	/* INSTRUCTIONS:
		Find your PDP Analysis Ready Files, copy and save them under 
		the 1_data-pdp subfolder of this toolkit. 
		
		For this toolkit, we are only using the AR Cohort file and the AR 
		Course file, so you only need to copy these two in that folder.
	*/

*	==========================================
*	PART 2. - Add the Pathway Data File Names
*	==========================================

	/* INSTRUCTIONS:
		Replace the file names in quotes with the names of the student pathway 
		data files you just saved under 2_data-toolkit. 
		
		Do NOT change the names of the globals (studentpathwaysfile, 
		pathwaylabelsfile and studentpathwaytimeline).
		
		Globals in Stata allow you to store once something that the code refers
		to frequently. The global works as a placeholder in the rest of the code.
		In this case, we are using the global studentpathwaysfile to refer to your 
		student pathway data file, the global pathwaylabelsfile to refer to your 
		pathway labeling file, and the global studentpathwaytimeline to define
		whether you are using a year or a term based analysis timeline (the 
		default is Year). 
		
		In the toolkit code, everytime we are calling one of these files, 
		we are calling the corresponding global name (preceded by $), and Stata 
		will automatically replace it with the name you defined here. This 
		avoids you having to change the filename in every line of code where 
		the file is being opened or referenced. You only have to change 
		it once here, and everywhere else in the code, these files are 
		referred to from the name of the globals directly.
		
		Similarly, the studentpathwaytimeline global is used as a switch later 
		in the code, to run the Year portion of the code instead of the Term 
		portion of the code.
	*/

* Name of the file where you define the student pathways (once filled)
global studentpathwaysfile "add-your-file-name-here.xlsx"

* Name of the file where you define the pathway labels (once filled)
global pathwaylabelsfile "add-your-file-name-here.xlsx"

* Change the word Year below to the word Term if you are doing a Term level analysis
global studentpathwaytimeline "Year"
