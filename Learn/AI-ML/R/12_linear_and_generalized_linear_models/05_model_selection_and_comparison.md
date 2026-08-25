## Model Selection and Comparison


### Information Criteria

```r
# Compare models using AIC/BIC
models <- list(
  model1 = lm(mpg ~ wt, data = mtcars),
  model2 = lm(mpg ~ wt + hp, data = mtcars),
  model3 = lm(mpg ~ wt + hp + cyl, data = mtcars),
  model4 = lm(mpg ~ wt * hp + cyl, data = mtcars)
)

# AIC comparison
aic_values <- sapply(models, AIC)
bic_values <- sapply(models, BIC)

comparison_table <- data.frame(
  Model = names(models),
  AIC = aic_values,
  BIC = bic_values,
  Delta_AIC = aic_values - min(aic_values)
)
```

### Likelihood Ratio Tests

```r
# Nested model comparison
anova(models$model1, models$model2, models$model3, test = "F")

# For GLMs
anova(logit_model, test = "Chisq")
```

### Cross-Validation

```r
library(caret)
# K-fold cross-validation
set.seed(123)
cv_results <- train(mpg ~ wt + hp + cyl, 
                   data = mtcars,
                   method = "lm",
                   trControl = trainControl(method = "cv", number = 10),
                   metric = "RMSE")

# Leave-one-out cross-validation
loocv_results <- train(mpg ~ wt + hp + cyl, 
                      data = mtcars,
                      method = "lm",
                      trControl = trainControl(method = "LOOCV"),
                      metric = "RMSE")
```

### Stepwise Selection

```r
# Forward selection
forward_model <- step(lm(mpg ~ 1, data = mtcars), 
                     scope = list(lower = ~ 1, upper = ~ wt + hp + cyl + gear + carb),
                     direction = "forward")

# Backward selection
full_model <- lm(mpg ~ ., data = mtcars)
backward_model <- step(full_model, direction = "backward")

# Bidirectional selection
both_model <- step(lm(mpg ~ 1, data = mtcars), 
                  scope = list(lower = ~ 1, upper = ~ .),
                  direction = "both")
```

