## Discrete Random Variables

### Definition

A random variable $X$ is a function that maps outcomes in a sample space $\Omega$ to real numbers: $X: \Omega \rightarrow \mathbb{R}$. A random variable is **discrete** if it takes values in a finite or countably infinite set.

$$X: \Omega \rightarrow \{x_1, x_2, x_3, \ldots\}$$

[Inference] This mapping formalism connects a random variable back to the sample space and event concepts established earlier: for any value $x_i$, the set $\{\omega \in \Omega : X(\omega) = x_i\}$ is itself an event, since it is a subset of $\Omega$. This is a direct logical consequence of the definitions already established, not an independently confirmed empirical claim.

### Probability Mass Function (PMF)

For a discrete random variable $X$, the probability mass function assigns a probability to each possible value:

$$p_X(x) = P(X = x)$$

A valid PMF must satisfy two conditions, which follow directly from Kolmogorov's axioms applied to the events $\{X = x_i\}$:

$$p_X(x) \geq 0 \quad \text{for all } x$$

$$\sum_{x} p_X(x) = 1$$

### Cumulative Distribution Function (CDF)

$$F_X(x) = P(X \leq x) = \sum_{x_i \leq x} p_X(x_i)$$

For a discrete random variable, $F_X$ is a **step function**: it is constant between consecutive possible values of $X$ and jumps by $p_X(x_i)$ at each value $x_i$.

### Visualizing PMF vs CDF (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">PMF vs CDF for a Discrete Random Variable (svg_diagram)</text>

  <line x1="60" y1="160" x2="280" y2="160" stroke="#333" stroke-width="1" />
  <line x1="60" y1="60" x2="60" y2="160" stroke="#333" stroke-width="1" />
  <text x="140" y="185" font-size="12" fill="#333">PMF</text>
  <rect x="90" y="130" width="20" height="30" fill="#4a90d9" />
  <rect x="140" y="100" width="20" height="60" fill="#4a90d9" />
  <rect x="190" y="120" width="20" height="40" fill="#4a90d9" />
  <rect x="240" y="145" width="20" height="15" fill="#4a90d9" />
  <text x="95" y="175" font-size="10" fill="#1a1a1a">1</text>
  <text x="145" y="175" font-size="10" fill="#1a1a1a">2</text>
  <text x="195" y="175" font-size="10" fill="#1a1a1a">3</text>
  <text x="245" y="175" font-size="10" fill="#1a1a1a">4</text>

  <line x1="360" y1="160" x2="580" y2="160" stroke="#333" stroke-width="1" />
  <line x1="360" y1="60" x2="360" y2="160" stroke="#333" stroke-width="1" />
  <text x="440" y="185" font-size="12" fill="#333">CDF</text>
  <path d="M 360 145 L 390 145 L 390 105 L 440 105 L 440 65 L 490 65 L 490 45 L 540 45 L 540 40 L 580 40" fill="none" stroke="#e07a3f" stroke-width="2" />
  <text x="395" y="175" font-size="10" fill="#1a1a1a">1</text>
  <text x="445" y="175" font-size="10" fill="#1a1a1a">2</text>
  <text x="495" y="175" font-size="10" fill="#1a1a1a">3</text>
  <text x="545" y="175" font-size="10" fill="#1a1a1a">4</text>

  <text x="320" y="220" font-size="12" fill="#1a1a1a" text-anchor="middle">PMF gives P(X=x) at each point; CDF accumulates as a step function</text>
</svg>

### Expected Value (Mean)

$$E[X] = \sum_{x} x \cdot p_X(x)$$

[Inference] This definition is a weighted average of possible values, weighted by their probabilities. This is the standard definition used across probability texts; I cannot cite a specific primary source confirming this exact notation within this conversation, so the notation is presented as the conventional form rather than a direct quotation from a verified document.

### Variance and Standard Deviation

$$\text{Var}(X) = E[(X - E[X])^2] = E[X^2] - (E[X])^2$$

$$\sigma_X = \sqrt{\text{Var}(X)}$$

[Inference] The equality $E[(X-E[X])^2] = E[X^2] - (E[X])^2$ follows by expanding the square inside the expectation and applying linearity of expectation. This is a direct algebraic derivation, not an independently confirmed empirical result. I have not reproduced every intermediate expansion step here.

### Worked Example

**Example**

Let $X$ = number of heads in 2 independent fair coin tosses. $\Omega = \{HH, HT, TH, TT\}$, each with probability $\tfrac{1}{4}$.

Possible values of $X$: $0, 1, 2$.

$$p_X(0) = P(TT) = \tfrac{1}{4}, \quad p_X(1) = P(HT) + P(TH) = \tfrac{2}{4} = \tfrac{1}{2}, \quad p_X(2) = P(HH) = \tfrac{1}{4}$$

Check: $\tfrac{1}{4} + \tfrac{1}{2} + \tfrac{1}{4} = 1$, satisfying the PMF normalization condition.

**Expected value:**

$$E[X] = (0)(\tfrac{1}{4}) + (1)(\tfrac{1}{2}) + (2)(\tfrac{1}{4}) = 0 + 0.5 + 0.5 = 1$$

**Variance:**

$$E[X^2] = (0)^2(\tfrac{1}{4}) + (1)^2(\tfrac{1}{2}) + (2)^2(\tfrac{1}{4}) = 0 + 0.5 + 1 = 1.5$$

$$\text{Var}(X) = E[X^2] - (E[X])^2 = 1.5 - 1^2 = 0.5$$

These are direct computations from the stated PMF values; each step follows mechanically from the formulas above applied to this specific example.

### Common Discrete Distribution Families (Preview)

The following are named distributions built on the discrete random variable framework, each covered in dedicated future topics:

- **Bernoulli** — single trial, two outcomes
- **Binomial** — number of successes in $n$ independent Bernoulli trials
- **Geometric** — number of trials until first success
- **Poisson** — number of events in a fixed interval, under certain conditions
- **Hypergeometric** — sampling without replacement from a finite population

[Unverified] The precise defining conditions and parameter formulas for each of these distributions are deferred to their dedicated topics and are not derived or confirmed in this response; this list is presented only as a preview of upcoming material.

### Relevance to Machine Learning

- **Loss function expectations**: the expected loss (risk) in statistical learning theory is formally defined as $E[L(Y, \hat{Y})]$, directly using the expectation operator defined above, extended to the more general case of random variables that may be continuous or a mix of discrete and continuous.
- **Class labels as discrete random variables**: in classification tasks, the target variable $Y$ is typically modeled as a discrete random variable taking values in a finite label set, with model outputs interpreted as estimates of $p_Y(y \mid x)$.
- **Discrete latent variables**: [Inference] models such as discrete Variational Autoencoders or certain mixture models treat latent variables as discrete random variables with an associated PMF, relying on the same normalization and expectation machinery described above. Whether any specific model implementation computes these quantities exactly versus via approximation (e.g., Gumbel-Softmax relaxation) is implementation-specific, and I do not have a verified source confirming the exact behavior of any particular named library or codebase; this should not be treated as a guaranteed behavioral property of any specific tool.

### Common Pitfalls

- Confusing the PMF value $p_X(x)$ with the CDF value $F_X(x)$ — the PMF gives the probability of an exact value, while the CDF gives cumulative probability up to and including that value.
- Applying continuous-distribution formulas (e.g., integrating a density) to discrete random variables — discrete random variables require summation over the PMF, not integration over a density function; the two frameworks are related but distinct (covered further in the continuous random variables topic).
- Computing variance using only $E[(X-E[X])^2]$ or only $E[X^2]-(E[X])^2$ without verifying both give the same result as a check — a mismatch indicates an arithmetic error in one of the two computation paths.

This entire response contains labeled [Inference] and [Unverified] statements as noted inline. Per the stated labeling requirement, since portions of this output rely on reasoned derivation or unconfirmed generalization rather than direct citation from a verified primary source, the response as a whole is marked accordingly: **[Inference/Unverified — mathematical content reflects standard, widely-taught definitions and derivations; it has not been cross-checked against a specific cited primary source within this conversation, and any behavioral claims about ML systems are explicitly disclaimed as not guaranteed.]**

**Related Topics**
- Continuous Random Variables and Probability Density Functions
- Bernoulli and Binomial Distributions
- Poisson Distribution
- Geometric and Hypergeometric Distributions
- Expectation, Variance, and Moment-Generating Functions
- Joint Distributions of Multiple Random Variables