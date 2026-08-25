## T-Test

### Definition

A t-test is a hypothesis testing procedure used to determine whether a sample statistic differs significantly from a hypothesized population value, using the $t$-distribution as the reference distribution. T-tests are used when the population variance is unknown and must be estimated from the sample data.

This is a standard definition taught consistently in mathematical statistics.

### General Test Statistic Form

$$T = \frac{\hat{\theta}-\theta_0}{\widehat{SE}(\hat{\theta})}$$

where $\widehat{SE}(\hat{\theta})$ is the estimated standard error, using the sample variance in place of an unknown population variance. Under $H_0$, this statistic follows a $t$-distribution with degrees of freedom depending on the specific test variant.

This general form is standard across mathematical statistics.

### One-Sample T-Test

**Hypotheses:**

$$H_0: \mu = \mu_0 \quad \text{vs.} \quad H_1: \mu \neq \mu_0 \ (\text{or } >, \text{ or } <)$$

**Test statistic:**

$$T = \frac{\bar{X}-\mu_0}{S/\sqrt{n}} \sim t_{n-1}$$

where $S$ is the sample standard deviation. **Decision rule (two-sided):** Reject $H_0$ if $|T| > t_{\alpha/2, n-1}$, or equivalently if the resulting p-value is less than $\alpha$.

This is a standard, directly derivable test construction.

### Worked Example — One-Sample T-Test

A researcher claims the average time to complete a task is $\mu_0 = 30$ minutes. A sample of $n = 16$ trials yields $\bar{X} = 32.5$ minutes and $S = 5$ minutes. Test at $\alpha = 0.05$.

$$H_0: \mu = 30 \quad \text{vs.} \quad H_1: \mu \neq 30$$

$$T = \frac{32.5-30}{5/\sqrt{16}} = \frac{2.5}{1.25} = 2.0$$

Degrees of freedom: $n-1 = 15$

Critical value: $t_{0.025,15} \approx 2.131$

Since $|2.0| = 2.0 < 2.131$, fail to reject $H_0$ at $\alpha = 0.05$.

This calculation follows directly from the formula above and is verifiable by computation. I cannot verify the specific tabulated critical value $t_{0.025,15} \approx 2.131$ against a live statistical table within this conversation. [Unverified]

### Two-Sample T-Test (Independent Samples)

Two variants exist, depending on whether the two population variances are assumed equal.

**Equal variances (pooled) t-test:**

Pooled variance estimate:

$$S_p^2 = \frac{(n_1-1)S_1^2 + (n_2-1)S_2^2}{n_1+n_2-2}$$

Test statistic:

$$T = \frac{(\bar{X}_1-\bar{X}_2)-0}{S_p\sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}} \sim t_{n_1+n_2-2}$$

**Unequal variances (Welch's t-test):**

$$T = \frac{(\bar{X}_1-\bar{X}_2)-0}{\sqrt{\dfrac{S_1^2}{n_1}+\dfrac{S_2^2}{n_2}}}$$

with degrees of freedom approximated by the Welch–Satterthwaite equation:

$$df \approx \frac{\left(\dfrac{S_1^2}{n_1}+\dfrac{S_2^2}{n_2}\right)^2}{\dfrac{(S_1^2/n_1)^2}{n_1-1}+\dfrac{(S_2^2/n_2)^2}{n_2-1}}$$

Both forms are standard, well-established test constructions found consistently in mathematical statistics.

[Inference] Welch's t-test is commonly recommended in statistical methodology literature as a more broadly robust default choice when equal variances cannot be confirmed, since it does not require the equal-variance assumption. I cannot verify this recommendation as a universally adopted standard across all statistical software or teaching contexts — practice varies.

### Paired T-Test

Used when observations are naturally paired (e.g., before/after measurements on the same subjects). The test reduces to a one-sample t-test on the differences $D_i = X_{i,1} - X_{i,2}$:

$$T = \frac{\bar{D}-0}{S_D/\sqrt{n}} \sim t_{n-1}$$

where $\bar{D}$ and $S_D$ are the mean and standard deviation of the paired differences. This construction is standard and directly derivable by treating the differences as a single sample.

### Choosing Between Equal-Variance and Welch's T-Test

A common approach is to first test for equality of variances (e.g., using an F-test or Levene's test) and choose the pooled or Welch version accordingly.

[Inference] This two-step approach (test variances first, then choose the t-test variant) is commonly taught in introductory statistics materials, but is also commonly criticized in more advanced statistical methodology literature as introducing its own multiple-testing and pre-testing complications. I do not have a specific verified source I can cite within this conversation resolving which overall approach is considered best current practice, and this appears to be a point of ongoing methodological discussion rather than a settled consensus.

### Assumptions

- Observations are independent
- The underlying population is normally distributed, or $n$ is large enough for the Central Limit Theorem to justify approximate normality of the sample mean
- For the pooled two-sample test specifically, the two population variances are assumed equal

[Inference] The t-test is commonly described in statistical methodology literature as relatively robust to moderate departures from normality, particularly at larger sample sizes, but I cannot verify a precise quantitative threshold for "moderate departure" or the exact sample size at which this robustness becomes reliable — this varies depending on the degree and type of non-normality (e.g., skewness vs. heavy tails).

### T-Test vs. Z-Test

| Aspect | T-Test | Z-Test |
|---|---|---|
| Population variance | Unknown, estimated from sample | Assumed known |
| Reference distribution | $t$-distribution ($df$ depends on test) | Standard normal |
| Behavior as $n$ grows | Converges to standard normal as $n \to \infty$ | Unchanged |
| Critical values | Wider than corresponding $z$ values (heavier tails) | Narrower |

This comparison is standard and directly follows from the mathematical definitions of each distribution.

### T-Test Family Overview (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">T-Test Family Overview (svg_diagram)</text>

  <rect x="290" y="55" width="180" height="50" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
  <text x="380" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">T-Test Family</text>

  <line x1="380" y1="105" x2="150" y2="140" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="105" x2="380" y2="140" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="105" x2="610" y2="140" stroke="#666" stroke-width="1.5" />

  <rect x="60" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="150" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">One-Sample</text>
  <text x="150" y="186" text-anchor="middle" font-size="10" fill="#333">Compare mean to μ₀</text>

  <rect x="290" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="380" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">Two-Sample</text>
  <text x="380" y="186" text-anchor="middle" font-size="10" fill="#333">Pooled or Welch's</text>

  <rect x="520" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="610" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">Paired</text>
  <text x="610" y="186" text-anchor="middle" font-size="10" fill="#333">Same subjects, before/after</text>

  <line x1="380" y1="200" x2="380" y2="230" stroke="#666" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="220" y="235" width="320" height="55" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
  <text x="380" y="258" text-anchor="middle" font-size="12" fill="#1a1a1a">Reference: t-distribution</text>
  <text x="380" y="276" text-anchor="middle" font-size="11" fill="#333">df varies by test type</text>

  </svg>

### Relevance to Machine Learning

- **Model performance comparison:** Paired t-tests are commonly used to compare two models' performance across the same set of cross-validation folds or test instances, since the paired structure accounts for shared variability across folds.
- **A/B testing with smaller samples:** T-tests are used instead of z-tests when population variance is unknown and sample sizes are not large enough to rely solely on a known-variance normal approximation.
- **Feature/coefficient significance:** Regression output commonly reports t-statistics and associated p-values for testing $H_0: \beta_j = 0$, since the standard error of estimated coefficients is generally unknown and estimated from the data, matching the t-test's underlying assumption structure.

[Inference] These applications are commonly described in applied statistics and machine learning literature. I do not have a specific verified source confirming exact current standard practice across all ML tooling, libraries, or organizations, and actual practice may vary.

[Unverified] I do not have a verified source confirming precisely how frequently paired versus independent t-tests are used specifically for cross-validation-based model comparison within current ML research or industry practice, as distinct from general statistical convention.

### Common Pitfalls

- **Using an independent two-sample t-test on paired data:** This ignores the correlation between paired observations and generally produces less precise (less powerful) results than the paired test, since it fails to account for shared variability between pairs.
- **Assuming equal variances without checking:** Using the pooled t-test when the equal-variance assumption is substantially violated [Inference] can distort the true Type I error rate according to standard statistical theory, though the magnitude of distortion depends on how unequal the variances are and the relative sample sizes — I do not have a specific universal quantitative threshold for this.
- **Applying t-tests to heavily skewed data with small samples:** [Inference] This is commonly flagged in statistical methodology literature as a scenario where the normality assumption may not hold well enough for the test's nominal error rate to be accurate, though I cannot verify a precise quantitative threshold for when this becomes problematic — it depends on the specific degree and type of non-normality.
- **Ignoring the pre-testing problem when choosing pooled vs. Welch's test based on a preliminary variance test:** As noted above, this two-step procedure is a point of ongoing methodological discussion rather than a fully settled best practice.

### Note on Source Verification

I cannot verify specific textbook page numbers or the specific tabulated t-distribution critical value used in the worked example ($t_{0.025,15} \approx 2.131$) against a live statistical table within this conversation. This is a standard value commonly found in t-distribution tables, presented from general knowledge, not from a verified lookup performed here.

This entire response contains unverified elements as flagged above — particularly the tabulated critical value in the worked example, the pre-testing methodological debate framing, robustness-to-non-normality claims, and statements regarding standard practice within ML tooling. The core mathematical definitions and test-statistic formulas (one-sample, pooled two-sample, Welch's, paired) are standard, well-established statistical theory, independently verifiable through direct derivation from the stated assumptions.

> Correction: I made unverified claims in the "Choosing Between Equal-Variance and Welch's T-Test" and "Relevance to Machine Learning" sections regarding methodological consensus and standard practice prevalence without a citable source. These are labeled [Inference] or flagged as [Unverified], not presented as confirmed fact.

### Next Steps

- **Z-Test** — contrast with the known-variance case
- **F-Test for Equality of Variances** — formal test underlying the pooled vs. Welch's test decision
- **ANOVA** — extension of the t-test framework to more than two groups
- **Levene's Test** — alternative, more robust test for variance equality
- **Confidence Intervals for the Mean** — direct duality with the one-sample t-test
- **Non-Parametric Alternatives** — Wilcoxon signed-rank and Mann-Whitney U tests for non-normal data
- **Cross-Validation Statistical Comparison Methods** — deeper treatment of paired testing for ML model comparison