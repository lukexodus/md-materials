## Regularization Techniques


Regularization prevents overfitting by adding penalty terms to the loss function.

### Ridge Regression (L2 Regularization)

```r
library(glmnet)
# Prepare data
x <- model.matrix(mpg ~ . - 1, data = mtcars)  # Remove intercept
y <- mtcars$mpg

# Ridge regression
ridge_model <- glmnet(x, y, alpha = 0)  # alpha = 0 for ridge

# Cross-validation for optimal lambda
cv_ridge <- cv.glmnet(x, y, alpha = 0)
optimal_lambda_ridge <- cv_ridge$lambda.min

# Final model with optimal lambda
final_ridge <- glmnet(x, y, alpha = 0, lambda = optimal_lambda_ridge)
coef(final_ridge)
```

### LASSO Regression (L1 Regularization)

```r
# LASSO regression
lasso_model <- glmnet(x, y, alpha = 1)  # alpha = 1 for LASSO

# Cross-validation for optimal lambda
cv_lasso <- cv.glmnet(x, y, alpha = 1)
optimal_lambda_lasso <- cv_lasso$lambda.min

# Final model
final_lasso <- glmnet(x, y, alpha = 1, lambda = optimal_lambda_lasso)
coef(final_lasso)

# Variable selection (non-zero coefficients)
selected_vars <- which(coef(final_lasso)[-1] != 0)
```

### Elastic Net (Combined L1 and L2)

```r
# Elastic Net (alpha between 0 and 1)
elastic_model <- glmnet(x, y, alpha = 0.5)

# Cross-validation
cv_elastic <- cv.glmnet(x, y, alpha = 0.5)
optimal_lambda_elastic <- cv_elastic$lambda.min

final_elastic <- glmnet(x, y, alpha = 0.5, lambda = optimal_lambda_elastic)
```

### Regularization Comparison

```r
# Compare regularization methods
comparison_data <- data.frame(
  Method = c("Ridge", "LASSO", "Elastic Net"),
  Lambda = c(optimal_lambda_ridge, optimal_lambda_lasso, optimal_lambda_elastic),
  CV_Error = c(min(cv_ridge$cvm), min(cv_lasso$cvm), min(cv_elastic$cvm)),
  N_Variables = c(
    sum(coef(final_ridge)[-1] != 0),
    sum(coef(final_lasso)[-1] != 0),
    sum(coef(final_elastic)[-1] != 0)
  )
)

# Regularization path plot
plot(lasso_model, xvar = "lambda")
```

### Advanced Regularization

```r
# Group LASSO (for grouped variables)
library(gglasso)
# Define groups
group_index <- c(1, 1, 2, 2, 3, 3, 4, 4, 5, 5)  # Example grouping
group_lasso <- gglasso(x, y, group = group_index)

# Adaptive LASSO
# [Inference] Two-stage process where initial weights are from ridge regression
ridge_coef <- coef(cv_ridge, s = "lambda.min")[-1]  # Remove intercept
adaptive_weights <- 1 / abs(ridge_coef)^2
adaptive_lasso <- glmnet(x, y, alpha = 1, penalty.factor = adaptive_weights)
```

**Key Points:**

- Linear models assume linear relationships, independence, homoscedasticity, and normality
- GLMs extend linear models to non-normal distributions through link functions
- Model diagnostics are essential for validating assumptions and identifying problems
- Regularization techniques help prevent overfitting and perform variable selection
- Cross-validation provides unbiased estimates of model performance
- Interaction terms and polynomials capture non-linear relationships

**Example** comprehensive modeling workflow:

```r
# Complete modeling pipeline
# 1. Data preparation
data_clean <- raw_data %>%
  filter(!is.na(outcome_variable)) %>%
  mutate(
    log_predictor = log(predictor + 1),
    categorical_var = factor(categorical_var)
  )

# 2. Initial model fitting
initial_model <- lm(outcome ~ predictor1 + predictor2 + categorical_var, 
                   data = data_clean)

# 3. Assumption checking
car::residualPlots(initial_model)
car::ncvTest(initial_model)
shapiro.test(residuals(initial_model))

# 4. Model refinement
refined_model <- lm(outcome ~ poly(predictor1, 2) + predictor2 * categorical_var,
                   data = data_clean)

# 5. Model comparison
anova(initial_model, refined_model)
AIC(initial_model, refined_model)

# 6. Cross-validation
cv_results <- train(outcome ~ poly(predictor1, 2) + predictor2 * categorical_var,
                   data = data_clean,
                   method = "lm",
                   trControl = trainControl(method = "cv", number = 10))

# 7. Regularized alternative
x_matrix <- model.matrix(outcome ~ . - 1, data = data_clean)
y_vector <- data_clean$outcome
lasso_cv <- cv.glmnet(x_matrix, y_vector, alpha = 1)
final_lasso <- glmnet(x_matrix, y_vector, 
                     alpha = 1, lambda = lasso_cv$lambda.min)
```

These techniques provide a comprehensive foundation for statistical modeling, from basic linear relationships to complex regularized models capable of handling high-dimensional data and preventing overfitting.

---

