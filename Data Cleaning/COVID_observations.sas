
libname cov " \\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data"; 


proc contents data=cov.Tr_observations; run; /*CODE, VALUE */
proc print data=cov.tr_observations (obs=10); run;

proc sort data=cov.Tr_allergies; by patient; run; 



/********************************************************/
/***********************TRAINING ************************/
/********************************************************/


data cohort_0; set cov.tr_patients(keep=id rename=(id=patient)); run;
proc sort data=cohort_0; by patient; run;


data cohort_2 (keep=patient date code_c description value rename=(code_c=code)) ; 
length code_c $12;
set cov.Tr_observations ; 

code_c = catt("obs_", code); 

run;
proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 

data cohort_3a; set cohort_3; 
code = tranwrd(code, "-", "_"); 
run; 


proc sql; 
	create table code_xwalk as
	select distinct code, description
	from cohort_2 ;
	run; 

proc sql;
	create table obs_count1 as 
	select code, count(distinct patient) as count 
	from cohort_2
	group by code
	order by calculated count desc;
quit;

proc sql; 
	create table freq_table as
	select * 
	from obs_count1 A left join code_xwalk B
	on A.code=B.code
	order by count desc;
	quit; 


data cohort_vital0 (drop=value rename=(value_n=value)); set cohort_3a;
if code in ("obs_QALY", "obs_DALY", "obs_QOLS", "obs_2708_6", "obs_8462_4") 
  |  code in ( "obs_2708_6", "obs_8310_5", "obs_8310_5",  "obs_8480_6")  
  |  code in ("obs_29463_7", "obs_8867_4", "obs_72514_3", "obs_8302_2", "obs_39156_5", "obs_72166_2")
; 

if code = "obs_72166_2" and VALUE = "Never smoker" then value = 0; 
if code = "obs_72166_2" and VALUE = "Former smoker" then value = 1; 
if code = "obs_72166_2" and VALUE = "Current every day smo" then value = 2; 

value_n = value*1; 

run; 

proc sort data=cohort_vital0; by patient code date; run; 
data cohort_vital1; set cohort_vital0; 
by patient code; 
if last.code; 
run;  

proc sql; 
	select distinct code into: class separated by " " 
	from cohort_vital1
	order by code; 
	quit; 
/*proc print data=cohort_vital1(obs=500); run;*/

%put &class;

/*proc print data=cohort_vital_2 (obs=5); run; */

data cohort_vital_2 (drop=i  obs_39156_5);
	merge cohort_0 (in=A ) cohort_vital1;
	by patient;
	if A; 

	format &class Best8.;
	retain &class;
	array classes(*) &class;

	if first.patient then do i=1 to dim(classes);
		classes(i)=99;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=value;
	end;

	if 0<obs_39156_5<25 then obs_39156_5_cat=0; 
		else if 25<=obs_39156_5<30 then obs_39156_5_cat=1; 
		else if 30<=obs_39156_5<99 then obs_39156_5_cat=2;
		else if obs_39156_5=99 then obs_39156_5_cat=99; 

	if last.patient then output; 
run; 

proc print data=cohort_vital_2 (obs=200); run;

proc freq data=cohort_vital_2; tables OBS_39156_5_cat/missing; run;
proc freq data=cohort_vital_2; tables obs_72166_2; run; 
proc freq data=cohort_vital_2; tables obs_72514_3; run; 



/*** LAB ****/

proc contents data=cohort_3a; run;


data cohort_lab0 (drop=value description); set cohort_3a;
if code not in ("obs_QALY", "obs_DALY", "obs_QOLS", "obs_2708_6", "obs_8462_4") 
  &  code not in ( "obs_2708_6", "obs_8310_5", "obs_8310_5",  "obs_8480_6")  
  &  code not in ("obs_29463_7", "obs_8867_4", "obs_72514_3", "obs_8302_2", "obs_39156_5", "obs_72166_2")
; 
run; 

proc sql ; 
	select distinct code into: class separated by " "
	from cohort_lab0
	order by code;
	quit; 

%put &class;

proc print data=cohort_lab0 (obs=10); run;


/** 2020 */
data lab_2020; set cohort_lab0; 
if year(date)=2020; run;
/**/
/*/*proc contents data=cohort_lab0; run;*/*/
/*proc sort data=lab_2020; by patient; run;*/
/**/
/**/
/**/
/*data lab_2020_1 (drop=i code date);*/
/*	merge cohort_3 (in=A) lab_2020;*/
/*	by patient;*/
/*	format &class 1.;*/
/*	retain &class;*/
/*	array classes(*) &class;*/
/*	if A; */
/*	if first.patient then do i=1 to dim(classes);*/
/*		classes(i)=0;*/
/*	end;*/
/*	do i=1 to dim(classes);*/
/*		if code=scan("&class", i) then classes(i)=1;*/
/*	end;*/
/*	if last.patient then output; */
/*run; */
/**/
/*proc transpose data=lab_2020_1 (obs=0) out=varnames; */
/*var _all_; run; */
/**/
/*proc sql; */
/*select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2020'))) into:rename separated by ' ' */
/*from varnames; quit; */
/**/
/*%put NOTE: &=rename;*/
/*proc datasets; */
/*	modify lab_2020_1; */
/*	rename &rename; run; 


/** 2019 ***/
data lab_2019; set cohort_lab0; 
if year(date)=2019; run; 

proc sort data=cohort_0; by patient; 
proc sort data=lab_2019; by patient; run;

data lab_2019_1 (drop=i code date);
	merge cohort_0 (in=A) lab_2019;
	by patient;
	if A; 

	format &class 1.;
	retain &class;
	array classes(*) &class;

	if first.patient then do i=1 to dim(classes);
		classes(i)=0;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=1;
	end;
	if last.patient then output; 
run; 


proc transpose data=lab_2019_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2019'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify lab_2019_1; 
	rename &rename; run; 


/** 2018 ***/
data lab_2018; set cohort_lab0; 
if year(date)=2018; run; 

proc sort data=cohort_0; by patient; 
proc sort data=lab_2018; by patient; run;

data lab_2018_1 (drop=i code date);
	merge cohort_0 (in=A) lab_2018;
	by patient;
	if A; 

	format &class 1.;
	retain &class;
	array classes(*) &class;

	if first.patient then do i=1 to dim(classes);
		classes(i)=0;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=1;
	end;
	if last.patient then output; 
run; 


proc transpose data=lab_2018_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2018'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify lab_2018_1; 
	rename &rename; run; 


/** merge **/
data data.SJ_observations_train; 
merge cohort_vital_2 (drop=code date description value)
	  lab_2018_1 (rename=(patient_2018=patient)) 
	  lab_2019_1 (rename=(patient_2019=patient)) 
	  ; 
by patient; 
run; 



/********************************************************/
/***********************TESTING**************************/
/********************************************************/

libname clean "\\vhasfcreap\bocheng2\Covid19_challenge\Data_cleaned2"; 

data cohort_0 ; set clean.sg_patients_test (keep=patient); run;
proc sort data=cohort_0; by patient; run;

data cohort_2 (keep=patient date code_c description value rename=(code_c=code)) ; 
length code_c $12;
set cov.Tt_observations; 

code_c = catt("obs_", code); 

run; 
proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 

data cohort_3a; set cohort_3; 
code = tranwrd(code, "-", "_"); 
run; 


proc sql; 
	create table code_xwalk as
	select distinct code, description
	from cohort_2 ;
	run; 

proc sql;
	create table obs_count1 as 
	select code, count(distinct patient) as count 
	from cohort_2
	group by code
	order by calculated count desc;
quit;

proc sql; 
	create table freq_table as
	select * 
	from obs_count1 A left join code_xwalk B
	on A.code=B.code
	order by count desc;
	quit; 

proc contents data=cohort_3a; run;

proc freq data=cohort_3a; tables value; where code="obs_72166_2"; run;

data cohort_vital0 (drop=value rename=(value_n=value)); 
set cohort_3a;

if code in ("obs_QALY", "obs_DALY", "obs_QOLS", "obs_2708_6", "obs_8462_4") 
  |  code in ( "obs_2708_6", "obs_8310_5", "obs_8310_5",  "obs_8480_6")  
  |  code in ("obs_29463_7", "obs_8867_4", "obs_72514_3", "obs_8302_2", "obs_39156_5", "obs_72166_2")
; 

if code = "obs_72166_2" and VALUE = "Never smoker" then value = 0; 
if code = "obs_72166_2" and VALUE = "Former smoke" then value = 1; 
if code = "obs_72166_2" and VALUE = "Current ever" then value = 2; 

value_n = value*1; 

run; 

proc sort data=cohort_vital0; by patient code date; run; 
data cohort_vital1; set cohort_vital0; 
by patient code; 
if last.code; 
run;  

proc sql; 
	select distinct code into: class separated by " " 
	from cohort_vital1
	order by code; 
	quit; 
/*proc print data=cohort_vital1(obs=500); run;*/

%put &class;
 
proc print data=cohort_vital_2 (obs=5); run; 

data cohort_vital_2 (drop=i  obs_39156_5 code date description value);
	merge cohort_0 (in=A ) cohort_vital1;
	by patient;
	format &class Best8.;
	retain &class;
	array classes(*) &class;
	if A; 
	if first.patient then do i=1 to dim(classes);
		classes(i)=99;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=value;
	end;

	if 0<obs_39156_5<25 then obs_39156_5_cat=0; 
		else if 25<=obs_39156_5<30 then obs_39156_5_cat=1; 
		else if 30<=obs_39156_5<99 then obs_39156_5_cat=2;
		else if obs_39156_5=99 then obs_39156_5_cat=99; 

	if last.patient then output; 
run; 
/**/
/*proc print data=cohort_vital_2 (obs=200); run;*/
/**/
/*proc freq data=cohort_vital_2; tables OBS_39156_5_cat/missing; run;*/
/*proc freq data=cohort_vital_2; tables obs_72166_2; run; */
/*proc freq data=cohort_vital_2; tables obs_72514_3; run; */
/**/


/*** LAB ****/

proc contents data=cohort_3a; run;


data cohort_lab0 (drop=value description); set cohort_3a;
if code not in ("obs_QALY", "obs_DALY", "obs_QOLS", "obs_2708_6", "obs_8462_4") 
  &  code not in ( "obs_2708_6", "obs_8310_5", "obs_8310_5",  "obs_8480_6")  
  &  code not in ("obs_29463_7", "obs_8867_4", "obs_72514_3", "obs_8302_2", "obs_39156_5", "obs_72166_2")
; 
run; 

proc sql ; 
	select distinct code into: class separated by " "
	from cohort_lab0
	order by code;
	quit; 

%put &class;

proc print data=cohort_lab0 (obs=10); run;


/** 2020 */
data lab_2020; set cohort_lab0; 
if year(date)=2020; run; /*LAB does not have 2020 data in test data */
/**/
/*/*proc contents data=cohort_lab0; run;*/*/
/*proc sort data=lab_2020; by patient; run;*/
/**/
/*data lab_2020_1 (drop=i code date);*/
/*	merge cohort_3 (in=A) lab_2020;*/
/*	by patient;*/
/*	format &class 1.;*/
/*	retain &class;*/
/*	array classes(*) &class;*/
/*	if A; */
/*	if first.patient then do i=1 to dim(classes);*/
/*		classes(i)=0;*/
/*	end;*/
/*	do i=1 to dim(classes);*/
/*		if code=scan("&class", i) then classes(i)=1;*/
/*	end;*/
/*	if last.patient then output; */
/*run; */
/**/
/*proc transpose data=lab_2020_1 (obs=0) out=varnames; */
/*var _all_; run; */
/**/
/*proc sql; */
/*select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2020'))) into:rename separated by ' ' */
/*from varnames; quit; */
/**/
/*%put NOTE: &=rename;*/
/*proc datasets; */
/*	modify lab_2020_1; */
/*	rename &rename; run; 

/** 2019 ***/
data lab_2019; set cohort_lab0; 
if year(date)=2019; run; 

proc sort data=cohort_0; by patient; 
proc sort data=lab_2019; by patient; run;

data lab_2019_1 (drop=i code date);
	merge cohort_0 (in=A) lab_2019;
	by patient;
	if A; 

	format &class 1.;
	retain &class;
	array classes(*) &class;
	
	if first.patient then do i=1 to dim(classes);
		classes(i)=0;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=1;
	end;
	if last.patient then output; 
run; 

proc transpose data=lab_2019_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2019'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify lab_2019_1; 
	rename &rename; run; 


/** 2019 ***/
data lab_2018; set cohort_lab0; 
if year(date)=2018; run; 

proc sort data=cohort_0; by patient; 
proc sort data=lab_2018; by patient; run;

data lab_2018_1 (drop=i code date);
	merge cohort_0 (in=A) lab_2018;
	by patient;
	if A; 

	format &class 1.;
	retain &class;
	array classes(*) &class;
	
	if first.patient then do i=1 to dim(classes);
		classes(i)=0;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=1;
	end;
	if last.patient then output; 
run; 

proc transpose data=lab_2018_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2018'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify lab_2018_1; 
	rename &rename; run; 


/**** FINAL DATA, medication ***/
libname data "\\vhasfcreap\sun\COVID project\data\cleaned_0623"; 

data data.SJ_observations_test; 
merge cohort_vital_2  
	  lab_2018_1 (rename=(patient_2018=patient))
	  lab_2019_1 (rename=(patient_2019=patient)) ; 
by patient; 
run; 


proc contents data=data.Sj_allergies_train; run;
proc contents data=data.Sj_allergies_test; run;


proc contents data=data.Sj_immunizations_train; run;
proc contents data=data.Sj_immunizations_test; run;


proc contents data=data.Sj_medications_train; run;
proc contents data=data.Sj_medications_test; run;

proc contents data=data.Sj_observations_train; run;
proc contents data=data.Sj_observations_test; run;
