### THIS SCRIPT READS IN THE PREDICTION FILE AND THE CLEAN DATA FILE 
### USES PREDICTED HOSP/ICU BINARY PROBS  AND OTHER COVS TO MODEL COUNT OF HOSP_LOS ICU_LOS
### USES MULTIPLE MODEL PREDICTIONS TO PRODUCE ENSEMBLE LOS PREDICTIONS
### TAKES PREDICTED DEATH/COVID/NIV PROBS OF VARIOUS MODELS, CALIBRATES, AVERAGES TO PRODUCE ENSEMBLE PROBS


library(data.table) ## good library for fast reading of csv
library(rms) ## Frank Harrells library for RMS book
library(HEMDAG) ## for AUPRC
library(pscl) ## for zinflate


allpred <- fread("covid19_all_prediction_final_07022020.csv",data.table=FALSE)
allpred <- allpred[order(allpred$PATIENT),]

dat <- fread("Covid19_cohort_cleaned_bj.csv",data.table=FALSE)
dat <- dat[order(dat$PATIENT),]
table(allpred$PATIENT == dat$PATIENT)

for(vname in c('age','GENDER','obs_2708_6','obs_8310_5',
	'obs_8867_4','enco1518_wellness','enco1518_outpatient_cat','obs_14959_1_2019',
	'enco19_urgentcare_cat','enco19_ambulatory_cat','enco19_inpatient_cat','immune_140_2019')){
		print(vname)
		print(grep(vname,names(dat)))
	}

allpred <- cbind(allpred, dat[,c('covid_status','covid_hosp','covid_hosp_los',
	'covid_icu','covid_icu_los','covid_niv','death',
	'age','GENDER','obs_2708_6','obs_8310_5',
	'obs_8867_4','enco1518_wellness','enco1518_outpatient_cat','obs_14959_1_2019',
	'enco19_urgentcare_cat','enco19_ambulatory_cat','enco19_inpatient_cat','immune_140_2019')])  
names(allpred)


#### Now do zero-inflated models for lengths of stay

### calculate RMSE between predicted and actual days.  not sure if do this in all patients or
### just ones with a hospital/icu stay

rmse <- function(yhat,y,which=NULL){
	if (!is.null(which)){
		y <- y[which]
		yhat <- yhat[which]
	}
	return(sqrt(mean((y-yhat)^2)))
}

### Hospital Days
gbHospDays <- 
zeroinfl(covid_hosp_los ~ BJ_hosp + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(gbHospDays)
write.csv(file="ucsf_pepper_1_covid_hosp_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_hosp_los=predict(gbHospDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)

rfHospDays <- 
zeroinfl(covid_hosp_los ~ SG_hosp + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(rfHospDays)
write.csv(file="ucsf_pepper_2_covid_hosp_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_hosp_los=predict(rfHospDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)
		
enHospDays <- 
zeroinfl(covid_hosp_los ~ BJ_hosp + SG_hosp + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(enHospDays)
write.csv(file="ucsf_pepper_3_covid_hosp_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_hosp_los=predict(enHospDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)
		
rmse(predict(gbHospDays,newdata=allpred,type="response"),allpred$covid_hosp_los,(allpred$train_vet_test)<2)
rmse(predict(rfHospDays,newdata=allpred,type="response"),allpred$covid_hosp_los,(allpred$train_vet_test)<2)
rmse(predict(enHospDays,newdata=allpred,type="response"),allpred$covid_hosp_los,(allpred$train_vet_test)<2)

### ICU Days
gbICUDays <- 
zeroinfl(covid_icu_los ~ BJ_icu + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(gbICUDays)
write.csv(file="ucsf_pepper_1_covid_icu_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_icu_los=predict(gbICUDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)

rfICUDays <- 
zeroinfl(covid_icu_los ~ SG_icu + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(rfICUDays)
write.csv(file="ucsf_pepper_2_covid_icu_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_icu_los=predict(rfICUDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)

enICUDays <- 
zeroinfl(covid_icu_los ~ BJ_hosp + SG_icu + rcs(age,5)*GENDER+obs_2708_6+obs_8310_5+
	obs_8867_4+enco1518_wellness+enco1518_outpatient_cat+obs_14959_1_2019+
	enco19_urgentcare_cat+enco19_ambulatory_cat+enco19_inpatient_cat+immune_140_2019, data=allpred)
summary(enICUDays)
write.csv(file="ucsf_pepper_3_covid_icu_los.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_icu_los=predict(enICUDays,newdata=allpred,type="response"))[allpred$train_vet_test==2,],row.names=FALSE)

rmse(predict(gbICUDays,newdata=allpred,type="response"),allpred$covid_icu_los,(allpred$train_vet_test)<2)
rmse(predict(rfICUDays,newdata=allpred,type="response"),allpred$covid_icu_los,(allpred$train_vet_test)<2)
rmse(predict(enICUDays,newdata=allpred,type="response"),allpred$covid_icu_los,(allpred$train_vet_test)<2)


#### ensemble binary probs

roccomp <- function(p1,p2,p3,y,which){
	print(AUROC.single.class(y[which],p1[which]))
	print(AUROC.single.class(y[which],p2[which]))
	print(AUROC.single.class(y[which],p3[which]))
	
}

gbCalCovid <- predict(lrm(covid_status~BJ_covid_status, data=allpred),newdata=allpred,type="fitted")
rfCalCovid <- predict(lrm(covid_status~SG_covid_status, data=allpred),newdata=allpred,type="fitted")
enCovid <- (gbCalCovid+rfCalCovid)/2
roccomp(gbCalCovid,rfCalCovid,enCovid,allpred$train_vet_test<2)

gbCalDeath <- predict(lrm(death~BJ_death, data=allpred),newdata=allpred,type="fitted")
rfCalDeath <- predict(lrm(death~SG_death, data=allpred),newdata=allpred,type="fitted")
enDeath <- (gbCalDeath+rfCalDeath)/2
roccomp(gbCalDeath,rfCalDeath,enDeath,allpred$train_vet_test<2)

gbCalNIV <- predict(lrm(covid_niv~BJ_niv, data=allpred),newdata=allpred,type="fitted")
rfCalNIV <- predict(lrm(covid_niv~SG_niv, data=allpred),newdata=allpred,type="fitted")
enNIV <- (gbCalNIV+rfCalNIV)/2
roccomp(gbCalNIV,rfCalNIV,enNIV,allpred$train_vet_test<2)

write.csv(file="ucsf_pepper_3_covid_status.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_status=enCovid)[allpred$train_vet_test==2,],row.names=FALSE)

write.csv(file="ucsf_pepper_3_death.csv",
	data.frame(PATIENT=allpred$PATIENT,
		death=enDeath)[allpred$train_vet_test==2,],row.names=FALSE)


write.csv(file="ucsf_pepper_3_covid_niv.csv",
	data.frame(PATIENT=allpred$PATIENT,
		covid_niv=enNIV)[allpred$train_vet_test==2,],row.names=FALSE)







