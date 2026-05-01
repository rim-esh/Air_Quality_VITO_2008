#1. Load Data
library(readxl)
aq_raw <- read_xlsx("H:/My Drive/Assignment/DS7003/Assessment/6th March 2026/Database/air+quality/Clean_air_data.xlsx")

#2. Null value check 
colSums(is.na(aq_raw))
#3. Seprate Variables
features <- aq_raw[, c("sensor1_co","sensor2_nmhc","sensor3_nox","sensor4_no2","sensor5_o3","temperature_c","relative_humidity","absolute_humidity")]  
co_mg <- aq_raw$co_mg_m3
aq.c <-cbind(co_mg,features)
str(aq.c)
#4. create training (80%) and test data (20%)
set.seed(12345)
nrow(aq.c)
floor(0.8 * nrow(aq.c))
aq.train <- aq.c[1:7485,]
aq.test <-aq.c[7486:9357,]  

#4.1) Check distribution
par(mfrow=c(1,3)) 
boxplot(aq.train$co_mg, col="skyblue", main="Train of co_mg boxplot", xlab="co_mg")
boxplot(aq.test$co_mg, col="skyblue", main="Test of co_mg boxplot", xlab="co_mg")
boxplot(aq.c$co_mg, col="skyblue", main="All co_mg boxplot", xlab="co_mg")
par(mfrow=c(1,1))
#5. SIMPLE LINEAR REGRESSION (SLR)

#5.1 Simple Linear Regression using one feature
slr_model <- lm(co_mg ~ sensor1_co, data = aq.train)

# Model summary
summary(slr_model)

#5.2 predict on test
slr_pred <- predict(slr_model, newdata = aq.test)

#5.3 Evaluate Performance
# RMSE
slr_rmse <- sqrt(mean((aq.test$co_mg - slr_pred)^2))

# MAE
slr_mae <- mean(abs(aq.test$co_mg - slr_pred))

# R-squared (on test set)
str(aq.test$co_mg)
slr_ss_total <- sum((aq.test$co_mg - mean(aq.test$co_mg))^2)
slr_ss_res   <- sum((aq.test$co_mg - slr_pred)^2)
slr_r2_test  <- 1 - (slr_ss_res/slr_ss_total)

#5.4 Final Print
cat("First Model: SLR Test RMSE:", slr_rmse, 
    " | MAE:", slr_mae, 
    " | R²:", slr_r2_test, "\n")


#5.5 SLR Graphics plot
# Set 3x1 plotting layout
par(mfrow=c(3,1), mar=c(4,4,2,1))  # margins: bottom, left, top, right
mtext("SLR: Simple Linear Regression Analysis", side=3, line=2, outer=TRUE, cex=1.5)

#i) Feature vs Target (Train)
plot(aq.train$sensor1_co, aq.train$co_mg,
     xlab="Sensor1_CO", ylab="CO_mg",
     main="Train: Sensor1 vs CO", col="skyblue", pch=16)
abline(slr_model, col="red", lwd=2)

#ii)Actual vs Predicted (Test)
plot(aq.test$co_mg, slr_pred,
     xlab="Actual CO_mg", ylab="Predicted CO_mg",
     main="Test: Actual vs Predicted", col="blue", pch=16)
abline(0,1, col="red", lwd=2)
#iii) Residuals vs Predicted
slr_residuals <- aq.test$co_mg - slr_pred
plot(slr_pred, slr_residuals,
     xlab="Predicted CO_mg", ylab="Residuals",
     main="Residuals vs Predicted", col="darkgreen", pch=16)
abline(h=0, col="red", lwd=2)

# Reset plotting layout
par(mfrow=c(1,1), mar=c(1,1,1,1)) 


#6. Correlation Check
cor(aq.c$co_mg, aq.c[,-1])
round(cor(aq.c),2)
library(corrplot)
corrplot(cor(aq.c), method="color", type="upper", tl.cex=0.8)

#7. Multiple LINEAR REGRESSION (MLR)
#7.1 Run Regular MLR model
mlm_model <- lm(co_mg ~ sensor1_co + sensor2_nmhc + sensor3_nox + 
                  sensor4_no2 + sensor5_o3, data=aq.train)

summary(mlm_model)

#7.2 Multicollinearity Check (VIF)
library(car)
vif(mlm_model)

#7.3 Check correlation between sensor1_co, sensor2_nmhc, sensor5_o3
cor(aq.train[, c("sensor1_co","sensor2_nmhc","sensor5_o3")])

#7.4 Remove two highly correlated features
mlm_model2 <- lm(co_mg ~ sensor1_co + sensor3_nox + sensor4_no2, data=aq.train)
vif(mlm_model2)

#7.5 MLM model 2 summary
summary(mlm_model2)

#7.6 Predict on test set
mlm_pred2 <- predict(mlm_model2, newdata=aq.test)

#7.7 Evaluate performance

# RMSE
mlm_rmse2 <- sqrt(mean((aq.test$co_mg - mlm_pred2)^2))

# MAE
mlm_mae2 <- mean(abs(aq.test$co_mg - mlm_pred2))

# R²
mlm_ss_total2 <- sum((aq.test$co_mg - mean(aq.test$co_mg))^2)
mlm_ss_res2   <- sum((aq.test$co_mg - mlm_pred2)^2)
mlm_r2_2 <- 1 - (mlm_ss_res2/mlm_ss_total2)


#7.8 Final Print

cat("Optimized MLM Test RMSE:", mlm_rmse2, 
    "| MAE:", mlm_mae2, 
    "| R²:", mlm_r2_2, "\n")


#7.9 MLM Model 2 Graphics plot
# Residuals
mlm_resid <- residuals(mlm_model2)
mlm_pred  <- predict(mlm_model2, newdata=aq.test)

# Setup layout 3 rows, 1 column
par(mfrow=c(3,1), mar=c(4,4,2,1))

# i) Feature vs Target (Train) - using first predictor for simplicity
plot(aq.train$sensor1_co, aq.train$co_mg,
     xlab="Sensor1_CO", ylab="CO_mg",
     main="Train: Sensor1 vs CO", col="skyblue", pch=16)
abline(lm(co_mg ~ sensor1_co, data=aq.train), col="red", lwd=2)

# ii) Actual vs Predicted (Test)
plot(aq.test$co_mg, mlm_pred,
     xlab="Actual CO_mg", ylab="Predicted CO_mg",
     main="Test: Actual vs Predicted", col="blue", pch=16)
abline(0,1, col="red", lwd=2)

# 4) Residual histogram + density + normal curve
hist(mlm_resid, prob=TRUE, col="grey", border="black",
     main="MLM Residuals Distribution", xlab="Residuals", ylab="Density")
lines(density(mlm_resid), col="red", lwd=2)

# Reset plotting layout
par(mfrow=c(1,1), mar=c(1,1,1,1)) 

#7.10 # PCA BASED MULTIPLE LINEAR REGRESSION (PCR)

# PCA exclusively on sensor features to handle multicollinearity
pca_sensor_features <- aq.train[, c("sensor1_co","sensor2_nmhc","sensor3_nox","sensor4_no2","sensor5_o3")]
# We scale the sensors because they have different units/ranges
pca_res <- prcomp(pca_sensor_features, scale. = TRUE)

# View variance explained
summary(pca_res)
plot(pca_res, type = "l", main = "Scree Plot: Variance by Components")

# Usually, first 2 PCs capture >90% of sensor variance
train_pca_components <- as.data.frame(pca_res$x[, 1:2])
# Combine PCs with Weather data and Target variable

train_pcr_combined <- cbind(train_pca_components, 
                            aq.train[, c("temperature_c", "absolute_humidity", "relative_humidity", "co_mg")])


# Transform Test data using the SAME PCA transformation
test_pca_components <- as.data.frame(predict(pca_res, newdata = aq.test[, c("sensor1_co","sensor2_nmhc","sensor3_nox","sensor4_no2","sensor5_o3")])[, 1:2])
test_pcr_combined <- cbind(test_pca_components, 
                           aq.test[, c("temperature_c", "absolute_humidity", "relative_humidity", "co_mg")])

# Fit the PCR (Principal Component Regression) Model
pcr_model <- lm(co_mg ~ ., data = train_pcr_combined)
summary(pcr_model)

# Predictions on Test set
pcr_pred <- predict(pcr_model, newdata = test_pcr_combined)

# Evaluate Performance
pcr_rmse <- sqrt(mean((test_pcr_combined$co_mg - pcr_pred)^2))
pcr_mae  <- mean(abs(test_pcr_combined$co_mg - pcr_pred))
pcr_r2   <- 1 - sum((test_pcr_combined$co_mg - pcr_pred)^2) / sum((test_pcr_combined$co_mg - mean(test_pcr_combined$co_mg))^2)

# Final Print for Section 7.10
cat("PCA Regression (PCR) Test RMSE:", round(pcr_rmse, 4), 
    " | MAE:", round(pcr_mae, 4), 
    " | R²:", round(pcr_r2, 4), "\n")

# Diagnostic Plots for PCR
par(mfrow=c(2,1), mar=c(4,4,2,1))
# Actual vs Predicted
plot(test_pcr_combined$co_mg, pcr_pred, 
     main="PCR: Actual vs Predicted", col="purple", pch=16)
abline(0,1, col="red", lwd=2)
# Residuals
pcr_resid <- test_pcr_combined$co_mg - pcr_pred
plot(pcr_pred, pcr_resid, main="PCR Residuals", col="darkred", pch=16)
abline(h=0, col="blue", lwd=2)
par(mfrow=c(1,1))



#8. Stepwise Regression Model

full_model <- lm(co_mg ~ sensor1_co + sensor2_nmhc + sensor3_nox + sensor4_no2 + sensor5_o3 + temperature_c + relative_humidity + absolute_humidity, data=aq.train)
null_model <- lm(co_mg ~ 1, data=aq.train)
colnames(aq.train)

# Stepwise selection (both directions)
step_model <- step(null_model,scope=list(lower=null_model, upper=full_model), 
                   direction="both", trace=1)  
#8.1 Summary of Stepwise model
summary(step_model)

#8.2 Predict on test set
step_pred <- predict(step_model, newdata=aq.test)


#8.3 Evaluate performance
step_rmse <- sqrt(mean((aq.test$co_mg - step_pred)^2))
step_mae  <- mean(abs(aq.test$co_mg - step_pred))
step_r2   <- 1 - sum((aq.test$co_mg - step_pred)^2) / sum((aq.test$co_mg - mean(aq.test$co_mg))^2)

#8.4 Print metrics
cat("Stepwise Regression Test RMSE:", step_rmse,
    " | MAE:", step_mae,
    " | R²:", step_r2, "\n")



#9. Random Forest


#9.1 run packages("randomForest")
library(randomForest)

#9.2 Features & Target
aq.f_train <- aq.train[, -1]  # exclude target column co_mg
aq.t_train <- aq.train$co_mg
aq.f_test  <- aq.test[, -1]
aq.t_test  <- aq.test$co_mg

# Fit Random Forest
set.seed(12345)
rf_model <- randomForest(x=aq.f_train, y=aq.t_train,
                         ntree=500, mtry=3, importance=TRUE)

# Predictions
rf_pred <- predict(rf_model, newdata=aq.f_test)

# Test accuracy check:
postResample(pred = rf_pred, obs = aq.test$co_mg)

# Performance Metrics
rf_rmse <- sqrt(mean((aq.t_test - rf_pred)^2))
rf_mae  <- mean(abs(aq.t_test - rf_pred))
rf_r2   <- 1 - sum((aq.t_test - rf_pred)^2) / sum((aq.t_test - mean(aq.t_test))^2)

# Print metrics
cat("Random Forest Test RMSE:", rf_rmse,
    " | MAE:", rf_mae,
    " | R²:", rf_r2, "\n")

# Feature importance plot
importance(rf_model)
varImpPlot(rf_model)

# Diagnostic plots similar to MLM
par(mfrow=c(3,1), mar=c(4,4,2,1))

# i) Feature vs Target (Train) - example first predictor
plot(aq.train$sensor1_co, aq.train$co_mg,
     xlab="Sensor1_CO", ylab="CO_mg",
     main="Train: Sensor1 vs CO", col="skyblue", pch=16)

# ii) Actual vs Predicted (Test)
plot(aq.t_test, rf_pred,
     xlab="Actual CO_mg", ylab="Predicted CO_mg",
     main="Random Forest: Actual vs Predicted", col="blue", pch=16)
abline(0,1, col="red", lwd=2)

# iii) Residuals vs Predicted
rf_resid <- aq.t_test - rf_pred
plot(rf_pred, rf_resid,
     xlab="Predicted CO_mg", ylab="Residuals",
     main="Residuals vs Predicted", col="darkgreen", pch=16)
abline(h=0, col="red", lwd=2)

par(mfrow=c(1,1), mar=c(4,4,2,1))


#10. automatic hyperparameter tuning Random Forest
library(caret)
set.seed(12345)
# Define training control
train_control <- trainControl(method="cv", number=5, search="grid")
# Define tuning grid for mtry
tune_grid <- expand.grid(mtry = 1:ncol(aq.f_train))
# Train Random Forest with auto-tuning
rf_tuned <- train(x = aq.f_train,y = aq.t_train,method = "rf",metric = "RMSE",
                  tuneGrid = tune_grid,trControl = train_control,ntree = 500,
                  importance = TRUE)
# Show best parameters
print(rf_tuned)

# Predictions
rf_t_pred <- predict(rf_tuned, newdata = aq.test)
# Test accuracy check:
postResample(pred = rf_t_pred, obs = aq.test$co_mg)

#check feature importance (because of overfitting of model)
# Feature importance plot garna
varImpPlot(rf_tuned$finalModel, main="Feature Importance")

#11. overfitting soluation
features_reduced <- aq_raw[, c("sensor2_nmhc", "sensor4_no2", "temperature_c", "absolute_humidity", "relative_humidity")]
aq.reduced <- cbind(co_mg, features_reduced)

#data Split
aq.train_red <- aq.reduced[1:7485,]
aq.test_red <- aq.reduced[7486:9357,]

# New Tuning Grid with nodesize
red_control <- trainControl(method="cv", number=5)

#model train using Reduced features
rf_reduced <- train(co_mg ~ ., data = aq.train_red, 
                    method = "rf", 
                    tuneGrid = expand.grid(mtry = c(2, 3)), 
                    ntree = 200,
                    nodesize = 10,
                    trControl = red_control)

# # Predictions
rf_red_pred <- predict(rf_reduced, newdata = aq.test_red)
postResample(pred = rf_red_pred, obs = aq.test_red$co_mg)



#graphics plot
par(mfrow=c(2,1), mar=c(4,4,2,1))
plot(aq.test_red$co_mg, rf_red_pred, 
     xlab="Actual CO (mg/m3)", 
     ylab="Predicted CO (mg/m3)", 
     main="Final Reduced RF: Actual vs Predicted", 
     col="darkblue", pch=16)
abline(0, 1, col="red", lwd=2) # 45 degree line

# Residuals for reduced model
final_resid <- aq.test_red$co_mg - rf_red_pred

plot(rf_red_pred, final_resid, 
     xlab="Predicted CO (mg/m3)", 
     ylab="Residuals", 
     main="Final Reduced RF: Residuals vs Predicted", 
     col="darkgreen", pch=16)
abline(h=0, col="red", lwd=2)
# Reset layout
par(mfrow=c(1,1), mar=c(1,1,1,1))


#----------XGBoost------------
# 12. Normal XGBoost
library(xgboost)
# Prepare matrices for all features
train_x_all <- as.matrix(aq.train[, -1]) # exclude co_mg
train_y_all <- aq.train$co_mg
test_x_all  <- as.matrix(aq.test[, -1])
test_y_all  <- aq.test$co_mg



dtrain_all <- xgb.DMatrix(data = train_x_all, label = train_y_all)
dtest_all  <- xgb.DMatrix(data = test_x_all, label = test_y_all)
# Train with default parameters
set.seed(12345)

params_normal <- list(
  objective = "reg:squarederror",
  max_depth = 6,
  eta = 0.3,
  nthread = 2
)
# Train with all features
set.seed(12345)
model_xgb_normal <- xgb.train(
  params = params_normal, 
  data = dtrain_all, 
  nrounds = 50
)
# Predictions
pred_normal <- predict(model_xgb_normal, dtest_all)

# Final Accuracy Check
postResample(pred = pred_normal, obs = test_y_all)

# Evaluate Normal XGBoost
pred_normal <- predict(model_xgb_normal, dtest_all)
postResample(pred = pred_normal, obs = test_y_all)


# 13. Tuned & Reduced XGBoost
# Using reduced features prepared earlier
train_x_red <- as.matrix(aq.train_red[, -1])
train_y_red <- aq.train_red$co_mg
test_x_red  <- as.matrix(aq.test_red[, -1])
test_y_red  <- aq.test_red$co_mg

identical(colnames(train_x_red), colnames(test_x_red))

dtrain_red <- xgb.DMatrix(data = train_x_red, label = train_y_red)
dtest_red  <- xgb.DMatrix(data = test_x_red, label = test_y_red)

# Params to control overfitting
params_tuned <- list(
  objective = "reg:squarederror",
  eta = 0.1,           
  max_depth = 4,       
  subsample = 0.8,     
  colsample_bytree = 0.8,
  nthread = 2
)

set.seed(12345)
model_xgb_tuned <- xgb.train(
  params = params_tuned, 
  data = dtrain_red, 
  nrounds = 150        # More rounds with lower eta
)

# Final XGBoost Evaluation
pred_xgb_tuned <- predict(model_xgb_tuned, dtest_red)
postResample(pred = pred_xgb_tuned, obs = test_y_red)

#14 XGBoost plot
# Importance for Tuned XGBoost
importance_final <- xgb.importance(feature_names = colnames(train_x_red), model = model_xgb_tuned)
xgb.plot.importance(importance_matrix = importance_final, main = "Final XGBoost Feature Importance")

par(mfrow=c(2,1), mar=c(4,4,2,1))

# Actual vs Predicted for XGBoost
plot(test_y_red, pred_xgb_tuned, 
     xlab = "Actual CO (mg/m3)", 
     ylab = "Predicted CO (mg/m3)", 
     main = "Final XGBoost: Actual vs Predicted", 
     col = "darkorange", pch = 16)
abline(0, 1, col = "red", lwd = 2)

# Residuals for XGBoost
xgb_resid <- test_y_red - pred_xgb_tuned

plot(pred_xgb_tuned, xgb_resid, 
     xlab = "Predicted CO (mg/m3)", 
     ylab = "Residuals", 
     main = "Final XGBoost: Residuals vs Predicted", 
     col = "purple", pch = 16)
abline(h = 0, col = "red", lwd = 2)

par(mfrow=c(1,1), mar=c(4,4,2,1))

#------------------------------

# 14. Support Vector Regression (SVR)
library(e1071)

#14.1 SVM with all sensors and weather data
set.seed(12345)
svm_normal <- svm(co_mg ~ ., data = aq.train, 
                  kernel = "radial", cost = 1, epsilon = 0.1)

# Predictions & Accuracy
svm_norm_pred <- predict(svm_normal, newdata = aq.test)
postResample(pred = svm_norm_pred, obs = aq.test$co_mg)


#14.2 SVM with reduced features (NMHC, NO2, Temp, Humidity)
set.seed(12345)
svm_reduced <- svm(co_mg ~ ., data = aq.train_red, 
                   kernel = "radial", cost = 1, epsilon = 0.1)

# Predictions & Accuracy
svm_red_pred <- predict(svm_reduced, newdata = aq.test_red)
postResample(pred = svm_red_pred, obs = aq.test_red$co_mg)


# Saving metrics for final table
svm_rmse <- sqrt(mean((aq.test_red$co_mg - svm_red_pred)^2))
svm_r2   <- 1 - sum((aq.test_red$co_mg - svm_red_pred)^2) / sum((aq.test_red$co_mg - mean(aq.test_red$co_mg))^2)
svm_mae  <- mean(abs(aq.test_red$co_mg - svm_red_pred))

print(svm_rmse)
print(svm_r2)
print(svm_mae)

# SVM Plot Layout (1 row, 2 columns)
par(mfrow=c(1,2), mar=c(4,4,3,1))

# i) Normal SVM (All Features)
plot(aq.test$co_mg, svm_norm_pred, 
     main="Normal SVM: Actual vs Pred", 
     xlab="Actual CO", ylab="Predicted CO", 
     col="gray", pch=16, cex=0.8)
abline(0, 1, col="red", lwd=2)

# ii) Reduced SVM (Optimized)
plot(aq.test_red$co_mg, svm_red_pred, 
     main="Reduced SVM: Actual vs Pred", 
     xlab="Actual CO", ylab="Predicted CO", 
     col="darkred", pch=16, cex=0.8)
abline(0, 1, col="blue", lwd=2)

# Reset Layout
par(mfrow=c(1,1))

# Residual Plots
par(mfrow=c(1,2), mar=c(4,4,3,1))

# i) Normal SVM Residuals
norm_resid <- aq.test$co_mg - svm_norm_pred
plot(svm_norm_pred, norm_resid, 
     main="Normal SVM Residuals", 
     xlab="Predicted", ylab="Residuals", 
     col="gray", pch=16)
abline(h=0, col="red", lwd=2)

# ii) Reduced SVM Residuals
red_resid <- aq.test_red$co_mg - svm_red_pred
plot(svm_red_pred, red_resid, 
     main="Reduced SVM Residuals", 
     xlab="Predicted", ylab="Residuals", 
     col="darkorange", pch=16)
abline(h=0, col="blue", lwd=2)

par(mfrow=c(1,1))

#------------------------------
#15. FINAL MODEL COMPARISON SUMMARY
#------------------------------
# Final Comparison Table using your stored variables
model_names <- c("Optimized MLR", "Stepwise", "PCR", "Random Forest (Reduced)", "XGBoost (Tuned)", "SVR (Reduced)")

# Collecting RMSE from your environment
rmse_vals <- c(
  mlm_rmse2, 
  step_rmse, 
  pcr_rmse, 
  sqrt(mean((aq.test_red$co_mg - rf_red_pred)^2)), # RF Reduced
  sqrt(mean((test_y_red - pred_xgb_tuned)^2)),    # XGBoost Tuned
  svm_rmse                                        # SVR Reduced
)

# Collecting R-Squared from your environment
r2_vals <- c(
  mlm_r2_2, 
  step_r2, 
  pcr_r2, 
  postResample(pred = rf_red_pred, obs = aq.test_red$co_mg)[2], # RF R2
  postResample(pred = pred_xgb_tuned, obs = test_y_red)[2],     # XGBoost R2
  svm_r2                                                       # SVR R2
)

performance_report <- data.frame(Model = model_names, RMSE = rmse_vals, R_Squared = r2_vals)
print(performance_report)





save.image(file = "H:/My Drive/Assignment/DS7003/Assessment/AirQuality_Dissertation_Final.RData")



#rm(list = ls())
   