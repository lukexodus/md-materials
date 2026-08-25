## Interaction Terms and Polynomial Models


### Interaction Effects

```r
# Two-way interaction
interaction_model <- lm(mpg ~ wt * hp, data = mtcars)
summary(interaction_model)

# Three-way interaction
three_way_model <- lm(mpg ~ wt * hp * cyl, data = mtcars)

# Interaction with categorical variables
mtcars$cyl_factor <- factor(mtcars$cyl)
cat_interaction <- lm(mpg ~ wt * cyl_factor, data = mtcars)
```

### Interaction Interpretation

```r
# Simple slopes analysis
library(interactions)
interact_plot(interaction_model, pred = wt, modx = hp, 
              modx.values = c(100, 150, 200))

# Johnson-Neyman intervals
sim_slopes(interaction_model, pred = wt, modx = hp, johnson_neyman = TRUE)

# Marginal effects at different levels
margins::margins(interaction_model, 
                at = list(hp = c(100, 150, 200)))
```

### Polynomial Models

```r
# Quadratic model
quad_model <- lm(mpg ~ wt + I(wt^2), data = mtcars)

# Orthogonal polynomials (preferred)
poly_model <- lm(mpg ~ poly(wt, 2), data = mtcars)

# Cubic model
cubic_model <- lm(mpg ~ poly(wt, 3), data = mtcars)

# Test polynomial terms
anova(lm(mpg ~ wt, data = mtcars),
      lm(mpg ~ poly(wt, 2), data = mtcars),
      lm(mpg ~ poly(wt, 3), data = mtcars))
```

### Spline Models

```r
library(splines)
# Natural splines
spline_model <- lm(mpg ~ ns(wt, df = 3), data = mtcars)

# B-splines
bs_model <- lm(mpg ~ bs(wt, df = 3), data = mtcars)

# Smoothing splines
library(mgcv)
gam_model <- gam(mpg ~ s(wt), data = mtcars)
```

