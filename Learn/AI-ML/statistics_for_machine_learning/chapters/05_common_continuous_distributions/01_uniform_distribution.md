## Uniform Distribution (svg_diagram)

### Definition

The (continuous) uniform distribution describes a random variable whose values are equally likely across every point within a fixed interval $[a, b]$. Unlike the discrete uniform distribution, which assigns equal probability mass to a finite set of values, the continuous uniform distribution assigns equal probability density across a continuous range.

A random variable $X$ follows a continuous uniform distribution on $[a, b]$, denoted $X \sim \text{Uniform}(a, b)$, if its density is constant over that interval and zero elsewhere.

### Probability Density Function

$$f(x) = \begin{cases} \dfrac{1}{b-a} & a \le x \le b \\ 0 & \text{otherwise} \end{cases}$$

### Cumulative Distribution Function

$$F(x) = \begin{cases} 0 & x < a \\ \dfrac{x-a}{b-a} & a \le x \le b \\ 1 & x > b \end{cases}$$

### Parameters

- $a$: lower bound of the interval
- $b$: upper bound of the interval, with $b > a$

### Key Points

- The density is constant, meaning no value within $[a,b]$ is more likely than another.
- The probability of $X$ falling in any sub-interval depends only on the length of that sub-interval, not its location within $[a,b]$.
- Since $X$ is continuous, $P(X = x) = 0$ for any single point $x$; probabilities are only meaningful over intervals.
- The uniform distribution is often used to model complete uncertainty about a value within known bounds. [Inference] This use case follows from the distribution's constant-density property, which encodes no preference for any sub-region; whether it is the "best" choice for a given modeling problem depends on context not addressed here.

### Mean and Variance

$$E[X] = \frac{a+b}{2}$$

$$\text{Var}(X) = \frac{(b-a)^2}{12}$$

[Inference] These are standard results derived via direct integration of the density function; the integration steps are not reproduced in this response.

### Example

Suppose $X \sim \text{Uniform}(0, 10)$, representing a value assumed equally likely anywhere between 0 and 10.

$$f(x) = \frac{1}{10-0} = 0.1 \quad \text{for } 0 \le x \le 10$$

$$E[X] = \frac{0+10}{2} = 5$$

$$\text{Var}(X) = \frac{(10-0)^2}{12} = \frac{100}{12} \approx 8.333$$

To find $P(3 \le X \le 7)$:

$$P(3 \le X \le 7) = F(7) - F(3) = \frac{7-0}{10} - \frac{3-0}{10} = 0.7 - 0.3 = 0.4$$

[Inference] These calculations follow directly from the formulas above given the stated parameters; they have not been separately verified through simulation in this response.

### Diagram: PDF Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Uniform(a,b) Density (svg_diagram)</text>

  <line x1="60" y1="240" x2="560" y2="240" stroke="#333" stroke-width="2" />
  <line x1="60" y1="240" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="300" y="270" text-anchor="middle" font-size="12" fill="#333">x</text>
  <text x="20" y="150" font-size="11" fill="#333">1/(b-a)</text>

  <line x1="150" y1="140" x2="450" y2="140" stroke="#4a76d4" stroke-width="3" />
  <line x1="150" y1="140" x2="150" y2="240" stroke="#4a76d4" stroke-width="2" stroke-dasharray="4,3" />
  <line x1="450" y1="140" x2="450" y2="240" stroke="#4a76d4" stroke-width="2" stroke-dasharray="4,3" />

  <line x1="60" y1="140" x2="150" y2="140" stroke="#999" stroke-width="1" stroke-dasharray="2,2" />

  <rect x="150" y="140" width="300" height="100" fill="#4a76d4" fill-opacity="0.15" />

  <text x="150" y="255" text-anchor="middle" font-size="12" fill="#222">a</text>
  <text x="450" y="255" text-anchor="middle" font-size="12" fill="#222">b</text>

  <text x="300" y="130" text-anchor="middle" font-size="11" fill="#666">Area under curve = 1</text>
</svg>

### Relationship to Other Distributions

- **Discrete uniform distribution**: The discrete analogue, defined over a finite set of integers rather than a continuous interval.
- **Beta distribution**: The $\text{Uniform}(0,1)$ distribution is a special case of the Beta distribution with parameters $\alpha = 1, \beta = 1$.
- **Exponential distribution**: Applying the inverse CDF of the exponential distribution to a $\text{Uniform}(0,1)$ random variable produces a random variable following the exponential distribution — a technique known as inverse transform sampling.

### Applications in Machine Learning

- **Random weight initialization**: Some neural network weight initialization schemes (e.g., certain variants of Xavier/Glorot initialization) draw values from a uniform distribution over a bounded range. [Unverified] The exact initialization scheme and default distribution vary by framework and version, and this response does not confirm specific library defaults.
- **Inverse transform sampling**: The uniform distribution is foundational to generating samples from other distributions, since most random number generators produce $\text{Uniform}(0,1)$ values as a base, which are then transformed.
- **Hyperparameter search**: Random search over hyperparameters sometimes samples continuous hyperparameters (e.g., learning rate on a log scale) from a uniform distribution over a specified range.
- **Dropout and stochastic regularization**: Certain stochastic regularization techniques rely on uniform random draws to decide which units or connections to include per iteration. [Unverified] Specific implementation details vary by framework and are not confirmed here.
- **Data augmentation**: Random transformations (e.g., rotation angle, crop position) in image augmentation pipelines are frequently sampled from uniform distributions over a defined parameter range.

### Standard Uniform Distribution

The special case $\text{Uniform}(0,1)$ is called the standard uniform distribution. It plays a central role in simulation because most pseudo-random number generators are designed to approximate draws from this distribution, from which other distributions can be derived via transformation methods.

### Common Pitfalls

- **Confusing discrete and continuous uniform**: Using PMF-style point probabilities (e.g., $P(X=x)$) for a continuous uniform variable is incorrect, since point probabilities are zero for continuous distributions.
- **Incorrect bounds handling**: Errors in whether endpoints $a$ and $b$ are inclusive or exclusive can lead to subtle bugs in sampling code, though for continuous distributions this has no effect on probability calculations since individual points have zero probability.
- **Assuming uniformity without justification**: Applying a uniform prior or model assumption when the true underlying process is not uniform can bias downstream results. [Inference] based on general statistical modeling principles regarding assumption-model mismatch.

### Related Topics

- Discrete uniform distribution
- Beta distribution
- Inverse transform sampling
- Random number generation
- Hyperparameter search methods (random search, grid search)
- Data augmentation techniques

---

[Unverified] This response contains statements labeled [Inference] and [Unverified] as specified; portions describing standard mathematical derivations (mean, variance, CDF) are established results from probability theory but their derivation steps were not independently re-verified line-by-line in this response.