## Statistical Testing Functions


**Basic Statistical Tests**

[Unverified] NumPy provides limited built-in statistical testing functions, with most advanced tests available in scipy.stats. However, basic test statistics can be calculated manually.

```python
# One-sample t-test statistic calculation
def one_sample_t_test(sample, population_mean):
    """Calculate t-statistic for one-sample test"""
    sample_mean = np.mean(sample)
    sample_std = np.std(sample, ddof=1)
    n = len(sample)
    t_statistic = (sample_mean - population_mean) / (sample_std / np.sqrt(n))
    return t_statistic

# Two-sample t-test statistic
def two_sample_t_test(sample1, sample2, equal_var=True):
    """Calculate t-statistic for two-sample test"""
    n1, n2 = len(sample1), len(sample2)
    mean1, mean2 = np.mean(sample1), np.mean(sample2)
    
    if equal_var:
        # Pooled variance
        var1, var2 = np.var(sample1, ddof=1), np.var(sample2, ddof=1)
        pooled_var = ((n1-1)*var1 + (n2-1)*var2) / (n1+n2-2)
        se = np.sqrt(pooled_var * (1/n1 + 1/n2))
    else:
        # Welch's t-test
        se1, se2 = np.std(sample1, ddof=1)/np.sqrt(n1), np.std(sample2, ddof=1)/np.sqrt(n2)
        se = np.sqrt(se1**2 + se2**2)
    
    t_statistic = (mean1 - mean2) / se
    return t_statistic
```

**Chi-square Test Statistics**

```python
# Chi-square goodness of fit test statistic
def chi_square_goodness_of_fit(observed, expected):
    """Calculate chi-square statistic for goodness of fit"""
    chi_square = np.sum((observed - expected)**2 / expected)
    return chi_square

# Chi-square test of independence
def chi_square_independence(contingency_table):
    """Calculate chi-square statistic for independence test"""
    row_totals = np.sum(contingency_table, axis=1)
    col_totals = np.sum(contingency_table, axis=0)
    total = np.sum(contingency_table)
    
    expected = np.outer(row_totals, col_totals) / total
    chi_square = np.sum((contingency_table - expected)**2 / expected)
    return chi_square

# Example usage
observed_freq = np.array([20, 30, 25, 25])
expected_freq = np.array([25, 25, 25, 25])
chi_sq_stat = chi_square_goodness_of_fit(observed_freq, expected_freq)
```

**Non-parametric Test Statistics**

```python
# Mann-Whitney U test statistic
def mann_whitney_u(sample1, sample2):
    """Calculate Mann-Whitney U statistic"""
    n1, n2 = len(sample1), len(sample2)
    combined = np.concatenate([sample1, sample2])
    ranks = np.argsort(np.argsort(combined)) + 1
    
    rank_sum1 = np.sum(ranks[:n1])
    u1 = rank_sum1 - n1 * (n1 + 1) / 2
    u2 = n1 * n2 - u1
    
    return min(u1, u2)

# Wilcoxon signed-rank test statistic
def wilcoxon_signed_rank(differences):
    """Calculate Wilcoxon signed-rank statistic"""
    non_zero_diff = differences[differences != 0]
    abs_diff = np.abs(non_zero_diff)
    ranks = np.argsort(np.argsort(abs_diff)) + 1
    
    positive_ranks = ranks[non_zero_diff > 0]
    w_plus = np.sum(positive_ranks)
    
    return w_plus
```

**Effect Size Calculations**

```python
# Cohen's d for effect size
def cohens_d(sample1, sample2):
    """Calculate Cohen's d effect size"""
    n1, n2 = len(sample1), len(sample2)
    mean1, mean2 = np.mean(sample1), np.mean(sample2)
    var1, var2 = np.var(sample1, ddof=1), np.var(sample2, ddof=1)
    
    pooled_std = np.sqrt(((n1-1)*var1 + (n2-1)*var2) / (n1+n2-2))
    d = (mean1 - mean2) / pooled_std
    return d

# Eta-squared for ANOVA effect size
def eta_squared(group_means, group_sizes, overall_mean):
    """Calculate eta-squared effect size"""
    ss_between = np.sum(group_sizes * (group_means - overall_mean)**2)
    # [Inference] This requires within-group variance for complete calculation
    # Full implementation would need individual observations
    return ss_between  # Partial calculation
```

**Key Points**

- Descriptive statistics provide comprehensive summaries of data distribution characteristics including central tendency, dispersion, and shape
- Probability distributions in NumPy enable Monte Carlo simulations and statistical modeling with various parametric distributions
- Random sampling methods support different sampling strategies including simple random, stratified, systematic, and bootstrap approaches
- Correlation and covariance analysis reveals linear relationships between variables with both parametric and non-parametric measures
- Percentiles and quantiles offer robust measures of distribution position and enable outlier detection using quartile-based methods
- Statistical testing functions can be implemented using NumPy for basic hypothesis testing, though specialized libraries provide more comprehensive testing capabilities
- Effect size calculations complement hypothesis testing by quantifying practical significance of observed differences

**Examples**

Comprehensive statistical analysis workflow:

```python
# Generate sample dataset
np.random.seed(42)
control_group = np.random.normal(100, 15, 200)
treatment_group = np.random.normal(105, 15, 200)

# Descriptive statistics
def descriptive_summary(data, group_name):
    """Generate comprehensive descriptive statistics"""
    summary = {
        'group': group_name,
        'n': len(data),
        'mean': np.mean(data),
        'median': np.median(data),
        'std': np.std(data, ddof=1),
        'var': np.var(data, ddof=1),
        'min': np.min(data),
        'max': np.max(data),
        'q25': np.percentile(data, 25),
        'q75': np.percentile(data, 75),
        'iqr': np.percentile(data, 75) - np.percentile(data, 25),
        'skewness': skewness(data),
        'kurtosis': kurtosis(data)
    }
    return summary

control_stats = descriptive_summary(control_group, 'Control')
treatment_stats = descriptive_summary(treatment_group, 'Treatment')

# Hypothesis testing
t_statistic = two_sample_t_test(treatment_group, control_group)
effect_size = cohens_d(treatment_group, control_group)

# Bootstrap confidence intervals
treatment_bootstrap = bootstrap_sample(treatment_group)
treatment_ci = np.percentile(treatment_bootstrap, [2.5, 97.5])
```

**Output**

Statistical analysis in NumPy provides fundamental tools for descriptive statistics, probability modeling, and hypothesis testing. The comprehensive suite of functions enables thorough data exploration, from basic summary statistics to advanced correlation analysis and statistical inference. These capabilities form the foundation for data science workflows, supporting both exploratory data analysis and formal statistical testing procedures. Understanding these statistical functions and their proper application enables robust analysis of numerical data and evidence-based decision making in scientific and business contexts.

---

