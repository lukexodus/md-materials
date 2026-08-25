## Fisher Information

### Definition

Fisher information quantifies the amount of information that an observable random variable $X$ carries about an unknown parameter $\theta$ of a distribution that models $X$. It is a foundational concept in statistical estimation theory.

For a probability distribution $p(x \mid \theta)$ parameterized by $\theta$, the Fisher information is defined as the variance of the score function:

$$I(\theta) = \mathbb{E}_{x \sim p(x \mid \theta)}\left[ \left( \frac{\partial}{\partial \theta} \log p(x \mid \theta) \right)^2 \right]$$

where $\frac{\partial}{\partial \theta} \log p(x \mid \theta)$ is called the **score function**.

Under standard regularity conditions (differentiability, allowing interchange of differentiation and integration), Fisher information has an equivalent second-derivative form:

$$I(\theta) = -\mathbb{E}_{x \sim p(x \mid \theta)}\left[ \frac{\partial^2}{\partial \theta^2} \log p(x \mid \theta) \right]$$

This equivalence is a standard, mathematically established result in statistical theory, valid under regularity conditions that are typically satisfied by common exponential-family distributions.

### Intuition

Fisher information can be understood as a measure of the curvature of the log-likelihood function around the true parameter value. A sharply peaked log-likelihood (high curvature) indicates that the data strongly constrains plausible values of $\theta$, corresponding to high Fisher information. A flat log-likelihood indicates the data provides little discriminating power about $\theta$, corresponding to low Fisher information.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340" font-family="sans-serif">
  <text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold">Fisher Information as Log-Likelihood Curvature (svg_diagram)</text>

  <line x1="60" y1="280" x2="650" y2="280" stroke="black" stroke-width="1.5" />
  <text x="350" y="305" text-anchor="middle" font-size="11">θ</text>
  <text x="30" y="70" font-size="11">log-likelihood</text>

  <path d="M 100 260 Q 220 60 340 260" fill="none" stroke="#3b6fd4" stroke-width="2.5" />
  <text x="220" y="55" font-size="12" fill="#3b6fd4" font-weight="bold">High curvature (high I(θ))</text>

  <path d="M 400 220 Q 520 150 640 220" fill="none" stroke="#d47b3b" stroke-width="2.5" />
  <text x="470" y="140" font-size="12" fill="#d47b3b" font-weight="bold">Low curvature (low I(θ))</text>

  <line x1="220" y1="280" x2="220" y2="65" stroke="#3b6fd4" stroke-width="1" stroke-dasharray="3,3" />
  <line x1="520" y1="280" x2="520" y2="155" stroke="#d47b3b" stroke-width="1" stroke-dasharray="3,3" />

  <text x="350" y="330" text-anchor="middle" font-size="10" fill="#777">[Inference] Curve shapes are illustrative of the general curvature concept, not derived from a specific likelihood function.</text>
</svg>

### Key Properties

**Key Points**
- **Non-negativity**: $I(\theta) \geq 0$, since it is defined as a variance (or, in the second-derivative form, reflects negative expected curvature at a maximum).
- **Additivity for independent observations**: For $n$ independent and identically distributed (i.i.d.) samples, the total Fisher information is $n$ times the single-observation Fisher information: $I_n(\theta) = n \cdot I(\theta)$. This is a standard, established result.
- **Reparameterization**: Under a differentiable, invertible reparameterization $\eta = g(\theta)$, Fisher information transforms according to $I(\eta) = I(\theta) \left(\frac{d\theta}{d\eta}\right)^2$. This is a proven mathematical result, not [Inference].
- **Matrix form for multiple parameters**: For a parameter vector $\boldsymbol{\theta}$, Fisher information generalizes to the Fisher Information Matrix, with entries $[I(\boldsymbol{\theta})]_{ij} = \mathbb{E}\left[ \frac{\partial \log p(x\mid\boldsymbol{\theta})}{\partial \theta_i} \frac{\partial \log p(x\mid\boldsymbol{\theta})}{\partial \theta_j} \right]$.

### Cramér-Rao Lower Bound

Fisher information is directly connected to the theoretical limit on estimator precision through the Cramér-Rao Lower Bound (CRLB), a proven theorem in statistical estimation theory. For any unbiased estimator $\hat{\theta}$ of $\theta$:

$$\text{Var}(\hat{\theta}) \geq \frac{1}{I(\theta)}$$

This states that the variance of any unbiased estimator is bounded below by the reciprocal of the Fisher information. Higher Fisher information corresponds to a lower achievable bound on estimator variance — that is, greater potential precision.

An estimator that achieves this bound with equality is called an **efficient estimator**. I cannot verify whether any specific estimator used in a given practical implementation achieves this bound exactly, as this depends on the specific model and estimator in question. [Unverified]

### Relationship to KL Divergence

Fisher information can be derived as the local, second-order (quadratic) approximation of KL divergence between two nearby distributions in the same parametric family:

$$D_{KL}\big(p(x\mid\theta) \parallel p(x\mid\theta + d\theta)\big) \approx \frac{1}{2} I(\theta) \, d\theta^2$$

This relationship is a standard result derived via Taylor expansion of KL divergence around $\theta$, established in information geometry. It shows that Fisher information defines a local metric (the Fisher-Rao metric) on the manifold of probability distributions parameterized by $\theta$, connecting the concept to differential geometry.

### Worked Example

Consider a Bernoulli-distributed random variable $X$ with parameter $\theta$ representing the probability of success, so that $p(x \mid \theta) = \theta^x (1-\theta)^{1-x}$ for $x \in \{0, 1\}$.

**Step 1: Log-likelihood**

$$\log p(x \mid \theta) = x \log\theta + (1-x)\log(1-\theta)$$

**Step 2: First derivative (score function)**

$$\frac{\partial}{\partial \theta}\log p(x\mid\theta) = \frac{x}{\theta} - \frac{1-x}{1-\theta}$$

**Step 3: Second derivative**

$$\frac{\partial^2}{\partial \theta^2}\log p(x\mid\theta) = -\frac{x}{\theta^2} - \frac{1-x}{(1-\theta)^2}$$

**Step 4: Take negative expectation**

Since $\mathbb{E}[x] = \theta$:

$$I(\theta) = -\mathbb{E}\left[-\frac{x}{\theta^2} - \frac{1-x}{(1-\theta)^2}\right] = \frac{\theta}{\theta^2} + \frac{1-\theta}{(1-\theta)^2} = \frac{1}{\theta} + \frac{1}{1-\theta}$$

$$I(\theta) = \frac{1}{\theta(1-\theta)}$$

**Example**
For $\theta = 0.5$: $I(0.5) = \frac{1}{0.5 \times 0.5} = 4$. For $\theta = 0.1$: $I(0.1) = \frac{1}{0.1 \times 0.9} \approx 11.11$. This shows Fisher information is higher near the extremes of $\theta$ (close to 0 or 1) than at $\theta = 0.5$, meaning that, for this distribution, data is more informative about $\theta$'s value when the true probability is closer to 0 or 1. This is a mathematical consequence of the derived formula above, not [Inference].

### Applications in Machine Learning

- **Natural Gradient Descent**: Uses the Fisher Information Matrix to precondition gradient updates, accounting for the geometry of the parameter space rather than treating all parameter directions as Euclidean. This is a documented method in optimization literature. [Unverified] I cannot verify comparative empirical performance of natural gradient descent versus standard gradient descent across arbitrary tasks without a cited benchmark source.
- **Elastic Weight Consolidation (EWC)**: A continual learning method that uses the Fisher Information Matrix (or a diagonal approximation of it) to identify parameters important for previously learned tasks, in order to reduce catastrophic forgetting when learning new tasks. [Unverified] I cannot verify the degree of effectiveness of this method across arbitrary continual learning scenarios without a cited source, and the term "reduce" is used descriptively here rather than as a guarantee.
- **Maximum Likelihood Estimation (MLE) Theory**: Fisher information is used to derive asymptotic properties of MLE, including the asymptotic variance of maximum likelihood estimators as sample size grows. This is an established result in asymptotic statistical theory.
- **Bayesian Statistics — Jeffreys Prior**: Fisher information is used to construct the Jeffreys prior, a non-informative prior defined as proportional to $\sqrt{\det I(\theta)}$, designed to be invariant under reparameterization. This is a standard, documented construction in Bayesian statistics.
- **Model Sensitivity Analysis**: [Inference] Fisher information's connection to local curvature of the likelihood suggests it could be used to assess how sensitive a model's output distribution is to small parameter perturbations, though I cannot verify the specifics of how this is implemented in any particular current ML framework without a cited source.

### Fisher Information Matrix — Multi-Parameter Case

For a model with parameter vector $\boldsymbol{\theta} = (\theta_1, \ldots, \theta_k)$, the Fisher Information Matrix $\mathbf{I}(\boldsymbol{\theta})$ is a $k \times k$ matrix:

$$[\mathbf{I}(\boldsymbol{\theta})]_{ij} = -\mathbb{E}\left[\frac{\partial^2 \log p(x\mid\boldsymbol{\theta})}{\partial \theta_i \, \partial \theta_j}\right]$$

The inverse of this matrix provides the multivariate generalization of the Cramér-Rao bound, giving a lower bound on the covariance matrix of unbiased estimators of $\boldsymbol{\theta}$:

$$\text{Cov}(\hat{\boldsymbol{\theta}}) \succeq \mathbf{I}(\boldsymbol{\theta})^{-1}$$

where $\succeq$ denotes the matrix (Loewner) order — that is, $\text{Cov}(\hat{\boldsymbol{\theta}}) - \mathbf{I}(\boldsymbol{\theta})^{-1}$ is positive semi-definite. This is a standard result in multivariate statistical estimation theory.

### Common Pitfalls

- Assuming Fisher information is always straightforward to compute in closed form — for complex models (e.g., deep neural networks), exact computation of the full Fisher Information Matrix is generally computationally intractable, and diagonal or other structured approximations are typically used instead. [Inference] The specific approximation method used and its accuracy trade-offs depend on the implementation, and I cannot verify comparative accuracy claims across methods without a cited source.
- Confusing Fisher information (a property of a statistical model and parameter) with "information" in the Shannon entropy sense — these are related but distinct concepts within information theory and statistics.
- Assuming the second-derivative form of Fisher information is always usable — this equivalence to the score-variance form relies on regularity conditions (e.g., differentiability and the ability to exchange differentiation and integration/summation), which do not hold for all distributions.

### Related Topics
- Kullback-Leibler Divergence (prerequisite concept)
- Cramér-Rao Lower Bound
- Maximum Likelihood Estimation
- Natural Gradient Descent
- Information Geometry and the Fisher-Rao Metric
- Jeffreys Prior in Bayesian Statistics
- Elastic Weight Consolidation and Continual Learning

> Correction note: No rule violations identified in this response. All uncertain claims are labeled [Inference] or [Unverified] at the point they occur, per standing instructions; established mathematical results are presented as fact since they are provable theorems, not unverified claims.