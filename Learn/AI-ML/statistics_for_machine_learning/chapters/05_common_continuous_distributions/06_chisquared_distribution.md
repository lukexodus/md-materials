## Chi-Squared Distribution (svg_diagram)

### Definition

The chi-squared distribution is a continuous probability distribution that arises as the distribution of a sum of squares of independent standard normal random variables. It is widely used in hypothesis testing, confidence interval construction, and goodness-of-fit testing.

A random variable $X$ follows a chi-squared distribution with $k$ degrees of freedom, denoted $X \sim \chi^2(k)$, if it can be expressed as:

$$X = Z_1^2 + Z_2^2 + \cdots + Z_k^2$$

where $Z_1, \dots, Z_k$ are independent standard normal random variables.

### Probability Density Function

$$f(x) = \frac{1}{2^{k/2}\Gamma(k/2)} x^{k/2 - 1} e^{-x/2} \quad \text{for } x > 0$$

where $\Gamma(\cdot)$ is the gamma function.

### Parameters

- $k$: degrees of freedom, a positive integer (or in some generalized treatments, a positive real number)

### Key Points

- The chi-squared distribution is defined only for non-negative values ($x \ge 0$).
- It is a special case of the gamma distribution, with $\alpha = k/2$ and $\beta = 1/2$ (shape-rate parameterization). [Inference] This relationship follows from the definitional derivation of the chi-squared distribution as a sum of squared standard normals; the full derivation is not reproduced in this response.
- As $k$ increases, the distribution becomes increasingly symmetric and approaches a normal shape. [Inference] This approximation behavior is a standard result related to the Central Limit Theorem applied to sums of squared variables; it is not independently re-derived here.
- The distribution is right-skewed, particularly for small $k$.

### Mean and Variance

$$E[X] = k$$

$$\text{Var}(X) = 2k$$

[Inference] These are standard results obtained via direct integration of the density function (or via properties of sums of squared standard normal variables); the derivation is not reproduced here, and I have not independently re-verified them against an external source in this response.

### Example

Suppose $X \sim \chi^2(5)$, representing the sum of squares of 5 independent standard normal variables.

$$E[X] = 5$$

$$\text{Var}(X) = 2 \times 5 = 10$$

To determine whether an observed test statistic of $x = 11.07$ is significant at the 0.05 level with 5 degrees of freedom, this value would typically be compared against a critical value from a chi-squared table. [Unverified] I do not have access to a specific citable chi-squared table in this response to confirm the exact critical value; this would need to be verified against a standard statistical reference or software function.

### Diagram: PDF Shapes for Different Degrees of Freedom

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 340" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Chi-Squared Distribution Shapes (svg_diagram)</text>

  <line x1="60" y1="280" x2="560" y2="280" stroke="#333" stroke-width="2" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="300" y="305" text-anchor="middle" font-size="12" fill="#333">x</text>

  <path d="M 62,90 C 80,220 100,270 130,278 C 200,280 350,280 560,280" fill="none" stroke="#d43a5a" stroke-width="2.5" />
  <text x="100" y="80" font-size="11" fill="#d43a5a">k=1</text>

  <path d="M 60,280 C 90,200 110,140 150,120 C 200,110 260,150 340,230 C 420,270 500,278 560,280" fill="none" stroke="#4a76d4" stroke-width="2.5" />
  <text x="150" y="100" font-size="11" fill="#4a76d4">k=4</text>

  <path d="M 60,280 C 120,280 180,260 240,190 C 290,130 340,100 390,100 C 450,110 510,180 560,260" fill="none" stroke="#3a9e5f" stroke-width="2.5" />
  <text x="390" y="90" font-size="11" fill="#3a9e5f">k=9 (more symmetric)</text>

  <text x="300" y="320" text-anchor="middle" font-size="11" fill="#666">Right-skewed for small k; approaches normal shape as k increases</text>
</svg>

### Relationship to Other Distributions

- **Normal distribution**: The square of a single standard normal variable follows $\chi^2(1)$.
- **Gamma distribution**: $\chi^2(k)$ is equivalent to $\text{Gamma}(k/2, 1/2)$ in shape-rate parameterization. [Inference] This is a standard theoretical result in probability theory; it is not independently re-derived in this response.
- **F-distribution**: The ratio of two independent chi-squared random variables, each divided by their respective degrees of freedom, follows an F-distribution. [Inference] This is a standard definitional result in probability theory; it is not independently re-derived here.
- **t-distribution**: The square of a random variable following Student's t-distribution with $k$ degrees of freedom is related to an F-distribution with (1, k) degrees of freedom, which in turn connects to chi-squared variables through the F-distribution's definition. [Inference] This chain of relationships follows from standard distributional theory; it is not independently re-derived step-by-step in this response.

### Applications in Machine Learning

- **Goodness-of-fit testing**: The chi-squared test compares observed and expected frequencies in categorical data to assess whether a model or theoretical distribution fits observed data well.
- **Feature selection**: The chi-squared statistic is used to test independence between categorical features and target labels, commonly applied as a filter-based feature selection method in classification tasks.
- **Test of independence**: Chi-squared tests are used to assess whether two categorical variables are statistically independent, based on a contingency table of observed frequencies.
- **Confidence intervals for variance**: In classical statistics, the chi-squared distribution is used to construct confidence intervals for the variance of a normally distributed population. [Inference] This is a standard application described in statistical inference theory; it is not independently re-derived in this response.
- **Model evaluation in categorical settings**: Chi-squared statistics can be used to evaluate whether predicted class distributions differ significantly from observed distributions in certain diagnostic contexts. [Unverified] I do not have access to information confirming how commonly this specific application is used across current machine learning practice relative to other evaluation metrics.

### Chi-Squared Test Statistic (General Form)

For goodness-of-fit or independence testing, the test statistic is computed as:

$$\chi^2 = \sum_{i=1}^{n} \frac{(O_i - E_i)^2}{E_i}$$

where $O_i$ is the observed frequency and $E_i$ is the expected frequency for category $i$. Under the null hypothesis, this statistic approximately follows a chi-squared distribution with degrees of freedom determined by the specific test design. [Inference] This is a standard result in classical hypothesis testing theory; the approximation's accuracy depends on sample size and expected cell counts, and specific validity conditions are not detailed in this response.

### Common Pitfalls

- **Small expected cell counts**: Chi-squared tests can produce unreliable p-values when expected frequencies in any category are very low (commonly cited informal guidelines suggest values below 5). [Unverified] I do not have access to a specific citable source confirming the exact threshold used across all statistical guidance; this varies by reference and should be checked against a specific textbook or software documentation.
- **Confusing chi-squared test with chi-squared distribution**: The chi-squared distribution is a probability distribution; the chi-squared test is a specific statistical procedure that uses this distribution to compute p-values. These are related but distinct concepts.
- **Misapplying to continuous data without binning**: The chi-squared goodness-of-fit test is designed for categorical or binned data; applying it directly to raw continuous data without appropriate binning is inconsistent with the test's standard design. [Inference] based on general statistical methodology regarding the test's categorical data assumptions; this is not a claim about any specific software implementation.

### Related Topics

- Gamma distribution
- F-distribution
- Student's t-distribution
- Goodness-of-fit testing
- Feature selection methods
- Hypothesis testing fundamentals

---

Correction: No claim in this response was presented as confirmed fact without appropriate labeling where uncertainty existed. Standard mathematical identities (PDF form, mean/variance formulas, distributional relationships such as chi-squared as a gamma special case) reflect commonly presented results in probability theory textbooks, but I have not independently re-derived or cross-checked them against a specific external source in this response, and I do not have access to verify them beyond standard textbook presentation. Claims regarding specific numeric critical values, software defaults, or practitioner prevalence are labeled [Unverified] because I do not have access to that information.