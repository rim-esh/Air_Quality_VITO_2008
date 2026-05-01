# Machine Learning-Based Prediction of Carbon Monoxide Concentration Using Sensor and Meteorological Data

![R](https://img.shields.io/badge/R-Statistical%20Modelling-blue)
![Machine Learning](https://img.shields.io/badge/Machine%20Learning-Regression-green)
![Air Quality](https://img.shields.io/badge/Application-Air%20Quality-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

## Project Overview

This project develops a machine learning workflow to predict hourly carbon monoxide (CO) concentration using low-cost metal oxide (MOx) sensor responses and meteorological variables. The analysis was conducted in R as part of the DS7003 Advanced Decision Making: Predictive Analytics & Machine Learning module.

Low-cost air-quality sensors provide an affordable alternative to reference-grade monitoring stations. However, MOx sensors are affected by non-linear response, cross-sensitivity to multiple gases, sensor noise, and meteorological influences such as temperature and humidity. This project evaluates whether machine learning models can improve CO prediction compared with conventional linear regression approaches.

## Dataset

The analysis uses the **UCI Air Quality Dataset**.

**Dataset source:** UCI Machine Learning Repository  
**Dataset link:** https://doi.org/10.24432/C59K5F  

The dataset contains hourly averaged air-quality observations from a MOx sensor array and reference measurements. In this project, the cleaned dataset was used for modelling.

### Target Variable

| Variable | Description |
|---|---|
| `co_mg` | Hourly averaged carbon monoxide concentration |

### Predictor Variables

| Variable | Description |
|---|---|
| `sensor1_co` | MOx sensor response related to CO |
| `sensor2_nmhc` | MOx sensor response related to non-methane hydrocarbons |
| `sensor3_nox` | MOx sensor response related to nitrogen oxides |
| `sensor4_no2` | MOx sensor response related to nitrogen dioxide |
| `sensor5_o3` | MOx sensor response related to ozone |
| `temperature_c` | Ambient temperature |
| `relative_humidity` | Relative humidity |
| `absolute_humidity` | Absolute humidity |

## Research Aim

The aim of this project is to design, evaluate, and compare machine learning models for predicting hourly CO concentration using multicollinear sensor and meteorological data.

## Methodological Workflow

The modelling workflow followed these steps:

1. Load and inspect the cleaned air-quality dataset.
2. Check missing values and prepare predictor and target variables.
3. Split the dataset into 80% training data and 20% testing data.
4. Conduct exploratory data analysis using boxplots and correlation analysis.
5. Apply baseline statistical models.
6. Train non-linear machine learning models.
7. Compare model performance using RMSE, MAE, and R².
8. Evaluate model reliability using observed-versus-predicted and residual plots.

## Models Implemented

The following models were tested:

| Model Category | Models |
|---|---|
| Baseline model | Simple Linear Regression |
| Parametric models | Multiple Linear Regression, Stepwise Regression |
| Dimensionality reduction model | Principal Component Regression |
| Ensemble models | Random Forest, XGBoost |
| Kernel-based model | Support Vector Regression |

## Model Performance Summary

| Model | RMSE | R² |
|---|---:|---:|
| Optimized MLR | 0.7856 | 0.6684 |
| Principal Component Regression | 0.6602 | 0.7658 |
| Stepwise Regression | 0.5622 | 0.8302 |
| Random Forest Reduced | 0.5714 | 0.8274 |
| XGBoost Tuned | 0.5661 | 0.8314 |
| Support Vector Regression Reduced | 0.5479 | 0.8387 |

The **reduced Support Vector Regression model with radial basis function kernel** achieved the best performance among the tested models.

## Key Findings

- Linear models provided useful baselines but were limited by multicollinearity and non-linear sensor behaviour.
- Principal Component Regression reduced multicollinearity but did not fully capture non-linear sensor-weather interactions.
- Random Forest and XGBoost improved prediction by modelling non-linear relationships.
- Reduced SVR achieved the lowest RMSE and highest R².
- Feature reduction improved model stability by removing redundant predictors.
- Temperature and humidity were important because they influence both pollutant dispersion and MOx sensor response.
- The results support the use of machine learning for low-cost air-quality sensor calibration, but external validation is required before operational deployment.

## Important Figures

The project includes the following key diagnostic outputs:

| Figure | Description |
|---|---|
| Figure 4.1 | Boxplot of CO concentration across train, test, and full dataset |
| Figure 4.2 | Pearson correlation matrix of variables |
| Figure 6.1 | RMSE comparison of all tested models |
| Figure 6.2 | Observed versus predicted CO concentration for normal and reduced SVR models |
| Figure 6.3 | Feature importance ranking from tuned XGBoost |
| Figure 6.4 | Residual plots for normal and reduced SVR models |
| Figure G.1 | Simple Linear Regression diagnostic plots |
| Figure G.2 | Multiple Linear Regression diagnostic plots |
| Figure G.3 | PCA scree plot |
| Figure G.4 | Principal Component Regression diagnostic plots |
| Figure G.5 | Stepwise Regression diagnostic plots |
| Figure G.6 | Random Forest diagnostic plots using all features |
| Figure G.7 | Reduced Random Forest diagnostic plots |
| Figure G.8 | Tuned XGBoost diagnostic plots |

## Recommended Repository Structure

```text
carbon-monoxide-prediction-ml/
│
├── README.md
├── data/
│   └── Clean_air_data.xlsx
│
├── scripts/
│   ├── 01_data_preparation.R
│   ├── 02_exploratory_data_analysis.R
│   ├── 03_baseline_models.R
│   ├── 04_machine_learning_models.R
│   └── 05_model_evaluation.R
│
├── figures/
│   ├── figure_4_1_boxplot.png
│   ├── figure_4_2_correlation_matrix.png
│   ├── figure_6_1_rmse_comparison.png
│   ├── figure_6_2_svr_actual_vs_predicted.png
│   ├── figure_6_3_xgboost_feature_importance.png
│   ├── figure_6_4_svr_residuals.png
│   └── appendix_g/
│
├── outputs/
│   └── model_performance_summary.csv
│
└── report/
    └── final_report.pdf
```

## Required R Packages

```r
install.packages(c(
  "readxl",
  "dplyr",
  "caret",
  "corrplot",
  "car",
  "randomForest",
  "xgboost",
  "e1071",
  "mice",
  "pls"
))
```

## How to Run the Project

1. Clone the repository.

```bash
git clone https://github.com/your-username/carbon-monoxide-prediction-ml.git
```

2. Open the project folder in RStudio.

3. Place the cleaned dataset inside the `data/` folder.

```text
data/Clean_air_data.xlsx
```

4. Run the scripts in sequence:

```r
source("scripts/01_data_preparation.R")
source("scripts/02_exploratory_data_analysis.R")
source("scripts/03_baseline_models.R")
source("scripts/04_machine_learning_models.R")
source("scripts/05_model_evaluation.R")
```

5. Review model outputs in the `outputs/` folder and figures in the `figures/` folder.

## Evaluation Metrics

| Metric | Interpretation |
|---|---|
| RMSE | Penalises larger prediction errors and is useful for assessing failure to predict high CO events |
| MAE | Measures average absolute prediction error |
| R² | Measures the proportion of variance explained by the model |

## Limitations

This project provides strong internal validation but has several limitations:

- The dataset represents a specific monitoring context.
- Long-term MOx sensor drift was not fully addressed.
- The model was not externally validated on another city, year, or sensor network.
- Imputed values remain statistically estimated values, not direct observations.
- Model performance may change under different meteorological or emission conditions.

## Future Work

Future research should focus on:

- External validation using independent air-quality datasets.
- Drift-aware recalibration of low-cost sensors.
- Time-series models such as LSTM for temporal prediction.
- Deployment testing in real-time IoT air-quality monitoring systems.
- Comparing model performance across different urban environments.

## Academic Use

This repository is intended for academic demonstration of predictive analytics and machine learning methods in environmental monitoring. The work highlights how data preprocessing, feature selection, model regularisation, and diagnostic evaluation contribute to reliable air-quality prediction.

## Author

**Narayan Pandey**  
MSc Data Science  
University of East London  
Module: DS7003 Advanced Decision Making: Predictive Analytics & Machine Learning

## Acknowledgement

This project was completed as part of academic coursework. The dataset was obtained from the UCI Machine Learning Repository.

## Reference

UCI Machine Learning Repository. *Air Quality Dataset*. Available at: https://doi.org/10.24432/C59K5F
