## Kurtosis

### Definition

Kurtosis is the standardized fourth moment of a probability distribution, measuring the "tailedness" of the distribution relative to its spread. It quantifies the propensity of a distribution to produce outliers.

$$\text{Kurt}(X) = E\left[\left(\frac{X - \mu}{\sigma}\right)^4\right] = \frac{\mu_4}{\sigma^4}$$

where $\mu_4 = E[(X-\mu)^4]$ is the fourth central moment and $\sigma$ is the standard deviation.

### Relationship to the Fourth Moment

Kurtosis builds on the sequence of moments used to characterize a distribution's shape:

- 1st moment → mean (location)
- 2nd central moment → variance (spread)
- 3rd standardized moment → skewness (asymmetry)
- 4th standardized moment → kurtosis (tail weight)

Because the fourth power heavily amplifies large deviations from the mean, kurtosis is disproportionately sensitive to values far from $\mu$. This makes it primarily a measure of extreme value behavior rather than central shape.

### Excess Kurtosis

The raw kurtosis of a normal distribution equals 3. To make comparisons intuitive, **excess kurtosis** subtracts this baseline:

$$\text{Excess Kurt}(X) = \frac{\mu_4}{\sigma^4} - 3$$

Most statistical software (NumPy's `scipy.stats.kurtosis`, pandas `.kurt()`) reports excess kurtosis by default. [Unverified — exact default behavior may vary by library version and should be checked against current documentation before being relied upon in code.]

### Classification by Tail Type

**Mesokurtic** (excess kurtosis ≈ 0)
Tail behavior similar to a normal distribution. The Gaussian is the reference case.

**Leptokurtic** (excess kurtosis > 0)
Heavier tails and a sharper peak than normal. Higher probability of extreme outliers. Examples: Student's t-distribution, Laplace distribution, many financial return series.

**Platykurtic** (excess kurtosis < 0)
Lighter tails and a flatter peak than normal. Lower probability of extreme outliers. Example: uniform distribution (excess kurtosis = −1.2).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380" font-family="sans-serif">
  <text x="320" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Kurtosis: Tail Weight Comparison (svg_diagram)</text>
  <line x1="60" y1="320" x2="600" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="320" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="600" y="340" font-size="12" fill="#333" text-anchor="end">x</text>
  <text x="45" y="55" font-size="12" fill="#333" text-anchor="end">density</text>

  <path d="M 90,318 C 150,315 190,250 230,140 C 260,60 280,40 330,40 C 380,40 400,60 430,140 C 470,250 510,315 570,318" fill="none" stroke="#e63946" stroke-width="2.5" />
  <path d="M 90,315 C 160,300 240,180 330,60 C 420,180 500,300 570,315" fill="none" stroke="#1d3557" stroke-width="2.5" stroke-dasharray="1,0" />
  <path d="M 90,290 Q 200,270 330,150 Q 460,270 570,290" fill="none" stroke="#2a9d8f" stroke-width="2.5" />

  <rect x="420" y="60" width="16" height="12" fill="#e63946" />
  <text x="442" y="70" font-size="12" fill="#222">Leptokurtic (excess &gt; 0) — heavy tails, sharp peak</text>

  <rect x="420" y="85" width="16" height="12" fill="#1d3557" />
  <text x="442" y="95" font-size="12" fill="#222">Mesokurtic (excess = 0) — normal</text>

  <rect x="420" y="110" width="16" height="12" fill="#2a9d8f" />
  <text x="442" y="120" font-size="12" fill="#222">Platykurtic (excess &lt; 0) — light tails, flat peak</text>
</svg>

### Sample Kurtosis Estimator

For a sample $x_1, \dots, x_n$, the biased sample estimator is:

$$g_2 = \frac{\frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{x})^4}{\left(\frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{x})^2\right)^2} - 3$$

A bias-corrected version, sometimes called $G_2$, adjusts for sample size:

$$G_2 = \frac{n-1}{(n-2)(n-3)}\left[(n+1)g_2 + 6\right]$$

[Inference] The correction term matters most for small $n$; as $n$ grows large, $g_2$ and $G_2$ converge. This follows from the algebraic structure of the formula rather than from a cited empirical source.

### Worked Example

Given a small sample: $\{2, 4, 4, 4, 5, 5, 7, 9\}$

1. Mean: $\bar{x} = 5$
2. Deviations: $\{-3, -1, -1, -1, 0, 0, 2, 4\}$
3. Fourth powers: $\{81, 1, 1, 1, 0, 0, 16, 256\}$, sum $= 356$
4. Squared deviations: $\{9, 1, 1, 1, 0, 0, 4, 16\}$, sum $= 32$
5. $\mu_4 = 356/8 = 44.5$
6. $\sigma^2 = 32/8 = 4$, so $\sigma^4 = 16$
7. Raw kurtosis $= 44.5 / 16 = 2.78$
8. Excess kurtosis $= 2.78 - 3 = -0.22$

This sample is mildly platykurtic relative to normal, though with $n=8$ this estimate carries substantial sampling variability. [Inference] A sample this small does not provide strong evidence about the population's true kurtosis; this is a reasoned statistical caveat, not a confirmed property of this specific dataset's origin.

### Relevance to Machine Learning

**Outlier sensitivity**
High-kurtosis features indicate a greater proportion of extreme values, which can disproportionately influence models sensitive to outliers (e.g., linear regression, k-means, PCA). [Inference] This connection follows from the definition of kurtosis as a moment weighted by fourth powers, which mathematically amplifies extreme deviations.

**Feature engineering and diagnostics**
Kurtosis is used alongside skewness during exploratory data analysis to assess whether a feature deviates from normality before applying models that assume Gaussian-distributed inputs (e.g., Gaussian Naive Bayes, LDA).

**Model residual diagnostics**
In regression, examining the kurtosis of residuals can help assess whether error assumptions (e.g., normally distributed errors) are reasonable. Leptokurtic residuals suggest heavier-than-expected tails, which [Inference] may indicate the presence of unmodeled outliers or a misspecified model — this is a common diagnostic heuristic rather than a rule with formal statistical proof presented here.

**Financial and risk modeling**
Leptokurtic distributions are frequently discussed in quantitative finance because heavy tails imply higher probability of extreme gains or losses compared to a normal-distribution assumption. [Unverified] Specific claims about which asset classes exhibit leptokurtosis depend on the dataset and time period examined and are not verified here.

### Kurtosis vs. Skewness

| Aspect | Skewness | Kurtosis |
|---|---|---|
| Moment order | 3rd | 4th |
| Measures | Asymmetry | Tail weight / peakedness |
| Normal distribution value | 0 | 3 (raw) / 0 (excess) |
| Sign meaning | Direction of asymmetry | N/A (magnitude of tail extremity) |

### Common Pitfalls

- Confusing raw kurtosis (baseline 3) with excess kurtosis (baseline 0) when interpreting software output — always check which convention a given library uses. [Unverified] Convention varies by tool and should be confirmed in current documentation rather than assumed.
- Treating "peakedness" as the primary meaning of kurtosis; contemporary statistical literature generally emphasizes tail behavior over peak sharpness as the more accurate interpretation. [Inference] This reflects a documented shift in how kurtosis is explained in some statistics texts, though I cannot verify the full extent of consensus across the field without a specific citation.
- Applying kurtosis-based normality judgments to very small samples, where the estimator has high variance.

### Related Topics

- Jarque-Bera test for joint testing of skewness and kurtosis
- Heavy-tailed distributions (Student's t, Pareto, Cauchy)
- Moment generating functions and their relation to higher moments
- Robust statistics and outlier-resistant estimators
- Q-Q plots for visual normality assessment