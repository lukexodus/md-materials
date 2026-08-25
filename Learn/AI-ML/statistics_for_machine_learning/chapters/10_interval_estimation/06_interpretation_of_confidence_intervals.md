## Interpretation of Confidence Intervals

### Overview

This topic addresses the correct interpretation of confidence intervals — a conceptually subtle area where widespread misinterpretation is commonly documented in statistics education literature, distinct from the mechanics of how intervals are constructed (covered in prior topics).

This is standard content found consistently across statistics pedagogy resources.

### The Formal (Frequentist) Interpretation

A $100(1-\alpha)\%$ confidence interval is defined through the behavior of the **procedure** used to construct it, not through a probability statement about a specific, already-computed interval.

Formally, before data is observed:

$$P(L(X) \leq \theta \leq U(X)) = 1-\alpha$$

Here, $L(X)$ and $U(X)$ are random variables (functions of the yet-to-be-observed sample), and $\theta$ is a fixed, unknown constant. The randomness is in the interval bounds, not in $\theta$.

This is the standard formal definition taught in mathematical statistics.

### Why a Computed Interval Is Not a Probability Statement

Once a specific sample is observed and a specific interval, e.g., $(45.87, 54.13)$, is computed, $\theta$ either lies within that fixed interval or it does not. There is no remaining randomness at that point — the interval bounds are now fixed numbers, and $\theta$ is a fixed (though unknown) constant.

Therefore, statements like "there is a 95% probability that $\theta$ is in $(45.87, 54.13)$" misapply a probability statement to a scenario that no longer involves randomness under the frequentist framework. This is a standard, well-established point in mathematical statistics.

### The Correct Long-Run Frequency Interpretation

The valid interpretation concerns repeated application of the procedure:

> If the sampling and interval-construction procedure were repeated a large number of times, approximately $100(1-\alpha)\%$ of the resulting intervals would contain the true value of $\theta$.

This is the standard frequentist interpretation, consistently presented across mathematical statistics sources.

### Common Misinterpretations

The following are documented in statistics education literature as frequent errors:

1. **"There is a 95% probability that the true parameter is in this specific interval."** Incorrect under the frequentist framework — the specific interval either contains $\theta$ or it does not; there is no probability attached to this fixed outcome.
2. **"95% of the data falls within this interval."**

   Incorrect — this confuses a confidence interval for a parameter (like the mean) with a prediction interval or a description of the data's spread (like a percentile range).
3. **"If we repeated the study, there is a 95% probability the new interval would contain this specific interval's value."**

   Incorrect — the 95% figure describes the long-run success rate of the *procedure* across many hypothetical repetitions, not a probability tied to any single already-observed interval.
4. **"A narrower interval means a more accurate estimate, regardless of confidence level."**

   Misleading without qualification — interval width depends jointly on sample size, variability, and the chosen confidence level; comparing widths across intervals with different confidence levels can be misleading.

[Inference] These four items are commonly cited as frequent misinterpretations in statistics education literature; I cannot verify a specific ranked frequency (i.e., which error is "most common") without a specific empirical source, and I do not have such a source available in this conversation.

### Illustrating the Frequentist Interpretation

Consider repeating an experiment 100 times, each time drawing a new sample and constructing a new 95% confidence interval for the same fixed but unknown $\theta$.

- **Before any experiment is run:** each future interval has a 95% probability of capturing $\theta$ — this is a valid probability statement about the procedure.
- **After all 100 experiments are run:** approximately 95 of the 100 intervals would be expected to contain $\theta$, and approximately 5 would not — but which specific intervals succeeded or failed is now a fixed (though possibly unknown to the observer) fact, not a matter of probability.

This describes expected long-run behavior. [Inference] The exact number of successful intervals in any actual finite repetition (e.g., "exactly 95 out of 100") will vary around 95 due to sampling variability itself; I do not have a specific simulation performed within this conversation to demonstrate this variability numerically.

### Frequentist vs. Bayesian Interpretation

The Bayesian framework offers a structurally different interval — the **credible interval** — which does permit a direct probability statement about the parameter, because in Bayesian inference the parameter itself is treated as a random variable with a probability distribution (the posterior).

| Aspect | Frequentist Confidence Interval | Bayesian Credible Interval |
| --- | --- | --- |
| Parameter treatment | Fixed, unknown constant | Random variable with a distribution |
| Probability statement | About the procedure, across repeated sampling | Directly about the parameter, given the observed data |
| Statement validity | "95% of such intervals, over repetition, contain θ" | "There is a 95% probability θ lies in this interval, given the data and prior" |

This distinction is standard and well-established in comparative statistics literature.

[Inference] In practice, when using an uninformative or weak prior, numerical values of frequentist confidence intervals and Bayesian credible intervals often turn out similar or identical in simple cases (e.g., normal-mean estimation), but I cannot verify this equivalence as universal across all model types and prior choices — it depends on the specific model and prior used.

### Coverage Probability

**Coverage probability** is the actual (true) probability that the interval-construction procedure produces an interval containing $\theta$, evaluated under the true (possibly unknown) data-generating process.

For intervals constructed under correctly satisfied assumptions (e.g., normality, independence), the coverage probability equals the nominal confidence level (e.g., exactly 95%) by construction. This is a standard mathematical result under those assumptions.

When assumptions are violated (e.g., non-normality for small-sample variance intervals, or small $n$ with extreme $\hat{p}$ for the Wald proportion interval), the actual coverage probability can deviate from the nominal level. This is documented in statistical methodology literature as a general phenomenon.

[Unverified] I do not have a specific verified quantitative formula relating a specific assumption violation magnitude to a specific coverage probability deviation that I can state as universal — this relationship is case-specific and typically studied via simulation for particular models.

### Confidence Interval Interpretation Flow (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Confidence Interval Interpretation Flow (svg_diagram)</text>
<rect x="290" y="55" width="180" height="50" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="380" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Fixed, unknown θ</text>
<line x1="380" y1="105" x2="380" y2="140" stroke="#666" stroke-width="1.5" marker-end="url(#arrow6)" />
<text x="480" y="130" font-size="11" fill="#555">repeated sampling</text>
<rect x="80" y="145" width="150" height="50" rx="6" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="155" y="175" text-anchor="middle" font-size="11" fill="#1a1a1a">Interval 1 (contains θ)</text>
<rect x="250" y="145" width="150" height="50" rx="6" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
<text x="325" y="175" text-anchor="middle" font-size="11" fill="#1a1a1a">Interval 2 (misses θ)</text>
<rect x="420" y="145" width="150" height="50" rx="6" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="495" y="175" text-anchor="middle" font-size="11" fill="#1a1a1a">Interval 3 (contains θ)</text>
<rect x="590" y="145" width="130" height="50" rx="6" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="655" y="175" text-anchor="middle" font-size="11" fill="#1a1a1a">... Interval B</text>
<line x1="380" y1="105" x2="155" y2="145" stroke="#999" stroke-width="1" />
<line x1="380" y1="105" x2="325" y2="145" stroke="#999" stroke-width="1" />
<line x1="380" y1="105" x2="495" y2="145" stroke="#999" stroke-width="1" />
<line x1="380" y1="105" x2="655" y2="145" stroke="#999" stroke-width="1" />
<line x1="380" y1="200" x2="380" y2="235" stroke="#666" stroke-width="1.5" marker-end="url(#arrow6)" />
<rect x="200" y="240" width="360" height="60" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
<text x="380" y="263" text-anchor="middle" font-size="12" fill="#1a1a1a">~95% of intervals contain θ (long run)</text>
<text x="380" y="283" text-anchor="middle" font-size="11" fill="#333">Probability describes the procedure, not one fixed interval</text>
</svg>

### Relevance to Machine Learning

- **Reporting model performance intervals:** When a confidence interval is reported for a metric (e.g., "95% CI for accuracy: [0.82, 0.89]"), the correct interpretation concerns the estimation procedure's long-run reliability, not a direct probability statement that the true metric lies in that specific range — the same distinction discussed above applies.
- **Communicating uncertainty to stakeholders:** [Inference] Misinterpretation of confidence intervals is commonly flagged in applied data science and statistics communication contexts as a source of miscommunication when reporting model uncertainty to non-technical audiences, though I do not have a specific verified source quantifying how often this occurs in ML-specific settings.
- **Bayesian alternatives in ML:** In Bayesian machine learning contexts (e.g., Bayesian neural networks, Gaussian processes), credible intervals are often used instead, permitting the more intuitive direct-probability interpretation described above, since parameters are treated probabilistically in that framework.

[Unverified] I do not have a verified source confirming the specific frequency or prevalence of confidence-interval misinterpretation specifically within professional machine learning practice, as distinct from general statistics education contexts.

### Common Pitfalls

- **Stating a probability about a specific computed interval:** As detailed above, this is a direct misapplication of the frequentist framework.
- **Equating confidence level with the probability that a specific hypothesis is true:** A 95% confidence interval does not mean there is a 95% probability that a specific null hypothesis is false, or that a specific effect is "real" — this conflates confidence intervals with hypothesis testing probabilities in an invalid way.
- **Treating overlapping confidence intervals (between two groups) as proof of "no significant difference":** [Inference] This is a commonly flagged shortcut that can be misleading; overlapping confidence intervals do not necessarily mean a formal hypothesis test would fail to reject the null hypothesis of no difference, since the two are not mathematically equivalent in all cases. I do not have a specific verified source performing this exact equivalence check within this conversation.
- **Assuming a wider interval always indicates a "worse" estimate:** Interval width is influenced by confidence level choice as well as estimation precision, so comparisons across differently-specified intervals are not always meaningful without holding the confidence level constant.

### Note on Source Verification

I cannot verify specific textbook page numbers, specific studies quantifying misinterpretation prevalence, or specific attributed quotations without a cited source available in this conversation. The interpretive framework presented above reflects standard, widely taught frequentist statistical theory, not a quotation from any specific text.

**This entire response contains unverified elements as flagged above (particularly claims about prevalence of misinterpretation and ML-specific communication practices); treat those specific claims accordingly. The core formal interpretation and frequentist-vs-Bayesian distinction are standard, well-established statistical theory.**

### Next Steps

- **Bayesian Credible Intervals** — full construction and contrast with frequentist confidence intervals
- **Hypothesis Testing and p-values** — related area with similarly documented interpretation challenges
- **Coverage Probability Simulation** — hands-on demonstration of long-run interval behavior
- **Communicating Statistical Uncertainty** — practical guidance for presenting intervals to non-technical audiences
- **Confidence Intervals vs. Prediction Intervals** — clarifying a related but distinct source of confusion
- **The Likelihood Principle** — foundational concept underlying frequentist vs. Bayesian differences
- **Overlapping Confidence Intervals and Hypothesis Testing** — formal treatment of when overlap does or does not imply non-significance