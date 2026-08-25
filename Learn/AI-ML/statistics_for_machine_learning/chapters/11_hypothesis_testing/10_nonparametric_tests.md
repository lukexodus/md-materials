## Nonparametric Tests

### Overview

Nonparametric tests are statistical methods that do not assume the data follows a specific probability distribution, most notably not requiring normality. They typically operate on ranks or signs rather than raw values, making them useful when distributional assumptions of parametric tests (like the t-test or ANOVA) are violated, when sample sizes are small, or when data is ordinal rather than interval/ratio scale. In machine learning, nonparametric tests are commonly used for comparing model performance, validating feature distributions, and analyzing data that departs from normality.

### When to Use Nonparametric Tests

- Data is ordinal or ranked rather than continuous
- Sample size is small and normality cannot be reasonably assumed
- Data contains significant outliers that would distort parametric test results
- The underlying distribution is unknown or clearly non-normal
- Homogeneity of variance assumptions required by parametric tests are violated

Nonparametric tests generally trade some statistical power for reduced assumptions. When parametric assumptions genuinely hold, parametric tests are typically more powerful at detecting true effects [Inference — this is standard statistical guidance regarding the power tradeoff between parametric and nonparametric methods; not verified against a specific source in this conversation].

### Common Nonparametric Tests — Overview Table

| Test | Parametric Equivalent | Use Case |
| --- | --- | --- |
| Mann-Whitney U test | Independent samples t-test | Compare two independent groups |
| Wilcoxon signed-rank test | Paired samples t-test | Compare two paired/related samples |
| Kruskal-Wallis test | One-way ANOVA | Compare 3+ independent groups |
| Friedman test | Repeated measures ANOVA | Compare 3+ related groups |
| Spearman's rank correlation | Pearson correlation | Monotonic relationship between variables |
| Chi-squared test | — | Test independence/association in categorical data |
| Sign test | One-sample t-test | Test median of paired differences |

### Mann-Whitney U Test

Tests whether two independent samples come from the same distribution, commonly interpreted as a test of whether one population tends to have larger values than the other.

**Hypotheses:**

$$H_0: \text{The two populations have the same distribution}$$



$$H_1: \text{The two populations differ in distribution (or location)}$$

**Procedure:** Combine both samples, rank all values, sum the ranks for each group, and compute the U statistic:

$$U_1 = n_1 n_2 + \frac{n_1(n_1+1)}{2} - R_1$$

where $n_1, n_2$ are the sample sizes and $R_1$ is the sum of ranks in group 1. For large samples, the U statistic is approximately normally distributed, allowing a z-based approximation for significance testing.

### Wilcoxon Signed-Rank Test

Used for paired data (e.g., before/after measurements on the same subjects) to test whether the median difference between pairs is zero.

**Procedure:** Compute differences between paired observations, rank the absolute values of nonzero differences, sum ranks separately for positive and negative differences, and use the smaller sum as the test statistic $W$.

$$H_0: \text{median of paired differences} = 0$$

This test is a common alternative to the paired t-test when the differences are not normally distributed.

### Kruskal-Wallis Test

Extends the Mann-Whitney U test to three or more independent groups, serving as a nonparametric alternative to one-way ANOVA.

**Test statistic:**

$$H = \frac{12}{N(N+1)} \sum_{i=1}^{k} \frac{R_i^2}{n_i} - 3(N+1)$$

where $N$ is the total sample size across all groups, $k$ is the number of groups, $n_i$ is the size of group $i$, and $R_i$ is the sum of ranks in group $i$.

Under $H_0$, the $H$ statistic approximately follows a chi-squared distribution with $k-1$ degrees of freedom. Like ANOVA, a significant Kruskal-Wallis result indicates a difference exists among groups but does not identify which specific groups differ — post-hoc tests such as Dunn's test are used for that purpose.

### Friedman Test

A nonparametric alternative to repeated-measures ANOVA, used when the same subjects (or matched blocks) are measured under three or more conditions.

$$H_0: \text{no difference in central tendency across the related conditions}$$

Commonly used in machine learning to compare multiple algorithms across multiple datasets, where each dataset acts as a "block" and each algorithm as a "treatment." [Inference — this is a widely referenced use case for the Friedman test in ML algorithm comparison literature, not confirmed against a specific source here]

### Spearman's Rank Correlation

Measures the strength and direction of a monotonic relationship between two variables, based on ranks rather than raw values.

$$\rho = 1 - \frac{6 \sum d_i^2}{n(n^2-1)}$$

where $d_i$ is the difference between the ranks of corresponding values in the two variables, and $n$ is the number of observations. $\rho$ ranges from $-1$ to $1$, with values near $\pm 1$ indicating strong monotonic association.

Spearman's correlation captures monotonic (not necessarily linear) relationships, distinguishing it from Pearson's correlation coefficient, which specifically measures linear association.

### Chi-Squared Test of Independence

Tests whether two categorical variables are statistically independent, based on comparing observed frequencies to frequencies expected under independence.

$$\chi^2 = \sum \frac{(O_i - E_i)^2}{E_i}$$

where $O_i$ is the observed frequency and $E_i$ is the expected frequency under $H_0$ for each cell of a contingency table.

### Diagram: Choosing a Nonparametric Test

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 420">
<text x="320" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Nonparametric test selection guide (svg_diagram)</text>
<rect x="240" y="45" width="160" height="45" rx="6" fill="#e0e7ff" stroke="#4338ca" stroke-width="1.5" />
<text x="320" y="72" text-anchor="middle" font-size="12" fill="#1a1a1a">How many groups?</text>
<line x1="280" y1="90" x2="150" y2="130" stroke="#333" stroke-width="1.3" />
<text x="200" y="110" font-size="11" fill="#333">Two</text>
<line x1="360" y1="90" x2="490" y2="130" stroke="#333" stroke-width="1.3" />
<text x="440" y="110" font-size="11" fill="#333">3+</text>
<rect x="60" y="130" width="180" height="45" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
<text x="150" y="157" text-anchor="middle" font-size="12" fill="#1a1a1a">Independent or paired?</text>
<rect x="410" y="130" width="180" height="45" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" />
<text x="500" y="157" text-anchor="middle" font-size="12" fill="#1a1a1a">Independent or related?</text>
<line x1="120" y1="175" x2="80" y2="220" stroke="#333" stroke-width="1.2" />
<line x1="180" y1="175" x2="220" y2="220" stroke="#333" stroke-width="1.2" />
<line x1="470" y1="175" x2="430" y2="220" stroke="#333" stroke-width="1.2" />
<line x1="530" y1="175" x2="570" y2="220" stroke="#333" stroke-width="1.2" />
<rect x="10" y="220" width="150" height="50" rx="6" fill="#f3f4f6" stroke="#4b5563" stroke-width="1.3" />
<text x="85" y="240" text-anchor="middle" font-size="11" fill="#1a1a1a">Independent:</text>
<text x="85" y="255" text-anchor="middle" font-size="11" fill="#1a1a1a">Mann-Whitney U</text>
<rect x="170" y="220" width="150" height="50" rx="6" fill="#f3f4f6" stroke="#4b5563" stroke-width="1.3" />
<text x="245" y="240" text-anchor="middle" font-size="11" fill="#1a1a1a">Paired:</text>
<text x="245" y="255" text-anchor="middle" font-size="11" fill="#1a1a1a">Wilcoxon signed-rank</text>
<rect x="360" y="220" width="150" height="50" rx="6" fill="#f3f4f6" stroke="#4b5563" stroke-width="1.3" />
<text x="435" y="240" text-anchor="middle" font-size="11" fill="#1a1a1a">Independent:</text>
<text x="435" y="255" text-anchor="middle" font-size="11" fill="#1a1a1a">Kruskal-Wallis</text>
<rect x="520" y="220" width="110" height="50" rx="6" fill="#f3f4f6" stroke="#4b5563" stroke-width="1.3" />
<text x="575" y="240" text-anchor="middle" font-size="11" fill="#1a1a1a">Related:</text>
<text x="575" y="255" text-anchor="middle" font-size="11" fill="#1a1a1a">Friedman</text>
</svg>

### Worked Example — Mann-Whitney U Test

Two feature-selection methods produce validation F1-scores across 6 independent runs each:

| Method A | Method B |
| --- | --- |
| 0.71 | 0.66 |
| 0.74 | 0.69 |
| 0.70 | 0.65 |
| 0.76 | 0.68 |
| 0.73 | 0.67 |
| 0.75 | 0.70 |

Combining and ranking all 12 values, then summing ranks per group, gives the basis for the U statistic. I have not carried out this ranking and summation here, so I cannot state a specific U value. I cannot verify a numeric result without performing the full calculation, and I will not present an estimated number as fact.

The general approach: compute $U_1$ and $U_2$ from rank sums, take the smaller value, and compare against critical values for $n_1=6, n_2=6$, or compute an exact/asymptotic p-value via statistical software.

### Python Implementation Example

```python
from scipy import stats

method_a = [0.71, 0.74, 0.70, 0.76, 0.73, 0.75]
method_b = [0.66, 0.69, 0.65, 0.68, 0.67, 0.70]

u_stat, p_value = stats.mannwhitneyu(method_a, method_b, alternative='two-sided')

print(f"U-statistic: {u_stat}")
print(f"p-value: {p_value:.6f}")
```

I have not executed this code, so I cannot verify its numeric output. [Unverified] Library behavior can also vary across `scipy` versions and installation environments, and this is not guaranteed to produce identical results in all settings. [Inference]

### Nonparametric Tests in Machine Learning Contexts

- **Comparing classifiers across multiple datasets**: the Friedman test followed by a post-hoc test (e.g., Nemenyi test) is a commonly referenced approach for comparing multiple algorithms across multiple benchmark datasets [Inference — this reflects a commonly cited methodology in ML benchmarking literature; not confirmed against a specific source in this conversation]
- **Feature ranking**: Spearman correlation is used to assess monotonic relationships between features and targets, particularly for ordinal or non-linear associations
- **A/B testing with non-normal metrics**: Mann-Whitney U test is used when outcome metrics (e.g., time-on-page, revenue) are heavily skewed
- **Categorical feature association**: chi-squared tests assess independence between categorical features and target labels, informing feature selection

### Advantages and Limitations

**Advantages:**

- Fewer distributional assumptions, making them robust to non-normality
- Less sensitive to outliers, since they operate on ranks rather than raw magnitudes
- Applicable to ordinal data where parametric tests are not well-suited

**Limitations:**

- Generally lower statistical power than parametric equivalents when parametric assumptions actually hold [Inference]
- Test on distribution/location shifts rather than means directly, which can complicate interpretation
- Tied ranks require correction procedures that add computational and conceptual complexity
- Effect size interpretation is less direct than with parametric tests

### **Key Points**

- Nonparametric tests avoid assumptions of normality and are typically rank-based
- Each nonparametric test has a corresponding parametric analog it can substitute for under specific conditions
- Nonparametric tests generally trade statistical power for reduced distributional assumptions [Inference]
- Significant results in group-comparison nonparametric tests (Kruskal-Wallis, Friedman) require post-hoc testing to identify specific group differences
- Choice between parametric and nonparametric tests should be guided by sample size, data type (ordinal vs. continuous), and whether distributional assumptions are reasonably met

### **Related Topics**

- F-test and ANOVA (parametric equivalents)
- Post-hoc tests: Dunn's test, Nemenyi test
- Chi-squared goodness-of-fit test
- Bootstrap methods and permutation tests
- Effect size measures for nonparametric tests (e.g., rank-biserial correlation)
- Statistical power and sample size considerations
- Assumption checking: Shapiro-Wilk test, Levene's test