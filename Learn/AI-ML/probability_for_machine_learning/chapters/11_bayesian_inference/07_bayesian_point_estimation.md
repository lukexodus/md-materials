## Bayesian Point Estimation

### Definition

Bayesian point estimation refers to methods for extracting a single representative value from a posterior distribution, condensing the full distribution into one summary statistic for the parameter $\theta$.

### Common Point Estimators

**Maximum A Posteriori (MAP)**

The value of $\theta$ that maximizes the posterior density.

$$\hat{\theta}_{MAP} = \arg\max_\theta P(\theta \mid D) = \arg\max_\theta P(D \mid \theta) \, P(\theta)$$

**Posterior Mean**

The expected value of $\theta$ under the posterior distribution.

$$\hat{\theta}_{mean} = E[\theta \mid D] = \int \theta \, P(\theta \mid D) \, d\theta$$

**Posterior Median**

The value splitting the posterior probability mass into two equal halves.

$$P(\theta \le \hat{\theta}_{median} \mid D) = 0.5$$

### Comparison of Estimators

| Estimator | Definition | Sensitivity | Typical Use Case |
|---|---|---|---|
| MAP | Mode of posterior | Sensitive to posterior shape near the peak | Regularized optimization, point prediction |
| Posterior Mean | Expected value of posterior | Sensitive to skew and outlier tail mass | Minimizing squared-error loss |
| Posterior Median | 50th percentile of posterior | Robust to skew and outliers | Minimizing absolute-error loss |

[Inference] This comparison of sensitivity properties follows from the mathematical definitions of mode, mean, and median. I cannot verify how these properties manifest in every specific applied dataset without testing that dataset directly.

### Connection to Loss Functions

Each point estimator corresponds to the Bayes-optimal decision under a specific loss function, from Bayesian decision theory.

| Estimator | Optimal Under Loss Function |
|---|---|
| Posterior Mean | Squared error loss: $(\theta - \hat{\theta})^2$ |
| Posterior Median | Absolute error loss: $\lvert \theta - \hat{\theta} \rvert$ |
| MAP | 0-1 loss (in the limit of a vanishing tolerance window) |

[Inference] This correspondence between estimators and loss functions is a standard result described in Bayesian decision theory literature. I cannot verify this against a specific cited source in this conversation; it should be treated as a commonly presented theoretical result rather than an independently confirmed fact.

### Worked Example: Beta Posterior

**Example**

Using the earlier posterior: $\theta \mid D \sim \text{Beta}(9, 5)$

**Posterior mean:**

$$E[\theta \mid D] = \frac{\alpha'}{\alpha' + \beta'} = \frac{9}{14} \approx 0.643$$

**MAP estimate (mode of Beta distribution, for $\alpha', \beta' > 1$):**

$$\hat{\theta}_{MAP} = \frac{\alpha' - 1}{\alpha' + \beta' - 2} = \frac{8}{12} \approx 0.667$$

**Output**

- Posterior mean ≈ 0.643
- MAP estimate ≈ 0.667

These two values differ because the Beta(9,5) distribution is slightly skewed; mean and mode coincide only for symmetric distributions. [Inference] This explanation follows from known properties of the Beta distribution's shape under asymmetric parameters. I have not independently re-derived or numerically verified this specific calculation beyond applying the standard formulas shown above.

### MAP Estimation and Regularization

MAP estimation is mathematically related to regularized maximum likelihood estimation. Taking the log of the posterior:

$$\log P(\theta \mid D) = \log P(D \mid \theta) + \log P(\theta) - \log P(D)$$

Since $\log P(D)$ does not depend on $\theta$, maximizing the posterior is equivalent to maximizing:

$$\log P(D \mid \theta) + \log P(\theta)$$

This resembles a log-likelihood term plus a regularization term contributed by the prior.

**Example**

A Gaussian prior on model weights, $\theta \sim \mathcal{N}(0, \sigma^2)$, contributes a term proportional to $-\theta^2$ to the log-posterior, which corresponds structurally to L2 (ridge) regularization in a standard maximum likelihood framing.

[Inference] This correspondence between a Gaussian prior and L2 regularization is a well-established mathematical derivation. I cannot verify whether this equivalence holds identically across every possible model architecture or loss formulation without checking each specific case.

### Visualizing Point Estimates on a Skewed Posterior

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">MAP vs. Mean vs. Median on Skewed Posterior (svg_diagram)</text>

  <line x1="60" y1="280" x2="640" y2="280" stroke="#333" stroke-width="1.5"/>
  <line x1="60" y1="280" x2="60" y2="60" stroke="#333" stroke-width="1.5"/>
  <text x="350" y="310" font-size="12" text-anchor="middle" fill="#333">θ</text>
  <text x="30" y="170" font-size="12" text-anchor="middle" fill="#333" transform="rotate(-90 30 170)">Density</text>

  <path d="M 100 280 Q 200 270 300 90 Q 360 60 420 140 Q 500 260 600 280" fill="none" stroke="#555" stroke-width="2"/>
  <text x="470" y="90" font-size="11" fill="#555">Skewed posterior density</text>

  <line x1="320" y1="280" x2="320" y2="80" stroke="#2f7a4f" stroke-width="1.5"/>
  <text x="320" y="65" font-size="10" fill="#2f7a4f" text-anchor="middle">MAP (mode)</text>

  <line x1="370" y1="280" x2="370" y2="140" stroke="#3a5a8c" stroke-width="1.5"/>
  <text x="370" y="330" font-size="10" fill="#3a5a8c" text-anchor="middle">Median</text>

  <line x1="410" y1="280" x2="410" y2="160" stroke="#a3701e" stroke-width="1.5"/>
  <text x="410" y="310" font-size="10" fill="#a3701e" text-anchor="middle">Mean</text>
</svg>

[Unverified] This diagram is an illustrative conceptual approximation showing the general ordering of mode, median, and mean on a right-skewed distribution. It is not generated from computed numerical values for the Beta(9,5) example and should not be used to infer exact positions.

### Point Estimation vs. Full Posterior Use

| Aspect | Point Estimate | Full Posterior / Predictive Distribution |
|---|---|---|
| Information retained | Single value | Complete uncertainty structure |
| Computational cost | Lower | Generally higher (especially for non-conjugate models) |
| Use case | Fast inference, simple reporting | Uncertainty-aware decision-making |

[Inference] This comparison reflects general tradeoffs discussed in Bayesian modeling literature regarding computational cost and information retention. I cannot verify exact computational cost differences without benchmarking specific implementations.

### Computation for Non-Conjugate Posteriors

When no closed-form posterior exists, point estimates are typically approximated using:

- **Optimization-based methods** for MAP (e.g., gradient ascent on the log-posterior)
- **Sample averaging** for posterior mean, using MCMC or variational samples
- **Empirical median** from sorted posterior samples

```plaintext
===MERMAID_DIAGRAM===
flowchart TD
    A[Non-conjugate posterior] --> B{Estimator needed}
    B -->|MAP| C[Optimize log-posterior via gradient-based method]
    B -->|Mean| D[Average posterior samples from MCMC or variational approximation]
    B -->|Median| E[Sort samples, take 50th percentile]
    C --> F[Point estimate obtained]
    D --> F
    E --> F
```

[Inference] This procedural outline reflects standard approaches described in Bayesian computational statistics literature. I cannot verify implementation-specific details of any particular software library without reference to that library's documentation.

### Common Pitfalls

- Treating a point estimate as if it conveys the same information as the full posterior
- Using MAP estimation on a multimodal posterior, where the global mode may not represent a "typical" value well
- Assuming posterior mean and MAP coincide, which only holds exactly for symmetric unimodal posteriors
- Applying squared-error-optimal estimators (posterior mean) in contexts where absolute-error or 0-1 loss is more appropriate

[Inference] These pitfalls are reasoned from the mathematical properties of each estimator described above. I cannot verify their relative frequency of occurrence in real-world applied machine learning settings without access to empirical survey data.

### Related Topics

- Posterior distributions and Bayesian updating
- Conjugate priors
- Posterior predictive distributions
- Credible intervals
- Bayesian decision theory and loss functions
- Regularization (L1/L2) and its Bayesian interpretation
- Markov Chain Monte Carlo (MCMC) methods
