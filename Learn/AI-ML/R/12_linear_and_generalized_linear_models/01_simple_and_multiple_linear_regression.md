## Simple and Multiple Linear Regression


### Simple Linear Regression

Simple linear regression models the relationship between one predictor and one continuous response variable:

```r
# Basic simple linear regression
model_simple <- lm(mpg ~ wt, data = mtcars)

# Model summary
summary(model_simple)
```

The model equation: `mpg = β₀ + β₁ × wt + ε`

```r
# Extract coefficients
coef(model_simple)
# (Intercept)          wt 
#   37.285126   -5.344472 

# Confidence intervals for coefficients
confint(model_simple)

# Predictions
new_data <- data.frame(wt = c(2.5, 3.0, 3.5))
predictions <- predict(model_simple, newdata = new_data, 
                      interval = "confidence")
```

### Multiple Linear Regression

Multiple regression incorporates several predictors:

```r
# Multiple regression model
model_multiple <- lm(mpg ~ wt + hp + cyl, data = mtcars)
summary(model_multiple)

# Alternative formula specifications
model_all <- lm(mpg ~ ., data = mtcars)  # All variables
model_interaction <- lm(mpg ~ wt * hp, data = mtcars)  # Include interaction
model_exclude <- lm(mpg ~ . - gear - carb, data = mtcars)  # Exclude variables
```

Advanced model specifications:

```r
# Polynomial terms
model_poly <- lm(mpg ~ poly(wt, 2) + hp, data = mtcars)

# Transformed variables
model_log <- lm(log(mpg) ~ wt + I(hp^2), data = mtcars)

# Categorical variables
mtcars$cyl_factor <- factor(mtcars$cyl)
model_categorical <- lm(mpg ~ wt + cyl_factor, data = mtcars)
```

### Model Interpretation

```r
# Coefficient interpretation
tidy_model <- broom::tidy(model_multiple, conf.int = TRUE)
print(tidy_model)

# Standardized coefficients
model_scaled <- lm(scale(mpg) ~ scale(wt) + scale(hp) + scale(cyl), 
                   data = mtcars)

# Effect sizes
car::Anova(model_multiple, type = "II")  # Type II ANOVA

# Partial correlation
ppcor::pcor(mtcars[, c("mpg", "wt", "hp", "cyl")])
```

