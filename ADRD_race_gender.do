* YZ Feb 2018 Adjusted ADRD Prevalence 
clear all 
capture log close
set more off
set maxvar 30000
global input /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Input
global output /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia/Output
global rand_hrs /schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_p.dta
log using $output/ADRD_race_gender, text replace
global hrs_sensitive /schaeffer-a/s ch-data-library/dua-data/HRS/Sensitive/Adams/Stata
use $input/dementia92_14.dta, clear
/*merge using $input/cogimp_14.dta, replace
gen totcogtest= totcog
replace totcogtest = ser7+bwc20+tr20 if wave==12
recode totcogtest (0/6=1) (7/11=2) (12/27=3) (miss=.) (nonmiss=3), gen(cogstate_selftest)
gen cogstatetest=cogstate 
replace cogstatetest=cogstate_selftest if wave==12& proxy==0 &!missing(cogstate_selftest)

sort hhidpn wave,stable
gen dementiatest =1.cogstatetest
bys hhidpn (wave): egen firsttimetest=min(cond(cogstatetest==1),wave,.) //if cogstate==1, firsttime=min wave when (cogstate==1); otherwise firsttime=wave
gen dementiaetest=dementiatest
replace dementiaetest=1 if wave>=firsttimetest & dementiaetest ==0        //if wave>firsttime, then dementia, absorbed 
tab wave dementiatest
tab wave dementiaetest  //higher pravelence
label var dementiatest "Respondent has dementia this wave, test"
label var dementiaetest "Ever had dementia, test"

*Confirmed dementia
gen dementiae_stricttest=dementiatest
bys hhidpn (wave): egen confirmedtest = min(cond(inlist(cogstatetest[_n+1],1,2) & cogstatetest==1,wave,.)) // if cogstate in the next wave is dementia or CIND and cogstate in the current wave is dmeentia, confirmed=min; otherwise confirmed=wave
replace dementiae_stricttest = 0 if dementiatest== 1 & wave < confirmedtest
gen dementia_stricttest=dementiae_stricttest
* fill forward once confirmed
replace dementiae_stricttest = 1 if dementiae_stricttest == 0 & wave >= confirmedtest //if current wave < confirmed in previous waves, then not demented; if wave>=confirmed, then dementia in the current wave can be confirmed ; absorbed
label var dementiae_stricttest "Confirmed dementia (subsequent wave has either dementia on CIND, test)"
replace dementiae_stricttest = 1 if f2died == 1 & dementiatest == 1 & dementiae_stricttest == 0  //died with dementia are counted as having dementia 
replace dementia_stricttest=1 if f2died==1 & dementiatest==1 & dementia_stricttest==0
lab var dementia_stricttest "Confirmed,Unabsorbed, test"
*/


gen dementia_adams=dementia_adams1
replace dementia_adams=dementia_adams2 if dementia_adams2!=dementia_adams1 & !missing(dementia_adams1)&!missing(dementia_adams2)
recode age_yrs (-9/66.999=.)(67/74.999=1)(75/84.999=2)(85/200=3)(201/.=.), gen(agegroup_claims)
lab val agegroup_claims agegroupclaims
lab def agegroupclaims 1"67 to 74"2"75 to 84"3"85 and above"
recode age_yrs(-9/69.999=.)(70/74.999=1)(75/84.999=2)(85/200=3)(201/.=.),gen(agegroup_new)
lab val agegroup_new agegroupnew
lab def agegroupnew 1"70 to 74"2"75 to 84"3"85 and above"
lab val gender_h male
lab def male 0"Female"1"Male"
lab val wave wave
lab def wave 5"2000"6"2002"7"2004"8"2006"9"2008"10"2010"11"2012", modify
lab var gender_h "Male"
//recode gender_h (0=1)(1=0), gen(female)

foreach var in  stroke shlt diabe hibpe smokev hearte adla iadla cancre {
replace `var'=. if missing(`var')
}
recode shlt(1/3=0)(4/5=1),gen(poorhealth)
recode adla (1/5=1),gen(anyadl)
recode iadla (1/3=1),gen(anyiadl)

**** Check ADRD prevalence among 70+ adults           ****
tab dementiae_strict wave [aw=wtcrnh] if inrange(wave,3,12)&inrange(age_yrs,67,200), col
*** Sensitivity***
recode age_yrs (-10/69.9=.)(70/74.9=1)(75/79.9=2)(80/84.9=3)(85/89.9=4)(90/200=5),gen(age_sensitivity)
lab val age_sensitivity agesensi
lab def agesensi 1"70 to 74" 2"75 to 79" 3 "80 to 84" 4"85 to 89" 5 "90 and above"

gen racehrs=.
replace racehrs=1 if raracem==1 & hispan_h==0
replace racehrs=2 if raracem==2 & hispan_h==0
replace racehrs=3 if hispan_h==1
replace racehrs=4 if raracem==3& hispan_h==0

lab var racehrs "Race"
lab val racehrs racehrs
lab def racehrs 1"White" 2"Black"3"Hispanic"4"Other race"

//save $input/dementia92_14,replace

tab racehrs [aw=wtcrnh] if wave==7&inrange(age_yrs,70,200)
tab dementiae_strict [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200)
sort racehrs
ci dementiae_strict [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200)
*** Table 1 ADRD, 71+, 2004 ***
** Demographic charactteristics across data sources
foreach var in race_h female agegroup_new  educ_h {
tab `var' [aw=adamswt] if _merge==3 //`var' in ADAMS 2000-2004
tab `var' [aw=wtcrnh] if wave==7 & inrange(age_yrs,70,200) //`var' in HRS 2004
tab `var' [aw=wtcrnh] if wave==8 & inrange(age_yrs,70,200) //`var' in HRS 2006
tab `var' [aw=wtcrnh] if wave==11 & inrange(age_yrs,70,200) //`var' in HRS 2012

}

*** Sensitivity ***
tab age_sensitivity [aw=adamswt] if _merge==3 //`var' in ADAMS 2000-2004
tab age_sensitivity [aw=wtcrnh] if wave==7&inrange(age_yrs,70,200) 
** ADRD Prevalence across data sources
*ADAMS 2000-2004
//ADAMS Definition
tab dementia_adams race_a [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
tab dementia_adams female [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
tab dementia_adams agegroup_new [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
// HRS Definition
tab dementiae_strict race_a [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
tab dementiae_strict female [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
tab dementiae_strict agegroup_new [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
* HRS 2004
tab dementiae_strict race_h [aw=wtcrnh] if inrange(age_yrs, 70,200) & wave==7, col
tab dementiae_strict female [aw=wtcrnh] if inrange(age_yrs, 70,200) & wave==7, col
tab dementiae_strict agegroup_new [aw=wtcrnh] if inrange(age_yrs, 70,200) & wave==7, col

*** ADRD Prevalence across data sources by age , sensitivity ***
tab dementia_adams age_sensitivity [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, col
tab dementiae_strict age_sensitivity [aw=wtcrnh] if inrange(age_yrs, 70,200) & wave==7, col


***Supplementary Table 1: Unadjusted ADRD prevalence by race/sex/age and year

bys wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(age_yrs,67,200)&inrange(wave,8,12), by (race_h)
bys wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(age_yrs,67,200)&inrange(wave,8,12), by (female)
bys wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(age_yrs,67,200)&inrange(wave,8,12), by (agegroup_claims)

*** Age_Sensitivity***
bys wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(age_yrs,67,200)&inrange(wave,8,12), by (age_sensitivity)
sort age_sensitivity
ci dementia_adams [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3, by(age_sensitivity) total
ci dementiae_strict [aw=adamswt] if inrange(age_yrs,70,200)&_merge==3,by(age_sensitivity) total
ci dementiae_strict [aw=wtcrnh] if inrange(age_yrs,70,200)&wave==7,by(age_sensitivity) total

***Table 2: Narrower age, Other race***
recode age_yrs (-10/66.9=.)(67/69.9=1)(70/74.9=2)(75/79.9=3)(80/84.9=4)(85/89.9=5)(90/200=6), gen(claims_sensi)
lab val claims_sensi ageclaims
lab def ageclaims 1"67 to 69" 2"70 to 74" 3"75 to 79" 4"80 to 84" 5"85 to 89" 6"90 and above"

eststo clear
eststo: logit dementiae_strict i.female i.claims_sensi i.racehrs i.wave if inrange(wave,8,11)&inrange(age_yrs,67,200)
outreg2 using "$output/95cisensitivity.xls", eform ci alpha(0.001, 0.05, 0.01) dec(2) br cttop(prev) label replace

***Supplementary Table 2: Predicted Dementia Prevalence***
predict dementiaprev_sensi
predict xb_sensi, xb
predict error_sensi, stdp
generate lb_sensi = xb_sensi - invnormal(0.975)*error_sensi
generate ub_sensi = xb_sensi + invnormal(0.975)*error_sensi
generate plb_sensi=invlogit(lb_sensi)
generate pub_sensi = invlogit(ub_sensi)

bys wave: tabstat dementiaprev_sensi plb_sensi pub_sensi [aw=wtcrnh] if inrange(wave,8,11)& inrange(age_yrs,67,200) 
bys wave : tabstat dementiaprev_sensi plb_sensi pub_sensi  [aw=wtcrnh] if inrange(wave,8,11)& inrange(age_yrs,67,200) , by (claims_sensi)
bys wave : tabstat dementiaprev_sensi plb_sensi pub_sensi  [aw=wtcrnh] if inrange(wave,8,11)& inrange(age_yrs,67,200) , by (racehrs)
bys wave: tabstat dementiaprev_sensi plb_sensi pub_sensi  [aw=wtcrnh] if inrange(wave,8,11)& inrange(age_yrs,67,200) , by (female)

gen lb_bon = xb_sensi-invnormal(0.9979)*error_sensi
gen ub_bon = xb_sensi + invnormal(0.9979)*error_sensi
gen plb_bon= invlogit(lb_bon)
gen pub_bon=invlogit(ub_bon)

bys wave: tabstat dementiaprev_sensi plb_bon pub_bon [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)
bys wave: tabstat dementiaprev_sensi plb_bon pub_bon [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(claims_sensi)
bys wave: tabstat dementiaprev_sensi plb_bon pub_bon [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(racehrs)
bys wave: tabstat dementiaprev_sensi plb_bon pub_bon [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(female)

gen lb_bontest = xb_sensi-invnormal(0.999479)*error_sensi
gen ub_bontest = xb_sensi + invnormal(0.999479)*error_sensi
gen plb_bontest= invlogit(lb_bontest)
gen pub_bontest=invlogit(ub_bontest)

bys wave: tabstat dementiaprev_sensi plb_bontest pub_bontest [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)
bys wave: tabstat dementiaprev_sensi plb_bontest pub_bontest [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(claims_sensi)
bys wave: tabstat dementiaprev_sensi plb_bontest pub_bontest [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(racehrs)
bys wave: tabstat dementiaprev_sensi plb_bontest pub_bontest [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), by(female)


*************************************************************
***Supplementary Table 3:  Sensitivity analysis - FFS and MA, revising ***

bys hhidpn (wave): gen l2medicare_hmo = medicare_hmo[_n-1]
gen ffs2=1 if partb_stat==1 & medicare_hmo==0
replace ffs2=0 if partb_stat==1 & medicare_stat==1 & l2medicare_hmo==1 & ffs!=1
tab ffs ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200) 
tab ffs ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200) ,m
 
 bys racehrs wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)&!missing(ffs2), by (ffs2)
 bys claims_sensi wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)&!missing(ffs2), by (ffs2)
 bys gender_h wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)&!missing(ffs2), by (ffs2)
bys wave: tabstat dementiae_strict [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200)&!missing(ffs2), by (ffs2)

bys wave: tab racehrs ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys wave: tab educ_h ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys wave: tab gender_h ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys wave: tab claims_sensi ffs2 [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys wave: tab agegroup_claims ffs [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
**************************************************************
*** Supplementary Table 4: Standardized Dementia Prevalence ***
gen sample=. 
 replace sample=1 if claims_sensi ==1 & gender_h==0 & racehrs==1 & wave==8
 replace sample=2 if claims_sensi ==2 & gender_h==0 & racehrs==1 & wave==8
 replace sample=3 if claims_sensi ==3 & gender_h==0 & racehrs==1 & wave==8
 replace sample=4 if claims_sensi ==4 & gender_h==0 & racehrs==1 & wave==8
 replace sample=5 if claims_sensi ==5 & gender_h==0 & racehrs==1 & wave==8
 replace sample=6 if claims_sensi ==6 & gender_h==0 & racehrs==1 & wave==8
 replace sample=7 if claims_sensi ==1 & gender_h==1 & racehrs==1 & wave==8
 replace sample=8 if claims_sensi ==2 & gender_h==1 & racehrs==1 & wave==8
 replace sample=9 if claims_sensi ==3 & gender_h==1 & racehrs==1 & wave==8
 replace sample=10 if claims_sensi ==4 & gender_h==1 & racehrs==1 & wave==8
 replace sample=11  if claims_sensi ==5 & gender_h==1 & racehrs==1 & wave==8
 replace sample=12 if claims_sensi ==6 & gender_h==1 & racehrs==1 & wave==8
 replace sample=13 if claims_sensi ==1 & gender_h==0 & racehrs==2 & wave==8
 replace sample=14 if claims_sensi ==2 & gender_h==0 & racehrs==2 & wave==8
 replace sample=15 if claims_sensi ==3 & gender_h==0 & racehrs==2 & wave==8
 replace sample=16 if claims_sensi ==4 & gender_h==0 & racehrs==2 & wave==8
 replace sample=17  if claims_sensi ==5 & gender_h==0& racehrs==2 & wave==8
 replace sample=18 if claims_sensi ==6 & gender_h==0 & racehrs==2 & wave==8
 replace sample=19 if claims_sensi ==1 & gender_h==1 & racehrs==2 & wave==8
 replace sample=20 if claims_sensi ==2 & gender_h==1& racehrs==2 & wave==8
 replace sample=21 if claims_sensi ==3 & gender_h==1 & racehrs==2 & wave==8
 replace sample=22 if claims_sensi ==4 & gender_h==1 & racehrs==2 & wave==8
 replace sample=23  if claims_sensi ==5 & gender_h==1& racehrs==2 & wave==8
 replace sample=24  if claims_sensi ==6 & gender_h==1 & racehrs==2 & wave==8
 replace sample=25 if claims_sensi ==1 & gender_h==0 & racehrs==3 & wave==8
 replace sample=26 if claims_sensi ==2 & gender_h==0 & racehrs==3 & wave==8
 replace sample=27 if claims_sensi ==3 & gender_h==0  & racehrs==3 & wave==8
 replace sample=28 if claims_sensi ==4 & gender_h==0  & racehrs==3& wave==8
 replace sample=29  if claims_sensi ==5 & gender_h==0 & racehrs==3 & wave==8
 replace sample=30 if claims_sensi ==6 & gender_h==0  & racehrs==3 & wave==8
 replace sample=31 if claims_sensi ==1 & gender_h==1 & racehrs==3 & wave==8
 replace sample=32 if claims_sensi ==2 & gender_h==1 & racehrs==3 & wave==8
 replace sample=33 if claims_sensi ==3 & gender_h==1  & racehrs==3 & wave==8
 replace sample=34 if claims_sensi ==4 & gender_h==1  & racehrs==3& wave==8
 replace sample=35 if claims_sensi ==5 & gender_h==1 & racehrs==3 & wave==8
 replace sample=36 if claims_sensi ==6 & gender_h==1  & racehrs==3 & wave==8
 replace sample=37 if claims_sensi ==1 & gender_h==0 & racehrs==4 & wave==8
 replace sample=38 if claims_sensi ==2 & gender_h==0 & racehrs==4 & wave==8
 replace sample=39 if claims_sensi ==3 & gender_h==0  & racehrs==4 & wave==8
 replace sample=40 if claims_sensi ==4 & gender_h==0  & racehrs==4& wave==8
 replace sample=41  if claims_sensi ==5 & gender_h==0 & racehrs==4 & wave==8
 replace sample=42 if claims_sensi ==6 & gender_h==0  & racehrs==4 & wave==8
 replace sample=43 if claims_sensi ==1 & gender_h==1 & racehrs==4 & wave==8
 replace sample=44 if claims_sensi ==2 & gender_h==1 & racehrs==4 & wave==8
 replace sample=45 if claims_sensi ==3 & gender_h==1  & racehrs==4 & wave==8
 replace sample=46 if claims_sensi ==4 & gender_h==1  & racehrs==4& wave==8
 replace sample=47 if claims_sensi ==5 & gender_h==1 & racehrs==4 & wave==8
 replace sample=48 if claims_sensi ==6 & gender_h==1  & racehrs==4 & wave==8
tab sample [aw=wtcrnh] if wave==8
tab dementiaprev_sensi sample if wave==8
tab plb_bontest sample  if wave==8
tab pub_bontest sample  if wave==8



gen sample2 = .
 replace sample2=1 if claims_sensi ==1 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=2 if claims_sensi ==2 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=3 if claims_sensi ==3 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=4 if claims_sensi ==4 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=5 if claims_sensi ==5 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=6 if claims_sensi ==6 & gender_h==0 & racehrs==1 & wave==11
 replace sample2=7 if claims_sensi ==1 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=8 if claims_sensi ==2 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=9 if claims_sensi ==3 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=10 if claims_sensi ==4 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=11  if claims_sensi ==5 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=12 if claims_sensi ==6 & gender_h==1 & racehrs==1 & wave==11
 replace sample2=13 if claims_sensi ==1 & gender_h==0 & racehrs==2 & wave==11
 replace sample2=14 if claims_sensi ==2 & gender_h==0 & racehrs==2 & wave==11
 replace sample2=15 if claims_sensi ==3 & gender_h==0 & racehrs==2 & wave==11
 replace sample2=16 if claims_sensi ==4 & gender_h==0 & racehrs==2 & wave==11
 replace sample2=17  if claims_sensi ==5 & gender_h==0& racehrs==2 & wave==11
 replace sample2=18 if claims_sensi ==6 & gender_h==0 & racehrs==2 & wave==11
 replace sample2=19 if claims_sensi ==1 & gender_h==1 & racehrs==2 & wave==11
 replace sample2=20 if claims_sensi ==2 & gender_h==1& racehrs==2 & wave==11
 replace sample2=21 if claims_sensi ==3 & gender_h==1 & racehrs==2 & wave==11
 replace sample2=22 if claims_sensi ==4 & gender_h==1 & racehrs==2 & wave==11
 replace sample2=23  if claims_sensi ==5 & gender_h==1& racehrs==2 & wave==11
 replace sample2=24  if claims_sensi ==6 & gender_h==1 & racehrs==2 & wave==11
 replace sample2=25 if claims_sensi ==1 & gender_h==0 & racehrs==3 & wave==11
 replace sample2=26 if claims_sensi ==2 & gender_h==0 & racehrs==3 & wave==11
 replace sample2=27 if claims_sensi ==3 & gender_h==0  & racehrs==3 & wave==11
 replace sample2=28 if claims_sensi ==4 & gender_h==0  & racehrs==3& wave==11
 replace sample2=29  if claims_sensi ==5 & gender_h==0 & racehrs==3 & wave==11
 replace sample2=30 if claims_sensi ==6 & gender_h==0  & racehrs==3 & wave==11
 replace sample2=31 if claims_sensi ==1 & gender_h==1 & racehrs==3 & wave==11
 replace sample2=32 if claims_sensi ==2 & gender_h==1 & racehrs==3 & wave==11
 replace sample2=33 if claims_sensi ==3 & gender_h==1  & racehrs==3 & wave==11
 replace sample2=34 if claims_sensi ==4 & gender_h==1  & racehrs==3& wave==11
 replace sample2=35 if claims_sensi ==5 & gender_h==1 & racehrs==3 & wave==11
 replace sample2=36 if claims_sensi ==6 & gender_h==1  & racehrs==3 & wave==11
 replace sample2=37 if claims_sensi ==1 & gender_h==0 & racehrs==4 & wave==11
 replace sample2=38 if claims_sensi ==2 & gender_h==0 & racehrs==4 & wave==11
 replace sample2=39 if claims_sensi ==3 & gender_h==0  & racehrs==4 & wave==11
 replace sample2=40 if claims_sensi ==4 & gender_h==0  & racehrs==4& wave==11
 replace sample2=41  if claims_sensi ==5 & gender_h==0 & racehrs==4 & wave==11
 replace sample2=42 if claims_sensi ==6 & gender_h==0  & racehrs==4 & wave==11
 replace sample2=43 if claims_sensi ==1 & gender_h==1 & racehrs==4 & wave==11
 replace sample2=44 if claims_sensi ==2 & gender_h==1 & racehrs==4 & wave==11
 replace sample2=45 if claims_sensi ==3 & gender_h==1  & racehrs==4 & wave==11
 replace sample2=46 if claims_sensi ==4 & gender_h==1  & racehrs==4& wave==11
 replace sample2=47 if claims_sensi ==5 & gender_h==1 & racehrs==4 & wave==11
 replace sample2=48 if claims_sensi ==6 & gender_h==1  & racehrs==4 & wave==11
tab sample2 [aw=wtcrnh] if wave==11
tab  dementiaprev_sensi sample2
tab plb_bon sample2  if wave==11
tab pub_bon sample2  if wave==11

*** Composition of the population over time ***

bys gender_h racehrs: tab claims_sensi wave [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys gender_h claims_sensi: tab race_h claims_sensi [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
bys race_h claims_sensi: tab gender_h wave [aw=wtcrnh] if inrange(wave,8,11)&inrange(age_yrs,67,200), col
******************************************************************



