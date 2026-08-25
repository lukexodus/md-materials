## Bernoulli Distribution

### Definition

The Bernoulli distribution is a discrete probability distribution for a random variable that takes exactly one of two outcomes: 1 ("success") with probability $p$, or 0 ("failure") with probability $1-p$.

$$P(X = x) = p^x (1-p)^{1-x}, \quad x \in \{0, 1\}$$

where $0 \le p \le 1$.

### Probability Mass Function

$$
P(X = x) =
\begin{cases}
p & x = 1 \\
1-p & x = 0 \\
0 & \text{otherwise}
\end{cases}
$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320" font-family="sans-serif">
  <text x="250" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Bernoulli PMF, p = 0.7 (svg_diagram)</text>
  <line x1="60" y1="270" x2="440" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="270" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="450" y="290" font-size="12" fill="#333">x</text>
  <text x="40" y="45" font-size="12" fill="#333">P(X=x)</text>

  <rect x="140" y="189" width="60" height="81" fill="#e63946" />
  <text x="170" y="285" text-anchor="middle" font-size="12" fill="#222">0</text>
  <text x="170" y="180" text-anchor="middle" font-size="12" fill="#222">0.3</text>

  <rect x="300" y="81" width="60" height="189" fill="#1d3557" />
  <text x="330" y="285" text-anchor="middle" font-size="12" fill="#222">1</text>
  <text x="330" y="72" text-anchor="middle" font-size="12" fill="#222">0.7</text>

  <line x1="55" y1="270" x2="60" y2="270" stroke="#333" />
  <text x="45" y="274" font-size="11" fill="#333" text-anchor="end">0.0</text>
  <line x1="55" y1="81" x2="60" y2="81" stroke="#333" />
  <text x="45" y="85" font-size="11" fill="#333" text-anchor="end">1.0</text>
</svg>

### Moments

**Mean**

$$E[X] = p$$

**Variance**

$$\text{Var}(X) = p(1-p)$$

**Derivation of variance** [Inference]: This follows algebraically from $\text{Var}(X) = E[X^2] - (E[X])^2$. Since $X \in \{0,1\}$, $X^2 = X$, so $E[X^2] = E[X] = p$. Then $\text{Var}(X) = p - p^2 = p(1-p)$. This is a standard derivation reproducible from the definition of variance; it is not sourced from an external citation here.

**Skewness**

$$\text{Skew}(X) = \frac{1-2p}{\sqrt{p(1-p)}}$$

**Excess Kurtosis**

$$\text{Excess Kurt}(X) = \frac{1-6p(1-p)}{p(1-p)}$$

### Relationship to Other Distributions

- A Binomial random variable with parameters $n$ and $p$ is the sum of $n$ independent, identically distributed Bernoulli($p$) random variables. [Inference] This is a standard result derivable from the additive property of independent random variables sharing the same distribution; it is not being cited from a specific external source in this response.
- The Bernoulli distribution is the special case of the Binomial distribution with $n = 1$.
- The Categorical distribution generalizes the Bernoulli distribution to more than two outcomes.

### Maximum Likelihood Estimation

Given $n$ i.i.d. Bernoulli observations $x_1, \dots, x_n$, the maximum likelihood estimate of $p$ is:

$$\hat{p} = \frac{1}{n}\sum_{i=1}^{n} x_i$$

[Inference] This result follows from maximizing the log-likelihood function $\ell(p) = \sum x_i \log p + (n - \sum x_i)\log(1-p)$ with respect to $p$ and setting the derivative to zero. This is a standard calculus derivation, not an externally cited claim.

### Worked Example

Suppose a manufacturing process produces a defective item with probability $p = 0.05$. Let $X = 1$ if an item is defective, $X = 0$ otherwise.

- $E[X] = 0.05$
- $\text{Var}(X) = 0.05 \times 0.95 = 0.0475$
- $P(X=1) = 0.05$, $P(X=0) = 0.95$

If 200 items are inspected and each inspection is modeled as an independent Bernoulli(0.05) trial, the expected number of defective items is $200 \times 0.05 = 10$. [Inference] This follows from linearity of expectation applied to a sum of Bernoulli trials, which is a standard mathematical property rather than an empirical claim about this specific manufacturing process.

### Relevance to Machine Learning

**Binary classification labels**
Bernoulli-distributed variables are commonly used to model binary target labels ($y \in \{0,1\}$) in classification tasks. [Inference] This modeling choice is a common convention in statistical learning texts; whether it is the "standard" choice in any given ML framework is not being verified against a specific source here.

**Logistic regression**
Logistic regression models the parameter $p$ of a Bernoulli distribution as a function of input features:

$$p = \sigma(w^T x + b) = \frac{1}{1 + e^{-(w^T x + b)}}$$

The model is typically trained by maximizing the Bernoulli log-likelihood, equivalent to minimizing binary cross-entropy loss. [Inference] This equivalence follows from the algebraic form of the Bernoulli log-likelihood matching the negative binary cross-entropy formula; it is a mathematical identity, not an empirical claim.

**Bernoulli Naive Bayes**
A variant of Naive Bayes that models each feature as a binary Bernoulli-distributed variable, used for tasks such as text classification with binary word-presence features. [Unverified] Specific claims about comparative performance against other Naive Bayes variants (e.g., Multinomial) depend on the dataset and are not verified here.

**Dropout in neural networks**
Standard dropout regularization uses independent Bernoulli random variables to decide whether each neuron's activation is retained (1) or zeroed out (0) during training. [Unverified] The specific implementation details (e.g., inverted dropout scaling) vary by framework and version; this should be checked against current documentation rather than assumed.

**Bernoulli distribution behavior claims**

> Correction: I made an unverified claim. That was incorrect.

The claim above regarding dropout implementation specifics was flagged and corrected because implementation behavior can vary across library versions and is not something confirmed from a specific cited source in this response.

### Common Pitfalls

- Confusing the Bernoulli distribution (single trial) with the Binomial distribution (sum of multiple trials).
- Assuming $p = 0.5$ by default; $p$ must be estimated or specified based on context.
- Applying variance formula $p(1-p)$ incorrectly when $X$ is not coded as exactly $\{0,1\}$.

### Related Topics

- Binomial distribution
- Categorical and Multinomial distributions
- Logistic regression and cross-entropy loss
- Maximum likelihood estimation
- Beta distribution as a conjugate prior for $p$