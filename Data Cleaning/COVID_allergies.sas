
libname cov " \\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data"; 




/**ALLERGIES :: Allergies data does contain date, but it goes all the way back to 30s. I would not stratify the data by 2015-2018, 2019, and 2000 because
there are so few obs during those 5 years. Without stratifying it by year, I will just look at whether a patiet "ever had" a certain type of allergie */

/** TRAINING **/
proc contents data=cov.Tr_allergies; run; /*CODE, VALUE */
proc sort data=cov.Tr_allergies; by patient; run; 

data cohort_0; set cov.tr_patients(keep=id rename=(id=patient)); run;
proc sort data=cohort_0; by patient; run;
proc sql; select count(patient), count(distinct patient) from cohort_0; quit; 


data cohort_2 (keep=patient code_c rename=(code_c=code)) ; 
set cov.Tr_allergies; 
code_c = catt("allergies_", code); 
run; 

proc sql; 
	create table allergies_code as 
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

proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 
data allergies (drop=code); 
merge cohort_0 (in=A) cohort_3; 
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
	drop i; 
run; 


/**** FINAL DATA, medication ***/
libname data "\\vhasfcreap\sun\COVID project\data\cleaned_0623"; 
data data.SJ_allergies_train; set allergies; run; 





/** TESTING **/

proc contents data=cov.Tt_allergies; run; /*CODE, VALUE */

proc sort data=cov.Tt_allergies; by patient; run; 
data cohort_0 ; set clean.sg_patients_test (keep=patient); run;

proc sort data=cohort_0; by patient; run;
proc sql; select count(patient), count(distinct patient) from cohort_0; quit; 
proc sql; select count(patient), count(distinct patient) from clean.sg_patients_test; quit; 

data cohort_2 (keep=patient code_c rename=(code_c=code)) ; 
set cov.Tt_allergies; 
code_c = catt("allergies_", code); 
run; 

proc sql; 
	create table allergies_code as 
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

proc sort data=cohort_2 nodup out=cohort_3; by patient code; run; 

data allergies (drop=code); 
merge cohort_0 (in=A) cohort_3; 
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
	drop i; 
run; 

data data.SJ_allergies_test; set allergies; run; 


