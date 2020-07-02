
##This is the code to build a Gradient Boosting model for death outcome due to Covid19.;

##set up the path, load the data and load the library

memory.limit(size=10000000)
setwd("P:/ORD_Steinman_201211009D/Bocheng Jing/Data")

library(ape,lib="//vhasfcreap/Bocheng2/R Packages")          # Cluster visualizations
library(caret)        # createDataPartition creates a stratified random split 
library(ck37r)        # impute_missing_values, standardize, SuperLearner helpers
library(dplyr)        # Data cleaning
library(glmnet)       # Lasso 
library(ggplot2)      # Graphics 
library(magrittr)     # Pipes %>% for data cleaning, installed by dplyr
library(mclust)       # Model-based clustering
library(PCAmixdata)   # PCA
library(pROC)         # Compute and plot AUC 
library(pvclust)      # Dendrograms with p-values
library(ranger)       # Random forest algorithm
library(remotes)      # Allows installing packages from github
library(rio)          # Import/export for any filetype.
library(rpart)        # Decision tree algorithm
library(rpart.plot)   # Decision tree plotting
library(SuperLearner) # Ensemble methods
library(xgboost)      # Boosting method
library(vip)          # Variable importance plots
library(randomForest)
library(data.table)
library(rms)
library(epiR)
library(SuperLearner)
library(arm)
library(e1071)
library(cvAUC)
library(ROCR)
library(gplots)
library(HEMDAG)


Covid19_dataset= fread ("P:/ORD_Steinman_201211009D/Bocheng Jing/Data/BJ_train_test_dataset.csv")

## separate outcome with predictors

outcome= (subset(Covid19_dataset, select=c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,death)))

## sparate the continumous predictors
num_var=(subset(Covid19_dataset, select=c(age,obs_2708_6, obs_29463_7,obs_8302_2,obs_8310_5,obs_8462_4,obs_8480_6,obs_8867_4,
                                          obs_DALY,obs_QALY,obs_QOLS)))

train_vet_test=(subset(Covid19_dataset, select=c(train_vet_test)))

## get the character variables and use model matrix to convert;

cha_var=(subset(Covid19_dataset, select=-c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,death,
                                           age,obs_2708_6, obs_29463_7,obs_8302_2,obs_8310_5,obs_8462_4,obs_8480_6,obs_8867_4,
                                           obs_DALY,obs_QALY,obs_QOLS,
                                           train_vet_test, CITY,STATE,COUNTY, HEALTHCARE_EXPENSES, HEALTHCARE_COVERAGE,
                                           healthcare_total,PATIENT)))

## Using the data.matrix to convert all the categorical variables

data_factor=model.matrix(~.,cha_var)[,-1]


##merge numeric variables with factor variables
dataset=cbind(train_vet_test,outcome, num_var, data_factor)


## Split the data into training and testing

data_train=dataset[dataset$train_vet_test==0,]

data_test_holdout=dataset[dataset$train_vet_test==1,]

data_test=dataset[dataset$train_vet_test==2,]

### remove some of the outcomes in the training dataset

data_train_1=(subset(data_train, select=-c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))

data_train_1$death=ifelse(data_train_1$death==1,"Yes","No")

#### now train the data in Gradient Boosting


cv_control =
  trainControl(method = "repeatedcv",
               # Number of folds
               number = 3L,
               # Number of complete sets of folds to compute
               repeats = 2L,
               # Calculate class probabilities?
               classProbs = TRUE,
               # Indicate that our response variable is binary
               summaryFunction = twoClassSummary) 

## set up the hyperparameters of the gradient boosting algorithms
xgb_grid = expand.grid(
  # Number of trees to fit, aka boosting iterations
  nrounds = c( 400,500,600,800,1000),
  # Depth of the decision tree (how many levels of splits).
  max_depth = c(4,5,6,7,8,9,10), 
  # Learning rate: lower means the ensemble will adapt more slowly.
  eta = c(0.01, 0.2),
  # Make this larger and xgboost will tend to make smaller trees
  gamma = 0,
  colsample_bytree = 1.0,
  subsample = 0.8,
  # Stop splitting a tree if we only have this many obs in a tree node.
  min_child_weight = 10L)

# check the number of different combinations of settings do we end up with.
nrow(xgb_grid) ##70 combos


## Fitting in the gradient boosting model
set.seed(31415126)

train.GB.death = caret::train(death ~ ., data =data_train_1, 
                              # Use xgboost's tree-based algorithm (i.e. gbm)
                              method = "xgbTree",
                              # Use "AUC" as our performance metric, which caret incorrectly calls "ROC"
                              metric = "ROC",
                              # Specify our cross-validation settings
                              trControl = cv_control,
                              # Test multiple configurations of the xgboost algorithm
                              tuneGrid = xgb_grid,
                              # Hide detailed output (setting to TRUE will print that output)
                              verbose = FALSE)
#The final values used for the model were nrounds = 800, max_depth = 8, eta = 0.01, gamma = 0, colsample_bytree = 1,
#train.GB.death$results
train.GB.death$times

##    user    system   elapsed 
## 322578.12   5809.92 147460.95

train.GB.death$bestTune
train.GB.death$results[as.integer(rownames(train.GB.death$bestTune)), ]

## Now rerun the best tune model;

xgb_grid_best = expand.grid(
  # Number of trees to fit, aka boosting iterations
  nrounds = 1000,
  # Depth of the decision tree (how many levels of splits).
  max_depth = 5, 
  # Learning rate: lower means the ensemble will adapt more slowly.
  eta = 0.01,
  # Make this larger and xgboost will tend to make smaller trees
  gamma = 0,
  colsample_bytree = 1.0,
  subsample = 0.8,
  # Stop splitting a tree if we only have this many obs in a tree node.
  min_child_weight = 10L)

train.GB.death.best = caret::train(death ~ ., data =data_train_1, 
                              # Use xgboost's tree-based algorithm (i.e. gbm)
                              method = "xgbTree",
                              # Use "AUC" as our performance metric, which caret incorrectly calls "ROC"
                              metric = "ROC",
                              # Specify our cross-validation settings
                              trControl = cv_control,
                              # Test multiple configurations of the xgboost algorithm
                              tuneGrid = xgb_grid_best,
                              # Hide detailed output (setting to TRUE will print that output)
                              verbose = FALSE)

### Now we have the best training model, let's test it.

data_test_1=(subset(data_test_holdout, select=-c(covid_status, covid_hosp,death, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))

test_death=as.factor(data_test_holdout$death)

pred_probs_death = predict(train.GB.death.best, data_test_1, type = "prob")
pred_death_label = predict(train.GB.death.best, data_test_1)

test_death_label=ifelse(data_test_holdout$death==1,"Yes","No")

(rocCurve_death = pROC::roc(response = test_death,
                      predictor = pred_probs_death[, "Yes"],
                      levels = rev(levels(test_death)),
                      auc = TRUE, ci = TRUE))


table(test_death_label,pred_death_label)


summary(epi.tests(table(test_death_label,pred_death_label), conf.level = 0.95))


##now make a table and output it
PATIENT=Covid19_dataset[which(train_vet_test==1),]$PATIENT
death_outcome=data_test_holdout$death

prob_death_yes=pred_probs_death[,2]

prob_death_No=pred_probs_death[,1]

GB.test.holdout.death=data.frame(PATIENT,death_outcome,pred_death_label,prob_death_No,prob_death_yes)

write.csv(GB.test.holdout.death,"P:/ORD_Steinman_201211009D/Bocheng Jing/Document/GB_holdout_probs_death.csv", row.names=TRUE)

## Get the prediction for the training dataset;
data_train_1=(subset(data_train, select=-c(covid_status, covid_hosp,death, covid_niv, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))
train_death=as.factor(data_train$death)

pred_train_death = predict(train.GB.death.best, data_train_1, type = "prob")

(rocCurve_train_death = pROC::roc(response = train_death,
                                         predictor = 
                                    pred_train_death[, "Yes"],
                                         levels = rev(levels(train_death)),
                                         auc = TRUE, ci = TRUE))

##make the table;

BJ_death=pred_train_death[,2]
PATIENT=Covid19_dataset[which(train_vet_test==0),]$PATIENT

GB.train.prob.death=data.frame(PATIENT,BJ_death)

write.csv(GB.train.prob.death,"P:/ORD_Steinman_201211009D/Bocheng Jing/Document/GB_train_probs_death.csv", row.names=TRUE)



#############predict the actual results from the testing dataset
data_test_2=(subset(data_test, select=-c(covid_status, covid_hosp,death, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))
pred_probs_death_act = predict(train.GB.death.best, data_test_2, type = "prob")

PATIENT=Covid19_dataset[which(train_vet_test==2),]$PATIENT

probs_death=pred_probs_death_act[,2]

GB.test.prob.death=data.frame(PATIENT,probs_death)

write.csv(GB.test.prob.death,"P:/ORD_Steinman_201211009D/Bocheng Jing/Document/GB_probs_death.csv", row.names=TRUE)


#/##########################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------#

## Now we try super learner -- an ensemble method 


### Since the data is super unclean, I will use the clean version of the data;
SL_data= fread ("P:/ORD_Steinman_201211009D/Bocheng Jing/Data/Covid19_cohort_cleaned_bj.csv")

## separate outcome with predictors

SL_outcome= (subset(SL_data, select=c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,death)))

## sparate the continumous predictors
SL_num_var=(subset(Covid19_dataset, select=c(age,obs_2708_6, obs_29463_7,obs_8302_2,obs_8310_5,obs_8462_4,obs_8480_6,obs_8867_4,
                                          obs_DALY,obs_QALY,obs_QOLS)))

train_vet_test=(subset(SL_data, select=c(train_vet_test)))

## get the character variables and use model matrix to convert;

SL_cha_var=(subset(SL_data, select=-c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,death,
                                           age,obs_2708_6, obs_29463_7,obs_8302_2,obs_8310_5,obs_8462_4,obs_8480_6,obs_8867_4,
                                           obs_DALY,obs_QALY,obs_QOLS,
                                           train_vet_test,enco20_urgentcare, enco20_urgentcare_cat,PATIENT)))

## Using the data.matrix to convert all the categorical variables

SL_data_factor=model.matrix(~.,SL_cha_var)[,-1]


##merge numeric variables with factor variables
SL_dataset=cbind(train_vet_test,SL_outcome, SL_num_var, SL_data_factor)


## Split the data into training and testing

SL_data_train=dataset[dataset$train_vet_test==0,]

SL_data_test_holdout=dataset[dataset$train_vet_test==1,]

SL_data_test=dataset[dataset$train_vet_test==2,]

### remove some of the outcomes in the training dataset

SL_data_train_1=(subset(SL_data_train, select=-c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))


#1. check the algorithms 

SuperLearner::listWrappers()

sl_lib=c("SL.xgboost","SL.glmnet", "SL.ranger","SL.svm","SL.nnet")

#2. cross validation for the 
death1=SL_data_train_1$death
train_x_class=subset(SL_data_train_1,select=-c(death))

cv_sl_death=
    SuperLearner::CV.SuperLearner(Y=death1, X=train_x_class,
                                  verbose=FALSE,
                                  SL.library=sl_lib,family=binomial(),
                                  method="method.AUC",
                                  cvControl=list(V=3L,stratifyCV=TRUE))
summary(cv_sl_death)

#####################################################################################################################
##### Now the try to merge the training data with testing holdout dataset;


data_train_test=rbind(data_train,data_test_holdout)


### remove some of the outcomes in the training dataset

data_train_test_death=(subset(data_train_test, select=-c(covid_niv,covid_status, covid_hosp, covid_hosp_los, 
                                                         covid_icu, covid_icu_los,train_vet_test)))

data_train_test_death$death=ifelse(data_train_test_death$death==1,"Yes","No")


train_test.GB.death.best = caret::train(death ~ ., data =data_train_test_death, 
                                              # Use xgboost's tree-based algorithm (i.e. gbm)
                                              method = "xgbTree",
                                              # Use "AUC" as our performance metric, which caret incorrectly calls "ROC"
                                              metric = "ROC",
                                              # Specify our cross-validation settings
                                              trControl = cv_control,
                                              # Test multiple configurations of the xgboost algorithm
                                              tuneGrid = xgb_grid_best,
                                              # Hide detailed output (setting to TRUE will print that output)
                                              verbose = FALSE)


## predict the actual death data
data_test_2=(subset(data_test, select=-c(covid_status, covid_hosp,death, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))
pred_probs_death_act = predict(train_test.GB.death.best, data_test_2, type = "prob")

PATIENT=Covid19_dataset[which(train_vet_test==2),]$PATIENT

BJ_death=pred_probs_death_act[,2]

GB.test.prob.death1=data.frame(PATIENT,BJ_death)

write.csv(GB.test.prob.death1,"P:/ORD_Steinman_201211009D/Bocheng Jing/Document/GB_probs_death1.csv", row.names=TRUE)


### predict for all dataset
dataset1=(subset(dataset, select=-c(train_vet_test,covid_status, covid_hosp,death, covid_hosp_los, covid_icu, covid_icu_los, covid_niv,train_vet_test)))
pred_probs_death_overall = predict(train_test.GB.death.best, dataset1, type = "prob")

PATIENT=Covid19_dataset$PATIENT

BJ_death=pred_probs_death_overall[,2]

train_vet_test=Covid19_dataset$train_vet_test

GB.test.prob.death.overall=data.frame(PATIENT,train_vet_test,BJ_death)

write.csv(GB.test.prob.death.overall,"P:/ORD_Steinman_201211009D/Bocheng Jing/Document/GB_probs_death_overall.csv", row.names=TRUE)


# viewing the full list of variable importance
View(vip::vi(train_test.GB.death.best))

