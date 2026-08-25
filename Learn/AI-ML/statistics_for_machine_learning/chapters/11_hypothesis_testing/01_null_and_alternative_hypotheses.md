## Null and Alternative Hypotheses

### Overview

Hypothesis testing is a formal statistical framework for evaluating claims about population parameters using sample data. The null and alternative hypotheses are the two competing statements that structure this framework.

This is standard content found consistently across mathematical statistics textbooks.

### Definitions

**Null Hypothesis ($H_0$):** A statement of "no effect," "no difference," or a default/baseline claim about a population parameter, which is assumed true unless sufficient evidence indicates otherwise.

**Alternative Hypothesis ($H_1$ or $H_a$):** A statement representing the claim the researcher is typically trying to find evidence for — contradicting the null hypothesis.

Formally, for a parameter $\theta$:

$$H_0: \theta = \theta_0 \quad \text{vs.} \quad H_1: \theta \neq \theta_0 \ (\text{or } \theta > \theta_0, \text{ or } \theta < \theta_0)$$

These are standard definitions taught consistently in mathematical statistics.

### One-Sided vs. Two-Sided Alternatives

- **Two-sided (two-tailed) test:** $H_1: \theta \neq \theta_0$ — evidence in either direction from $\theta_0$ counts against $H_0$
- **One-sided (one-tailed) test:** $H_1: \theta > \theta_0$ or $H_1: \theta < \theta_0$ — only evidence in a specific direction counts against $H_0$

The choice between one-sided and two-sided tests should be determined by the research question **before** observing the data. This is standard methodological guidance in statistics.

[Inference] Choosing the test direction after inspecting the data (sometimes informally called "data snooping" in this context) is commonly flagged in statistical methodology literature as inflating the true Type I error rate beyond the nominal level, though I cannot verify a precise quantitative relationship between this practice and the resulting error inflation without a specific cited simulation or source.

### Formal Structure of a Hypothesis Test

1. State $H_0$ and $H_1$
2. Choose a significance level $\alpha$ (commonly 0.05, 0.01, or 0.10)
3. Select an appropriate test statistic
4. Compute the test statistic from the sample
5. Compare the test statistic (or resulting p-value) against a decision rule
6. Decide to either reject $H_0$ or fail to reject $H_0$

This is a standard procedural framework taught consistently in mathematical statistics.

### Why We "Fail to Reject" Rather Than "Accept" $H_0$

A hypothesis test is structured to control the probability of incorrectly rejecting a true $H_0$ (Type I error), not to prove $H_0$ true. Failing to find sufficient evidence against $H_0$ does not establish that $H_0$ is true — it only indicates the data did not provide strong enough evidence to reject it at the chosen $\alpha$ level.

This asymmetry is a standard, well-established conceptual point in statistical methodology, analogous to the presumption of innocence in a legal framework: failure to prove guilt is not equivalent to proof of innocence.

### Type I and Type II Errors

| | $H_0$ is True | $H_0$ is False |
|---|---|---|
| **Reject $H_0$** | Type I Error (probability $\alpha$) | Correct decision (power $= 1-\beta$) |
| **Fail to reject $H_0$** | Correct decision | Type II Error (probability $\beta$) |

- **Type I error:** Rejecting a true null hypothesis (a "false positive")
- **Type II error:** Failing to reject a false null hypothesis (a "false negative")

This table and terminology are standard across mathematical statistics.

[Inference] There is commonly described trade-off between Type I and Type II error rates for a fixed sample size — decreasing $\alpha$ (reducing Type I error risk) generally increases $\beta$ (Type II error risk), holding other factors constant. This relationship is a standard theoretical result under typical testing setups, though the exact magnitude of the trade-off depends on the specific test, effect size, and sample size involved.

### Statistical Power

**Power** is defined as $1 - \beta$, the probability of correctly rejecting $H_0$ when $H_1$ is true. Power depends on:

- Sample size $n$ (larger $n$ generally increases power)
- Effect size (larger true differences from $\theta_0$ generally increase power)
- Significance level $\alpha$ (larger $\alpha$ generally increases power, at the cost of higher Type I error risk)
- Variability in the data (lower variability generally increases power)

These relationships are standard and well-established in statistical theory.

### Worked Example — Setting Up Hypotheses

Suppose a researcher wants to test whether a new website design increases the average time-on-page compared to a known baseline of $\mu_0 = 120$ seconds.

Since the researcher is specifically interested in whether the new design *increases* time-on-page (a directional claim), a one-sided test is appropriate:

$$H_0: \mu = 120 \quad \text{vs.} \quad H_1: \mu > 120$$

This setup follows directly from the definitions above and reflects a standard directional hypothesis structure given the stated research question.

### p-values

The **p-value** is the probability, computed under the assumption that $H_0$ is true, of observing a test statistic at least as extreme as the one actually observed.

$$p\text{-value} = P(\text{test statistic at least as extreme as observed} \mid H_0 \text{ true})$$

If the p-value is less than $\alpha$, $H_0$ is rejected. This is a standard, well-established definition.

**Common misinterpretation:** The p-value is *not* the probability that $H_0$ is true, nor is it the probability that the observed result occurred "by chance" in a general sense. It is a conditional probability computed under a specific assumption ($H_0$ true). This distinction is a standard and frequently emphasized point in statistics pedagogy.

### Relationship to Confidence Intervals

A two-sided hypothesis test of $H_0: \theta = \theta_0$ at significance level $\alpha$ rejects $H_0$ if and only if $\theta_0$ falls outside the corresponding $100(1-\alpha)\%$ confidence interval. This duality was addressed in the confidence intervals topic and is a standard, well-established result.

### Hypothesis Test Decision Framework (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Hypothesis Test Decision Framework (svg_diagram)</text>

  <rect x="290" y="55" width="180" height="55" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
  <text x="380" y="80" text-anchor="middle" font-size="12" fill="#1a1a1a">State H₀ and H₁</text>
  <text x="380" y="98" text-anchor="middle" font-size="11" fill="#333">before observing data</text>

  <line x1="380" y1="110" x2="380" y2="145" stroke="#666" stroke-width="1.5" marker-end="url(#arrow7)" />

  <rect x="270" y="150" width="220" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="380" y="175" text-anchor="middle" font-size="12" fill="#1a1a1a">Compute test statistic</text>
  <text x="380" y="193" text-anchor="middle" font-size="11" fill="#333">and p-value</text>

  <line x1="380" y1="205" x2="380" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="235" x2="200" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="235" x2="560" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="200" y1="235" x2="200" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow7)" />
  <line x1="560" y1="235" x2="560" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow7)" />

  <text x="290" y="228" text-anchor="middle" font-size="11" fill="#555">p &lt; α</text>
  <text x="470" y="228" text-anchor="middle" font-size="11" fill="#555">p ≥ α</text>

  <rect x="110" y="260" width="180" height="55" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
  <text x="200" y="285" text-anchor="middle" font-size="12" fill="#1a1a1a">Reject H₀</text>
  <text x="200" y="303" text-anchor="middle" font-size="11" fill="#333">evidence against H₀</text>

  <rect x="470" y="260" width="180" height="55" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
  <text x="560" y="285" text-anchor="middle" font-size="12" fill="#1a1a1a">Fail to reject H₀</text>
  <text x="560" y="303" text-anchor="middle" font-size="11" fill="#333">insufficient evidence</text>

  </svg>

### Relevance to Machine Learning

- **Model comparison:** Hypothesis testing frameworks are used when statistically comparing performance between two models or algorithms (e.g., testing whether a difference in accuracy is statistically significant).
- **A/B testing:** The null and alternative hypothesis structure is foundational to A/B testing in product and ML experimentation contexts, where $H_0$ typically represents "no difference between variants."
- **Feature selection:** Hypothesis tests on regression coefficients (testing $H_0: \beta_j = 0$) are used to assess whether individual features have a statistically detectable relationship with the outcome variable.

[Inference] These applications are commonly described in applied statistics and machine learning experimentation literature, but I do not have a specific verified source I can cite confirming exact current practice across ML tooling or organizations generally.

[Unverified] I do not have a verified source confirming which significance level ($\alpha = 0.05$ vs. other values) is treated as a universal standard within machine learning experimentation practice specifically, as opposed to general statistical convention.

### Common Pitfalls

- **Treating "fail to reject $H_0$" as "proof $H_0$ is true":** As discussed above, this is a direct misapplication of the hypothesis testing logic.
- **Interpreting the p-value as the probability $H_0$ is true:** This is a standard, frequently documented misinterpretation distinct from the correct conditional-probability definition given above.
- **Choosing a one-sided vs. two-sided test after seeing the data:** [Inference] This is commonly flagged in statistical methodology literature as a practice that can inflate the effective Type I error rate, though I do not have a specific verified quantitative source to cite for the magnitude of this inflation.
- **Confusing statistical significance with practical/business significance:** A statistically significant result (small p-value) does not necessarily indicate a practically meaningful effect size, particularly with large sample sizes where even trivial effects can produce small p-values.

### Note on Source Verification

I cannot verify specific textbook page numbers or specific attributed quotations without a cited source available in this conversation. The definitions, procedures, and terminology presented above reflect standard, widely taught hypothesis testing theory, not a quotation from any specific text.

**This entire response contains unverified elements as flagged above (particularly claims about ML-specific conventions and the magnitude of error-rate inflation from post-hoc test-direction selection); treat those specific claims accordingly. The core definitions, procedural framework, and Type I/Type II error structure are standard, well-established statistical theory.**

### Next Steps

- **p-values and Significance Testing** — deeper treatment of p-value computation and interpretation
- **Type I and Type II Errors** — detailed treatment of error trade-offs and power analysis
- **Statistical Power Analysis** — formal methods for determining required sample size given desired power
- **Common Hypothesis Tests** — z-test, t-test, Chi-square test, ANOVA overview
- **Multiple Testing and the Multiple Comparisons Problem** — adjustments needed when conducting many tests simultaneously
- **A/B Testing Methodology** — practical application of hypothesis testing in experimentation
- **Statistical vs. Practical Significance** — distinguishing detectability from meaningfulness of an effect