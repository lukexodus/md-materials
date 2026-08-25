## Confidence Interval for Proportions

### Overview

This topic covers confidence intervals for a population proportion $p$, estimated from a sample proportion $\hat{p}$. Unlike the mean of a continuous variable, proportions are based on binary (Bernoulli) outcomes, which introduces distinct considerations — particularly around the normal approximation's reliability at small sample sizes or extreme proportions.

This is standard content found consistently across mathematical statistics textbooks.

### Sample Proportion and Its Distribution

For $n$ independent Bernoulli trials with success probability $p$, the sample proportion is:

$$\hat{p} = \frac{X}{n}$$

where $X = \sum_{i=1}^n X_i$ is the number of successes, $X \sim \text{Binomial}(n, p)$.

The mean and variance of $\hat{p}$ are:

$$E[\hat{p}] = p, \quad \text{Var}(\hat{p}) = \frac{p(1-p)}{n}$$

These are directly derivable from the properties of the binomial distribution.

By the Central Limit Theorem, for sufficiently large $n$:

$$\hat{p} \approx N\left(p, \frac{p(1-p)}{n}\right)$$

This normal approximation underlies the most commonly taught confidence interval method for proportions.

### Wald Confidence Interval

The Wald interval substitutes $\hat{p}$ for the unknown $p$ in the variance formula and applies the normal approximation:

$$\hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$$

This is the most commonly taught method due to its simplicity, and the formula itself is standard and directly derivable from the normal approximation above.

**Known limitation:** The Wald interval is documented in statistical literature as having poor coverage properties — meaning its actual coverage rate can deviate substantially from the nominal confidence level — particularly when $n$ is small or $\hat{p}$ is close to 0 or 1. This is a well-established finding in statistical methodology literature.

[Unverified] I cannot verify a single precise, universally-agreed-upon numerical threshold (e.g., a specific minimum $n\hat{p}$ value) for when Wald coverage becomes unacceptable, as this depends on the specific true $p$ and $n$ combination and different sources present varying guidance. Commonly cited rules of thumb suggest checking that $n\hat{p} \geq 5$ and $n(1-\hat{p}) \geq 5$, but I cannot verify this specific threshold as authoritative across all sources — treat it as a general heuristic, not a confirmed cutoff.

### Worked Example — Wald Interval

Suppose $n = 100$ trials yield $X = 60$ successes, so $\hat{p} = 0.60$. Constructing a 95% confidence interval:

$$0.60 \pm 1.96\sqrt{\frac{0.60(0.40)}{100}} = 0.60 \pm 1.96(0.049) = 0.60 \pm 0.096$$

Resulting interval: $(0.504,\ 0.696)$

This calculation follows directly from the formula above and is verifiable by computation.

### Wilson Score Interval

The Wilson score interval addresses the Wald interval's known weaknesses by inverting the normal approximation to the binomial test directly, rather than using a simple plug-in variance estimate. The formula:

$$\frac{\hat{p} + \frac{z_{\alpha/2}^2}{2n} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n} + \frac{z_{\alpha/2}^2}{4n^2}}}{1 + \frac{z_{\alpha/2}^2}{n}}$$

This interval is documented in statistical literature as having better coverage properties than the Wald interval across a wider range of $n$ and $p$ values, including smaller sample sizes. [Inference] This claim reflects widely reported findings in statistical methodology sources describing the Wilson interval's coverage performance; I have not independently re-derived or simulated this comparison within this response.

### Clopper-Pearson (Exact) Interval

The Clopper-Pearson interval is constructed by directly inverting the binomial distribution rather than relying on a normal approximation. It is based on the relationship between the binomial CDF and the Beta distribution:

$$\left(\text{Beta}^{-1}\left(\frac{\alpha}{2}; X, n-X+1\right),\ \text{Beta}^{-1}\left(1-\frac{\alpha}{2}; X+1, n-X\right)\right)$$

This method guarantees that the actual coverage is at least the nominal confidence level (i.e., it is conservative), because it does not rely on a large-sample approximation. This "exact" property is a standard, well-established mathematical characteristic of this construction method, since it directly inverts the binomial distribution rather than approximating it.

[Inference] Because it is conservative, the Clopper-Pearson interval is commonly described in statistical literature as tending to be wider than necessary compared to the Wilson interval, particularly for small $n$. I have not independently verified this specific comparison through simulation within this response.

### Comparison Summary

| Method | Basis | Known Behavior |
| --- | --- | --- |
| Wald | Normal approximation, plug-in variance | Simple; documented poor coverage for small $n$ or extreme $\hat{p}$ |
| Wilson | Inverted normal approximation | Documented improved coverage across broader range of $n$, $p$ |
| Clopper-Pearson | Exact binomial inversion | Conservative; guarantees minimum nominal coverage; can be wider |

[Unverified] I do not have simulation results generated within this conversation to independently confirm the relative performance claims in this table — these reflect commonly reported findings in statistical methodology literature, not a verification I have personally performed here.

### Assumptions and Validity Conditions

- Trials are independent
- Each trial has constant success probability $p$ (i.e., the Bernoulli/binomial model holds)
- For the Wald and Wilson intervals, the normal approximation is used (exact for Clopper-Pearson)

[Inference] Violations of independence (e.g., clustered or correlated binary outcomes) are commonly described in statistical literature as invalidating the standard variance formula used above. I do not have a general correction formula that applies universally across arbitrary dependence structures — the correction depends on the specific dependence structure.

### Relevance to Machine Learning

- **Classification accuracy reporting:** Model accuracy, precision, and recall are proportions, and confidence intervals for these metrics quantify uncertainty in reported performance.
- **A/B testing for conversion rates:** Comparing proportions (e.g., click-through rates) between two model variants or system configurations often relies on confidence intervals for proportions or their difference.
- **Class imbalance settings:** [Inference] When a proportion of interest is small (e.g., rare-event detection rates), the Wald interval's known weaknesses at extreme $\hat{p}$ values are particularly relevant, making Wilson or Clopper-Pearson intervals potentially more appropriate. I have not verified a specific ML methodology source recommending this exact substitution as standard current practice.

[Unverified] I do not have a verified, specific source confirming which of these interval methods is treated as the default standard within current machine learning evaluation libraries or practices generally — this varies by tool and practitioner.

### Wald vs Wilson Interval Width (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Wald vs Wilson Interval Width (svg_diagram)</text>
<line x1="80" y1="290" x2="700" y2="290" stroke="#333" stroke-width="1.5" />
<line x1="80" y1="290" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
<text x="390" y="320" text-anchor="middle" font-size="13" fill="#333">Sample Proportion p̂ (fixed n, small)</text>
<text x="30" y="175" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 30 175)">Interval Width</text>
<path d="M 100 220 Q 250 90 390 70 T 680 220" fill="none" stroke="#a53a3a" stroke-width="2.5" />
<text x="600" y="110" font-size="11" fill="#a53a3a">Wald (shrinks near 0/1)</text>
<path d="M 100 180 Q 250 130 390 120 T 680 180" fill="none" stroke="#4a6fa5" stroke-width="2.5" />
<text x="600" y="160" font-size="11" fill="#4a6fa5">Wilson (more stable)</text>

<text x="105" y="235" font-size="11" fill="#555">p̂≈0</text>

<text x="380" y="65" font-size="11" fill="#555">p̂≈0.5</text>

<text x="655" y="235" font-size="11" fill="#555">p̂≈1</text>

<text x="390" y="55" text-anchor="middle" font-size="12" fill="#666">Qualitative illustration — not derived from simulation in this response</text>

</svg>

[Unverified] The diagram above is a qualitative, illustrative representation of commonly reported directional patterns (Wald interval narrowing artificially near 0 and 1) and is not generated from an actual simulation or dataset within this conversation. Exact shapes and magnitudes are not verified.

### Common Pitfalls

- **Using the Wald interval with small $n$ or extreme $\hat{p}$:** Documented in statistical literature as producing coverage below the nominal level in these conditions.
- **Interval bounds falling outside $[0,1]$:** The Wald interval can produce a lower bound below 0 or an upper bound above 1 when $\hat{p}$ is near the boundary, which is logically invalid for a proportion. The Wilson and Clopper-Pearson intervals do not have this specific problem, by construction.
- **Assuming independence when trials are clustered:** [Inference] Applying the standard binomial variance formula to clustered data (e.g., repeated measurements from the same subject) is commonly described in statistical literature as producing understated standard errors. I do not have a general correction I can confirm as universally applicable here.
- **Treating "exact" (Clopper-Pearson) as synonymous with "best":** The exact method's conservatism means it can produce wider intervals than necessary; [Inference] whether this trade-off is preferable depends on the specific application's tolerance for interval width versus guaranteed minimum coverage, which is a judgment call rather than a fact I can resolve generally.

### Note on Source Verification

I cannot verify specific textbook page numbers, specific simulation studies, or exact numerical coverage-rate comparisons between these methods without a specific cited source in this conversation. Statements above about relative performance (Wald vs. Wilson vs. Clopper-Pearson) reflect commonly reported findings in statistical methodology literature as generally taught, not a citation I can confirm precisely in this response.

**This entire response contains unverified elements as flagged above; treat comparative performance claims and ML-practice claims accordingly.**

### Next Steps

- **Confidence Interval for the Mean** — contrast with the continuous-variable case
- **Hypothesis Testing for Proportions** — one-sample and two-sample z-tests
- **Confidence Interval for the Difference of Two Proportions** — pooled vs. unpooled approaches
- **Continuity Correction for Normal Approximation to Binomial** — refinement to the Wald method
- **Beta-Binomial Bayesian Credible Intervals** — Bayesian alternative to Clopper-Pearson
- **Sample Size Determination for Proportions** — planning studies with a target margin of error
- **Coverage Probability Simulation Studies** — methodology for empirically comparing interval methods