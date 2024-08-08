

/*******************************************************************************

		SECTION 1 - Data Prep
		
		
		This file takes your PDP data and puts it in the format appropriate
		to run Section 1 of the Toolkit on them.
		
*******************************************************************************/

*	==========================================
*	PART 1. - Set Up 
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
quietly { //quietly ensures the code is run in the background without displaying any output
	do "$root/1.Add-PDP-Data.do"
	do "$root/2.3.Add-Pathway-Data.do"
	do "$root/3.Define-Institution-Parameters.do"
}

/* INSTRUCTIONS : replace "no" by "yes" if you want to run the pathway data 
	entry diagnostics when you add in the pathway data. */
global rundiagnostics "no"

*	==========================================
*	PART 2. - Load PDP data
*		Analysis ready COHORT file
*	==========================================

import excel "$root/1_data-pdp/$arcohortfile", firstrow clear

* Remove records without a StudentID
drop if StudentID == .

*	==========================================
*	PART 3.1 - Clean PDP data 
*		Verify uniqueness of student records 
*	==========================================

	/* Note : the analysis ready cohort file is supposed to be
		unique at the student-level. StudentID is used to uniquely
		identify student records. We verify here that it is the case as it
		will be a requirement for the rest of the analysis.
		If it is not the case, we first clean the duplicates.
	*/	
	
duplicates tag StudentID, gen(dup)
tab dup

duplicates drop StudentID, force	
drop dup	
	
isid StudentID 

*	==========================================
*	PART 3.2 - Clean PDP data 
*		Create attributes of interest 
*	==========================================

*** Gender

* Create one male variable with takes values 1 for males and 0 for females
gen male = .
replace male = 1 if strpos(Gender, "M")>0
replace male = 0 if strpos(Gender, "F")>0

	/* Note : in Stata, strpos(var, "string") returns the position in the variable
	var where the string "string" appears. For example, strpos(Gender, "M") will
	return 1 for the observations where Gender starts with M. If the string is not
	present in the variable, strpos returns 0. In the PDP data, the variable
	Gender takes value M for males, F for females and NA for not applicable. 
	However, because of possibly inconsistent formatting like leading or trailing 
	blanks, using a simple equality (replace male = 1 if Gender == "M") may not 
	identify all the cases where the variable takes the value M appropriately. 
	One approach would be to clean the Gender variable by removing leading and 
	trailing blanks before using the equality equation. Another approach is to use 
	strpos() which will return a strictly positive number if M is present in the 
	variable, no matter its position; and will return 0 if M is not present in 
	the variable (ie. either F or NA). */
	
* Check that the male variable correctly maps the Gender variable	
tab Gender male, m

* Apply value labels
label define male_vals 0 "Female" 1 "Male"
label values male male_vals

*** Race

* Remove leading and trailing blanks in the Race variable
replace Race = strtrim(Race)

* Collapse multiple consecutive internal blanks into one blank
replace Race = stritrim(Race)

* Create the race variable based on PDP values
gen race = . 
replace race = 1 if strpos(Race, "White") >0
replace race = 2 if strpos(Race, "Hispanic") >0
replace race = 3 if strpos(Race, "American Indian") >0
replace race = 3 if strpos(Race, "Alaska Native") >0
replace race = 4 if strpos(Race, "Native Hawaiian") >0
replace race = 4 if strpos(Race, "Pacific Islander") >0
replace race = 5 if strpos(Race, "Black") >0
replace race = 6 if strpos(Race, "Asian") >0
replace race = 97 if strpos(Race, "Two") >0
replace race = 98 if strpos(Race, "Nonresident") >0
replace race = 99 if strpos(Race, "Unknown") >0


	/* Note : we use strpos() for similar reasons as above. For the race
	categories that are combined (eg. American Indian or Alaska Native) we
	check the two phrases separately - and assign them the same value - in case
	the PDP data doesn't contain the full phrase but only one of the two.
	
	Below are the possible values according to the data dictionary:
		White
		Hispanic
		American Indian or Alaska Native
		Native Hawaiian or Other Pacific Islander
		Two or More Races
		Black or African American
		Nonresident alien
		Asian
		Unknown
		
	We reorder the categories to have the values Two or More Races, Nonresident
	alien and Unknown appear at the end of the list for more clarity in the outputs.
	*/
	
* Apply value labels
label define race_vals 1 "White" 2 "Hispanic" 3 "American Indian" 4 "Native Hawaiian" 5 "Black" 6 "Asian" 97 "Two or More" 98 "Nonresident alien" 99 "Unknown"
label values race race_vals 

* Check
tab Race race, m	
	
*** Parents Education Level 

	/* Note : We first need to count the missing observations because 
		a variable that contains only all-missing values will be imported
		as numeric by Stata, even if it would be string if there were some
		non-missing observations. Thus for the code to be robust to both
		cases where all values are missing and some values are non-missing, we
		need to differentiate between these two cases.
	*/

* Create a categorical variable
gen parents_postsecondaryed = . 

count if missing(FirstGen)
if r(N) < _N { //we only fill values if there is at least one non missing obs in FirstGen
	replace parents_postsecondaryed = 0 if strpos(FirstGen, "N")>0
	replace parents_postsecondaryed = 1 if strpos(FirstGen, "P")>0
	replace parents_postsecondaryed = 2 if strpos(FirstGen, "C")>0
	replace parents_postsecondaryed = 3 if strpos(FirstGen, "A")>0
	replace parents_postsecondaryed = 4 if strpos(FirstGen, "B")>0
}
		/* Note :
		N = No parent has attended post-secondary
		P = At least one parent has attended post-secondary but earned no credential or degree
		C = At least one parent has a certificate
		A = At least one parent has an Associate’s degree
		B = At least one parent has a Bachelor’s degree or higher
		*/
		
* Apply value labels
label define ed_vals 0 "Never Attended" 1 "Attended, No Degree" 2 "Certificate" 3 "Associate's" 4 "Bachelor's or more"
label values parents_postsecondaryed ed_vals

* Check
tab FirstGen parents_postsecondaryed, m

*** FirstGen 

* Create an indicator
gen firstgen = . 

count if missing(FirstGen)
if r(N) < _N { //we only fill values if there is at least one non missing obs in FirstGen
	replace firstgen = 0 if strpos(FirstGen,"N")==0 & FirstGen != ""
	replace firstgen = 1 if strpos(FirstGen,"N")>0 
}

* Labels
label define first 0 "At least one parent attended post-secondary" 1 "First-generation post-secondary student"
label values firstgen first

*** Transfer-In indicator 

gen enroll_type = .
replace enroll_type = 1 if strpos(EnrollmentType, "First")>0
replace enroll_type = 2 if strpos(EnrollmentType, "Transfer")>0

label define transfer 1 "First-Time" 2 "Transfer-In"
label val enroll_type transfer

tab EnrollmentType enroll_type, m


*** Student Age
encode(StudentAge), gen(age) //note: as a categorical 

*** Term1 GPA
rename GPAGroupTerm1 gpa_term1 

*** Pell Grant Status 
gen pell = (PellStatusFirstYear=="Y")

*** Cohort Year
gen cohort_year = ustrregexs(0) if ustrregexm(Cohort, "20([0-9]+)")
destring(cohort_year), replace

*	==========================================
*	PART 4. - Clean PDP data   
*		Generate an Entry Pathway variable		
*	========================================== 

* Add in Pathway labels from the Excel labeling template

if fileexists("$root/2_data-toolkit/$pathwaylabelsfile") {
	preserve 
		* update the name (and file path) of the xlsx file you just created with labels info.
		import excel using "$root/2_data-toolkit/$pathwaylabelsfile", firstrow clear
		* drop any missing rows created during the excel import
		drop if ProgramofStudy==.
		*check uniqueness
		isid ProgramofStudy
		* save as temp datafile for merging back with the main dataset
		tempfile labels
		save `labels'
	restore		
} 
else {
	dis as err "Please follow instructins in 2.2.Create-Pathway-Labeling-Template.do to label the pathways/programs of study in your PDP data. Change the appropriate file name to your filled pathway labels template file in the 2.3.Add-Pathway-Data dofile."
}

* Merge back with the main datasets to add the label columns for both program of study vars
	* note that keep(1 3) ensures no observation is added just from the excel template

* Merge for the Term1 program of study	
rename ProgramofStudyTerm1 ProgramofStudy
merge m:1 ProgramofStudy using `labels', nogen keep(1 3)
rename ProgramofStudy_Label ProgramofStudyTerm1_Label 
rename ProgramofStudy_ID ProgramofStudyTerm1_ID
rename ProgramofStudy ProgramofStudyTerm1

* Merge for the Year1 program of study	
rename ProgramofStudyYear1 ProgramofStudy
merge m:1 ProgramofStudy using `labels', nogen keep(1 3)
rename ProgramofStudy_Label ProgramofStudyYear1_Label 
rename ProgramofStudy_ID ProgramofStudyYear1_ID
rename ProgramofStudy ProgramofStudyYear1

*** Create a pathway_entry variable

* Create a numeric entry pathway variable and label it

gen pathway_entry = ProgramofStudyTerm1_ID
replace pathway_entry = ProgramofStudyYear1_ID if ProgramofStudyTerm1_ID == . & ProgramofStudyYear1_ID != .

/* IF ProgramofStudyTerm1 is string, the following code instead should work
destring(ProgramofStudyTerm1), gen(pathway_entry)
	
	/* Note :
			- This may generate an error if the codes are not all numeric
					If that is the case, please remove non-numeric characters
					in ProgramofStudyTerm1 BEFORE using the destring() command.
			- This will remove all the leading zeros from the numeric code
	*/ 
*/

* Create a string variable containing the label for the pathway_entry var 
gen pathway_entry_label = ProgramofStudyTerm1_Label
replace pathway_entry_label = ProgramofStudyYear1_Label if ProgramofStudyTerm1_Label == "" & ProgramofStudyYear1_Label != ""

* Label the pathway_entry variable
labmask pathway_entry, values(pathway_entry_label)
 

*	==========================================
*	PART 5. - Merge Year or Term Pathway   
*		Data previously generated by the user			
*	==========================================  

if "$studentpathwaytimeline" == "Year" {

*** Add in pathway data over years in wide format
preserve 
	* update the name (and file path) of the xlsx file you created with pathways year by year info.
	import excel "$root/2_data-toolkit/$studentpathwaysfile", firstrow clear
	
	* drop excess rows
	drop if StudentID == .
	
	* keep only relevant variables 
	keep StudentID AcademicYear ProgramofStudyYear_input
		/* Note : this avoids conflict down the line with the main PDP cohort 
			file when we merge the pathway information back. 
			
			Alternatively, an institution may want to keep some redundant data 
			here to double check the information on a student is consistent
			between the course and the cohort file.
		*/
	
	* merge with the pathway labeling file to obtain the pathway IDs for each year
	    *rename the year variable to be Term1 variable to match the labeling file	
		rename ProgramofStudyYear_input ProgramofStudy
		*merge with labeling file
		merge m:1 ProgramofStudy using `labels', nogen keep(1 3)
	
	* reshape wide at the student level 
		*identify continuous years for each student and drop academic year info
		sort StudentID AcademicYear
		by StudentID: gen year_y = _n 
		drop AcademicYear
		*rename variables to identify them as user entered
		rename ProgramofStudy ProgramofStudyYear_input 
		rename ProgramofStudy_ID ProgramofStudyYear_ID_input 
		rename ProgramofStudy_Label ProgramofStudyYear_Label_input 
		*reshape wide
		reshape wide ProgramofStudyYear@_input ProgramofStudyYear@_ID_input ProgramofStudyYear@_Label_input, i(StudentID) j(year_y)

	* Check that StudentID uniquely identifies the records
	isid StudentID 
	
	tempfile pathways
	save `pathways'
restore 

	* note : the assert(3) ensures no students are added from this operation
merge 1:1 StudentID using `pathways', nogen assert(1 3)

*** Clean and label pathway data over years 
	/* INSTRUCTION : change the number 6 below to the max number of years you 
		have observed for any student.*/
forvalues year=1/6 {
	gen pathway_y`year' = ProgramofStudyYear`year'_ID_input
	labmask pathway_y`year', values(ProgramofStudyYear`year'_Label_input)
}

	/*Note
		- Alternative code if the ProgramofStudyYear`year'_input var is string:
			destring(ProgramofStudyYear`year'_input), gen(pathway_y`year')
		- The value labels will be empty for any pathway not already defined in 
		the PDP data. Do we want to provide a second labeling opportunity/template
		here? (or maybe do just one labeling step after having merged in the
		year by year data)
	*/	 

}


if "$studentpathwaytimeline" == "Term" {

*** Add in pathway data over years in wide format
preserve 
	* update the name (and file path) of the xlsx file you created with pathways year by year info.
	import excel "$root/2_data-toolkit/$studentpathwaysfile", firstrow clear
	
	* drop excess rows
	drop if StudentID == .
	
	* keep only relevant variables 
	keep StudentID AcademicYear AcademicTerm_Num ProgramofStudyTerm_input
		/* Note : this avoids conflict down the line with the main PDP cohort 
			file when we merge the pathway information back. 
			
			Alternatively, an institution may want to keep some redundant data 
			here to double check the information on a student is consistent
			between the course and the cohort file.
		*/
	
	* merge with the pathway labeling file to obtain the pathway IDs for each year
	    *rename the year variable to be Term1 variable to match the labeling file	
		rename ProgramofStudyTerm_input ProgramofStudy
		*merge with labeling file
		merge m:1 ProgramofStudy using `labels', nogen keep(1 3)
	
	* reshape wide at the student level 
		*identify continuous years for each student and drop academic year info
		sort StudentID AcademicYear AcademicTerm_Num
		by StudentID: gen term_t = _n 
		drop AcademicYear AcademicTerm_Num
		*rename variables to identify them as user entered
		rename ProgramofStudy ProgramofStudyTerm_input 
		rename ProgramofStudy_ID ProgramofStudyTerm_ID_input 
		rename ProgramofStudy_Label ProgramofStudyTerm_Label_input 
		*reshape wide
		reshape wide ProgramofStudyTerm@_input ProgramofStudyTerm@_ID_input ProgramofStudyTerm@_Label_input, i(StudentID) j(term_t)

	* Check that StudentID uniquely identifies the records
	isid StudentID 
	
	tempfile pathways
	save `pathways'
restore 

	* note : the assert(3) ensures no students are added from this operation
merge 1:1 StudentID using `pathways', nogen assert(1 3)

*** Clean and label pathway data over years 
	/* INSTRUCTION : change the number 6 below to the max number of years you 
		have observed for any student.*/
forvalues term=1/12 {
	gen pathway_t`term' = ProgramofStudyTerm`term'_ID_input
	labmask pathway_t`term', values(ProgramofStudyTerm`term'_Label_input)
}	

	/*Note
		- Alternative code if the ProgramofStudyYear`year'_input var is string:
			destring(ProgramofStudyYear`year'_input), gen(pathway_y`year')
		- The value labels will be empty for any pathway not already defined in 
		the PDP data. Do we want to provide a second labeling opportunity/template
		here? (or maybe do just one labeling step after having merged in the
		year by year data)
	*/	 

}


*	==========================================
*	PART 5. OPTIONAL - Data  Diagnostics
*		On Pathway Data Entry			
*	==========================================  

if "$rundiagnostics" != "no" {

	/* Note
		There are a few diagnostics we can do at this stage, and export separately.
			1. Students whose pathway from term1 or year1 in the PDP data isn't the same
				as their pathway in year1 from the user-entered Excel
			2. Pathway numbers from the user-entered Excel that are new compared 
				to the list of pathways included in the PDP Program of Study variable 
	*/

	* Flag pathway inconsistencies
	gen flag_pathway_y1 = 0
	replace flag_pathway_y1 = 1 if ProgramofStudyYear1 != ProgramofStudyYear1_input & !missing(ProgramofStudyYear1) & !missing(ProgramofStudyYear1_input)
	lab var flag_pathway_y1 "Flag: Inconsistent Pathway in Year1 between AR file and user input"

	* Flag new pathways
	gen flag_pathway_new = 0
	gen flag_pathway_new_years = ""
	levelsof(ProgramofStudyYear1), local(programs) //compare to list of program of studies listed in Year1 var
	forvalues year = 1/4 {
		tostring(ProgramofStudyYear`year'_input), replace
		replace flag_pathway_new = 1 if strpos(`"`programs'"', ProgramofStudyYear`year'_input) == 0
		replace flag_pathway_new_years = flag_pathway_new_years + "Year`year' " if strpos(`"`programs'"', ProgramofStudyYear`year'_input) == 0
	}
	levelsof(ProgramofStudyTerm1), local(programs) //compare to list of program of studies listed in Term1 var
	forvalues year = 1/4 {
		tostring(ProgramofStudyYear`year'_input), replace
		replace flag_pathway_new = 1 if strpos(`"`programs'"', ProgramofStudyYear`year'_input) == 0
		replace flag_pathway_new_years = flag_pathway_new_years + "Year`year' " if strpos(`"`programs'"', ProgramofStudyYear`year'_input) == 0
	}
	lab var flag_pathway_new "Flag: Program of Study Code Non-Present in the PDP AR File"
		
	* Export flagged values
	local varstoexport "FirstName MiddleName LastName DateofBirth StudentID AttendanceStatusTerm1 CredentialTypeSoughtYear1 ProgramofStudyTerm1 pathway_entry ProgramofStudyYear1 ProgramofStudyYear1_input pathway_y1 ProgramofStudyYear2_input pathway_y2 ProgramofStudyYear3_input pathway_y3 ProgramofStudyYear4_input pathway_y4 flag_pathway_y1 flag_pathway_new flag_pathway_new_years"	
	cap export excel `varstoexport' if flag_pathway_y1==1 using "$root/3_data-diagnostics/Pathway_diagnostics.xlsx", first(variable) replace sheet("Y1 Inconsistency")
	cap export excel `varstoexport' if flag_pathway_new==1 using "$root/3_data-diagnostics/Pathway_diagnostics.xlsx", first(variable) sheet("New Pathway", replace)

	drop flag_*

}

*	==========================================
*	PART 6. - Clean PDP data   
*		Create an Entry Credential variable			
*	========================================== 

	/* Note : This is an alternative pathway-like variable that can be 
			an interesting analysis dimension for the colleges. */
			
	
	/* Labels in the data dictionary:
		C1 = Less than one-year certificate, less than Associate degree
		C2 = One to two year certificate, less than Associate degree
		C4 = Two to four year certificate, less than Bachelor’s degree
		01 = Undergraduate Certificate or Diploma Program
		A or 02 = Associate Degree
		B or 03 = Bachelor’s Degree
		PB or 04 = Post Baccalaureate Certificate
		M or 05 = Master’s Degree
		D or 06 = Doctoral Degree
		FP or 07 = First Professional Degree
		PC or 08 = Graduate/Professional Certificate
		NC or 99 = Non- Credential Program (Preparatory Coursework/Teach Certification)
		−1= Missing
	*/
	
* Create a categorical 

* Remove leading, trailing and consecutive internal blanks in the variable
replace CredentialTypeSoughtYear1 = strtrim(CredentialTypeSoughtYear1)
replace CredentialTypeSoughtYear1 = stritrim(CredentialTypeSoughtYear1)

gen credential_entry = . 
replace  credential_entry = 1 if strpos(CredentialTypeSoughtYear1, "C1") >0
replace  credential_entry = 2 if strpos(CredentialTypeSoughtYear1, "C2") >0
replace  credential_entry = 3 if strpos(CredentialTypeSoughtYear1, "C4") >0
replace  credential_entry = 4 if strpos(CredentialTypeSoughtYear1, "01") >0
replace  credential_entry = 5 if CredentialTypeSoughtYear1 == "A" | strpos(CredentialTypeSoughtYear1, "02") >0 | strpos(CredentialTypeSoughtYear1, "Associate Degree") >0
replace  credential_entry = 6 if CredentialTypeSoughtYear1 == "B" | strpos(CredentialTypeSoughtYear1, "03") >0 | strpos(CredentialTypeSoughtYear1, "Bachelor's Degree") >0
replace  credential_entry = 7 if CredentialTypeSoughtYear1 == "PB" | strpos(CredentialTypeSoughtYear1, "04") >0 |strpos(CredentialTypeSoughtYear1, "Post Baccalaureate Certificate") >0
replace  credential_entry = 8 if CredentialTypeSoughtYear1 == "M" | strpos(CredentialTypeSoughtYear1, "05") >0 | strpos(CredentialTypeSoughtYear1, "Master's Degree") >0
replace  credential_entry = 9 if CredentialTypeSoughtYear1 == "D" | strpos(CredentialTypeSoughtYear1, "06") >0 | strpos(CredentialTypeSoughtYear1, "Doctoral Degree") >0
replace  credential_entry = 10 if CredentialTypeSoughtYear1 == "FP" | strpos(CredentialTypeSoughtYear1, "07") >0 | strpos(CredentialTypeSoughtYear1, "First Professional Degree") >0
replace  credential_entry = 11 if CredentialTypeSoughtYear1 == "PC" | strpos(CredentialTypeSoughtYear1, "08") >0 | strpos(CredentialTypeSoughtYear1, "Graduate/Professional Certificate") >0
replace  credential_entry = 99 if CredentialTypeSoughtYear1 == "NC"| strpos(CredentialTypeSoughtYear1, "99") >0 | strpos(CredentialTypeSoughtYear1, "Non- Credential Program") >0
replace  credential_entry = . if CredentialTypeSoughtYear1 == "-1"

tab CredentialTypeSoughtYear1 credential_entry, m
	
* Define labels
label define creds 1 "< 1-Year Certificate" 2 "1-2-Year Certificate" 3 "2-4-Year Certificate" 4 "Undergrad Certificate" 5 "Associate" 6 "Bachelor's" 7 "Post-Bac Certificate" 8 "Master's" 9 "Doctoral" 10 "First Professional Degree" 11 "Grad/Professional Certificate" 99 "Non-Credential Program"	
label value credential_entry creds
	
	
*	==========================================
*	PART 7. - Clean PDP data   
*		Create short term outcome variables			
*	========================================== 
	
rename Retention retention 
lab var retention "Retention After Y1" 	

rename Persistence persistence 
lab var persistence "Persistence After Y1" 	

gen switch_program_y1 = (ProgramofStudyYear1 != ProgramofStudyTerm1) & ProgramofStudyYear1 != . & ProgramofStudyTerm1 != .
lab var switch_program_y1 "Switched Program within Y1"

*	==========================================
*	PART 8. - Clean PDP data   
*		Create long term outcome variables			
*	========================================== 
	
gen graduate = (YearstoBachelorsatCohortIn != 0) | (YearstoAssociatesorCertific != 0)	
lab var graduate "Complete (Cohort Inst.)"

gen graduate_other = (YearstoBachelorsatOtherIns != 0) | (AY != 0)
lab var graduate_other "Transfer and Complete (Other Inst.)"

gen transfer = (YearofLastEnrollmentotheri != 0)
lab var transfer "Transfer"

gen years_to_cred = YearstoBachelorsatCohortIn
replace years_to_cred = YearstoAssociatesorCertific if years_to_cred == 0
lab var years_to_cred "Years to Completion (Cohort Inst.)"

tab years_to_cred graduate, m
	//check consistency: that all the 0 for graduate are also 0 for years to cred
	
gen years_to_cred_otherinst = YearstoBachelorsatOtherIns
replace  years_to_cred_otherinst = AY if years_to_cred_otherinst == 0
lab var years_to_cred_otherinst "Years to Completion (Other Inst.)"

tab years_to_cred_otherinst graduate_other, m
	//check consistency
	
gen no_creds = (years_to_cred == 0) & (years_to_cred_otherinst == 0)
lab var no_creds "No Credentials Earned"

*	==========================================
*	PART 9. - Clean PDP data   
*		Create time relative variables			
*	========================================== 

* Obtain the latest (max) cohort year in this file 
egen latest_year = max(cohort_year)

* Calculate the latest year minus 6 (analysis will be limited to students enrolled PRIOR to that date for the 4-year institutions)
gen latest_year_minus6 = latest_year - 6

* Calculate the latest year minus 3 (analysis will be limited to students enrolled PRIOR to that date for the 2-year institutions)
gen latest_year_minus3 = latest_year - 3


*	==========================================
*	PART 99. - Save transformed data   
*	========================================== 
	
save "$root/2_data-toolkit/section1_student.dta", replace	
	
* Save labels for the graphs later
label save using "$root/2_data-toolkit/pathwaylabels.do", replace	
