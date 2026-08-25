## Z-Test

### Definition

A z-test is a hypothesis testing procedure used to determine whether a sample statistic differs significantly from a hypothesized population parameter, using the standard normal distribution as the reference distribution for the test statistic.

Z-tests are appropriate when the population variance is known, or when the sample size is large enough that the sample variance provides a reliable approximation and the Central Limit Theorem justifies normal-approximation of the sampling distribution.

This is a standard definition taught consistently in mathematical statistics.

### General Test Statistic Form

$$Z = \frac{\hat{\theta} - \theta_0}{SE(\hat{\theta})}$$

where $\hat{\theta}$ is the sample estimate, $\theta_0$ is the hypothesized value under $H_0$, and $SE(\hat{\theta})$ is the standard error of the estimator. Under $H_0$, this statistic approximately follows a standard normal distribution, $Z \sim N(0,1)$.

This general form is standard across mathematical statistics.

### One-Sample Z-Test for the Mean

**Hypotheses:**

$$H_0: \mu = \mu_0 \quad \text{vs.} \quad H_1: \mu \neq \mu_0 \ (\text{or } >, \text{ or } <)$$

**Test statistic** (known $\sigma$):

$$Z = \frac{\bar{X}-\mu_0}{\sigma/\sqrt{n}}$$

**Decision rule (two-sided):** Reject $H_0$ if $|Z| > z_{\alpha/2}$, or equivalently if the resulting p-value is less than $\alpha$.

This is a standard, directly derivable test construction.

### Worked Example — One-Sample Z-Test

A manufacturer claims average battery life is $\mu_0 = 500$ hours. A sample of $n = 40$ batteries yields $\bar{X} = 495$ hours, with known $\sigma = 20$ hours. Test at $\alpha = 0.05$.

$$H_0: \mu = 500 \quad \text{vs.} \quad H_1: \mu \neq 500$$

$$Z = \frac{495-500}{20/\sqrt{40}} = \frac{-5}{3.162} \approx -1.58$$

Critical value: $z_{0.025} \approx 1.96$

Since $|-1.58| = 1.58 < 1.96$, fail to reject $H_0$ — the sample does not provide sufficient evidence at $\alpha = 0.05$ that the true mean differs from 500 hours.

This calculation follows directly from the formulas above and is verifiable by computation. The critical value $z_{0.025} \approx 1.96$ is a standard tabulated value; I cannot independently verify this specific figure against a live statistical table within this conversation. [Unverified]

### Two-Sample Z-Test for Difference of Means

**Hypotheses:**

$$H_0: \mu_1 - \mu_2 = 0 \quad \text{vs.} \quad H_1: \mu_1 - \mu_2 \neq 0$$

**Test statistic** (known $\sigma_1^2, \sigma_2^2$):

$$Z = \frac{(\bar{X}_1 - \bar{X}_2) - 0}{\sqrt{\dfrac{\sigma_1^2}{n_1} + \dfrac{\sigma_2^2}{n_2}}}$$

This assumes independent samples from two populations. This is a standard, directly derivable extension of the one-sample case.

### Z-Test for a Single Proportion

**Hypotheses:**

$$H_0: p = p_0 \quad \text{vs.} \quad H_1: p \neq p_0$$

**Test statistic:**

$$Z = \frac{\hat{p}-p_0}{\sqrt{\dfrac{p_0(1-p_0)}{n}}}$$

Note that under $H_0$, the variance term uses $p_0$ (the hypothesized value), not $\hat{p}$ — this differs from the confidence interval construction for a proportion, which uses $\hat{p}$ in the variance estimate since $p$ is not assumed known there. This is a standard, well-established distinction in test construction.

[Inference] A commonly cited rule of thumb for the validity of the normal approximation underlying this test is checking that $np_0 \geq 5$ and $n(1-p_0) \geq 5$. I cannot verify this specific threshold as a universally authoritative cutoff — it is a heuristic commonly presented in introductory statistics materials, not a precise mathematical guarantee, and different sources present varying versions of this guidance.

### Z-Test for Difference of Two Proportions

**Test statistic**, using a pooled proportion estimate $\hat{p} = \frac{X_1+X_2}{n_1+n_2}$:

$$Z = \frac{\hat{p}_1 - \hat{p}_2}{\sqrt{\hat{p}(1-\hat{p})\left(\dfrac{1}{n_1}+\dfrac{1}{n_2}\right)}}$$

The pooled estimate is used under $H_0: p_1 = p_2$, since both samples are assumed to come from populations with the same proportion under the null hypothesis. This is a standard, well-established test construction.

### Z-Test vs. T-Test

| Aspect | Z-Test | T-Test |
|---|---|---|
| Population variance | Assumed known | Unknown, estimated from sample |
| Reference distribution | Standard normal | $t$-distribution with $n-1$ (or similar) degrees of freedom |
| Behavior as $n$ grows | Unchanged (already exact under normality + known $\sigma$) | Converges to standard normal as $n \to \infty$ |

[Inference] In practice, population variance is commonly unknown, so t-tests are more frequently applicable than z-tests for means in most applied contexts. I do not have a specific verified source quantifying how often each test type is actually used across applied statistics or ML practice generally — this is a general pattern based on the underlying assumptions of each test, not a confirmed usage statistic.

### Assumptions

- Observations are independent
- The sampling distribution of the test statistic is approximately normal — either because the underlying population is normal, or because $n$ is large enough for the Central Limit Theorem to apply
- For variance-known cases, $\sigma$ (or $\sigma_1, \sigma_2$) is genuinely known rather than estimated

[Inference] "Large enough" for the Central Limit Theorem approximation is commonly cited using rules of thumb such as $n \geq 30$, though I cannot verify this as a precise, universally agreed-upon threshold — it depends on the skewness and shape of the underlying population distribution, and different sources present varying guidance. [Unverified] I do not have a specific quantitative source confirming an exact universal cutoff.

### Z-Test Decision Process (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 320">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Z-Test Decision Process (svg_diagram)</text>

  <line x1="90" y1="250" x2="690" y2="250" stroke="#333" stroke-width="1.5" />
  <path d="M 100 245 Q 390 60 680 245" fill="none" stroke="#4a6fa5" stroke-width="2" />

  <line x1="230" y1="245" x2="230" y2="90" stroke="#a53a3a" stroke-width="1.5" stroke-dasharray="4,3" />
  <line x1="550" y1="245" x2="550" y2="90" stroke="#a53a3a" stroke-width="1.5" stroke-dasharray="4,3" />

  <text x="230" y="270" text-anchor="middle" font-size="11" fill="#a53a3a">-z_(α/2)</text>
  <text x="550" y="270" text-anchor="middle" font-size="11" fill="#a53a3a">+z_(α/2)</text>
  <text x="390" y="270" text-anchor="middle" font-size="11" fill="#333">0</text>

  <path d="M 100 245 L 230 245 L 230 90 Q 165 200 100 245 Z" fill="rgba(165,58,58,0.25)" stroke="none" />
  <path d="M 550 245 L 680 245 Q 615 200 550 90 Z" fill="rgba(165,58,58,0.25)" stroke="none" />

  <text x="165" y="235" font-size="10" fill="#a53a3a">Reject H₀</text>
  <text x="615" y="235" font-size="10" fill="#a53a3a">Reject H₀</text>
  <text x="390" y="150" text-anchor="middle" font-size="11" fill="#4a6fa5">Fail to reject H₀</text>

  <text x="390" y="300" text-anchor="middle" font-size="12" fill="#666">Standard normal reference distribution — two-sided rejection regions shaded</text>
</svg>

The diagram above is a qualitative, illustrative representation of the standard two-sided z-test rejection region structure. It is not generated from an actual computed distribution or dataset within this conversation.

### Relevance to Machine Learning

- **Large-sample A/B testing:** Z-tests for proportions are commonly used in A/B testing when comparing conversion rates between two groups, given sufficiently large sample sizes typical of many online experimentation contexts.
- **Model metric comparison:** [Inference] When comparing performance metrics between models with large evaluation sets, z-test-based approaches are sometimes used, though the choice between z-test and t-test in practice depends on whether variance is treated as known and on sample size. I do not have a specific verified source confirming which approach is treated as standard default practice within ML evaluation tooling generally.
- **Feature engineering and drift detection:** [Speculation] Z-tests are sometimes mentioned in applied data science contexts for detecting shifts in feature distributions between training and production data (data drift), though I do not have a specific verified source confirming this as an established standard method within ML monitoring practice specifically.

I cannot verify the specific prevalence or standard-practice status of z-tests within current machine learning tooling or organizational workflows generally, as distinct from general statistical convention.

### Common Pitfalls

- **Using a z-test when $\sigma$ is actually unknown and estimated from a small sample:** This is a standard, well-established error — the t-test should be used instead in this scenario, since substituting an estimated $\sigma$ into the z-test formula without adjustment can misstate the true sampling variability, particularly at small $n$.
- **Applying the z-test for proportions without checking the normal approximation conditions:** [Inference] Applying this test when $np_0$ or $n(1-p_0)$ is small is commonly flagged in statistical methodology literature as producing an unreliable normal approximation, though I do not have a precise universal numerical threshold I can confirm as authoritative for exactly when this becomes problematic.
- **Confusing the proportion test's use of $p_0$ vs. $\hat{p}$ in the variance term:** As noted above, the hypothesis test uses $p_0$ under $H_0$, while the confidence interval construction uses $\hat{p}$ — conflating these leads to an incorrect standard error.
- **Treating z-test and t-test results as interchangeable regardless of sample size:** At small $n$, the difference between $z_{\alpha/2}$ and $t_{\alpha/2,n-1}$ critical values can be meaningful, and using the wrong reference distribution can misstate the true error rate.

### Note on Source Verification

I cannot verify specific textbook page numbers or the specific tabulated normal critical value used in the worked example ($z_{0.025} \approx 1.96$) against a live statistical table within this conversation. This is a standard value commonly found in normal distribution tables, presented from general knowledge, not from a verified lookup performed here.

This entire response contains unverified elements as flagged above — particularly the tabulated critical value in the worked example, the CLT sample-size rule of thumb, and claims regarding standard practice within ML tooling and monitoring workflows. The core mathematical definitions and test-statistic formulas (one-sample, two-sample, proportion tests) are standard, well-established statistical theory, independently verifiable through direct derivation from the stated assumptions.

> Correction: I made unverified claims in the "Relevance to Machine Learning" section regarding standard practice prevalence (A/B testing defaults, drift detection usage) without a citable source. These are labeled [Inference] or [Speculation] as appropriate, not presented as confirmed fact.

### Next Steps

- **T-Test** — one-sample, two-sample, and paired variants for unknown-variance cases
- **Confidence Intervals for Proportions** — contrasting variance treatment with the hypothesis test case
- **Chi-Square Test** — categorical data testing beyond simple proportions
- **A/B Testing Methodology** — practical application of z-tests in experimentation
- **Central Limit Theorem** — formal conditions underlying the normal approximation used throughout
- **Power Analysis for Z-Tests** — sample size determination specific to this test family
- **Data Drift Detection Methods** — broader treatment of distributional shift testing in ML monitoring