clear all
set more off
capture log close

/*
•	Input: bene_status_yearYYYY.dta, bene_demog2013.dta, bsfccYYYY.dta, 02-13.
•	Output: in each year, outputs prevalence rate for ADRD (ccw), for all and by age 67-74,75-84,85+)
•	Sample is 3 year FFS, 67+ from 2004 on; 2002 & 2003 has 1 or 2 years of FFS coverage
*/


//////////////////  FFS SAMPLE (2002-2013 pooled) //////////////////

////////  	2002  //////////
use "../bene_status_year2002.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2002 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2002.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

//bene_id has repeats in 2002-2005. Unique from 2006 on. 
sort bene_id
drop if bene_id==bene_id[_n-1]
merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2002

gen AD = 0
replace AD = 1 if year(alzhe)<=2002

gen insamp2002 = (ffs2002==1 & age_beg>=67 & age_beg!=.)

save "../samp2002.dta", replace


////////  	2003  //////////
use "../bene_status_year2003.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2003 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2003.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

//bene_id has repeats in 2003-2005. Unique from 2006 on. 
sort bene_id
drop if bene_id==bene_id[_n-1]
merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2003

gen AD = 0
replace AD = 1 if year(alzhe)<=2003

merge 1:1 bene_id using "../samp2002.dta", keepusing(bene_id ffs2002)
drop _m

gen insamp2003 = (ffs2002==1 & ffs2003==1 & age_beg>=67 & age_beg!=.)

save "../samp2003.dta", replace



////////  	2004  //////////
use "../bene_status_year2004.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2004 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2004.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

//bene_id has repeats in 2003-2005. Unique from 2006 on. 
sort bene_id
drop if bene_id==bene_id[_n-1]
merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2004

gen AD = 0
replace AD = 1 if year(alzhe)<=2004

merge 1:1 bene_id using "../samp2003.dta", keepusing(bene_id ffs2003 ffs2002)
drop _m

gen insamp2004 = (ffs2002==1 & ffs2003==1 & ffs2004==1 &  age_beg>=67 & age_beg!=.)

save "../samp2004.dta", replace



////////  	2005  //////////
use "../bene_status_year2005.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2005 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2005.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

//bene_id has repeats in 2003-2005. Unique from 2006 on. 
sort bene_id
drop if bene_id==bene_id[_n-1]
merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2005

gen AD = 0
replace AD = 1 if year(alzhe)<=2005

merge 1:1 bene_id using "../samp2004.dta", keepusing(bene_id ffs2004 ffs2003)
drop _m

gen insamp2005 = (ffs2003==1 & ffs2004==1 & ffs2005==1 &  age_beg>=67 & age_beg!=.)

save "../samp2005.dta", replace


////////  	2006  //////////
use "../bene_status_year2006.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2006 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2006.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2006

gen AD = 0
replace AD = 1 if year(alzhe)<=2006

merge 1:1 bene_id using "../samp2005.dta", keepusing(bene_id ffs2004 ffs2005)
drop _m

gen insamp2006 = (ffs2004==1 & ffs2005==1 & ffs2006==1 &  age_beg>=67 & age_beg!=.)

save "../samp2006.dta", replace



////////  	2007  //////////
use "../bene_status_year2007.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2007 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2007.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2007

gen AD = 0
replace AD = 1 if year(alzhe)<=2007

merge 1:1 bene_id using "../samp2006.dta", keepusing(bene_id ffs2006 ffs2005)
drop _m

gen insamp2007 = (ffs2007==1 & ffs2005==1 & ffs2006==1 &  age_beg>=67 & age_beg!=.)

save "../samp2007.dta", replace


////////  	2008  //////////
use "../bene_status_year2008.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2008 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2008.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2008

gen AD = 0
replace AD = 1 if year(alzhe)<=2008

merge 1:1 bene_id using "../samp2007.dta", keepusing(bene_id ffs2006 ffs2007)
drop _m

gen insamp2008 = (ffs2007==1 & ffs2008==1 & ffs2006==1 &  age_beg>=67 & age_beg!=.)

save "../samp2008.dta", replace


////////  	2009  //////////
use "../bene_status_year2009.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2009 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2009.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2009

gen AD = 0
replace AD = 1 if year(alzhe)<=2009

merge 1:1 bene_id using "../samp2008.dta", keepusing(bene_id ffs2008 ffs2007)
drop _m

gen insamp2009 = (ffs2007==1 & ffs2008==1 & ffs2009==1 &  age_beg>=67 & age_beg!=.)

save "../samp2009.dta", replace


////////  	2010  //////////
use "../bene_status_year2010.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2010 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2010.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2010

gen AD = 0
replace AD = 1 if year(alzhe)<=2010

merge 1:1 bene_id using "../samp2009.dta", keepusing(bene_id ffs2008 ffs2009)
drop _m

gen insamp2010 = (ffs2010==1 & ffs2008==1 & ffs2009==1 &  age_beg>=67 & age_beg!=.)

save "../samp2010.dta", replace


////////  	2011  //////////
use "../bene_status_year2011.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2011 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2011.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2011

gen AD = 0
replace AD = 1 if year(alzhe)<=2011

merge 1:1 bene_id using "../samp2010.dta", keepusing(bene_id ffs2010 ffs2009)
drop _m

gen insamp2011 = (ffs2010==1 & ffs2011==1 & ffs2009==1 &  age_beg>=67 & age_beg!=.)

save "../samp2011.dta", replace


////////  	2012  //////////
use "../bene_status_year2012.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2012 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2012.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2012

gen AD = 0
replace AD = 1 if year(alzhe)<=2012

merge 1:1 bene_id using "../samp2011.dta", keepusing(bene_id ffs2010 ffs2011)
drop _m

gen insamp2012 = (ffs2010==1 & ffs2011==1 & ffs2012==1 &  age_beg>=67 & age_beg!=.)

save "../samp2012.dta", replace


////////  	2013  //////////
use "../bene_status_year2013.dta", clear
keep bene_id enrFFS_allyr enrAB_mo_yr age_beg race_bg year sex

gen ffs2013 = (enrFFS_allyr == "Y" & enrAB_mo_yr == 12) // no missing

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
gen race_dw = race_bg == "1" if !missing(race_bg)
gen race_db = race_bg == "2" if !missing(race_bg)
gen race_dh = race_bg == "5" if !missing(race_bg)
gen race_do = 0 if !missing(race_bg)
replace race_do = 1 if race_bg=="0" | race_bg=="3" | race_bg=="4" | race_bg=="6" | race_bg==""

drop enrFFS_allyr enrAB_mo_yr

tempfile status
save `status', replace

use "../bene_demog2014.dta", clear
keep bene_id dropflag
drop if dropflag=="Y" //make sure no bigprob or >120 or >90 or no claims
merge 1:1 bene_id using `status'
keep if _m==3
drop _m
tempfile enrollees
save `enrollees', replace

use "../bsfcc2013.dta", clear  //need to check selected ccw codes and whether verified
keep bene_id alzh*

merge 1:1 bene_id using `enrollees'
drop _m

gen ADRD = 0
replace ADRD = 1 if year(alzhdmte)<=2013

gen AD = 0
replace AD = 1 if year(alzhe)<=2013

merge 1:1 bene_id using "../samp2012.dta", keepusing(bene_id ffs2012 ffs2011)
drop _m

gen insamp2013 = (ffs2013==1 & ffs2011==1 & ffs2012==1 &  age_beg>=67 & age_beg!=.)

save "../samp2013.dta", replace


////// pooling years together to get long file ///////

use "../samp2013.dta", clear
keep bene_id year age_beg sex race* insamp* AD* 

append using "../samp2012.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1

append using "../samp2011.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1

append using "../samp2010.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1

append using "../samp2009.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1

append using "../samp2008.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1

append using "../samp2007.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 

append using "../samp2006.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1

append using "../samp2005.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1

append using "../samp2004.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 

append using "../samp2003.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 | insamp2003 == 1 

append using "../samp2002.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 | insamp2003 == 1 | insamp2002 == 1 

sort bene_id year
unique bene_id
list in 1/20

save "../samp0213.dta", replace


////// pooling years together to get long file ///////

use "../samp2013.dta", clear
keep bene_id year age_beg sex race* insamp* AD* 

append using "../samp2012.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1

append using "../samp2011.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1

append using "../samp2010.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1

append using "../samp2009.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1

append using "../samp2008.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1

append using "../samp2007.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 

append using "../samp2006.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1

append using "../samp2005.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1

append using "../samp2004.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 

append using "../samp2003.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 | insamp2003 == 1 

append using "../samp2002.dta", keep(bene_id year age_beg sex race* insamp* AD*)
keep if insamp2013 == 1 | insamp2012 == 1 | insamp2011 == 1 | insamp2010 == 1 | insamp2009 == 1 | insamp2008 == 1 | insamp2007 == 1 | insamp2006 == 1 | insamp2005 == 1 | insamp2004 == 1 | insamp2003 == 1 | insamp2002 == 1 

sort bene_id year

save "../samp0213.dta"

//race - 0 unknown, 1 white, 2 black, 3 other, 4 asian/pacific islander, 5 hispanic, 6 american indian/alaskan native
destring race_bg, gen(race_bgn)
recode race_bgn (0 3 4 6=99 "99.other") (1=1 "1.white") (2=2 "2.black") (5=3 "3.hispanic"), gen(race) label(race)
tab race race_bgn, m
tab race, m

recode age_beg (-9/66.999=.)(67/74.999=1)(75/84.999=2)(85/120=3), gen(agegroup)
lab def age 1 "1.67-74" 2 "2.75-84" 3 "3.85+"
lab val agegroup age
tab agegroup, m

destring sex, replace
recode sex (1=0 "0.male") (2=1 "1.female"), gen(female) label(female)
tab sex female, m
tab female, m

save "../samp0213.dta", replace

use "../adrd_dxdate_2002_2014.dta", clear
keep if inrange(year,2004,2013)
bys bene_id: egen n_dx=count(dx_max)
sum n_dx
label var n_dx "# of any-type dementia dx 04-13"
drop if bene_id==bene_id[_n-1]
keep bene_id n_dx
merge 1:m bene_id using "../samp0213.dta"
gen ADRD_ver = 0
replace ADRD_ver=1 if ADRD ==1 & n_dx>=2 & !missing(n_dx)
tab ADRD ADRD_ver, row
forvalues i=2004/2013{
	tab ADRD ADRD_ver if year==`i', row
}
save "../samp0413_ADver.dta", replace




