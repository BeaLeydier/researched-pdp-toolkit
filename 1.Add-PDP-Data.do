
/*******************************************************************************

		ADD PDP DATA		
				
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
*	PART 2. - Add the AR File Names
*	==========================================

	/* INSTRUCTIONS:
		Replace the file names in quotes with the names of the PDP Analysis
		Ready files you just saved under 1_data-pdp. 
		
		Do NOT change the names of the globals (arcohortfile and arcoursefile).
		
		Globals in Stata allow you to store once something that the code refers
		to frequently. The global works as a placeholder in the rest of the code.
		In this case, we are using the global arcohortfile to refer to your 
		AR Cohort File, and the global arcoursefile to refer to your AR Course 
		File. In the toolkit code, everytime we are calling one of these files, 
		we are calling the corresponding global name (preceded by $), and Stata 
		will automatically replace it with the name you defined here. This 
		avoids you having to change the filename in every line of code where 
		the file is being opened or referenced. You only have to change 
		it once here, and everywhere else in the code, these files are 
		referred to from the name of the globals directly.
	*/

* Name of your PDP AR files (including the file extension)
global arcohortfile "add-your-file-name-here.xlsx"
global arcoursefile "add-your-file-name-here.csv"
