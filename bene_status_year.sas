/* bene_status_year.sas
   make a file of beneficiary status by year
   Flags for AB enrollment, HMO status, dual eligibility,
     whether died this year, Part D plan,
     LIS status, RDS status, consistent with bene_status_month file
   Keep flags on whether enrolled AB all year, HMO all yr, FFS allyr,
     whether creditable coverage. Also whether rds/dual/lis all year.
   Also keep gender, birthdate, deathdate, age at beg of year and July 1st.
   
   SAMPLE: all benes on denominator or bsf, no duplicates,
           and did not die in a prior year according to the death date.
   Level of observation: bene_id, year
   
   Input files: denall[yyyy] or bsfall[yyyy]
   Output files: bene_status_year[yyyy]
*/

options ls=150 ps=58 nocenter compress=yes replace;

%include "sascontents.mac";
%include "listvars.mac";
%include "renvars.mac";
%include "statyr.mac";  /* macro to get bene_status_year vars across years */

%partABlib(types=bsf);
libname bene "&datalib.&clean_data.BeneStatus";

%let contentsdir=&doclib.&clean_data.Contents/BeneStatus/;


%statyr(2002,2005,hmo_mo=hmo_mo,hmoind=hmoind,hmonm=0,stbuy=buyin,stbuymo=buyin_mo,denbsf=bsfab,denlib=bsf,demogyr=2013)
%statyr(2006,2013,hmo_mo=hmo_mo,hmoind=hmoind,hmonm=0,stbuy=buyin,stbuymo=buyin_mo,denbsf=bsfall,denlib=bene,demogyr=2013);

