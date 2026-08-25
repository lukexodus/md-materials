## Bernoulli Distribution

### Definition

The Bernoulli distribution models a single trial with exactly two possible outcomes, typically labeled "success" ($X = 1$) and "failure" ($X = 0$). It is parameterized by a single value $p \in [0, 1]$, the probability of success.

The probability mass function (PMF) is:

$$P(X = x) = p^x (1-p)^{1-x}, \quad x \in \{0, 1\}$$

Equivalently:

$$P(X = 1) = p, \qquad P(X = 0) = 1 - p$$

### Key Points

- The Bernoulli distribution is the simplest discrete probability distribution, describing a single binary trial.
- It is the building block for the Binomial distribution, which sums $n$ independent Bernoulli trials.
- The parameter $p$ fully determines the distribution.

### Moments

**Expectation:**

$$E[X] = \sum_{x \in \{0,1\}} x \cdot P(X = x) = 0 \cdot (1-p) + 1 \cdot p = p$$

**Variance:**

$$\text{Var}(X) = E[X^2] - (E[X])^2$$

Since $X^2 = X$ for $X \in \{0, 1\}$ (as $0^2 = 0$ and $1^2 = 1$), $E[X^2] = E[X] = p$, so:

$$\text{Var}(X) = p - p^2 = p(1-p)$$

**Standard deviation:**

$$\sigma_X = \sqrt{p(1-p)}$$

These moment formulas are [Verified] standard results derivable directly from the PMF definition above, following from basic expectation and variance calculations.

### Moment Generating Function

The moment generating function (MGF) is:

$$M_X(t) = E[e^{tX}] = (1-p) + p \cdot e^t$$

This can be differentiated to recover the moments: $M_X'(0) = E[X] = p$.

This derivation is [Verified] a standard result obtainable by direct computation from the definition of the MGF applied to the Bernoulli PMF.

### Worked Example

Consider a spam classifier where $X = 1$ if an email is classified as spam and $X = 0$ otherwise, with $P(X = 1) = 0.3$.

$$E[X] = 0.3$$

$$\text{Var}(X) = 0.3 \times 0.7 = 0.21$$

$$\sigma_X = \sqrt{0.21} \approx 0.458$$

This is [Inference] a correct application of the formulas above given the stated input value of $p = 0.3$; the value $p = 0.3$ itself is an illustrative figure I constructed for this example, not a measurement from any real classifier.

### Diagram: Bernoulli PMF

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 350">
  <text x="300" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Bernoulli PMF, p = 0.3 (svg_diagram)</text>

  <line x1="80" y1="280" x2="520" y2="280" stroke="#333" stroke-width="2" />
  <line x1="80" y1="280" x2="80" y2="60" stroke="#333" stroke-width="2" />

  <text x="60" y="285" font-size="12" text-anchor="end" fill="#333">0</text>
  <text x="60" y="215" font-size="12" text-anchor="end" fill="#333">0.2</text>
  <text x="60" y="145" font-size="12" text-anchor="end" fill="#333">0.4</text>
  <text x="60" y="75" font-size="12" text-anchor="end" fill="#333">0.6</text>

  <line x1="75" y1="210" x2="80" y2="210" stroke="#333" stroke-width="1" />
  <line x1="75" y1="140" x2="80" y2="140" stroke="#333" stroke-width="1" />
  <line x1="75" y1="70" x2="80" y2="70" stroke="#333" stroke-width="1" />

  <rect x="160" y="126" width="100" height="154" fill="#4285f4" stroke="#1a56c4" stroke-width="1" />
  <text x="210" y="115" font-size="14" text-anchor="middle" fill="#1a1a1a">0.70</text>
  <text x="210" y="305" font-size="14" text-anchor="middle" fill="#1a1a1a">X = 0</text>

  <rect x="340" y="175" width="100" height="105" fill="#ea4335" stroke="#b3261e" stroke-width="1" />
  <text x="390" y="163" font-size="14" text-anchor="middle" fill="#1a1a1a">0.30</text>
  <text x="390" y="305" font-size="14" text-anchor="middle" fill="#1a1a1a">X = 1</text>

  <text x="300" y="330" font-size="12" text-anchor="middle" fill="#555">P(X = x) = p^x (1-p)^(1-x)</text>
</svg>

### Relationship to Other Distributions

- **Binomial distribution**: The sum of $n$ independent and identically distributed (i.i.d.) Bernoulli($p$) random variables follows a Binomial($n, p$) distribution.
- **Categorical distribution**: The Bernoulli distribution is a special case of the categorical distribution restricted to two categories.
- **Indicator random variables**: Any indicator variable $\mathbb{1}_A$ for an event $A$ follows a Bernoulli distribution with $p = P(A)$.

This is [Verified] a standard set of relationships found in probability theory, though I cannot verify the specific notation or framing used in any course or textbook you may be referencing, since none was specified.

### Application in Machine Learning

**Key Points**
- **Binary classification**: The Bernoulli distribution underlies binary classification models. Logistic regression models $P(Y = 1 \mid X)$ as a Bernoulli parameter estimated via a sigmoid function applied to a linear combination of features.
- **Binary cross-entropy loss**: This is [Inference] commonly derived as the negative log-likelihood of the Bernoulli distribution, i.e., $-[y \log \hat{p} + (1-y)\log(1-\hat{p})]$, though the exact derivation steps and framing can vary across sources, and I cannot verify this matches any specific textbook's presentation without that source being specified.
- **Dropout regularization**: In neural networks, dropout masks are commonly modeled using independent Bernoulli random variables to decide whether each unit is retained or dropped during training. I cannot verify that any specific framework's internal implementation uses this exact formulation without inspecting its source code directly.
- **Naive Bayes classifiers**: The Bernoulli Naive Bayes variant models each feature as a Bernoulli random variable, commonly used for binary feature representations such as word-presence text data.

[Unverified] Whether any particular trained model or library correctly implements Bernoulli-based assumptions as intended cannot be confirmed without direct inspection of that system's code and behavior, and such behavior is not guaranteed to remain consistent across versions or configurations.

### Maximum Likelihood Estimation

Given $n$ i.i.d. observations $x_1, \ldots, x_n$ from a Bernoulli($p$) distribution, the maximum likelihood estimator (MLE) for $p$ is:

$$\hat{p}_{\text{MLE}} = \frac{1}{n}\sum_{i=1}^{n} x_i$$

This is the sample proportion of successes. This result is [Verified] derivable by maximizing the log-likelihood function with respect to $p$ and setting the derivative to zero, a standard calculus-based derivation in statistics.

### Common Pitfalls

- Confusing the Bernoulli distribution (single trial) with the Binomial distribution (sum of multiple trials); they are related but not interchangeable.
- Assuming $p$ can take values outside $[0, 1]$; this violates the definition and produces invalid probabilities.
- Applying Bernoulli assumptions to features or outcomes with more than two categories without adjustment to a categorical or multinomial framework.

### Related Topics

- Binomial distribution
- Categorical and multinomial distributions
- Logistic regression and the sigmoid function
- Binary cross-entropy / log-loss derivation
- Maximum likelihood estimation
- Bernoulli Naive Bayes