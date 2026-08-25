## Gibbs Sampling

**[Unverified]** This section describes standard theoretical material from the probability and statistics literature. Individual claims below are labeled per the stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly.

### Definition

Gibbs sampling is a Markov Chain Monte Carlo (MCMC) algorithm for generating samples from a joint distribution $p(x_1, x_2, \dots, x_D)$ by iteratively sampling each variable from its full conditional distribution, holding all other variables fixed at their current values.

$$x_i^{(t+1)} \sim p(x_i \mid x_1^{(t+1)}, \dots, x_{i-1}^{(t+1)}, x_{i+1}^{(t)}, \dots, x_D^{(t)})$$

Gibbs sampling is a special case of the Metropolis-Hastings algorithm in which the proposal distribution is the full conditional itself, and the acceptance probability is always 1. [Inference — this characterization is standard in MCMC literature; the derivation showing acceptance probability equals 1 for this proposal choice is not independently re-derived here.]

### Algorithm Steps

Given a joint distribution over $D$ variables $x = (x_1, \dots, x_D)$ and an initial state $x^{(0)}$:

1. For $t = 0, 1, 2, \dots$:
2. Sample $x_1^{(t+1)} \sim p(x_1 \mid x_2^{(t)}, x_3^{(t)}, \dots, x_D^{(t)})$
3. Sample $x_2^{(t+1)} \sim p(x_2 \mid x_1^{(t+1)}, x_3^{(t)}, \dots, x_D^{(t)})$
4. Continue sequentially through all variables, always conditioning on the most recently updated values.
5. Sample $x_D^{(t+1)} \sim p(x_D \mid x_1^{(t+1)}, \dots, x_{D-1}^{(t+1)})$

This full sweep constitutes one iteration of the chain.

### Why This Produces the Correct Stationary Distribution

[Inference] Each individual update step samples from a full conditional of $p(x)$, which by construction leaves $p(x)$ invariant under that update. The standard argument in the literature is that the sequence of these conditional updates, taken together, produces a Markov chain with $p(x)$ as its stationary distribution. This derivation is presented here as commonly stated theory; it has not been independently reproduced or checked against a specific cited proof in this session.

### Requirement: Tractable Full Conditionals

Gibbs sampling requires that each conditional distribution $p(x_i \mid x_{-i})$ be known in closed form and directly sampleable. This is the primary practical constraint on the method. [Inference — this is the standard stated requirement in the literature; whether it holds for any particular model is model-specific and not verified here in general.]

Common cases where full conditionals are tractable:

- Conjugate exponential-family models (e.g., Gaussian with conjugate Gaussian/Inverse-Gamma priors).
- Certain hierarchical Bayesian models with conjugate structure at each level.
- Discrete graphical models where conditionals reduce to simple categorical distributions.

**[Unverified]** The specific list above reflects commonly cited examples in secondary sources on Bayesian computation; it has not been cross-checked against a primary source in this session and should not be treated as exhaustive.

### Diagram: Gibbs Sampling Sweep (Two Variables)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Gibbs Sampling Sweep, 2D Case (svg_diagram)</text>

  <line x1="80" y1="330" x2="620" y2="330" stroke="#333" stroke-width="2" />
  <line x1="80" y1="330" x2="80" y2="60" stroke="#333" stroke-width="2" />
  <text x="600" y="355" font-size="13" fill="#333">x1</text>
  <text x="55" y="70" font-size="13" fill="#333">x2</text>

  <circle cx="200" cy="250" r="5" fill="#2980b9" />
  <text x="200" y="270" font-size="11" text-anchor="middle" fill="#555">(t)</text>

  <line x1="200" y1="250" x2="350" y2="250" stroke="#e67e22" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#arrow4)" />
  <circle cx="350" cy="250" r="5" fill="#e67e22" />
  <text x="350" y="235" font-size="10" text-anchor="middle" fill="#e67e22">sample x1|x2</text>

  <line x1="350" y1="250" x2="350" y2="140" stroke="#27ae60" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#arrow4)" />
  <circle cx="350" cy="140" r="5" fill="#27ae60" />
  <text x="410" y="145" font-size="10" fill="#27ae60">sample x2|x1</text>

  <line x1="350" y1="140" x2="480" y2="140" stroke="#e67e22" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#arrow4)" />
  <circle cx="480" cy="140" r="5" fill="#e67e22" />

  <line x1="480" y1="140" x2="480" y2="90" stroke="#27ae60" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#arrow4)" />
  <circle cx="480" cy="90" r="5" fill="#8e44ad" />
  <text x="480" y="75" font-size="11" text-anchor="middle" fill="#555">(t+2)</text>

  <text x="200" y="300" font-size="11" fill="#555">Coordinate-wise updates trace an axis-aligned path toward high-density regions</text>

  </svg>

### Worked Example: Bivariate Gaussian

Consider a bivariate Gaussian target with correlation $\rho$:

$$\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} \sim \mathcal{N}\left(\begin{pmatrix}0\\0\end{pmatrix}, \begin{pmatrix}1 & \rho \\ \rho & 1\end{pmatrix}\right)$$

The full conditionals for this distribution have a known closed form [Inference — this is a standard textbook result for the bivariate Gaussian case; the derivation itself is not reproduced or independently re-verified here]:

$$x_1 \mid x_2 \sim \mathcal{N}(\rho x_2, \, 1 - \rho^2)$$
$$x_2 \mid x_1 \sim \mathcal{N}(\rho x_1, \, 1 - \rho^2)$$

A Gibbs sampler alternates drawing $x_1$ from the first conditional and $x_2$ from the second, using the most recently sampled value each time. **[Unverified]** The specific rate at which this sampler explores the joint distribution for a given $\rho$ has not been independently tested or verified in this session.

### Gibbs Sampling and High Correlation

[Speculation] It is commonly discussed in the literature that when $\rho$ is close to $\pm 1$, the conditional distributions become narrow relative to the joint distribution's extent, which may cause the sampler to move slowly through the space. This is presented as a commonly discussed qualitative pattern, not as a confirmed quantitative result verified in this session, and the degree of any slowdown for a specific $\rho$ value is not established here.

### Blocked and Collapsed Gibbs Sampling

- **Blocked Gibbs sampling**: Groups of correlated variables are sampled jointly from their joint conditional rather than one at a time, when this joint conditional is tractable. [Inference — this is a standard named variant described in MCMC literature; not independently re-verified here.]
- **Collapsed Gibbs sampling**: Certain variables are analytically marginalized out (integrated out) before sampling the remaining variables, reducing the dimensionality of the sampling problem. **[Unverified]** This technique is commonly referenced in topic modeling literature (e.g., collapsed Gibbs sampling for Latent Dirichlet Allocation), but this specific application has not been independently verified against a primary source in this session.

### Convergence and Burn-In

I cannot verify how many iterations are sufficient for convergence in any specific model; this depends on the target distribution's structure and is not a fixed, generally applicable number. As with other MCMC methods, initial samples before approximate convergence are commonly discarded as "burn-in," and diagnostics such as trace plots or the Gelman-Rubin statistic are commonly used as heuristic indicators. **[Unverified]** None of these diagnostics constitutes formal proof of convergence for a finite chain.

### Limitations

- Requires closed-form, directly sampleable full conditionals — not applicable to arbitrary target distributions. [Inference]
- Samples are autocorrelated, particularly when variables are highly correlated with one another. **[Unverified]**
- Can mix slowly in high-dimensional or highly correlated posteriors. **[Speculation]** — commonly discussed in the literature as a qualitative concern, not confirmed here with a specific quantitative bound.
- Does not use gradient information, unlike Hamiltonian Monte Carlo, which some sources discuss as a potential efficiency difference in certain settings. **[Unverified]**

### Applications in Machine Learning

- Bayesian inference in conjugate hierarchical models.
- Latent Dirichlet Allocation (LDA) topic modeling, commonly fit using collapsed Gibbs sampling in some implementations. **[Unverified — specific implementation choices vary by library and are not independently checked here.]**
- Restricted Boltzmann Machines, where block Gibbs sampling alternates between visible and hidden layers. **[Unverified — specific training procedures vary by implementation and are not confirmed here.]**
- Gaussian mixture model inference with conjugate priors.

### Key Points

- Gibbs sampling updates each variable in turn from its full conditional distribution, given current values of all other variables.
- It is a special case of Metropolis-Hastings with acceptance probability always equal to 1. [Inference]
- It requires tractable, directly sampleable full conditional distributions, which limits applicability to certain model classes.
- High correlation between variables is commonly discussed as a factor that may slow mixing. [Speculation]
- Convergence is asymptotic; no finite chain length is confirmed here to guarantee exact convergence for a specific model.

### Related Topics

- Metropolis-Hastings algorithm
- Blocked and collapsed Gibbs sampling
- Hamiltonian Monte Carlo
- Conjugate priors and exponential family distributions
- Latent Dirichlet Allocation
- Convergence diagnostics (trace plots, Gelman-Rubin statistic, ESS)