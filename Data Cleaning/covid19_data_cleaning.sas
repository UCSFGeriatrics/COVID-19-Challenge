libname covidnew "XXX";
options nofmterr nocenter nodate mlogic mprint ls=256 ps=80; 

*patients;
proc import out=patients
            datafile='XXX\patients.csv' replace; 
            getnames=yes;
run;

data patients_cohort;
  set patients;
  healthcare_total=Healthcare_Expenses+Healthcare_Coverage;
  age=int((intck('month',BIRTHDATE,mdy(01,01,2020))- (mdy(01,01,2020) < day(BIRTHDATE))) / 12);
  rename id=patient;
run;

%macro quint(dsn,var,quintvar,quintlev);

/* calculate the cutpoints for the quintiles */
proc univariate noprint data=&dsn;
  var &var;
  output out=quintile pctlpts=20 40 60 80 pctlpre=pct;
run;

/* write the quintiles to macro variables */
data _null_;
set quintile;
call symputx('q1',pct20) ;
call symputx('q2',pct40) ;
call symputx('q3',pct60) ;
call symputx('q4',pct80) ;
run;

/* create the new variable in the main dataset */
data &dsn;
  set &dsn;
  length &quintlev $ 30.;
  if &var =. then do; &quintvar = . ; &quintlev =""; end;
  else if &var le &q1. *1 then do; &quintvar= 1; &quintlev = "<= &q1."; end;
  else if &var le &q2. *1 then do; &quintvar= 2; &quintlev = "&q1. - &q2."; end;
  else if &var le &q3. *1 then do; &quintvar= 3; &quintlev = "&q2. - &q3."; end;
  else if &var le &q4. *1 then do; &quintvar= 4; &quintlev = "&q3. - &q4."; end; 
  else do; &quintvar=5; &quintlev = "> &q4."; end;
run;

%mend quint;

%quint(patients_cohort,Healthcare_Expenses,Healthcare_Expenses_quint,Healthcare_Expenses_quint_cat);
%quint(patients_cohort,Healthcare_Coverage,Healthcare_Coverage_quint,Healthcare_Coverage_quint_cat);
%quint(patients_cohort,healthcare_total,healthcare_total_quint,healthcare_total_quint_cat);


proc sort data=patients_cohort nodupkey;
  by patient;
run;

data patients_cohort_final;
  set patients_cohort;
  if marital='' then marital='U';
  keep patient age gender marital race ethnicity state county city
       Healthcare_Expenses Healthcare_Expenses_quint 
       Healthcare_Coverage Healthcare_Coverage_quint 
       healthcare_total healthcare_total_quint;
run;

data covidnew.SG_patients_test;
  set patients_cohort_final;
run;

*conditions;
proc import out=conditions
            datafile='XXX\conditions.csv' replace; 
            getnames=yes;
run;

data conditions_cohort2;
  set conditions;
  condition_year=year(start);
  if condition_year=2020 then condition_year_cat='2020';
  else if condition_year=2019 then condition_year_cat='2019';
  else if 2014 <condition_year<2019 then condition_year_cat='1518';
  if condition_year_cat ne "";
run;

proc sql;
  create table conditions_cohort3 as
  select distinct patient,condition_year_cat,code,description 
  from conditions_cohort2;
quit;

data conditions_cohort2020;
  set conditions_cohort3;
  if condition_year_cat='2020';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=conditions_cohort2020 out=conditions_cohort2020_wide prefix=como20_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data conditions_cohort2020_wide;
  set conditions_cohort2020_wide;
  array como(*) como20_:;

  do i=1 to dim(como);
    if como(i)=. then como(i)=0;
  end;

  drop _name_ i;
run;

data conditions_cohort2019;
  set conditions_cohort3;
  if condition_year_cat='2019';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=conditions_cohort2019 out=conditions_cohort2019_wide prefix=como19_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data conditions_cohort2019_wide;
  set conditions_cohort2019_wide;
  array como(*) como19_:;

  do i=1 to dim(como);
    if como(i)=. then como(i)=0;
  end;

  drop _name_ i;
run;

data conditions_cohort1518;
  set conditions_cohort3;
  if condition_year_cat='1518';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=conditions_cohort1518 out=conditions_cohort1518_wide prefix=como1518_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data conditions_cohort1518_wide;
  set conditions_cohort1518_wide;
  array como(*) como1518_:;

  do i=1 to dim(como);
    if como(i)=. then como(i)=0;
  end;

  drop _name_ i;
run;

proc sql;
  create table conditions_cohort_all as
  select d.patient,a.*,b.*,c.*
  from (select distinct patient from patients_cohort_final) d left join conditions_cohort2020_wide a on d.patient=a.patient
                                                   left join conditions_cohort2019_wide b on d.patient=b.patient
                                                   left join conditions_cohort1518_wide c on d.patient=c.patient;
quit;

data conditions_cohort_all;
  set conditions_cohort_all;
  array como(*) como20_: como19_: como1518_:;

  do i=1 to dim(como);
    if como(i)=. then como(i)=999;
  end;

  drop _name_ i;
run;

proc freq data=conditions_cohort_all;
  table como19_: como1518_:;
  label;
run;

data covidnew.SG_conditions_test;
  set conditions_cohort_all;
run;

*encounter;
proc import out=encounters
            datafile='XXX\encounters.csv' replace; 
            getnames=yes;
run;

data encounters_cohort2;
  set encounters;
  encounter_year=year(datepart(start));
  if encounter_year=2020 then encounter_year_cat='2020';
  else if encounter_year=2019 then encounter_year_cat='2019';
  else if 2014 <encounter_year<2019 then encounter_year_cat='1518';
  if encounter_year_cat ne "";
proc sort nodupkey;
  by patient start ENCOUNTERCLASS;
run;

proc sql;
  create table encounters_cohort3 as
  select distinct patient,encounter_year_cat,ENCOUNTERCLASS,count(*) as n
  from encounters_cohort2
  group by patient,encounter_year_cat,ENCOUNTERCLASS;
quit;

data encounters_cohort2020;
  set encounters_cohort3;
  if encounter_year_cat='2020';
  count=1;
proc sort nodupkey;
  by patient ENCOUNTERCLASS;
run;

proc transpose data=encounters_cohort2020 out=encounters_cohort2020_wide prefix=enco20_;
  by patient;
  var n;
  id ENCOUNTERCLASS;
run;

data encounters_cohort2019;
  set encounters_cohort3;
  if encounter_year_cat='2019';
  count=1;
proc sort nodupkey;
  by patient ENCOUNTERCLASS;
run;

proc transpose data=encounters_cohort2019 out=encounters_cohort2019_wide prefix=enco19_;
  by patient;
  var n;
  id ENCOUNTERCLASS;
run;

data encounters_cohort1518;
  set encounters_cohort3;
  if encounter_year_cat='1518';
  count=1;
proc sort nodupkey;
  by patient ENCOUNTERCLASS;
run;

proc transpose data=encounters_cohort1518 out=encounters_cohort1518_wide prefix=enco1518_;
  by patient;
  var n;
  id ENCOUNTERCLASS;
run;

proc sql;
  create table encounters_cohort_all as
  select d.patient,a.*,b.*,c.*
  from (select distinct patient from patients_cohort_final) d left join encounters_cohort2020_wide a on d.patient=a.patient
                                                              left join encounters_cohort2019_wide b on d.patient=b.patient
                                                              left join encounters_cohort1518_wide c on d.patient=c.patient;
quit;

data encounters_cohort_all;
  set encounters_cohort_all;
  array enco(*) enco20_: enco19_: enco1518_:;

  do i=1 to dim(enco);
    if enco(i)=. then enco(i)=0;
  end;

  drop _name_ i;
run;

proc freq data=encounters_cohort_all;
  table enco19_: enco1518_:;
  label;
run;

data covidnew.SG_encounters_test;
  set encounters_cohort_all;
run;

*procedures;
proc import out=procedures
            datafile='XXX\procedures.csv' replace; 
            getnames=yes;
run;

data procedures_cohort2;
  set procedures;
  proc_year=year(Date);
  if proc_year=2020 then proc_year_cat='2020';
  else if proc_year=2019 then proc_year_cat='2019';
  else if 2014 <proc_year<2019 then proc_year_cat='1518';
  if proc_year_cat ne "";
run;

proc sql;
  create table procedures_cohort3 as
  select distinct patient,proc_year_cat,code,description 
  from procedures_cohort2;
quit;

data procedures_cohort2020;
  set procedures_cohort3;
  if proc_year_cat='2020';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=procedures_cohort2020 out=procedures_cohort2020_wide prefix=proc20_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data procedures_cohort2020_wide;
  set procedures_cohort2020_wide;
  array proc(*) proc20_:;

  do i=1 to dim(proc);
    if proc(i)=. then proc(i)=0;
  end;

  drop _name_ i;
run;

data procedures_cohort2019;
  set procedures_cohort3;
  if proc_year_cat='2019';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=procedures_cohort2019 out=procedures_cohort2019_wide prefix=proc19_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data procedures_cohort2019_wide;
  set procedures_cohort2019_wide;
  array proc(*) proc19_:;

  do i=1 to dim(proc);
    if proc(i)=. then proc(i)=0;
  end;

  drop _name_ i;
run;

data procedures_cohort1518;
  set procedures_cohort3;
  if proc_year_cat='1518';
  count=1;
proc sort nodupkey;
  by patient code;
run;

proc transpose data=procedures_cohort1518 out=procedures_cohort1518_wide prefix=proc1518_;
  by patient;
  var count;
  id code;
  idlabel description;
run;

data procedures_cohort1518_wide;
  set procedures_cohort1518_wide;
  array proc(*) proc1518_:;

  do i=1 to dim(proc);
    if proc(i)=. then proc(i)=0;
  end;

  drop _name_ i;
run;

proc sql;
  create table procedures_all as
  select d.patient,a.*,b.*,c.*
  from (select distinct patient from patients_cohort_final) d left join procedures_cohort2020_wide a on d.patient=a.patient
                                                              left join procedures_cohort2019_wide b on d.patient=b.patient
                                                              left join procedures_cohort1518_wide c on d.patient=c.patient;
quit;

data procedures_all;
  set procedures_all;
  array proc(*) proc20_: proc19_: proc1518_:;

  do i=1 to dim(proc);
    if proc(i)=. then proc(i)=999;
  end;

  drop _name_ i;
run;

proc freq data=procedures_all;
  table proc19_: proc1518_:;
  label;
run;

data covidnew.SG_procedures_test;
  set procedures_all;
run;
