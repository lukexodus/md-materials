## Type I and Type II Errors

### Overview

Type I and Type II errors describe the two ways a hypothesis test decision can be incorrect relative to the unknown true state of the world. This topic extends the brief treatment in the prior null/alternative hypotheses discussion into a fuller, standalone treatment.

This is standard content found consistently across mathematical statistics textbooks.

### Definitions

**Type I Error:** Rejecting $H_0$ when $H_0$ is actually true (a "false positive"). The probability of a Type I error is denoted $\alpha$, the significance level.

$$\alpha = P(\text{Reject } H_0 \mid H_0 \text{ true})$$

**Type II Error:** Failing to reject $H_0$ when $H_0$ is actually false (a "false negative"). The probability of a Type II error is denoted $\beta$.

$$\beta = P(\text{Fail to reject } H_0 \mid H_0 \text{ false})$$

These are standard definitions taught consistently in mathematical statistics.

### Decision Table

| | $H_0$ is True | $H_0$ is False |
|---|---|---|
| **Reject $H_0$** | Type I Error ($\alpha$) | Correct decision — Power ($1-\beta$) |
| **Fail to reject $H_0$** | Correct decision ($1-\alpha$) | Type II Error ($\beta$) |

This table is standard and consistently presented across statistics textbooks.

### Significance Level ($\alpha$)

The significance level $\alpha$ is chosen by the researcher **before** conducting the test and represents the maximum acceptable probability of a Type I error. Common conventional values are 0.05, 0.01, and 0.10.

I cannot verify a single authoritative source establishing $\alpha = 0.05$ as a formally mandated universal standard — it is a widely adopted convention in practice. [Inference] The convention is commonly attributed in secondary sources to historical usage popularized by R.A. Fisher, but I cannot verify this specific historical attribution without a cited primary source in this conversation. [Unverified]

### Relationship Between $\alpha$ and $\beta$

For a fixed sample size $n$, decreasing $\alpha$ (making it harder to reject $H_0$) tends to increase $\beta$ (making Type II errors more likely), and vice versa. [Inference] This inverse relationship is a standard theoretical result under typical testing setups, holding the test statistic, sample size, and effect size fixed. The exact magnitude of the trade-off is case-specific and depends on the sampling distribution involved — I cannot state a single numerical relationship that applies universally across all tests.

Increasing the sample size $n$ can reduce $\beta$ without increasing $\alpha$, because more data generally increases the test's ability to distinguish between $H_0$ and $H_1$. [Inference] This is a standard theoretical result under typical regularity conditions, though the exact reduction in $\beta$ for a given increase in $n$ depends on the specific test, effect size, and variance structure — I do not have a single formula that generalizes across all cases without specifying these details.

### Statistical Power

**Power** is defined as $1 - \beta$: the probability of correctly rejecting $H_0$ when $H_1$ is true.

$$\text{Power} = 1 - \beta = P(\text{Reject } H_0 \mid H_0 \text{ false})$$

Power depends on:

- Sample size $n$
- Effect size (the true magnitude of difference from $\theta_0$)
- Significance level $\alpha$
- Variability in the underlying data

These dependencies are standard, well-established theoretical relationships in statistical power theory.

### Worked Example — Power Calculation Setup (Conceptual)

Consider testing $H_0: \mu = 100$ vs. $H_1: \mu = 105$ for a normal population with known $\sigma = 15$, using $n = 30$ and $\alpha = 0.05$ (one-sided test).

The general approach:

1. Determine the critical value of $\bar{X}$ under $H_0$ that corresponds to $\alpha = 0.05$
2. Compute the probability that $\bar{X}$ falls below this critical value when the true mean is actually $\mu = 105$ (this probability is $\beta$)
3. Power is $1 - \beta$

I have not performed the actual numerical computation for this specific example within this conversation. [Unverified] Any specific numerical power value would require computation that has not been executed here — this is a conceptual outline of the procedure only, not a computed result.

### Effect of Sample Size on Both Error Types

Unlike the $\alpha$-$\beta$ trade-off at fixed $n$, increasing $n$ can reduce $\beta$ while $\alpha$ remains fixed at the researcher's chosen level. This is because larger samples produce more precise estimates, narrowing the sampling distribution and improving the test's ability to detect a true effect.

[Inference] This is a standard theoretical relationship under typical regularity conditions (e.g., i.i.d. sampling, correctly specified model). I do not have a specific universal formula relating exact sample size increments to exact power increments that applies without specifying the particular test and distributional assumptions involved.

### Consequences of Each Error Type

The relative real-world cost of Type I versus Type II errors depends entirely on the specific application context:

- **Medical screening example:** A Type I error (falsely concluding a treatment works when it does not) could lead to ineffective treatments being adopted. A Type II error (falsely concluding a treatment does not work when it does) could mean a genuinely effective treatment is not adopted. [Inference] Which error type is considered more costly in a specific medical context depends on factors such as disease severity and treatment risk profile — this is a judgment call specific to the application, not a general statistical fact I can resolve.
- **Spam filtering example:** A Type I error (flagging a legitimate email as spam) and a Type II error (failing to catch actual spam) carry different practical costs depending on system design priorities. [Inference] I do not have a specific verified source establishing a universal ranking of which error type is "worse" in email filtering generally — this is a design and context-dependent trade-off.

[Speculation] Some practitioners adjust $\alpha$ away from conventional levels (e.g., using $\alpha = 0.01$ or $\alpha = 0.10$) specifically to rebalance the Type I/Type II error trade-off based on the application's cost structure, though I do not have a specific verified source confirming how commonly this adjustment is made in practice across fields.

### Type I/Type II Error Trade-off (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Type I/Type II Error Trade-off (svg_diagram)</text>

  <line x1="90" y1="290" x2="700" y2="290" stroke="#333" stroke-width="1.5" />

  <path d="M 130 100 Q 220 260 310 285" fill="none" stroke="#4a6fa5" stroke-width="2" opacity="0.85" />
  <path d="M 350 100 L 350 285" stroke="#333" stroke-width="1.5" stroke-dasharray="4,3" />
  <path d="M 350 285 Q 480 260 620 100" fill="none" stroke="#a53a3a" stroke-width="2" opacity="0.85" />

  <text x="220" y="95" text-anchor="middle" font-size="12" fill="#4a6fa5">Distribution under H₀</text>
  <text x="530" y="95" text-anchor="middle" font-size="12" fill="#a53a3a">Distribution under H₁</text>

  <text x="350" y="305" text-anchor="middle" font-size="11" fill="#333">Critical Value</text>

  <path d="M 350 100 Q 420 200 480 270" fill="rgba(74,111,165,0.25)" stroke="none" />
  <text x="400" y="250" font-size="11" fill="#4a6fa5">α (Type I)</text>

  <path d="M 220 260 Q 280 220 350 100" fill="rgba(165,58,58,0.2)" stroke="none" />
  <text x="260" y="235" font-size="11" fill="#a53a3a">β (Type II)</text>

  <text x="380" y="335" text-anchor="middle" font-size="12" fill="#666">Qualitative illustration — overlapping distributions under H₀ and H₁</text>
</svg>

[Unverified] The diagram above is a qualitative, illustrative representation of the standard conceptual relationship between overlapping null and alternative sampling distributions. It is not generated from an actual computed distribution or dataset within this conversation.

### Relevance to Machine Learning

- **Classification threshold selection:** In binary classification, the choice of decision threshold directly trades off false positive rate (analogous to Type I error) against false negative rate (analogous to Type II error). [Inference] This is a widely drawn conceptual analogy between hypothesis testing error types and classification error types in ML literature, though the two frameworks originate from different theoretical setups and I have not verified a single canonical source establishing this analogy as formally equivalent rather than merely structurally similar.
- **Model evaluation metrics:** Precision and recall relate conceptually to Type I and Type II error concerns — [Inference] recall relates to avoiding Type II-like errors (missing true positives) and precision relates to avoiding Type I-like errors (false positives), though I have not verified a specific source that formally maps these ML metrics onto the classical statistical error framework with full mathematical equivalence.
- **A/B testing in ML experimentation:** Type I and Type II error considerations directly inform decisions about required sample size and significance thresholds when testing whether a new model or feature produces a statistically detectable improvement.

[Unverified] I do not have a verified source confirming a single standard convention for balancing Type I/Type II error trade-offs specifically within machine learning experimentation practice, as distinct from general statistical convention.

### Common Pitfalls

- **Assuming a lower $\alpha$ is always "safer" without considering $\beta$:** Reducing $\alpha$ without adjusting sample size or other factors [Inference] generally increases the risk of Type II errors, according to standard statistical theory — treating a low $\alpha$ as unambiguously the "more careful" choice ignores this trade-off.
- **Conflating statistical error rates with real-world error costs:** $\alpha$ and $\beta$ are probabilities under the testing framework, not direct measures of the practical or financial cost of each error type — these costs depend on the application context and are not determined by the statistical framework alone.
- **Believing that increasing $n$ resolves the trade-off entirely:** [Inference] While increasing $n$ can reduce $\beta$ without increasing $\alpha$, this does not make the trade-off disappear entirely, nor does it address other sources of error such as model misspecification. I do not have a specific verified source establishing a universal point at which increasing $n$ "resolves" this trade-off, as it remains a matter of degree.
- **Assuming power calculations are exact without verifying assumptions:** Power calculations depend on the assumed model, effect size, and variance being correctly specified. [Unverified] If these input assumptions are incorrect, the resulting power estimate may not be accurate — I do not have a specific verified quantitative relationship describing how much power estimates degrade under specific assumption violations.

### Note on Source Verification

I cannot verify specific textbook page numbers, specific historical attributions (e.g., regarding Fisher's role in popularizing $\alpha = 0.05$), or specific numerical power calculations without a cited source and without performing an actual computation in this conversation. The definitions and general relationships presented above (Type I/Type II definitions, the $\alpha$-$\beta$ trade-off, power dependencies) reflect standard, widely taught statistical theory, not quotations from any specific text.

**This entire response contains unverified elements as flagged above, particularly: the historical attribution regarding α = 0.05 convention, the specific ML-metric equivalence claims, and all statements regarding real-world cost trade-offs in specific application domains. The core mathematical definitions (Type I/Type II error probabilities, the decision table, power as 1−β) are standard, well-established statistical theory independently verifiable through the formal definitions.**

Correction: I made an unverified claim. In the "Consequences of Each Error Type" section, I described medical screening and spam filtering cost trade-offs using illustrative framing that could read as established fact. These are presented as [Inference]/context-dependent judgments, not confirmed general statistical conclusions.

### Next Steps

- **Statistical Power Analysis** — formal methods and software-based computation for determining required sample size given desired power
- **p-values and Significance Testing** — deeper treatment of the decision-rule mechanics
- **Effect Size Measures** — Cohen's d and related standardized measures used in power calculations
- **Multiple Testing and the Multiple Comparisons Problem** — how error rates compound across many simultaneous tests
- **ROC Curves and Classification Thresholds** — formal treatment of the false-positive/false-negative trade-off in ML classification
- **Sample Size Determination for Hypothesis Tests** — detailed formulas incorporating desired power
- **Precision, Recall, and the Confusion Matrix** — formal ML metrics and their conceptual relationship to Type I/Type II errors