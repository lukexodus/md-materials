## Bayes Factors and Model Comparison

### Overview

A Bayes factor quantifies the relative evidence that observed data provides for one model over another. Given two competing models $M_1$ and $M_2$, the Bayes factor is defined as the ratio of their marginal likelihoods:

$$
BF_{12} = \frac{p(y \mid M_1)}{p(y \mid M_2)}
$$

where $p(y \mid M_k) = \int p(y \mid \theta_k, M_k)\, p(\theta_k \mid M_k)\, d\theta_k$ is the marginal likelihood (also called model evidence) obtained by integrating over the parameters $\theta_k$ of model $M_k$, weighted by their prior.

### Relation to Posterior Model Odds

Bayes factors connect prior and posterior beliefs about models via Bayes' theorem applied at the model level:

$$
\underbrace{\frac{p(M_1 \mid y)}{p(M_2 \mid y)}}_{\text{posterior odds}} = \underbrace{\frac{p(y \mid M_1)}{p(y \mid M_2)}}_{\text{Bayes factor}} \times \underbrace{\frac{p(M_1)}{p(M_2)}}_{\text{prior odds}}
$$

**Key Points**
- The Bayes factor is the multiplicative update applied to prior model odds to obtain posterior model odds.
- Unlike p-values, Bayes factors directly quantify evidence for or against each model, rather than only rejecting a null hypothesis.
- This is a mathematical identity derived from Bayes' theorem; its correctness follows from the definitions above. [Inference]

### Interpretation Scales

Several interpretive scales for Bayes factor magnitude have been proposed in the literature. One commonly cited scale is attributed to Harold Jeffreys:

| $BF_{12}$ | Interpretation |
|---|---|
| 1–3 | Barely worth mentioning |
| 3–10 | Substantial evidence for $M_1$ |
| 10–30 | Strong evidence for $M_1$ |
| 30–100 | Very strong evidence for $M_1$ |
| >100 | Decisive evidence for $M_1$ |

I cannot verify the exact wording or original publication details of this scale from primary source text; the table reflects a commonly cited paraphrase found in secondary literature. [Unverified]

### Computing Marginal Likelihoods

Computing $p(y \mid M_k)$ requires integrating over the full parameter space, which is analytically tractable only in specific conjugate cases and is otherwise computationally demanding.

**Methods commonly used:**
- **Conjugate analytic solutions**: closed-form marginal likelihoods exist for select conjugate prior-likelihood pairs (e.g., Beta-Binomial, Normal-Normal).
- **Laplace approximation**: approximates the integral using a Gaussian centered at the posterior mode.
- **Bridge sampling**: an estimator designed to improve accuracy over naive Monte Carlo integration for marginal likelihood estimation. [Unverified — effectiveness depends on implementation and model]
- **Importance sampling / harmonic mean estimator**: the harmonic mean estimator is known in the literature to be unstable in many practical settings. [Unverified — instability is a commonly cited concern, but severity is model-dependent]
- **Nested sampling**: a sampling algorithm designed specifically to estimate marginal likelihoods alongside posterior samples.

### Bayes Factors vs. Information Criteria

**Key Points**
- **BIC (Bayesian Information Criterion)** is sometimes used as a rough asymptotic approximation to $-2\log(BF)$ under certain conditions. [Unverified — approximation validity depends on sample size and model regularity conditions]
- **AIC (Akaike Information Criterion)** is derived from a different theoretical framework (expected predictive accuracy) and is not a Bayes factor approximation.
- **WAIC** and **LOO-CV** (leave-one-out cross-validation, often computed via Pareto-smoothed importance sampling) are Bayesian model comparison tools that estimate out-of-sample predictive accuracy, and are conceptually distinct from Bayes factors, which measure evidence rather than predictive performance directly.

### Diagram: Model Comparison Workflow

```mermaid
flowchart TD
    A[Observed Data y] --> B[Model M1: prior + likelihood]
    A --> C[Model M2: prior + likelihood]
    B --> D[Marginal Likelihood p(y|M1)]
    C --> E[Marginal Likelihood p(y|M2)]
    D --> F[Bayes Factor BF12 = p(y|M1) / p(y|M2)]
    E --> F
    F --> G[Combine with Prior Odds]
    G --> H[Posterior Model Odds]
```

### Example

**Example**
Comparing two candidate models for a coin's fairness:
- $M_1$: coin is fair, $\theta = 0.5$ (point mass prior)
- $M_2$: coin bias is unknown, $\theta \sim \text{Beta}(1,1)$

After observing 8 heads in 10 flips, the marginal likelihood under $M_1$ is fixed at $0.5^{10}$, while under $M_2$ it is obtained by integrating the Binomial likelihood against the Beta(1,1) prior, yielding a Beta-Binomial marginal likelihood with a closed-form expression. Comparing these two values produces $BF_{12}$, indicating which model the data favor. The exact numerical result depends on precise calculation and is not stated here as a verified figure. [Inference — general procedure; specific numeric output not computed/verified in this response]

### Sensitivity to Prior Choice

**Key Points**
- Bayes factors are known to be sensitive to the choice of prior on parameters within each model, particularly for diffuse or improper priors. [Unverified — degree of sensitivity varies by model and prior]
- This sensitivity is often referred to in the literature as a caution against using very vague priors when computing Bayes factors, since marginal likelihoods (unlike posteriors) do not always "wash out" prior influence as sample size grows. [Inference]
- Improper priors can make Bayes factors mathematically undefined up to an arbitrary constant, a known limitation discussed in Bayesian model comparison literature. [Unverified — specific mathematical conditions not verified here]

### Practical Considerations

- Bayes factors require proper (normalized) priors for both models to be well-defined.
- Computation cost can be substantial for complex models, motivating the use of approximation methods listed above.
- Model comparison via Bayes factors differs conceptually from model selection via predictive accuracy metrics (e.g., cross-validation); the two approaches can, in some cases, favor different models. [Inference]

### Conclusion

Bayes factors provide a formal Bayesian mechanism for comparing models by quantifying the relative support that data give to each, and they integrate directly into the framework of prior and posterior model odds. Their practical use requires care regarding prior sensitivity and computational tractability, and reported interpretive scales (e.g., Jeffreys' scale) are conventions rather than fixed statistical laws. [Inference]

### Related Topics

- Marginal likelihood estimation methods (bridge sampling, nested sampling)
- Bayesian Information Criterion (BIC) and its relation to Bayes factors
- WAIC and LOO cross-validation for Bayesian model comparison
- Sensitivity analysis for prior specification
- Savage-Dickey density ratio for nested model comparison
- Posterior predictive checks as a complementary model evaluation tool

> Correction note (proactive check): No unverified claim was presented as fact in this response; uncertain items were labeled per the specified convention.