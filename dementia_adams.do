* YZ Sep 2017 Dementia_ADAMS
clear all 
capture log close
set more off
set maxvar 30000
global input /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Input
global output /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Output
global rand_hrs /schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_p.dta
log using $output/dementia_adams, text replace
global hrs_sensitive /schaeffer-a/sch-data-library/dua-data/HRS/Sensitive/Adams/Stata
display "*** dementia_adams.do ***"

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
A person has CIND if he/she has Mild-ambiguous, cognitive impairment secondary to vascular disease, mild cognitive impairment, depression, psychaitric disorder, mental retardation, alcohol abuse (past), alcohol abuse (current), stroke, other neurological conditions ([a,b,c]dfdx1 >=20 & [a,b,c]dfdx1 <30) | [a,b,c]dfdx1 ==33
,possible lewy body dementia, CIND, non-specified  
 ([a,b,c]dfdx1 >=20 & [a,b,c]dfdx1 <30) | [a,b,c]dfdx1 ==33)
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

* Merge adamsb and adams_a
use /*hhidpn BDFDX1 BDFDX2 BDFDX3 using*/ "$hrs_sensitive/adamsb.dta", clear
foreach x of varlist B* {
        ren `x' `=lower("`x'")'
}
sort hhidpn
merge hhidpn using `adams_a',sort
tab _merge
drop _merge
save `adams_a', replace

* Merge adamsc and adams_a
use /*hhidpn CDFDX1 CDFDX2 CDFDX3 using*/ "$hrs_sensitive/adamsc.dta", clear
foreach x of varlist C* {
        ren `x' `=lower("`x'")'
}
sort hhidpn
merge hhidpn using `adams_a',sort
tab _merge
drop _merge
save `adams_a', replace

* Merge adamsd and adams_a
use /*hhidpn DDFDX1 DDFDX2 DDFDX3 using*/  "$hrs_sensitive/adamsd.dta", clear
foreach x of varlist D* {
        ren `x' `=lower("`x'")'
}
sort hhidpn
merge hhidpn using `adams_a',sort
tab _merge
drop _merge
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
keep hhidpn *year *month *assess  *fresult *vitstat *alocexm *agebkt *age *amarrd  folupsel cwave dwave gender ethnic edyrs degree wavesel aacogstr /*stratum*/ aaagesel proxy nursehm selfcog proxcog aurbrur seclust sestrat a*sampwt_f /*cross-sectional*/ a*longwt /*prospective analysis of the wave A adams sample cohort and tract each member to a final disposition at wave C*/ outcome* /*respondent's status in wave **/ birthmo birthyr *dfdx* *onset
gen wave = 5 if wavesel == 1
replace wave = 6 if wavesel == 2
ren aasampwt_f adamswt
lab var adamswt "ADAMS cross-sectional sampling weight"
sort hhidpn wave

lab val outcomec outcome
lab val outcomed outcome
lab def outcomec 1"wave A dementia"9"wave A deceased,nonreponse"11"wave B dementia"18"wave B deceased"21"wave C dementia"22"wave C CIND"23"wave C normal"28"wave C deceased" 29 "wave C non-response" 31"wave D dementia "32"wave D CIND" 33"wave D normal" 38 "wave D deceased" 39 "wave  D non-response"


* make dates from assessment months
gen adamdt1=mdy(amonth,15,ayear) if ayear != 9997
gen adamdt2=mdy(bmonth,15,byear) if byear != 9997
gen adamdt3=mdy(cmonth,15,cyear) if cyear != 9997
gen adamdt4=mdy(dmonth,15,dyear) if dyear != 9997

* Figure # days between assessments
*
gen daysA_B = adamdt2 - adamdt1 
gen daysA_C = adamdt3 - adamdt1 if missing(adamdt2)
gen daysB_C = adamdt3 - adamdt2
gen daysC_D = adamdt4 - adamdt3
gen daysB_D = adamdt4 - adamdt2 if missing(adamdt3) & !missing(adamdt2)
gen daysA_D = adamdt4 - adamdt1 if missing(adamdt3) & missing(adamdt2)

** Rename
* Rename final diagnosis, generate cogstate and dementia in each wave
foreach x in dfdx1 dfdx2 dfdx3{
      ren a`x' `x'_1
      ren b`x' `x'_2
      ren c`x' `x'_3
      ren d`x' `x'_4
} 
tabout dfdx1_1 [aw=adamswt] using $output/cogstate_adams.xls,  c(freq col)  format (0c 1p) oneway replace

//transform pathologies to cogstate (dementia/CIND/normal)
lab def fdx 1"Probable AD"2"Possible AD"3"Probable Vascular Dementia"4"Possible Vascular Dementia"5"Parkinson's"6"Huntington's"7"Progressive Supranuclear Palsy"8"Normal pressure hydrocephalus"10"Dementia of undetermined etiology"11"Pick's disease"13"Frontal lobe dementia"14"Severe head trauma (with residual)"15"Alcoholic dementia"16"ALS with dementia"17"Hypoperfusion dementia"18"Probable Lewy Body dementia"19"Post encephalitic dementia"20" Mild-ambiguous"21"Cognitive impairment secondary to vascular disease"22" Mild Cognitive Impairment"23"Depression"24"Psychiatric Disorder"25"Mental Retardation"26"Alcohol Abuse (past)"27"Alcohol Abuse (current)"28"Stroke"29"Other Neurological conditions"30"Other Medical conditions"31"Normal/Non-case"32"Possible Lewy Body dementia"33" CIND, non-specified"
lab def cogstate 1"dementia"2"CIND"3"Normal"
forval i=1/3 {
forval j=1/4 {
lab val dfdx`i'_`j' fdx
lab var dfdx`i'_`j' "Final Diagnosis `i' Wave`j'"
tabout dfdx`i'_`j' [aw=adamswt] using $output/cogstate_adams.xls,  c(freq col)  format (0c 1p) oneway append
recode dfdx`i'_`j' (1/19=1)(32=1) (20/30=2)(33=2)(31=3),gen(cogstate`i'_`j') 
lab var cogstate`i'_`j' "Cognitive Status Diagnosis`i' Wave`j'"
lab val cogstate`i'_`j' cogstate
tabout cogstate`i'_`j'[aw=adamswt] using $output/cogstate_adams.xls,  c(freq col)  format (0c 1p) oneway append
}
} 
// demented if any of the three final diagnosis demented; CIND if not demented and any CIND; normal if any normal and not demented/CIND; generate dementia variable in each adams wave
forval j=1/4 {
gen cogstate_adams`j'=.
replace cogstate_adams`j'=1 if cogstate1_`j'==1|cogstate2_`j'==1|cogstate3_`j'==1
replace cogstate_adams`j'=2 if cogstate_adams`j'!=1 &(cogstate1_`j'==2| cogstate2_`j'==2|cogstate3_`j'==2)
replace cogstate_adams`j'=3 if cogstate_adams`j'>2 & (!missing(cogstate1_`j')|!missing(cogstate2_`j')|!missing(cogstate3_`j')) //Neither dementia nor CIND and at least one of the final diagnosis is not missing
lab val cogstate_adams`j' cogstate
gen dementia_adams`j'=(cogstate_adams`j'==1) if !missing(cogstate_adams`j')
lab val dementia_adams`j' dementia
gen dementia_adamse`j'=dementia_adams`j'
lab val dementia_adamse`j' dementia
}
//For cases with positive dementia dianoses in two consecutive ADAMS waves, make the second one missing
replace dementia_adams2=. if dementia_adams1==1&dementia_adams2==1 //17 observations demented both in wave A and B
replace dementia_adams4=. if dementia_adams3==1&dementia_adams4==1 //1 observation (AD)
//Construct outcomeb and dementia_adamse2
gen outcomeb=dementia_adams2
replace outcomeb=.r if bfresult ==5
replace outcomeb=.d if bfresult==7
replace outcomeb=.m if bfresult==97
replace outcomeb=.x if dementia_adams1==1 & outcomeb==.m
replace outcomeb=.n if dementia_adams1==0 & outcomeb==.m
lab val outcomeb outcomeb
lab def outcomeb 0"Not demented"1"Demented in wave B" .m"Missing in wave A" .n"CIND or Normal in wave A" .x "Demented in wave A" .d"Deceased in wave B" .r"Refulsed/non-participation" 
tab dementia_adamse1 outcomeb,m
tab dementia_adamse1 outcomeb [aw=adamswt],m
tab dementia_adamse1 outcomeb, row col m
tab dementia_adamse1 outcomeb [aw=adamswt], row col m
/*Ever demented in wave A = Dementia (Incident) in wave A
  Ever demented in wave B = 1 if Dementia (Incidenct) in wave B | (Demented in wave A & !deceased in wave B &!refused in wave B)
                          = 0 if CIND/Normal in wave B (Not demented (rediagnosis,7) in wave B compared to dementia in wave A) | CIND/Normal in wave A and not targeted in wave B
  WAVE B DECEASED : Bfresult 33; outcomec 42; outcomed 28 (14 added to wave c deceased) Decision: current wave
*/
/*keep hhidpn byear bmonth dementia_adams2 cogstate_adams2 adamdt2 ayear amonth dementia_adams1 cogstate_adams1 adamdt1
save $input/outcomeb.dta, replace*/


//Descriptive incidence of dementia by wave
forval i=1/4 {
tab dementia_adams`i' [aw=adamswt] 
}
tab dementia_adams3 [aw=aclongwt] 
tab dementia_adams4 [aw=adlongwt] 


* Ever demented 
replace dementia_adamse2=1 if outcomeb==.x | dementia_adams2==1
replace dementia_adamse2=0 if outcomeb==.n | dementia_adams2==0
replace dementia_adamse3=1 if dementia_adamse2==1 & outcomec<28
replace dementia_adamse4=1 if dementia_adamse3==1 & outcomed<38
lab def dementia 1"Demented"0"Not demented"
forval i=1/4 {
tabout dementia_adamse`i'[aw=adamswt] using $output/cogstate_adams.xls,  c(freq col)  format (0c 1p) oneway append
}


** 7 cases demented in wave A and not demented in wave B (6 CIND 1 Normal)? 

* Rename other variables
foreach x in agebkt age year month assess fresult alocexm amarrd donset {
      ren a`x' `x'1
      ren b`x' `x'2
      ren c`x' `x'3
      ren d`x' `x'4
} 
* eligwv provides the last Adams wave for which R was eligible (no AD & assessed
*   eligwv is set to core wave closest to targetdt for eligwave
*   demwave is the earliest wave of the onset of dementia
gen demwave=(dementia_adams1==1) + 2*(dementia_adams2==1) + 3*(dementia_adams3==1) + 4*(dementia_adams4==1)
gen eligwave=0 
forvalues t = 1/4 {
  replace eligwave=`t' if ~missing(dementia_adams`t') 
  }
tab demwave eligwave
drop if eligwave==0
gen waves = 1000* (assess1==1) + 100 * (assess2==1) + 10 * (assess3==1) + (assess4==1)

//one case with 2 assessments 
list hhidpn assess1 assess2 assess3 assess4 dementia_adams1 dementia_adams2 dementia_adams3 dementia_adams4 if waves==1111 & demwave==3  
replace waves = 1110 if waves==1111 & demwave==3

foreach x in vitstat {
      ren `x' `x'1
      ren c`x' `x'3
      ren d`x' `x'4
}

merge 1:1 hhidpn using $rand_hrs, keepusing(hhidpn r*iwend r*iwstat inw* r*iwendy) 
keep if _merge==3
drop _merge r1iwend r2iwend r3iwend r1iwstat r2iwstat r3iwstat inw1 inw2 inw3 r1iwendy r2iwendy r3iwendy
 gen wave_sv = wave
 
 preserve
 recode age1 (0/69.99=0)(70/79.99=1)(80/89.99=2)(90/200=3)(200/.=.),gen(agegroup_a1)
lab val agegroup_a1 agegroup
lab def agegroup 0"Below 70"1"70 to 79"2"80 to 89"3 "90 and above"
ren ethnic race_a
lab val race_a race
lab def race 1"white"2"black"3"hispanic"
recode gender(2=0), gen(gender_a)
recode degree (0/1=1)(2=2)(3/6=3)(9/.=.), gen(educ_a)
lab val educ_a educ
lab def educ 1"less than highschool"2"highschool"3"college and above"
tab educ_a,gen(educ_a)
gen loweduc_a =(educ_a<=2) if !missing(educ_a)
tab loweduc_a,gen(loweduc_a)
recode amarrd1 (1=0)(2=1)(3/5=0)(8/.=.), gen(married_a1)
lab val married_a1 married
lab def married 1"married"0"single"

tabstat dementia_adams1 [aw=adamswt],by(wavesel) stats (mean n)
tabstat dementia_adams1 [aw=adamswt],by(year1) stats (mean n)
foreach x of  varlist gender_a agegroup_a1 race_a married_a1 educ_a loweduc_a {
tabstat dementia_adams1 [aw=adamswt], by(`x' ) stats (mean n)
bys `x': tabstat dementia_adams1 [aw=adamswt], by(wavesel ) stats (mean n)
bys `x': tabstat dementia_adams1 [aw=adamswt], by(year1 ) stats (mean n)
}
tabout dementia_adams1  [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) replace
tabout dementia_adams1 wavesel [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) layout(cb) append
tabout dementia_adams1 year1 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) layout(cb) append
foreach x of  varlist gender_a agegroup_a1 race_a married_a1 educ_a loweduc_a {
tabout dementia_adams1 `x' [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
tabout dementia_adams1 `x' if wavesel==1 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
tabout dementia_adams1 `x' if wavesel==2 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
tabout dementia_adams1 `x' if year1==2001 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
tabout dementia_adams1 `x' if year1==2002 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
tabout dementia_adams1 `x' if year1==2003 [aw=adamswt] using $output/prevalence_adams.xls, cells(freq col) format (0c 1p) clab(No. %) oneway layout(cb) append
}
 restore
 
forval aw=1/4 {
     gen elig`aw' = (demwave==0 | demwave >= `aw') & !missing(adamdt`aw')
  }
gen date1=.
gen date15=abs(adamdt1-r5iwend)
gen date16=abs(adamdt1-r6iwend)
replace date1=date15 if (date15<date16 | date15==date16) & !missing(date15)
gen adamswave=.
replace adamswave=5 if date1==date15 & !missing(date15)
gen adam5=.
replace adam5=1 if  date1==date15 & !missing(date15)
//eplace adam5=0 if adam5!=1 & elig1==1
 //replace date1=date16 if (date16<date15) & !missing(date16)
 //replace adamswave=6 if date1==date16 & !missing(date16)
gen adam6=.
forval i=6/9 {
  local n=`i'+1
  cap drop date1`i' 
  gen date1`i'=abs(adamdt1-r`i'iwend)  
  gen date1`n'=abs(adamdt1-r`n'iwend)  
  sum date1`i' date1`n' 
  //replace adam`i'=0 if ((date1<date1`i')|(date1`i'>date1`n')) &!missing(r`i'iwend)  & elig1==1
  replace date1=date1`i' if (date1`i'<date1)&!missing(date1`i')& (date1`i'<date1`n'|date1`i'==date1`n')  
  replace adamswave=`i' if date1==date1`i' & !missing(date1`i')
  replace adam`i'=1 if (date1`i'<date1)&!missing(date1`i')& (date1`i'<date1`n'|date1`i'==date1`n') 
 replace date1 =date1`n' if date1`n'<date1`i' & !missing(date1`n') 
 replace adamswave=`n' if date1==date1`n' & !missing(date1`n') 
 gen adam`n'=1 if  date1`n'<date1`i' & !missing(date1`n')
 }
forval aw=2/4 {
  gen date`aw'=.
  gen date`aw'5=abs(adamdt`aw'-r5iwend) if elig`aw'==1
   gen date`aw'6=abs(adamdt`aw'-r6iwend) if elig`aw'==1
  replace date`aw'=date`aw'5 if (date`aw'5<date`aw'6 ) & (date`aw'5<. ) //& elig`aw'==1
  replace adamswave=5 if date`aw'==date`aw'5 & (date`aw'<.) //& elig`aw'==1
  replace adam5=1 if date`aw'==date`aw'5 & (date`aw'<.) //& elig`aw'==1
   replace date`aw'=date`aw'6 if (date`aw'6<date`aw'5) & (date`aw'6<.) //& elig`aw'==1
  replace adamswave=6 if date`aw'==date`aw'6 & (date`aw'6<.) //& elig`aw'==1
   replace adam6=1 if date`aw'==date`aw'6 & (date`aw'6<.) //& elig`aw'==1
 }
forval aw=2/4 {
  forval wv= 6/9 {
  local nwv=`wv'+1
   cap drop date`aw'`wv'
  gen date`aw'`wv'=abs(adamdt`aw'-r`wv'iwend) /*if elig`aw'==1*/
  gen date`aw'`nwv'=abs(adamdt`aw'-r`nwv'iwend) /*if elig`aw'==1*/
  sum date`aw'`wv' date`aw'`nwv' 
  replace adam`wv'=. if ((date`aw'<date`aw'`wv'|date`aw'==date`aw'`wv')|(date`aw'`wv'>date`aw'`nwv')) &!missing(r`wv'iwend) & elig`aw'==1
  replace date`aw'=date`aw'`wv' if (date`aw'`wv'<date`aw')&!missing( date`aw'`wv') & (date`aw'`wv'<date`aw'`nwv'|date`aw'`wv'==date`aw'`nwv') /*elig`aw'==1*/
  replace adamswave=`wv' if date`aw'==date`aw'`wv' & !missing(date`aw'`wv') /*elig`aw'==1*/
 replace adam`wv'=1 if date`aw'==date`aw'`wv' & !missing(date`aw'`wv') /*elig`aw'==1*/
 //replace adam`wv'=0 if date`aw'==date`aw'`nwv' & !missing(date`aw'`nwv')  
 replace date`aw' =date`aw'`nwv' if date`aw'`nwv'<date`aw' & !missing(date`aw') /*elig`aw'==1*/
 replace adamswave=`nwv' if date`aw'==date`aw'`nwv' & !missing(date`aw'`nwv') /*elig`aw'==1*/
 replace adam`nwv'=1 if date`aw'==date`aw'`nwv' & !missing(date`aw'`nwv') /*elig`aw'==1*/
 }
 }
forval i=5/10 {
gen wave`i'=.
replace wave`i'=1 if date1==date1`i' & !missing(date1)
replace wave`i'=1 if date2==date2`i' &!missing(date2)
replace wave`i'=1 if date3==date3`i' &!missing(date3)
replace wave`i'=1 if date4==date4`i' &!missing(date4)
replace wave`i'=0 if wave`i'!=1
}
egen wavetest=rowtotal(wave5 wave6 wave7 wave8 wave9 wave10)
forval i=5/10 {
replace wave=`i' if wave`i'==1
}
sort hhidpn
save $input/adams_wide,replace
/*
*** Match HRS and ADAMS wave: closest interview date
** have ADAMs wave cogstate(dementia) dx-ed, last eligible ADAMs wave. Need hrs wave for assignment.
***
* find the core interviews closest to 
*   demwave and eligwv dates (= targetdt)
*   Will use these core waves to set dementia back and forward
*
*  in the loop, aw counts adams waves, wv counts core waves
*   demwv is set to core wave closest to targetdt for demwave
*   adamnp ="p" if using prior wave, "n" if using next wave for adamwave
*   padamdays is # days between prior core interview and targetdt for adamwave
*   nadamdays is # days between next core interview and Adams for adamwave
*   padamwv is prior wave and targetdt for adamwave
*   nadamwv is next wave and Adams for adamwave
*   padamwvdt is prior core interview date (lagged core interview) for adamwave
*   nadamwvdt is next core interview date (lagged core interview) for adamwave
*   adamdt is the adams assessment date for adamwave (target date)
*
*   eligwv is set to core wave closest to targetdt for eligwave
*   elignp ="p" if using prior wave, "n" if using next wave for eligwave
*   peligdays is # days between prior core interview and targetdt for eligwave
*   neligdays is # days between next core interview and adams for eligwave
*   peligwv is prior wave and targetdt for eligwave
*   neligwv is next wave and adams for eligwave
*   peligwvdt is prior core interview date (lagged core interview) for eligwave
*   neligwvdt is next core interview date (lagged core interview) for eligwave
*   eligdt is the Adams assessment date
*   In loop find waves surrounding adams date, figure distance to prior/next core wave
*      then set adamwv/eligwv to closest core wave and adamnp to indicate choice.
*   If R is NR in one of core interviews, distance will be missing (and highest)
*   Maybe reject distances longer than a year.
*
**** loop thru adams waves 
gen adamwave=1
foreach v in "adam" "elig" {
  dis " v is `v'"
  cap drop `v'dt `v'wv `v'np `v'days `v'dtx
  cap drop p`v'wv p`v'wvdt p`v'days
  cap drop n`v'wv n`v'wvdt n`v'days
  gen `v'dt = .
  gen `v'wv=0
  gen `v'np=" "
  gen `v'days=.
  gen p`v'wv = 0
  gen n`v'wv = 0
  gen p`v'wvdt = .
  gen n`v'wvdt = .
  gen p`v'days = .
  gen n`v'days = .
  forvalues aw = 1/4 {  
    replace `v'dt = mdy(month(adamdt`aw'),day(adamdt`aw'),year(adamdt`aw')) if `v'wave==`aw'
    }
  
  /* add check for no target date. ADdt will be missing if no alzhmr dx.
  gen `v'dtx=missing(`v'dt)
  tab `v'wave `v'dtx*/ //checked
      * loop thru core waves 
 * Previous date :r(n-1)iwend; previous wave: (n-1); next date:rniwend; next wave: n
 * between days: previous hrs date<=adams date<=next hrs date or >=next hrs date

  cap drop prvdt prvwv nxtdt nxtwv betw
  gen prvdt=.
  gen prvwv=0
  gen nxtdt=.
  gen nxtwv=0
  gen betw = .
  forvalues nwv = 5/9 {  
     local pwv = `nwv'-1
     replace prvdt=r`pwv'iwend if ~missing(r`pwv'iwend)
     replace prvwv=`pwv' if ~missing(r`pwv'iwend)
     replace nxtdt=r`nwv'iwend if ~missing(r`nwv'iwend) 
     replace nxtwv=`nwv' if ~missing(r`nwv'iwend) 

     replace betw = (prvdt<=`v'dt) & (`v'dt<=nxtdt) & ~missing(`v'dt) & ~missing(nxtdt) & ~missing(prvdt)
     replace betw = 1 if `v'dt>nxtdt & ~missing(`v'dt) & ~missing(nxtdt)
     replace p`v'wv=prvwv if betw==1
     replace p`v'wvdt=prvdt if betw==1
     replace p`v'days=`v'dt - prvdt if betw==1

     replace n`v'wv=nxtwv if betw==1
     replace n`v'wvdt=nxtdt if betw==1
     replace n`v'days=nxtdt - `v'dt if betw==1
     }
     
  tab p`v'wv n`v'wv
  sum p`v'days n`v'days
  replace `v'np="p" if abs(p`v'days)<abs(n`v'days) & ~missing(p`v'days) & ~missing(n`v'days)
  replace `v'np="p" if ~missing(p`v'days) & missing(n`v'days)
  replace `v'np="n" if abs(n`v'days)<=abs(p`v'days) & ~missing(p`v'days) & ~missing(n`v'days)
  replace `v'np="n" if missing(p`v'days) & ~missing(n`v'days)
  replace `v'wv=p`v'wv if `v'np=="p"
  replace `v'wv=n`v'wv if `v'np=="n"
  replace `v'days=p`v'wvdt - `v'dt if `v'np=="p"
  replace `v'days=n`v'wvdt - `v'dt if `v'np=="n"
  replace `v'np="b" if p`v'wv==n`v'wv & p`v'wv>0  
  tab `v'np 
  tab `v'wv
  sum `v'days p`v'days n`v'days if `v'np=="p"
  sum `v'days p`v'days n`v'days if `v'np=="n"
  sum `v'days p`v'days n`v'days if `v'np=="b"
  sum `v'days p`v'days n`v'days if `v'np==" "
  }

  
  gen demwv=0
  gen demdays=.
  replace demwv=eligwv if demwave>0 
  replace demdays=eligdays if demwave>0
  tab demwv eligwv
  tab demwave demwv
  sum demdays if demwave>0

  label variable adamwv "Core wave closest to Adams A"  
  label variable adamdays "# days from Adams A date to core IW date"
  label variable padamwv "Core wave before Adams A"
  label variable padamwvdt "IW date of core wave before Adams A"
  label variable padamdays "# days from prior IW to Adams A"
  label variable nadamwv "Core wave after Adams A"
  label variable nadamwvdt "IW date of core wave after Adams A"
  label variable nadamdays "# days from Adams A to next IW"
  label variable adamnp "Whether prior/next/both selected for Adams A core wave"
  label variable eligwv "Core wave closest to last Adams"  
  label variable eligdays "# days from last Adams date to core IW date"
  label variable peligwv "Core wave before last Adams"
  label variable peligwvdt "IW date of core wave before last Adams"
  label variable peligdays "# days from prior IW to last Adams"
  label variable neligwv "Core wave after last Adams"
  label variable neligwvdt "IW date of core wave after last Adams"
  label variable neligdays "# days from last Adams to next IW"
  label variable elignp "Whether prior/next/both selected for last Adams core wave"
  label variable demwv "Core wave closest to Adams dementia diagnosis"  
  label variable demdays "# days from Adams dementia diagnosis to core IW date"
  
  tab adamwave adamnp, missing
  tab adamwave adamwv, missing
  tab eligwave elignp, missing
  tab eligwave eligwv, missing
  tab adamwv eligwv, missing
  gen eligdcat=(abs(eligdays)>180) + (abs(eligdays)>365) + (abs(eligdays)>730) if ~missing(eligdays)
  label define dcat 0 "lt 6 mo" 1 "6 mo - 1 yr" 2 "1 - 2 yrs" 3 "gt 2 yrs"
  label values eligdcat dcat
  tab eligdcat
  
  sum adamdays  padamdays nadamdays if adamnp=="p"
  sum adamdays  padamdays nadamdays if adamnp=="n"
  sum adamdays  padamdays nadamdays if adamnp=="b"

  sum eligdays demdays peligdays neligdays if elignp=="p"
  sum eligdays demdays peligdays neligdays if elignp=="n"
  sum eligdays demdays peligdays neligdays if elignp=="b"

  tab adamwv year1
  tab eligwv year1
  tab eligwv year2
  tab eligwv year3
  tab eligwv year4
  
 save $input/adams_wide, replace*/
 
 
 
drop wave
 * Transpose the data to create a record for each wave/person
reshape long agebkt age year month assess fresult alocexm amarrd dfdx1_ dfdx2_ dfdx3_ cogstate1_ cogstate2_ cogstate3_ cogstate_adams donset adamdt dementia_adams dementia_adamse, i(hhidpn) j(wave)
ren dfdx1_ fdx1
ren dfdx2_ fdx2
ren dfdx3_ fdx3
ren cogstate1_ cogstate1
ren cogstate2_ cogstate2
ren cogstate3_ cogstate3
* Now make the waves compatible with the HRS waves
/*replace wave = adamswv + wave - 1  //Make sure each adams wave correspondes with 1-year lag of HRS wave*/
 * Keep only relevant variables
/*keep hhidpn seclust sestrat adamswt aclongwt  fdx1 fdx2 fdx3 wave agebkt age year month assess fresult alocexm amarrd*/
lab val assess assess
lab def assess 1"Assessed"5"Not Assessed"

/*consistent with HRS categories*/
** Final Diagnosis: dementia if one of cogstate1-3 equals to 1; CIND if one of cogstate1-3 euquals to 2 and not dementia; normal if not dementia/CIND and at least one of cogstate1-3 not missing 

/*gen dementia_adams =(cogstate_adams==1) if !missing(cogstate_adams) 
gen dementia_adamsetest = dementia_adams
bys hhidpn (wave):egen firsttime=min(cond(cogstate_adams==1,wave,.)
replace dementia_adamsetest =1 if wave>=firsttime & dementia_adamsetest==0*/
lab var dementia_adams "Dementia in certain ADAMS wave"
lab var dementia_adamse "Ever Dementia or not"
/*lab val dementia_adams dementia
lab val dementia_adamse dementia
lab def dementia 1"Demented"0"Not demented"
tab dementia_adamse dementia_adamsetest,m*/
recode age (0/69.99=0)(70/79.99=1)(80/89.99=2)(90/200=3)(200/.=.),gen(agegroup_a)
lab val agegroup_a agegroup
lab def agegroup 0"Below 70"1"70 to 79"2"80 to 89"3 "90 and above"

ren ethnic race_a
lab val race_a race
lab def race 1"white"2"black"3"hispanic"
recode gender(2=0), gen(gender_a)

recode degree (0/1=1)(2=2)(3/6=3)(9/.=.), gen(educ_a)
lab val educ_a educ
lab def educ 1"less than highschool"2"highschool"3"college and above"
tab educ_a,gen(educ_a)

gen loweduc_a =(educ_a<=2) if !missing(educ_a)
tab loweduc_a,gen(loweduc_a)

recode amarrd (1=0)(2=1)(3/5=0)(8/.=.), gen(married_a)
lab val married_a married
lab def married 1"married"0"single"

foreach x of  varlist gender_a agegroup_a race_a married_a educ_a loweduc_a {
table year `x' [aw=adamswt],c(n dementia_adams mean dementia_adams)
}


/*tabout fdx1 fdx2  [aw=adamswt] using $output/disagreement.xls, cells(freq row) format (0c 1p) layout(rb) replace 

** Need to further Check Disagreement
bys adamswv: tab cogstate_adams1 cogstate_adams2 [aw=adamswt], row m
bys adamswv: tab cogstate_adams1 cogstate_adams3 [aw=adamswt], row m
gen wave1 = wave+adamswv - 1
gen wave2=wave if adamswv==1
replace wave2=adamswv+5 if adamswv>1 & !missing(adamswv)  //Three approaches to construct wave, my approach: wave 5 and 6 in A, 7 in B, 8 in C, 9 in D. 
recode year (2001=5)(2002/2003=6)(2004/2005=7)(2006/2007=8)(2008/2009=9), gen(wave3)
browse wave1 wave2 wave3 adamswv wavesel
browse wave1 wave2 wave3 adamswv wavesel if wave2!=wave3 & wave3<15
tab wave1 wave2,m
tab wave1 wave3,m
tab wave2 wave3,m //169 belong to wave 5 based on wavesel (source of sample) and belong to wave 6 based on year of completing interview
replace wave = wave2 */

tabout dementia_adams dementia_adamse wave [aw=adamswt] using $output/dementia_adams.xls, cells(freq row col) format(0c 1p 1p 1p) clab(No. Row_% Col_% Prob_%) layout (rb) replace 
tabout dementia_adams dementia_adamse year [aw=adamswt] if year<3000 using $output/dementia_adams.xls, cells(freq row col) format(0c 1p 1p 1p) clab(No. Row_% Col_% Prob_%) layout (rb) append 

foreach v in agegroup_a race_a gender_a married_a educ_a loweduc_a {
forval i=1/4 {
tabout dementia_adams dementia_adamse `v'  [aw=adamswt] if wave==`i' using $output/dementia_adams.xls, cells(freq row col) format(0c 1p 1p 1p) clab(No. Row_% Col_% ) layout (rb) append 
tabout  `v'  [aw=adamswt] if wave==`i' using $output/adams_simple.xls, cells(freq row col) format(0c 1p 1p 1p) clab(No. Row_% Col_% ) oneway layout (rb) append 
}
tabout  `v'  [aw=adamswt] using $output/adams_simple.xls, cells(freq row col) format(0c 1p 1p 1p) clab(No. Row_% Col_% ) oneway layout (rb) append 
}
ren age ageadams //may need to be changed
sort hhidpn wave
save $input/adams_long, replace
log close

