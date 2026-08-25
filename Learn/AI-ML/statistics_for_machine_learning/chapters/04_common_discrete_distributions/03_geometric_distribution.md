## Geometric Distribution

### Definition

The Geometric distribution models the number of independent Bernoulli($p$) trials required to obtain the first success. Two common parameterizations exist, distinguished by their support.

**Parameterization 1 — number of trials until first success** ($k = 1, 2, 3, \dots$):

$$P(X = k) = (1-p)^{k-1} p$$

**Parameterization 2 — number of failures before first success** ($k = 0, 1, 2, \dots$):

$$P(X = k) = (1-p)^{k} p$$

[Unverified] Different textbooks and software libraries default to different parameterizations; the specific convention used in any given tool should be checked against its current documentation rather than assumed.

### Parameters

- $p$ — probability of success on a single trial, $0 < p \le 1$
- Support: $k \in \{1, 2, 3, \dots\}$ (trials version) or $k \in \{0, 1, 2, \dots\}$ (failures version)

### Probability Mass Function Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" font-family="sans-serif">
  <text x="270" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Geometric PMF, p = 0.4 (svg_diagram)</text>
  <line x1="50" y1="270" x2="510" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="50" y1="270" x2="50" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="520" y="290" font-size="12" fill="#333">k (trials)</text>
  <text x="30" y="45" font-size="12" fill="#333">P(X=k)</text>

  <rect x="65" y="82" width="35" height="188" fill="#2a9d8f" />
  <rect x="110" y="145" width="35" height="125" fill="#2a9d8f" />
  <rect x="155" y="182" width="35" height="88" fill="#2a9d8f" />
  <rect x="200" y="206" width="35" height="64" fill="#2a9d8f" />
  <rect x="245" y="221" width="35" height="49" fill="#2a9d8f" />
  <rect x="290" y="232" width="35" height="38" fill="#2a9d8f" />
  <rect x="335" y="239" width="35" height="31" fill="#2a9d8f" />
  <rect x="380" y="244" width="35" height="26" fill="#2a9d8f" />

  <text x="82" y="285" text-anchor="middle" font-size="10">1</text>
  <text x="127" y="285" text-anchor="middle" font-size="10">2</text>
  <text x="172" y="285" text-anchor="middle" font-size="10">3</text>
  <text x="217" y="285" text-anchor="middle" font-size="10">4</text>
  <text x="262" y="285" text-anchor="middle" font-size="10">5</text>
  <text x="307" y="285" text-anchor="middle" font-size="10">6</text>
  <text x="352" y="285" text-anchor="middle" font-size="10">7</text>
  <text x="397" y="285" text-anchor="middle" font-size="10">8</text>
</svg>

The PMF is strictly decreasing in $k$, forming a monotonically declining shape regardless of the value of $p$. [Inference] This follows algebraically from the formula $(1-p)^{k-1}p$, since $0 < 1-p < 1$ causes each successive term to shrink; this is a mathematical property derivable from the definition, not an externally sourced claim.

### Moments (Trials Parameterization)

**Mean**

$$E[X] = \frac{1}{p}$$

**Variance**

$$\text{Var}(X) = \frac{1-p}{p^2}$$

**Skewness**

$$\text{Skew}(X) = \frac{2-p}{\sqrt{1-p}}$$

**Excess Kurtosis**

$$\text{Excess Kurt}(X) = 6 + \frac{p^2}{1-p}$$

[Inference] These formulas follow from standard derivations using the probability generating function or moment generating function of the geometric distribution. The derivation itself is not reproduced here in full; the results are consistent with standard probability theory references, though no specific external source is being cited in this response.

### Memoryless Property

The Geometric distribution (on the trials parameterization) is the only discrete distribution with the memoryless property:

$$P(X > m+n \mid X > m) = P(X > n), \quad \forall m, n \ge 0$$

This means that, conditional on no success having occurred in the first $m$ trials, the distribution of additional trials needed is identical to the distribution starting fresh. [Inference] This is a well-known theoretical property provable directly from the geometric PMF and the definition of conditional probability; it is a mathematical result, not an empirical claim about any specific dataset.

### Relationship to Other Distributions

- The Geometric distribution is a special case of the Negative Binomial distribution, corresponding to the count of trials until the 1st success (Negative Binomial generalizes this to the $r$-th success). [Inference] This relationship follows from the definitional structure of both distributions; it is a standard result in probability theory, not sourced from a specific external citation here.
- The Geometric distribution is the discrete analogue of the continuous Exponential distribution, sharing the memoryless property. [Inference] This analogy is commonly drawn in probability theory texts due to the shared memoryless characteristic, though the full formal correspondence is not derived in this response.

### Maximum Likelihood Estimation

Given $n$ i.i.d. Geometric($p$) observations $x_1, \dots, x_n$ (trials parameterization), the MLE for $p$ is:

$$\hat{p} = \frac{n}{\sum_{i=1}^{n} x_i} = \frac{1}{\bar{x}}$$

[Inference] This follows from maximizing the log-likelihood $\ell(p) = n\log p + \left(\sum x_i - n\right)\log(1-p)$ with respect to $p$ and setting the derivative equal to zero. This is a standard calculus derivation, not an externally cited claim.

### Worked Example

A sales representative closes a deal with probability $p = 0.2$ on each independent client call. Let $X$ denote the number of calls until the first successful sale.

1. $E[X] = 1/0.2 = 5$ calls expected until first success
2. $\text{Var}(X) = (1-0.2)/0.2^2 = 0.8/0.04 = 20$
3. $P(X = 3) = (0.8)^2 (0.2) = 0.128$ — probability the first sale occurs exactly on the 3rd call
4. $P(X > 5) = (1-p)^5 = (0.8)^5 \approx 0.328$ — probability more than 5 calls are needed

By the memoryless property, if no sale has occurred in the first 5 calls, the expected number of additional calls needed remains $1/p = 5$. [Inference] This conclusion follows directly from the memoryless property proven for the geometric distribution; it assumes the underlying process genuinely satisfies the i.i.d. Bernoulli trial assumption, which is a modeling assumption about this scenario rather than a verified fact about actual sales behavior.

### Relevance to Machine Learning

**Modeling waiting times and rare events**
The Geometric distribution is used to model the number of attempts until a rare event occurs, such as the number of samples drawn before encountering a minority-class instance in an imbalanced dataset. [Inference] This is a reasoned modeling application consistent with the distribution's definition; whether it is the specific method used in any given imbalanced-learning pipeline is not verified here.

**Reinforcement learning**
In some reinforcement learning formulations, the Geometric distribution arises when modeling the number of time steps until an episode terminates under a constant per-step termination probability. [Unverified] The specific way termination is modeled varies substantially across RL algorithms and environments; this general connection should not be assumed to apply to any particular implementation without checking its documentation.

**Negative Binomial regression connection**
Because the Geometric distribution is a special case of the Negative Binomial distribution, understanding it supports understanding count-based regression models used for overdispersed count data. [Inference] This connection follows from the mathematical relationship between the two distributions described earlier in this document; it does not constitute a claim about the performance of any specific regression implementation.

**Random sampling and hashing analysis**
[Speculation] The geometric distribution may be referenced in some analyses of hash collision behavior or randomized algorithm run-times, since such analyses sometimes involve counting trials until a specific random event occurs. This connection is plausible given the distribution's definition, but I do not have a specific confirmed source verifying its use in this exact context, so this should be treated as a speculative possibility rather than an established application.

### Common Pitfalls

- Confusing the two parameterizations (trials until success vs. failures before success), which changes the support, mean, and formulas.
- Applying the memoryless property to real-world processes that may not actually satisfy the i.i.d. Bernoulli trial assumption.
- Confusing the Geometric distribution with the Negative Binomial distribution when modeling counts of multiple successes rather than a single success.

**Disclaimer on behavioral claims**: Statements in this document regarding how specific software libraries parameterize or implement the Geometric distribution are [Unverified] and should be confirmed against current, version-specific documentation before being relied upon in code. Behavior may vary across libraries and versions, and no guarantee is made regarding consistency.

### Related Topics

- Negative Binomial distribution
- Exponential distribution (continuous analogue)
- Memorylessness in probability distributions
- Poisson process and waiting-time models
- Survival analysis and hazard functions