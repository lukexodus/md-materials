## Metropolis-Hastings Algorithm

**[Unverified]** This section describes standard theoretical material from the probability and statistics literature. Specific claims about convergence, performance, or applicability have not been independently verified against a cited source in this session and are not guarantees of behavior for any specific implementation.

### Definition

The Metropolis-Hastings algorithm is a Markov Chain Monte Carlo method for generating samples from a target distribution $p(x)$ known only up to a normalizing constant:

$$p(x) = \frac{\tilde{p}(x)}{Z}, \quad Z \text{ intractable}$$

It constructs a Markov chain by proposing candidate states from a proposal distribution and probabilistically accepting or rejecting them, such that the chain's stationary distribution is $p(x)$.

### Algorithm Steps

Given current state $x^{(t)}$:

1. **Propose**: Sample a candidate $x^*$ from a proposal distribution $q(x^* \mid x^{(t)})$.
2. **Compute acceptance ratio**:

$$\alpha = \min\left(1, \frac{\tilde{p}(x^*) \, q(x^{(t)} \mid x^*)}{\tilde{p}(x^{(t)}) \, q(x^* \mid x^{(t)})}\right)$$

3. **Accept or reject**: Draw $u \sim \text{Uniform}(0,1)$. If $u \leq \alpha$, set $x^{(t+1)} = x^*$. Otherwise, set $x^{(t+1)} = x^{(t)}$.
4. **Repeat** for $t = 0, 1, 2, \dots$

### Why the Acceptance Ratio Has This Form

**[Inference]** The acceptance ratio is constructed specifically so that the resulting chain satisfies detailed balance with respect to $p(x)$:

$$p(x) \, T(x' \mid x) = p(x') \, T(x \mid x')$$

This is the standard justification given in the literature for why Metropolis-Hastings has $p(x)$ as its stationary distribution. This derivation has not been independently reproduced or checked against a specific cited proof in this session; it is presented here as commonly stated theory, not as independently confirmed fact.

Note that the unknown normalizing constant $Z$ cancels in the ratio $\tilde{p}(x^*)/\tilde{p}(x^{(t)})$, which is why only the unnormalized density is required.

### Symmetric Proposals: The Metropolis Algorithm

When the proposal distribution is symmetric, i.e., $q(x^* \mid x^{(t)}) = q(x^{(t)} \mid x^*)$ (e.g., a Gaussian centered on the current state), the proposal terms cancel and the acceptance ratio simplifies to:

$$\alpha = \min\left(1, \frac{\tilde{p}(x^*)}{\tilde{p}(x^{(t)})}\right)$$

This special case is historically referred to as the Metropolis algorithm; the general asymmetric-proposal version is the Metropolis-Hastings extension. **[Unverified]** The exact historical attribution and naming conventions are commonly stated in secondary sources but have not been verified here against a primary historical source.

### Choice of Proposal Distribution

A common proposal choice is a Gaussian random walk:

$$q(x^* \mid x^{(t)}) = \mathcal{N}(x^{(t)}, \sigma^2)$$

The step-size parameter $\sigma$ affects sampling behavior:

- **Small $\sigma$**: Proposals are close to the current state, leading to high acceptance rates but slow exploration of the state space (high autocorrelation between samples). [Inference — this describes a commonly cited tradeoff in the MCMC literature; the specific magnitude of the effect for any given target distribution is not verified here.]
- **Large $\sigma$**: Proposals move further, but are more likely to land in low-probability regions and be rejected, also leading to slow exploration. [Inference — same caveat as above.]

**[Unverified]** A frequently cited heuristic in the literature targets an acceptance rate in an intermediate range (commonly discussed figures include roughly 20-50% depending on dimensionality), but this is described as a rule of thumb in secondary sources, not a formally proven optimum for all cases, and has not been independently verified here.

### Diagram: Acceptance Decision Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Metropolis-Hastings Acceptance Flow (svg_diagram)</text>

  <rect x="270" y="60" width="160" height="60" rx="8" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="350" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Current state</text>
  <text x="350" y="103" font-size="12" text-anchor="middle" fill="#333">x(t)</text>

  <line x1="350" y1="120" x2="350" y2="160" stroke="#333" stroke-width="2" marker-end="url(#arrow3)" />

  <rect x="270" y="160" width="160" height="60" rx="8" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="350" y="185" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Propose x*</text>
  <text x="350" y="203" font-size="12" text-anchor="middle" fill="#333">x* ~ q(x*|x(t))</text>

  <line x1="350" y1="220" x2="350" y2="255" stroke="#333" stroke-width="2" marker-end="url(#arrow3)" />

  <polygon points="350,255 430,300 350,345 270,300" fill="#f4ecf7" stroke="#8e44ad" stroke-width="2" />
  <text x="350" y="295" font-size="11" text-anchor="middle" fill="#1a1a1a" font-weight="bold">u &lt;= alpha?</text>
  <text x="350" y="312" font-size="10" text-anchor="middle" fill="#333">compute ratio</text>

  <line x1="430" y1="300" x2="530" y2="300" stroke="#27ae60" stroke-width="2" marker-end="url(#arrow3)" />
  <text x="480" y="290" font-size="11" fill="#27ae60" font-weight="bold">yes</text>
  <rect x="530" y="270" width="140" height="50" rx="6" fill="#eafaf1" stroke="#27ae60" stroke-width="2" />
  <text x="600" y="300" font-size="12" text-anchor="middle" fill="#1a1a1a">x(t+1) = x*</text>

  <line x1="270" y1="300" x2="140" y2="300" stroke="#c0392b" stroke-width="2" marker-end="url(#arrow3)" />
  <text x="200" y="290" font-size="11" fill="#c0392b" font-weight="bold">no</text>
  <rect x="0" y="270" width="140" height="50" rx="6" fill="#fdecea" stroke="#c0392b" stroke-width="2" />
  <text x="70" y="300" font-size="12" text-anchor="middle" fill="#1a1a1a">x(t+1) = x(t)</text>

  </svg>

### Worked Example

Suppose the target is $p(x) \propto \exp(-x^2/2)$ (an unnormalized standard normal), and the proposal is a Gaussian random walk $q(x^* \mid x^{(t)}) = \mathcal{N}(x^{(t)}, 1)$, which is symmetric.

At state $x^{(t)} = 1.0$, suppose a candidate $x^* = 1.8$ is proposed. The acceptance ratio (Metropolis form, since the proposal is symmetric):

$$\alpha = \min\left(1, \frac{\exp(-1.8^2/2)}{\exp(-1.0^2/2)}\right) = \min(1, \exp(-1.62 + 0.5)) = \min(1, \exp(-1.12)) \approx \min(1, 0.326) = 0.326$$

A uniform random draw $u$ is then compared to $\alpha \approx 0.326$: if $u \leq 0.326$, the chain moves to $x^{(t+1)} = 1.8$; otherwise it remains at $x^{(t)} = 1.0$. **[Inference]** This numeric result follows directly from applying the stated formula to the stated inputs; it has not been independently verified by separate computation or against an external source in this session.

### Convergence and Burn-In

**[Unverified]** The chain's distribution is commonly stated in the literature to approach $p(x)$ as the number of iterations increases, under the theoretical conditions of irreducibility and aperiodicity discussed in MCMC theory generally. This is an asymptotic property; no finite chain length is claimed here to guarantee an exact match to $p(x)$. Early samples (before approximate convergence) are typically discarded as "burn-in." There is no single universally agreed method for determining sufficient burn-in length; this varies by source and application and is not independently verified here.

### Limitations

- Performance is sensitive to proposal distribution tuning (e.g., step size $\sigma$). [Inference — commonly cited in MCMC literature; magnitude of sensitivity varies by target distribution and is not verified here.]
- Samples are autocorrelated, which reduces effective sample size relative to nominal chain length.
- In high-dimensional spaces, random-walk proposals are commonly described in the literature as requiring smaller step sizes to maintain reasonable acceptance rates, which can slow exploration. **[Unverified]** The degree of this effect for any specific case is not independently confirmed here.
- Multimodal target distributions can cause a chain to remain trapped near a single mode for extended periods. **[Unverified]**

### Applications in Machine Learning

- Bayesian posterior sampling in models without closed-form posteriors.
- Approximate inference in probabilistic graphical models and hierarchical Bayesian models.
- Used as a component algorithm within more advanced samplers (e.g., component of Gibbs sampling variants, or as a comparison baseline for Hamiltonian Monte Carlo). **[Unverified — specific usage patterns not independently checked against current documentation in this session.]**

### Key Points

- Metropolis-Hastings generates samples from $p(x)$ using only an unnormalized density $\tilde{p}(x)$.
- The acceptance ratio is designed to satisfy detailed balance, the standard theoretical justification cited in the literature for correctness.
- Symmetric proposals reduce the algorithm to the simpler Metropolis form.
- Step-size tuning of the proposal distribution affects acceptance rate and exploration efficiency; this tradeoff is described qualitatively above, not with a universally proven optimal value.
- Convergence is asymptotic; diagnostics for practical convergence are heuristic, not formal proof.

### Related Topics

- Gibbs sampling
- Hamiltonian Monte Carlo and NUTS
- Convergence diagnostics (trace plots, Gelman-Rubin statistic, ESS)
- Detailed balance and stationary distributions
- Bayesian posterior inference

> Correction note per stated preferences: no rule violations identified in this response at time of generation. If any absolute-certainty term (e.g., "ensures," "guarantees," "eliminates") appears above outside of this notice, treat it as an error inconsistent with stated preferences.