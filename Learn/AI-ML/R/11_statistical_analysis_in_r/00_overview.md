## Overview


Statistical analysis forms the cornerstone of data science and research methodology, providing systematic approaches to understanding patterns, relationships, and uncertainties within data. R offers comprehensive statistical capabilities through base functions and specialized packages, enabling rigorous analysis from basic descriptive statistics to advanced inferential procedures.

**Descriptive Statistics**

Descriptive statistics summarize and describe the main features of datasets without making inferences beyond the observed data. These statistics provide initial understanding of data distributions, central tendencies, variability, and potential outliers that inform subsequent analytical decisions.

Measures of central tendency include the mean, calculated using `mean()`, which represents the arithmetic average; the median, obtained through `median()`, indicating the middle value when data is ordered; and the mode, which requires custom functions or the `mfv()` function from the `modeest` package [Unverified] for the most frequently occurring value.

```r
# Central tendency measures
data <- c(12, 15, 18, 20, 22, 25, 28, 30, 35, 40)

mean(data)                    # Arithmetic mean
median(data)                  # Middle value
mean(data, trim = 0.1)        # Trimmed mean (removes extreme 10%)

# Handling missing values
data_with_na <- c(data, NA)
mean(data_with_na, na.rm = TRUE)
```

Measures of variability quantify data spread and include variance calculated by `var()`, standard deviation through `sd()`, range using `range()` or `max() - min()`, and interquartile range via `IQR()`. The coefficient of variation, calculated as standard deviation divided by mean, provides standardized variability measures for comparing datasets with different scales.

```r
# Variability measures
var(data)                     # Sample variance
sd(data)                      # Sample standard deviation
range(data)                   # Min and max values
IQR(data)                     # Interquartile range
mad(data)                     # Median absolute deviation

# Coefficient of variation
cv <- sd(data) / mean(data)
```

Distribution shape characteristics include skewness, measuring asymmetry, and kurtosis, indicating tail heaviness. These require packages like `moments` [Unverified] or can be calculated manually. Quantiles and percentiles, obtained through `quantile()`, provide detailed distribution information at specific cut points.

```r
# Distribution characteristics
quantile(data)                # Default quartiles
quantile(data, probs = seq(0, 1, 0.1))  # Deciles
summary(data)                 # Six-number summary

# Custom percentiles
quantile(data, probs = c(0.05, 0.95))   # 5th and 95th percentiles
```

The `summary()` function provides comprehensive overviews including minimum, first quartile, median, mean, third quartile, and maximum values. For data frames, `describe()` from the `psych` package [Unverified] offers extended descriptive statistics including skewness, kurtosis, and standard errors.

**Probability Distributions**

R provides extensive support for probability distributions through families of functions with consistent naming patterns: `d*()` for density/probability mass functions, `p*()` for cumulative distribution functions, `q*()` for quantile functions, and `r*()` for random number generation.

Normal distribution functions include `dnorm()` for density calculation, `pnorm()` for cumulative probabilities, `qnorm()` for quantile determination, and `rnorm()` for random sampling. These functions accept parameters for mean and standard deviation, enabling work with any normal distribution.

```r
# Normal distribution examples
x <- seq(-3, 3, length.out = 100)
density_values <- dnorm(x, mean = 0, sd = 1)

# Probability calculations
prob_less_than_1 <- pnorm(1, mean = 0, sd = 1)
critical_value <- qnorm(0.975, mean = 0, sd = 1)
random_sample <- rnorm(1000, mean = 0, sd = 1)

# Distribution visualization
plot(x, density_values, type = "l", main = "Standard Normal Distribution")
```

Other commonly used distributions include binomial (`binom`), Poisson (`pois`), exponential (`exp`), chi-square (`chisq`), t-distribution (`t`), and F-distribution (`f`). Each follows the same function naming convention with appropriate parameters for the specific distribution.

```r
# Various distribution examples
# Binomial distribution (n trials, p probability)
prob_success <- dbinom(5, size = 10, prob = 0.3)

# Poisson distribution (lambda rate parameter)
poisson_prob <- dpois(3, lambda = 2.5)

# t-distribution (df degrees of freedom)
t_critical <- qt(0.975, df = 20)

# Chi-square distribution
chi_critical <- qchisq(0.95, df = 10)
```

Distribution fitting involves determining which theoretical distribution best describes observed data. The `fitdistr()` function from the `MASS` package [Inference - commonly available in R] estimates parameters for specified distributions, while goodness-of-fit tests assess how well distributions match data.

**Hypothesis Testing**

Hypothesis testing provides systematic frameworks for making inferences about populations based on sample data. The process involves formulating null and alternative hypotheses, selecting appropriate significance levels, calculating test statistics, and interpreting p-values to make statistical decisions.

The fundamental structure includes the null hypothesis (H₀) representing no effect or difference, the alternative hypothesis (H₁) indicating the effect of interest, significance level (α) determining Type I error tolerance, and p-values indicating the probability of observing results at least as extreme as those obtained, assuming the null hypothesis is true.

One-sample tests examine whether sample statistics differ significantly from hypothesized population parameters. The `t.test()` function performs one-sample t-tests for means, while `prop.test()` handles proportion testing.

```r
# One-sample t-test
sample_data <- rnorm(30, mean = 52, sd = 8)
t_result <- t.test(sample_data, mu = 50, alternative = "two.sided")
print(t_result)

# One-sample proportion test
success_count <- 65
total_count <- 100
prop_result <- prop.test(success_count, total_count, p = 0.6)
```

Two-sample tests compare statistics between independent groups or paired observations. Independent samples t-tests use `t.test()` with separate sample vectors, while paired t-tests specify `paired = TRUE` for dependent observations.

```r
# Independent samples t-test
group1 <- rnorm(25, mean = 100, sd = 15)
group2 <- rnorm(30, mean = 105, sd = 12)
independent_t <- t.test(group1, group2, var.equal = FALSE)

# Paired samples t-test
before <- rnorm(20, mean = 80, sd = 10)
after <- before + rnorm(20, mean = 5, sd = 3)
paired_t <- t.test(before, after, paired = TRUE)
```

Assumptions testing precedes parametric tests and includes normality assessment through `shapiro.test()` or `ks.test()`, homogeneity of variance via `var.test()` or `bartlett.test()`, and independence verification through study design considerations.

**Correlation and Regression**

Correlation analysis measures the strength and direction of linear relationships between variables. Pearson correlation, calculated using `cor()`, assumes normal distributions and linear relationships, while Spearman correlation handles monotonic relationships without normality assumptions.

```r
# Correlation analysis
x <- rnorm(100, mean = 50, sd = 10)
y <- 2 * x + rnorm(100, mean = 0, sd = 5)

# Pearson correlation
pearson_cor <- cor(x, y, method = "pearson")
cor_test <- cor.test(x, y, method = "pearson")

# Spearman correlation (rank-based)
spearman_cor <- cor(x, y, method = "spearman")

# Correlation matrix for multiple variables
data_matrix <- cbind(x, y, z = x + y + rnorm(100))
cor_matrix <- cor(data_matrix)
```

Simple linear regression examines relationships between one predictor and one outcome variable through `lm()`. The function fits models using least squares estimation and provides comprehensive output including coefficients, standard errors, t-statistics, and p-values.

```r
# Simple linear regression
model <- lm(y ~ x)
summary(model)

# Model diagnostics
par(mfrow = c(2, 2))
plot(model)  # Residual plots

# Prediction
new_data <- data.frame(x = c(45, 55, 65))
predictions <- predict(model, new_data, interval = "confidence")
```

Multiple regression extends simple regression to multiple predictors, enabling control for confounding variables and examination of partial relationships. Model building involves variable selection, interaction terms, and polynomial relationships.

```r
# Multiple regression
z <- rnorm(100, mean = 30, sd = 8)
multiple_model <- lm(y ~ x + z + I(x^2))
summary(multiple_model)

# Model comparison
anova(model, multiple_model)  # Compare nested models

# Stepwise selection
step_model <- step(multiple_model, direction = "both")
```

Regression diagnostics assess model assumptions including linearity, independence, homoscedasticity, and normality of residuals. Functions like `plot()` on model objects provide diagnostic plots, while specific tests examine individual assumptions.

**ANOVA and t-tests**

Analysis of Variance (ANOVA) tests differences among three or more group means by partitioning total variance into between-group and within-group components. One-way ANOVA examines differences across levels of single factors, while factorial ANOVA handles multiple factors and their interactions.

```r
# One-way ANOVA
groups <- factor(rep(c("A", "B", "C"), each = 20))
response <- c(rnorm(20, 100, 10), rnorm(20, 105, 10), rnorm(20, 110, 10))
anova_data <- data.frame(groups, response)

anova_model <- aov(response ~ groups, data = anova_data)
summary(anova_model)

# Post-hoc comparisons
TukeyHSD(anova_model)
```

Two-way ANOVA examines main effects of two factors and their interaction effects. The model formula includes both factors and their interaction term, enabling comprehensive examination of factorial designs.

```r
# Two-way ANOVA
factor1 <- factor(rep(c("Low", "High"), each = 30))
factor2 <- factor(rep(c("Treatment", "Control"), times = 30))
response2 <- rnorm(60) + 
            as.numeric(factor1 == "High") * 2 + 
            as.numeric(factor2 == "Treatment") * 3

two_way_model <- aov(response2 ~ factor1 * factor2)
summary(two_way_model)

# Interaction plots
interaction.plot(factor1, factor2, response2)
```

ANOVA assumptions include independence of observations, normality of residuals within groups, and homogeneity of variances across groups. Violations may require transformations or alternative non-parametric approaches.

T-tests represent special cases of ANOVA for comparing two groups or testing single means against hypothesized values. They provide exact probability distributions when assumptions are met and robust alternatives when assumptions are violated.

**Non-parametric Tests**

Non-parametric tests make fewer distributional assumptions than parametric counterparts, relying on ranks or signs rather than specific probability distributions. These tests maintain validity under broader conditions but may have reduced statistical power when parametric assumptions are satisfied.

The Wilcoxon signed-rank test serves as a non-parametric alternative to the one-sample or paired t-test, examining whether median differences equal zero without assuming normality.

```r
# Wilcoxon signed-rank test (one-sample)
sample_data <- c(12, 15, 18, 20, 22, 25, 28, 30)
wilcox_one <- wilcox.test(sample_data, mu = 20, alternative = "two.sided")

# Wilcoxon signed-rank test (paired)
before <- c(10, 15, 12, 18, 20, 25, 22, 28)
after <- c(12, 18, 15, 20, 23, 28, 25, 30)
wilcox_paired <- wilcox.test(before, after, paired = TRUE)
```

The Mann-Whitney U test (Wilcoxon rank-sum test) provides a non-parametric alternative to the independent samples t-test, comparing distributions between two independent groups.

```r
# Mann-Whitney U test
group1 <- c(23, 25, 28, 30, 32, 35, 38)
group2 <- c(30, 33, 35, 38, 40, 42, 45)
mann_whitney <- wilcox.test(group1, group2, alternative = "two.sided")
```

The Kruskal-Wallis test extends non-parametric comparisons to three or more groups, serving as the non-parametric equivalent of one-way ANOVA.

```r
# Kruskal-Wallis test
group_a <- c(12, 15, 18, 20)
group_b <- c(22, 25, 28, 30)
group_c <- c(32, 35, 38, 40)

all_values <- c(group_a, group_b, group_c)
group_labels <- factor(c(rep("A", 4), rep("B", 4), rep("C", 4)))

kruskal_result <- kruskal.test(all_values ~ group_labels)
```

Chi-square tests examine associations between categorical variables or goodness-of-fit to expected distributions. The `chisq.test()` function handles both independence testing and goodness-of-fit applications.

```r
# Chi-square test of independence
contingency_table <- matrix(c(10, 20, 15, 25), nrow = 2)
chi_square <- chisq.test(contingency_table)

# Chi-square goodness-of-fit
observed <- c(18, 22, 16, 14)
expected_probs <- c(0.25, 0.25, 0.25, 0.25)
goodness_fit <- chisq.test(observed, p = expected_probs)
```

**Confidence Intervals**

Confidence intervals provide ranges of plausible values for population parameters based on sample data and specified confidence levels. These intervals quantify estimation uncertainty and support more nuanced interpretation than point estimates alone.

Confidence intervals for means depend on sample sizes and variance assumptions. For large samples or known population variance, normal distribution-based intervals apply, while t-distribution intervals handle small samples with unknown variance.

```r
# Confidence interval for mean
sample_data <- rnorm(25, mean = 100, sd = 15)
t_result <- t.test(sample_data)
confidence_interval <- t_result$conf.int

# Manual calculation
sample_mean <- mean(sample_data)
sample_se <- sd(sample_data) / sqrt(length(sample_data))
margin_error <- qt(0.975, df = length(sample_data) - 1) * sample_se
manual_ci <- c(sample_mean - margin_error, sample_mean + margin_error)
```

Confidence intervals for proportions use normal approximations for large samples or exact methods for small samples. The `prop.test()` function automatically calculates appropriate intervals.

```r
# Confidence interval for proportion
successes <- 65
trials <- 100
prop_result <- prop.test(successes, trials)
proportion_ci <- prop_result$conf.int

# Manual calculation using normal approximation
p_hat <- successes / trials
se_prop <- sqrt(p_hat * (1 - p_hat) / trials)
z_critical <- qnorm(0.975)
manual_prop_ci <- p_hat + c(-1, 1) * z_critical * se_prop
```

Confidence intervals for regression coefficients emerge automatically from `lm()` output and can be extracted using `confint()`. These intervals indicate the range of plausible values for each coefficient while controlling other variables.

```r
# Confidence intervals for regression coefficients
x <- rnorm(50, mean = 10, sd = 2)
y <- 3 + 2 * x + rnorm(50, mean = 0, sd = 1)
reg_model <- lm(y ~ x)

# Coefficient confidence intervals
coeff_ci <- confint(reg_model, level = 0.95)

# Prediction intervals
new_values <- data.frame(x = c(8, 10, 12))
pred_intervals <- predict(reg_model, new_values, interval = "prediction")
```

**Effect Sizes and Power Analysis**

Effect sizes quantify the practical significance of statistical findings by measuring the magnitude of differences or relationships in standardized units. Unlike p-values, effect sizes remain independent of sample size and provide meaningful comparisons across studies.

Cohen's d measures standardized mean differences for t-tests and represents small (0.2), medium (0.5), and large (0.8) effects according to conventional interpretations [Inference - these are commonly accepted benchmarks]. The `effsize` package [Unverified] provides convenient calculation functions.

```r
# Cohen's d for independent groups
group1 <- rnorm(25, mean = 100, sd = 15)
group2 <- rnorm(25, mean = 110, sd = 15)

# Manual calculation
pooled_sd <- sqrt(((length(group1) - 1) * var(group1) + 
                  (length(group2) - 1) * var(group2)) / 
                  (length(group1) + length(group2) - 2))
cohens_d <- (mean(group2) - mean(group1)) / pooled_sd
```

Correlation coefficients serve as effect sizes for relationship strength, with conventional interpretations of small (r = 0.1), medium (r = 0.3), and large (r = 0.5) effects [Inference - commonly accepted benchmarks]. For ANOVA, eta-squared (η²) and partial eta-squared indicate proportion of variance explained.

```r
# Effect size for ANOVA (eta-squared)
anova_model <- aov(response ~ groups, data = anova_data)
anova_summary <- summary(anova_model)

# Manual eta-squared calculation
ss_between <- anova_summary[[1]][["Sum Sq"]][1]
ss_total <- sum(anova_summary[[1]][["Sum Sq"]])
eta_squared <- ss_between / ss_total
```

Power analysis determines the probability of detecting effects of specified magnitudes given sample sizes, significance levels, and effect sizes. The `pwr` package [Unverified] provides comprehensive power analysis functions for various statistical tests.

```r
# Power analysis examples (conceptual - requires pwr package)
# Power for t-test given sample size
# power_result <- pwr.t.test(n = 25, d = 0.5, sig.level = 0.05, type = "two.sample")

# Sample size needed for desired power
# sample_size <- pwr.t.test(power = 0.8, d = 0.5, sig.level = 0.05, type = "two.sample")

# Power for correlation
# cor_power <- pwr.r.test(n = 50, r = 0.3, sig.level = 0.05)
```

Power analysis applications include determining adequate sample sizes during study planning, assessing the likelihood of detecting meaningful effects in completed studies, and interpreting non-significant results in the context of statistical power limitations.

**Key Points**

Statistical analysis in R requires understanding both theoretical foundations and practical implementation details. Descriptive statistics provide essential data summaries that inform subsequent analytical decisions and help identify potential issues requiring attention before inferential procedures.

Hypothesis testing frameworks require careful attention to assumptions, appropriate test selection, and meaningful interpretation beyond statistical significance. Effect sizes complement significance tests by quantifying practical importance and enabling meaningful comparisons across studies and contexts.

Non-parametric alternatives provide robust options when distributional assumptions are violated, though they may sacrifice some statistical power compared to parametric counterparts when assumptions are satisfied. Confidence intervals offer more nuanced parameter estimation than point estimates alone and support more informative statistical communication.

**Example**

A comprehensive statistical analysis workflow:

```r
# Comprehensive statistical analysis example
# Load and examine data
data(mtcars)
str(mtcars)
summary(mtcars)

# Descriptive statistics by group
aggregate(mpg ~ cyl, data = mtcars, FUN = function(x) c(
  n = length(x),
  mean = mean(x),
  sd = sd(x),
  median = median(x)
))

# Test assumptions
# Normality test
shapiro.test(mtcars$mpg[mtcars$cyl == 4])
shapiro.test(mtcars$mpg[mtcars$cyl == 6])
shapiro.test(mtcars$mpg[mtcars$cyl == 8])

# Homogeneity of variance
bartlett.test(mpg ~ cyl, data = mtcars)

# ANOVA if assumptions met
anova_result <- aov(mpg ~ factor(cyl), data = mtcars)
summary(anova_result)

# Post-hoc comparisons
TukeyHSD(anova_result)

# Effect size calculation
anova_summary <- summary(anova_result)
ss_between <- anova_summary[[1]][["Sum Sq"]][1]
ss_total <- sum(anova_summary[[1]][["Sum Sq"]])
eta_squared <- ss_between / ss_total

# Non-parametric alternative if assumptions violated
kruskal.test(mpg ~ cyl, data = mtcars)

# Correlation and regression analysis
cor.test(mtcars$mpg, mtcars$wt)
reg_model <- lm(mpg ~ wt + hp + cyl, data = mtcars)
summary(reg_model)
confint(reg_model)

# Model diagnostics
par(mfrow = c(2, 2))
plot(reg_model)
```

**Conclusion**

Statistical analysis in R encompasses a comprehensive toolkit for exploring, testing, and modeling data relationships. The combination of descriptive and inferential procedures enables thorough data understanding while rigorous hypothesis testing frameworks support evidence-based conclusions.

Mastery of these statistical foundations enables appropriate method selection, assumption verification, and meaningful result interpretation. The integration of effect sizes and power considerations with traditional significance testing promotes more complete and nuanced statistical communication.

Understanding both parametric and non-parametric approaches ensures analytical flexibility across diverse data types and distributional characteristics. The emphasis on assumption testing and diagnostic procedures supports robust analytical practices that enhance the reliability and validity of statistical conclusions.

Modern statistical practice increasingly emphasizes effect sizes, confidence intervals, and practical significance alongside traditional hypothesis testing, reflecting a more comprehensive approach to statistical inference and scientific communication.

---

