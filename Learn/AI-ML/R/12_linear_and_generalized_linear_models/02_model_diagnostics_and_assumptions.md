## Model Diagnostics and Assumptions


Linear regression assumes linearity, independence, homoscedasticity, and normality of residuals.

### Residual Analysis

```r
# Basic diagnostic plots
par(mfrow = c(2, 2))
plot(model_multiple)

# Individual diagnostic plots
# 1. Residuals vs Fitted (linearity, homoscedasticity)
plot(model_multiple, which = 1)

# 2. Q-Q plot (normality)
plot(model_multiple, which = 2)

# 3. Scale-Location (homoscedasticity)
plot(model_multiple, which = 3)

# 4. Residuals vs Leverage (influential points)
plot(model_multiple, which = 5)
```

### Assumption Testing

```r
# Normality tests
shapiro.test(residuals(model_multiple))
car::qqPlot(model_multiple)

# Homoscedasticity tests
car::ncvTest(model_multiple)  # Non-constant variance test
lmtest::bptest(model_multiple)  # Breusch-Pagan test

# Linearity assessment
car::residualPlots(model_multiple)

# Independence (autocorrelation)
car::durbinWatsonTest(model_multiple)

# Multicollinearity
car::vif(model_multiple)  # Variance Inflation Factor
```

### Influential Points and Outliers

```r
# Cook's distance
cooksd <- cooks.distance(model_multiple)
influential_points <- which(cooksd > 4/nrow(mtcars))

# Leverage values
leverage <- hatvalues(model_multiple)
high_leverage <- which(leverage > 2 * length(coef(model_multiple))/nrow(mtcars))

# Standardized residuals
std_residuals <- rstandard(model_multiple)
outliers <- which(abs(std_residuals) > 2)

# Comprehensive influence measures
influence_stats <- car::influencePlot(model_multiple)
```

### Robust Regression

When assumptions are violated:

```r
# Robust regression (M-estimation)
robust_model <- MASS::rlm(mpg ~ wt + hp + cyl, data = mtcars)
summary(robust_model)

# Huber-White robust standard errors
robust_se <- sandwich::vcovHC(model_multiple, type = "HC3")
coeftest(model_multiple, vcov = robust_se)
```

