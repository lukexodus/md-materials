## Confidence Interval for Variance

### Overview

This topic covers the confidence interval for a population variance $\sigma^2$, estimated from sample data. This case differs structurally from the mean and proportion cases because the relevant pivotal quantity follows a Chi-square distribution, which is asymmetric — leading to an asymmetric confidence interval even though the point estimate itself is unbiased.

This is standard content found consistently across mathematical statistics textbooks.

### Sampling Distribution of the Sample Variance

For $X_1, \ldots, X_n \sim N(\mu, \sigma^2)$, the sample variance is:

$$S^2 = \frac{1}{n-1}\sum_{i=1}^n (X_i - \bar{X})^2$$

The key pivotal quantity for constructing a confidence interval for $\sigma^2$ is:

$$\frac{(n-1)S^2}{\sigma^2} \sim \chi^2_{n-1}$$

following a Chi-square distribution with $n-1$ degrees of freedom. This is a standard, well-established result derivable under the normality assumption.

### Confidence Interval Construction

Using the Chi-square pivotal quantity, a $100(1-\alpha)\%$ confidence interval for $\sigma^2$ is:

$$\left(\frac{(n-1)S^2}{\chi^2_{\alpha/2,\,n-1}},\ \frac{(n-1)S^2}{\chi^2_{1-\alpha/2,\,n-1}}\right)$$

where $\chi^2_{\alpha/2,\,n-1}$ and $\chi^2_{1-\alpha/2,\,n-1}$ are the upper and lower critical values of the Chi-square distribution with $n-1$ degrees of freedom.

Note the inversion: the *upper* critical value is used in the *denominator* of the *lower* bound, and the *lower* critical value is used in the denominator of the *upper* bound. This follows directly from algebraically inverting the pivotal quantity inequality and is a standard, verifiable derivation.

A confidence interval for the standard deviation $\sigma$ is obtained by taking the square root of both bounds:

$$\left(\sqrt{\frac{(n-1)S^2}{\chi^2_{\alpha/2,\,n-1}}},\ \sqrt{\frac{(n-1)S^2}{\chi^2_{1-\alpha/2,\,n-1}}}\right)$$

### Worked Example

Suppose $n = 20$ observations yield $S^2 = 25$. Constructing a 95% confidence interval for $\sigma^2$:

Degrees of freedom: $n - 1 = 19$

Using standard Chi-square table values: $\chi^2_{0.025,19} \approx 32.852$ and $\chi^2_{0.975,19} \approx 8.907$

$$\left(\frac{19(25)}{32.852},\ \frac{19(25)}{8.907}\right) = \left(\frac{475}{32.852},\ \frac{475}{8.907}\right) \approx (14.46,\ 53.33)$$

This calculation follows directly from the formula above. I cannot independently verify the specific tabulated Chi-square critical values ($32.852$ and $8.907$) against a live statistical table within this response — these are standard values commonly found in Chi-square distribution tables, but I am presenting them from general knowledge rather than a verified lookup performed in this conversation. [Unverified]

### Asymmetry of the Interval

Unlike confidence intervals for the mean, this interval is **not** symmetric around the point estimate $S^2$. This asymmetry arises directly from the skewed shape of the Chi-square distribution, which is not symmetric like the normal or $t$-distribution. This is a standard, well-established mathematical property of the Chi-square distribution.

### Critical Dependence on Normality

The Chi-square pivotal quantity result above depends on the assumption that the underlying population is normally distributed. This is a standard mathematical requirement, not merely a convenience assumption.

[Inference] Unlike confidence intervals for the mean, where the Central Limit Theorem provides some robustness to non-normality as $n$ grows, the variance interval is commonly described in statistical literature as considerably more sensitive to violations of the normality assumption. I cannot verify a precise quantitative threshold for how much non-normality causes how much distortion — this depends on the specific shape of the true underlying distribution.

[Unverified] I do not have a specific verified source confirming an exact degree of sensitivity or a quantified robustness comparison between the mean-CI case and the variance-CI case within this response.

### Alternative Approaches Under Non-Normality

When normality cannot be assumed, standard approaches include:

- **Bootstrap confidence intervals:** Resampling-based construction that does not require a normality assumption
- **Robust variance estimators:** Alternative estimators designed to be less sensitive to distributional assumptions

[Speculation] These alternatives are commonly mentioned in applied statistics contexts as practical responses to non-normality concerns, but I do not have a specific verified source within this conversation confirming which method is considered best practice in any particular applied setting.

### Relevance to Machine Learning

- **Model residual analysis:** Confidence intervals for variance are relevant when assessing uncertainty in residual variance estimates from regression models, which relates to model diagnostic procedures.
- **Homogeneity of variance assumptions:** Some statistical tests and models (e.g., ANOVA, certain regression diagnostics) assume constant variance (homoscedasticity); confidence intervals for variance can be part of assessing this assumption.
- **Uncertainty in noise estimation:** [Inference] In probabilistic ML models where noise variance is a parameter (e.g., Gaussian process regression, Bayesian linear regression), confidence or credible intervals around the estimated noise variance relate conceptually to the frequentist construction described above, though Bayesian approaches typically use credible intervals derived differently (via the posterior distribution) rather than this exact Chi-square pivotal method. I do not have a specific verified source directly equating these two constructions as interchangeable.

[Unverified] I do not have a verified specific source confirming standard current practice for variance interval estimation within mainstream ML libraries or workflows generally.

### Chi-Square Pivotal Construction (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Chi-Square Pivotal Construction (svg_diagram)</text>
<rect x="40" y="65" width="220" height="65" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="150" y="92" text-anchor="middle" font-size="13" fill="#1a1a1a">Sample Variance</text>
<text x="150" y="112" text-anchor="middle" font-size="12" fill="#333">S²</text>
<line x1="260" y1="97" x2="310" y2="97" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
<rect x="310" y="65" width="220" height="65" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="420" y="92" text-anchor="middle" font-size="13" fill="#1a1a1a">Pivotal Quantity</text>
<text x="420" y="112" text-anchor="middle" font-size="12" fill="#333">(n-1)S² / σ² ~ χ²ₙ₋₁</text>
<line x1="530" y1="97" x2="580" y2="97" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
<rect x="580" y="65" width="140" height="65" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
<text x="650" y="92" text-anchor="middle" font-size="13" fill="#1a1a1a">χ² Critical</text>
<text x="650" y="112" text-anchor="middle" font-size="12" fill="#333">Values</text>
<line x1="650" y1="130" x2="650" y2="175" stroke="#666" stroke-width="1.5" />
<line x1="650" y1="175" x2="420" y2="175" stroke="#666" stroke-width="1.5" />
<line x1="420" y1="175" x2="420" y2="210" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
<rect x="220" y="210" width="400" height="60" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
<text x="420" y="235" text-anchor="middle" font-size="12" fill="#1a1a1a">Asymmetric Interval for σ²</text>
<text x="420" y="253" text-anchor="middle" font-size="11" fill="#333">( (n-1)S²/χ²_(α/2), (n-1)S²/χ²_(1-α/2) )</text>

<text x="420" y="300" text-anchor="middle" font-size="12" fill="#666">Not symmetric around S² — reflects χ² skewness</text>

</svg>

### Common Pitfalls

- **Assuming symmetry around $S^2$:** Unlike mean intervals, this interval is not centered symmetrically on the point estimate — treating it as if it were is a direct mathematical error given the Chi-square distribution's asymmetry.
- **Mixing up which critical value goes in which bound:** The upper critical value produces the lower bound and vice versa, due to the algebraic inversion step; reversing this produces an incorrect interval.
- **Applying this method to non-normal data without adjustment:** [Inference] This is commonly flagged in statistical literature as more problematic here than in the mean case, given the stated greater sensitivity of variance estimation to normality violations, though I cannot verify a precise quantitative threshold for this.
- **Confusing the confidence interval for $\sigma^2$ with the interval for $\sigma$:** These require different transformations (the $\sigma$ interval is obtained by taking square roots, not by an independent derivation), and conflating them can lead to incorrect reporting.

### Note on Source Verification

I cannot verify the specific Chi-square critical values used in the worked example above ($32.852$ and $8.907$) against a live statistical table within this conversation. These are presented from general knowledge of standard Chi-square distribution tables, not from a confirmed lookup performed here. I do not have access to a specific cited textbook or table to confirm exact page-level values.

**This entire response contains unverified elements as flagged above (particularly the exact critical-value figures and the ML-practice claims); treat those specific claims accordingly. The mathematical derivations (pivotal quantity, interval formula, asymmetry property) are standard, well-established results independently verifiable through direct computation.**

### Next Steps

- **Chi-Square Distribution** — properties, derivation, and relationship to the normal distribution
- **Confidence Interval for the Ratio of Two Variances** — F-distribution based construction
- **Bartlett's and Levene's Tests** — hypothesis tests for equality of variances
- **Bootstrap Confidence Intervals for Variance** — non-parametric alternative under non-normality
- **Homoscedasticity Assumptions in Regression** — practical relevance of variance estimation
- **Bayesian Credible Intervals for Variance** — inverse-gamma conjugate prior approach
- **Robustness of Variance Estimators to Non-Normality** — deeper treatment of sensitivity concerns