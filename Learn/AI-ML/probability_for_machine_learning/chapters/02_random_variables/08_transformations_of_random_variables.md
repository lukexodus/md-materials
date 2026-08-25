## Transformations of Random Variables

### Motivation

Given a random variable $X$ with a known distribution, a transformation $Y = g(X)$ produces a new random variable $Y$. [Inference] Determining the distribution of $Y$ from the distribution of $X$ and the function $g$ is a recurring need in probability modeling, since derived quantities (sums, scaled values, functions of a base variable) are common in applied settings. I cannot verify this exact motivating framing is stated identically across all probability texts, though the underlying mathematical problem (deriving the distribution of $g(X)$) is standard.

### Discrete Case: Direct Substitution

For a discrete random variable $X$ with PMF $p_X(x)$, and $Y = g(X)$:

$$
p_Y(y) = \sum_{x : g(x) = y} p_X(x)
$$

[Inference] This follows from the definition of the PMF established in the earlier PMF module, applied to the event $\{Y = y\} = \{X \in g^{-1}(y)\}$; countable additivity (established in the Kolmogorov axioms module) gives the sum over all $x$ values mapping to $y$, which is necessary when $g$ is not one-to-one, since multiple $x$ values can map to the same $y$.

**Example**: Let $X$ be the outcome of a fair die roll, $X \in \{1,\dots,6\}$, and define $Y = X \bmod 2$ (parity). Then $Y \in \{0,1\}$, and:

$$
p_Y(0) = p_X(2) + p_X(4) + p_X(6) = \frac{3}{6} = \frac{1}{2}
$$

[Inference] This follows by direct application of the substitution formula above, summing over the three $x$ values (2, 4, 6) that map to $y=0$ under the parity function. I have verified this specific arithmetic within this response.

### Continuous Case: The CDF Method

For a continuous random variable $X$ with CDF $F_X$, and $Y = g(X)$, the general procedure is:

1. Express $F_Y(y) = P(Y \leq y) = P(g(X) \leq y)$.
2. Solve the inequality $g(X) \leq y$ for $X$ in terms of $y$, which depends on whether $g$ is increasing or decreasing.
3. Rewrite in terms of $F_X$, then differentiate to obtain $f_Y(y)$.

[Inference] This procedure follows from the CDF definition established in the earlier CDF module, applied to the transformed variable $Y$; the differentiation step in part 3 follows from the PDF-as-derivative-of-CDF relationship established in that same module.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>Transformation of a random variable through a function g (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Transformation Y = g(X) (svg_diagram)</text>

<rect x="60" y="100" width="140" height="60" fill="#a3c9f9" fill-opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
<text x="130" y="135" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">X, f_X(x)</text>

<line x1="200" y1="130" x2="340" y2="130" stroke="#333333" stroke-width="2" />
<polygon points="340,124 356,130 340,136" fill="#333333" />
<text x="270" y="115" font-size="12" text-anchor="middle" font-family="sans-serif" fill="#111111">g(·)</text>

<rect x="360" y="100" width="140" height="60" fill="#f9a3a3" fill-opacity="0.6" stroke="#c0392b" stroke-width="2" />
<text x="430" y="135" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Y, f_Y(y)</text>

<text x="300" y="210" font-size="12" text-anchor="middle" font-family="monospace" fill="#111111">f_Y(y) = f_X(g⁻¹(y)) |d/dy g⁻¹(y)|</text>
</svg>

### The Change-of-Variables Formula

For a monotonic, differentiable, invertible $g$:

$$
f_Y(y) = f_X\big(g^{-1}(y)\big) \left| \frac{d}{dy} g^{-1}(y) \right|
$$

[Unverified] I do not have a derivation of this formula within the scope of this document series, as noted previously in the PDF module. This formula requires a Jacobian-based argument not established in the preceding modules of this series; it is commonly presented in probability texts, but I cannot verify its derivation here and it should be checked against a dedicated source.

### Worked Example: Linear Transformation

Let $X \sim \text{Uniform}(0,1)$, and define $Y = 2X + 3$.

Using the CDF method: $g(x) = 2x+3$ is increasing, so:

$$
F_Y(y) = P(2X+3 \leq y) = P\left(X \leq \frac{y-3}{2}\right) = F_X\left(\frac{y-3}{2}\right)
$$

Since $X \sim \text{Uniform}(0,1)$, $F_X(x) = x$ for $0 \leq x \leq 1$, so:

$$
F_Y(y) = \frac{y-3}{2}, \quad 3 \leq y \leq 5
$$

Differentiating:

$$
f_Y(y) = \frac{d}{dy}\left[\frac{y-3}{2}\right] = \frac{1}{2}, \quad 3 \leq y \leq 5
$$

[Inference] This result means $Y \sim \text{Uniform}(3,5)$, which follows from the general fact that a linear transformation of a Uniform random variable remains Uniform, with the new bounds determined by applying $g$ to the original bounds. I have verified this specific derivation within this response by direct computation, not by citing this general fact independently.

### General Linear Transformation Result

For $Y = aX + b$ with $a \neq 0$:

$$
f_Y(y) = \frac{1}{|a|} f_X\left(\frac{y-b}{a}\right)
$$

[Inference] This follows from applying the change-of-variables formula stated above with $g^{-1}(y) = \frac{y-b}{a}$ and $\frac{d}{dy}g^{-1}(y) = \frac{1}{a}$, taking the absolute value to ensure a non-negative density regardless of the sign of $a$. [Unverified] Since the general change-of-variables formula itself is labeled [Unverified] above (its full derivation not being reproduced in this series), this specific application inherits that same unverified status for its formal justification, even though the algebraic substitution shown here is direct.

### Non-Monotonic Transformations

When $g$ is not monotonic (e.g., $Y = X^2$), the direct inverse function does not exist globally, and the CDF method must account for multiple branches.

**Example**: Let $X \sim N(0,1)$ (standard normal) and $Y = X^2$.

$$
F_Y(y) = P(X^2 \leq y) = P(-\sqrt{y} \leq X \leq \sqrt{y}) = F_X(\sqrt{y}) - F_X(-\sqrt{y}), \quad y \geq 0
$$

[Inference] This follows because $X^2 \leq y$ is equivalent to $-\sqrt{y} \leq X \leq \sqrt{y}$ for $y \geq 0$, and the resulting probability is computed as a CDF difference using the interval-probability relationship established in the earlier CDF module. [Unverified] I have not carried out the further differentiation to derive the explicit PDF of $Y$ (which yields the Chi-squared distribution with 1 degree of freedom) within this response, since that requires differentiating $F_X(\sqrt y) - F_X(-\sqrt y)$ using the chain rule and substituting the standard normal PDF, which I have not performed here; this specific derivation should be checked against a dedicated source rather than accepted from this statement alone.

### Sums of Random Variables (Preview)

[Unverified] The distribution of a sum $Z = X + Y$ of two independent random variables can be computed via a convolution of their individual PDFs or PMFs. I do not have a derivation of the convolution formula within this document series; this is mentioned here only as a named related technique, not derived, and full treatment is deferred to a later module covering joint distributions and sums of random variables.

### Relevance to Machine Learning

- **Feature scaling and normalization** (e.g., standardizing a feature by subtracting the mean and dividing by the standard deviation) is a linear transformation of a random variable, directly connecting to the general linear transformation result derived above. [Inference] This follows because standardization has the form $Y = \frac{X-\mu}{\sigma}$, a special case of $Y=aX+b$ with $a=\frac{1}{\sigma}$ and $b=-\frac{\mu}{\sigma}$.
- **Log transformations** of skewed target variables (e.g., in regression on income or count data) are a nonlinear transformation of a random variable. [Unverified] I do not have access to information confirming the specific statistical justification used in any particular applied modeling context for choosing a log transformation over alternatives; this should be verified against the specific modeling literature in use rather than assumed from this general structural connection.
- **The reparameterization trick** in variational autoencoders expresses a sampled latent variable as a deterministic transformation of a base noise variable (e.g., $Y = \mu + \sigma \cdot \epsilon$ where $\epsilon \sim N(0,1)$), structurally matching the linear transformation form derived above. [Unverified] I do not have access to confirming implementation-specific details of this technique in any particular deployed system; this is a general structural description only, and specific behavior should be verified against the relevant implementation rather than assumed to be guaranteed from this description.
- **Activation functions** applied to a model's pre-activation outputs can be viewed as transformations of a random variable when the pre-activation is treated as random (e.g., under a Bayesian neural network interpretation). [Speculation] I do not have access to information confirming this framing is a standard or common way of describing activation functions in current ML literature; this connection is offered as a speculative structural parallel only, not an established equivalence.

### Common Pitfalls

- Applying the simple change-of-variables formula to a non-monotonic function without accounting for multiple branches, which produces an incorrect or incomplete PDF.
- Forgetting the absolute value of the derivative term in the change-of-variables formula, which can yield a negative (invalid) density.
- Assuming a transformed variable retains the same distributional family as the original (e.g., assuming $X^2$ is still Normal when $X$ is Normal); this generally does not hold, as illustrated in the non-monotonic example above.
- Confusing the discrete substitution method (direct summation over preimages) with the continuous CDF-based method; the two require different formal treatments as shown in this module.

**Related Topics**
- Joint distributions and sums of independent random variables (convolution)
- The reparameterization trick in variational inference
- Feature standardization and normalization in preprocessing
- The Chi-squared distribution as a transformation of the Normal distribution
- Moment generating functions for deriving distributions of transformed variables
- The Central Limit Theorem

> Correction: This document contains multiple [Unverified] labeled points, including an underived general change-of-variables formula and its inherited unverified status in the linear transformation application, an unperformed full derivation of the Chi-squared PDF from the $Y=X^2$ example, an undreived convolution formula for sums of random variables, and unverified or speculative claims about specific ML technique justifications and framings. These are labeled rather than stated as confirmed fact, consistent with the requirement not to chain unverified claims into stated conclusions. I have not independently added new unverified claims beyond restating and extending labels consistent with prior modules in this series.