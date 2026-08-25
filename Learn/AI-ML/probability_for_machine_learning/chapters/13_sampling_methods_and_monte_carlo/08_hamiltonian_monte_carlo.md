## Hamiltonian Monte Carlo

**[Unverified]** This section describes standard theoretical material from the probability and statistics literature. Individual claims are labeled per stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly.

### Definition

Hamiltonian Monte Carlo (HMC) is a Markov Chain Monte Carlo method that uses gradient information about the target distribution to propose distant candidate states, with the intent of reducing the random-walk behavior seen in methods such as basic Metropolis-Hastings. [Inference — this characterization is standard in the MCMC literature; not independently re-derived here.] HMC augments the target variable $x$ with an auxiliary momentum variable $r$ and simulates Hamiltonian dynamics over this joint space.

### Core Idea: Physical Analogy

HMC treats sampling as a physics simulation problem. [Inference] The negative log-density of the target, $-\log p(x)$, is treated as a "potential energy" function $U(x)$, and an auxiliary momentum variable $r$ is introduced with a "kinetic energy" $K(r)$, typically:

$$K(r) = \frac{1}{2} r^T M^{-1} r$$

where $M$ is a mass matrix (often set to identity). The joint distribution over $(x, r)$ is:

$$p(x, r) \propto \exp(-U(x) - K(r))$$

Simulating the trajectory of this system via Hamiltonian dynamics, then accepting or rejecting the resulting state via a Metropolis step, is intended to produce large, efficient moves through the state space. **[Unverified]** Whether this produces improved efficiency relative to simpler samplers for any specific target distribution is not established here and depends on the implementation and problem.

### Hamiltonian Dynamics

The Hamiltonian is defined as:

$$H(x, r) = U(x) + K(r)$$

The system evolves according to Hamilton's equations:

$$\frac{dx}{dt} = \frac{\partial H}{\partial r} = M^{-1} r, \qquad \frac{dr}{dt} = -\frac{\partial H}{\partial x} = -\nabla U(x)$$

[Inference] These equations are the standard formulation from classical mechanics as applied in the HMC literature; the derivation itself is not reproduced or independently re-verified here.

### Algorithm Steps

Given current state $x^{(t)}$:

1. Sample momentum $r \sim \mathcal{N}(0, M)$.
2. Simulate Hamiltonian dynamics forward for $L$ steps of size $\epsilon$ using a numerical integrator (commonly the leapfrog integrator), starting from $(x^{(t)}, r)$, producing a proposed state $(x^*, r^*)$.
3. Compute the Metropolis acceptance probability:

$$\alpha = \min\left(1, \exp\big(-H(x^*, r^*) + H(x^{(t)}, r)\big)\right)$$

4. Accept $x^{(t+1)} = x^*$ with probability $\alpha$; otherwise $x^{(t+1)} = x^{(t)}$.

**[Unverified]** The specific numerical accuracy and stability of this procedure in any given implementation is not independently confirmed here.

### The Leapfrog Integrator

Since Hamiltonian dynamics generally cannot be solved in closed form for non-trivial $U(x)$, a numerical integrator is used. The leapfrog integrator is the standard choice cited in the HMC literature, [Inference] due to properties described in that literature as time-reversibility and volume preservation, which are stated as necessary for the acceptance step above to be theoretically valid. This claim is presented as commonly stated theory; it has not been independently re-derived here.

One leapfrog step of size $\epsilon$:

$$r_{t+\epsilon/2} = r_t - \frac{\epsilon}{2} \nabla U(x_t)$$
$$x_{t+\epsilon} = x_t + \epsilon \, M^{-1} r_{t+\epsilon/2}$$
$$r_{t+\epsilon} = r_{t+\epsilon/2} - \frac{\epsilon}{2} \nabla U(x_{t+\epsilon})$$

### Diagram: HMC Trajectory Simulation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">HMC Trajectory Simulation (svg_diagram)</text>

  <ellipse cx="350" cy="220" rx="220" ry="120" fill="none" stroke="#bdc3c7" stroke-width="1.5" stroke-dasharray="3,3" />
  <ellipse cx="350" cy="220" rx="150" ry="80" fill="none" stroke="#bdc3c7" stroke-width="1.5" stroke-dasharray="3,3" />
  <ellipse cx="350" cy="220" rx="80" ry="40" fill="none" stroke="#bdc3c7" stroke-width="1.5" stroke-dasharray="3,3" />
  <text x="600" y="120" font-size="11" fill="#888">level sets of U(x)</text>

  <circle cx="450" cy="260" r="6" fill="#2980b9" />
  <text x="450" y="280" font-size="11" text-anchor="middle" fill="#2980b9" font-weight="bold">x(t)</text>

  <path d="M 450,260 C 420,200 350,150 300,160 C 260,168 240,200 230,230" fill="none" stroke="#e67e22" stroke-width="3" />

  <circle cx="230" cy="230" r="6" fill="#c0392b" />
  <text x="200" y="220" font-size="11" text-anchor="middle" fill="#c0392b" font-weight="bold">x*</text>

  <text x="330" y="140" font-size="11" fill="#e67e22">leapfrog trajectory (L steps)</text>

  <line x1="450" y1="260" x2="480" y2="300" stroke="#27ae60" stroke-width="2" marker-end="url(#arrow5)" />
  <text x="500" y="310" font-size="10" fill="#27ae60">initial momentum r</text>

  </svg>

### Tuning Parameters

- **Step size $\epsilon$**: Controls numerical integration accuracy. [Inference] Larger step sizes are described in the literature as reducing acceptance probability due to discretization error, while smaller step sizes are described as requiring more steps to traverse the same distance. This tradeoff is presented as commonly discussed theory, not independently confirmed with a specific numeric bound here.
- **Number of steps $L$**: Controls trajectory length. **[Unverified]** The literature commonly discusses risks at both extremes — trajectories too short resembling random-walk behavior, and trajectories too long potentially looping back toward the starting point (sometimes called "U-turns") — but the specific behavior for any given target distribution is not established here.
- **Mass matrix $M$**: Affects the geometry of the momentum distribution and can be tuned to the covariance structure of the target. **[Unverified]**

### The No-U-Turn Sampler (NUTS)

NUTS is an extension of HMC that adaptively determines the trajectory length $L$, intended to remove the need for manual tuning of this parameter. [Inference — this is the commonly stated motivation for NUTS in the literature; not independently re-derived here.] **[Unverified]** I cannot verify specific implementation details or performance characteristics of NUTS as used in any particular current software library without checking current documentation, which has not been done in this session.

### Why HMC Can Be More Efficient Than Random-Walk Methods

[Speculation] It is commonly discussed in the literature that, because HMC uses gradient information to guide proposals along directions of high probability density rather than proposing purely randomly, it may explore the state space more efficiently in high dimensions than methods like basic Metropolis-Hastings. This is presented as a commonly discussed qualitative claim, not as a confirmed quantitative result verified in this session. The degree of any such difference depends on the specific target distribution, tuning, and implementation, and is not established here.

### Limitations

- Requires the target's log-density to be differentiable, which is not the case for all models (e.g., certain discrete-variable models). [Inference]
- Sensitive to tuning of step size $\epsilon$, number of steps $L$, and mass matrix $M$. **[Unverified]**
- Computational cost per iteration is higher than simpler methods like Metropolis-Hastings, due to the need for gradient evaluations at each leapfrog step. [Inference — standard characterization in the literature; not independently benchmarked here.]
- Can struggle with target distributions that have widely varying scales across dimensions or strong multimodality, per commonly discussed concerns in the literature. **[Speculation]**

### Applications in Machine Learning

- Bayesian inference in models with continuous, differentiable parameter spaces, including Bayesian neural networks and hierarchical models.
- Used as the default or commonly available sampler (often via NUTS) in probabilistic programming frameworks. I cannot verify the current default settings of any specific software library without checking current documentation, which has not been done in this session.
- Posterior sampling in Bayesian deep learning research contexts. **[Unverified]**

### Key Points

- HMC augments the target variable with auxiliary momentum and simulates Hamiltonian dynamics to propose distant states.
- The leapfrog integrator is the standard numerical method used, chosen for stated reversibility and volume-preservation properties described in the literature.
- Step size, number of steps, and mass matrix are key tuning parameters affecting performance; their effects are described qualitatively above and are not established here with specific numeric guarantees.
- NUTS extends HMC to adaptively set trajectory length.
- Gradient requirements and per-iteration cost are the primary limitations relative to simpler MCMC methods.

### Related Topics

- No-U-Turn Sampler (NUTS)
- Metropolis-Hastings algorithm
- Gibbs sampling
- Bayesian neural networks and posterior inference
- Probabilistic programming frameworks
- Convergence diagnostics (trace plots, Gelman-Rubin statistic, ESS)