library(data.table) ## good library for fast reading of csv
library(rms) ## Frank Harrells library for RMS book
library(HEMDAG) ## for AUPRC
library(pscl) ## for zinflate

dat <- fread("BJ_train_test_dataset.csv",data.table=FALSE)
table(dat$train_vet_test)
dat$raceCat <- dat$RACE
dat$raceCat[dat$raceCat=="nativ"] <- "other" ## only 80 listed as other so grouping native/other for analysis


dat0 <- dat[dat$train_vet_test==0,-1209] ### save the mini-training set without the test/train column

### look at outcome variables
table(dat0$covid_status) ## 59001
table(dat0$covid_hosp) ## 16273
table(dat0$covid_hosp_los)
table(dat0$covid_icu)  ## 3955
table(dat0$covid_icu_los)
table(dat0$covid_niv) ## 3329

### really ugly way to drop a few variables and make a separate data frame for each outcome that only has the outcome
### and predictors that might be used
#### basically drops by hand-counting the variable numbers a few random variables won't use
names(dat)[1:100]
#  [1] "PATIENT"                   "covid_status"              "covid_hosp"               
#  [4] "covid_hosp_los"            "covid_icu"                 "covid_icu_los"            
#  [7] "covid_niv"                 "death"                     "MARITAL"                  
# [10] "RACE"                      "ETHNICITY"                 "GENDER"                   
# [13] "CITY"                      "STATE"                     "COUNTY"                   
# [16] "HEALTHCARE_EXPENSES"       "HEALTHCARE_COVERAGE"       "healthcare_total"         
# [19] "age"                       "Healthcare_Expenses_quint" "Healthcare_Coverage_quint"
# [22] "healthcare_total_quint"    "enco19_wellness"           "enco19_ambulatory"        
datCovid0 <- dat0[,-c(1,3,4,5,6,7,8,10,13,14,16,17,18,22)]
datHosp0 <-  dat0[,-c(1,2,4,5,6,7,8,10,13,14,16,17,18,22)]
datICU0 <-   dat0[,-c(1,2,3,4,6,7,8,10,13,14,16,17,18,22)]
datNIV0 <-   dat0[,-c(1,2,3,4,5,6,8,10,13,14,16,17,18,22)]
datDeath0 <- dat0[,-c(1,2,3,4,5,6,7,10,13,14,16,17,18,22)]
### did this in case want to do something with automated selection on all the non-outcome variabels

### look at age/gender and age/gender/race/geog/utilization models for each outcome
### lrm automatically knows that the non-continuous variables are factors which is nice!

lrm(covid_status ~ age+GENDER, data=datCovid0)
lrm(covid_status ~ age+raceCat+ETHNICITY+GENDER+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datCovid0)




lrm(covid_hosp ~ age+GENDER, data=datHosp0)
lrm(covid_hosp ~ age+raceCat+ETHNICITY+GENDER+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datHosp0)


lrm(covid_icu ~ age+GENDER, data=datICU0)
lrm(covid_icu ~ age+raceCat+ETHNICITY+GENDER+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datICU0)

lrm(covid_niv ~ age+GENDER, data=datNIV0)
lrm(covid_niv ~ age+raceCat+ETHNICITY+GENDER+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datNIV0)

lrm(death ~ age+GENDER, data=datDeath0)
lrm(death ~ rcs(age,5)*GENDER, data=datDeath0)
dtmp <- lrm(death ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+GENDER+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datDeath0)
dtmp
phat <- predict(dtmp,type='fitted')

AUROC.single.class(datDeath0$death,phat)
AUPRC.single.class(datDeath0$death,phat)
### auprc is fairly low as it leaves out the trueNegatives in each point of curve calculation

#### add way to calibrate probs and make ensemble prediction
rankhat <- rank(phat)  ## make a version of the predicted probabilites that is very uncalibrated!
rankhat <- (rankhat-min(rankhat))/(max(rankhat)-min(rankhat))

AUROC.single.class(datDeath0$death,rankhat)
AUPRC.single.class(datDeath0$death,rankhat)
val.prob(phat,datDeath0$death)
val.prob(rankhat,datDeath0$death)

hist(rankhat)
phatCalib <- predict(lrm(death~rankhat, data=datDeath0),type="fitted")
AUROC.single.class(datDeath0$death,phatCalib)
AUPRC.single.class(datDeath0$death,phatCalib)
val.prob(phatCalib,datDeath0$death)  # this calibration method preserves the AUROC/AUPRC and fixes calibration
### now could average the phatCalib from different models even if their predictions are not well calibrated

### explore models with more predictors


outsingle <- rep(0,ncol(datDeath0)-1)
names(outsingle) <- names(datDeath0)[-1]
varnames <- names(datDeath0)[-1]
for (i in 1:length(outsingle)){
	cat(i)
	rhs <- "rcs(age,5)*GENDER"
	if (!((varnames[i] == 'age') | (varnames[i] == 'GENDER'))){
		rhs <- paste(varnames[i],rhs,sep="+")
	}
	myformula <- as.formula(paste("death ~ ",rhs))
	outtmp <- try(lrm(myformula, data=datDeath0)$stat['C'])
	if(!is.null(outtmp)){
		outsingle[i] <- outtmp
		print(myformula)
	}
}


sort(outsingle-outsingle[5],decr=TRUE)
whichgood <- (1:length(outsingle))[outsingle > .805]
datgood <- cbind(datDeath0[,c('age','GENDER')],datDeath0[,whichgood+1])


vargood <- names(datgood)
### looks like all the proc19 and obs variables might be measuring nearly same thing?
vargood[grep('proc19',vargood)]
apply(datgood[,grep('proc19',vargood)],2,mean) ## all have same mean
min(cor(datgood[,grep('proc19',vargood)])) ### correlated >0.99999

vargood[grep('obs_',vargood)]
apply(datDeath0[,grep('obs_',vargood)],2,mean) ## all have same mean
min(cor(datDeath0[,grep('obs_',vargood)])) ### correlated >0.99999


datDerive <- dat0[,c('death','covid_status','covid_icu','covid_icu_los','covid_hosp','covid_hosp_los','covid_niv',
'age','raceCat','GENDER',"ETHNICITY","COUNTY",
"Healthcare_Expenses_quint",'Healthcare_Coverage_quint',
"enco19_wellness","enco19_outpatient","enco19_urgentcare","enco1518_wellness","enco1518_outpatient",
"proc19_430193006","obs_2708_6","MED_106892_2018","MED_106892_2019","immune_140_2019")]

baseModelCovid <- lrm(covid_status~rcs(age,5)*GENDER, data=datDerive)
AUROC.single.class(datDerive$covid_status,predict(baseModelCovid,type="fitted"))
AUPRC.single.class(datDerive$covid_status,predict(baseModelCovid,type="fitted"))
baseModelDeath <- lrm(death~rcs(age,5)*GENDER, data=datDerive)
AUROC.single.class(datDerive$death,predict(baseModelDeath,type="fitted"))
AUPRC.single.class(datDerive$death,predict(baseModelDeath,type="fitted"))
baseModelHosp <- lrm(covid_hosp~rcs(age,5)*GENDER, data=datDerive)
AUROC.single.class(datDerive$covid_hosp,predict(baseModelHosp,type="fitted"))
AUPRC.single.class(datDerive$covid_hosp,predict(baseModelHosp,type="fitted"))
baseModelICU <- lrm(covid_icu~rcs(age,5)*GENDER, data=datDerive)
AUROC.single.class(datDerive$covid_icu,predict(baseModelICU,type="fitted"))
AUPRC.single.class(datDerive$covid_icu,predict(baseModelICU,type="fitted"))
baseModelNIV <- lrm(covid_niv~rcs(age,5)*GENDER, data=datDerive)
AUROC.single.class(datDerive$covid_niv,predict(baseModelNIV,type="fitted"))
AUPRC.single.class(datDerive$covid_niv,predict(baseModelNIV,type="fitted"))



smallModelCovid <- lrm(covid_status~rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
#smallModelCovid
#val.prob(predict(smallModelCovid,type="fitted"),datDerive$covid_status)
AUROC.single.class(datDerive$covid_status,predict(smallModelCovid,type="fitted"))
AUPRC.single.class(datDerive$covid_status,predict(smallModelCovid,type="fitted"))

smallModelDeath <- lrm(death~rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
#smallModelDeath
#val.prob(predict(smallModelDeath,type="fitted"),datDerive$death)
AUROC.single.class(datDerive$death,predict(smallModelDeath,type="fitted"))
AUPRC.single.class(datDerive$death,predict(smallModelDeath,type="fitted"))

smallModelHosp <- lrm(covid_hosp~rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
#smallModelHosp
#val.prob(predict(smallModelHosp,type="fitted"),datDerive$covid_hosp)
AUROC.single.class(datDerive$covid_hosp,predict(smallModelHosp,type="fitted"))
AUPRC.single.class(datDerive$covid_hosp,predict(smallModelHosp,type="fitted"))

smallModelICU <- 
lrm(covid_icu ~rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
#smallModelICU
#val.prob(predict(smallModelICU,type="fitted"),datDerive$covid_icu)
AUROC.single.class(datDerive$covid_icu,predict(smallModelICU,type="fitted"))
AUPRC.single.class(datDerive$covid_icu,predict(smallModelICU,type="fitted"))

smallModelNIV<- lrm(covid_niv~rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
#smallModelCovid
#val.prob(predict(smallModelCovid,type="fitted"),datDerive$covid_niv)
AUROC.single.class(datDerive$covid_niv,predict(smallModelNIV,type="fitted"))
AUPRC.single.class(datDerive$covid_niv,predict(smallModelNIV,type="fitted"))


#### Now do zero-inflated models for lengths of stay
### first Hospital Days

smallModelHospDays <- 
zeroinfl(covid_hosp_los ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
summary(smallModelHospDays)

### calculate RMSE between predicted and actual days.  not sure if do this in all patients or
### just ones with a hospital/icu stay

rmse <- function(yhat,y,which=NULL){
	if (!is.null(which)){
		y <- y[which]
		yhat <- yhat[which]
	}
	return(sqrt(mean((y-yhat)^2)))
}

rmse(predict(smallModelHospDays,type="response"),datDerive$covid_hosp_los,)
mean(datDerive$covid_hosp_los)
rmse(rep(3.2289,nrow(datDerive)),datDerive$covid_hosp_los) # null model
### model brings down overall RMSE from 6.28 to 6.15

rmse(predict(smallModelHospDays,type="count"),datDerive$covid_hosp_los,datDerive$covid_hosp==1)
mean(datDerive$covid_hosp_los[datDerive$covid_hosp_los>0])
rmse(rep(13.64,nrow(datDerive)),datDerive$covid_hosp_los,datDerive$covid_hosp==1) # null model
### model brings down RMSE in those hospitalzied from 4.96 to 4.51
rmse(predict(smallModelHospDays,type="response"),datDerive$covid_hosp_los,datDerive$covid_hosp==1)
#### RMSE is 11.14 if use overall predictions but get judged just in hospitalized


### now do ICU DAYS

smallModelICUDays <- 
zeroinfl(covid_icu_los ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint+
enco19_wellness+enco19_outpatient+enco19_urgentcare+enco1518_wellness+enco1518_outpatient+
proc19_430193006+obs_2708_6+MED_106892_2018+MED_106892_2019+immune_140_2019, data=datDerive)
summary(smallModelICUDays)

rmse(predict(smallModelICUDays,type="response"),datDerive$covid_icu_los)
mean(datDerive$covid_icu_los)
rmse(rep(0.41406,nrow(datDerive)),datDerive$covid_icu_los) # null model
### model brings down overall RMSE from 1.8 to 0.41


rmse(predict(smallModelICUDays,type="count"),datDerive$covid_icu_los,datDerive$covid_icu==1)
mean(datDerive$covid_icu_los[datDerive$covid_icu_los>0])
rmse(rep(7.198,nrow(datDerive)),datDerive$covid_icu_los,datDerive$covid_icu==1) # null model
### model brings down RMSE in those hospitalzied from 2.78 to 2.57
rmse(predict(smallModelICUDays,type="response"),datDerive$covid_icu_los,datDerive$covid_icu==1)
#### RMSE is 6.94 if use overall predictions but get judged just in hospitalized

#### need to do above on basemodel also


#### below here discusses adding way to use predicted output from non regression model 
#### to make predictions using zinb or zinp

lrmhosp <- lrm(covid_hosp ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data=datHosp0)
phathosp <- predict(lrmhosp,type='fitted')
zhathosp <- zeroinfl(covid_hosp_los ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data = dat0)

zhathosp2 <- zeroinfl(covid_hosp_los ~ phathosp, data = data.frame(dat0,phathosp=phathosp))
zhathosp3 <- zeroinfl(covid_hosp_los ~ phathosp+age, data = data.frame(dat0,phathosp=phathosp))
yhathosp <- predict(ols(covid_hosp_los ~ rcs(age,5)*GENDER+raceCat+ETHNICITY+COUNTY+Healthcare_Expenses_quint+Healthcare_Coverage_quint, data = dat0))



dzhathospGT0 <- predict(zhathosp,type='count')
pzhathosp0 <- predict(zhathosp,type='prob')[,1]
fzhathosp1 <- predict(zhathosp,type='response')
fzhathosp2 <- predict(zhathosp2,type='response')
fzhathosp3 <- predict(zhathosp3,type='response')

summary(fzhathosp1  - (1-pzhathosp0)*dzhathospGT0)  # they are the same

summary(fzhathosp1)
plot(fzhathosp1,fzhathosp3)

rmse(fzhathosp1,dat0$covid_hosp_los)
rmse(fzhathosp2,dat0$covid_hosp_los)
rmse(fzhathosp3,dat0$covid_hosp_los)
rmse(phathosp,dat0$covid_hosp_los)
rmse(yhathosp,dat0$covid_hosp_los)
rmse(fzhathosp1,dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(fzhathosp2,dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(fzhathosp3,dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(phathosp,dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(yhathosp,dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(rep(13.64,length(yhathosp)),dat0$covid_hosp_los,dat0$covid_hosp==1)
rmse(dzhathospGT0,dat0$covid_hosp_los,dat0$covid_hosp==1)


