/*Purpose: This is the program to explore all the training and testing datasets for the PrecisionFDA Covid19 Modeling challenging
  Deadline: 2020/06/02 - 2020/07/03
  Author: Bocheng Jing
  Date: 2020/06/05



*/



libname data "F:\User SAS Storage\Bocheng\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data";
libname dataup  "\\vhasfcreap\Bocheng2\Covid19_challenge\Data_cleaned";


/*1. Explore the training datasets*/

** Import all the files;


%macro imp(infile);
PROC IMPORT OUT=data.tr_&infile datafile = "F:\User SAS Storage\Bocheng\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data\Training_datasets\&infile..csv"
DBMS=csv REPLACE;
GETNAMES=YES;

run;
%mend;

%imp(allergies)
%imp(careplans)
%imp(conditions)
%imp(devices)
%imp(encounters)
%imp(imaging_studies)
%imp(immunizations)
%imp(medications)
%imp(observations)
%imp(organizations)
%imp(patients)
%imp(payer_transitions)
%imp(payers)
%imp(procedures)
%imp(providers)
%imp(supplies)

proc contents data=data.TR_patients;run;

proc sql;
	select count(distinct id), count(*) from data.TR_patients;
quit; **117,959//117,959;

proc sql;
	select count(distinct patient), count(*) from data.TR_allergies;
quit; **10903//29412;

proc sql;
	select count(distinct patient), count(*) from data.TR_careplans;
quit; **114977//489745;

proc sql;
	select count(distinct patient), count(*) from data.TR_conditions;
quit;  **117626//1362601;

proc sql;
	select count(distinct patient), count(*) from data.TR_devices;
quit; **11473//33496;

proc sql;
	select count(distinct patient), count(*) from data.TR_encounters;
quit;  **117821//6023703;

proc sql;
	select count(distinct patient), count(*) from data.TR_IMAGING_STUDIES;
quit;  **13748//57345;

proc sql;
	select count(distinct patient), count(*) from data.TR_IMMUNIZATIONS;
quit; **101001//131924;

proc sql;
	select count(distinct patient), count(*) from data.TR_MEDICATIONS;
quit; **107365//9670543;

proc sql;
	select count(distinct patient), count(*) from data.TR_OBSERVATIONS;
quit;**117959//20656425;

proc sql;
	select count(distinct patient), count(*) from data.TR_PROCEDURES;
quit;**111735//1298614;

proc sql;
	select count(distinct patient), count(*) from data.TR_SUPPLIES;
quit; **20424//1576868;

proc sql;
	select count(distinct ID), count(*) from data.TR_ORGANIZATIONS;
quit; **9218//9218;

proc sql;
	select count(distinct patient), count(*) from data.TR_PAYER_TRANSITIONS;
quit; **117165//496312;

proc sql;
	select count(distinct ID), count(*) from data.TR_Payers;
quit; **10 suppliers;

proc sql;
	select count(distinct ID), count(*) from data.TR_Providers;
quit; **60968//60968;

/*2. Loading the testing dataset*/

%macro imptt(infile);
PROC IMPORT OUT=data.tt_&infile datafile = "\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data\Testing_datasets\&infile..csv"
DBMS=csv REPLACE;
GETNAMES=YES;

run;
%mend;

%imptt(allergies)
%imptt(careplans)
%imptt(conditions)
%imptt(devices)
%imptt(encounters)
%imptt(imaging_studies)
%imptt(immunizations)
%imptt(medications)
%imptt(observations)
%imptt(organizations)
%imptt(patients)
%imptt(payer_transitions)
%imptt(payers)
%imptt(procedures)
%imptt(providers)
%imptt(supplies)

proc sql;
	select count(distinct id), count(*) from data.TT_patients;
quit; **8013//29492;

proc sql;
	select count(distinct patient), count(*) from data.TT_allergies;
quit; **2826//7892;

proc sql;
	select count(distinct patient), count(*) from data.TT_careplans;
quit; **26993//88048;

proc sql;
	select count(distinct patient), count(*) from data.TT_conditions;
quit;  **28671//192568;

proc sql;
	select count(distinct patient), count(*) from data.TT_devices;
quit; **28671//129568;

proc sql;
	select count(distinct patient), count(*) from data.TT_encounters;
quit;  **29129//1425205;

proc sql;
	select count(distinct patient), count(*) from data.TT_IMAGING_STUDIES;
quit;  **13748//57345;

proc sql;
	select count(distinct patient), count(*) from data.TT_IMMUNIZATIONS;
quit; **18834/23847;

proc sql;
	select count(distinct patient), count(*) from data.TT_MEDICATIONS;
quit; **26310//2328570;

proc sql;
	select count(distinct patient), count(*) from data.TT_OBSERVATIONS;
quit;**29466//1413790;

proc sql;
	select count(distinct patient), count(*) from data.TT_PROCEDURES;
quit;**18423//1298614;

proc sql;
	select count(distinct patient), count(*) from data.TT_SUPPLIES;
quit; **doesn't have any data;

proc sql;
	select count(distinct ID), count(*) from data.TT_ORGANIZATIONS;
quit; **9218//9218;

proc sql;
	select count(distinct patient), count(*) from data.TT_PAYER_TRANSITIONS;
quit; **29262//123329;

proc sql;
	select count(distinct ID), count(*) from data.TT_Payers;
quit; **10 suppliers;

proc sql;
	select count(distinct ID), count(*) from data.TT_Providers;
quit; **60968//60968;


/**********************************************************************************************************************/
/*************************************************3. Merge data together***********************************************/
/*---------------------------------------------------------------------------------------------------------------------*/

PROC IMPORT OUT=data.tt_patient_update datafile = "\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Data\Testing_datasets\patients.csv"
DBMS=csv REPLACE;
GETNAMES=YES;

run;


data TT_patient1;
	set data.TT_patients;
	where id is not null;
run;

proc sql;
	select count(distinct id), count(*) from _last_;
quit; **8013//8013;

proc sql;
	create table data.full_patients as 
	select *, 1 as tr_tt_flag from data.TR_patients	
		union
	select *, 0 as tr_tt_flag from TT_patient1;
quit;

proc sql;
	select count(distinct id), count(*) from _last_;
quit; **125972//125972;

%macro cat(infile);

data data.full_&infile;
	set data.TR_&infile data.TT_&infile;
run;
%mend;
	
%cat(allergies)
%cat(careplans)
%cat(conditions)
%cat(devices)
%cat(encounters)
%cat(imaging_studies)
%cat(immunizations)
%cat(medications)
%cat(observations)
%cat(organizations)
%cat(payer_transitions)
%cat(payers)
%cat(procedures)
%cat(providers)
%cat(supplies)

/**************************************************************************************************************************************/
/************************************************4. Cohort generation *****************************************************************/
/*--------------------------------------------------------------------------------------------------------------------------------------*/


proc sql;
	create table data.tr_cohort as 
	select A.*, B.*
	from data.tr_patients A inner join data.tr_observations B on A.id=B.patient
	where CODE="94531-1" and value="Detected (qualifier v";
quit;

proc sql;
	select count(distinct id), count(*) from _last_;
quit; **73967//73967;

proc freq data=data.tr_cohort;table date;run;


proc sql;
	create table covid19_test as 
	select *
	from data.tr_observations 
	where CODE="94531-1" ;
quit;

proc freq data=covid19_test;table date;run;


/******************************************************************************************************************************************/
/****5.Check out the data: suppliers, device and imaging studies ***************************************************************************/
/*-----------------------------------------------------------------------------------------------------------------------------------------*/

** Imaging studies;
proc sql;
	create table tr_cohort_image as 
	select A.id, A.id as patient, B.*
	from data.tr_patients A inner join data.tr_imaging_studies B on A.id=B.patient
	where '01Jan2019'd<=B.date<='30Jun2020'd;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **3525//6228;

proc freq data=tr_cohort_image;table bodysite_description modality_description sop_description;run;



data tr_cohort_image1(keep=patient image_type image_body);
	set tr_cohort_image;
	if SOP_description="CT Image Storage" then image_type=1;
	if SOP_description in ("Digital X-Ray Image Storage","Digital X-Ray Image Storage – for Presentation") then image_type=2;
	if SOP_description in ("Ultrasound Image Storage", "Ultrasound Multiframe Image Storage") then image_type=3;

	if BODYSITE_DESCRIPTION='Ankle' then image_body=1;
	if BODYSITE_DESCRIPTION='Arm' then image_body=2;
	if BODYSITE_DESCRIPTION='Chest' then image_body=3;
	if BODYSITE_DESCRIPTION='Clavicle' then image_body=4;
	if BODYSITE_DESCRIPTION='Knee' then image_body=5;
	if BODYSITE_DESCRIPTION='Pelvis' then image_body=6;
	if BODYSITE_DESCRIPTION='Structure of right upper quadrant o' then image_body=7;
	if BODYSITE_DESCRIPTION in ('Thoracic','Thoracic structure','Thoracic structure (body structure)','thoracic') then image_body=8;
	if BODYSITE_DESCRIPTION='Wrist' then image_body=9;


	label image_type= "1=CT 2=X-ray 3=Ultrasound";
	label image_body="1=Ankle 2=Arm 3=Chest 4=Clavicle 5=Knee 6=Pelvis 7=quadrant 8=Thoracic 9=Wrist";
run;

proc freq data=tr_cohort_image1;table image_type image_body;run;

data tr_cohort_image2;
	set tr_cohort_image1;
	if image_type=1 then image_type1=1;else image_type1=0;
	if image_type=2 then image_type2=1;else image_type2=0;
	if image_type=3 then image_type3=1;else image_type3=0;
	
	if image_body=1 then image_body1=1;else image_body1=0;
	if image_body=2 then image_body2=1;else image_body2=0;
	if image_body=3 then image_body3=1;else image_body3=0;
	if image_body=4 then image_body4=1;else image_body4=0;
	if image_body=5 then image_body5=1;else image_body5=0;
	if image_body=6 then image_body6=1;else image_body6=0;
	if image_body=7 then image_body7=1;else image_body7=0;
	if image_body=8 then image_body8=1;else image_body8=0;
	if image_body=9 then image_body9=1;else image_body9=0;
run;

proc sql;
	create table tr_cohort_image3 as 
	select patient, max(image_type1) as image_type1,max(image_type2) as image_type2,max(image_type3) as image_type3,
					max(image_body1) as image_body1,max(image_body2) as image_body2,max(image_body3) as image_body3,
					max(image_body4) as image_body4,max(image_body5) as image_body5,max(image_body6) as image_body6,
					max(image_body7) as image_body7,max(image_body8) as image_body8,max(image_body9) as image_body9
	from tr_cohort_image2
	group by patient;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **3525//3525;


**Device;

proc sql;
	create table tr_cohort_device1 as 
	select A.id, A.id as patient, B.*
	from data.tr_patients A inner join data.tr_devices B on A.id=B.patient 
	where '01Jan2019'd<=B.start<='30Jun2020'd;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **4647//22942;

proc freq data=tr_cohort_device1;table DESCRIPTION;run;

data tr_cohort_device2;
	set tr_cohort_device1;
	if description="Coronary artery stent (physical object)" then device=1;
	if DESCRIPTION="Hemodialysis machine  device (physical object)" then device=2;
	if description="Implantable cardiac pacemaker (physical object)" then device=3;
	if description="Implantable defibrillator  device (physical object)" then device=4;
	if description="Mechanical ventilator (physical object)" then device=5;
	if description="Videolaryngoscope (physical object)" then device=6;

	if device=1 then device1=1;else device1=0;	
	if device=2 then device2=1;else device2=0;
	if device=3 then device3=1;else device3=0;
	if device=4 then device4=1;else device4=0;
	if device=5 then device5=1;else device5=0;
	if device=6 then device6=1;else device6=0;

run;

proc freq data=tr_cohort_device2;table device;run;


proc sql;
	create table tr_cohort_device3 as 
	select distinct patient, max(device1) as device1, max(device2) as device2,max(device3) as device3,max(device4) as device4,
					max(device5) as device5,max(device6) as device6
	from tr_cohort_device2
	group by patient;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **4647//4647;

libname data1 '\\vhasfcreap\Bocheng2\Covid19_challenge\Data_cleaned2';

proc sql;
	create table tr_cohort as 
	select distinct id as patient 
	from data.tr_patients
	order by id;
quit;

data data1.bj_imagine_device_train;
	merge tr_cohort(in=a) tr_cohort_image3 tr_cohort_device3;
	by patient;
	array miss _numeric_;
		do over miss;
			if miss=. then miss=0;
		end;
run;


proc freq data=data.TR_patients;table DEATHDATE;format DEATHDATE year4.;run;

proc freq data=data.tt_patient_update;table DEATHDATE;format DEATHDATE year4.;run;

/***************************************************** Now clean the testing dataset***********************************************/

** Imaging studies;
proc sql;
	create table tt_cohort_image as 
	select A.id, A.id as patient, B.*
	from data.tt_patient_update A inner join data.tt_imaging_studies B on A.id=B.patient
	where '01Jan2019'd<=B.date<='30Jun2020'd;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **628//1032;

proc freq data=tt_cohort_image;table bodysite_description modality_description sop_description;run;


data tt_cohort_image1(keep=patient image_type image_body);
	set tt_cohort_image;
	if SOP_description="CT Image Storage" then image_type=1;
	if SOP_description in ("Digital X-Ray Image Storage","Digital X-Ray Image Storage – for Presentation") then image_type=2;
	if SOP_description in ("Ultrasound Image Storage", "Ultrasound Multiframe Image Storage") then image_type=3;

	if BODYSITE_DESCRIPTION='Ankle' then image_body=1;
	if BODYSITE_DESCRIPTION='Arm' then image_body=2;
	if BODYSITE_DESCRIPTION='Chest' then image_body=3;
	if BODYSITE_DESCRIPTION='Clavicle' then image_body=4;
	if BODYSITE_DESCRIPTION='Knee' then image_body=5;
	if BODYSITE_DESCRIPTION='Pelvis' then image_body=6;
	if BODYSITE_DESCRIPTION='Structure of right upper quadrant o' then image_body=7;
	if BODYSITE_DESCRIPTION in ('Thoracic','Thoracic structure','Thoracic structure (body structure)','thoracic') then image_body=8;
	if BODYSITE_DESCRIPTION='Wrist' then image_body=9;


	label image_type= "1=CT 2=X-ray 3=Ultrasound";
	label image_body="1=Ankle 2=Arm 3=Chest 4=Clavicle 5=Knee 6=Pelvis 7=quadrant 8=Thoracic 9=Wrist";
run;

proc freq data=tt_cohort_image1;table image_type image_body;run;

data tt_cohort_image2;
	set tt_cohort_image1;
	if image_type=1 then image_type1=1;else image_type1=0;
	if image_type=2 then image_type2=1;else image_type2=0;
	if image_type=3 then image_type3=1;else image_type3=0;
	
	if image_body=1 then image_body1=1;else image_body1=0;
	if image_body=2 then image_body2=1;else image_body2=0;
	if image_body=3 then image_body3=1;else image_body3=0;
	if image_body=4 then image_body4=1;else image_body4=0;
	if image_body=5 then image_body5=1;else image_body5=0;
	if image_body=6 then image_body6=1;else image_body6=0;
	if image_body=7 then image_body7=1;else image_body7=0;
	if image_body=8 then image_body8=1;else image_body8=0;
	if image_body=9 then image_body9=1;else image_body9=0;
run;

proc sql;
	create table tt_cohort_image3 as 
	select patient, max(image_type1) as image_type1,max(image_type2) as image_type2,max(image_type3) as image_type3,
					max(image_body1) as image_body1,max(image_body2) as image_body2,max(image_body3) as image_body3,
					max(image_body4) as image_body4,max(image_body5) as image_body5,max(image_body6) as image_body6,
					max(image_body7) as image_body7,max(image_body8) as image_body8,max(image_body9) as image_body9
	from tt_cohort_image2
	group by patient;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **628//628;


**Device;

proc sql;
	create table tt_cohort_device1 as 
	select A.id, A.id as patient, B.*
	from data.TT_PATIENT_UPDATE A inner join data.tt_devices B on A.id=B.patient 
	where '01Jan2019'd<=B.start<='30Jun2020'd;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **70//70;

proc freq data=tt_cohort_device1;table DESCRIPTION;run;

data tt_cohort_device2;
	set tt_cohort_device1;
	if description="Coronary artery stent (physical object)" then device=1;
	if DESCRIPTION="Hemodialysis machine  device (physical object)" then device=2;
	if description="Implantable cardiac pacemaker (physical object)" then device=3;
	if description="Implantable defibrillator  device (physical object)" then device=4;
	if description="Mechanical ventilator (physical object)" then device=5;
	if description="Videolaryngoscope (physical object)" then device=6;

	if device=1 then device1=1;else device1=0;	
/*	if device=2 then device2=1;else device2=0;*/
	if device=3 then device3=1;else device3=0;
	if device=4 then device4=1;else device4=0;
/*	if device=5 then device5=1;else device5=0;*/
/*	if device=6 then device6=1;else device6=0;*/

run;

proc freq data=tt_cohort_device2;table device;run;


proc sql;
	create table tt_cohort_device3 as 
	select distinct patient, max(device1) as device1, 
/*					max(device2) as device2,*/
					max(device3) as device3,
					max(device4) as device4
/*					max(device5) as device5,*/
/*					max(device6) as device6*/
	from tt_cohort_device2
	group by patient;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **70//70;


proc sql;
	create table tt_cohort as 
	select distinct id as patient 
	from data.TT_PATIENT_UPDATE
	order by id;
quit;

data data1.bj_imagine_device_test;
	merge tt_cohort(in=a) tt_cohort_image3 tt_cohort_device3;
	by patient;
	array miss _numeric_;
		do over miss;
			if miss=. then miss=0;
		end;
run;

/***********************************************************************************************************/
/************ Get the patients from both training and testing dataset who did not die prior to 2019*********/

proc freq data=data.TR_patients;table DEATHDATE;format DEATHDATE year4.;run;

proc freq data=data.tt_patient_update;table DEATHDATE;format DEATHDATE year4.;run;


proc sql;
	create table TR_patients_not_dead as 
	select id as patient, deathdate
	from data.TR_patients
	where year(deathdate)=2020 or deathdate is null
	order by id;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **85944//85944;

proc sql;
	create table TT_patients_not_dead as 
	select id as patient, deathdate
	from data.tt_patient_update
	where year(deathdate)=2020 or deathdate is null
	order by id;
quit;

proc sql;
	select count(distinct patient), count(*) from _last_;
quit; **21479//21479;


/******************************************************************************************************************************/
/**************************Merge all the data together for training and testing dataset ****************************************/
/*-----------------------------------------------------------------------------------------------------------------------------*/

*** Training dataset;

data covid19_cohort_train(drop=deathdate);
	merge dataup.sg_outcomes dataup.SJ_outcome_death 
		  data1.sg_patients_train  data1.sg_encounters_train data1.sg_conditions_train_new data1.sg_procedures_train
		  data1.sj_medications_train data1.sj_observations_train data1.sj_immunizations_train data1.sj_allergies_train 
		  data1.bj_imagine_device_train TR_patients_not_dead(in=a);
	by patient;
	if a;
	if covid_hosp=. then covid_hosp=0;
	if covid_hosp_los=. then covid_hosp_los=0;
	if covid_icu=. then covid_icu=0;
	if covid_icu_los=. then covid_icu_los=0;
	if covid_niv=. then covid_niv=0;
	if death=. then death=0;

run;

*** Getting the COvid status -- patients who tested positive;


proc sql;
	create table covid19_pos_train as 
	select A.*, B.*
	from data.tr_patients A inner join data.tr_observations B on A.id=B.patient
	where CODE="94531-1" and value="Detected (qualifier v";
quit;

proc sql;
	select count(distinct id), count(*) from _last_;
quit; **73967//73967;

proc sql;
	create table data1.BJ_train_dataset as 
	select Patient, case when patient in (select patient from covid19_pos_train) then 1 else 0 end as covid_status,
		   *
	from covid19_cohort_train;
quit;

proc freq data=data1.BJ_train_dataset;table covid: death ;run;
proc freq data=data1.BJ_train_dataset;table com:;run;

**** testing dataset;

data data1.BJ_test_dataset(drop=deathdate);
	merge data1.sg_patients_test  data1.sg_encounters_test data1.sg_conditions_test data1.sg_procedures_test
		  data1.sj_medications_test data1.sj_observations_test data1.sj_immunizations_test data1.sj_allergies_test 
		  data1.bj_imagine_device_test TT_patients_not_dead(in=a);
	by patient;
	if a;
run;

proc contents data=data1.BJ_train_dataset out=train_list;run;
proc contents data=data1.BJ_test_dataset out=test_list;run;

**** Now checking the variable from both training and testing datasets;

proc sql;
	create table train_list1 as 
	select compress(Name,".") as variable , 1 as train
	from train_list
	order by Name;
quit;


proc sql;
	create table test_list1 as 
	select compress(Name,".") as variable , 1 as test
	from test_list
	order by Name;
quit;

proc sort data=train_list1;by variable;run;
proc sort data=test_list1;by variable;run;


data train_test_list;
	merge train_list1 test_list1;
	by variable;
	if train=. then train=0;
	if test=. then test=0;
	if train=1 and test=1 then train_test_flag=1;else train_test_flag=0;
	if variable in ('covid_status','covid_hosp','covid_hosp_los','covid_icu','covid_icu_los','covid_niv','death') then train_test_flag=1;
run;
proc export data=train_test_list outfile="\\vhasfcreap\Bocheng2\Covid19_challenge\Data_cleaned2\train_test_variable.xlsx"
	dbms=xlsx
	replace;
run;

proc freq data=train_test_list;table train_test_flag train*test /norow nocol nopercent;run;

proc sql;
	create table checking_variable_list as 
	select *
	from train_test_list 
	where train=0 and test=1;
quit;



/****************************Merge data with the comment variables**************************/

proc sql;
	select variable into: train_test separate by " "
	from train_test_list
	where train_test_flag=1;
quit;


data BJ_train_dataset(keep=PATIENT &train_test);
	set data1.BJ_train_dataset;
run;

data BJ_test_dataset(keep=PATIENT &train_test);
	set data1.BJ_test_dataset;
run;

proc contents data=BJ_train_dataset;run;
proc contents data=BJ_test_dataset;run;



proc surveyselect data=BJ_train_dataset out=BJ_train_dataset1 method=srs samprate=0.8
         seed=1234567;
  samplingunit patient;
run;

proc sql;
	create table BJ_train_dataset2 as 
	select *
	from BJ_train_dataset
	where patient not in (select patient from BJ_train_dataset1);
quit;

data BJ_train_dataset1;
	set BJ_train_dataset1;
	train_vet_test=0;
run;

data BJ_train_dataset2;
	set BJ_train_dataset2;
	train_vet_test=1;
run;

data BJ_test_dataset;
	set BJ_test_dataset;
	train_vet_test=2;
run;

data data1.BJ_train_test_dataset;
	set BJ_train_dataset1 BJ_train_dataset2 BJ_test_dataset;
run;

proc freq data=data1.BJ_train_test_dataset;table train_vet_test;run;

proc export data=data1.BJ_train_test_dataset outfile="\\vhasfcreap\Bocheng2\Covid19_challenge\Data_cleaned2\BJ_train_test_dataset.csv"
	dbms=csv
	replace;
run;


*** Let's clean the data and make it a desiable dataset before model building;

proc freq data=data1.BJ_train_test_dataset;table death MARITAL race ethnicity gender como19_195662009 ;run;

proc contents  data=covid19_cohort_cleanup;run;

proc freq data=data1.BJ_train_test_dataset;table death covid_hosp covid_hosp_los covid_icu covid_icu_los covid_niv;run;

proc freq data=data1.BJ_train_test_dataset;table train_vet_test*(death covid_hosp covid_hosp_los covid_icu covid_icu_los covid_niv) /nocol norow nofreq;run;

proc freq data=data1.BJ_train_test_dataset;table MED: /out=med_frq;run;

proc freq data=data1.BJ_train_test_dataset;table allergies:;run;

proc freq data=data1.BJ_train_test_dataset;table como:;run;

proc freq data=data1.BJ_train_test_dataset;table device:;run;

proc freq data=data1.BJ_train_test_dataset;table enco:;run;

proc freq data=data1.BJ_train_test_dataset;table image:;run;

proc freq data=data1.BJ_train_test_dataset;table immune:;run;

proc freq data=data1.BJ_train_test_dataset;table obs:;run;

proc freq data=data1.BJ_train_test_dataset;table proc:;run;


*** To clean the data, at this moment, we will only remove variables with 0 frequencies;

data covid19_cohort_cleanup_1(drop=MED_1043400_2018 MED_1049630_2018 MED_1049635_2018 MED_105078_2018 MED_1100184_2018 MED_1114085_2018 MED_1190795_2018 
								   MED_1234995_2018 MED_1359133_2018 MED_1363309_2018 MED_1366343_2018 MED_141918_2018 MED_1601380_2018 MED_1652673_2018
								   MED_1659263_2018 MED_1660014_2018 MED_1665227_2018 MED_1723208_2018 MED_1729584_2018 MED_1732136_2018 MED_1732186_2018
								MED_1734340_2018 MED_1734919_2018 MED_1735006_2018 MED_1736854_2018 MED_1737449_2018 MED_1740467_2018 MED_1790099_2018
								MED_1791701_2018 MED_1804799_2018 MED_1808217_2018 MED_1809104_2018 MED_1946840_2018 MED_197319_2018 MED_197378_2018
							    MED_197541_2018 MED_198240_2018 MED_198405_2018 MED_198767_2018 MED_199224_2018 MED_200064_2018 MED_205532_2018 MED_205923_2018
								MED_2119714_2018 MED_235389_2018 MED_243670_2018 MED_259255_2018 MED_308182_2018 MED_308192_2018 MED_309043_2018 MED_309045_2018
								MED_309097_2018 MED_310261_2018 MED_311700_2018 MED_311989_2018 MED_311995_2018 MED_312615_2018 MED_312617_2018 MED_313002_2018
								MED_313185_2018 MED_313572_2018 MED_313820_2018 MED_477045_2018 MED_583214_2018 MED_596926_2018 MED_597195_2018 MED_665078_2018
								MED_727762_2018 MED_749785_2018 MED_749882_2018 MED_789980_2018 MED_833036_2018 MED_833135_2018 MED_834061_2018 MED_834102_2018
								MED_834357_2018 MED_857005_2018 MED_861467_2018 MED_996740_2018 MED_997223_2018 MED_997488_2018 MED_1014678_2019 MED_1049630_2019
								MED_1049635_2019 MED_105078_2019 MED_1091392_2019 MED_1100184_2019 MED_1114085_2019 MED_1359133_2019 MED_1363309_2019
								MED_1366343_2019 MED_1373463_2019 MED_141918_2019 MED_1652673_2019 MED_1665227_2019 MED_1735006_2019 MED_1737449_2019 
								MED_1791701_2019 MED_1809104_2019 MED_199224_2019 MED_200064_2019 MED_205532_2019 MED_2119714_2019 MED_235389_2019 MED_243670_2019
								MED_308182_2019 MED_309043_2019 MED_309045_2019 MED_310261_2019 MED_310385_2019 MED_312615_2019 MED_313185_2019 MED_313572_2019
								MED_313820_2019 MED_597195_2019 MED_665078_2019 MED_727762_2019 MED_749785_2019 MED_749882_2019 MED_789980_2019 MED_834061_2019
								MED_993452_2019 MED_996740_2019 MED_997223_2019 MED_997488_2019 MED_997501_2019 como19_233604007 como19_127295002
								como19_86849004 como19_1734006 como19_433144002 como19_45816000 como1518_39848009 como1518_233604007 como1518_195967001 como1518_301011002
								como1518_58150001 como1518_44465007 como1518_283385000 como1518_239720000 como1518_70704007 como1518_263102004 como1518_65966004
								como1518_161622006 como1518_62106007 como1518_398254007 como1518_359817006 como1518_284549007 como1518_262574004 como1518_403191005
								como1518_33737001 como1518_443165006 como1518_284551006 como1518_444448004 como1518_408512008 como1518_307731004 como1518_370247008
								como1518_36923009 como1518_403190006 como1518_110030002 como1518_30832001 como1518_48333001 como1518_444470001 como1518_65275009
								como1518_235919008 immune_10_2018 immune_113_2018 immune_114_2018 immune_115_2018 immune_121_2018 immune_133_2018 immune_140_2018
								immune_20_2018 immune_21_2018 immune_3_2018 immune_33_2018 immune_43_2018 immune_49_2018 immune_52_2018 immune_62_2018 immune_8_2018
								immune_83_2018 immune_10_2019 immune_115_2019 immune_20_2019 immune_21_2019 immune_3_2019 immune_49_2019 immune_62_2019 immune_8_2019
								immune_83_2019 obs_10230_1_2018 obs_10480_2_2018 obs_10834_0_2018 obs_14959_1_2018 obs_1742_6_2018 obs_1751_7_2018 obs_17861_6_2018
obs_18262_6_2018 obs_1920_8_2018 obs_1975_2_2018 obs_19926_5_2018 obs_2028_9_2018 obs_20454_5_2018 obs_20505_4_2018 obs_20565_8_2018 obs_20570_8_2018 obs_2069_3_2018
obs_2075_0_2018 obs_2085_9_2018 obs_2093_3_2018 obs_21000_5_2018 obs_2160_0_2018 obs_21905_5_2018 obs_21906_3_2018 obs_21907_1_2018 obs_21908_9_2018 obs_21924_6_2018
obs_2339_0_2018 obs_2345_7_2018 obs_2514_8_2018 obs_25428_4_2018 obs_2571_8_2018 obs_26453_1_2018 obs_26464_8_2018 obs_26515_7_2018 obs_2823_3_2018 obs_28245_9_2018
obs_2857_1_2018 obs_2885_2_2018 obs_2947_0_2018 obs_2951_2_2018 obs_3016_3_2018 obs_3024_7_2018 obs_30385_9_2018 obs_30428_7_2018 obs_3094_0_2018 obs_32167_9_2018
obs_32207_3_2018 obs_32465_7_2018 obs_32623_1_2018 obs_33037_3_2018 obs_33728_7_2018 obs_33756_8_2018 obs_33762_6_2018 obs_33914_3_2018 obs_38265_5_2018 obs_38483_4_2018
obs_4171810_2018 obs_42719_5_2018 obs_44667_4_2018 obs_4544_3_2018 obs_4548_4_2018 obs_46240_8_2018 obs_46288_7_2018 obs_49765_1_2018 obs_55277_8_2018 
obs_5767_9_2018 obs_5770_3_2018 obs_5778_6_2018 obs_57905_2_2018 obs_5792_7_2018 obs_5794_3_2018 obs_5797_6_2018 obs_5799_2_2018 obs_5802_4_2018 obs_5803_2_2018
obs_5804_0_2018 obs_5811_5_2018 obs_59557_9_2018 obs_59576_9_2018 obs_6075_6_2018 obs_6082_2_2018 obs_6085_5_2018 obs_6095_4_2018 obs_6106_9_2018 obs_6158_0_2018
obs_6189_5_2018 obs_6206_7_2018 obs_6246_3_2018 obs_6248_9_2018 obs_6273_7_2018 obs_6276_0_2018 obs_6298_4_2018 obs_6299_2_2018 obs_63513_6_2018 obs_66519_0_2018
obs_66524_0_2018 obs_66529_9_2018 obs_66534_9_2018 obs_6690_2_2018 obs_6768_6_2018 obs_6833_8_2018 obs_6844_5_2018 obs_69453_9_2018 obs_71802_3_2018 obs_718_7_2018
obs_71970_8_2018 obs_71972_4_2018 obs_72009_4_2018 obs_72010_2_2018 obs_72011_0_2018 obs_72012_8_2018 obs_72013_6_2018 obs_72014_4_2018 obs_72015_1_2018 obs_72016_9_2018
obs_72093_8_2018 obs_72094_6_2018 obs_72095_3_2018 obs_72096_1_2018 obs_72097_9_2018 obs_72106_8_2018 obs_7258_7_2018 obs_74006_8_2018 obs_75443_2_2018 obs_76690_7_2018
obs_77606_2_2018 obs_777_3_2018 obs_785_6_2018 obs_786_4_2018 obs_787_2_2018 obs_789_8_2018 obs_80271_0_2018 obs_84215_3_2018 obs_85318_4_2018 obs_85319_2_2018
obs_85337_4_2018 obs_85339_0_2018 obs_85343_2_2018 obs_85344_0_2018 obs_85352_3_2018 obs_88040_1_2018 obs_9279_1_2018 obs_9843_4_2018  obs_4171810_2019 obs_21924_6_2019
obs_4171810_2019 obs_59576_9_2019 obs_71972_4_2019 obs_72009_4_2019 obs_72010_2_2019 obs_72011_0_2019 obs_72012_8_2019 obs_72013_6_2019 obs_72014_4_2019 obs_72015_1_2019
obs_72016_9_2019 obs_72093_8_2019 obs_72094_6_2019 obs_72095_3_2019 obs_72096_1_2019 obs_72097_9_2019 obs_9843_4_2019 proc19_38102005 proc19_305433001 proc19_88039007
proc19_241615005 proc19_384692006 proc19_447759004 proc19_177157003 proc19_74857009 proc19_88848003 proc19_90407005 proc19_52734007 proc19_113120007 proc1518_40701008
proc1518_232717009 proc1518_265764009 proc1518_410006001 proc1518_415070008 proc1518_430193006 proc1518_15081005 proc1518_127783003 proc1518_73761001 proc1518_703423002
proc1518_399208008 proc1518_433236007 proc1518_434158009 proc1518_18286008 proc1518_180325003 proc1518_35025007 proc1518_71651007 proc1518_90226004 proc1518_447365002
proc1518_23426006 proc1518_19490002 proc1518_274474001 proc1518_312681000 proc1518_433112001 proc1518_117015009 proc1518_65575008 proc1518_90470006 proc1518_76601001
proc1518_169553002 proc1518_398171003 proc1518_288086009 proc1518_384700001 proc1518_269911007 proc1518_104435004 proc1518_274031008 proc1518_287664005 proc1518_311791003
proc1518_33195004 proc1518_122548005 proc1518_241055006 proc1518_392021009 proc1518_433114000 proc1518_434363004 proc1518_74016001 proc1518_168594001 proc1518_305428000
proc1518_43075005 proc1518_76164006 proc1518_60027007 proc1518_46706006 proc1518_1225002 proc1518_268425006 proc1518_14768001 proc1518_162676008 proc1518_301807007
proc1518_415300000 proc1518_698354004 proc1518_418891003 proc1518_432231006 proc1518_91602002 proc1518_167995008 proc1518_699253003 proc1518_54550000 proc1518_225337009
proc1518_385892002 proc1518_715252007 proc1518_5880005 proc1518_28163009 proc1518_31676001 proc1518_44608003 proc1518_47758006 proc1518_66348005 proc1518_104091002
proc1518_104326007 proc1518_104375008 proc1518_117010004 proc1518_118001005 proc1518_165829005 proc1518_167271000 proc1518_169230002 proc1518_169690007 proc1518_225158009
proc1518_252160004 proc1518_268556000 proc1518_269828009 proc1518_271442007 proc1518_274804006 proc1518_275833003 proc1518_310861008 proc1518_395123002 proc1518_399014008
proc1518_443529005 proc1518_173160006 proc1518_24623002 proc1518_241615005 proc1518_65546002 proc1518_171207006 proc1518_31208007 proc1518_65200003 proc1518_69031006
proc1518_234262008 proc1518_367336001 proc1518_43060002 proc1518_396487001 proc1518_443497002 proc1518_429609002 proc1518_305433001 proc1518_51116004 proc1518_10383002
proc1518_386394001 proc1518_714812005 proc1518_29303009 proc1518_45595009 proc1518_52765003 proc1518_22523008 city county state);
set data1.BJ_train_test_dataset;
run;

proc contents data=covid19_cohort_cleanup_1;run;

data como_proc(keep=Patient como: proc:);
	set covid19_cohort_cleanup_1;
	array variable _numeric_;
	do over variable;
		if variable=999 then variable=0;
	end;
run;

proc sql;
	create table covid19_cohort_cleanup_2 as 
	select A.*, B.*
	from covid19_cohort_cleanup_1(drop=como: proc:) A inner join como_proc B on A.patient=B.patient;
quit;


proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(med:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(allergies:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(device:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(image:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(immune:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(como:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(proc:) /nopercent norow nocol;run;
proc freq data=covid19_cohort_cleanup_2;table train_vet_test*(obs:) /nopercent norow nocol;run;

data covid19_cohort_cleanup_3(drop=MED_1091392_2018 MED_1094107_2018 MED_1373463_2018 MED_1659149_2018 MED_1873983_2018 MED_204892_2018	MED_241834_2018	MED_308971_2018	
MED_310965_2018	MED_311372_2018	MED_483438_2018	MED_562251_2018	MED_856987_2018	MED_897122_2018	MED_993452_2018 MED_105585_2019	MED_1190795_2019 MED_1234995_2019 
MED_1601380_2019 MED_1659149_2019 MED_1659263_2019	MED_1660014_2019 MED_1723208_2019 MED_1729584_2019 MED_1732136_2019 MED_1732186_2019 MED_1734919_2019 MED_1740467_2019	
MED_1790099_2019 MED_1808217_2019 MED_1856546_2019 MED_1870230_2019	MED_1873983_2019 MED_1946840_2019 MED_197378_2019 MED_197541_2019 MED_197591_2019 MED_198240_2019	
MED_198405_2019 MED_198767_2019 MED_204892_2019	MED_259255_2019	MED_311372_2019	MED_311700_2019	MED_311995_2019	MED_312617_2019	MED_313002_2019	MED_477045_2019 MED_483438_2019	
MED_542347_2019	MED_596926_2019	MED_833036_2019	MED_833135_2019	MED_834357_2019	MED_834357_2019	MED_897122_2019	image_body7 
como19_40275004 como19_128613002 como19_703151001 como19_403192003 como19_69896004 como19_82423001 como19_444448004 como19_275272006 como19_15724005 como19_6072007
como19_94260004 como19_236077008 como19_444470001 como19_65275009 como19_235919008 como19_239720000 como19_241929008 como19_230265002 como19_197927001 como19_262574004
como19_95417003 como19_47693006 como19_84757009 como19_110030002 como1518_75498004 como1518_127295002 como1518_195662009 como1518_10509002 como1518_1611400 como1518_6072007
como1518_36971009 como1518_94260004 como1518_40275004 como1518_95417003 como1518_225444004 como1518_698754002 proc19_54550000 proc19_387685009 proc19_183450002
proc19_305340004 proc19_433236007 proc19_232717009 proc19_415070008 proc19_69031006 proc19_241055006 proc19_396487001 proc19_443497002 proc19_447365002 proc19_29303009
proc19_45595009 proc19_52765003 proc19_22523008 proc19_313191000 proc19_33195004 proc19_445912000 proc19_429609002 proc19_236931002 proc19_395142003 proc19_234262008
proc19_392021009 proc19_385798007 obs_10480_2_2019 obs_17861_6_2019  obs_2028_9_2019 obs_2075_0_2019 obs_2160_0_2019 obs_2345_7_2019 obs_26453_1_2019 obs_26464_8_2019
obs_26515_7_2019 obs_2823_3_2019  obs_2951_2_2019 obs_3016_3_2019 obs_3024_7_2019 obs_30385_9_2019 obs_30428_7_2019 obs_3094_0_2019	obs_33037_3_2019 obs_42719_5_2019	
obs_6075_6_2019	obs_6082_2_2019	obs_6085_5_2019	obs_6095_4_2019	obs_6106_9_2019	obs_6158_0_2019	obs_6189_5_2019	obs_6206_7_2019	obs_6246_3_2019	obs_6248_9_2019	
obs_6273_7_2019	obs_6276_0_2019	obs_66519_0_2019 obs_66524_0_2019 obs_66529_9_2019	obs_66534_9_2019 obs_6833_8_2019 obs_6844_5_2019 obs_71970_8_2019 obs_7258_7_2019	
obs_80271_0_2019 obs_85343_2_2019	obs_85344_0_2019);
	set covid19_cohort_cleanup_2;

run;

proc contents data=covid19_cohort_cleanup_3;run;

**** Now clean up the encounter a bit;

data covid19_cohort_cleanup_4(drop=HEALTHCARE_EXPENSES HEALTHCARE_COVERAGE healthcare_total
								   enco19_ambulatory enco19_inpatient enco19_outpatient enco19_emergency enco19_urgentcare
								enco1518_ambulatory enco1518_inpatient enco1518_outpatient enco1518_emergency enco1518_urgentcare);
	set covid19_cohort_cleanup_3;
/*	if enco20_ambulatory=1 then enco20_ambulatory_cat=1;if enco20_ambulatory>1 then enco20_ambulatory_cat=2;*/
/*	if enco20_inpatient=0 then enco20_inpatient_cat=0;if enco20_inpatient=1 then enco20_inpatient_cat=1;if enco20_inpatient>1 then enco20_inpatient_cat=2;*/
/*	if enco20_outpatient=0 then enco20_outpatient_cat=0;if enco20_outpatient=1 then enco20_outpatient_cat=1;if enco20_outpatient>1 then enco20_outpatient_cat=2;*/
/*	if enco20_emergency=0 then enco20_emergency_cat=0;if enco20_emergency=1 then enco20_emergency_cat=1;if enco20_emergency>1 then enco20_emergency_cat=2;*/
	if enco20_urgentcare=0 then enco20_urgentcare_cat=0;if enco20_urgentcare=1 then enco20_urgentcare_cat=1;if enco20_urgentcare>1 then enco20_urgentcare_cat=2;
	if enco19_ambulatory=0 then enco19_ambulatory_cat=0;if enco19_ambulatory=1 then enco19_ambulatory_cat=1;if enco19_ambulatory>1 then enco19_ambulatory_cat=2;
	if enco19_inpatient=0 then enco19_inpatient_cat=0;if enco19_inpatient=1 then enco19_inpatient_cat=1;if enco19_inpatient>1 then enco19_inpatient_cat=2;
	if enco19_outpatient=0 then enco19_outpatient_cat=0;if enco19_outpatient=1 then enco19_outpatient_cat=1;if enco19_outpatient>1 then enco19_outpatient_cat=2;
	if enco19_emergency=0 then enco19_emergency_cat=0;if enco19_emergency=1 then enco19_emergency_cat=1;if enco19_emergency>1 then enco19_emergency_cat=2;
	if enco19_urgentcare=0 then enco19_urgentcare_cat=0;if enco19_urgentcare=1 then enco19_urgentcare_cat=1;if enco19_urgentcare>1 then enco19_urgentcare_cat=2;
	if enco1518_ambulatory=0 then enco1518_ambulatory_cat=0;if enco1518_ambulatory=1 then enco1518_ambulatory_cat=1;if enco1518_ambulatory>1 then enco1518_ambulatory_cat=2;
	if enco1518_inpatient=0 then enco1518_inpatient_cat=0;if enco1518_inpatient=1 then enco1518_inpatient_cat=1;if enco1518_inpatient>1 then enco1518_inpatient_cat=2;
	if enco1518_outpatient=0 then enco1518_outpatient_cat=0;if enco1518_outpatient=1 then enco1518_outpatient_cat=1;if enco1518_outpatient>1 then enco1518_outpatient_cat=2;
	if enco1518_emergency=0 then enco1518_emergency_cat=0;if enco1518_emergency=1 then enco1518_emergency_cat=1;if enco1518_emergency>1 then enco1518_emergency_cat=2;
	if enco1518_urgentcare=0 then enco1518_urgentcare_cat=0;if enco1518_urgentcare=1 then enco1518_urgentcare_cat=1;if enco1518_urgentcare>1 then enco1518_urgentcare_cat=2;
	if obs_QOLS=99 then obs_QOLS=0;
run;

proc freq data=covid19_cohort_cleanup_4;table obs:;run;

proc contents data=covid19_cohort_cleanup_4;run;

proc export data=covid19_cohort_cleanup_4 outfile="\\vhasfcreap\Bocheng2\Covid19_challenge\Data_cleaned\Covid19_cohort_cleaned_bj.csv"
	dbms=csv
	replace;
run;

/**************************************************************************************************************************************************************/
***** Now merge all the data together;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_holdout_probs_covidstatus.csv"
	out=GB_holdout_probs_covidstatus
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_holdout_probs_death.csv"
	out=GB_holdout_probs_death
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_holdout_probs_hosp.csv"
	out=GB_holdout_probs_hosp
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_holdout_probs_icu.csv"
	out=GB_holdout_probs_icu
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_holdout_probs_niv.csv"
	out=GB_holdout_probs_niv
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_covidstatus.csv"
	out=GB_probs_covidstatus
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_death.csv"
	out=GB_probs_death
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_hosp.csv"
	out=GB_probs_hosp
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_icu.csv"
	out=GB_probs_icu
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_niv.csv"
	out=GB_probs_niv
	dbms=csv
	replace;
run;
proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GS_RandomForest_prediction.csv"
	out=GS_RandomForest_prediction
	dbms=csv
	replace;
run;


**** predicted probability from training;
proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_train_probs_covidstatus.csv"
	out=GB_train_probs_covidstatus
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_train_probs_death.csv"
	out=GB_train_probs_death
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_train_probs_hosp.csv"
	out=GB_train_probs_hosp
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_train_probs_icu.csv"
	out=GB_train_probs_icu
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_train_probs_niv.csv"
	out=GB_train_probs_niv
	dbms=csv
	replace;
run;

**** Now merge my data;

proc sql;
	create table GB_covidstatus as 
	select Patient, BJ_covid_status from GB_train_probs_covidstatus
		union
	select Patient, prob_covidstatus_yes as BJ_covid_status from GB_HOLDOUT_PROBS_COVIDSTATUS
		union
	select Patient, (1-probs_covid_status) as BJ_covid_status from GB_PROBS_COVIDSTATUS;
quit;

proc sql;
	create table GB_death as 
	select Patient, BJ_death from GB_train_probs_death
		union
	select Patient,prob_death_yes as BJ_death from GB_holdout_probs_death
		union
	select Patient, probs_death as BJ_death from GB_probs_death;
quit;

proc sql;
	create table GB_hosp as 
	select Patient, BJ_hosp from GB_train_probs_hosp
		union
	select Patient,prob_hosp_yes as BJ_hosp from GB_holdout_probs_hosp
		union
	select Patient, probs_covid_hosp as BJ_hosp from GB_probs_hosp;
quit;

proc sql;
	create table GB_icu as 
	select Patient, BJ_icu from GB_train_probs_icu
		union
	select Patient,prob_icu_yes as BJ_icu from GB_holdout_probs_icu
		union
	select Patient, probs_icu as BJ_icu from GB_probs_icu;
quit;

proc sql;
	create table GB_niv as 
	select Patient, BJ_niv from GB_train_probs_niv
		union
	select Patient,prob_niv_yes as BJ_niv from GB_holdout_probs_niv
		union
	select Patient, probs_covid_niv as BJ_niv from GB_probs_niv;
quit;

proc sql;
	create table BJ_GB_prediction as 
	select A.*, B.*,C.*, D.*, E.*
	from GB_covidstatus A inner join GB_death B on A.patient=B.patient
						  inner join GB_hosp C on B.patient=C.patient
						  inner join GB_icu D on C.patient=D.patient
						  inner join GB_niv E on D.patient=E.patient;
quit;


**** Now merge all the data;

proc sql;
	create table Covid19_prediction as 
	select A.*, B.*, C.*
	from SJ_lasso_prediction A inner join GS_randomforest_prediction B on A.patient=B.patient
							   inner join BJ_GB_prediction C on A.patient=C.patient
	order by train_vet_test;
quit;

proc sql;
	select count(distinct Patient), count(*) from _last_;
quit;

proc export data=Covid19_prediction outfile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\Covid19_prediction.csv"
	dbms=csv
	replace;
run;


**** Now import the predictions from overall predictions;
proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_covidstatus_overall.csv"
	out=GB_probs_covidstatus_overall
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_death_overall.csv"
	out=GB_probs_death_overall
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_hosp_overall.csv"
	out=GB_probs_hosp_overall
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_icu_overall.csv"
	out=GB_probs_icu_overall
	dbms=csv
	replace;
run;

proc import datafile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\GB_probs_niv_overall.csv"
	out=GB_probs_niv_overall
	dbms=csv
	replace;
run;

proc sql;
	create table BJ_covid_prediciton_overall as
	select A.Patient, A.train_vet_test, A.BJ_death,
		   B.BJ_covid_status, 
		   C.BJ_hosp,
		   D.BJ_niv,
		   E.BJ_icu
	from GB_probs_death_overall A inner join GB_probs_covidstatus_overall B on A.patient=B.patient
								  inner join GB_probs_hosp_overall C on A.patient=C.patient
								  inner join GB_probs_niv_overall D on A.patient=D.patient
								  inner join GB_probs_icu_overall E on A.patient=E.patient;
quit;


proc export data=BJ_covid_prediciton_overall outfile="\\vhasfcreap\Bocheng2\Bocheng Personal\PrecisionFDA_Covid19_Model_challenge\Document\BJ_Covid19_prediction.csv"
	dbms=csv
	replace;
run;


					














































 




	















































































































































































































;
	set covid19_cohort_cleanup;
run;


