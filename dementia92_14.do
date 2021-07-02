
* YZ Jan 2018 Prevalence_Linked (ADAMS wave A & HRS wave 5 to wave 7)
clear all 
capture log close
set more off
set maxvar 30000
global input /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Input
global output /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Output
global rand_hrs /schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_p.dta
log using $output/dementia92_14, text replace
global hrs_sensitive /schaeffer-a/sch-data-library/dua-data/HRS/Sensitive/Adams/Stata
display "*** dementia92_14.do ***"

* Merge ADAMS wave A and HRS wave 5/6
*Recode AD based on final primary/secondary/tertiary diagnosis
/*
* adfdx1
         .................................................................................
           122           1.  Probable AD
           107           2.  Possible AD
            22           3.  Probable Vascular Dementia
            26           4.  Possible Vascular Dementia
             2           5.  Parkinson's
                         6.  Huntington's
                         7.  Progressive Supranuclear Palsy
             1           8.  Normal pressure hydrocephalus
            23          10.  Dementia of undetermined etiology
                        11.  Pick's disease
             1          13.  Frontal lobe dementia
             2          14.  Severe head trauma (with residual)
             1          15.  Alcoholic dementia
                        16.  ALS with dementia
                        17.  Hypoperfusion dementia
             1          18.  Probable Lewy Body dementia
                        19.  Post encephalitic dementia
            94          20.  Mild-ambiguous
            20          21.  Cognitive impairment secondary to vascular disease
             4          22.  Mild Cognitive Impairment
             8          23.  Depression
             2          24.  Psychiatric Disorder
             8          25.  Mental Retardation
             3          26.  Alcohol Abuse (past)
             3          27.  Alcohol Abuse (current)
            34          28.  Stroke
            10          29.  Other Neurological conditions
            55          30.  Other Medical conditions
           307          31.  Normal/Non-case
                        32.  Possible Lewy Body dementia
                        33.  CIND, non-specified
                        
A person has AD if [a,b,c]dfdx1 == 1 | [a,b,c]dfdx1 == 2  if [a,b,c]dfdx1 <= 33 & [a,b,c]dfdx1 >= 1
*** YZ: DFDX2 and DFDX3 present different pathologies rather than discrepancies on diagnosis
A person has dementia if Probable and possible AD/vascular dementia, Parkinson's, Huntington's, Progressive Supranuclear Palsy, Normal pressure hudrocephalus, Dementia of undetermined etiology, 
Pick's disease, Frontal lobal dementia, Severe head trauma (with residual), Alcoholic dementia, ALS with dementia, Hypoperfusion dementia, Probable lewy Body dementia, Post encephalitic dementia; Possible lewy body dementia
([a,b,c]dfdx1 >=1 & [a,b,c]dfdx1 <=19) | [a,b,c]dfdx1 ==32 if [a,b,c]dfdx1 <= 33 & [a,b,c]dfdx1 >= 1
A person has CIND if ([a,b,c]dfdx1 >=20 & [a,b,c]dfdx1 <30) | [a,b,c]dfdx1 ==33
A person is cognitively healthy if [a,b,c]dfdx1 ==31
*/

***********
** Create the Wave A ADAMS Alzheimer's Disease Dataset
***********

* INCLUDE DEMENTIA DIAGNOSES/SUMMARY SCORES FROM WAVE A
tempfile adams_a
* Load wave A data
use /*hhidpn ADFDX1 ADFDX2 ADFDX3 using*/ "$hrs_sensitive/adamsa.dta", clear
foreach x of varlist A* {
	ren `x' `=lower("`x'")'
}
sort hhidpn
save `adams_a', replace

* Merge tracker file with adams_a EXTRACT SAMPLING WEIGHT FOR WAVE A AND WAVE OF INTERVIEW FROM ADAMS TRACKER FILE;save dataset
use "$hrs_sensitive/adams1trk_r", clear
sort hhidpn
merge hhidpn using `adams_a',sort
tab _merge
drop _merge
save `adams_a', replace
/*ren AASAMPWT_F aasampwt_f*/ //renamed in adams_a 

*Keep useful variables;  HRS wave from which the subject was selected
keep hhidpn *year *month *assess  *fresult *vitstat *alocexm *agebkt *age *amarrd  folupsel cwave dwave gender ethnic degree wavesel aacogstr /*stratum*/ aaagesel proxy nursehm selfcog proxcog aurbrur seclust sestrat a*sampwt_f /*cross-sectional*/ a*longwt /*prospective analysis of the wave A adams sample cohort and tract each member to a final disposition at wave C*/ outcome* /*respondent's status in wave **/ birthmo birthyr *dfdx* *onset andssft andssbt andstot/*digit span, f,b, total*/ anaftot/*animal fluency*/ adblscor /*Blessed demenita rating scale*/
gen wave = 5 if wavesel == 1
replace wave = 6 if wavesel == 2
ren aasampwt_f adamswt
lab var adamswt "ADAMS cross-sectional sampling weight"

* make dates from assessment months
gen adamdt1=mdy(amonth,15,ayear) if ayear != 9997

** Rename
* Rename final diagnosis, generate cogstate and dementia in each wave
foreach x in dfdx1 dfdx2 dfdx3{
      ren a`x' `x'_1
      } 
tabout dfdx1_1 [aw=adamswt] using $output/cogstate_adams.xls,  c(freq col)  format (0c 1p) oneway replace

//transform pathologies to cogstate (dementia/CIND/normal)
lab def fdx 1"Probable AD"2"Possible AD"3"Probable Vascular Dementia"4"Possible Vascular Dementia"5"Parkinson's"6"Huntington's"7"Progressive Supranuclear Palsy"8"Normal pressure hydrocephalus"10"Dementia of undetermined etiology"11"Pick's disease"13"Frontal lobe dementia"14"Severe head trauma (with residual)"15"Alcoholic dementia"16"ALS with dementia"17"Hypoperfusion dementia"18"Probable Lewy Body dementia"19"Post encephalitic dementia"20" Mild-ambiguous"21"Cognitive impairment secondary to vascular disease"22" Mild Cognitive Impairment"23"Depression"24"Psychiatric Disorder"25"Mental Retardation"26"Alcohol Abuse (past)"27"Alcohol Abuse (current)"28"Stroke"29"Other Neurological conditions"30"Other Medical conditions"31"Normal/Non-case"32"Possible Lewy Body dementia"33" CIND, non-specified"
lab def cogstate 1"dementia"2"CIND"3"Normal"

forval i=1/3 {
lab val dfdx`i'_1 fdx
lab var dfdx`i'_1 "Final Diagnosis `i' Wave A"
recode dfdx`i'_1 (1/19=1)(32=1) (20/30=2)(33=2)(31=3),gen(cogstate`i'_1) 
lab var cogstate`i'_1 "Cognitive Status Diagnosis`i' Wave A"
lab val cogstate`i'_1 cogstate
}
gen cogstate_adams1=1 if cogstate1_1==1|cogstate2_1==1|cogstate3_1==1
replace cogstate_adams1=2 if cogstate_adams1!=1 &(cogstate1_1==2| cogstate2_1==2|cogstate3_1==2)
replace cogstate_adams1=3 if cogstate_adams1>2 & (!missing(cogstate1_1)|!missing(cogstate2_1)|!missing(cogstate3_1)) //Neither dementia nor CIND and at least one of the final diagnosis is not missing
lab val cogstate_adams1 cogstate
gen dementia_adams1=(cogstate_adams1==1) if !missing(cogstate_adams1)
lab val dementia_adams1 dementia
gen dementia_adamse1=dementia_adams1
lab val dementia_adamse1 dementia
lab var cogstate_adams1 "Diagnosis"
lab val proxcog proxycog
lab def proxycog 2"HRS IQCODE score=2"3"HRS IQCODE score=3"4"HRS IQCODE score=4"5"HRS IQCODE score=5"97"proxy reporter with completed self R cognition items"
** Replicate Langa et al., 2005 - ADAMS sample characteristics and prevalence of dementia
* Interview Status in Wave A 
gen astatus=.
replace astatus=1 if aassess ==1
replace astatus =2 if afresult==5
replace astatus=3 if afresult==7
lab var astatus "Interview Status in Wave A"
lab val astatus status
lab def status 1 "Assessed"2"Alive but not assessed"3"Deceased"

* Recoding Characteristics
recode aage (0/69.99=0)(70/79.99=1)(80/89.99=2)(90/200=3)(200/.=.),gen(agegroup_a1)
lab var agegroup_a1 "Age group in wave A"
lab val agegroup_a1 agegroup
lab def agegroup 0"Below 70"1"70 to 79"2"80 to 89"3 "90 and above"
recode aage (0/69.99=.)(70/74.99=1)(75/79.99=2)(80/84.99=3)(85/89.99=4)(90/200=5), gen(agetest)
lab var agetest "Age (in HRS 2000 or 2002"
lab val agetest agetest
lab def agetest 1"70 to 74"2"75 to 79"3"80 to 84" 4"85 to 89" 5"90 and above" 

ren ethnic race_a
lab val race_a race
lab def race 1"white"2"black"3"hispanic"
recode gender(2=0), gen(gender_a)
lab var gender_a "Sex"
lab val gender_a gender
lab def gender 1"Male"0"Female"
recode degree (0/1=1)(2=2)(3/6=3)(9/.=.), gen(educ_a)
lab var educ_a "Education"
lab val educ_a educ
lab def educ 1"less than highschool"2"highschool"3"college and above"
tab educ_a,gen(educ_a)
gen loweduc_a =(educ_a<=2) if !missing(educ_a)
tab loweduc_a,gen(loweduc_a)
lab var loweduc_a "High school and below"
recode aamarrd (1=0)(2=1)(3/5=0)(8/.=.), gen(married_a1)
lab var married_a1 "Marital Status" 
lab val married_a1 married
lab def married 1"married"0"single"
drop proxy
save $input/dementia_adams.dta, replace

use $input/dementia_adams.dta, clear
drop wave 
sort hhidpn wave
merge 1:1 hhidpn using $rand_hrs, keepusing(hhidpn r5iwend r6iwend r7iwend r5iwstat r6iwstat r7iwstat inw5 inw6 inw7 r5iwendy r6iwendy r7iwendy r8iwend) 
keep if _merge==3
drop _merge
sort hhidpn 
merge hhidpn using $input/outcomeb.dta
gen adamdt=adamdt1
replace adamdt=adamdt2 if dementia_adams2!=dementia_adams1 & !missing(dementia_adams1)&!missing(dementia_adams2)
gen wavedif5 = adamdt1 - r5iwend if ayear<9000
gen wavedif6 = adamdt1 - r6iwend if ayear<9000
gen wavedif7 = adamdt1 - r7iwend if ayear<9000
gen wavediff5=adamdt - r5iwend if ayear<9000 
gen wavediff6 = adamdt - r6iwend if ayear<9000
gen wavediff7 = adamdt - r7iwend if ayear<9000
gen wavediff8 = adamdt - r8iwend if ayear<9000
gen wave = .
replace wave = 5 if (abs(wavedif5)<abs(wavedif6)) & (abs(wavedif5)<abs(wavedif7))
replace wave = 6 if abs(wavedif6)<abs(wavedif5) & abs(wavedif6)<abs(wavedif7)
replace wave = 7 if abs(wavedif7)<abs(wavedif5) & abs(wavedif7)<abs(wavedif6)
replace wave=6 if wave==7 & abs(wavedif6)==abs(wavedif7)
replace wave=6 if wave==. & (abs(wavedif6)==abs(wavedif7))

gen wavef=.
replace wavef=5 if (abs(wavediff5)<abs(wavediff6)) & (abs(wavediff5)<abs(wavediff7)) & (abs(wavediff5)<abs(wavediff8))
replace wavef=6 if (abs(wavediff6)<abs(wavediff5)) & (abs(wavediff6)<abs(wavediff8))& (abs(wavediff6)<abs(wavediff7))
replace wavef = 7 if (abs(wavediff7)<abs(wavediff5)) & abs(wavediff7)<abs(wavediff6) & (abs(wavediff7)<abs(wavediff8)) //no abs(wavediff7) equals to abs(wavediff8)
replace wavef=8 if (abs(wavediff8)<abs(wavediff5)) & (abs(wavediff8)<abs(wavediff6)) & (abs(wavediff8)<abs(wavediff7))
replace wavef=6 if wavef==7 & (abs(wavediff6)==abs(wavediff7))
replace wavef=6 if wavef==. & (abs(wavediff6)==abs(wavediff7))

tab wave wavef,m
tab wave
tab wave wavesel
lab val wave wave
lab val wavef wave
lab def wave 5"2000"6"2002"7"2004"
gen datedif=wavedif5 if wave==5
replace datedif=wavedif6 if wave==6
replace datedif=wavedif7 if wave==7
sum datedif,d
bysort wave: sum datedif,d
gen datediff = wavediff5 if wavef==5
replace datediff=wavediff6 if wavef==6
replace datediff=wavediff7 if wavef==7
sum datediff[aw=adamswt],d
bysort wavef: sum datediff[aw=adamswt],d
gen wavea=wave
replace wave=wavef
ren _merge _mergeoutcomeb
merge 1:1 hhidpn wave using $input/dementia_hrs
sort hhidpn wave
save $input/dementia92_14.dta,replace

//Prevalence of dementia in ADAMS and HRS by race and wave or by education and wave

use $input/dementia92_14.dta, clear
gen dementia_adams=dementia_adams1
replace dementia_adams=dementia_adams2 if dementia_adams2!=dementia_adams1 & !missing(dementia_adams1)&!missing(dementia_adams2)
recode age_yrs(-9/70.999=.)(71/74.999=1)(75/84.999=2)(85/200=3)(201/.=.),gen(agegroup_new)
tab agegroup_new
lab val agegroup_new agegroupnew
lab def agegroupnew 1"71 to 74"2"75 to 84"3"85 and above"
recode age_yrs (-9/66.999=.)(67/74.999=1)(75/84.999=2)(85/200=3)(201/.=.), gen(agegroup_claims)
lab val agegroup_claims agegroupclaims
lab def agegroupclaims 1"67 to 74"2"75 to 84"3"85 and above"
lab val gender_h male
lab def male 1"Male"0"Female"
lab val wave wave
lab def wave 5"2000"6"2002"7"2004"8"2006"9"2008"10"2010"11"2012", modify

/**Age Distribution by age group , gender and wave
bys wave gender: tabstat age_yrs [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200), by(agegroup_claims) stats(mean p25 median p75 p90 max)

**Table 1. Unadjusted ADRD Prevalence by Agegroup/Race/Gender and wave in ADAMS, HRS and Claims
tabout dementia_adams agegroup_new [aw=adamswt] if _merge==3 using $output/prevalence_dementia.xls, cells(freq col) clab(N %) layout(rb) replace
tab dementiae_strict agegroup_new [aw=adamswt] if _merge==3, col
tab dementiae_strict agegroup_new [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200)
//Race
tab dementia_adams race_h [aw=adamswt] if _merge==3, col
tab dementiae_strict race_h [aw=adamswt] if _merge==3, col
tabout dementiae_strict race_h [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200) using $output/prevalence_dementia.xls, cells(freq col) clab(hrspoolN hrspool%) layout(rb) replace
//Gender
tab dementia_adams gender_h [aw=adamswt] if _merge==3, col
tab dementiae_strict gender_h [aw=adamswt] if _merge==3, col
tab dementiae_strict gender_h [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200), col
tabout dementiae_strict gender_h [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200) using $output/prevalence_dementia.xls, cells(freq col) clab(hrspoolN hrspool%) layout(rb) append
bys gender_h: tabstat age_yrs [aw=wtcrnh ] if inrange(wave,6,11)&inrange(age_yrs,67,200) ,by(agegroup_claims ) stats(mean min p10 p25 median p75 p90 max)

//Table 2. Adjusted ADRD Prevalence by race and wave in ADAMS and HRS
bys wave: tab dementiae_strict agegroup_claims [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200), col
bys wave proxy: tab dementiae_strict agegroup_claims [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200), col
tabout dementiae_strict wave [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200)&gender_h==0 using$output/prevalence_dementia.xls, cells(freq col) clab(femaleN female%) append
tabout dementiae_strict wave [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200)&gender_h==1 using$output/prevalence_dementia.xls, cells(freq col) clab(maleN male%) append
//Table 3. Adjusted ADRD Prevalence by race/agegroup and wave
*Adjusted ADRD Prevalence by race, agegroup and wave
eststo clear
*Education, Age and Age Square
/*eststo:logit dementiae_strict i.gender_h i.race_h i.educ_h i.wave c.age_yrs##c.age_yrs if inrange(wave,8,11)&inrange(age_yrs,67,200)
*/
*Education, Age Group
eststo:logit dementiae_strict i.gender_h i.race_h i.educ_h i.wave i.agegroup_claims if inrange(wave,8,11)&inrange(age_yrs,67,200)
/**No Educ, Age and Age Square
eststo:logit dementiae_strict i.gender_h i.race_h i.wave c.age_yrs##c.age_yrs if inrange(wave,8,11)&inrange(age_yrs,67,200)
*No Education, Race/Gender Interacted with Age Group*/
eststo:logit dementiae_strict (i.gender_h)#i.agegroup_claims i.race_h i.wave if inrange(wave,8,11)&inrange(age_yrs,67,200)
*Education, Race/Gender Interacted with Age Group
eststo:logit dementiae_strict (i.gender_h)#i.agegroup_claims i.race_h i.educ_h i.wave if inrange(wave,8,11)&inrange(age_yrs,67,200)
*Education, Gender Interacted with Age Group, Cardiovascular factors
eststo:logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave i.stroke i.diabe i.hearte  i.hibpe if inrange(wave,8,11)&inrange(age_yrs,67,200)
/**Education, Gender Interacted with Age Group, Cardiovascular factors, Proxy
eststo:logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave i.stroke i.diabe i.hearte  i.hibpe i.proxy if inrange(wave,8,11)&inrange(age_yrs,67,200)
*/
esttab est1 est2 est3 est4 est5 using $output/hrsrace.csv,  cells(`"b(fmt(a1) star) ci( par("[" " " "]"))"') pr2 label replace
* Unadjusted ADRD Prevalence by race/gender,agegroup and wave

/*bys wave: tab dementiae_strict agegroup_claims[aw=wtcrnh] if wave>=5 & wave<=11 & age_yrs>=65 & age_yrs<200, col
bys wave: tab dementiae_strict agegroup_new [aw=wtcrnh] if wave>=5 & wave<=11 & age_yrs>=65 & age_yrs<200, col
bys wave: tab dementiae_strict agegroup_new [aw=adamswt] if wave>5 &_merge==3, col

table  wave [aw=adamswt] if _merge==3 & wave>5 , c(mean dementia_adams n dementia_adams)
table  wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3 , c(mean dementiae n dementiae)
table  wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementiae n dementiae)
table  wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3, c(mean dementiae_strict n dementiae_strict)
table  wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementiae_strict n dementiae_strict)

replace race_h=race_a if _merge==3
table race_h wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementia_adams n dementia_adams)
table race_h wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3, c(mean dementiae_strict n dementiae_strict)
table race_h wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementiae_strict n dementiae_strict)

table educ_h wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementia_adams n dementia_adams)
table educ_h wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3, c(mean dementiae_strict n dementiae_strict)
table educ_h wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementiae_strict )

table agegroup_new wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementia_adams n dementia_adams)
table agegroup_new wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3, c(mean dementiae_strict n dementiae_strict)
table agegroup_new wave [aw=adamswt] if _merge==3 & wave>5, c(mean dementiae_strict )

tab race_h [aw=adamswt] if _merge==3 & wave>5
tab race_h wave [aw=adamswt] if _merge==3 & wave>5, col
tab race_h [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3
tab race_h wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3,col

tab educ_h [aw=adamswt] if _merge==3
tab educ_h wave [aw=adamswt] if _merge==3& wave>5, col
tab educ_h [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3
tab educ_h wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3,col

tab agegroup_new [aw=adamswt] if _merge==3 & wave>5
tab agegroup_new wave [aw=adamswt] if _merge==3 & wave>5, col
tab agegroup_new [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3
tab agegroup_new wave [aw=weight] if wave>5& wave<=7 & agegroup_h>=1&agegroup_h<=3,col

/*gen discrepstrict=.
replace discrepstrict = 0 if dementiae==dementiae_strict
replace discrepstrict=1 if dementiae!=dementiae_strict & !missing(dementiae)&!missing(dementiae_strict)
tab discrepstrict 
tab discrepstrict if  wave>=5& wave<=7 & agegroup_h>=1&agegroup_h<=3 
tab discrepstrict race_h, col
tab discrepstrict race_h if  wave>=5& wave<=7 & agegroup_h>=1&agegroup_h<=3, col
tab discrepstrict educ_h, col
tab discrepstrict educ_h if  wave>=5& wave<=7 & agegroup_h>=1&agegroup_h<=3, col
tab discrepstrict agegroup_new, col
tab discrepstrict agegroup_new if  wave>=5& wave<=7 & agegroup_h>=1&agegroup_h<=3, col*/

gen discrep=.
replace discrep=0 if _merge==3 & dementia_adams==dementiae_strict
replace discrep=1 if _merge==3 & dementia_adams!=dementiae_strict

table race_h wave [aw=adamswt] if inrange(wave,6,7)  ,c(mean discrep)
table educ_h wave [aw=adamswt] if inrange(wave,6,7), c(mean discrep)
table agegroup_new wave [aw=adamswt] if inrange(wave,6,7),c(mean discrep)
table race_h educ_h [aw=adamswt] if inrange(wave,6,7),c(mean discrep)

gen adamsearlier=.
replace adamsearlier=0 if discrep==1 & dementia_adams<dementiae_strict&!missing(dementiae_strict )
replace adamsearlier=1 if discrep==1 & dementia_adams>dementiae_strict&!missing(dementia_adams)
gen adamsdatebefore = .
replace adamsdatebefore=1 if _merge==3 & datediff<0 & wave>5
replace adamsdatebefore=0 if _merge==3 & (datediff>0|datediff==0) & wave>5 
lab val adamsdatebefore adamsdate
lab def adamsdate 0"ADAMS date latter" 1 "ADAMS date earlier"
tab adamsdatebefore adamsearlier [aw=adamswt], col row*/


/****PROXY AND STROKE, 2/13/2018****
eststo clear
eststo: ologit cogstate_self stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave  if proxy==0 &inrange(wave,5,11)
eststo: ologit cogstate_proxy stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave  if proxy==1&inrange(wave,5,11)
eststo: reg proxy_nonmiss stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave  if proxy==1&inrange(wave,5,11)
eststo: reg inter_cogstate stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave  if proxy==1&inrange(wave,5,11)
eststo: reg iadlza stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave  if proxy==1&inrange(wave,5,11)
eststo: reg proxy_mem stroke gender_h i.race_h i.educ_h c.age_yrs##c.age_yrs i.wave if  proxy==1&inrange(wave,5,11)
esttab est1 est2  est3 est4 est5 est6  using $output/stroke.csv, cells(`"b(fmt(a1) star) "') r2 label replace
********Double Check FFS********
bys wave gender ffs: tabstat age_yrs[aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200), by(agegroup_claims) stats(mean p25 median p75 p90 max)
bys wave ffs: tab dementiae_strict agegroup_claims [aw=wtcrnh] if inrange(wave,5,11)&inrange(age_yrs,67,200), col
*/


*****Model Test******
gen anyadl=(adla>0) if !missing(adla)
gen anyiadl=(iadla>0) if !missing(iadla)
/*logit dementiae_strict i.gender_h i.agegroup_claims i.educ_h i.race_h i.wave if inrange(wave,8,11)&inrange(age_yrs,67,200)
logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave if inrange(wave,8,11)&inrange(age_yrs,67,200)
logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave i.proxy if inrange(wave,8,11)&inrange(age_yrs,67,200)
logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave i.shlt i.anyadl i.anyiadl if inrange(wave,8,11)&inrange(age_yrs,67,200)
logit dementiae_strict i.gender_h#i.agegroup_claims i.educ_h i.race_h i.wave i.stroke i.diabe i.hearte  i.hibpe if inrange(wave,8,11)&inrange(age_yrs,67,200)
tab cogstate_self gender_h [aw=wtcrnh ] if inrange(wave,5,11)&inrange(age_yrs,67,200)&proxy==0&agegroup_claims ==1, col
tab cogstate_proxy gender_h [aw=wtcrnh ] if inrange(wave,5,11)&inrange(age_yrs,67,200)&proxy==1&agegroup_claims ==1, col
*/
*/
clear all 
exit,STATA
