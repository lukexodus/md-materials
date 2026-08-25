## Discrete Uniform Distribution (svg_diagram)

### Definition

The discrete uniform distribution describes a random variable that takes one of a finite number of equally likely values. Each outcome in the sample space has the same probability of occurring.

A random variable $X$ follows a discrete uniform distribution over the integers $\{a, a+1, \dots, b\}$ if every value in this range has equal probability of occurring.

### Probability Mass Function

$$P(X = x) = \frac{1}{n} \quad \text{for } x \in \{a, a+1, \dots, b\}$$

where $n = b - a + 1$ is the number of possible outcomes.

For the general case where the support is an arbitrary finite set $\{x_1, x_2, \dots, x_n\}$:

$$P(X = x_i) = \frac{1}{n} \quad \text{for } i = 1, 2, \dots, n$$

### Parameters

- $a$: lower bound (minimum value)
- $b$: upper bound (maximum value)
- $n = b - a + 1$: number of possible outcomes

### Key Points

- Every outcome has identical probability $1/n$.
- The distribution is symmetric around its mean when the support is a contiguous integer range.
- It is the simplest discrete probability distribution in terms of parameterization.
- A fair die roll and a fair coin flip are both instances of discrete uniform distributions (with $n=6$ and $n=2$ respectively).

### Mean and Variance

For $X$ uniform on $\{a, a+1, \dots, b\}$:

$$E[X] = \frac{a+b}{2}$$

$$\text{Var}(X) = \frac{(b-a+1)^2 - 1}{12} = \frac{n^2 - 1}{12}$$

### Derivation Note

$$E[X] = \frac{a+b}{2}$$

This follows from the arithmetic series sum of integers from $a$ to $b$, divided by $n$ terms. [Inference] This is a standard algebraic result from summation formulas; it is not derived step-by-step in this response.

### Example

Consider a fair six-sided die roll, where $X \in \{1, 2, 3, 4, 5, 6\}$.

$$P(X = x) = \frac{1}{6} \quad \text{for each } x \in \{1,2,3,4,5,6\}$$

$$E[X] = \frac{1+6}{2} = 3.5$$

$$\text{Var}(X) = \frac{6^2 - 1}{12} = \frac{35}{12} \approx 2.9167$$

[Inference] These values follow directly from the formulas above given the stated parameters; they have not been separately verified through simulation in this response.

### Diagram: PMF Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 320" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Discrete Uniform PMF, n=6 (svg_diagram)</text>

  <line x1="60" y1="260" x2="560" y2="260" stroke="#333" stroke-width="2" />
  <line x1="60" y1="260" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="30" y="265" font-size="11" fill="#333">0</text>
  <text x="10" y="165" font-size="11" fill="#333">1/6</text>
  <line x1="55" y1="160" x2="60" y2="160" stroke="#333" stroke-width="1" />

  <text x="300" y="295" text-anchor="middle" font-size="12" fill="#333">Outcome (x)</text>

  <rect x="90" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="120" y="275" text-anchor="middle" font-size="12" fill="#222">1</text>

  <rect x="170" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="200" y="275" text-anchor="middle" font-size="12" fill="#222">2</text>

  <rect x="250" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="280" y="275" text-anchor="middle" font-size="12" fill="#222">3</text>

  <rect x="330" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="360" y="275" text-anchor="middle" font-size="12" fill="#222">4</text>

  <rect x="410" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="440" y="275" text-anchor="middle" font-size="12" fill="#222">5</text>

  <rect x="490" y="160" width="60" height="100" fill="#4a76d4" />
  <text x="520" y="275" text-anchor="middle" font-size="12" fill="#222">6</text>

  <text x="300" y="50" text-anchor="middle" font-size="11" fill="#666">All bars equal height: P(x) = 1/6</text>
</svg>

### Relationship to Continuous Uniform Distribution

The discrete uniform distribution is the finite-support, integer-valued analogue of the continuous uniform distribution. Where the continuous uniform distribution assigns equal probability density across an interval $[a,b]$, the discrete uniform distribution assigns equal probability mass to a finite, countable set of values.

### Applications in Machine Learning

- **Random initialization**: Some weight or index initialization schemes sample from a discrete uniform distribution, such as randomly selecting an index from a dataset. [Unverified] Specific initialization schemes vary by library and implementation; this response does not confirm which frameworks use discrete uniform sampling by default.
- **Random sampling without informative priors**: When no prior information favors one category over another, a discrete uniform distribution is sometimes used as a non-informative baseline or null model.
- **Cross-validation fold assignment**: Randomly assigning data points to $k$ folds can be modeled as sampling from a discrete uniform distribution over fold indices.
- **Bootstrap resampling**: Selecting indices with equal probability during bootstrap sampling relies on discrete uniform sampling over the dataset indices.
- **Baseline comparison models**: A classifier that predicts classes uniformly at random is often used as a naive baseline to compare against trained models.

### Entropy

The discrete uniform distribution has the maximum entropy among all discrete distributions with a fixed, finite support size $n$, since no outcome is more likely than another.

$$H(X) = -\sum_{i=1}^{n} \frac{1}{n} \log\left(\frac{1}{n}\right) = \log(n)$$

[Inference] This maximum-entropy property follows from the general information-theoretic result that entropy is maximized under a uniform distribution given a fixed finite support; the full proof is not reproduced in this response.

### Common Pitfalls

- **Assuming uniformity without justification**: Treating a variable as discrete uniform when the underlying process is not equally likely across outcomes can lead to biased model assumptions. [Inference] based on general statistical modeling principles regarding distributional assumptions and bias.
- **Confusing discrete and continuous uniform**: Applying continuous uniform formulas (e.g., density functions) to a discrete uniform variable produces incorrect results, since discrete variables require probability mass functions, not densities.
- **Off-by-one errors in range**: Miscounting $n = b - a + 1$ (versus $b - a$) is a common implementation error when coding discrete uniform sampling.

### Related Topics

- Continuous uniform distribution
- Bernoulli distribution
- Categorical distribution
- Entropy and information theory
- Random sampling methods (bootstrap, cross-validation)
- Maximum entropy principle