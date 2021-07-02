clear all
set more off
capture log close

use "../samp0413_ADver.dta"

*** Table 1 ADRD, 71+, 2004 ***

** Descriptive stats & Figure 1
foreach var in race female agegroup {
	tab `var' if year==2004
	tab ADRD_ver `var' if inrange(age_yrs,70,200) & year==2004, col	
}

*** Sensitivity: narrower age bands ***
recode age_beg (-10/69.9=.)(70/74.9=1)(75/79.9=2)(80/84.9=3)(85/89.9=4)(90/200=5),gen(agegrp_sensitivity)
lab def agesensi 1"70 to 74" 2"75 to 79" 3 "80 to 84" 4"85 to 89" 5 "90 and above"
lab val agegrp_sensitivity agesensi
tab agegrp_sensitivity, m

foreach var in race female agegrp_sensitivity {
	tab `var' if year==2004
	tab ADRD_ver `var' if inrange(age_yrs,70,200) & year==2004, col	
} 

*** Figure 2 & 3 Unadjusted ADRD prevalence by race/sex/age and year

bys year: tabstat ADRD_ver if inrange(age_beg,67,200) & inrange(year,2006,2013), by (race)
bys year: tabstat ADRD_ver if inrange(age_beg,67,200) & inrange(year,2006,2013), by (female)
bys year: tabstat ADRD_ver if inrange(age_beg,67,200) & inrange(year,2006,2013), by (agegroup)

*** Sensitivity ***
bys year: tabstat ADRD_ver if inrange(age_beg,67,200) & inrange(year,2006,2013), by (agegrp_sensitivity)
sort agegrp_sensitivity
ci ADRD_ver if inrange(age_beg,70,200), by(agegrp_sensitivity) total
ci ADRD_ver if inrange(age_beg,70,200), by(agegrp_sensitivity) total
ci ADRD_ver if inrange(age_beg,70,200) & year==2004, by(agegrp_sensitivity) total


*** Table 2 ***
eststo: logit ADRD_ver i.female i.agegrp i.race i.year if inrange(year,2006,2013)&inrange(age_beg,67,200)


*** Supplementary Table 2 ***
predict dementiaprev_sensi
predict xb_sensi, xb
predict error_sensi, stdp
gen lb_sensi = xb_sensi - invnormal(0.975)*error_sensi
gen ub_sensi = xb_sensi + invnormal(0.975)*error_sensi
gen plb_sensi = invlogit(lb_sensi)
gen pub_sensi = invlogit(ub_sensi)
bys year: tabstat dementiaprev_sensi plb_sensi pub_sensi if inrange(year,2006,2013)& inrange(age_beg,67,200) 
bys year: tabstat dementiaprev_sensi plb_sensi pub_sensi if inrange(year,2006,2013)& inrange(age_beg,67,200), by(agegrp)

gen lb_bon = xb_sensi - invnormal(0.9979)*error_sensi
gen ub_bon = xb_sensi + invnormal(0.9979)*error_sensi
gen plb_bon = invlogit(lb_sensi)
gen pub_bon = invlogit(ub_sensi)
bys year: tabstat dementiaprev_sensi plb_bon pub_bon if inrange(year,2006,2013)& inrange(age_beg,67,200) 
bys year: tabstat dementiaprev_sensi plb_bon pub_bon if inrange(year,2006,2013)& inrange(age_beg,67,200), by(agegrp)

gen lb_bontest = xb_sensi-invnormal(0.999479)*error_sensi
gen ub_bontest = xb_sensi + invnormal(0.999479)*error_sensi
gen plb_bontest= invlogit(lb_bontest)
gen pub_bontest=invlogit(ub_bontest)
bys year: tabstat dementiaprev_sensi plb_bontest pub_bontest if inrange(year,2006,2013)& inrange(age_beg,67,200) 
bys year: tabstat dementiaprev_sensi plb_bontest pub_bontest if inrange(year,2006,2013)& inrange(age_beg,67,200), by(agegrp)


*** Supplementary Table 4 ***
gen sample=.
replace sample=1 if agegrp ==1 & male==0 & race==1 & year==2006
replace sample=2 if agegrp ==2 & male==0 & race==1 & year==2006
replace sample=3 if agegrp ==3 & male==0 & race==1 & year==2006
replace sample=4 if agegrp ==4 & male==0 & race==1 & year==2006
replace sample=5 if agegrp ==5 & male==0 & race==1 & year==2006
replace sample=6 if agegrp ==6 & male==0 & race==1 & year==2006
replace sample=7 if agegrp ==1 & male==1 & race==1 & year==2006
replace sample=8 if agegrp ==2 & male==1 & race==1 & year==2006
replace sample=9 if agegrp ==3 & male==1 & race==1 & year==2006
replace sample=10 if agegrp ==4 & male==1 & race==1 & year==2006
replace sample=11 if agegrp ==5 & male==1 & race==1 & year==2006
replace sample=12 if agegrp ==6 & male==1 & race==1 & year==2006
replace sample=13 if agegrp ==1 & male==0 & race==2 & year==2006
replace sample=14 if agegrp ==2 & male==0 & race==2 & year==2006
replace sample=15 if agegrp ==3 & male==0 & race==2 & year==2006
replace sample=16 if agegrp ==4 & male==0 & race==2 & year==2006
replace sample=17 if agegrp ==5 & male==0 & race==2 & year==2006
replace sample=18 if agegrp ==6 & male==0 & race==2 & year==2006
replace sample=19 if agegrp ==1 & male==1 & race==2 & year==2006
replace sample=20 if agegrp ==2 & male==1 & race==2 & year==2006
replace sample=21 if agegrp ==3 & male==1 & race==2 & year==2006
replace sample=22 if agegrp ==4 & male==1 & race==2 & year==2006
replace sample=23 if agegrp ==5 & male==1 & race==2 & year==2006
replace sample=24 if agegrp ==6 & male==1 & race==2 & year==2006
replace sample=25 if agegrp ==1 & male==0 & race==3 & year==2006
replace sample=26 if agegrp ==2 & male==0 & race==3 & year==2006
replace sample=27 if agegrp ==3 & male==0 & race==3 & year==2006
replace sample=28 if agegrp ==4 & male==0 & race==3 & year==2006
replace sample=29 if agegrp ==5 & male==0 & race==3 & year==2006
replace sample=30 if agegrp ==6 & male==0 & race==3 & year==2006
replace sample=31 if agegrp ==1 & male==1 & race==3 & year==2006
replace sample=32 if agegrp ==2 & male==1 & race==3 & year==2006
replace sample=33 if agegrp ==3 & male==1 & race==3 & year==2006
replace sample=34 if agegrp ==4 & male==1 & race==3 & year==2006
replace sample=35 if agegrp ==5 & male==1 & race==3 & year==2006
replace sample=36 if agegrp ==6 & male==1 & race==3 & year==2006
replace sample=37 if agegrp ==1 & male==0 & race==99 & year==2006
replace sample=38 if agegrp ==2 & male==0 & race==99 & year==2006
replace sample=39 if agegrp ==3 & male==0 & race==99 & year==2006
replace sample=40 if agegrp ==4 & male==0 & race==99 & year==2006
replace sample=41 if agegrp ==5 & male==0 & race==99 & year==2006
replace sample=42 if agegrp ==6 & male==0 & race==99 & year==2006
replace sample=43 if agegrp ==1 & male==1 & race==99 & year==2006
replace sample=44 if agegrp ==2 & male==1 & race==99 & year==2006
replace sample=45 if agegrp ==3 & male==1 & race==99 & year==2006
replace sample=46 if agegrp ==4 & male==1 & race==99 & year==2006
replace sample=47 if agegrp ==5 & male==1 & race==99 & year==2006
replace sample=48 if agegrp ==6 & male==1 & race==99 & year==2006

tab sample, m
tab sample if year==2006
bys sample: tabstat dementiaprev_sensi if year==2006
bys sample: tabstat plb_sensi pub_sensi if year==2006

gen sample2=.
replace sample2=1 if agegrp ==1 & male==0 & race==1 & year==2012
replace sample2=2 if agegrp ==2 & male==0 & race==1 & year==2012
replace sample2=3 if agegrp ==3 & male==0 & race==1 & year==2012
replace sample2=4 if agegrp ==4 & male==0 & race==1 & year==2012
replace sample2=5 if agegrp ==5 & male==0 & race==1 & year==2012
replace sample2=6 if agegrp ==6 & male==0 & race==1 & year==2012
replace sample2=7 if agegrp ==1 & male==1 & race==1 & year==2012
replace sample2=8 if agegrp ==2 & male==1 & race==1 & year==2012
replace sample2=9 if agegrp ==3 & male==1 & race==1 & year==2012
replace sample2=10 if agegrp ==4 & male==1 & race==1 & year==2012
replace sample2=11 if agegrp ==5 & male==1 & race==1 & year==2012
replace sample2=12 if agegrp ==6 & male==1 & race==1 & year==2012
replace sample2=13 if agegrp ==1 & male==0 & race==2 & year==2012
replace sample2=14 if agegrp ==2 & male==0 & race==2 & year==2012
replace sample2=15 if agegrp ==3 & male==0 & race==2 & year==2012
replace sample2=16 if agegrp ==4 & male==0 & race==2 & year==2012
replace sample2=17 if agegrp ==5 & male==0 & race==2 & year==2012
replace sample2=18 if agegrp ==6 & male==0 & race==2 & year==2012
replace sample2=19 if agegrp ==1 & male==1 & race==2 & year==2012
replace sample2=20 if agegrp ==2 & male==1 & race==2 & year==2012
replace sample2=21 if agegrp ==3 & male==1 & race==2 & year==2012
replace sample2=22 if agegrp ==4 & male==1 & race==2 & year==2012
replace sample2=23 if agegrp ==5 & male==1 & race==2 & year==2012
replace sample2=24 if agegrp ==6 & male==1 & race==2 & year==2012
replace sample2=25 if agegrp ==1 & male==0 & race==3 & year==2012
replace sample2=26 if agegrp ==2 & male==0 & race==3 & year==2012
replace sample2=27 if agegrp ==3 & male==0 & race==3 & year==2012
replace sample2=28 if agegrp ==4 & male==0 & race==3 & year==2012
replace sample2=29 if agegrp ==5 & male==0 & race==3 & year==2012
replace sample2=30 if agegrp ==6 & male==0 & race==3 & year==2012
replace sample2=31 if agegrp ==1 & male==1 & race==3 & year==2012
replace sample2=32 if agegrp ==2 & male==1 & race==3 & year==2012
replace sample2=33 if agegrp ==3 & male==1 & race==3 & year==2012
replace sample2=34 if agegrp ==4 & male==1 & race==3 & year==2012
replace sample2=35 if agegrp ==5 & male==1 & race==3 & year==2012
replace sample2=36 if agegrp ==6 & male==1 & race==3 & year==2012
replace sample2=37 if agegrp ==1 & male==0 & race==99 & year==2012
replace sample2=38 if agegrp ==2 & male==0 & race==99 & year==2012
replace sample2=39 if agegrp ==3 & male==0 & race==99 & year==2012
replace sample2=40 if agegrp ==4 & male==0 & race==99 & year==2012
replace sample2=41 if agegrp ==5 & male==0 & race==99 & year==2012
replace sample2=42 if agegrp ==6 & male==0 & race==99 & year==2012
replace sample2=43 if agegrp ==1 & male==1 & race==99 & year==2012
replace sample2=44 if agegrp ==2 & male==1 & race==99 & year==2012
replace sample2=45 if agegrp ==3 & male==1 & race==99 & year==2012
replace sample2=46 if agegrp ==4 & male==1 & race==99 & year==2012
replace sample2=47 if agegrp ==5 & male==1 & race==99 & year==2012
replace sample2=48 if agegrp ==6 & male==1 & race==99 & year==2012

tab sample2, m
tab sample2 if year==2012
tabstat dementiaprev_sensi, stat(mean) by(race)


*** Supplementary Table 5 ***
use "../samp0413_ADver.dta", clear
append using "../HRS_append.dta", force
recode age_beg (-10/66.9=.)(67/69.9=1)(70/74.9=2)(75/79.9=3)(80/84.9=4)(85/89.9=5)(90/200=6), gen(agegrp)
replace HRS=0 if missing(HRS)
tab HRS, m

eststo: logit ADRD_ver i.agegrp i.race i.female i.year i.HRS if inrange(year,2006,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race##i.HRS i.female i.year if inrange(year,2006,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp##i.HRS i.race i.female i.year if inrange(year,2006,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race i.female##i.HRS i.year if inrange(year,2006,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race i.female i.year##i.HRS if inrange(year,2006,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race i.female i.year i.HRS if inrange(year,2004,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race##i.HRS i.female i.year if inrange(year,2004,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp##i.HRS i.race i.female i.year if inrange(year,2004,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race i.female##i.HRS i.year if inrange(year,2004,2013) & inrange(age_beg,67,200)
eststo: logit ADRD_ver i.agegrp i.race i.female i.year##i.HRS if inrange(year,2004,2013) & inrange(age_beg,67,200)

