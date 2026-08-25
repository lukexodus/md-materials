## Confidence Intervals

### Definition

A confidence interval (CI) is a range of values, derived from sample data, used to estimate an unknown population parameter. A $100(1-\alpha)\%$ confidence interval is constructed such that, under repeated sampling, the interval would contain the true parameter value in $100(1-\alpha)\%$ of samples.

Formally, for parameter $\theta$:

$$P(L(X) \leq \theta \leq U(X)) = 1 - \alpha$$

where $L(X)$ and $U(X)$ are lower and upper bounds computed from the sample, and $\alpha$ is the significance level.

This is standard definitional content from mathematical statistics.

### Interpretation

The correct interpretation of a confidence interval concerns the procedure, not a specific computed interval:

- **Correct:** If the sampling procedure were repeated many times, approximately $100(1-\alpha)\%$ of the constructed intervals would contain the true parameter.
- **Incorrect (common misinterpretation):** "There is a $100(1-\alpha)\%$ probability that the true parameter lies within this specific computed interval."

Once a specific interval is calculated from a specific sample, the true parameter either is or is not within it — the randomness lies in the sampling procedure, not in the fixed true parameter. This distinction is a well-established point of emphasis in statistics pedagogy.

[Inference] This misinterpretation is widely cited as one of the most common errors in applied statistics teaching, though I do not have a specific survey or study reference to quantify how prevalent it is in practice.

### General Construction — Pivotal Quantity Method

A common method for constructing confidence intervals uses a pivotal quantity — a function of the data and the parameter whose distribution does not depend on the parameter.

General steps:

1. Identify a pivotal quantity $Q(X, \theta)$ with a known distribution independent of $\theta$
2. Find values $a$ and $b$ such that $P(a \leq Q(X,\theta) \leq b) = 1-\alpha$
3. Algebraically rearrange the inequality to isolate $\theta$

This is a standard general-purpose construction method taught in mathematical statistics.

### Worked Example — Mean of a Normal Distribution (Known Variance)

For $X_1, \ldots, X_n \sim N(\mu, \sigma^2)$ with $\sigma^2$ known, the sample mean $\bar{X}$ has distribution:

$$\bar{X} \sim N\left(\mu, \frac{\sigma^2}{n}\right)$$

Standardizing gives the pivotal quantity:

$$Z = \frac{\bar{X}-\mu}{\sigma/\sqrt{n}} \sim N(0,1)$$

Using the standard normal distribution, a $100(1-\alpha)\%$ confidence interval for $\mu$ is:

$$\bar{X} \pm z_{\alpha/2}\cdot\frac{\sigma}{\sqrt{n}}$$

where $z_{\alpha/2}$ is the upper $\alpha/2$ critical value of the standard normal distribution (e.g., $z_{0.025} = 1.96$ for a 95% CI). This is a directly verifiable derivation and a standard textbook result.

### Worked Example — Mean of a Normal Distribution (Unknown Variance)

When $\sigma^2$ is unknown and estimated by the sample variance $S^2$, the pivotal quantity becomes:

$$T = \frac{\bar{X}-\mu}{S/\sqrt{n}} \sim t_{n-1}$$

following a $t$-distribution with $n-1$ degrees of freedom. The confidence interval is:

$$\bar{X} \pm t_{\alpha/2, n-1}\cdot\frac{S}{\sqrt{n}}$$

This substitution of the $t$-distribution for the normal distribution accounts for the additional uncertainty introduced by estimating $\sigma^2$ from the data. This is standard and directly derivable.

### Confidence Intervals for Proportions

For a binomial proportion $\hat{p}$ estimated from $n$ trials, the Wald (normal approximation) interval is:

$$\hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$$

This relies on the Central Limit Theorem approximation and is known to perform poorly for small $n$ or $\hat{p}$ near 0 or 1. Alternative methods exist, including the Wilson score interval and the Clopper-Pearson (exact) interval, which are generally more reliable in these edge cases.

[Inference] The specific threshold at which the Wald interval's poor performance becomes practically significant depends on $n$ and $\hat{p}$ jointly; I do not have a single universal rule of thumb I can confirm as authoritative, though commonly cited guidance suggests caution when $n\hat{p}$ or $n(1-\hat{p})$ is small (e.g., below 5–10). This threshold guidance itself is [Unverified] as a precise cutoff and varies across sources.

### Bootstrap Confidence Intervals

The bootstrap method constructs confidence intervals via resampling, without relying on a known analytical sampling distribution:

1. Resample the observed data with replacement to create $B$ bootstrap samples
2. Compute the statistic of interest (e.g., the mean) for each bootstrap sample
3. Use the empirical distribution of the $B$ bootstrap statistics to construct the interval (e.g., via the percentile method)

The percentile bootstrap CI takes the $\alpha/2$ and $1-\alpha/2$ quantiles of the bootstrap distribution as the interval bounds.

This is a standard, well-established resampling technique. [Inference] Bootstrap methods are commonly used in machine learning contexts where the sampling distribution of a statistic is analytically intractable (e.g., complex model performance metrics), though the specific choice between percentile, basic, and bias-corrected accelerated (BCa) bootstrap methods depends on the properties of the estimator and is not something I can generalize as a single best default.

### Relationship to Hypothesis Testing

A $100(1-\alpha)\%$ confidence interval and a hypothesis test at significance level $\alpha$ are mathematically connected: a two-sided hypothesis test of $H_0: \theta = \theta_0$ at level $\alpha$ rejects $H_0$ if and only if $\theta_0$ falls outside the corresponding $100(1-\alpha)\%$ confidence interval.

This duality is a standard and well-established result in mathematical statistics.

### Relevance to Machine Learning

- **Model parameter uncertainty:** Confidence intervals for regression coefficients (e.g., in linear regression) quantify uncertainty in estimated parameters, often computed using standard errors derived from the Fisher Information matrix.
- **Performance metric estimation:** CIs are used to express uncertainty around estimated model performance metrics (e.g., accuracy, AUC) — frequently computed via bootstrap methods when the underlying sampling distribution is not analytically known.
- **A/B testing and model comparison:** Confidence intervals for differences in metrics between models or treatment groups inform decisions about whether observed differences are likely to reflect real effects versus sampling variability.
- **Cross-validation:** [Inference] Confidence intervals are sometimes constructed around cross-validation performance estimates, though the statistical validity of standard CI formulas in this setting is a subject of ongoing methodological discussion, since cross-validation folds are not independent samples in the classical sense. I do not have a specific consensus reference to confirm a single agreed-upon correct method for this case, and I am not aware of a technique that resolves this issue without added assumptions.

[Unverified] I do not have a verified comprehensive account of current best practices across the ML literature for CI construction under cross-validation; this remains an area with multiple competing proposed methods rather than one settled standard.

### CI Construction Flow (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">CI Construction Flow (svg_diagram)</text>
<rect x="40" y="65" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="140" y="90" text-anchor="middle" font-size="13" fill="#1a1a1a">Sample Data</text>
<text x="140" y="108" text-anchor="middle" font-size="12" fill="#333">X₁, ..., Xₙ</text>
<line x1="240" y1="95" x2="290" y2="95" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />
<rect x="290" y="65" width="200" height="60" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="390" y="90" text-anchor="middle" font-size="13" fill="#1a1a1a">Pivotal Quantity</text>
<text x="390" y="108" text-anchor="middle" font-size="12" fill="#333">Q(X, θ), known dist.</text>
<line x1="490" y1="95" x2="540" y2="95" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />
<rect x="540" y="65" width="180" height="60" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
<text x="630" y="90" text-anchor="middle" font-size="13" fill="#1a1a1a">Critical Values</text>
<text x="630" y="108" text-anchor="middle" font-size="12" fill="#333">e.g., z_(α/2), t_(α/2)</text>
<line x1="630" y1="125" x2="630" y2="170" stroke="#666" stroke-width="1.5" />
<line x1="630" y1="170" x2="390" y2="170" stroke="#666" stroke-width="1.5" />
<line x1="390" y1="170" x2="390" y2="205" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />
<rect x="240" y="205" width="300" height="65" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
<text x="390" y="230" text-anchor="middle" font-size="13" fill="#1a1a1a">Confidence Interval</text>
<text x="390" y="250" text-anchor="middle" font-size="12" fill="#333">θ̂ ± (critical value) × SE</text>
<line x1="390" y1="270" x2="390" y2="300" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />
<text x="390" y="320" text-anchor="middle" font-size="12" fill="#333">Interpreted via repeated-sampling coverage</text>
</svg>

### Common Pitfalls

- **Misinterpreting a specific interval as a probability statement about $\theta$:** As noted above, this is a frequent conceptual error; the probability statement applies to the procedure, not to a single realized interval.
- **Using the Wald interval for proportions with small $n$ or extreme $\hat{p}$:** Known to produce poor coverage in these cases; alternative methods (Wilson, Clopper-Pearson) are generally preferred in that regime. [Inference] "Generally preferred" reflects common statistical guidance rather than a claim I can verify as universally agreed upon in all applied contexts.
- **Confusing confidence level with coverage guarantee for a specific interval:** A stated 95% confidence level describes the long-run performance of the method, not a property of the specific interval already computed from your data.
- **Applying standard i.i.d.-based CI formulas to correlated or non-independent data:** [Inference] Standard errors computed under an independence assumption are likely to be invalid when this assumption is violated (e.g., time series or clustered data), and I do not have a general formula that automatically corrects for arbitrary dependence structures — the correction method depends on the specific data-dependence structure.

### Note on Source Verification

I cannot verify specific textbook page numbers, exact coverage-probability simulation results, or empirical claims about method performance without a specific cited source in this conversation. General statements above about relative performance of Wald vs. Wilson vs. Clopper-Pearson intervals reflect commonly taught statistical guidance, not a confirmed citation.

### Next Steps

- **Hypothesis Testing Fundamentals** — formal connection to confidence intervals via the duality principle
- **Bootstrap Methods (detailed)** — percentile, basic, and BCa interval construction with worked examples
- **Confidence Intervals for Regression Coefficients** — standard error derivation using the Fisher Information matrix
- **Wilson and Clopper-Pearson Intervals** — detailed construction for proportions
- **Prediction Intervals vs. Confidence Intervals** — distinguishing parameter uncertainty from individual observation uncertainty
- **Confidence Intervals under Cross-Validation** — open methodological questions in ML evaluation
- **Bayesian Credible Intervals** — contrast with frequentist confidence intervals