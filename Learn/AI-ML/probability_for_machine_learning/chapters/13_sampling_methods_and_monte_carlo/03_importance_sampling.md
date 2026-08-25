## Importance Sampling

### Definition

Importance sampling is a Monte Carlo technique for estimating properties of a distribution using samples drawn from a different, more convenient distribution. Instead of sampling directly from a target distribution $p(x)$ that may be difficult to sample from, samples are drawn from a proposal distribution $q(x)$ and reweighted to correct for the discrepancy.

The core identity:

$$\mathbb{E}_{p}[f(x)] = \int f(x) p(x) \, dx = \int f(x) \frac{p(x)}{q(x)} q(x) \, dx = \mathbb{E}_{q}\left[f(x) \frac{p(x)}{q(x)}\right]$$

where $q(x) > 0$ wherever $p(x) f(x) \neq 0$.

### Motivation

Importance sampling addresses two common problems in probabilistic machine learning:

- **Intractable sampling**: $p(x)$ may be known only up to a normalizing constant, or direct sampling may be computationally expensive.
- **Rare-event estimation**: When the quantity of interest depends on a region where $p(x)$ places little probability mass, naive Monte Carlo sampling from $p(x)$ wastes most samples on irrelevant regions. A well-chosen $q(x)$ concentrates samples where they matter most.

### The Importance Weight

The ratio

$$w(x) = \frac{p(x)}{q(x)}$$

is called the importance weight. It corrects for the fact that samples are drawn from $q(x)$ rather than $p(x)$: samples from regions where $q$ over-represents relative to $p$ are down-weighted, and samples from regions where $q$ under-represents relative to $p$ are up-weighted.

### Monte Carlo Estimator

Given $N$ i.i.d. samples $x^{(1)}, \dots, x^{(N)} \sim q(x)$, the importance sampling estimator is:

$$\hat{I} = \frac{1}{N} \sum_{i=1}^{N} f(x^{(i)}) \, w(x^{(i)}) = \frac{1}{N} \sum_{i=1}^{N} f(x^{(i)}) \frac{p(x^{(i)})}{q(x^{(i)})}$$

This estimator is unbiased [Inference — follows directly from the identity above under standard regularity conditions, but the specific unbiasedness claim for any given implementation is not independently confirmed here] provided the support condition $q(x) > 0$ wherever $p(x)f(x) \neq 0$ holds.

### Unnormalized Importance Sampling (Self-Normalized)

In many machine learning contexts, $p(x)$ is known only up to a normalizing constant, e.g., $p(x) = \tilde{p}(x) / Z$ where $Z$ is intractable. In this case, a self-normalized estimator is used:

$$\hat{I}_{SN} = \frac{\sum_{i=1}^{N} f(x^{(i)}) \tilde{w}(x^{(i)})}{\sum_{i=1}^{N} \tilde{w}(x^{(i)})}, \quad \tilde{w}(x^{(i)}) = \frac{\tilde{p}(x^{(i)})}{q(x^{(i)})}$$

This estimator is consistent (converges to the true value as $N \to \infty$) but is generally biased for finite $N$ [Inference — this is a standard theoretical property in Monte Carlo literature; not independently verified against a specific source here].

### Choosing the Proposal Distribution

The variance of the importance sampling estimator depends heavily on the choice of $q(x)$. The theoretically optimal proposal (minimizing variance for estimating $\mathbb{E}_p[f(x)]$) is:

$$q^*(x) \propto |f(x)| \, p(x)$$

This is rarely usable directly since it requires knowing the same quantity being estimated, but it motivates practical heuristics:

- Choose $q(x)$ with heavier tails than $p(x)$ to avoid weight explosion.
- Choose $q(x)$ that concentrates mass in regions where $|f(x)| p(x)$ is largest.
- Avoid $q(x)$ that assigns near-zero probability where $p(x) f(x)$ is non-negligible, since this produces extremely large, high-variance weights.

### Effective Sample Size

A diagnostic commonly used to assess the quality of an importance sampling estimate is the effective sample size (ESS):

$$\text{ESS} = \frac{\left(\sum_{i=1}^{N} w^{(i)}\right)^2}{\sum_{i=1}^{N} \left(w^{(i)}\right)^2}$$

ESS estimates how many "equivalent" i.i.d. samples from $p(x)$ the weighted sample set represents. When $q(x)$ is a poor match to $p(x)$, a few samples can dominate the weight sum, driving ESS far below $N$ and indicating an unreliable estimate. [Inference — this interpretation is standard in the Monte Carlo literature but the specific threshold at which ESS is considered "too low" varies by application and is not a fixed rule.]

### Weight Degeneracy

A well-known failure mode: if $q(x)$ poorly matches $p(x)$ — especially in high dimensions — the importance weights can become highly skewed, with nearly all probability mass concentrated on a single sample. This is known as weight degeneracy or weight collapse. It is a central challenge in applying importance sampling to high-dimensional posterior distributions in Bayesian machine learning. [Unverified — general phenomenon is well documented in the sampling literature, but no specific numeric claim is being made here about when this occurs.]

### Diagram: Importance Sampling Reweighting

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 420">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Importance Sampling Reweighting (svg_diagram)</text>

  
  <line x1="60" y1="360" x2="650" y2="360" stroke="#333" stroke-width="2" />
  <line x1="60" y1="360" x2="60" y2="60" stroke="#333" stroke-width="2" />
  <text x="355" y="395" font-size="13" text-anchor="middle" fill="#333">x</text>
  <text x="30" y="200" font-size="13" text-anchor="middle" fill="#333" transform="rotate(-90 30 200)">density</text>

  
  <path d="M 60,355 C 200,350 350,340 420,120 C 470,300 550,355 650,357" fill="none" stroke="#c0392b" stroke-width="3" />
  <text x="440" y="105" font-size="13" fill="#c0392b" font-weight="bold">p(x) — target</text>

  
  <path d="M 60,357 C 150,300 250,150 355,150 C 460,150 560,300 650,357" fill="none" stroke="#2980b9" stroke-width="3" stroke-dasharray="6,4" />
  <text x="470" y="170" font-size="13" fill="#2980b9" font-weight="bold">q(x) — proposal</text>

  
  <circle cx="180" cy="360" r="5" fill="#2980b9" />
  <circle cx="260" cy="360" r="5" fill="#2980b9" />
  <circle cx="330" cy="360" r="5" fill="#2980b9" />
  <circle cx="400" cy="360" r="5" fill="#2980b9" />
  <circle cx="470" cy="360" r="5" fill="#2980b9" />
  <circle cx="540" cy="360" r="5" fill="#2980b9" />

  
  <line x1="180" y1="360" x2="180" y2="345" stroke="#7f8c8d" stroke-width="2" />
  <line x1="260" y1="360" x2="260" y2="330" stroke="#7f8c8d" stroke-width="2" />
  <line x1="330" y1="360" x2="330" y2="300" stroke="#7f8c8d" stroke-width="2" />
  <line x1="400" y1="360" x2="400" y2="200" stroke="#e67e22" stroke-width="3" />
  <line x1="470" y1="360" x2="470" y2="260" stroke="#7f8c8d" stroke-width="2" />
  <line x1="540" y1="360" x2="540" y2="345" stroke="#7f8c8d" stroke-width="2" />

  <text x="400" y="195" font-size="11" fill="#e67e22" font-weight="bold" text-anchor="middle">high weight</text>
  <text x="180" y="20" font-size="12" fill="#555" />

  <text x="60" y="410" font-size="12" fill="#555">Samples drawn from q(x); vertical bars indicate relative importance weight w(x) = p(x)/q(x)</text>
</svg>

### Applications in Machine Learning

- **Off-policy reinforcement learning**: Estimating the expected return of a target policy using trajectories collected under a different behavior policy, with importance weights correcting for the policy mismatch.
- **Variational inference**: Importance-weighted autoencoders (IWAE) use multiple importance-weighted samples to tighten the variational lower bound on the log-likelihood.
- **Bayesian inference**: Approximating posterior expectations when direct posterior sampling is infeasible, often as a component of sequential Monte Carlo (particle filtering).
- **Rare-event simulation**: Estimating small failure probabilities (e.g., in reliability analysis or adversarial robustness testing) by oversampling the rare region of interest.
- **Class imbalance handling**: Reweighting samples from an imbalanced empirical distribution to approximate expectations under a balanced or target distribution.

### Worked Example

Suppose $p(x) = \mathcal{N}(0, 1)$ and the goal is to estimate $\mathbb{E}_p[\mathbf{1}(x > 3)]$, i.e., the probability that a standard normal exceeds 3. Direct Monte Carlo sampling from $p(x)$ would require a very large $N$ since $P(x>3) \approx 0.00135$, and most samples would be wasted.

Using a proposal $q(x) = \mathcal{N}(3, 1)$ shifts the sampling mass toward the region of interest. Each sample $x^{(i)} \sim q(x)$ is weighted by:

$$w(x^{(i)}) = \frac{p(x^{(i)})}{q(x^{(i)})} = \exp\left(-\frac{(x^{(i)})^2}{2} + \frac{(x^{(i)}-3)^2}{2}\right)$$

The estimator $\hat{I} = \frac{1}{N}\sum_i \mathbf{1}(x^{(i)} > 3) \, w(x^{(i)})$ then converges to the true tail probability with substantially lower variance than naive sampling from $p(x)$ for a fixed $N$. [Inference — the variance reduction in this specific tail-probability scenario follows from standard importance sampling theory applied to rare-event estimation, consistent with the general principle described above.]

### Key Points

- Importance sampling reweights samples from a tractable proposal $q(x)$ to estimate expectations under an intractable or hard-to-sample target $p(x)$.
- The support condition $q(x) > 0$ wherever $p(x)f(x) \neq 0$ is necessary for validity.
- Self-normalized importance sampling handles unnormalized target densities but introduces finite-sample bias.
- Proposal choice is critical: mismatched proposals cause high-variance or degenerate weights.
- Effective sample size is a standard diagnostic for weight degeneracy.

### Related Topics

- Sequential Monte Carlo and particle filtering
- Markov Chain Monte Carlo (MCMC) — Metropolis-Hastings
- Rejection sampling
- Variational inference and the evidence lower bound (ELBO)
- Importance-weighted autoencoders (IWAE)
- Off-policy evaluation in reinforcement learning