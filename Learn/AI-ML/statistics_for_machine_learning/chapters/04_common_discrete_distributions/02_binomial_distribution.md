## Binomial Distribution

### Definition

The Binomial distribution models the number of successes in $n$ independent Bernoulli trials, each with the same success probability $p$. If $X$ represents the count of successes:

$$P(X = k) = \binom{n}{k} p^k (1-p)^{n-k}, \quad k = 0, 1, \dots, n$$

where $\binom{n}{k} = \frac{n!}{k!(n-k)!}$ is the binomial coefficient counting the number of ways to arrange $k$ successes among $n$ trials.

### Parameters

- $n$ — number of trials (positive integer)
- $p$ — probability of success on a single trial, $0 \le p \le 1$
- Support: $k \in \{0, 1, 2, \dots, n\}$

### Probability Mass Function Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 340" font-family="sans-serif">
  <text x="280" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Binomial PMF, n = 10, p = 0.5 (svg_diagram)</text>
  <line x1="50" y1="290" x2="530" y2="290" stroke="#333" stroke-width="1.5" />
  <line x1="50" y1="290" x2="50" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="540" y="310" font-size="12" fill="#333">k</text>
  <text x="30" y="45" font-size="12" fill="#333">P(X=k)</text>

  <rect x="60" y="285" width="30" height="5" fill="#1d3557" />
  <rect x="100" y="270" width="30" height="20" fill="#1d3557" />
  <rect x="140" y="230" width="30" height="60" fill="#1d3557" />
  <rect x="180" y="170" width="30" height="120" fill="#1d3557" />
  <rect x="220" y="110" width="30" height="180" fill="#1d3557" />
  <rect x="260" y="90" width="30" height="200" fill="#1d3557" />
  <rect x="300" y="110" width="30" height="180" fill="#1d3557" />
  <rect x="340" y="170" width="30" height="120" fill="#1d3557" />
  <rect x="380" y="230" width="30" height="60" fill="#1d3557" />
  <rect x="420" y="270" width="30" height="20" fill="#1d3557" />
  <rect x="460" y="285" width="30" height="5" fill="#1d3557" />

  <text x="75" y="303" text-anchor="middle" font-size="10">0</text>
  <text x="115" y="303" text-anchor="middle" font-size="10">1</text>
  <text x="155" y="303" text-anchor="middle" font-size="10">2</text>
  <text x="195" y="303" text-anchor="middle" font-size="10">3</text>
  <text x="235" y="303" text-anchor="middle" font-size="10">4</text>
  <text x="275" y="303" text-anchor="middle" font-size="10">5</text>
  <text x="315" y="303" text-anchor="middle" font-size="10">6</text>
  <text x="355" y="303" text-anchor="middle" font-size="10">7</text>
  <text x="395" y="303" text-anchor="middle" font-size="10">8</text>
  <text x="435" y="303" text-anchor="middle" font-size="10">9</text>
  <text x="475" y="303" text-anchor="middle" font-size="10">10</text>
</svg>

The distribution is symmetric when $p = 0.5$, right-skewed when $p < 0.5$, and left-skewed when $p > 0.5$. [Inference] This follows from the algebraic structure of the PMF and the behavior of the binomial coefficient; it is a mathematical property derivable from the formula, not an externally cited claim.

### Moments

**Mean**

$$E[X] = np$$

**Variance**

$$\text{Var}(X) = np(1-p)$$

**Standard deviation**

$$\sigma_X = \sqrt{np(1-p)}$$

**Skewness**

$$\text{Skew}(X) = \frac{1-2p}{\sqrt{np(1-p)}}$$

**Excess Kurtosis**

$$\text{Excess Kurt}(X) = \frac{1-6p(1-p)}{np(1-p)}$$

[Inference] These moment formulas follow from the fact that a Binomial($n,p$) random variable is the sum of $n$ independent Bernoulli($p$) random variables, combined with linearity of expectation and the additivity of variance under independence. This is a standard derivation, not a claim sourced from an external citation in this response.

### Relationship to the Bernoulli Distribution

If $X_1, \dots, X_n$ are independent and identically distributed Bernoulli($p$) random variables, then:

$$X = \sum_{i=1}^{n} X_i \sim \text{Binomial}(n, p)$$

This decomposition is the basis for deriving the Binomial mean and variance directly from the simpler Bernoulli moments. [Inference] This is a standard result following from properties of sums of independent random variables; it is not being cited from a specific external source here.

### Normal and Poisson Approximations

**Normal approximation**
For large $n$, the Binomial distribution can be approximated by a Normal distribution:

$$X \approx \mathcal{N}(np, \, np(1-p))$$

A commonly cited rule of thumb requires $np \ge 5$ and $n(1-p) \ge 5$ for the approximation to be reasonable. [Unverified] The specific threshold values vary across textbooks and sources; the "5" cutoff is one common convention, but I cannot verify a single universally agreed-upon threshold without a specific citation.

**Poisson approximation**
When $n$ is large and $p$ is small such that $\lambda = np$ remains moderate, the Binomial distribution can be approximated by a Poisson distribution with parameter $\lambda$. [Inference] This approximation is a standard asymptotic result in probability theory; the precise conditions under which it is considered "good" vary by source and are not being verified here.

### Maximum Likelihood Estimation

Given an observed count $k$ successes out of $n$ known trials, the MLE for $p$ is:

$$\hat{p} = \frac{k}{n}$$

[Inference] This follows from maximizing the log-likelihood $\ell(p) = k \log p + (n-k)\log(1-p)$ with respect to $p$. This is a standard calculus derivation, not an externally sourced claim.

### Worked Example

A coin with unknown fairness is flipped $n = 20$ times, landing heads $k = 14$ times.

1. MLE estimate: $\hat{p} = 14/20 = 0.7$
2. Under the null hypothesis $p = 0.5$ (fair coin), expected heads: $E[X] = 20 \times 0.5 = 10$
3. Variance under null: $\text{Var}(X) = 20 \times 0.5 \times 0.5 = 5$
4. Standard deviation under null: $\sigma = \sqrt{5} \approx 2.236$
5. Observed value is $(14 - 10)/2.236 \approx 1.79$ standard deviations above the expected mean

This standardized distance can be used as input to a hypothesis test (e.g., an exact Binomial test or a normal-approximation z-test) to assess whether the coin's fairness assumption is plausible. [Inference] The specific conclusion of any such test (e.g., statistical significance at a given threshold) depends on the chosen significance level and test procedure, which is not specified or evaluated here.

### Relevance to Machine Learning

**Binary outcome aggregation**
The Binomial distribution is used to model aggregate counts of binary events, such as total conversions in an A/B test out of a fixed number of trials. [Inference] This is a common modeling convention in applied statistics; whether it is the specific method used in any given production A/B testing system is not verified here.

**Hypothesis testing and confidence intervals**
Binomial-based tests and confidence intervals (e.g., Wilson score interval, Clopper-Pearson interval) are used to quantify uncertainty around estimated proportions, such as classifier accuracy on a test set. [Unverified] Claims about which interval method is most appropriate depend on sample size and context; a general recommendation is not being asserted here without further specification.

**Relation to logistic regression**
Binomial regression (a generalization of logistic regression) models grouped binary outcome counts using a binomial likelihood combined with a link function such as the logit. [Inference] This is a standard generalized linear model construction; specific software implementation details are not verified here.

**Model evaluation under repeated trials**
When evaluating a classifier over $n$ independent test examples, the number of correct predictions can be modeled as Binomial($n, p$) where $p$ is the true accuracy. [Inference] This modeling assumption relies on the test examples being independent and identically distributed, which may not hold in all real-world evaluation settings; this is a reasoned modeling assumption, not a verified property of any specific dataset.

### Common Pitfalls

- Applying the Normal approximation when $np$ or $n(1-p)$ is small, leading to inaccurate probability estimates.
- Confusing $n$ (number of trials) with $k$ (number of observed successes) in the PMF formula.
- Assuming independence between trials when real-world processes may exhibit correlation, which violates the Binomial model's core assumption.

### Related Topics

- Bernoulli distribution
- Poisson distribution
- Normal approximation to the Binomial
- Hypothesis testing for proportions
- Beta-Binomial distribution as a Bayesian extension