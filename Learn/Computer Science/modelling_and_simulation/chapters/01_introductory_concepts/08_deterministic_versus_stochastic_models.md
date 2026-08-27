## Deterministic versus Stochastic Models

### Definitions

A **deterministic model** produces exactly one output for a given set of inputs and initial conditions — running the model repeatedly under identical conditions always yields identical results. There is no randomness embedded in the model's structure.

A **stochastic model** incorporates randomness explicitly, typically through random variables, probability distributions, or noise terms. Running the model repeatedly under identical inputs and initial conditions produces a distribution of possible outcomes rather than a single fixed result.

The distinction concerns whether **chance is a structural component** of the model, not whether the underlying real-world system is "truly" random — a deterministic model can be used to approximate a system that is technically stochastic if the noise is judged negligible relative to the phenomenon under study.

### Deterministic Models

**Key Points**
- Same inputs always produce the same outputs.
- No probability distributions embedded in state transitions or parameters.
- Fully predictable given the model equations and initial conditions.
- Simulation output requires only one run, since repeated runs are identical.

**Example**

The RC circuit charging equation introduced earlier is deterministic:

$$\frac{dV(t)}{dt} = \frac{1}{RC}\left(V_{source} - V(t)\right)$$

Given a fixed $R$, $C$, $V_{source}$, and $V(0)$, the trajectory $V(t)$ is uniquely determined for all $t$. Solving it analytically or numerically twice with identical parameters yields identical curves.

A discrete deterministic example — compound interest:

$$A_{n+1} = A_n (1 + r)$$

Given $A_0$ and $r$, every subsequent $A_n$ is fixed.

### Stochastic Models

**Key Points**
- Same inputs can produce different outputs across runs, due to embedded randomness.
- Randomness is typically introduced via random variables (e.g., $X \sim \mathcal{N}(\mu, \sigma^2)$), stochastic processes, or probabilistic transition rules.
- Requires multiple simulation runs (replications) to characterize the distribution of possible outcomes — a single run is one sample path, not the full picture.
- Output is commonly summarized using statistics: mean, variance, confidence intervals, percentiles.

**Example**

A stochastic version of population growth, adding environmental noise:

$$P_{n+1} = P_n + r P_n (1 - P_n/K) + \sigma P_n \, \varepsilon_n, \qquad \varepsilon_n \sim \mathcal{N}(0,1)$$

Here $\varepsilon_n$ is a random shock drawn independently at each step, so two runs with identical $P_0$, $r$, $K$, and $\sigma$ will diverge after the first step.

A queueing example: customer arrivals following a Poisson process with rate $\lambda$, where inter-arrival times are exponentially distributed:

$$P(T > t) = e^{-\lambda t}$$

Each simulated arrival sequence is a different random realization.

### Structural Comparison

| Aspect | Deterministic Model | Stochastic Model |
|---|---|---|
| Repeated runs, same inputs | Identical output | Distribution of outputs |
| Randomness in structure | None | Embedded (random variables, noise, distributions) |
| Number of runs needed | One | Many (replications) |
| Output form | Single trajectory/value | Distribution, confidence intervals, summary statistics |
| Typical tools | Analytical solution, ODE/algebraic solvers | Monte Carlo methods, random number generators, statistical analysis |
| Example domains | Orbital mechanics, circuit steady-state, compound interest | Queueing systems, epidemiological spread, financial asset pricing |

### Relationship Between the Two

A stochastic model reduces to its deterministic counterpart when the variance of all random components is set to zero. In the stochastic population growth example above, setting $\sigma = 0$ recovers the deterministic logistic growth difference equation exactly.

[Inference] Conversely, deterministic models are often extended into stochastic ones by identifying parameters or inputs subject to real-world uncertainty and replacing fixed values with distributions — though the specific choice of which parameters to randomize, and which distribution to assign, is a modeling decision rather than something derivable from the deterministic model alone.

### Diagram: Repeated Runs Under Each Model Type

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Deterministic vs Stochastic: Repeated Runs (svg_diagram)</text>

  
  <rect x="40" y="60" width="320" height="240" fill="none" stroke="#888" stroke-width="1.5" />
  <text x="200" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Deterministic Model</text>
  <line x1="70" y1="260" x2="330" y2="260" stroke="#333" stroke-width="1.5" />
  <line x1="70" y1="260" x2="70" y2="100" stroke="#333" stroke-width="1.5" />
  <text x="200" y="285" text-anchor="middle" font-size="11" fill="#333">Time</text>
  <text x="50" y="180" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 50 180)">State</text>
  <path d="M 70 240 C 120 235, 150 150, 200 130 C 250 115, 290 108, 330 105" fill="none" stroke="#2563eb" stroke-width="2.5" />
  <text x="200" y="320" text-anchor="middle" font-size="10" fill="#666">Every run overlays the same curve exactly</text>

  
  <rect x="400" y="60" width="320" height="240" fill="none" stroke="#888" stroke-width="1.5" />
  <text x="560" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Stochastic Model</text>
  <line x1="430" y1="260" x2="690" y2="260" stroke="#333" stroke-width="1.5" />
  <line x1="430" y1="260" x2="430" y2="100" stroke="#333" stroke-width="1.5" />
  <text x="560" y="285" text-anchor="middle" font-size="11" fill="#333">Time</text>
  <text x="410" y="180" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 410 180)">State</text>
  <path d="M 430 240 C 470 230, 500 160, 560 135 C 610 115, 650 112, 690 100" fill="none" stroke="#dc2626" stroke-width="1.5" opacity="0.7" />
  <path d="M 430 245 C 480 225, 510 190, 560 150 C 620 140, 660 125, 690 130" fill="none" stroke="#dc2626" stroke-width="1.5" opacity="0.7" />
  <path d="M 430 250 C 470 245, 520 170, 560 165 C 600 150, 640 100, 690 95" fill="none" stroke="#dc2626" stroke-width="1.5" opacity="0.7" />
  <path d="M 430 240 C 460 238, 510 200, 560 190 C 610 175, 650 150, 690 155" fill="none" stroke="#dc2626" stroke-width="1.5" opacity="0.7" />
  <text x="560" y="320" text-anchor="middle" font-size="10" fill="#666">Each run traces a different sample path</text>
</svg>

### Selection Criteria: Which Model Type to Use

**Key Points**
- Use a **deterministic model** when the sources of variability in the real system are negligible relative to the phenomenon of interest, or when the goal is to establish a baseline/idealized behavior before adding complexity.
- Use a **stochastic model** when variability itself affects decisions or outcomes of interest — e.g., worst-case queue lengths, probability of system failure, risk assessment — where a single "average" trajectory would understate the range of possible outcomes.
- [Inference] A common practical workflow is to build the deterministic version first to verify the model's core logic against known analytical or expected results, then introduce stochastic elements once the deterministic skeleton is validated — this is a convention rather than a required sequence.

### Common Pitfalls

- Running a stochastic model only once and treating that single sample path as representative — a single replication captures only one realization out of the full outcome distribution.
- Under-sampling: using too few replications to estimate output statistics reliably, leading to misleading confidence intervals. [Inference] The number of replications needed depends on the variance of the output and the desired precision, and is typically determined by preliminary variance estimation rather than a fixed rule of thumb.
- Confusing "stochastic" with "unpredictable in principle" — a stochastic model is fully specified mathematically (its random components follow known distributions); it is variable in outcome, not undefined.
- Applying a deterministic model to a system where rare but high-impact random events matter (e.g., using average arrival rates for capacity planning without accounting for burst variability), which can severely underestimate resource needs.

**Related Topics**
- Monte Carlo simulation methodology
- Random number generation and pseudo-random generators
- Variance reduction techniques (antithetic variates, common random numbers)
- Discrete-event stochastic simulation
- Confidence intervals and statistical output analysis for simulation
- Markov chains and stochastic processes
- Sensitivity analysis under parameter uncertainty