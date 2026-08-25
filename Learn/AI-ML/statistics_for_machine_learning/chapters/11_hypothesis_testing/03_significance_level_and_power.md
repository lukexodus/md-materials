## Significance Level and Power

### Overview

This topic examines the significance level ($\alpha$) and statistical power ($1-\beta$) in depth, building on their introduction in the prior Type I/Type II errors discussion. These two quantities jointly determine a hypothesis test's ability to correctly detect true effects while controlling false positive risk.

This is standard content found consistently across mathematical statistics textbooks.

### Significance Level ($\alpha$)

The significance level is the probability of rejecting $H_0$ when $H_0$ is actually true, chosen by the researcher **before** conducting the test:

$$\alpha = P(\text{Reject } H_0 \mid H_0 \text{ true})$$

Common conventional values are 0.05, 0.01, and 0.10. This is a standard definition taught consistently in mathematical statistics.

I cannot verify that any single value (such as 0.05) is a formally mandated universal standard — it is a widely adopted convention rather than a mathematical necessity.

### Statistical Power

Power is the probability of correctly rejecting $H_0$ when $H_1$ is true:

$$\text{Power} = 1-\beta = P(\text{Reject } H_0 \mid H_0 \text{ false})$$

This is a standard definition. Power is not a fixed property of a test alone — it depends jointly on several factors described below.

### Factors Affecting Power

1. **Sample size ($n$):** Larger $n$ generally increases power, holding other factors fixed. This is a standard theoretical result under typical regularity conditions (e.g., i.i.d. sampling, correctly specified model).
2. **Effect size:** A larger true difference between the parameter under $H_1$ and the value specified under $H_0$ generally increases power. This is standard theory.
3. **Significance level ($\alpha$):** A larger $\alpha$ generally increases power, at the cost of higher Type I error risk. This is a standard, direct mathematical consequence of how the rejection region is defined.
4. **Population variability:** Lower variability in the underlying data generally increases power, holding other factors fixed. This is standard theory.

[Inference] These four relationships are standard theoretical results under typical regularity conditions. I cannot state a single universal formula relating exact magnitudes of change in each factor to exact magnitude of change in power without specifying the particular test, distribution, and parameter values involved — the precise numerical relationship is case-specific.

### Power Function

The **power function** $\pi(\theta)$ expresses power as a function of the true (unknown) parameter value:

$$\pi(\theta) = P(\text{Reject } H_0 \mid \theta \text{ is the true parameter value})$$

When $\theta = \theta_0$ (i.e., $H_0$ is true), $\pi(\theta_0) = \alpha$. As the true $\theta$ moves further from $\theta_0$, $\pi(\theta)$ generally increases toward 1, reflecting that larger true effects are easier to detect.

This is a standard theoretical construct in mathematical statistics, and the property $\pi(\theta_0) = \alpha$ follows directly from the definitions of $\alpha$ and the power function.

### Worked Example — Power for a One-Sample Z-Test (Conceptual Setup)

Consider testing $H_0: \mu = \mu_0$ vs. $H_1: \mu = \mu_1$ (where $\mu_1 > \mu_0$) with known $\sigma$, sample size $n$, and significance level $\alpha$.

The general formula for power in this one-sided case is:

$$\text{Power} = P\left(Z > z_\alpha - \frac{(\mu_1-\mu_0)\sqrt{n}}{\sigma}\right)$$

where $z_\alpha$ is the upper-$\alpha$ critical value of the standard normal distribution, and $Z \sim N(0,1)$.

This formula follows from the standard construction of a one-sided z-test's rejection region combined with the true sampling distribution of $\bar{X}$ under $H_1$. This is a standard, derivable result.

I have not performed a specific numerical computation using specific plugged-in values within this conversation. Any specific numerical power value would require computation not executed here.

### Sample Size Determination for Desired Power

Given a target power $1-\beta$, significance level $\alpha$, effect size $\delta = \mu_1 - \mu_0$, and known $\sigma$, the required sample size for a one-sided test is:

$$n = \left(\frac{(z_\alpha + z_\beta)\sigma}{\delta}\right)^2$$

rounded up to the nearest integer. This is a standard formula derived by algebraically solving the power expression for $n$.

[Inference] In applied settings, $\sigma$ and $\delta$ are often not known with certainty at the planning stage and must be estimated from pilot data or prior research; this substitution is commonly described in statistical methodology literature as standard planning practice, though I cannot verify this as a single universally followed procedure across all applied contexts.

### The $\alpha$–Power Relationship at Fixed $n$

For a fixed sample size, there is a direct trade-off: increasing $\alpha$ (making rejection easier) increases power, but also increases the Type I error rate. Decreasing $\alpha$ reduces power (increasing $\beta$) while reducing Type I error risk.

This inverse relationship, holding $n$ fixed, is a standard theoretical result under typical testing setups.

### Power Curves

A **power curve** plots power ($1-\beta$) as a function of a varying quantity — commonly effect size or sample size — holding other factors fixed. Power curves are used to visualize how power changes as these factors change, and are commonly used in study planning to determine an adequate sample size for a desired power level (often 0.80 by convention).

[Inference] The 0.80 power convention is commonly cited in statistical methodology literature as a widely used planning target, but I cannot verify this as a formally mandated universal standard — it is a convention, not a mathematical requirement.

### Power vs. Sample Size (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Power vs Sample Size (svg_diagram)</text>

  <line x1="80" y1="290" x2="700" y2="290" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="290" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="390" y="320" text-anchor="middle" font-size="13" fill="#333">Sample Size (n)</text>
  <text x="30" y="175" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 30 175)">Power (1-β)</text>

  <line x1="80" y1="130" x2="700" y2="130" stroke="#999" stroke-width="1" stroke-dasharray="4,3" />
  <text x="710" y="134" font-size="11" fill="#666">0.80</text>

  <path d="M 100 270 Q 220 220 320 150 T 500 90 T 680 70" fill="none" stroke="#4a6fa5" stroke-width="2.5" />

  <circle cx="100" cy="270" r="4" fill="#4a6fa5" />
  <circle cx="320" cy="150" r="4" fill="#4a6fa5" />
  <circle cx="440" cy="110" r="4" fill="#4a6fa5" />
  <circle cx="680" cy="70" r="4" fill="#4a6fa5" />

  <text x="390" y="55" text-anchor="middle" font-size="12" fill="#666">Qualitative illustration — not derived from a specific computed model</text>
</svg>

The diagram above is a qualitative, illustrative representation of the standard directional relationship between sample size and power. It is not generated from an actual computed power function or dataset within this conversation.

### Relevance to Machine Learning

- **A/B test planning:** Power calculations inform the required sample size before launching an experiment comparing model variants or product features, so that a meaningful effect (if one exists) has a reasonable chance of being detected.
- **Feature significance testing:** Power considerations relate to whether a study has adequate sample size to detect a coefficient's true effect in regression-based feature evaluation.
- **Underpowered studies:** [Inference] Studies with insufficient sample size relative to the true effect size and desired $\alpha$ are commonly described in statistical methodology literature as prone to failing to detect real effects (Type II errors) and, in some discussions, as associated with exaggerated effect size estimates among the subset of results that do reach significance. I cannot verify a specific quantitative relationship for this exaggeration effect without a specific cited source, and I do not have such a source available in this conversation.

I do not have a verified source confirming a single standard convention for target power levels specifically within machine learning experimentation practice, as distinct from general statistical convention across other fields.

### Common Pitfalls

- **Treating $\alpha = 0.05$ as a fixed law rather than a convention:** This is a widely adopted default, not a value derived from mathematical necessity — appropriate significance levels can and do vary by context.
- **Ignoring power when designing a study:** Focusing only on controlling $\alpha$ without considering power [Inference] commonly results, according to standard statistical theory, in studies that are unlikely to detect real effects even when they exist, particularly with small sample sizes or small true effect sizes.
- **Assuming high power guarantees a study will find significant results:** Power describes the probability of detecting an effect if one truly exists at the assumed magnitude — it does not describe certainty, and it says nothing about whether an effect actually exists in reality.
- **Using post-hoc (observed) power calculations to interpret a completed non-significant result:** [Inference] This practice is commonly criticized in statistical methodology literature as providing limited additional information beyond the p-value itself, though I cannot verify a single universally agreed-upon account of exactly why this criticism holds across all statistical sub-fields, and I do not have a specific source to cite for this claim within this conversation.

### Note on Source Verification

I cannot verify specific textbook page numbers, specific numerical power calculations, or specific claims about conventions within machine learning experimentation practice without a cited source and without performing an actual computation in this conversation. The definitions and formulas presented above (power function, sample size formula, factors affecting power) reflect standard, widely taught statistical theory, not quotations from any specific text.

This entire response contains unverified elements as flagged above, particularly: the 0.80 power convention's status as a universal standard, the post-hoc power criticism, and the underpowered-study effect-size-exaggeration claim. The core mathematical definitions and derivable formulas (power function, sample size formula, α-power trade-off) are standard, well-established statistical theory.

> Correction: In the "Underpowered studies" and "post-hoc power" pitfalls above, I described commonly cited claims from statistical methodology discourse without a specific verifiable source. These are labeled [Inference] rather than confirmed fact, consistent with the labeling required here.

### Next Steps

- **Effect Size Measures** — Cohen's d and standardized effect size metrics used in power calculations
- **Sample Size Determination (detailed)** — extended formulas for two-sample tests, proportions, and unequal variances
- **Power Analysis Software and Simulation Methods** — practical computation approaches
- **Multiple Testing and the Multiple Comparisons Problem** — how power and error rates interact across many simultaneous tests
- **A/B Testing Methodology** — applying power analysis to experimentation design
- **Post-Hoc Power and Its Limitations** — deeper treatment of this contested practice
- **Type I and Type II Errors (review)** — foundational error definitions underlying α and power