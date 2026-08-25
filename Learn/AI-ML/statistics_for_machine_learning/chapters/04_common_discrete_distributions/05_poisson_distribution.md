## Poisson Distribution

### Definition

The Poisson distribution models the number of events occurring in a fixed interval of time or space, given that events occur independently at a constant average rate.

$$P(X = k) = \frac{\lambda^k e^{-\lambda}}{k!}, \quad k = 0, 1, 2, \dots$$

where $\lambda > 0$ is the average rate of events per interval.

### Parameters

- $\lambda$ — rate parameter (average number of events per interval), $\lambda > 0$
- Support: $k \in \{0, 1, 2, \dots\}$

### Probability Mass Function Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" font-family="sans-serif">
  <text x="270" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Poisson PMF, λ = 4 (svg_diagram)</text>
  <line x1="50" y1="270" x2="510" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="50" y1="270" x2="50" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="520" y="290" font-size="12" fill="#333">k</text>
  <text x="30" y="45" font-size="12" fill="#333">P(X=k)</text>

  <rect x="60" y="245" width="30" height="25" fill="#457b9d" />
  <rect x="100" y="165" width="30" height="105" fill="#457b9d" />
  <rect x="140" y="115" width="30" height="155" fill="#457b9d" />
  <rect x="180" y="90" width="30" height="180" fill="#457b9d" />
  <rect x="220" y="82" width="30" height="188" fill="#457b9d" />
  <rect x="260" y="90" width="30" height="180" fill="#457b9d" />
  <rect x="300" y="115" width="30" height="155" fill="#457b9d" />
  <rect x="340" y="150" width="30" height="120" fill="#457b9d" />
  <rect x="380" y="185" width="30" height="85" fill="#457b9d" />
  <rect x="420" y="215" width="30" height="55" fill="#457b9d" />

  <text x="75" y="285" text-anchor="middle" font-size="10">0</text>
  <text x="115" y="285" text-anchor="middle" font-size="10">1</text>
  <text x="155" y="285" text-anchor="middle" font-size="10">2</text>
  <text x="195" y="285" text-anchor="middle" font-size="10">3</text>
  <text x="235" y="285" text-anchor="middle" font-size="10">4</text>
  <text x="275" y="285" text-anchor="middle" font-size="10">5</text>
  <text x="315" y="285" text-anchor="middle" font-size="10">6</text>
  <text x="355" y="285" text-anchor="middle" font-size="10">7</text>
  <text x="395" y="285" text-anchor="middle" font-size="10">8</text>
  <text x="435" y="285" text-anchor="middle" font-size="10">9</text>
</svg>

For non-integer $\lambda$, the distribution is unimodal with its mode at $\lfloor \lambda \rfloor$. [Inference] This follows from analyzing the ratio $P(X=k)/P(X=k-1) = \lambda/k$, which is greater than 1 for $k < \lambda$ and less than 1 for $k > \lambda$; this is a mathematical property derivable from the PMF formula, not an externally sourced claim.

### Moments

**Mean**

$$E[X] = \lambda$$

**Variance**

$$\text{Var}(X) = \lambda$$

**Skewness**

$$\text{Skew}(X) = \frac{1}{\sqrt{\lambda}}$$

**Excess Kurtosis**

$$\text{Excess Kurt}(X) = \frac{1}{\lambda}$$

[Inference] These formulas follow from standard derivations using the moment generating function $M_X(t) = e^{\lambda(e^t - 1)}$. The full derivation is not reproduced here; the results are consistent with standard probability theory conventions, though no specific external source is being cited in this response.

The property $E[X] = \text{Var}(X) = \lambda$ is often called **equidispersion** and is a defining characteristic distinguishing the Poisson distribution from distributions like the Negative Binomial, which allow variance to exceed the mean.

### The Poisson Process

The Poisson distribution arises naturally from a Poisson process, a model for events occurring continuously and independently at a constant average rate $\lambda$ per unit interval. Over an interval of length $t$, the number of events follows Poisson($\lambda t$).

Assumptions of a Poisson process [Inference — these are the standard defining conditions found in probability theory treatments of the Poisson process, not verified against one specific external source here]:

- Events occur independently of one another.
- The average rate $\lambda$ is constant over the interval considered.
- Two events cannot occur at exactly the same instant.

### Relationship to Other Distributions

- The Poisson distribution is the limiting case of the Binomial distribution as $n \to \infty$ and $p \to 0$, such that $np \to \lambda$ remains fixed. [Inference] This is a standard asymptotic result in probability theory; the precise regularity conditions of the limit are not fully derived in this response.
- As $\lambda \to \infty$, the Poisson distribution can be approximated by a Normal distribution: $X \approx \mathcal{N}(\lambda, \lambda)$. [Inference] This follows from the Central Limit Theorem applied to the Poisson distribution's representation as a sum, though the precise conditions for a "good" approximation vary by source and are not verified here.
- The Negative Binomial distribution can be derived as a Poisson distribution with a Gamma-distributed rate parameter (a Poisson-Gamma mixture), providing a way to model overdispersed count data that violates the Poisson's equidispersion assumption.
- The sum of independent Poisson random variables is itself Poisson-distributed, with rate equal to the sum of the individual rates. [Inference] This additive property follows from convolution of Poisson PMFs or from moment generating function properties; it is a standard derivation, not sourced from a specific external citation here.

### Maximum Likelihood Estimation

Given $n$ i.i.d. Poisson($\lambda$) observations $x_1, \dots, x_n$, the MLE for $\lambda$ is:

$$\hat{\lambda} = \frac{1}{n}\sum_{i=1}^{n} x_i = \bar{x}$$

[Inference] This follows from maximizing the log-likelihood $\ell(\lambda) = \sum x_i \log\lambda - n\lambda - \sum \log(x_i!)$ with respect to $\lambda$ and setting the derivative equal to zero. This is a standard calculus derivation, not an externally cited claim.

### Worked Example

A website receives an average of $\lambda = 3$ support tickets per hour, modeled as a Poisson process.

1. $E[X] = 3$, $\text{Var}(X) = 3$
2. Probability of exactly 5 tickets in one hour:

$$P(X=5) = \frac{3^5 e^{-3}}{5!} = \frac{243 \times 0.0498}{120} \approx 0.1008$$

3. Probability of zero tickets in one hour:

$$P(X=0) = \frac{3^0 e^{-3}}{0!} = e^{-3} \approx 0.0498$$

4. Probability of more than 5 tickets:

$$P(X > 5) = 1 - P(X \le 5) \approx 1 - 0.9161 = 0.0839$$

[Inference] These numeric results follow from direct substitution into the PMF formula and its cumulative sum; they assume the ticket-arrival process genuinely satisfies the Poisson process assumptions (constant rate, independence), which is a modeling assumption about this hypothetical scenario rather than a verified fact about actual website ticket traffic.

### Relevance to Machine Learning

**Poisson regression**
Poisson regression models a count-valued response variable using a log-linear relationship between the rate parameter and input features:

$$\log(\lambda) = w^T x + b$$

The model is typically trained by maximizing the Poisson log-likelihood. [Inference] This is a standard Generalized Linear Model construction described in statistical learning theory; specific software implementation details are [Unverified] and should be checked against current, version-specific documentation before being relied upon in code.

**Natural language processing**
[Speculation] The Poisson distribution may be referenced in some early or baseline topic-modeling and word-count approaches as a generative assumption for term frequencies, since document word counts are non-negative integers. I do not have a specific confirmed source verifying the extent of this application in current NLP literature, so this connection should be treated as a speculative possibility rather than an established, citable practice.

**Anomaly and rare-event detection**
[Speculation] Poisson-based models may be used in some anomaly-detection systems to flag counts (e.g., transactions per minute) that deviate significantly from an expected Poisson-modeled baseline rate. I do not have a specific confirmed source verifying the prevalence of this exact technique in current production systems, so this should be treated as a speculative possibility rather than a confirmed industry-standard practice.

**Queueing theory and simulation**
Poisson processes are foundational to queueing theory, which underlies simulation-based methods for modeling arrival times in systems such as network traffic or customer service. [Inference] This connection follows from the standard mathematical definition of a Poisson process described earlier in this document; it is a theoretical construction, not a claim about any specific real-world system's actual behavior.

### Common Pitfalls

- Applying the Poisson distribution to count data that is actually overdispersed (variance substantially exceeds the mean), which violates the equidispersion assumption and may bias inference.
- Assuming a constant rate $\lambda$ when the true underlying rate varies over time or space (non-homogeneous Poisson process).
- Confusing the rate parameter $\lambda$ with a probability; $\lambda$ can exceed 1, unlike the $p$ parameter in Bernoulli or Binomial distributions.

**Disclaimer on behavioral claims**: Statements in this document regarding how specific software libraries implement Poisson regression, parameter estimation, or related numerical routines are [Unverified] and should be confirmed against current, version-specific documentation before being relied upon in code. Behavior may vary across libraries and versions, and no consistency across implementations should be assumed. This entire document contains a mixture of standard mathematical derivations and [Inference]/[Speculation]-labeled claims about applications; where any part of a section is unverified, the surrounding claims in that section should be treated with the same degree of caution.

### Related Topics

- Binomial distribution (limiting relationship)
- Negative Binomial distribution (Poisson-Gamma mixture)
- Exponential distribution (inter-arrival times in a Poisson process)
- Poisson regression and Generalized Linear Models
- Overdispersion tests for count data