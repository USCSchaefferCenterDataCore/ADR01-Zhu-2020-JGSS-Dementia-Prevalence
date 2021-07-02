* YZ August 2017 Dementia_HRS 
clear all 
capture log close
set more off
set maxvar 30000
global hrsfat /schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/Stata
global dementia /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia
global rand_hrs "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_p.dta"
global input $dementia/Input
global output $dementia/Output
log using $output/dementia_hrs, text replace
//include $dementia/Dofile/common.do
use $input/randhrs_clean, clear
* Merge with tics data
merge 1:1 hhidpn wave using $input/tics
tab wave _merge
drop _merge
sort hhidpn wave
tab ser7 wave
* Dementia Measure: single year and "confirmed" dementia
sort hhidpn wave,stable
gen dementia =1.cogstate
bys hhidpn (wave): egen firsttime=min(cond(cogstate==1),wave,.) //if cogstate==1, firsttime=min wave when (cogstate==1); otherwise firsttime=wave
gen dementiae=dementia
replace dementiae=1 if wave>=firsttime  & dementiae ==0        //if wave>firsttime, then dementia, absorbed 
tab wave dementia
tab wave dementiae  //higher pravelence
label var dementia "Respondent has dementia this wave"
label var dementiae "Ever had dementia"

*Confirmed dementia
gen dementiae_strict=dementia
bys hhidpn (wave): egen confirmed = min(cond(inlist(cogstate[_n+1],1,2) & cogstate==1,wave,.)) // if cogstate in the next wave is dementia or CIND and cogstate in the current wave is dmeentia, confirmed=min; otherwise confirmed=wave
replace dementiae_strict = 0 if dementia== 1 & wave < confirmed
gen dementia_strict=dementiae_strict
* fill forward once confirmed
replace dementiae_strict = 1 if dementiae_strict == 0 & wave >= confirmed //if current wave < confirmed in previous waves, then not demented; if wave>=confirmed, then dementia in the current wave can be confirmed ; absorbed
label var dementiae_strict "Confirmed dementia (subsequent wave has either dementia on CIND)"
gen f2died = f.died
replace dementiae_strict = 1 if f2died == 1 & dementia == 1 & dementiae_strict == 0  //died with dementia are counted as having dementia 
replace dementia_strict=1 if f2died==1 & dementia==1 & dementia_strict==0
lab var dementia_strict "Confirmed,Unabsorbed"

*Switch
bys hhidpn (wave): gen fswitch = 1 if dementia[_n] ==0 & dementia[_n-1]==1
replace fswitch = 0 if !missing(dementia)&fswitch !=1
bys hhidpn (wave): egen switch = max(fswitch) if !missing(dementia)
* In sum two measures: dementiae (absorbed and less strict) and dementiae_strict ("confirmed" dementia in subsequent waves , more strict)
* dementiae_strict in wave 2 may not be accurate as wave 1 dementia unobserved => wave 3 and above can be fine
* Rename and Recoding
recode age (-10/69.99=0)(70/79.99=1)(80/89.99=2)(90/200=3)(200/.=.),gen(agegroup_h)
ren age age_h
lab var age_h "Age HRS"
lab var agegroup_h "Age group HRS"
lab val agegroup_h agegroup
lab def agegroup 0"Below 70"1"70 to 79"2"80 to 89"3 "90 and above"
ren rahispan hispan_h
gen white_h = (raracem==1 & !hispan_h) if !missing(raracem)
gen black_h= (raracem==2 & !hispan_h) if  !missing(raracem)
gen race_h = 1 if white_h
replace race_h=2 if black_h
replace race_h=3 if hispan_h
lab var race_h "Ethnic Group HRS"
lab val race_h race
lab def race 1"non-hispanic white" 2"non-hispanic black"3"hispanic"

recode ragender (2=0),gen(gender_h)
lab var gender_h "Male HRS"
lab val gender_h male
lab def gender 1"Male" 0"Female"

recode raeduc (1/2=1)(3=2)(4/5=3)(.m=.), gen (educ_h)
lab var educ_h "Education HRS"
lab val educ_h educ
lab def educ 1"less than highschool"2"highschool"3"college and above"
gen loweduc_h =(educ_h<=2) if !missing(educ_h)
lab var loweduc_h "High school or less HRS"
lab val loweduc_h loweduc
lab def loweduc 1"High school or less" 0"College and above"
recode mstat (1/3=1)(4/8=0)(.m=.), gen (married_h)
lab var married_h "Marital Status HRS"
lab val married_h married
lab def married 1"married"0"single"

recode gender_h (0=1)(1=0),gen(female)
recode raedyrs (0/5=2)(6/11=3)(12/20=1), gen(education)
lab val education education
lab def education 2 "Low education (0-5)" 3"Mid-education(6-11)" 1"High education (12+)" 


lab var wave "HRS Wave"
lab var iwendy "Year of end of interview"

tab cogstate agegroup_h if age_yrs>=71 & wave>=5 & wave<=6,col
tab cogstate agegroup_h if age_yrs>=71 & wave>=5 & wave<=7,col

tab cogstate agegroup_h [aw=weight] if age_yrs>=71 & wave>=5 & wave<=6, col
tab cogstate agegroup_h [aw=weight] if age_yrs>=71 & wave>=5 & wave<=7, col

tab agegroup_h  if age_yrs>=71 & wave>=5 & wave<=6
tab agegroup_h [aw=weight] if age_yrs>=71 & wave>=5 & wave<=6
tab agegroup_h  if age_yrs>=71 & wave>=5 & wave<=7
tab agegroup_h [aw=weight] if age_yrs>=71 & wave>=5 & wave<=7

*AgeGroup for AD Project
recode age_yrs (-10/64.999=.)(65/74.999=1)(75/84.999=2)(85/200=3)(200/.=.),gen(agegroup_ad)
lab var agegroup_ad "Age group HRS"
lab val agegroup_ad agegroupad
lab def agegroupad 1"65 to 74"2"75 to 84"3 "85 and above"

* HRS Fullsample Appendix (Descriptive)
/*tabout dementia dementiae dementiae_strict iwendy [aw=weight]using $output/hrs_fullsample_appendix.xls, cells(freq row col) format(0c 1p 1p ) clab(Sample_size Row_percentage Col_percentage) layout (rb) replace 
tabout dementia dementiae dementiae_strict wave [aw=weight]using $output/hrs_fullsample_appendix.xls, cells(freq row col) format(0c 1p 1p) clab(Sample_size Row_percentage Col_percentage) layout (rb) append 
foreach v in agegroup_h race_h gender_h educ_h loweduc_h married_h {
tabout dementia dementiae dementiae_strict `v' [aw=weight]using $output/hrs_fullsample_appendix.xls, cells(freq row col) format(0c 1p 1p) clab(Sample_size Row_percentage Col_percentage) layout (rb) append 
forval i= 2/11 {
tabout dementia dementiae dementiae_strict `v' if wave==`i' [aw=weight]using $output/hrs_fullsample_appendix.xls, cells(freq row col) format(0c 1p 1p) clab(Sample_size Row_percentage Col_percentage) layout (rb) append 
}
}
*/
* Dementia (persistent and non-persistent) by race and agegroups for the 65+ population
/*foreach x in race_h agegroup_ad {
tabout dementiae `x' [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave>= 3 & wave<=12 using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (N %) layout (rb) replace
tabout dementiae wave [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave>= 3 & wave<=12 using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (N %) layout (rb) append
forval i=4/12 {
tabout dementiae `x' [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave==`i' using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (wave`i'N  wave`i'%) layout (rb) append
}

tabout dementiae_strict `x' [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave> =3 & wave<=12 using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (N %) layout (rb) append
tabout dementiae_strict wave [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave> =3 & wave<=12 using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (N %) layout (rb) append
forval i=4/12 {
tabout dementiae_strict `x' [aw=weight] if age_yrs>64.999 & !missing(age_yrs) & wave==`i' using $output/hrs_cog_`x'.xls,cells (freq col) format (0c 1p) clab (wave`i'N  wave`i'%) layout (rb) append
}
}*/
gen ffs=1 if partb_stat==1 & medicare_hmo==0
replace ffs=0 if partb_stat ==1 & medicare_stat ==1 & ffs!=1
bys hhidpn (wave): gen l2medicare_hmo = medicare_hmo[_n-1]

gen ffs2=1 if partb_stat==1 & medicare_hmo==0
replace ffs2=0 if partb_stat==1 & medicare_stat==1 & l2medicare_hmo==1 & ffs!=1

tab ffs ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200) 


tab educ_h , gen(educ)
ren educ1 lessthanhs
ren educ2 highschool
ren educ3 college
//bys wave: tabstat age_yrs gender_h white_h black_h hispan_h diabe hearte  smokev smoken lessthanhs highschool college dementiae_strict  [aw=wtcrnh], by(ffs)
//bys wave ffs: tabstat dementiae_strict  [aw=wtcrnh], by(race_h)
//bys wave ffs: tabstat dementiae_strict  [aw=wtcrnh], by(agegroup_claims)
//bys wave ffs: tabstat dementiae_strict  [aw=wtcrnh], by(gender_h)



**** Age group distribution for FFS and Dementia Prevalence by Age group for FFS across waves ******
tab agegroup_ad,gen(agegroup_ad)
//tabout agegroup_ad1 agegroup_ad2 agegroup_ad3 wave if age_yrs>64.999 & !missing(age_yrs) & ffs==1 using $output/hrs_cog_ffs.xls, cells (freq col)  clab (agegroupN agegroup%) layout (rb) replace
/*table agegroup_ad wave if age_yrs>64.999&!missing(age_yrs)&ffs==1, c(mean dementiae)
//table agegroup_ad wave if age_yrs>64.999&!missing(age_yrs)&ffs==1, c(mean dementiae_strict)
//table race_h wave if age_yrs>64.999&!missing(age_yrs)&ffs==1, c(mean dementiae)
//table race_h wave if age_yrs>64.999&!missing(age_yrs)&ffs==1, c(mean dementiae_strict)
*/
//Dementia variable missing wave1 and wave12
save $input/dementia_hrs,replace
capture log close
clear all
exit,STATA
