library(data.table) ## good library for fast reading of csv
library(rms) ## Frank Harrells library for RMS book
library(HEMDAG) ## for AUPRC
library(pscl) ## for zinflate



allpred <- fread("covid19_prediction.csv",data.table=FALSE)
allpred <- allpred[order(allpred$Patient),]

dat <- fread("Covid19_cohort_cleaned_bj.csv",data.table=FALSE)
dat <- dat[order(dat$PATIENT),]
table(allpred$Patient == dat$PATIENT)

allpred <- cbind(allpred,dat[,c('age','GENDER')])


pred0 <- allpred[allpred$train_vet_test==0,]
pred1 <- allpred[allpred$train_vet_test==1,]
pred2 <- allpred[allpred$train_vet_test==2,]


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

rfHospDays <- 
zeroinfl(covid_hosp_los ~ SG_hosp + rcs(age,5)*GENDER, data=pred0)
summary(rfHospDays)

rmse(predict(rfHospDays,type="response"),pred0$covid_hosp_los)
mean(pred0$covid_hosp_los)
rmse(rep(mean(pred0$covid_hosp_los),nrow(pred0)),pred0$covid_hosp_los) # null model
### model brings down overall RMSE from 6.28 to 1.89

rmse(predict(rfHospDays,type="count"),pred0$covid_hosp_los,pred0$covid_hosp==1)
mean(pred0$covid_hosp_los[pred0$covid_hosp_los>0])
rmse(rep(mean(pred0$covid_hosp_los[pred0$covid_hosp_los>0]),  nrow(pred0)),pred0$covid_hosp_los,pred0$covid_hosp==1) 
# null model
### model brings down RMSE in those hospitalzied from 4.96 to 3.74

rmse(predict(rfHospDays,type="response"),pred0$covid_hosp_los,pred0$covid_hosp==1)
#### RMSE is 3.79 if use overall predictions but get judged just in hospitalized



### ICU Days

rfICUDays <- 
zeroinfl(covid_icu_los ~ SG_icu + rcs(age,5)*GENDER, data=pred0)
summary(rfICUDays)

rmse(predict(rfICUDays,type="response"),pred0$covid_icu_los)
mean(pred0$covid_icu_los)
rmse(rep(mean(pred0$covid_icu_los),nrow(pred0)),pred0$covid_icu_los) # null model
### model brings down overall RMSE from 1.80 to 0.88

rmse(predict(rfICUDays,type="count"),pred0$covid_icu_los,pred0$covid_icu==1)
mean(pred0$covid_icu_los[pred0$covid_icu_los>0])
rmse(rep(mean(pred0$covid_icu_los[pred0$covid_icu_los>0]),  nrow(pred0)),pred0$covid_icu_los,pred0$covid_icu==1) 
# null model
### model brings down RMSE in those ICU'd from 2.78 to 2.66

rmse(predict(rfICUDays,type="response"),pred0$covid_icu_los,pred0$covid_icu==1)
#### RMSE is 3.09 if use overall predictions but get judged just in ICU'd


#### get predictions at all values
predRF <- data.frame(Patient=allpred$Patient, rfHospNonZero = predict(rfHospDays,allpred,type="count"), 
	rfHospResponse = predict(rfHospDays,allpred,type="response"),
	rfICUNonZero = predict(rfICUDays,allpred,type="count"), 
	rfICUResponse = predict(rfICUDays,allpred,type="response"))

#### check predictions for vet set
rmse(predRF$rfHospResponse,allpred$covid_hosp_los,which=(allpred$train_vet_test==1))
rmse(predRF$rfHospNonZero,allpred$covid_hosp_los,which=(allpred$train_vet_test==1) & (allpred$covid_hosp_los > 0)& !is.na(allpred$covid_hosp_los))

rmse(predRF$rfICUResponse,allpred$covid_icu_los,which=(allpred$train_vet_test==1))
rmse(predRF$rfICUNonZero,allpred$covid_icu_los,which=(allpred$train_vet_test==1) & (allpred$covid_icu_los > 0)& !is.na(allpred$covid_icu_los))

write.csv(file="predRF.csv",predRF)


