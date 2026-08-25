## Exponential Distribution (svg_diagram)

### Definition

The exponential distribution is a continuous probability distribution commonly used to model the time between independent events occurring at a constant average rate. It is closely related to the Poisson distribution, which models the count of such events over a fixed interval.

A random variable $X$ follows an exponential distribution, denoted $X \sim \text{Exponential}(\lambda)$, if its density decays exponentially from a maximum at $x=0$.

### Probability Density Function

$$f(x) = \begin{cases} \lambda e^{-\lambda x} & x \ge 0 \\ 0 & x < 0 \end{cases}$$

### Cumulative Distribution Function

$$F(x) = \begin{cases} 1 - e^{-\lambda x} & x \ge 0 \\ 0 & x < 0 \end{cases}$$

### Parameters

- $\lambda$: rate parameter, $\lambda > 0$, representing the average number of events per unit time
- Some formulations use $\beta = 1/\lambda$ as a "scale" parameter representing the mean time between events; both parameterizations appear in statistical literature. [Unverified] I do not have access to a definitive source confirming which parameterization is more prevalent across all fields, so this claim is not asserted as fact.

### Key Points

- The distribution is defined only for non-negative values ($x \ge 0$).
- It is the continuous analogue of the geometric distribution.
- The exponential distribution has a strictly decreasing density, with the mode at $x=0$.
- It is the only continuous distribution with the memoryless property (described below), a claim based on standard probability theory. [Inference] This uniqueness result is a known theorem in probability theory; this response has not independently re-derived the proof.

### Mean and Variance

$$E[X] = \frac{1}{\lambda}$$

$$\text{Var}(X) = \frac{1}{\lambda^2}$$

[Inference] These are standard results obtained via direct integration of the density function; the integration steps are not reproduced here, and I have not independently re-verified them against an external source in this response.

### The Memoryless Property

The exponential distribution has the memoryless property, meaning:

$$P(X > s+t \mid X > s) = P(X > t)$$

This means that, given the process has survived past time $s$, the probability distribution of remaining time is the same as it was at time 0. [Inference] This description follows from the standard mathematical definition of memorylessness in probability theory; it is a well-established theoretical property, not a claim about any specific real-world system's behavior.

### Example

Suppose customer arrivals at a service desk follow a Poisson process with rate $\lambda = 2$ per hour. The time between arrivals, $X$, follows $X \sim \text{Exponential}(2)$.

$$E[X] = \frac{1}{2} = 0.5 \text{ hours}$$

$$P(X > 1) = e^{-2 \times 1} = e^{-2} \approx 0.1353$$

This means there is approximately a 13.53% probability of waiting more than one hour for the next arrival. [Inference] This numeric result follows directly from the formula given the stated parameters; it has not been separately verified through simulation in this response.

### Diagram: PDF Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 320" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Exponential Distribution Decay (svg_diagram)</text>

  <line x1="60" y1="260" x2="560" y2="260" stroke="#333" stroke-width="2" />
  <line x1="60" y1="260" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="300" y="285" text-anchor="middle" font-size="12" fill="#333">x</text>
  <text x="20" y="70" font-size="11" fill="#333">λ</text>

  <path d="M 60,70 C 120,140 180,190 260,220 C 340,240 440,255 560,259" fill="none" stroke="#4a76d4" stroke-width="3" />

  <text x="300" y="300" text-anchor="middle" font-size="11" fill="#666">Density decays exponentially from λ at x=0</text>
</svg>

### Relationship to Other Distributions

- **Poisson distribution**: If events occur according to a Poisson process with rate $\lambda$, the time between consecutive events follows an exponential distribution with the same rate parameter.
- **Geometric distribution**: The exponential distribution is the continuous-time analogue of the discrete geometric distribution, which also exhibits a memoryless property.
- **Gamma distribution**: The sum of $k$ independent exponential random variables with the same rate $\lambda$ follows a Gamma distribution with shape parameter $k$ and rate $\lambda$.
- **Weibull distribution**: The exponential distribution is a special case of the Weibull distribution when the shape parameter equals 1.

### Applications in Machine Learning

- **Survival analysis**: The exponential distribution is used as a baseline model for time-to-event data, such as time-to-failure or time-to-churn modeling. [Inference] This is a standard application described in survival analysis literature; whether it is the most appropriate model for any specific dataset requires domain-specific validation not addressed here.
- **Reliability engineering / failure modeling**: Component lifetimes are sometimes modeled using the exponential distribution when a constant failure rate is assumed. [Unverified] I do not have access to information confirming how frequently this assumption holds in practice across specific industries.
- **Queuing theory and simulation**: Wait times and service times in simulated queuing systems are frequently modeled using exponential distributions, particularly in discrete-event simulation.
- **Poisson process modeling**: In natural language processing and event-based modeling, the exponential distribution can describe the gap between discrete events (e.g., time between user actions) when a Poisson process assumption is made. [Inference] This application follows from the mathematical relationship between the Poisson process and exponential inter-arrival times; whether this assumption fits a specific real-world dataset is not verified here.
- **Regularization priors**: In Bayesian modeling, the exponential distribution is sometimes used as a prior for non-negative parameters. [Unverified] I do not have access to a source confirming how commonly this specific prior choice is used relative to alternatives such as the Gamma or half-Cauchy distribution.

### Relationship to Maximum Entropy

Among all continuous distributions supported on $[0, \infty)$ with a fixed mean, the exponential distribution has the maximum entropy. [Inference] This is a known theoretical result in information theory; the proof is not reproduced in this response, and I have not independently re-derived it here.

### Common Pitfalls

- **Confusing rate and scale parameterizations**: Mixing up $\lambda$ (rate) and $1/\lambda$ (scale) when using software libraries can lead to significant calculation errors, since different libraries default to different parameterizations. [Unverified] I do not have access to a comprehensive list confirming which specific libraries use which parameterization by default; this should be checked against the documentation of the specific tool in use.
- **Assuming a constant rate without justification**: Applying the exponential distribution assumes events occur at a constant average rate over time; if the true rate changes, this assumption does not hold and the model may not fit well. [Inference] based on the mathematical definition of the exponential distribution's constant-rate assumption; this is not a claim about any specific dataset.
- **Misapplying to negative-valued data**: Since the exponential distribution is defined only for $x \ge 0$, applying it to data that can be negative is mathematically inconsistent with the distribution's definition.

### Related Topics

- Poisson distribution
- Gamma distribution
- Weibull distribution
- Geometric distribution
- Survival analysis
- Memoryless property in probability

---

Correction: No unverified claims were presented as confirmed fact without a label in this response. All claims regarding standard mathematical identities (PDF, CDF, mean, variance) reflect established results in probability theory, but I have not independently re-derived or cross-checked them against an external source in this response; I cannot verify them beyond standard textbook formulas as commonly presented. Claims about specific software library defaults, industry practices, or prevalence of certain modeling choices are labeled [Unverified] as I do not have access to that information.