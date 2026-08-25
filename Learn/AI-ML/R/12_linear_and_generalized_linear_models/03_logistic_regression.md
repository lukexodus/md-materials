## Logistic Regression


Logistic regression models binary outcomes using the logistic function.

### Binary Logistic Regression

```r
# Create binary outcome
mtcars$high_mpg <- ifelse(mtcars$mpg > median(mtcars$mpg), 1, 0)

# Fit logistic regression
logit_model <- glm(high_mpg ~ wt + hp + cyl, 
                   data = mtcars, 
                   family = binomial(link = "logit"))

summary(logit_model)
```

### Model Interpretation

```r
# Odds ratios
exp(coef(logit_model))
exp(confint(logit_model))

# Marginal effects
margins::margins(logit_model)

# Predicted probabilities
predicted_probs <- predict(logit_model, type = "response")

# Classification accuracy
predicted_class <- ifelse(predicted_probs > 0.5, 1, 0)
confusion_matrix <- table(Predicted = predicted_class, 
                         Actual = mtcars$high_mpg)
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
```

### Logistic Regression Diagnostics

```r
# Deviance residuals
dev_residuals <- residuals(logit_model, type = "deviance")

# Pearson residuals
pearson_residuals <- residuals(logit_model, type = "pearson")

# Hosmer-Lemeshow goodness of fit test
ResourceSelection::hoslem.test(mtcars$high_mpg, predicted_probs)

# ROC curve and AUC
library(pROC)
roc_curve <- roc(mtcars$high_mpg, predicted_probs)
auc(roc_curve)
plot(roc_curve)
```

### Multinomial Logistic Regression

For categorical outcomes with more than two levels:

```r
# Multinomial logistic regression
library(nnet)
mtcars$cyl_factor <- factor(mtcars$cyl)
multinom_model <- multinom(cyl_factor ~ mpg + wt + hp, data = mtcars)
summary(multinom_model)

# Predicted probabilities
multinom_probs <- predict(multinom_model, type = "probs")
```

