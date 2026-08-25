## Posterior Distributions

### Definition

The posterior distribution represents the updated probability distribution over a parameter (or hypothesis) after observing data, combining prior beliefs with observed evidence via Bayes' theorem.

$$P(\theta \mid D) = \frac{P(D \mid \theta) \, P(\theta)}{P(D)}$$

Where:
- $P(\theta \mid D)$ — posterior distribution (belief about $\theta$ after seeing data $D$)
- $P(D \mid \theta)$ — likelihood (probability of data given parameter)
- $P(\theta)$ — prior distribution (belief before seeing data)
- $P(D)$ — marginal likelihood or evidence (normalizing constant)

### Conceptual Role in Machine Learning

The posterior distribution is central to Bayesian machine learning because it quantifies uncertainty about model parameters rather than producing a single point estimate. This contrasts with frequentist approaches that typically yield one "best" parameter value.

Practical implications include:
- Uncertainty quantification alongside predictions
- Natural regularization through the prior
- Sequential updating as new data arrives

[Inference] Models that maintain full posterior distributions tend to provide better-calibrated uncertainty estimates than point-estimate methods, though this depends on model specification and approximation quality.

### The Normalizing Constant

The marginal likelihood $P(D)$ is computed as:

$$P(D) = \int P(D \mid \theta) \, P(\theta) \, d\theta$$

This integral is often intractable in closed form for complex models, which is a major motivation for approximate inference methods (discussed in later topics such as MCMC and Variational Inference).

Because $P(D)$ does not depend on $\theta$, it is common to work with the unnormalized posterior:

$$P(\theta \mid D) \propto P(D \mid \theta) \, P(\theta)$$

### Conjugate Priors and Closed-Form Posteriors

When the prior and likelihood belong to conjugate distribution families, the posterior has the same functional form as the prior, allowing closed-form computation without needing to evaluate the intractable integral.

**Example**

Beta-Binomial conjugacy:

- Prior: $\theta \sim \text{Beta}(\alpha, \beta)$
- Likelihood: $D \sim \text{Binomial}(n, \theta)$, with $k$ observed successes
- Posterior: $\theta \mid D \sim \text{Beta}(\alpha + k, \beta + n - k)$

This is commonly used in modeling click-through rates, coin-flip experiments, or any binary outcome scenario.

Common conjugate pairs:

| Likelihood | Prior | Posterior |
|---|---|---|
| Binomial | Beta | Beta |
| Poisson | Gamma | Gamma |
| Normal (known variance) | Normal | Normal |
| Multinomial | Dirichlet | Dirichlet |

### Sequential Updating

A key property of Bayesian posteriors is that they can be updated incrementally as new data arrives. The posterior from one round of data becomes the prior for the next.

$$P(\theta \mid D_1, D_2) \propto P(D_2 \mid \theta) \, P(\theta \mid D_1)$$

This property makes Bayesian inference naturally suited to online learning and streaming data settings.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Sequential Posterior Updating (svg_diagram)</text>

  <rect x="30" y="60" width="140" height="60" rx="6" fill="#e8eef7" stroke="#3a5a8c" stroke-width="1.5" />
  <text x="100" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Prior</text>
  <text x="100" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">P(θ)</text>

  <line x1="170" y1="90" x2="230" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="200" y="78" font-size="11" text-anchor="middle" fill="#555">+ Data D₁</text>

  <rect x="230" y="60" width="140" height="60" rx="6" fill="#e8f7ee" stroke="#2f7a4f" stroke-width="1.5" />
  <text x="300" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Posterior 1</text>
  <text x="300" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">P(θ|D₁)</text>

  <line x1="370" y1="90" x2="430" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="400" y="78" font-size="11" text-anchor="middle" fill="#555">+ Data D₂</text>

  <rect x="430" y="60" width="140" height="60" rx="6" fill="#f7f0e8" stroke="#a3701e" stroke-width="1.5" />
  <text x="500" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Posterior 2</text>
  <text x="500" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">P(θ|D₁,D₂)</text>

  <line x1="570" y1="90" x2="620" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="595" y="78" font-size="11" text-anchor="middle" fill="#555">...</text>

  <text x="350" y="160" font-size="12" text-anchor="middle" fill="#444">Each posterior becomes the prior for the next round of data</text>

  <line x1="60" y1="200" x2="640" y2="200" stroke="#ccc" stroke-width="1" />
  <path d="M 80 260 Q 150 190 220 250 Q 300 300 380 220 Q 450 170 520 240 Q 580 280 620 210" fill="none" stroke="#3a5a8c" stroke-width="2" />
  <text x="350" y="300" font-size="11" text-anchor="middle" fill="#555">Posterior sharpens (lower variance) as more data accumulates — illustrative only</text>

  </svg>

[Inference] The illustration above shows a general trend of variance reduction with additional data; actual posterior shape evolution depends on the specific model, prior, and data characteristics.

### When Closed-Form Solutions Are Unavailable

For most realistic ML models (e.g., neural networks, complex hierarchical models), the posterior lacks a closed-form solution because:
- The likelihood is not conjugate to any tractable prior
- The parameter space is high-dimensional
- The integral defining $P(D)$ cannot be solved analytically

In these cases, approximate methods are required:
- **Markov Chain Monte Carlo (MCMC)** — sampling-based approximation
- **Variational Inference** — optimization-based approximation
- **Laplace Approximation** — Gaussian approximation around the posterior mode

[Unverified] Specific claims about which method performs best are highly model- and data-dependent; no single method is universally superior across all use cases.

### Point Estimates Derived from the Posterior

Although the full posterior is the richest representation, point summaries are often extracted for practical use:

- **Maximum A Posteriori (MAP)**: $\hat{\theta}_{MAP} = \arg\max_\theta P(\theta \mid D)$
- **Posterior Mean**: $E[\theta \mid D] = \int \theta \, P(\theta \mid D) \, d\theta$
- **Posterior Median**: the value splitting the posterior mass in half

MAP estimation is related to regularized maximum likelihood estimation — for example, a Gaussian prior on weights corresponds to L2 regularization in this framing. [Inference] This equivalence holds under specific mathematical conditions and may not generalize to all prior/regularization pairings without verification.

### Credible Intervals

A Bayesian credible interval is a range within which the parameter lies with a specified posterior probability.

$$P(\theta_{low} \le \theta \le \theta_{high} \mid D) = 0.95$$

This differs conceptually from a frequentist confidence interval, which does not assign a probability to the parameter itself but instead describes long-run coverage properties of the interval-generating procedure.

### Worked Example

**Example**

Suppose we are estimating the probability $\theta$ that a user clicks an ad.

- Prior belief: $\theta \sim \text{Beta}(2, 2)$ (mild belief centered around 0.5)
- Observed data: 7 clicks out of 10 impressions

Posterior update:

$$\theta \mid D \sim \text{Beta}(2 + 7,\ 2 + 3) = \text{Beta}(9, 5)$$

**Output**

- Posterior mean: $\frac{9}{9+5} \approx 0.643$
- This reflects a shift from the prior's 0.5 toward the observed click rate of 0.7, moderated by the prior's influence.

### Common Pitfalls

- Treating the posterior as fully solved when only an approximation was computed
- Ignoring the influence of a poorly chosen prior on small datasets
- Confusing credible intervals with confidence intervals
- Assuming convergence of sampling-based approximations (e.g., MCMC) without diagnostic checks

[Inference] Diagnostic checks such as trace plots or convergence statistics are generally recommended practice for sampling-based posterior approximation, though specific diagnostic requirements vary by method and implementation.

### Related Topics

- Prior distributions and prior selection strategies
- Markov Chain Monte Carlo (MCMC) methods
- Variational Inference
- Conjugate priors in exponential family distributions
- Maximum A Posteriori (MAP) estimation vs. Maximum Likelihood Estimation (MLE)
- Credible intervals vs. confidence intervals
- Bayesian model comparison and marginal likelihood
- Hierarchical Bayesian models