* YZ August 2017  RandHRS Data Clean 
clear all 
capture log close
set more off
set maxvar 30000
global hrsfat /schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/Stata
global dementia /schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/dementia
global rand_hrs "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_p.dta"
global input $dementia/Input
global output $dementia/Output
log using $output/randhrs_clean, text replace
use $rand_hrs,clear
global hrs96 $hrsfat/hrs96.dta
global hrs98 $hrsfat/hrs98.dta
global hrs00 $hrsfat/hrs00.dta
global hrs02 $hrsfat/hrs02.dta
global hrs04 $hrsfat/hrs04.dta
global hrs06 $hrsfat/hrs06.dta
global hrs08 $hrsfat/hrs08.dta
global hrs10 $hrsfat/hrs10.dta
global hrs12 $hrsfat/hrs12.dta
global hrs14 $hrsfat/hrs14.dta

** using version p
sort hhidpn
merge hhidpn using $input/rand_hrscog2016
sort hhidpn
ren _merge _merge2016
#d;
	keep 
	rahrsamp raahdsmp racohbyr hacohort h*hhid hhidpn r*wtresp r*wthh r*iwbeg rabyear rabmonth r*iwendy r*wtcrnh
	rabplace rahispan ragender raracem raeduc raedyrs r*agey_e r*agem_e r*cenreg r*iwstat r*mstat 
	r*bmi r*smokev r*smoken 
	r*cancre r*hearte r*heartf r*hibpe r*diabe r*lunge r*stroke
	r*adla r1iadlww r1adlw r*iadla r*nrshom r*nhmliv r*shlt r*hosp r*homcar
	r*govmd r*govmr r*higov r*covr r*covs r*covrt r*hiothp r*hiltc r*lifein 
	r*oopmd r*doctim r*hsptim r*hspnit
	r*sayret r*lbrf r*work
	r*dstat
	r*cesd r*cesdm r*proxy
	r*issdi r*isdi r*issi 
 	r*iearn r*isret r*ipena r*iunwc r*igxfr
        r*flone r*psyche r*arthre
        r*bathh r*dressh r*walkrh r*dress r*bath r*eat r*money r*phone r*bed r*toilt r*walkr r*meds r*shop r*meals
        r7jlocc r7jlocca r7jlind r*jcocc
        inw*
	r*imrc r*dlrc 
 
 	h*icap h*iothr h*itot
	h*atoth h*anethb 
	h*atotf h*astck h*achck h*acd h*abond h*aothr
	h*arles h*atran h*absns h*aira 
	h*atota h*atotb h*atotn
	h*amort h*ahmln h*amrtb h*adebt
        h*cpl
	h*child
	s*iwstat s*agey_e s*agem_e s*hhidpn s*wtresp s*gender s*mstat s*racem s*hispan s*educ
	r*memrye r*alzhe r*demen
        r*igxfr
	r*jcten r*toilta 
	r*jcpen  r*peninc 
	r*jyears 
	
	/*financial outcomes*/ h*ahous h*afhous
	;
#d cr 

*** ------------------------------------------

*Recode memrye for wave 10 and 11

generate r10memrye=.
replace r10memrye=1 if r10alzhe==1 | r10demen==1 
replace r10memrye=0 if r10alzhe==0 & r10demen==0
replace r10memrye=.d if r10alzhe==.d & r10demen==.d
replace r10memrye=.r if r10alzhe==.r & r10demen==.r

generate r11memrye=.
replace r11memrye=1 if r11alzhe==1 | r11demen==1
replace r11memrye=0 if r11alzhe==0 & r11demen==0
replace r11memrye=.d if r11alzhe==.d & r11demen==.d
replace r11memrye=.r if r11alzhe==.r & r11demen==.r

generate r12memrye=.
replace r12memrye=1 if r12alzhe==1 | r12demen==1
replace r12memrye=0 if r12alzhe==0 & r12demen==0
replace r12memrye=.d if r12alzhe==.d & r12demen==.d
replace r12memrye=.r if r12alzhe==.r & r12demen==.r

tab r9memrye, m
tab r10memrye, m
tab r11memrye, m
tab r12memrye, m

* Merge with nursing home weights from the HRS tracker file.  Currently defined for waves 5-10, we zeroed out waves 1-4 and wave 11.  Variables are of the form r*weightnh
merge 1:1 hhidpn using "/schaeffer-a/sch-projects/public-data-projects/FEM/zhuyingy/trunk/input_data/nh_weights.dta"
tab _merge 
drop _merge


* Data clean and reshape
* Rename - Respondent 
	#d ; 
	foreach var in cenreg mstat wtresp agey_e agem_e iwstat iwbeg  iwendy/*momliv dadliv iwdelta*/ wtcrnh
	smokev smoken bmi shlt flone psyche arthre weightnh
	cancre hearte heartf hibpe diabe lunge stroke arthre psyche flone alzhe demen
	adla iadla  nrshom nhmliv hosp homcar
	/*retirecomm retirecomm_continue key_serv other_serv serv key_serv_use other_serv_use serv_use*/
		oopmd doctim hsptim hspnit
       isret isdi issi issdi iearn sayret lbrf ipena iunwc igxfr 
	work /*work2 jhours jhour2 jweeks jweek2 wgihr wgiwk */	
	govmd govmr higov covr covs hiothp covrt hiltc lifein memrye wthh jcten
        bathh dressh walkrh  dress bath eat money phone bed toilt walkr meds shop meals/*helperct helphoursyr helphoursyr_sp helphoursyr_nonsp volhours nkids gkcarehrs kid_byravg kid_mnage nkid_liv10mi*/
        isemp iosemp ioss iosdi iossi     
        /*parhelphours paralive parnotmar par10mi
        malive falive mlivage flivage mmarried fmarried mliv10mi fliv10mi*/
	cesd cesdm proxy toilta peninc jcpen imrc dlrc jcocc
	c/*aid2yr caidcur
	iadlhelp
	weightnh
	jyears
	binge*/ 
        { ; 
			forvalues i = 1(1)12 { ; 
				cap confirm var r`i'`var'; 
				if !_rc{;
					ren r`i'`var' `var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 	
	
* Household
	#d ; 
	foreach var in 	hhid icap iothr itot atoth anethb 
	atotf astck achck acd abond aothr  
	arles atran absns aira 
	atota atotb atotn 
	amort ahmln amrtb adebt cpl child ahous afhous
        { ; 
			forvalues i = 1(1)12{ ; 
				cap confirm var h`i'`var'; 
				if !_rc{;
					ren h`i'`var' h`var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 	
	
* Spouse
	#d ; 
	foreach var in hhidpn iwstat agey_e agem_e wtresp gender mstat racem hispan educ memrye alzhe demen igxfr jcten toilta jcpen peninc jyears { ; 
			forvalues i = 1(1)12 { ; 
				cap confirm var s`i'`var'; 
				if !_rc{;
					ren s`i'`var' s`var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 
	
	#d ; 
local wave3fat e5135 e5136 e5148 e5133 e5134 e5149 e5150 e5145 e5170_1
;
merge 1:1 hhidpn using $hrs96, keep(master match) keepusing(`wave3fat') nogen;

local wave4fat /* f1764 f2677 f2678 f2681 f2244 f2246 f2247 f1112 f1118 f1152 f1171
               f1278 f1279 f1280 f1166 f1167 f1135 f1141 f1142 f992 f1239 f1241 
               f2562 f2564 f2565 f2567 f2569 f2570 f2572 f2574 f2575 f2577 f2578 f2579 f2580 
               /* heart attack variables*/ f1156 f1157 f1158 f1162 f1164 f1165 f1168 f1169 f1170
               f1174 f1175 f26_1 f219 f218 f699 f697
               /*diabetes variables*/ f231 f1116 f1117 f1118 */
		/*insurance variables*/ f5868 f5869 f5881 f5882 f5883 f5887 f5888 f5889 f5938 f5893
			   f247 f5866 f5867 f5882 f5883 f5878 f5903 
;
merge 1:1 hhidpn  using $hrs98, keep(master match) keepusing(`wave4fat') nogen;

local wave5fat  /* g1980 g2995 g2996 g2999 g2495 g2497 g2498 g1241 g1249 g1285 g1411
               g1412 g1413 g1299 g1300 g1304 g1238 g1268 g1274 g1275 g1079 g1372 
               g1374 g2860 g2862 g2863 g2865 g2867 g2868 g2870 g2872 
               g2873 g2875 g2876 g2877 g2878 
               /* heart attack variables*/ g1289 g1290 g1291 g1295 g1297 g1298 g1301 g1302 g1303 g1307 g1308 
               g26_1 gprviwyr	gprviwmo giwyear	giwmonth
               /*diabetes variables*/ g231 g1245 g1248 g1249*/
			   /*insurance variables*/ g6241 g6242 g6254 g6260 g6261 g6262 g6312 g6266 
			   g247 g6238 g6240 g6255 g6256 g6251 g6276
;
merge 1:1 hhidpn using $hrs00, keep(master match) keepusing(`wave5fat') nogen;

*** Read version c, newer than a. Versin c has 2 less individuals hhidpn=22965040 and 22965041
*** (dropped because of missing values?) The count on the HRS website corresponds to version a.
*** Difference between versions c and d is on the coding of unknown or refused response (adds more 9s at the beggining) 
*** Version a has a set of duplicate variables (same name preceded by "_" doing the same thing: adjusting the length of 
*** the variable by adding or dropping an 9 when unknown or missing answer

local wave6fat  /* he012 hg086 hg087 hg092 hf175 hf176 hf177 hc008 hc012 hc017 hc033
               hc125 hc126 hc127 hc043 hc044 hc048 hc025 hc028 hc029 hb019 hc104 hc105 hg041 hg042 hg043 
			   hg044 hg045 hg046 hg047 hg048 hg049 hg050 hg051 hg052 hb053
               /* heart attack variables*/ hz105 hc036 hc037 hc038 hc040 hc041 hc042
               hc045 hc046 hc047 hc051 hc052 hz093 hz092 hz076 ha501 ha500 
               /*diabetes variables*/ hz102 hc010 hc011 hc012*/ 
			   /*insurance variables*/ hn005 hn006 hn009 
			   hz113 hn001 hn004 hn010 hn011 hn007
;
merge 1:1 hhidpn using $hrs02, keep(master match) keepusing(`wave6fat') nogen;

local wave7fat /* je012 jg086 jg195 jg196 jg197 jg198 jg199 jg200 jg201 jf175 jf176
               jf177 jlb508* jlb509 jlb511* jlb512* jlb513 jlb515* jlb516* jlb517 jlb519*
               jlb520* jlb521 jlb504* jc008 jc012 jc017 jc033 jc214 jz204 jc125 jc126 jc127
               jc043 jc044 jc048 jc028 jc029 jb019 jc104 jc105 jn005 jn006 jg041 jg042 jg043
               jg044 jg045 jg046 jg047 jg048 jg049 jg050 jg051 jg052 jg053 
               /* heart attack variables*/ jc036 jc037 jc038 jc040 jc041 jc042 jc045 jc046 jc047 jc051 jc052
               jz093 jz092 jz076 ja501 ja500
              /*diabetes variables*/ jz102 jz204 jc214 jc010 jc011 jc012*/
			  /*insurance variables*/ jn005 jn006 jn009 
			   jz113 jn001 jn004 jn010 jn011 jn007
;
 
merge 1:1 hhidpn using $hrs04, keep(master match) keepusing(`wave7fat') nogen;

local wave8fat /* ke012 klb018 kf175 klb020* kc008 kc012 kc017 kc033 kc214 kz204
               kc125 kc126 kc127 kc043 kc044 kc048 kc028 kc029 kb019 kc104 kc105 kn005 kn006
               kg041	kg042	kg043 kg044	kg045	kg046 kg047	kg048	kg049 kg050	kg051	kg052	kg053 
               /* heart attack variables*/ kc036 kc037 kc038 kc040 kc041 kc042 kc045 kc046 kc047
               kc051 kc052 kz093 kz092 kz076 ka501 ka500
			   /*diabetes variables*/ kz102 kz204 kc214 kc010 kc011 kc012*/
			   /*insurance variables*/ kn005 kn006 kn009 
			   kz113 kn001 kn004 kn010 kn011 kn007
;
merge 1:1 hhidpn using $hrs06, keep(master match) keepusing(`wave8fat') nogen;

local wave9fat /* le012 llb018 lf175 llb020* lc008 lc012 lc017 lc033 lc214 lz204
               lc125 lc126 lc127 lc043 lc044 lc048 lc028 lc029 lb019 lc104 lc105 ln005 ln006
               lg041	lg042	lg043 lg044	lg045	lg046 lg047	lg048	lg049 lg050	lg051	lg052	lg053
               /* heart attack variables*/ lc036 lc037 lc038 lc040 lc041 lc042 lc045 lc046 lc047
               lc051 lc052 lz093 lz092 lz076 la501 la500
			   /*diabetes variables*/ lz102 lc214 lc010 lc011 lc012*/
			   /*insurance variables*/ ln005 ln006 ln009 
			   lz113 ln001 ln004 ln010 ln011 ln007
;
merge 1:1 hhidpn using $hrs08, keep(master match) keepusing(`wave9fat') nogen;

local wave10fat MN005 MN006 MN009 MZ113 MN001 MN004 MN010 MN011 MN007;
merge 1:1 hhidpn using $hrs10, keep(master match) keepusing(`wave10fat') nogen;

local wave11fat /* ne012 nlb018 nf175 nlb020* nc008 nc012 nc017 nc033 nc214 nz204
                nc125 nc126 nc127 nc043 nc044 nc028 nc029 nb019 nc104 nc105 nc048 nc263 nc272
                nc273 nn005 nn006 ng041 ng042	ng043 ng044	ng045	ng046 ng047	ng048	ng049 ng050	
                ng051	ng052	ng053 /* heart attack variables*/ nc036 nc037 nc038 nc257 nc258
                nc259 nc274 nc275 nc276 nc277 nc040 nc041 nc042 nc043 nc044 nc260 nc261 nc262
                nc045 nc046 nc047 nc263 nc264 nc265 nc048 nc049 nc050 nc266 nc267 nc268 nc269
                nc282 nc270m1 nc051 nc052 na500 na501 nz255 nz093 nz076 nz092 */
		          /*insurance variables*/nn005 nn006 nn009 nz113 
			  nn001 nn004 nn007	
;
merge 1:1 hhidpn using $hrs12, keep(master match) keepusing(`wave11fat') nogen;

local wave12fat on005 on006 on009 oz113 on001 on004 on007
;

merge 1:1 hhidpn using $hrs14, keep(master match) keepusing(`wave12fat') nogen;

#d cr

***** derive insurance variables 

** Wave 3 **
gen medicare_hmo3 = .
replace medicare_hmo3 = 0 if inlist(e5148,5) & inlist(e5133,1,8,9) 
replace medicare_hmo3 = 0 if inlist(e5133,5) 
replace medicare_hmo3= 1 if e5148 == 1
lab var medicare_hmo3 "Medicare through HMO enrollment status in wave 3"

gen medicare_mo3= 12*e5149 if e5149 < 98
replace medicare_mo3 = e5150 if e5150 < 98 & inlist(e5149,0,98,99,.)
lab var medicare_mo3 "Medicare through HMO enrollment in months (wave 3)"

gen medicare_stat3 = .
replace medicare_stat3 = 0 if inlist(e5133,5)
replace medicare_stat3 = 1 if inlist(e5133,1)

** Wave 4 **
gen medicare_hmo4 = .
replace medicare_hmo4 = 0 if inlist(f5881,5) & inlist(f5866,1,8,9) 
replace medicare_hmo4 = 0 if inlist(f5866,5) 
replace medicare_hmo4 = 1 if f5881 == 1
lab var medicare_hmo4 "Medicare through HMO enrollment status in wave 4"

gen medicare_mo4= 12*f5882 if f5882 < 98
replace medicare_mo4 = f5883 if f5883 < 98 & inlist(f5882,0,98,99,.)
lab var medicare_mo4 "Medicare through HMO enrollment in months (wave 4)"

gen medicare_stat4 = .
replace medicare_stat4 = 0 if inlist(f5866,5)
replace medicare_stat4 = 1 if inlist(f5866,1)

** Wave 5 **
gen medicare_hmo5 = .
replace medicare_hmo5 = 0 if inlist(g6254,5) & inlist(g6238,1,8,9)
replace medicare_hmo5 = 0 if inlist(g6238,5)
replace medicare_hmo5 = 1 if g6254 == 1
lab var medicare_hmo5 "Medicare through HMO enrollment status in wave 5"

gen medicare_mo5= 12*g6255 if g6255 < 98
replace medicare_mo5 = g6256 if g6256 < 98 & inlist(g6255,0,98,99,.)
lab var medicare_mo5 "Medicare through HMO enrollment in months (wave 5)"

gen medicare_stat5 = .
replace medicare_stat5 = 0 if inlist(g6238,5)
replace medicare_stat5 = 1 if inlist(g6238,1)

** Wave 6 **
gen medicare_hmo6 = .
replace medicare_hmo6 = 0 if inlist(hn009,5) & inlist(hn001,1,8,9) 
replace medicare_hmo6 = 0 if inlist(hn001,5)
replace medicare_hmo6 = 1 if hn009 == 1 
lab var medicare_hmo6 "Medicare through HMO enrollment status in wave 6"

gen medicare_mo6= 12*hn010 if hn010 < 98
replace medicare_mo6 = hn011 if hn011 < 98 & inlist(hn010,0,98,99,.)
lab var medicare_mo6 "Medicare through HMO enrollment in months (wave 6)"

gen medicare_stat6 = .
replace medicare_stat6 = 0 if inlist(hn001,5)
replace medicare_stat6 = 1 if inlist(hn001,1)
** Wave 7 **
gen medicare_hmo7 = .
replace medicare_hmo7 = 0 if inlist(jn009,5) & inlist(jn001,1,8,9)
replace medicare_hmo7 = 0 if inlist(jn001,5)
replace medicare_hmo7 = 1 if jn009 == 1 
lab var medicare_hmo7 "Medicare through HMO enrollment status in wave 7"

gen medicare_mo7= 12*jn010 if jn010 < 98
replace medicare_mo7 = jn011 if jn011 < 98 & inlist(jn010,0,98,99,.)
lab var medicare_mo7 "Medicare through HMO enrollment in months (wave 7)"

gen medicare_stat7 = .
replace medicare_stat7 = 0 if inlist(jn001,5)
replace medicare_stat7 = 1 if inlist(jn001,1)

** Wave 8 **
gen medicare_hmo8 = .
replace medicare_hmo8 = 0 if inlist(kn009,5) & inlist(kn001,1,8,9)
replace medicare_hmo8 = 0 if inlist(kn001,5)
replace medicare_hmo8 = 1 if kn009 == 1
lab var medicare_hmo8 "Medicare through HMO enrollment status in wave 8"

gen medicare_mo8= 12*kn010 if kn010 < 98
replace medicare_mo8 = kn011 if kn011 < 98 & inlist(kn010,0,98,99,.)
lab var medicare_mo8 "Medicare through HMO enrollment in months (wave 8)"

gen medicare_stat8 = .
replace medicare_stat8 = 0 if inlist(kn001,5)
replace medicare_stat8 = 1 if inlist(kn001,1)
** Wave 9 **
gen medicare_hmo9 = .
replace medicare_hmo9 = 0 if inlist(ln009,5) & inlist(ln001,1,8,9)
replace medicare_hmo9 = 0 if inlist(ln001,5)
replace medicare_hmo9 = 1 if ln009 == 1
lab var medicare_hmo9 "Medicare through HMO enrollment status in wave 9"

gen medicare_mo9= 12*ln010 if ln010 < 98
replace medicare_mo9 = ln011 if ln011 < 98 & inlist(ln010,0,98,99,.)
lab var medicare_mo9 "Medicare through HMO enrollment in months (wave 9)"

gen medicare_stat9 = .
replace medicare_stat9 = 0 if inlist(ln001,5)
replace medicare_stat9 = 1 if inlist(ln001,1)

** Wave 10 ** 
gen medicare_hmo10 = .
replace medicare_hmo10 = 0 if inlist(MN009,5) & inlist(MN001,1,8,9)
replace medicare_hmo10 = 0 if inlist(MN001,5)
replace medicare_hmo10 = 1 if MN009 == 1
lab var medicare_hmo10 "Medicare through HMO enrollment status in wave 10"

gen medicare_mo10= 12*MN010 if MN010 < 98
replace medicare_mo10 = MN011 if MN011 < 98 & inlist(MN010,0,98,99,.)
lab var medicare_mo10 "Medicare through HMO enrollment in months (wave 10)"

gen medicare_stat10 = .
replace medicare_stat10 = 0 if inlist(MN001,5)
replace medicare_stat10 = 1 if inlist(MN001,1)

** Wave 11 ** 
gen medicare_hmo11 = .
replace medicare_hmo11 = 0 if inlist(nn009,5) & inlist(nn001,1,8,9)
replace medicare_hmo11 = 0 if inlist(nn001,5)
replace medicare_hmo11 = 1 if nn009 == 1
lab var medicare_hmo11 "Medicare through HMO enrollment status in wave 11"

gen medicare_stat11 = .
replace medicare_stat11 = 0 if inlist(nn001,5)
replace medicare_stat11 = 1 if inlist(nn001,1)
** Wave 12 ** 
gen medicare_hmo12 = .
replace medicare_hmo12 = 0 if inlist(on009,5) & inlist(on001,1,8,9)
replace medicare_hmo12 = 0 if inlist(on001,5)
replace medicare_hmo12 = 1 if on009 == 1
lab var medicare_hmo12 "Medicare through HMO enrollment status in wave 12"

gen medicare_stat12 = .
replace medicare_stat12 = 0 if inlist(on001,5)
replace medicare_stat12 = 1 if inlist(on001,1)
***** derive medicare part b coverage
gen partb_stat4 = .
replace partb_stat4 = 0 if inlist(f5866,5)
replace partb_stat4 = 0 if inlist(f5867,5)
replace partb_stat4 = 1 if inlist(f5867,1) 

lab var partb_stat4 "enrollment in Part B in wave 4"

gen partb_stat5 = .
replace partb_stat5 = 0 if inlist(g6238,5) 
replace partb_stat5 = 0 if inlist(g6240,5)
replace partb_stat5 = 1 if inlist(g6240,1)
lab var partb_stat5 "enrollment in Part B in wave 5"

gen partb_stat6 = .
replace partb_stat6 = 0 if inlist(hn001,5) 
replace partb_stat6 = 0 if inlist(hn004,5)
replace partb_stat6 = 1 if inlist(hn004,1)
lab var partb_stat6 "enrollment in Part B in wave 6"

gen partb_stat7 = .
replace partb_stat7 = 0 if inlist(jn001,5)
replace partb_stat7 = 0 if inlist(jn004,5)
replace partb_stat7 = 1 if inlist(jn004,1)
lab var partb_stat7 "enrollment in Part B in wave 7"

gen partb_stat8 = .
replace partb_stat8 = 0 if inlist(kn001,5) 
replace partb_stat8 = 0 if inlist(kn004,5)
replace partb_stat8 = 1 if inlist(kn004,1)
lab var partb_stat8 "enrollment in Part B in wave 8"

gen partb_stat9 = .
replace partb_stat9 = 0 if inlist(ln001,5)
replace partb_stat9 = 0 if inlist(ln004,5)
replace partb_stat9 = 1 if inlist(ln004,1)
lab var partb_stat9 "enrollment in Part B in wave 9" 

gen partb_stat10 = .
replace partb_stat10 = 0 if inlist(MN001,5)
replace partb_stat10 = 0 if inlist(MN004,5)
replace partb_stat10 = 1 if inlist(MN004,1)
lab var partb_stat10 "enrollment in Part B in wave 10" 

gen partb_stat11 = .
replace partb_stat11 = 0 if inlist(nn001,5)
replace partb_stat11 = 0 if inlist(nn004,5)
replace partb_stat11 = 1 if inlist(nn004,1)
lab var partb_stat11 "enrollment in Part B in wave 11" 

gen partb_stat12 = .
replace partb_stat12 = 0 if inlist(on001,5)
replace partb_stat12 = 0 if inlist(on004,5)
replace partb_stat12 = 1 if inlist(on004,1)
lab var partb_stat12 "enrollment in Part B in wave 12" 

*Medicare Advantage Coverage: Partb coverage and HMO in the last wave
gen ma4=1 if medicare_hmo3==1 & partb_stat4==1
replace ma4=0 if (medicare_stat4==1|partb_stat4==1)&ma4!=1

gen ma5=1 if medicare_hmo4==1 & partb_stat5==1
replace ma5=0 if (medicare_stat5==1|partb_stat5==1)&ma5!=1

gen ma6=1 if medicare_hmo5==1 & partb_stat6==1
replace ma6=0 if (medicare_stat6==1|partb_stat6==1)&ma6!=1

gen ma7=1 if medicare_hmo6==1 & partb_stat7==1
replace ma7=0 if (medicare_stat7==1|partb_stat7==1)&ma7!=1

gen ma8=1 if medicare_hmo7==1 & partb_stat8==1
replace ma8=0 if (medicare_stat8==1|partb_stat8==1)&ma8!=1

gen ma9=1 if medicare_hmo8==1 & partb_stat9==1
replace ma9=0 if (medicare_stat9==1|partb_stat9==1)&ma9!=1

gen ma10=1 if medicare_hmo9==1 & partb_stat10==1
replace ma10=0 if (medicare_stat10==1|partb_stat10==1)&ma10!=1

gen ma11=1 if medicare_hmo10==1 & partb_stat11==1
replace ma11=0 if (medicare_stat11==1|partb_stat11==1)&ma11!=1

gen ma12=1 if medicare_hmo11==1 & partb_stat12==1
replace ma12=0 if (medicare_stat12==1|partb_stat12==1)&ma12!=1


drop hhhid hhid
*** ------------------------------------------	
*** RESHAPE FROM WIDE FORMAT TO LONG FORMAT
#d;
	reshape long
	cenreg mstat wtresp wtcrnh agey_e agem_e iwstat iwbeg iwendy/*momliv dadliv iwdelta*/ inw
	smokev smoken bmi shlt
	cancre hearte heartf hibpe diabe lunge stroke alzhe demen
	adla iadla  nrshom nhmliv hosp homcar dress bath eat money phone bed toilt walkr meds shop meals
	/*retirecomm retirecomm_continue key_serv other_serv serv key_serv_use other_serv_use serv_use*/
	oopmd doctim hsptim hspnit
        isret issdi isdi issi iearn ipena iunwc igxfr 
	sayret lbrf work
	govmd govmr higov covr covs hiothp covrt hiltc lifein weightnh
	hhhid
        hcpl
	hicap hiothr hitot 
	hatoth hanethb 
	hatotf hastck hachck hacd habond haothr
	harles hatran habsns haira 
	hatota hatotb hatotn
	hamort hahmln hamrtb hadebt ahous afhous
        /*hanyproptxa hanyproptxb hproptxa hproptxb*/
	shhidpn siwstat sagey_e sagem_e swtresp sgender smstat sracem shispan seduc /*smalive sfalive smlivage sflivage smmarried sfmarried smliv10mi sfliv10mi
	dbclaim ssclaim diclaim
	htcany htcamt hchild helperct helphoursyr helphoursyr_sp helphoursyr_nonsp volhours nkids gkcarehrs kid_byravg kid_mnage nkid_liv10mi
	isemp iosemp ioss iosdi hiossi
	parhelphours paralive parnotmar par10mi malive falive mlivage flivage mmarried fmarried mliv10mi fliv10mi
	jlocc jlocca jlind*/  jcocc
	memrye wthh
        flone psyche arthre
        bathh dressh walkrh
	imrc dlrc
	cesd cesdm proxy peninc jcpen
	jcten
	medicare_hmo medicare_stat partb_stat medicare_mo ma
	,
	
	i(hhidpn rahrsamp racohbyr hacohort ragender raracem raeduc rahispan rabyear rabmonth ) j(wave);
#d cr

*** RENAME hhhid as hhid, for convenience; RENAME wtresp as weight; panel data setting
	ren hhhid hhid
	ren wtresp weight
	tsset hhidpn wave

*** FOR WAVE 7, IF NOT MOVE, THEN USE THE PERVIOUS WAVE'S INFO
	sort hhidpn wave, stable
	by hhidpn: replace cenreg = cenreg[_n-1] if cenreg == . & iwstat == 1 & wave == 7
	
*** Died 
recode iwstat (0 6 7 9 = .) (1 4 = 0) (2 3 5 = 1), gen (died) 
label var died "whether died or not in this wave"

*** Age
rename rabmonth rbmonth
gen age_iwe = agem_e / 12
label var age_iwe "exact age at the end of interview"
gen age_yrs = int((wave-1)*2 + 1992 - rabyear + (7-rbmonth)/12)
label var age_yrs "Age in years at July 1st"
gen age = (wave-1)*2 + 1992 - rabyear + (7-rbmonth)/12
label var age "Exact Age at July 1st"
tab jcocc
sort hhidpn wave
save $input/randhrs_clean,replace
log close 
clear all
exit,STATA
