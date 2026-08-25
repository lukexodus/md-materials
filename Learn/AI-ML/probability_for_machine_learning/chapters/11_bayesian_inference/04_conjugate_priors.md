## Conjugate Priors

### Definition

A conjugate prior is a prior distribution that, when combined with a specific likelihood function via Bayes' theorem, produces a posterior distribution belonging to the same family as the prior.

$$P(\theta \mid D) \propto P(D \mid \theta) \, P(\theta)$$

If $P(\theta)$ and $P(\theta \mid D)$ share the same distributional family, the prior is said to be conjugate to the likelihood $P(D \mid \theta)$.

### Why Conjugacy Matters

Conjugate priors allow the posterior to be computed in closed form, avoiding the need to solve the marginal likelihood integral:

$$P(D) = \int P(D \mid \theta) \, P(\theta) \, d\theta$$

Practical benefits include:
- Analytical, exact posterior updates
- Computational efficiency, especially in sequential/online settings
- Simplified derivation of point estimates and credible intervals

[Inference] Conjugate priors are commonly favored in textbook treatments of Bayesian inference because they simplify derivations for teaching purposes. This is a reasoned inference based on common pedagogical patterns, not a confirmed statement about all sources.

### Mathematical Structure

Conjugacy is tied to the concept of exponential family distributions. Likelihoods from the exponential family generally admit conjugate priors within the same family. [Inference] This relationship follows from the algebraic structure of exponential family sufficient statistics, though not every exponential family likelihood has a commonly used named conjugate prior.

The exponential family form:

$$P(x \mid \theta) = h(x) \exp\left( \eta(\theta)^T T(x) - A(\theta) \right)$$

Where $T(x)$ is the sufficient statistic, $\eta(\theta)$ is the natural parameter, and $A(\theta)$ is the log-partition function.

### Common Conjugate Pairs

| Likelihood | Conjugate Prior | Posterior |
|---|---|---|
| Bernoulli / Binomial | Beta | Beta |
| Poisson | Gamma | Gamma |
| Normal (known variance, unknown mean) | Normal | Normal |
| Normal (known mean, unknown variance) | Inverse-Gamma | Inverse-Gamma |
| Multinomial | Dirichlet | Dirichlet |
| Exponential | Gamma | Gamma |
| Geometric | Beta | Beta |

This table reflects standard, widely documented results in Bayesian statistics. [Unverified] I cannot verify this table against a specific external source in this conversation, though the pairings listed are standard and appear consistently across common Bayesian statistics references.

### Worked Example: Beta-Bernoulli

**Example**

Modeling the probability $\theta$ of a binary event (e.g., email spam classification).

- Prior: $\theta \sim \text{Beta}(\alpha, \beta)$
- Likelihood (single observation): $x \sim \text{Bernoulli}(\theta)$
- After observing $x = 1$ (event occurred):

$$P(\theta \mid x=1) \propto \theta^{\alpha} (1-\theta)^{\beta - 1}$$

$$\theta \mid x=1 \sim \text{Beta}(\alpha + 1, \beta)$$

After observing $k$ successes and $n-k$ failures across $n$ trials:

$$\theta \mid D \sim \text{Beta}(\alpha + k, \ \beta + n - k)$$

**Output**

The Beta distribution's parameters $\alpha$ and $\beta$ can be interpreted as "pseudo-counts" of prior successes and failures, which combine additively with observed counts.

### Worked Example: Normal-Normal

**Example**

Estimating an unknown mean $\mu$ with known variance $\sigma^2$.

- Prior: $\mu \sim \mathcal{N}(\mu_0, \tau_0^2)$
- Likelihood: $x_i \sim \mathcal{N}(\mu, \sigma^2)$ for $n$ observations

Posterior:

$$\mu \mid D \sim \mathcal{N}\left( \frac{\frac{\mu_0}{\tau_0^2} + \frac{n\bar{x}}{\sigma^2}}{\frac{1}{\tau_0^2} + \frac{n}{\sigma^2}}, \ \left( \frac{1}{\tau_0^2} + \frac{n}{\sigma^2} \right)^{-1} \right)$$

**Output**

The posterior mean is a precision-weighted average of the prior mean and the sample mean, where precision is defined as $1/\text{variance}$. As $n$ increases, the sample data dominates the prior's influence.

### Visualizing Conjugate Updating

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Beta-Bernoulli Conjugate Updating (svg_diagram)</text>

  <line x1="60" y1="280" x2="640" y2="280" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="350" y="310" font-size="12" text-anchor="middle" fill="#333">θ (probability of success)</text>
  <text x="30" y="170" font-size="12" text-anchor="middle" fill="#333" transform="rotate(-90 30 170)">Density</text>

  <path d="M 60 260 Q 350 260 640 260" fill="none" stroke="#999" stroke-width="2" stroke-dasharray="4,3" />
  <text x="150" y="245" font-size="11" fill="#777">Prior: Beta(2,2) — flat, centered at 0.5</text>

  <path d="M 60 280 Q 250 280 350 90 Q 450 280 640 280" fill="none" stroke="#2f7a4f" stroke-width="2.5" />
  <text x="420" y="110" font-size="11" fill="#2f7a4f">Posterior: Beta(9,5) — peak shifted right, narrower</text>

  <line x1="350" y1="280" x2="350" y2="290" stroke="#666" stroke-width="1" />
  <text x="350" y="303" font-size="10" fill="#666" text-anchor="middle">0.5</text>

  <text x="350" y="55" font-size="11" text-anchor="middle" fill="#555">Illustrative shapes only — not drawn to exact scale</text>
</svg>

[Unverified] The curve shapes in this diagram are illustrative approximations for conceptual purposes, not precise plots derived from computed density values.

### Conjugacy in Sequential Learning

Conjugate priors are particularly useful in online/streaming settings because the posterior after one batch of data becomes the prior for the next, without changing the distributional family:

```mermaid
flowchart LR
    A[Prior: Beta alpha0 beta0] -->|Observe batch 1| B[Posterior 1: Beta alpha1 beta1]
    B -->|Becomes new prior| C[Prior: Beta alpha1 beta1]
    C -->|Observe batch 2| D[Posterior 2: Beta alpha2 beta2]
    D -->|Becomes new prior| E[Continues...]
```

[Inference] This sequential property is a mathematical consequence of conjugacy and is a reasoned conclusion from the closed-form update rules shown above, not a claim requiring separate empirical verification.

### Limitations of Conjugate Priors

- Restricts prior choice to a specific parametric family, which may not reflect true prior beliefs
- Not all likelihoods have a known, named conjugate prior
- Complex models (e.g., deep neural networks) generally lack tractable conjugate structures, requiring approximate inference methods instead

[Unverified] I do not have access to a comprehensive, verified list of every likelihood function that lacks any conjugate prior; this is a general statistical limitation acknowledged in standard treatments of the topic, not a specific verified claim about any one likelihood.

### Conjugate Priors vs. Non-Conjugate Approaches

| Aspect | Conjugate Prior | Non-Conjugate / General Prior |
|---|---|---|
| Posterior form | Closed-form | Often intractable |
| Computation | Analytical | Requires MCMC, Variational Inference, etc. |
| Flexibility | Limited to specific families | Can represent arbitrary beliefs |
| Common use case | Simple models (Beta-Binomial, Normal-Normal) | Complex hierarchical or deep models |

### Common Pitfalls

- Selecting a conjugate prior for mathematical convenience rather than because it reflects genuine prior belief
- Assuming conjugacy exists for a given likelihood without verification
- Over-relying on pseudo-count interpretations without checking whether they align with the actual problem context

[Inference] These pitfalls are reasoned from general principles of Bayesian modeling practice described in standard statistical literature; I cannot verify how frequently each specific pitfall occurs in real-world applied settings.

### Related Topics

- Exponential family distributions
- Posterior distributions and Bayesian updating
- Beta, Gamma, and Dirichlet distributions in depth
- Markov Chain Monte Carlo (MCMC) methods for non-conjugate models
- Variational Inference
- Hierarchical Bayesian models
- Bayesian linear regression (Normal-Normal conjugacy application)