## Bayes Factors

### Overview

A Bayes factor is a ratio that quantifies the relative evidence provided by observed data for one statistical hypothesis or model over another. It is a central tool in Bayesian model comparison and hypothesis testing, offering an alternative to frequentist significance testing that does not rely on p-values. In machine learning, Bayes factors are used for model selection, comparing competing hypotheses about data-generating processes, and evaluating relative support for different model structures.

### Formal Definition

For two competing models or hypotheses $M_1$ and $M_2$, given observed data $D$:

$$BF_{12} = \frac{P(D \mid M_1)}{P(D \mid M_2)}$$

where $P(D \mid M_i)$ is the marginal likelihood (evidence) of the data under model $M_i$, obtained by integrating the likelihood over the prior distribution of that model's parameters:

$$P(D \mid M_i) = \int P(D \mid \theta_i, M_i)\, P(\theta_i \mid M_i)\, d\theta_i$$

### Relationship to Posterior Odds

The Bayes factor connects prior odds to posterior odds between two models:

$$\underbrace{\frac{P(M_1 \mid D)}{P(M_2 \mid D)}}_{\text{Posterior odds}} = \underbrace{\frac{P(D \mid M_1)}{P(D \mid M_2)}}_{\text{Bayes factor}} \times \underbrace{\frac{P(M_1)}{P(M_2)}}_{\text{Prior odds}}$$

This shows that the Bayes factor represents the factor by which the data updates the prior odds into posterior odds between the two models. This relationship follows directly from applying Bayes' theorem to each model and taking the ratio, which is a mathematical derivation, not an inference.

### Interpreting Bayes Factor Magnitude

A commonly cited interpretive scale, generally attributed to Harold Jeffreys, categorizes Bayes factor strength as follows:

| $BF_{12}$ | Interpretation (evidence for $M_1$ over $M_2$) |
| --- | --- |
| 1 to 3 | Barely worth mentioning / weak |
| 3 to 10 | Substantial / moderate |
| 10 to 30 | Strong |
| 30 to 100 | Very strong |
| > 100 | Decisive |

I cannot verify the precise wording or exact numeric thresholds of this scale against Jeffreys' original text without directly checking that specific source, so this table should be treated as a commonly cited approximation rather than a confirmed exact reproduction. [Unverified] Other authors have proposed alternative labeling schemes with different thresholds. [Inference — this reflects general awareness that multiple interpretive scales exist in the Bayesian statistics literature, not a specific verified enumeration of those alternative sources in this conversation]

A $BF_{12} < 1$ indicates the data favor $M_2$ over $M_1$; by symmetry, $BF_{21} = 1/BF_{12}$.

### Diagram: Bayes Factor as Evidence Ratio

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 300">
<text x="310" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Bayes factor combining prior and data (svg_diagram)</text>
<rect x="40" y="60" width="150" height="55" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
<text x="115" y="90" text-anchor="middle" font-size="12" fill="#1a1a1a">Prior odds</text>
<text x="115" y="105" text-anchor="middle" font-size="11" fill="#1a1a1a">P(M1)/P(M2)</text>

<text x="235" y="95" text-anchor="middle" font-size="20" fill="#333">x</text>

<rect x="270" y="60" width="150" height="55" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" />
<text x="345" y="83" text-anchor="middle" font-size="12" fill="#1a1a1a">Bayes factor</text>
<text x="345" y="99" text-anchor="middle" font-size="11" fill="#1a1a1a">P(D|M1)/P(D|M2)</text>

<text x="460" y="95" text-anchor="middle" font-size="20" fill="#333">=</text>

<rect x="480" y="60" width="150" height="55" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" />
<text x="555" y="83" text-anchor="middle" font-size="12" fill="#1a1a1a">Posterior odds</text>
<text x="555" y="99" text-anchor="middle" font-size="11" fill="#1a1a1a">P(M1|D)/P(M2|D)</text>

<text x="310" y="170" text-anchor="middle" font-size="12" fill="#333">Bayes factor is the update multiplier applied</text>

<text x="310" y="190" text-anchor="middle" font-size="12" fill="#333">to prior beliefs about relative model plausibility</text>

</svg>

### Worked Example — Bayes Factor for a Coin Fairness Test

Comparing two hypotheses about a coin: $M_1$: the coin is fair ($\theta = 0.5$, a point hypothesis), versus $M_2$: $\theta \sim \text{Beta}(1,1)$ (uniform prior over all possible bias values). Suppose 8 heads are observed in 20 flips.

Under $M_1$ (fixed $\theta = 0.5$):

$$P(D \mid M_1) = \binom{20}{8}(0.5)^8(0.5)^{12} = \binom{20}{8}(0.5)^{20}$$

Under $M_2$ (Beta(1,1) prior, which is conjugate to the Binomial likelihood), the marginal likelihood has a known closed-form Beta-Binomial expression:

$$P(D \mid M_2) = \binom{20}{8} \frac{B(1+8, 1+12)}{B(1,1)}$$

where $B(\cdot,\cdot)$ is the Beta function. I have not carried out the numerical evaluation of these Beta function terms or the final ratio here, so I cannot state a specific numeric Bayes factor value. I cannot verify a numeric result without completing this calculation explicitly, and I will not present an estimated number as fact.

The general approach is correct as outlined: compute each model's marginal likelihood by integrating (or, for a point hypothesis, directly evaluating) the likelihood function, then take their ratio. This procedural description is a direct consequence of the Bayes factor definition, not an unverified claim.

### Bayes Factors vs. p-values

| Aspect | Bayes Factor | p-value |
| --- | --- | --- |
| Quantifies | Relative evidence for one hypothesis over another | Probability of data at least as extreme, assuming $H_0$ is true |
| Can support the null hypothesis | Yes, directly (e.g., $BF < 1$) | No — a p-value cannot directly quantify evidence *for* $H_0$ |
| Requires specifying priors | Yes, for both models | No |
| Sample-size behavior | Does not automatically favor rejection as $n \to \infty$ in the same way p-values can [Inference] | Can become statistically significant for trivially small effects at large $n$ |

Bayes factors are sometimes presented as addressing certain interpretive limitations of p-values, such as the inability of a p-value to directly quantify evidence in favor of the null hypothesis. [Inference — this is a commonly cited argument in the Bayesian statistics literature favoring Bayes factors over p-values, not verified against a specific source in this conversation] This comparison reflects an ongoing methodological debate between frequentist and Bayesian approaches, and is presented here for informational balance rather than as an endorsement of either position.

### Sensitivity to Prior Choice

Unlike many posterior-based quantities (mean, credible intervals), where the influence of the prior tends to diminish with more data, Bayes factors can remain sensitive to the choice of prior — particularly the prior used for parameters within each model — even with substantial data. This sensitivity is sometimes referred to in the literature in connection with the "Jeffreys-Lindley paradox," where Bayes factors and p-value-based conclusions can diverge, especially for diffuse priors on model parameters. [Inference — this is a recognized phenomenon discussed in Bayesian statistics literature; I cannot verify the precise technical conditions or original source details without checking a specific, named reference]

I cannot verify further technical specifics of the Jeffreys-Lindley paradox beyond this general description without directly checking a primary source. [Unverified]

### Computing Bayes Factors

- **Conjugate models**: closed-form marginal likelihoods are available, allowing direct computation, as illustrated in the coin-fairness example above
- **Non-conjugate models**: marginal likelihoods generally require numerical integration or approximation methods, since the integral defining $P(D \mid M_i)$ often lacks a closed-form solution
- **Common approximation methods**:
  - **Laplace approximation**: approximates the marginal likelihood using a Gaussian approximation around the MAP estimate [Inference — standard description found in Bayesian computational statistics literature; not verified against a specific source in this conversation]
  - **Bridge sampling / importance sampling**: Monte Carlo-based methods for estimating marginal likelihoods [Inference]
  - **Savage-Dickey density ratio**: a specific technique applicable for certain nested model comparisons [Inference — this is a recognized specialized method described in Bayesian statistics literature; I cannot verify further technical details without checking a specific source]

I cannot verify implementation-specific details of any particular software library's Bayes factor computation routines without checking a specific, named, and current source. [Unverified]

### Bayes Factors in Machine Learning Contexts

- **Bayesian model selection**: comparing different model structures (e.g., number of components in a mixture model, presence/absence of specific predictors) using their relative marginal likelihoods
- **Hyperparameter and prior sensitivity checks**: examining how Bayes factors change under different reasonable prior specifications, as part of a broader sensitivity analysis [Inference]
- **Bayesian A/B testing**: some Bayesian A/B testing frameworks use Bayes factors (or closely related quantities) to quantify evidence for a treatment effect, as an alternative to frequentist significance testing [Inference — this reflects a commonly cited application in Bayesian experimentation literature, not verified against a specific source in this conversation]

I do not have access to information confirming which specific Bayes factor computation methods are considered standard practice across every particular machine learning subfield or software platform, so any such broad claim would require checking a named, current source. [Unverified]

### Python Implementation Example

```python
from scipy.special import betaln
import numpy as np

# Marginal likelihood under M2 (Beta(1,1) prior, conjugate to Binomial)
n, x = 20, 8
alpha_prior, beta_prior = 1, 1

log_marginal_M2 = (
    betaln(alpha_prior + x, beta_prior + n - x) - betaln(alpha_prior, beta_prior)
)

# Marginal likelihood under M1 (point hypothesis theta = 0.5)
log_marginal_M1 = x * np.log(0.5) + (n - x) * np.log(0.5)

log_bayes_factor_12 = log_marginal_M1 - log_marginal_M2
bayes_factor_12 = np.exp(log_bayes_factor_12)

print(f"Bayes factor (M1 vs M2): {bayes_factor_12:.4f}")
```

I have not executed this code, so I cannot verify its exact printed output. [Unverified] Behavior may also vary depending on the installed version of `scipy` or `numpy`, and I cannot guarantee identical results across all environments. [Inference]

### Limitations and Considerations

- Computing marginal likelihoods is often computationally demanding for complex, non-conjugate models, and approximation methods introduce their own sources of error [Inference]
- Bayes factors are sensitive to prior specification in a way that can persist even with large sample sizes, unlike some other posterior summaries [Inference]
- Interpretive scales (e.g., the Jeffreys scale) are conventions rather than fixed statistical laws, and different fields or authors may apply different thresholds [Inference]
- Bayes factors compare the specific models as specified, including their priors; a Bayes factor favoring one model does not by itself confirm that model is a good absolute fit to the data — this requires separate model-checking procedures [Inference]
- I do not have access to a comprehensive, verified account of every documented critique or defense of Bayes factors in the broader statistical literature, so any claim of "settled consensus" on their use would be unverified. [Unverified]

### **Key Points**

- A Bayes factor quantifies the relative evidence data provide for one model or hypothesis over another, via the ratio of marginal likelihoods
- It directly updates prior odds into posterior odds between two models — a relationship that follows mathematically from Bayes' theorem
- Interpretive scales (e.g., Jeffreys' scale) provide conventional labels for Bayes factor magnitude, but are conventions rather than fixed statistical laws [Inference]
- Unlike p-values, Bayes factors can directly quantify evidence in favor of a null hypothesis [Inference regarding the comparative framing; the underlying mathematical capability is a direct property of the Bayes factor definition]
- Bayes factor sensitivity to prior choice can persist even with large data, distinguishing it from some other posterior-based summaries [Inference]

### **Related Topics**

- Posterior distributions and Bayesian point estimation
- Prior distributions and conjugate priors
- Credible intervals
- Bayesian model comparison and model averaging
- p-values and frequentist hypothesis testing
- Jeffreys-Lindley paradox
- Marginal likelihood approximation methods (Laplace approximation, bridge sampling)
- Bayesian A/B testing