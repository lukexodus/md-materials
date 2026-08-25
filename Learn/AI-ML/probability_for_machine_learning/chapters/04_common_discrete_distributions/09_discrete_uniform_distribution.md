## Discrete Uniform Distribution

### Definition

A discrete random variable $X$ follows a discrete uniform distribution if it takes on a finite number of values, each with equal probability. If $X$ can take values $\{x_1, x_2, \ldots, x_n\}$, then:

$$P(X = x_i) = \frac{1}{n} \quad \text{for } i = 1, 2, \ldots, n$$

The defining property is that no outcome is favored over another — every value in the support has identical probability mass.

### Common Parameterization

The most frequently used form takes integer values from $a$ to $b$ inclusive, where $n = b - a + 1$:

$$P(X = k) = \frac{1}{b - a + 1}, \quad k \in \{a, a+1, \ldots, b\}$$

A common special case is $X \in \{1, 2, \ldots, n\}$, such as a fair die roll where $n = 6$.

### Probability Mass Function

$$f(k) = \begin{cases} \dfrac{1}{n} & k \in \{x_1, \ldots, x_n\} \\ 0 & \text{otherwise} \end{cases}$$

### Cumulative Distribution Function

For the integer range case $\{a, a+1, \ldots, b\}$:

$$F(k) = P(X \le k) = \frac{\lfloor k \rfloor - a + 1}{b - a + 1}, \quad a \le k \le b$$

### Mean and Variance

For the integer range $\{a, a+1, \ldots, b\}$:

$$E[X] = \frac{a + b}{2}$$

$$\text{Var}(X) = \frac{(b - a + 1)^2 - 1}{12}$$

**Key Points**
- The mean is simply the midpoint of the range.
- Variance grows quadratically with the range size — a wider uniform distribution has proportionally higher spread.
- These closed-form expressions apply specifically to the consecutive-integer parameterization; a general discrete uniform over arbitrary values requires computing mean and variance directly from the value set.

### Entropy

The discrete uniform distribution has the maximum entropy among all distributions over a fixed finite support, since no outcome is more predictable than another:

$$H(X) = -\sum_{i=1}^{n} \frac{1}{n} \log \frac{1}{n} = \log n$$

This property makes it the natural "no prior information" baseline in information-theoretic contexts.

### Relevance to Machine Learning

- **Weight initialization**: Some neural network initialization schemes sample from a discrete or continuous uniform distribution before more specialized schemes (e.g., Xavier, He) are applied. [Inference] The discrete case specifically arises less often than continuous uniform initialization in practice.
- **Random sampling and shuffling**: Uniform random selection of indices (e.g., shuffling a dataset, selecting mini-batches, bootstrap resampling) relies on discrete uniform sampling over index sets.
- **Baseline/null models**: A classifier that assigns equal probability to all classes represents a discrete uniform distribution, often used as a naive baseline for comparison against trained models.
- **Categorical feature encoding**: When no prior knowledge favors one category over another, a discrete uniform prior is a common default assumption before observing data — this connects to uniform (uninformative) priors in Bayesian ML settings.
- **Reinforcement learning**: Epsilon-greedy exploration strategies often use a discrete uniform distribution to select among available actions during the exploratory phase.

### Example

A six-sided fair die: $X \in \{1, 2, 3, 4, 5, 6\}$, $P(X = k) = \frac{1}{6}$ for each $k$.

$$E[X] = \frac{1 + 6}{2} = 3.5, \quad \text{Var}(X) = \frac{6^2 - 1}{12} = \frac{35}{12} \approx 2.9167$$

### Visualization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360">
  <text x="320" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Discrete Uniform PMF: Fair Die (svg_diagram)</text>

  <line x1="70" y1="300" x2="600" y2="300" stroke="#333" stroke-width="2" />
  <line x1="70" y1="300" x2="70" y2="60" stroke="#333" stroke-width="2" />

  <text x="335" y="335" text-anchor="middle" font-size="14" fill="#333">Outcome (k)</text>
  <text x="30" y="180" text-anchor="middle" font-size="14" fill="#333" transform="rotate(-90 30 180)">P(X = k)</text>

  <line x1="65" y1="260" x2="600" y2="260" stroke="#ddd" stroke-width="1" />
  <text x="55" y="264" text-anchor="end" font-size="11" fill="#666">1/6</text>

  <g fill="#4C72B0">
    <rect x="100" y="260" width="60" height="40" />
    <rect x="190" y="260" width="60" height="40" />
    <rect x="280" y="260" width="60" height="40" />
    <rect x="370" y="260" width="60" height="40" />
    <rect x="460" y="260" width="60" height="40" />
    <rect x="550" y="260" width="40" height="40" />
  </g>

  <g font-size="13" fill="#1a1a1a" text-anchor="middle">
    <text x="130" y="318">1</text>
    <text x="220" y="318">2</text>
    <text x="310" y="318">3</text>
    <text x="400" y="318">4</text>
    <text x="490" y="318">5</text>
    <text x="570" y="318">6</text>
  </g>

  <text x="335" y="60" text-anchor="middle" font-size="12" fill="#666">All bars equal height = equal probability</text>
</svg>

### Sampling Illustration (Process Flow)

```mermaid
flowchart LR
    A["Define support set n values"] --> B["Assign equal probability 1/n to each"]
    B --> C["Draw uniform random number in 0,1"]
    C --> D["Map to corresponding discrete outcome via CDF"]
    D --> E["Sampled value returned"]
```

**Next Steps**
- Bernoulli distribution
- Binomial distribution
- Categorical distribution (generalization of Bernoulli to multiple discrete outcomes, contrasted with uniform)
- Connection between discrete uniform priors and Bayesian uninformative priors

[Unverified] — This response includes standard statistical formulas that follow directly from the definition of the discrete uniform distribution; these are mathematically derivable and not sourced from a specific citable document. Machine learning application claims are labeled [Inference] where they describe general practice rather than confirmed, sourced facts. No claims of guaranteed behavior are made.