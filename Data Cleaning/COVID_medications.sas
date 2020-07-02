


libname cov " \\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data"; 

/**MEDICATIONS */

proc contents data=cov.tr_medications; run; /*CODE, VALUE */
proc print data=cov.tr_medications (obs=20); run; 


/********************************************************/
/***********************TRAINING ************************/
/********************************************************/

data cohort_0; set cov.tr_patients(keep=id rename=(id=patient)); run;
proc sort data=cohort_0; by patient; run;

proc sort data=cov.tr_medications; by patient; run; 

data cohort_2 (keep=patient start code_c rename=(code_c=code)) ; 
length code_c $12;
set cov.tr_medications (in=B); 

code_c = catt("MED_", code); 
run; 

proc sql;
	select count(distinct patient),count(*) from _last_;
quit; /**65814**/
proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 

proc sql; 
	create table med_code as 
	select code, count(code) as count
	from cohort_2 
	group by code
	order by calculated count desc; quit; 
proc sql ; 
	select distinct code into: class separated by " "
	from cohort_2 
	order by code;
	quit; 

%put &class;

/** 2020 **/
data cohort_2020; set cohort_3; 
if year(start)=2020; run;  /*2020 data is not in test data */
/**/
/*data cohort_2020_1(drop=i code start);*/
/*	merge cohort_0 (in=A) cohort_2020;*/
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
/*	proc sort data=cohort_2020_1; by patient; */
/*/*	proc sort data=x; by patient; run; */*/
/**/
/*proc transpose data=cohort_2020_1 out=varnames; */
/*var _all_; run; */
/**/
/*proc sql; */
/*select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2020'))) into:rename separated by ' ' */
/*from varnames; quit; */
/**/
/*%put NOTE: &=rename;*/
/*proc datasets; */
/*	modify cohort_2020_1; */
/*	rename &rename; run;

/** 2019 ***/
data cohort_2019; set cohort_3; 
if year(start)=2019; run; 

data cohort_2019_1(drop=i code start);
	merge cohort_0 (in=A) cohort_2019;
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

proc transpose data=cohort_2019_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2019'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify cohort_2019_1; 
	rename &rename; run; 


/** 2018 ***/
data cohort_2018; set cohort_3; 
if year(start) in (2015, 2016, 2017, 2018); run; 

data cohort_2018_1(drop=i code start);
	merge cohort_0 (in=A) cohort_2018;
	by patient;
	format &class 1.;
	retain &class;
	array classes(*) &class;
	if A; 

	if first.patient then do i=1 to dim(classes);
		classes(i)=0;
	end;
	do i=1 to dim(classes);
		if code=scan("&class", i) then classes(i)=1;
	end;
	if last.patient then output; 
run; 

proc transpose data=cohort_2018_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2018'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify cohort_2018_1; 
	rename &rename; run; 


/**** FINAL DATA, medication ***/
libname data "\\vhasfcreap\sun\COVID project\data\cleaned_0623"; 

data data.SJ_medications_train; 
merge cohort_2018_1 (rename = (PATIENT_2018=PATIENT))
	  cohort_2019_1 (rename = (PATIENT_2019=PATIENT))
/*	  cohort_2020_1 (rename = (PATIENT_2020=PATIENT))*/
	  ; 
by PATIENT; 
run; 




/********************************************************/
/***********************TESTING**************************/
/********************************************************/

proc sort data=cov.tt_medications; by patient; run; 


data cohort_0 ; set clean.sg_patients_test (keep=patient); run;
proc sort data=cohort_0; by patient; run;

data cohort_2 (keep=patient start code_c rename=(code_c=code)) ; 
length code_c $12;
set cov.tt_medications ; 

code_c = catt("MED_", code); 
run; 
/**/
/*proc sql;*/
/*	select count(distinct patient),count(*) from _last_;*/
/*quit; /**65814**/

proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 

proc sql; 
	create table med_code as 
	select code, count(code) as count
	from cohort_2 
	group by code
	order by calculated count desc; quit; 
proc sql ; 
	select distinct code into: class separated by " "
	from cohort_2 
	order by code;
	quit; 

%put &class;

/** 2020 **/
data cohort_2020; set cohort_3;  /*no 2020 data in the test data **/
if year(start)=2020; run; 
/**/
/*data cohort_2020_1(drop=i code start);*/
/*	merge cohort_3 (in=A) cohort_2020;*/
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
/*	proc sort data=cohort_2020_1; by patient; */
/**/
/*proc transpose data=cohort_2020_1 out=varnames; */
/*var _all_; run; */
/**/
/*proc sql; */
/*select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2020'))) into:rename separated by ' ' */
/*from varnames; quit; */
/**/
/*%put NOTE: &=rename;*/
/*proc datasets; */
/*	modify cohort_2020_1; */
/*	rename &rename; run; */


/** 2019 ***/
data cohort_2019; set cohort_3; 
if year(start)=2019; run; 

data cohort_2019_1(drop=i code start);
	merge cohort_0 (in=A) cohort_2019;
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

proc transpose data=cohort_2019_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2019'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify cohort_2019_1; 
	rename &rename; run; 


/** 2018 ***/
data cohort_2018; set cohort_3; 
if year(start) in (2015, 2016, 2017, 2018); run; 

data cohort_2018_1(drop=i code start);
	merge cohort_0 (in=A) cohort_2018;
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

proc transpose data=cohort_2018_1 (obs=0) out=varnames; 
var _all_; run; 

proc sql; 
select catx('=',nliteral(_name_),nliteral(cats(_name_, '_2018'))) into:rename separated by ' ' 
from varnames; quit; 

%put NOTE: &=rename;
proc datasets; 
	modify cohort_2018_1; 
	rename &rename; run; 


/**** FINAL DATA, medication ***/
libname data "\\vhasfcreap\sun\COVID project\data\cleaned_0623"; 

data data.SJ_medications_test; 
merge cohort_2018_1 (rename = (PATIENT_2018=PATIENT))
	  cohort_2019_1 (rename = (PATIENT_2019=PATIENT))
/*	  cohort_2020_1 (rename = (PATIENT_2020=PATIENT))*/
	  ; 
by PATIENT; 
run; 

