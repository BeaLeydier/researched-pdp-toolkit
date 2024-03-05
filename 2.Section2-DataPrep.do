

/*
ssc install sankey
import excel using "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey_example2.xlsx?raw=true", clear first	

Add explanation on the format of the Sankey chart data

source      destination     number   year  
pathwaya      pathwaya		 x		  2
*/


use "2_data-toolkit/cohort-AR-transformed.dta", clear	

keep StudentID pathway_y1 pathway_y2 pathway_y3 pathway_y4 graduate graduate_other transfer no_creds cohort_year years_to_cred years_to_cred_otherinst latest_year latest_year_minus6 latest_year_minus3 credential_entry enroll_type

* keep the pathway of interest 
keep if pathway_y1 == 8

* save the pathway largest value across all four years
local max = 0
forvalues y = 1/4 {
sum pathway_y`y' 
local max`y' = `r(max)'  
if `max`y'' > `max' {
    local max = `max`y'' 
}
}
global max = `max'

* generate outcome variables
gen pathway_y5 = .
gen pathway_y6 = . 

replace pathway_y5 = 0 if no_creds == 1
replace pathway_y6 = 0 if no_creds == 1


/// Sankey reshape

* create the destination variable for each year 
forvalues year = 1/4 {
    rename pathway_y`year' destination_y`year'
}

* create the source variable for each year
gen source_y2 = destination_y1 
gen source_y3 = destination_y2
gen source_y4 = destination_y3

drop destination_y1

* reshape at the year level

reshape long source_y destination_y, i(StudentID) j(year)

* store pathway info in wide format 

levelsof destination_y, local(pathways)
foreach x in `pathways' { 
	gen destination_`x' = (destination_y == `x')
}

rename destination_y destination

* reshape long at the destination pathway level, and then the source pathway level

reshape long destination_, i(StudentID year) j(destpathway)

* collapse at the dest-source combo by year

collapse (sum) destination_ , by(year destpathway source)

* the value is in the destination column; the variables are destpathway and sourcepathway, to be labeled

label value destpathway pathway_entry
label value source pathway_entry

rename destination_ value 

exit

* sankey diagram 

sankey value, from(source) to(destpathway) by(year) palette(okabe) 
graph export "4_output/sankey-test.png", as(png) replace 
 

/* archives

levelsof source_y, local(pathways)
foreach x in `pathways' { 
	gen source_`x' = (source_y == `x')
}

rename source_y source

reshape long source_, i(StudentID year destpathway) j(sourcepathway)
