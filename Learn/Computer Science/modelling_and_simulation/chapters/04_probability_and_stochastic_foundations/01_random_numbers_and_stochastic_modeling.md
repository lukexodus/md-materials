## Random Numbers and Stochastic Modeling

### Overview

Stochastic modeling incorporates randomness into simulations to represent uncertainty, variability, and unpredictability present in real-world systems. Unlike deterministic models, which produce the same output every time given the same input, stochastic models produce different outputs across runs because they draw values from probability distributions. The foundation of any stochastic simulation is the generation of random numbers that behave, for practical purposes, as if they were drawn independently and uniformly from a defined range.

### Why Randomness Matters in Simulation

Many real systems involve inherent variability: arrival times at a queue, equipment failure intervals, demand fluctuations, or measurement noise. Deterministic models cannot capture this variability, so they systematically misrepresent systems where randomness drives behavior. Stochastic simulation addresses this by embedding random variates into the model's logic, allowing the simulation to reproduce the statistical behavior of the real system across many replications, rather than a single fixed trajectory.

### Pseudo-Random Number Generators (PRNGs)

True randomness is difficult to obtain computationally, so simulations rely on Pseudo-Random Number Generators (PRNGs) — deterministic algorithms that produce sequences of numbers which approximate the statistical properties of true randomness.

**Key Points**

- A PRNG is initialized with a **seed** value; the same seed always produces the same sequence, which supports reproducibility.
- The output sequence eventually repeats after a fixed number of draws, known as the **period**. A well-designed PRNG has a period far larger than the number of values needed in any practical simulation.
- PRNGs are evaluated on statistical quality (uniformity, independence, absence of detectable patterns), period length, and computational speed.

#### Linear Congruential Generator (LCG)

One of the earliest and simplest PRNG families, defined by the recurrence:

$$X_{n+1} = (aX_n + c) \bmod m$$

where $a$ is the multiplier, $c$ is the increment, $m$ is the modulus, and $X_0$ is the seed. The generated integers are typically scaled to $[0, 1)$ by dividing by $m$.

LCGs are computationally cheap and easy to implement, but [Inference] their statistical quality is generally weaker than modern alternatives, particularly regarding lattice structure in higher dimensions, which is why they have largely been superseded in rigorous simulation work.

#### Mersenne Twister

A widely used PRNG in scientific computing and general-purpose programming languages, known for an extremely long period ($2^{19937}-1$) and strong statistical properties across many standard test suites. It underlies the default random number generation in many languages and libraries, including Python's `random` module and NumPy's legacy generator.

#### Modern Alternatives

Generators such as PCG (Permuted Congruential Generator) and Xorshift/Xoshiro families are increasingly used because they offer strong statistical quality with smaller state size and faster generation than Mersenne Twister, while maintaining long periods suitable for large-scale simulation.

### Properties of a Good Random Number Generator

- **Uniformity**: generated values should be evenly distributed across the target interval, with no sub-region over- or under-represented.
- **Independence**: successive values should show no discernible correlation or predictable pattern.
- **Long period**: the sequence should not repeat within the scope of a simulation's demand for random draws.
- **Reproducibility**: given the same seed, the sequence must be exactly replicable, which is essential for debugging, verification, and controlled experimentation.
- **Efficiency**: generation should be computationally cheap, since large-scale simulations may require billions of draws.

### Testing Randomness

Before trusting a PRNG for simulation work, its output is typically subjected to statistical tests to detect departures from ideal random behavior.

- **Chi-square test for uniformity**: partitions the range into intervals and compares observed versus expected frequencies of generated values.
- **Kolmogorov-Smirnov test**: compares the empirical cumulative distribution function of the generated sample against the theoretical uniform distribution.
- **Runs test**: examines the sequence for patterns of increasing or decreasing runs to detect non-randomness or serial correlation.
- **Autocorrelation test**: checks whether values at different lags in the sequence are statistically correlated, which would indicate non-independence.
- **Spectral test**: evaluates the lattice structure of generated points in multiple dimensions, historically important for exposing weaknesses in LCGs.

[Unverified] No single test can conclusively prove a generator is "truly random"; passing a battery of tests only indicates the absence of detected weaknesses relative to those specific tests.

### From Uniform Random Numbers to Random Variates

Simulations rarely need only uniform $[0,1)$ values directly; they need random variates that follow specific probability distributions (exponential, normal, Poisson, etc.) representing the phenomena being modeled. Several standard techniques transform uniform random numbers into variates from a target distribution.

#### Inverse Transform Method

If $F(x)$ is the cumulative distribution function (CDF) of the target distribution, and $U$ is a uniform random number on $[0,1)$, then:

$$X = F^{-1}(U)$$

produces a random variate $X$ following the target distribution, provided $F^{-1}$ can be computed or approximated.

**Example**

For an exponential distribution with rate $\lambda$, the CDF is $F(x) = 1 - e^{-\lambda x}$. Solving for $x$ gives the inverse transform:

$$X = -\frac{1}{\lambda} \ln(1 - U)$$

Since $1-U$ is also uniform on $(0,1]$, this is commonly simplified to $X = -\frac{1}{\lambda}\ln(U)$.

#### Acceptance-Rejection Method

Used when the inverse CDF is difficult or impossible to derive analytically. A simpler "proposal" distribution that envelopes the target density is sampled, and candidate values are accepted or rejected based on a probability ratio, until an accepted value is obtained. This method is more computationally expensive per accepted sample but applies to a broader class of distributions than the inverse transform method.

#### Composition Method

Applicable when the target distribution can be expressed as a weighted mixture of simpler distributions. A component distribution is selected according to the mixture weights, and a variate is then generated from that selected component.

#### Special-Case Methods

Certain distributions have dedicated efficient generation algorithms exploiting their specific mathematical structure, such as the Box-Muller transform for generating normal variates from pairs of uniform random numbers:

$$Z_0 = \sqrt{-2\ln U_1} \cos(2\pi U_2), \quad Z_1 = \sqrt{-2\ln U_1} \sin(2\pi U_2)$$

where $U_1, U_2$ are independent uniform $(0,1)$ variates and $Z_0, Z_1$ are independent standard normal variates.

### Random Variate Generation Workflow

Below is the general process by which uniform randomness becomes a usable stochastic input to a simulation model.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 220">
<text x="450" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Random Variate Generation Pipeline (svg_diagram)</text>
<rect x="20" y="70" width="150" height="70" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
<text x="95" y="100" text-anchor="middle" font-size="13" fill="#1a1a1a">Seed</text>
<text x="95" y="118" text-anchor="middle" font-size="11" fill="#444">initial value</text>
<line x1="170" y1="105" x2="215" y2="105" stroke="#666" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="220" y="70" width="160" height="70" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="2" />
<text x="300" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">PRNG</text>
<text x="300" y="113" text-anchor="middle" font-size="11" fill="#444">e.g. Mersenne</text>
<text x="300" y="127" text-anchor="middle" font-size="11" fill="#444">Twister, PCG</text>
<line x1="380" y1="105" x2="425" y2="105" stroke="#666" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="430" y="70" width="160" height="70" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
<text x="510" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Uniform Draw</text>
<text x="510" y="113" text-anchor="middle" font-size="11" fill="#444">U ~ [0,1)</text>
<line x1="590" y1="105" x2="635" y2="105" stroke="#666" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="640" y="70" width="220" height="70" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
<text x="750" y="92" text-anchor="middle" font-size="13" fill="#1a1a1a">Transformation Method</text>
<text x="750" y="110" text-anchor="middle" font-size="11" fill="#444">Inverse Transform /</text>
<text x="750" y="124" text-anchor="middle" font-size="11" fill="#444">Acceptance-Rejection / etc.</text>
<line x1="750" y1="140" x2="750" y2="175" stroke="#666" stroke-width="2" marker-end="url(#arrow1)" />
<text x="750" y="195" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Target Random Variate X</text>
</svg>

### Seeding Strategies

- **Fixed seeding**: using a constant, known seed produces identical output across runs, which is valuable for debugging and for verifying that model changes (not randomness) caused an observed difference in results.
- **Time-based or entropy-based seeding**: drawing a seed from system time or an entropy source produces a different sequence on each run, which is appropriate for production use where variability across executions is desired.
- **Independent streams**: many simulation frameworks provide mechanisms to generate multiple statistically independent random number streams from a single master seed, which is important when different stochastic elements of a model (e.g., arrival process vs. service time) must not be correlated with one another.

### Common Pitfalls

- **Seed reuse across independent runs**: reusing the same seed when independent replications are intended defeats the purpose of replication, since results will not vary.
- **Insufficient period**: using a low-quality generator with a short period in a large-scale simulation can cause the sequence to repeat, introducing artificial correlation into results.
- **Correlation between streams**: using overlapping or improperly partitioned streams for different random variables in a model can introduce spurious dependencies that do not reflect the real system.
- **Treating a PRNG as cryptographically secure**: standard simulation PRNGs (e.g., Mersenne Twister) are not designed to resist prediction from observed output, and [Inference] should not be used for security-sensitive applications such as key generation, since their internal state can often be reconstructed from a sufficient number of observed outputs.

### Applications in Modeling and Simulation

- **Discrete-event simulation**: generating random interarrival times, service times, and failure intervals to drive queueing and reliability models.
- **Monte Carlo simulation**: repeatedly sampling random inputs to estimate the distribution of an output quantity, such as project completion time or portfolio risk.
- **Agent-based modeling**: introducing individual-level stochastic variation in agent behavior, decision-making, or interaction outcomes.
- **System dynamics with noise**: injecting stochastic disturbances into otherwise continuous models to represent measurement error or environmental variability.

### Related Topics

- Discrete Random Variate Generation (Bernoulli, Binomial, Poisson)
- Continuous Distribution Fitting for Simulation Input Modeling
- Monte Carlo Methods and Variance Reduction Techniques
- Discrete-Event Simulation: Queueing Systems and Event Scheduling
- Verification and Validation of Stochastic Simulation Models
- Output Analysis: Confidence Intervals from Simulation Replications
- Markov Chains and Their Role in Stochastic Simulation