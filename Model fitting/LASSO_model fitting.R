
library ("foreign", lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("risksetROC", lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("Matrix", lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("data.table", lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("foreach", lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("glmnet", lib="//vhasfcreap/Sun/SEI_IIR/R packages")

library ("PRROC",  lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("qpcR",  lib="//vhasfcreap/Sun/SEI_IIR/R packages")
library ("rowr",  lib="//vhasfcreap/Sun/SEI_IIR/R packages")

data_0 = read.csv("//vhasfcreap/bocheng2/Covid19_challenge/Data_cleaned2/BJ_train_test_dataset.csv")

### VAR exploration
dim(data_0)
var_names = names(data_0)

### TRAINING DATA ####

outcome = subset(data_0, select = c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv, death, train_vet_test))
predictor_0 = subset(data_0, select = -c(covid_status, covid_hosp, covid_hosp_los, covid_icu, covid_icu_los, covid_niv, death))


predictor_cont = subset(predictor_0, select = c(enco19_wellness, enco19_ambulatory, 
                                                enco19_outpatient, enco19_urgentcare, enco19_inpatient, enco19_emergency,
                                                enco1518_wellness, enco1518_ambulatory, enco1518_outpatient, enco1518_inpatient,
                                                enco1518_emergency, enco1518_urgentcare, age, HEALTHCARE_EXPENSES, 
                                                HEALTHCARE_COVERAGE, healthcare_total, 
                                                obs_2708_6, obs_29463_7, obs_8302_2, obs_8310_5, obs_8462_4, obs_8480_6, 
                                                obs_8867_4, obs_DALY, obs_QALY, obs_QOLS
))

predictor_cat = subset(predictor_0, select = -c(train_vet_test, PATIENT, enco19_wellness, enco19_ambulatory, 
                                                enco19_outpatient, enco19_urgentcare, enco19_inpatient, enco19_emergency,
                                                enco1518_wellness, enco1518_ambulatory, enco1518_outpatient, enco1518_inpatient,
                                                enco1518_emergency, enco1518_urgentcare, age, HEALTHCARE_EXPENSES, 
                                                HEALTHCARE_COVERAGE, healthcare_total, 
                                                obs_2708_6, obs_29463_7, obs_8302_2, obs_8310_5, obs_8462_4, obs_8480_6, 
                                                obs_8867_4, obs_DALY, obs_QALY, obs_QOLS, 
                                                STATE, proc1518_40701008, proc1518_232717009, proc1518_265764009, proc1518_410006001, proc1518_415070008, proc1518_430193006, 
                                                proc1518_15081005, proc1518_127783003, proc1518_73761001, proc1518_703423002, proc1518_399208008, proc1518_433236007, proc1518_434158009, 
                                                proc1518_18286008, proc1518_180325003, proc1518_35025007, proc1518_71651007, proc1518_90226004, proc1518_447365002, proc1518_23426006,  
                                                proc1518_19490002, proc1518_274474001, proc1518_312681000, proc1518_433112001, proc1518_117015009, proc1518_65575008, proc1518_90470006,  
                                                proc1518_76601001, proc1518_169553002, proc1518_398171003, proc1518_288086009, proc1518_384700001, proc1518_269911007, proc1518_104435004, 
                                                proc1518_274031008, proc1518_287664005, proc1518_311791003, proc1518_33195004, proc1518_122548005, proc1518_241055006, proc1518_392021009, 
                                                proc1518_433114000, proc1518_434363004, proc1518_74016001, proc1518_168594001, proc1518_305428000, proc1518_43075005, proc1518_76164006,  
                                                proc1518_60027007, proc1518_46706006, proc1518_1225002, proc1518_268425006, proc1518_14768001, proc1518_162676008, proc1518_301807007, 
                                                proc1518_415300000, proc1518_698354004, proc1518_418891003, proc1518_432231006, proc1518_91602002, proc1518_167995008, proc1518_699253003, 
                                                proc1518_54550000, proc1518_225337009, proc1518_385892002, proc1518_715252007, proc1518_5880005, proc1518_28163009, proc1518_31676001,  
                                                proc1518_44608003, proc1518_47758006, proc1518_66348005, proc1518_104091002, proc1518_104326007, proc1518_104375008, proc1518_117010004, 
                                                proc1518_118001005, proc1518_165829005, proc1518_167271000, proc1518_169230002, proc1518_169690007, proc1518_225158009, proc1518_252160004, 
                                                proc1518_268556000, proc1518_269828009, proc1518_271442007, proc1518_274804006, proc1518_275833003, proc1518_310861008, proc1518_395123002, 
                                                proc1518_399014008, proc1518_443529005, proc1518_173160006, proc1518_24623002, proc1518_241615005, proc1518_65546002, proc1518_171207006, 
                                                proc1518_31208007, proc1518_65200003, proc1518_69031006, proc1518_234262008, proc1518_367336001, proc1518_43060002, proc1518_396487001, 
                                                proc1518_443497002, proc1518_429609002, proc1518_305433001, proc1518_51116004, proc1518_10383002, proc1518_386394001, proc1518_714812005, 
                                                proc1518_29303009, proc1518_45595009, proc1518_52765003, proc1518_22523008, MED_1049630_2018, MED_1049635_2018, MED_105078_2018,    
                                                MED_1091392_2018, MED_1100184_2018, MED_1114085_2018, MED_1190795_2018, MED_1234995_2018, MED_1359133_2018, MED_1363309_2018,   
                                                MED_1366343_2018, MED_141918_2018, MED_1601380_2018, MED_1652673_2018, MED_1659263_2018, MED_1660014_2018, MED_1665227_2018,   
                                                MED_1723208_2018, MED_1729584_2018, MED_1732136_2018, MED_1732186_2018, MED_1734340_2018, MED_1734919_2018, MED_1735006_2018,   
                                                MED_1736854_2018, MED_1737449_2018, MED_1740467_2018, MED_1790099_2018, MED_1791701_2018, MED_1804799_2018, MED_1808217_2018,   
                                                MED_1809104_2018, MED_1873983_2018, MED_1946840_2018, MED_197319_2018, MED_197378_2018, MED_197541_2018, MED_198240_2018,    
                                                MED_198405_2018, MED_198767_2018, MED_199224_2018, MED_200064_2018, MED_205532_2018, MED_205923_2018, MED_2119714_2018,   
                                                MED_235389_2018, MED_243670_2018, MED_259255_2018, MED_308182_2018, MED_308192_2018, MED_309043_2018, MED_309045_2018,    
                                                MED_309097_2018, MED_310261_2018, MED_311700_2018, MED_311995_2018, MED_312615_2018, MED_312617_2018, MED_313002_2018,    
                                                MED_313185_2018, MED_313820_2018, MED_477045_2018, MED_542347_2018, MED_583214_2018, MED_597195_2018, MED_665078_2018,    
                                                MED_727762_2018, MED_749785_2018, MED_749882_2018, MED_789980_2018, MED_833036_2018, MED_834061_2018, MED_834102_2018,    
                                                MED_834357_2018, MED_993452_2018, MED_996740_2018, MED_997223_2018, MED_997488_2018, MED_1049630_2019, MED_1049635_2019,   
                                                MED_105078_2019, MED_1091392_2019, MED_1100184_2019, MED_1359133_2019, MED_1363309_2019, MED_1366343_2019, MED_141918_2019,    
                                                MED_1652673_2019, MED_1665227_2019, MED_1737449_2019, MED_197378_2019, MED_198405_2019, MED_198767_2019, MED_205532_2019,    
                                                MED_235389_2019, MED_243670_2019, MED_308182_2019, MED_309043_2019, MED_309045_2019, MED_313185_2019, MED_313572_2019,    
                                                MED_313820_2019, MED_477045_2019, MED_665078_2019, MED_749785_2019, MED_749882_2019, MED_789980_2019, MED_834061_2019,    
                                                MED_996740_2019, MED_997223_2019, MED_997488_2019, obs_10230_1_2018, obs_10480_2_2018, obs_10834_0_2018, obs_14959_1_2018,   
                                                obs_1742_6_2018, obs_1751_7_2018, obs_17861_6_2018, obs_18262_6_2018, obs_1920_8_2018, obs_1975_2_2018, obs_19926_5_2018,   
                                                obs_2028_9_2018, obs_20454_5_2018, obs_20505_4_2018, obs_20565_8_2018, obs_20570_8_2018, obs_2069_3_2018, obs_2075_0_2018,    
                                                obs_2085_9_2018, obs_2093_3_2018, obs_21000_5_2018, obs_2160_0_2018, obs_21905_5_2018, obs_21906_3_2018, obs_21907_1_2018,   
                                                obs_21908_9_2018, obs_21924_6_2018, obs_2339_0_2018, obs_2345_7_2018, obs_2514_8_2018, obs_25428_4_2018, obs_2571_8_2018,    
                                                obs_26453_1_2018, obs_26464_8_2018, obs_26515_7_2018, obs_2823_3_2018, obs_28245_9_2018, obs_2857_1_2018, obs_2885_2_2018,    
                                                obs_2947_0_2018, obs_2951_2_2018, obs_3016_3_2018, obs_3024_7_2018, obs_30385_9_2018, obs_30428_7_2018, obs_3094_0_2018,    
                                                obs_32167_9_2018, obs_32207_3_2018, obs_32465_7_2018, obs_32623_1_2018, obs_33037_3_2018, obs_33728_7_2018, obs_33756_8_2018,   
                                                obs_33762_6_2018, obs_33914_3_2018, obs_38265_5_2018, obs_38483_4_2018, obs_4171810_2018, obs_42719_5_2018, obs_44667_4_2018,   
                                                obs_4544_3_2018, obs_4548_4_2018, obs_46240_8_2018, obs_46288_7_2018, obs_49765_1_2018, obs_55277_8_2018, obs_5767_9_2018,    
                                                obs_5770_3_2018, obs_5778_6_2018, obs_57905_2_2018, obs_5792_7_2018, obs_5794_3_2018, obs_5797_6_2018, obs_5799_2_2018,    
                                                obs_5802_4_2018, obs_5803_2_2018, obs_5804_0_2018, obs_5811_5_2018, obs_59557_9_2018, obs_59576_9_2018, obs_6075_6_2018,    
                                                obs_6082_2_2018, obs_6085_5_2018, obs_6095_4_2018, obs_6106_9_2018, obs_6158_0_2018, obs_6189_5_2018, obs_6206_7_2018,    
                                                obs_6246_3_2018, obs_6248_9_2018, obs_6273_7_2018, obs_6276_0_2018, obs_6298_4_2018, obs_6299_2_2018, obs_63513_6_2018,   
                                                obs_66519_0_2018, obs_66524_0_2018, obs_66529_9_2018, obs_66534_9_2018, obs_6690_2_2018, obs_6768_6_2018, obs_6833_8_2018,    
                                                obs_6844_5_2018, obs_69453_9_2018, obs_71802_3_2018, obs_718_7_2018, obs_71970_8_2018, obs_71972_4_2018, obs_72009_4_2018,   
                                                obs_72010_2_2018, obs_72011_0_2018, obs_72012_8_2018, obs_72013_6_2018, obs_72014_4_2018, obs_72015_1_2018, obs_72016_9_2018,   
                                                obs_72093_8_2018, obs_72094_6_2018, obs_72095_3_2018, obs_72096_1_2018, obs_72097_9_2018, obs_72106_8_2018, obs_7258_7_2018,    
                                                obs_74006_8_2018, obs_75443_2_2018, obs_76690_7_2018, obs_77606_2_2018, obs_777_3_2018, obs_785_6_2018, obs_786_4_2018,     
                                                obs_787_2_2018, obs_789_8_2018, obs_80271_0_2018, obs_84215_3_2018, obs_85318_4_2018, obs_85319_2_2018, obs_85337_4_2018,   
                                                obs_85339_0_2018, obs_85343_2_2018, obs_85344_0_2018, obs_85352_3_2018, obs_88040_1_2018, obs_9279_1_2018, obs_9843_4_2018,    
                                                obs_59576_9_2019, obs_69453_9_2019, obs_77606_2_2019, obs_9843_4_2019, immune_10_2018, immune_113_2018, immune_114_2018,    
                                                immune_115_2018, immune_121_2018, immune_133_2018, immune_140_2018, immune_20_2018, immune_21_2018, immune_3_2018,      
                                                immune_33_2018, immune_43_2018, immune_49_2018, immune_52_2018, immune_62_2018, immune_8_2018, immune_83_2018,     
                                                immune_10_2019, immune_115_2019, immune_20_2019, immune_21_2019, immune_3_2019, immune_49_2019, immune_62_2019,     
                                                immune_8_2019, immune_83_2019
))



col_names = names(predictor_cat)
predictor_cat[,col_names] = lapply(predictor_cat [,col_names], factor)
cat_levels=sapply(predictor_cat, levels)
# n_levels = lapply(cat_levels, length)
# single_level = names(which(n_levels==1))
# 
# multiple_level = names(which(n_levels==1))
# x=n_levels[n_levels>=3]


which(cat_levels)
str(predictor_cat)

predictor_1 = cbind(predictor_cont, predictor_cat, data_0$train_vet_test)
predictor.mx = model.matrix( ~ ., predictor_1)[, -1]

predictor.mx.train = predictor.mx[predictor.mx[,"`data_0$train_vet_test`"]<2, -ncol(predictor.mx_0) ]
predictor.mx.vet = predictor.mx[predictor.mx[,"`data_0$train_vet_test`"]==1, -ncol(predictor.mx_0) ]
predictor.mx.test = predictor.mx[predictor.mx[,"`data_0$train_vet_test`"]==2, -ncol(predictor.mx_0) ]
predictor.mx.all = predictor.mx[, -ncol(predictor.mx_0)]

outcome_train = outcome[outcome[,"train_vet_test"]<2, ]
outcome_vet = outcome[outcome[,"train_vet_test"]==1, ]
outcome_test = outcome[outcome[,"train_vet_test"]==2, ]


##DEATH PREDICTION

tic()
cvfit_death10 <- cv.glmnet(y=outcome_train$death, x=predictor.mx.train, family="binomial", nfold=3)
toc()
tic()
cvfit_vent10 <- cv.glmnet(y=outcome_train$covid_niv, x=predictor.mx.train, family="binomial", nfold=3)
toc()
tic()
cvfit_icu10 <- cv.glmnet(y=outcome_train$covid_icu, x=predictor.mx.train, family="binomial", nfold=3)
toc()
tic()
cvfit_hosp10 <- cv.glmnet(y=outcome_train$covid_hosp, x=predictor.mx.train, family="binomial", nfold=3)
toc()
# tic()
# cvfit_iculos10 <- cv.glmnet(y=outcome_train$covid_icu_los, x=predictor.mx.train, family="gaussian", nfold=3)
# toc()
# tic()
# cvfit_hosplos10 <- cv.glmnet(y=outcome_train$covid_hosp_los, x=predictor.mx.train, family="gaussian", nfold=3)
# toc()
tic()
cvfit_covid <- cv.glmnet(y=outcome_train$covid_status, x=predictor.mx.train, family="binomial", nfold=3)
toc()

## VAR
cvfit = cvfit_death10
cvfit = cvfit_vent10
cvfit = cvfit_icu10
cvfit = cvfit_hosp10
cvfit = cvfit_covid


outcome_obs = outcome$death
outcome_obs = outcome$covid_niv
outcome_obs = outcome$covid_icu
outcome_obs = outcome$covid_hosp
outcome_obs = outcome$covid_status
# 
# outcome_obs = outcome_vet$death
# outcome_obs = outcome_vet$covid_niv
# outcome_obs = outcome_vet$covid_icu
# outcome_obs = outcome_vet$covid_hosp
# outcome_obs = outcome_vet$covid_status

glmnet.obj <- cvfit$glmnet.fit 
optimal.lambda = cvfit$lambda.1se
lambda.index = which(glmnet.obj$lambda==optimal.lambda)
optimal.beta  <- glmnet.obj$beta[,lambda.index]
nonzero.coef <- abs(optimal.beta)>0 ##
selectedBeta <- optimal.beta[nonzero.coef] ## 206 var
length(selectedBeta)
selectedBeta[selectedBeta<0]

## ALL 
pred.death = predict(cvfit, predictor.mx.all, s=optimal.lambda, type=c("response"))
pred.niv = predict(cvfit, predictor.mx.all, s=optimal.lambda, type=c("response"))
pred.icu = predict(cvfit, predictor.mx.all, s=optimal.lambda, type=c("response"))
pred.hosp = predict(cvfit, predictor.mx.all, s=optimal.lambda, type=c("response"))
pred.status= predict(cvfit, predictor.mx.all, s=optimal.lambda, type=c("response"))

pred.all = data.frame(data_0[,1], outcome, pred.death, pred.niv, pred.icu, pred.hosp, pred.status)
colnames(pred.all) = c("Patient", "covid_status", "covid_hosp", "covid_hosp_los", "covid_icu", "covid_icu_los", "covid_niv", "death", "train_vet_test",
                       "pred.death", "pred.niv", "pred.icu", "pred.hosp", "pred.status")
write.dta(pred.all, "//vhasfcreap/sun/COVID project/data/0701 obs_pred.dta")
write.csv(pred.all, "//vhasfcreap/sun/COVID project/data/0701 SJ_LASSO.csv")

pred.train = pred.all[pred.all$train_vet_test<2,]
auc(pred.train$death, pred.train$pred.death)
auc(pred.train$covid_niv, pred.train$pred.niv)
auc(pred.train$covid_icu, pred.train$pred.icu)
auc(pred.train$covid_hosp, pred.train$pred.hosp)
auc(pred.train$covid_status, pred.train$pred.status)

fg <- pred.train$pred.icu[pred.train$covid_icu == 1]
bg <- pred.train$pred.icu[pred.train$covid_icu== 0]
pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)

fg <- pred.train$pred.death[pred.train$death == 1]
bg <- pred.train$pred.death[pred.train$death == 0]
pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)

fg <- pred.train$pred.status[pred.train$covid_status == 1]
bg <- pred.train$pred.status[pred.train$covid_status== 0]
pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)

fg <- pred.train$pred.niv[pred.train$covid_niv == 1]
bg <- pred.train$pred.niv[pred.train$covid_niv== 0]
pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)

fg <- pred.train$pred.hosp[pred.train$covid_hosp == 1]
bg <- pred.train$pred.hosp[pred.train$covid_hosp== 0]
pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)
