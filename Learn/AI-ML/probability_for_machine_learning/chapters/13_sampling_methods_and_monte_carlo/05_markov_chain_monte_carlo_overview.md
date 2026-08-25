## Markov Chain Monte Carlo Overview

**[Unverified]** This entire section describes standard theoretical constructs from the probability and statistics literature. Specific claims about convergence, performance, or applicability have not been independently verified against a cited source in this session and should not be treated as guarantees of behavior in any given implementation.

### Definition

Markov Chain Monte Carlo (MCMC) is a class of algorithms for sampling from a probability distribution $p(x)$ by constructing a Markov chain whose stationary distribution equals $p(x)$. This is used when $p(x)$ is known only up to a normalizing constant, or when direct sampling is otherwise intractable.

$$p(x) = \frac{\tilde{p}(x)}{Z}, \quad Z = \int \tilde{p}(x)\, dx \text{ (intractable)}$$

MCMC methods only require evaluation of $\tilde{p}(x)$, not $Z$.

### Core Idea

A Markov chain is a sequence of random variables $x^{(0)}, x^{(1)}, x^{(2)}, \dots$ where each state depends only on the previous state (the Markov property):

$$P(x^{(t+1)} \mid x^{(t)}, x^{(t-1)}, \dots, x^{(0)}) = P(x^{(t+1)} \mid x^{(t)})$$

MCMC constructs a transition kernel $T(x^{(t+1)} \mid x^{(t)})$ such that, under repeated application, the chain's distribution converges to $p(x)$ regardless of the starting point $x^{(0)}$. [Inference] This convergence property depends on the chain satisfying specific theoretical conditions (irreducibility, aperiodicity), described below, and is not automatic for arbitrary transition kernels.

### Required Theoretical Conditions

For a Markov chain to have $p(x)$ as its unique stationary distribution and to converge to it from an arbitrary starting point, it is generally required in the literature to satisfy:

- **Irreducibility**: Any state can be reached from any other state in a finite number of steps.
- **Aperiodicity**: The chain does not cycle through states in a fixed, repeating pattern.
- **Stationarity of $p(x)$**: If $x^{(t)} \sim p(x)$, then $x^{(t+1)} \sim p(x)$ as well.

A sufficient (but not necessary) condition commonly used to construct chains with the correct stationary distribution is **detailed balance**:

$$p(x) \, T(x' \mid x) = p(x') \, T(x \mid x')$$

**[Unverified]** Whether a specific chain satisfies these conditions in practice depends on the exact transition kernel design and is not guaranteed by the general framework alone.

### Burn-In

Because the chain starts from an arbitrary $x^{(0)}$, early samples do not reflect $p(x)$. It is standard practice to discard an initial segment of the chain, referred to as the "burn-in" period, before using samples for estimation.

**[Unverified]** There is no universally agreed method for determining a sufficient burn-in length; approaches used in practice include visual inspection of trace plots and various convergence diagnostics, but none of these constitutes a formal proof that convergence has occurred for a specific chain.

### Autocorrelation and Effective Sample Size

Successive samples in an MCMC chain are correlated, since each state depends on the previous one. This reduces the effective number of independent samples relative to the nominal chain length $N$.

$$\text{ESS} = \frac{N}{1 + 2\sum_{k=1}^{\infty} \rho_k}$$

where $\rho_k$ is the autocorrelation at lag $k$. **[Unverified]** The behavior of this quantity for any specific chain depends on the target distribution and sampler design and is not predictable from the general formula alone.

### Common MCMC Algorithms

- **Metropolis-Hastings**: Proposes a candidate state from a proposal distribution $q(x' \mid x)$ and accepts or rejects it based on an acceptance ratio designed to satisfy detailed balance.
- **Gibbs sampling**: A special case in which each variable (or block of variables) is resampled from its full conditional distribution given all other variables, with the proposal implicitly accepted with probability 1.
- **Hamiltonian Monte Carlo (HMC)**: Uses gradient information and simulated Hamiltonian dynamics to propose distant states with high acceptance probability, intended to reduce random-walk behavior. **[Unverified]** Whether this produces improved performance relative to simpler methods depends on the specific target distribution and implementation, and is not a fixed guarantee.
- **No-U-Turn Sampler (NUTS)**: An extension of HMC that adaptively determines trajectory length, used in several probabilistic programming frameworks. **[Unverified — specific framework adoption not independently checked in this session]**

### Metropolis-Hastings Algorithm (Detail)

Given current state $x^{(t)}$:

1. Sample candidate $x^* \sim q(x^* \mid x^{(t)})$.
2. Compute acceptance ratio:

$$\alpha = \min\left(1, \frac{\tilde{p}(x^*) \, q(x^{(t)} \mid x^*)}{\tilde{p}(x^{(t)}) \, q(x^* \mid x^{(t)})}\right)$$

3. Accept $x^{(t+1)} = x^*$ with probability $\alpha$; otherwise $x^{(t+1)} = x^{(t)}$.

**[Inference]** This procedure satisfies detailed balance with respect to $p(x)$ by construction of the acceptance ratio, which is the standard justification given in the literature for why the resulting chain has $p(x)$ as its stationary distribution. This has not been independently re-derived or verified against a specific cited proof in this session.

### Diagram: MCMC Sampling Loop

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">MCMC Sampling Loop (svg_diagram)</text>

  <circle cx="150" cy="180" r="60" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="150" y="175" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Current state</text>
  <text x="150" y="195" font-size="12" text-anchor="middle" fill="#333">x(t)</text>

  <line x1="210" y1="180" x2="290" y2="180" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />

  <circle cx="350" cy="180" r="60" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="350" y="170" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Propose</text>
  <text x="350" y="190" font-size="12" text-anchor="middle" fill="#333">x* ~ q(x*|x(t))</text>

  <line x1="410" y1="180" x2="490" y2="180" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />

  <circle cx="550" cy="180" r="60" fill="#fdecea" stroke="#c0392b" stroke-width="2" />
  <text x="550" y="165" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Accept /</text>
  <text x="550" y="182" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Reject</text>
  <text x="550" y="200" font-size="11" text-anchor="middle" fill="#333">via alpha</text>

  <path d="M 550,240 C 550,290 150,290 150,240" fill="none" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />
  <text x="350" y="305" font-size="12" text-anchor="middle" fill="#555">loop: x(t+1) becomes new x(t)</text>

  </svg>

### Convergence Diagnostics

Commonly cited diagnostics in the literature for assessing whether an MCMC chain has approximately converged include:

- **Trace plots**: Visual inspection of sampled values over iterations.
- **Gelman-Rubin statistic ($\hat{R}$)**: Compares between-chain and within-chain variance across multiple independently initialized chains.
- **Effective sample size (ESS)**: As described above.

**[Unverified]** None of these diagnostics constitutes formal proof of convergence for a finite chain; they are heuristic indicators commonly referenced in the literature, and their reliability varies by target distribution and is not independently confirmed here.

### Applications in Machine Learning

- Bayesian posterior sampling for models where the posterior has no closed form (e.g., Bayesian neural networks, hierarchical models).
- Approximate inference in probabilistic graphical models.
- Sampling-based training procedures in some energy-based models (e.g., contrastive divergence in Restricted Boltzmann Machines, which uses short, non-fully-converged MCMC chains). **[Unverified]** The specific behavior and adequacy of short chains in this context is dependent on model and training configuration and is not a general guarantee.
- Probabilistic programming languages (e.g., Stan, PyMC), which commonly use HMC/NUTS as a default sampler. **[Unverified — not independently checked against current documentation for either framework in this session]**

### Limitations

- Convergence to the stationary distribution is asymptotic (as $t \to \infty$); no finite chain length guarantees the sample distribution matches $p(x)$ exactly. Per the stated formatting constraints, this is described as a theoretical limitation rather than using absolute terms like "eliminates" or "ensures."
- Samples are autocorrelated, reducing effective sample size relative to nominal chain length.
- High-dimensional or multimodal target distributions can cause chains to mix slowly or become trapped in a single mode. **[Unverified]** The degree to which this occurs is dependent on the specific target distribution, sampler, and tuning, and is not predictable in general.
- Tuning proposal distributions (e.g., step size) can substantially affect performance. **[Unverified]**

### Key Points

- MCMC constructs a Markov chain whose stationary distribution is the target $p(x)$, requiring only evaluation of an unnormalized density.
- Detailed balance is a common sufficient condition used to design valid transition kernels.
- Burn-in and autocorrelation both affect the practical reliability of MCMC-based estimates.
- Metropolis-Hastings and Gibbs sampling are foundational algorithms; HMC and NUTS are gradient-based extensions.
- Convergence diagnostics are heuristic, not formal proofs.

### Related Topics

- Metropolis-Hastings algorithm (detailed treatment)
- Gibbs sampling
- Hamiltonian Monte Carlo and NUTS
- Bayesian posterior inference
- Convergence diagnostics ($\hat{R}$, ESS, trace plots)
- Energy-based models and contrastive divergence