## Negative Binomial Distribution

### Definition

The Negative Binomial distribution models the number of trials (or failures) needed to achieve a fixed number of successes $r$ in a sequence of independent Bernoulli($p$) trials.

**Parameterization 1 — number of failures before the $r$-th success** ($k = 0, 1, 2, \dots$):

$$P(X = k) = \binom{k+r-1}{k} p^r (1-p)^k$$

**Parameterization 2 — number of trials until the $r$-th success** ($n = r, r+1, r+2, \dots$):

$$P(N = n) = \binom{n-1}{r-1} p^r (1-p)^{n-r}$$

[Unverified] Different textbooks and software libraries default to different parameterizations, and some further reparameterize using a mean and dispersion parameter instead of $p$ directly. The specific convention used in any given tool should be checked against its current documentation rather than assumed.

### Parameters

- $r$ — number of successes required (positive integer, or positive real in a generalized version)
- $p$ — probability of success on a single trial, $0 < p \le 1$
- Support: $k \in \{0, 1, 2, \dots\}$ (failures version) or $n \in \{r, r+1, \dots\}$ (trials version)

### Probability Mass Function Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" font-family="sans-serif">
  <text x="270" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Negative Binomial PMF, r = 3, p = 0.4 (svg_diagram)</text>
  <line x1="50" y1="270" x2="510" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="50" y1="270" x2="50" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="520" y="290" font-size="12" fill="#333">k (failures)</text>
  <text x="30" y="45" font-size="12" fill="#333">P(X=k)</text>

  <rect x="60" y="206" width="30" height="64" fill="#e76f51" />
  <rect x="100" y="150" width="30" height="120" fill="#e76f51" />
  <rect x="140" y="115" width="30" height="155" fill="#e76f51" />
  <rect x="180" y="95" width="30" height="175" fill="#e76f51" />
  <rect x="220" y="85" width="30" height="185" fill="#e76f51" />
  <rect x="260" y="90" width="30" height="180" fill="#e76f51" />
  <rect x="300" y="105" width="30" height="165" fill="#e76f51" />
  <rect x="340" y="130" width="30" height="140" fill="#e76f51" />
  <rect x="380" y="160" width="30" height="110" fill="#e76f51" />
  <rect x="420" y="195" width="30" height="75" fill="#e76f51" />

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

For $r > 1$, the distribution is unimodal with a rightward tail. [Inference] This shape follows from the combinatorial structure of the PMF, in which the binomial coefficient term grows before the geometrically decaying $(1-p)^k$ term dominates. This is a mathematical property derivable from the formula itself, not an externally sourced claim.

### Moments (Failures Parameterization)

**Mean**

$$E[X] = \frac{r(1-p)}{p}$$

**Variance**

$$\text{Var}(X) = \frac{r(1-p)}{p^2}$$

**Skewness**

$$\text{Skew}(X) = \frac{2-p}{\sqrt{r(1-p)}}$$

**Excess Kurtosis**

$$\text{Excess Kurt}(X) = \frac{6}{r} + \frac{p^2}{r(1-p)}$$

[Inference] These formulas follow from standard derivations using the moment generating function of the Negative Binomial distribution, or equivalently from summing $r$ i.i.d. Geometric($p$) random variables. The full derivation is not reproduced here; the results are consistent with standard probability theory conventions, though no specific external source is being cited in this response.

### Relationship to Other Distributions

- The Negative Binomial distribution is the sum of $r$ independent, identically distributed Geometric($p$) random variables (failures-before-success version). [Inference] This follows from the additive property of independent random variables that count trials toward a repeated event; it is a standard derivation in probability theory, not sourced from a specific external citation here.
- When $r = 1$, the Negative Binomial distribution reduces exactly to the Geometric distribution.
- As $r \to \infty$ and $p \to 1$ in a coordinated way such that $r(1-p)$ stays fixed at some constant $\lambda$, the Negative Binomial distribution converges to a Poisson distribution with mean $\lambda$. [Inference] This limiting relationship is a standard asymptotic result in probability theory; the precise regularity conditions of the limit are not derived in full here.
- The Negative Binomial distribution is often used as an overdispersed alternative to the Poisson distribution for modeling count data. [Inference] This usage follows from the fact that the Negative Binomial's variance formula includes an extra term beyond the mean, allowing variance to exceed the mean — unlike the Poisson distribution, where mean equals variance. This is a mathematical property of the formulas, not a claim about any particular dataset.

### Maximum Likelihood Estimation

For a fixed, known $r$, given $n$ i.i.d. Negative Binomial($r, p$) observations $x_1, \dots, x_n$, the MLE for $p$ is:

$$\hat{p} = \frac{nr}{nr + \sum_{i=1}^{n} x_i}$$

[Inference] This follows from maximizing the log-likelihood function with respect to $p$ while holding $r$ fixed. When $r$ is also unknown and must be estimated, closed-form solutions generally do not exist and numerical optimization methods are used instead. [Unverified] The specific optimization approach (e.g., Newton-Raphson, method of moments) used to estimate $r$ varies by software implementation and should be checked against current documentation before being relied upon in code.

### Worked Example

A call center agent needs $r = 4$ successful sales calls to hit a daily target. Each call independently results in a sale with probability $p = 0.25$.

1. $E[X] = 4(1-0.25)/0.25 = 4(0.75)/0.25 = 12$ expected failed calls before reaching 4 sales
2. Total expected calls: $E[X] + r = 12 + 4 = 16$
3. $\text{Var}(X) = 4(0.75)/0.25^2 = 3/0.0625 = 48$
4. $P(X = 10)$, i.e., exactly 10 failures before the 4th success:

$$P(X=10) = \binom{13}{10}(0.25)^4(0.75)^{10} \approx 0.0546$$

[Inference] This numeric result follows from direct substitution into the PMF formula; it assumes the trials are genuinely independent with constant success probability $p = 0.25$, which is a modeling assumption about this hypothetical scenario rather than a verified fact about actual call center performance.

### Relevance to Machine Learning

**Overdispersed count data modeling**
The Negative Binomial distribution is commonly used in regression settings (Negative Binomial regression) when count data exhibits overdispersion — variance exceeding the mean — a condition under which standard Poisson regression assumptions are violated. [Inference] This application follows from the mathematical property that the Negative Binomial variance formula exceeds its mean whenever $p < 1$; whether this is the appropriate modeling choice for any specific dataset depends on empirical diagnostics not evaluated here.

**Natural language processing**
[Speculation] The Negative Binomial distribution may be referenced in some word-frequency or topic-modeling contexts as an alternative to the Poisson distribution, since text data word counts sometimes exhibit overdispersion. I do not have a specific confirmed source verifying this application in current NLP literature, so this connection should be treated as a speculative possibility rather than an established, citable practice.

**Bayesian hierarchical models**
The Negative Binomial distribution arises naturally as a Poisson distribution with a Gamma-distributed rate parameter (a Poisson-Gamma mixture), which is a standard construction in Bayesian hierarchical modeling of count data. [Inference] This is a well-known mathematical derivation in Bayesian statistics; whether any specific software library implements this construction internally is not verified here.

**Reinforcement learning and reliability modeling**
[Speculation] The distribution's success-counting interpretation may be relevant to modeling the number of failed attempts before achieving a target number of successes in some reliability-engineering or RL exploration contexts. This is a plausible but unconfirmed application, and I do not have a specific citable source verifying its established use in this exact context.

### Common Pitfalls

- Confusing the two parameterizations (failures before $r$-th success vs. trials until $r$-th success), which shifts the support and formulas.
- Confusing the Negative Binomial distribution with the Binomial distribution — the Negative Binomial counts trials/failures until a fixed number of successes, while the Binomial counts successes in a fixed number of trials.
- Assuming Negative Binomial regression is always the correct remedy for overdispersion without first verifying that overdispersion is actually present in the data.

**Disclaimer on behavioral claims**: Statements in this document regarding how specific software libraries parameterize, default, or numerically estimate parameters of the Negative Binomial distribution are [Unverified] and should be confirmed against current, version-specific documentation before being relied upon in code. Behavior may vary across libraries and versions, and no consistency across implementations should be assumed.

### Related Topics

- Geometric distribution
- Poisson distribution and the Poisson-Gamma mixture
- Overdispersion diagnostics in count regression
- Gamma distribution
- Zero-inflated and hurdle count models