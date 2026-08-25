## Confidence Interval for the Mean

### Overview

This topic covers the confidence interval for a population mean $\mu$, extending the general confidence interval framework to the specific and most commonly taught case of estimating a mean from sample data. Two primary scenarios are addressed: known population variance and unknown population variance.

This is standard content found consistently across mathematical statistics textbooks.

### Case 1 — Known Population Variance

For $X_1, \ldots, X_n \sim N(\mu, \sigma^2)$ with $\sigma^2$ known, the sample mean $\bar{X}$ has sampling distribution:

$$\bar{X} \sim N\left(\mu, \frac{\sigma^2}{n}\right)$$

Standardizing:

$$Z = \frac{\bar{X}-\mu}{\sigma/\sqrt{n}} \sim N(0,1)$$

The $100(1-\alpha)\%$ confidence interval for $\mu$ is:

$$\bar{X} \pm z_{\alpha/2}\cdot\frac{\sigma}{\sqrt{n}}$$

Common critical values:

| Confidence Level | $\alpha$ | $z_{\alpha/2}$ |
| --- | --- | --- |
| 90% | 0.10 | 1.645 |
| 95% | 0.05 | 1.96 |
| 99% | 0.01 | 2.576 |

These are standard tabulated values from the standard normal distribution and are directly verifiable by computing the inverse standard normal CDF.

### Case 2 — Unknown Population Variance

When $\sigma^2$ is unknown, it is estimated using the sample variance:

$$S^2 = \frac{1}{n-1}\sum_{i=1}^n (X_i - \bar{X})^2$$

The pivotal quantity becomes:

$$T = \frac{\bar{X}-\mu}{S/\sqrt{n}} \sim t_{n-1}$$

which follows a $t$-distribution with $n-1$ degrees of freedom rather than a standard normal distribution. The confidence interval is:

$$\bar{X} \pm t_{\alpha/2,\,n-1}\cdot\frac{S}{\sqrt{n}}$$

The $t$-distribution has heavier tails than the normal distribution, which widens the interval to account for the added uncertainty from estimating $\sigma^2$. As $n \to \infty$, $t_{n-1}$ converges to $N(0,1)$, so the two methods converge for large samples. This is a standard, well-established mathematical result.

### Worked Example

Suppose a sample of $n = 25$ observations yields $\bar{X} = 50$ and $S = 10$, with $\sigma^2$ unknown. Constructing a 95% confidence interval:

Degrees of freedom: $n - 1 = 24$

$t_{0.025, 24} \approx 2.064$ (standard tabulated value)

$$50 \pm 2.064 \cdot \frac{10}{\sqrt{25}} = 50 \pm 2.064(2) = 50 \pm 4.128$$

Resulting interval: $(45.87,\ 54.13)$

This calculation follows directly from the formula above and is verifiable by computation.

### Effect of Sample Size

The width of the confidence interval is proportional to $\frac{1}{\sqrt{n}}$. Increasing sample size narrows the interval, but with diminishing returns — quadrupling $n$ only halves the interval width, since the relationship is governed by the square root.

$$\text{Width} \propto \frac{1}{\sqrt{n}}$$

This proportionality is a direct mathematical consequence of the formula and is verifiable.

### Sample Size Determination

To achieve a desired margin of error $E$ with a given confidence level, the required sample size (known $\sigma$ case) is:

$$n = \left(\frac{z_{\alpha/2}\cdot\sigma}{E}\right)^2$$

rounded up to the nearest integer. This is a standard formula derived by algebraically solving the margin-of-error expression for $n$.

[Inference] In practice, when $\sigma$ is unknown at the planning stage, an estimate from a pilot study or prior research is typically substituted for $\sigma$ in this formula. I do not have a specific verified source confirming this as the universally standard approach across all applied contexts, though it is commonly described this way in introductory statistics materials.

### Assumptions and Validity Conditions

The intervals above rely on the following assumptions:

- Observations are independent and identically distributed
- The underlying population is normally distributed, **or** the sample size is large enough for the Central Limit Theorem to justify approximate normality of $\bar{X}$

[Inference] "Large enough" for the Central Limit Theorem approximation to be reasonable is commonly cited using rules of thumb such as $n \geq 30$. I cannot verify this threshold as a precise or universally agreed-upon cutoff — it is a heuristic that varies depending on the skewness and shape of the underlying population distribution, not a fixed mathematical guarantee.

If the population is heavily skewed or contains extreme outliers, the normal approximation may perform poorly even at moderate sample sizes. [Unverified] I do not have a specific verified quantitative relationship between skewness magnitude and required sample size that I can state as authoritative.

### Relevance to Machine Learning

- **Model coefficient estimation:** Confidence intervals for the mean generalize directly to confidence intervals for regression coefficients, using analogous standard error formulas.
- **Baseline comparison:** CIs for means are used when comparing average performance metrics (e.g., mean squared error across cross-validation folds) between models.
- **A/B testing:** Comparing the mean of a metric between two groups (e.g., control vs. treatment) often relies on confidence intervals for the difference in means, built on the same $t$-distribution or normal-approximation logic described above.

[Inference] These applications are commonly described in applied ML and experimentation literature, but I do not have a single specific source I can cite for this response confirming exact current industry practice.

### CI Width vs Sample Size (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">CI Width vs Sample Size (svg_diagram)</text>
<line x1="80" y1="290" x2="700" y2="290" stroke="#333" stroke-width="1.5" />
<line x1="80" y1="290" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
<text x="390" y="320" text-anchor="middle" font-size="13" fill="#333">Sample Size (n)</text>
<text x="30" y="175" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 30 175)">CI Width</text>
<path d="M 100 80 Q 200 140 300 190 T 500 240 T 680 270" fill="none" stroke="#4a6fa5" stroke-width="2.5" />
<circle cx="100" cy="80" r="4" fill="#4a6fa5" />
<circle cx="220" cy="160" r="4" fill="#4a6fa5" />
<circle cx="360" cy="210" r="4" fill="#4a6fa5" />
<circle cx="500" cy="240" r="4" fill="#4a6fa5" />
<circle cx="680" cy="270" r="4" fill="#4a6fa5" />

<text x="100" y="65" text-anchor="middle" font-size="11" fill="#555">n=5</text>

<text x="220" y="145" text-anchor="middle" font-size="11" fill="#555">n=20</text>

<text x="360" y="195" text-anchor="middle" font-size="11" fill="#555">n=50</text>

<text x="500" y="225" text-anchor="middle" font-size="11" fill="#555">n=100</text>

<text x="680" y="255" text-anchor="middle" font-size="11" fill="#555">n=200</text>

<text x="390" y="55" text-anchor="middle" font-size="12" fill="#666">Width ∝ 1/√n — diminishing returns as n grows</text>

</svg>

### Common Pitfalls

- **Using $z$ instead of $t$ when $\sigma$ is unknown:** This is a frequent error, particularly with small sample sizes, where the difference between $z_{\alpha/2}$ and $t_{\alpha/2, n-1}$ is largest. Using $z$ in this case produces an interval that is narrower than it should be, understating true uncertainty.
- **Assuming normality without checking:** Applying these formulas to strongly non-normal data with small $n$ can produce intervals with actual coverage that deviates from the nominal confidence level. [Inference] The degree of deviation depends on the specific shape of the underlying distribution and sample size; I do not have a general formula to quantify this deviation for arbitrary distributions.
- **Misinterpreting the interval as containing 95% of the data:** The confidence interval concerns the location of the population mean $\mu$, not the spread of individual observations — this is a distinct concept from a prediction interval.
- **Treating the margin of error formula as exact when $\sigma$ is estimated from a small pilot sample:** [Inference] Sample size calculations using an estimated $\sigma$ carry additional uncertainty not captured in the basic formula; I do not have a specific verified correction method that applies universally across all cases.

### Note on Source Verification

I cannot verify specific textbook page numbers or confirm this content against a specific cited source within this conversation. The formulas and values presented (e.g., $t_{0.025,24} \approx 2.064$) reflect standard tabulated statistical values that are independently verifiable by computation, not quotations from a specific text.

### Next Steps

- **Confidence Intervals for Proportions** — Wald, Wilson, and Clopper-Pearson methods
- **Confidence Intervals for the Difference of Two Means** — pooled vs. unpooled variance approaches
- **Prediction Intervals** — contrast with confidence intervals for individual future observations
- **Sample Size Determination in Experimental Design** — extended treatment including unknown-variance cases
- **Central Limit Theorem** — formal statement and conditions for normal approximation validity
- **t-Distribution Properties** — derivation and relationship to the normal distribution
- **Bootstrap Confidence Intervals for the Mean** — resampling-based alternative when normality is questionable