## Poisson Regression


Poisson regression models count data with non-negative integer outcomes.

### Basic Poisson Model

```r
# Simulate count data
set.seed(123)
count_data <- data.frame(
  x1 = rnorm(100),
  x2 = rnorm(100)
)
count_data$y <- rpois(100, exp(0.5 + 0.3 * count_data$x1 - 0.2 * count_data$x2))

# Fit Poisson regression
poisson_model <- glm(y ~ x1 + x2, 
                     data = count_data, 
                     family = poisson(link = "log"))

summary(poisson_model)
```

### Model Interpretation

```r
# Rate ratios (exponentiated coefficients)
exp(coef(poisson_model))
exp(confint(poisson_model))

# Incident rate ratios
car::Anova(poisson_model, type = "II", test = "LR")
```

### Overdispersion Testing

```r
# Check for overdispersion
overdispersion_test <- sum(residuals(poisson_model, type = "pearson")^2) / 
                      df.residual(poisson_model)

# Formal test
AER::dispersiontest(poisson_model)

# Quasi-Poisson model for overdispersion
quasi_poisson <- glm(y ~ x1 + x2, 
                     data = count_data, 
                     family = quasipoisson)

# Negative binomial model
library(MASS)
nb_model <- glm.nb(y ~ x1 + x2, data = count_data)
```

### Zero-Inflated Models

For data with excess zeros:

```r
library(pscl)
# Zero-inflated Poisson
zip_model <- zeroinfl(y ~ x1 + x2 | x1, data = count_data)
summary(zip_model)

# Zero-inflated negative binomial
zinb_model <- zeroinfl(y ~ x1 + x2 | x1, data = count_data, dist = "negbin")
```

