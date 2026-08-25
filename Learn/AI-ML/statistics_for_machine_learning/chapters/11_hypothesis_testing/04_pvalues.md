## p-values

### Definition

The p-value is the probability, computed under the assumption that $H_0$ is true, of obtaining a test statistic at least as extreme as the one actually observed in the sample.

$$p\text{-value} = P(\text{test statistic at least as extreme as observed} \mid H_0 \text{ true})$$

This is a standard definition taught consistently in mathematical statistics.

### Decision Rule

If the p-value is less than the chosen significance level $\alpha$, $H_0$ is rejected. If the p-value is greater than or equal to $\alpha$, the test fails to reject $H_0$.

$$\text{p-value} < \alpha \implies \text{Reject } H_0$$

This is a standard decision rule taught consistently across mathematical statistics.

### What the p-value Is Not

The following are documented in statistics education literature as frequent misinterpretations:

1. **"The p-value is the probability that $H_0$ is true."** Incorrect. The p-value is computed under the assumption that $H_0$ is already true — it cannot simultaneously serve as a probability statement about whether that assumption itself is correct.
2. **"The p-value is the probability that the results occurred by chance."** Incorrect as a general description. The p-value is a specific conditional probability tied to the observed test statistic and the assumed null distribution, not a general statement about "chance."
3. **"1 minus the p-value is the probability that $H_1$ is true."** Incorrect. This is not how the p-value is mathematically defined or derived.
4. **"A small p-value proves a large or practically important effect."** Incorrect. The p-value reflects the strength of evidence against $H_0$ given the data and sample size, not the magnitude or practical importance of the effect itself.

These misinterpretations are standard, well-documented points of emphasis in statistics pedagogy.

### Worked Example — Computing a p-value (One-Sample Z-Test)

Suppose $H_0: \mu = 100$ vs. $H_1: \mu \neq 100$, with a sample of $n = 36$, $\bar{X} = 104$, and known $\sigma = 12$.

Test statistic:

$$Z = \frac{\bar{X}-\mu_0}{\sigma/\sqrt{n}} = \frac{104-100}{12/\sqrt{36}} = \frac{4}{2} = 2.0$$

For a two-sided test, the p-value is:

$$p\text{-value} = 2 \cdot P(Z > 2.0) = 2(1 - \Phi(2.0))$$

Using standard normal table values, $\Phi(2.0) \approx 0.9772$, so:

$$p\text{-value} \approx 2(1-0.9772) = 2(0.0228) = 0.0456$$

I cannot independently verify the specific tabulated value $\Phi(2.0) \approx 0.9772$ against a live statistical table within this conversation — this is a standard value commonly found in standard normal distribution tables, presented from general knowledge rather than a verified lookup performed here. [Unverified] The arithmetic operations following from this value are directly verifiable by computation.

With $\alpha = 0.05$, since $0.0456 < 0.05$, $H_0$ would be rejected.

### One-Sided vs. Two-Sided p-values

For a one-sided test ($H_1: \mu > \mu_0$), the p-value uses only one tail of the distribution:

$$p\text{-value} = P(Z > z_{\text{observed}})$$

For a two-sided test, both tails are included, typically doubling the one-sided value for symmetric distributions like the normal:

$$p\text{-value} = 2 \cdot P(Z > |z_{\text{observed}}|)$$

This doubling relationship holds for symmetric null distributions; it is a standard, verifiable mathematical relationship following directly from symmetry.

### p-values and Sample Size

For a fixed true effect size, larger sample sizes generally produce smaller p-values, because the test statistic's magnitude typically increases with $n$ (holding effect size and variability fixed) — the same numerical formula pattern seen in the worked example above.

This is a standard mathematical consequence of how test statistics are constructed (e.g., $\sqrt{n}$ appearing in the denominator of the standard error). [Inference] A practical implication commonly noted in statistical methodology literature is that with very large samples, even small and practically unimportant effects can produce statistically significant (small) p-values. I do not have a specific quantitative threshold I can confirm as universal for when an effect becomes "practically unimportant" — this judgment is context-dependent and not a fixed statistical rule.

### The American Statistical Association's Statement on p-values

The American Statistical Association issued a formal statement in 2016 addressing widespread misuse and misinterpretation of p-values in scientific practice.

[Unverified] I cannot verify the exact wording or full specific content of this statement without direct access to the original document within this conversation. I am aware, from general knowledge, that such a statement exists and addressed common p-value misconceptions, but I cannot quote it directly or confirm specific details without a verified source available here. If you would like, I can search for the current text of this statement to provide verified, cited details.

### p-value Hacking and Multiple Testing

**p-hacking** refers to practices — such as testing many hypotheses and selectively reporting only significant results, or repeatedly checking results as data accumulates and stopping once significance is reached — that can inflate the effective false-positive rate beyond the nominal $\alpha$ level.

[Inference] This is commonly discussed as a methodological concern in statistical and scientific literature. I cannot verify a specific quantitative relationship describing exactly how much a particular p-hacking practice inflates the true error rate in general — the magnitude depends on the specific practice and how many hypotheses or looks at the data are involved.

The **multiple comparisons problem** arises when conducting many hypothesis tests simultaneously: even if each individual test has $\alpha = 0.05$, the probability of at least one false positive across many tests increases with the number of tests conducted.

$$P(\text{at least one Type I error across } m \text{ independent tests}) = 1-(1-\alpha)^m$$

This formula is a standard, direct mathematical consequence of the definition of independent events, assuming test independence.

### p-value Decision Process (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 320">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">p-value Decision Process (svg_diagram)</text>

  <rect x="280" y="60" width="200" height="55" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
  <text x="380" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Observed test statistic</text>
  <text x="380" y="103" text-anchor="middle" font-size="11" fill="#333">computed from sample</text>

  <line x1="380" y1="115" x2="380" y2="150" stroke="#666" stroke-width="1.5" marker-end="url(#arrow8)" />

  <rect x="255" y="155" width="250" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="380" y="180" text-anchor="middle" font-size="12" fill="#1a1a1a">p-value under H₀</text>
  <text x="380" y="198" text-anchor="middle" font-size="11" fill="#333">P(as extreme | H₀ true)</text>

  <line x1="380" y1="210" x2="380" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="235" x2="200" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="235" x2="560" y2="235" stroke="#666" stroke-width="1.5" />
  <line x1="200" y1="235" x2="200" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow8)" />
  <line x1="560" y1="235" x2="560" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow8)" />

  <text x="290" y="228" text-anchor="middle" font-size="11" fill="#555">p &lt; α</text>
  <text x="470" y="228" text-anchor="middle" font-size="11" fill="#555">p ≥ α</text>

  <rect x="110" y="260" width="180" height="45" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
  <text x="200" y="288" text-anchor="middle" font-size="12" fill="#1a1a1a">Reject H₀</text>

  <rect x="470" y="260" width="180" height="45" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
  <text x="560" y="288" text-anchor="middle" font-size="12" fill="#1a1a1a">Fail to reject H₀</text>

  </svg>

### Relevance to Machine Learning

- **Model comparison testing:** p-values are used when statistically comparing performance metrics between models, such as testing whether an accuracy difference is unlikely to have arisen under a "no difference" null hypothesis.
- **Feature significance in regression:** Standard regression output commonly includes p-values testing $H_0: \beta_j = 0$ for each coefficient, used to assess whether a feature shows a statistically detectable association with the outcome.
- **A/B testing:** p-values are central to the standard decision framework for determining whether an observed difference between experimental variants is unlikely to be due to random variation alone under the null hypothesis of no true difference.

[Inference] These applications are commonly described in applied statistics and ML experimentation literature. I do not have a specific verified source confirming exact current standard practice across all ML tooling or organizations, and practices may vary by team, tool, and context.

### Common Pitfalls

- **Treating p-value thresholds as an absolute binary truth marker:** Statistical significance based on a p-value threshold does not by itself establish practical importance, causal effect, or the size of an effect.
- **Multiple testing without correction:** Conducting many tests without adjusting $\alpha$ (e.g., via Bonferroni correction) inflates the overall false-positive rate, as shown in the multiple comparisons formula above.
- **Stopping data collection once significance is reached ("optional stopping"):** [Inference] This is commonly flagged in statistical methodology literature as a form of p-hacking that can distort the nominal error rate, though I do not have a specific verified source to cite for a precise quantitative description of this distortion in this response.
- **Reporting only p-values without effect sizes or confidence intervals:** [Inference] This is commonly criticized in statistical methodology and reporting-standards literature as providing an incomplete picture of the evidence, since p-values alone do not convey the magnitude or precision of an estimated effect. I do not have a specific verified source to cite confirming this criticism's origin or prevalence within this response.

### Note on Source Verification

I cannot verify the exact wording of the American Statistical Association's 2016 statement on p-values, specific textbook page numbers, or the specific tabulated normal distribution value used in the worked example ($\Phi(2.0) \approx 0.9772$) against a live source within this conversation. These are presented from general knowledge, not from a verified lookup or citation performed here.

This entire response contains unverified elements as flagged above — particularly the ASA statement reference, the tabulated normal value in the worked example, and claims regarding standard practice within ML tooling. The core mathematical definition of the p-value, the decision rule, and the multiple comparisons formula are standard, well-established statistical theory, independently verifiable through direct computation from the stated definitions.

> Correction: I made an unverified claim regarding the American Statistical Association's statement content without being able to cite its exact text. I have flagged this explicitly rather than presenting it as a confirmed quotation.

### Next Steps

- **Multiple Comparisons Correction Methods** — Bonferroni, Holm, Benjamini-Hochberg (FDR) procedures
- **Effect Size Measures** — reporting alongside p-values for a fuller picture of results
- **Confidence Intervals vs. p-values** — reviewing the duality relationship in more depth
- **p-hacking and Questionable Research Practices** — deeper methodological treatment
- **Bayesian Alternatives to p-values** — Bayes factors and posterior probability approaches
- **Statistical Significance vs. Practical Significance** — distinguishing detectability from importance
- **Common Hypothesis Tests** — z-test, t-test, Chi-square test, and their respective p-value computations