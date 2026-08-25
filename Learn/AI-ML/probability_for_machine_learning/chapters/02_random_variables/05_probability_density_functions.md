## Probability Density Functions

### Formal Definition

A probability density function (PDF), introduced in the continuous random variables module, is a function $f_X: \mathbb{R} \to [0, \infty)$ describing the relative likelihood of a continuous random variable $X$ taking values near a given point. It satisfies:

$$
f_X(x) \geq 0 \text{ for all } x, \qquad \int_{-\infty}^{\infty} f_X(x)\, dx = 1
$$

[Inference] These conditions are the continuous analogue of the PMF validity conditions established in the earlier PMF module, with summation replaced by integration; non-negativity corresponds to Axiom 1 of the Kolmogorov axioms, and the total-integral-equals-one condition corresponds to the normalization axiom $P(\Omega) = 1$ combined with countable additivity extended to the continuous case. I cannot verify that this extension from countable additivity to the continuous integral form is derived identically across all measure-theoretic sources, since the full justification relies on measure theory not covered in depth in this series.

### PDF Values Are Not Probabilities

$$
f_X(x) \neq P(X = x)
$$

As established in the continuous random variables module, $P(X = x) = 0$ for any single point when $X$ is continuous. [Inference] The density $f_X(x)$ instead represents a rate of probability accumulation per unit length near $x$, and can take values greater than 1, unlike a PMF value which is bounded in $[0,1]$. This follows directly from the definition of $f_X$ as a density rather than a point mass, restated here from the earlier module for emphasis.

### Probability as an Integral

$$
P(a \leq X \leq b) = \int_a^b f_X(x)\, dx
$$

[Inference] This is restated directly from the continuous random variables module. Because $P(X=a) = 0$ and $P(X=b) = 0$ for continuous $X$, the following four probabilities are all equal:

$$
P(a \leq X \leq b) = P(a < X \leq b) = P(a \leq X < b) = P(a < X < b)
$$

[Inference] This follows because removing a single point of zero probability from an interval does not change the integral over that interval; this is a direct consequence of $P(X=a)=0$ and $P(X=b)=0$ stated above, not a separately established rule.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>PDF as area under the curve (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">PDF as Area Under the Curve (svg_diagram)</text>

<line x1="70" y1="210" x2="530" y2="210" stroke="#333333" stroke-width="1.5" />
<line x1="70" y1="210" x2="70" y2="60" stroke="#333333" stroke-width="1.5" />

<path d="M 80 200 Q 200 80 300 75 Q 400 80 520 200" fill="none" stroke="#2b6cb0" stroke-width="2.5" />
<path d="M 220 200 Q 260 100 300 95 Q 340 100 380 200 Z" fill="#a3c9f9" fill-opacity="0.55" stroke="none" />

<line x1="220" y1="210" x2="220" y2="200" stroke="#333333" stroke-width="1.5" />
<line x1="380" y1="210" x2="380" y2="200" stroke="#333333" stroke-width="1.5" />
<text x="220" y="228" font-size="12" text-anchor="middle" font-family="sans-serif">a</text>
<text x="380" y="228" font-size="12" text-anchor="middle" font-family="sans-serif">b</text>

<text x="300" y="150" font-size="12" text-anchor="middle" font-family="sans-serif" fill="#111111">Area = P(a≤X≤b)</text>
<text x="70" y="50" font-size="11" font-family="sans-serif" fill="#333333">f_X(x)</text>
</svg>

### Recovering the PDF from the CDF

$$
f_X(x) = \frac{d}{dx} F_X(x)
$$

[Inference] This follows from the Fundamental Theorem of Calculus applied to $F_X(x) = \int_{-\infty}^{x} f_X(t)\,dt$, as stated in the continuous random variables module, and holds at points where $F_X$ is differentiable. [Unverified] I do not have a derivation within this document series confirming behavior at points where $F_X$ is not differentiable (e.g., kinks in the CDF); this edge case should be checked against a dedicated measure-theoretic source.

### Joint PDFs for Two Continuous Random Variables

For two continuous random variables $X$ and $Y$, the joint PDF $f_{X,Y}(x,y)$ satisfies:

$$
f_{X,Y}(x,y) \geq 0, \qquad \int_{-\infty}^{\infty}\int_{-\infty}^{\infty} f_{X,Y}(x,y)\, dx\, dy = 1
$$

**Marginal PDF**:

$$
f_X(x) = \int_{-\infty}^{\infty} f_{X,Y}(x,y)\, dy
$$

[Inference] This follows by the continuous analogue of the marginal PMF formula established in the earlier PMF module, replacing summation over $y$ with integration over $y$; full formal treatment of joint continuous distributions is deferred to a later module, and this is stated here only to establish the marginalization relationship.

### PDF Transformation Under Change of Variables

If $Y = g(X)$ for a monotonic, differentiable function $g$, the PDF of $Y$ is:

$$
f_Y(y) = f_X(g^{-1}(y)) \left| \frac{d}{dy} g^{-1}(y) \right|
$$

[Unverified] I do not have a derivation of this change-of-variables formula within the scope of this document series, since it requires a Jacobian-based argument not established in the preceding modules; this formula is commonly presented in probability texts, but should be checked against a dedicated derivation rather than accepted from this statement alone.

### Common Continuous PDFs (Cross-Reference)

The following PDFs were introduced in the previous module and are restated here only as a reference table, not re-derived:

| Distribution | PDF $f_X(x)$ | Support |
|---|---|---|
| Uniform($a,b$) | $\frac{1}{b-a}$ | $[a,b]$ |
| Normal($\mu,\sigma^2$) | $\frac{1}{\sigma\sqrt{2\pi}}\exp\left(-\frac{(x-\mu)^2}{2\sigma^2}\right)$ | $(-\infty,\infty)$ |
| Exponential($\lambda$) | $\lambda e^{-\lambda x}$ | $[0,\infty)$ |
| Beta($\alpha,\beta$) | $\frac{x^{\alpha-1}(1-x)^{\beta-1}}{B(\alpha,\beta)}$ | $[0,1]$ |

### Worked Example: Verifying a Candidate PDF

Consider a proposed function:

$$
f_X(x) = \begin{cases} c \, x^2 & 0 \leq x \leq 2 \\ 0 & \text{otherwise} \end{cases}
$$

Find $c$ such that this is a valid PDF.

$$
\int_0^2 c\,x^2\, dx = c \left[\frac{x^3}{3}\right]_0^2 = c \cdot \frac{8}{3} = 1
$$

$$
c = \frac{3}{8}
$$

[Inference] This follows by direct application of the normalization condition $\int f_X(x)\,dx = 1$ established above, solving algebraically for $c$. I have verified this specific integral computation within this response.

Using this PDF, compute $P(0 \leq X \leq 1)$:

$$
P(0 \leq X \leq 1) = \int_0^1 \frac{3}{8}x^2\, dx = \frac{3}{8}\left[\frac{x^3}{3}\right]_0^1 = \frac{3}{8} \cdot \frac{1}{3} = \frac{1}{8}
$$

[Inference] This follows from direct substitution into the interval-probability integral formula stated above, using the value of $c$ derived in this same worked example. I have verified this specific arithmetic within this response.

### Likelihood: A Key ML Application of the PDF

In maximum likelihood estimation, the **likelihood function** for a continuous random variable with parameter $\theta$ is constructed by evaluating the PDF at observed data points:

$$
L(\theta) = \prod_{i=1}^{n} f_X(x_i \mid \theta)
$$

[Inference] This construction treats each observed data point's density value (rather than a probability, since $P(X=x_i)=0$ for continuous $X$) as a measure of how well the parameter $\theta$ explains that observation, and the product form follows from an assumed independence between observations, consistent with the i.i.d. assumption discussed in the earlier independence module. [Unverified] I do not have a full derivation of maximum likelihood estimation itself within this document series; this statement establishes only the connection between the PDF and the likelihood function's construction, not the full estimation procedure.

### Relevance to Machine Learning

- **Gaussian likelihood** in regression models assumes residuals follow a Normal PDF, connecting the mean-squared-error loss to maximum likelihood estimation under this assumption. [Unverified] I do not have a full derivation within this document series confirming the exact equivalence between minimizing squared error and maximizing Gaussian likelihood; this connection is commonly stated in ML texts, but should be verified against a dedicated derivation.
- **Density estimation** techniques (e.g., kernel density estimation, normalizing flows) directly aim to estimate an unknown PDF from observed data. [Unverified] I do not have access to information confirming implementation-specific behavior of any particular density estimation method or software library; behavior should be verified against the specific implementation in use, and is not guaranteed to match the idealized formulation given here.
- **Continuous latent variable models** (e.g., variational autoencoders) involve PDFs over latent spaces, typically parameterized as Normal distributions. [Unverified] I do not have access to confirming implementation details of any specific model architecture; this is a general structural description, not a claim about any particular system's guaranteed behavior.

### Common Pitfalls

- Interpreting $f_X(x) > 1$ as an error; this is valid for PDFs (unlike PMFs) as long as the total integral equals 1, since density depends on the scale of the variable.
- Computing $P(X = x)$ directly from the PDF as if it were a PMF value, rather than recognizing this probability is always 0 for continuous random variables.
- Forgetting to take the absolute value of the derivative term in the change-of-variables formula, which can produce a negative (invalid) density if $g^{-1}$ is decreasing.
- Applying the likelihood function's product form without verifying the i.i.d. assumption holds for the specific observed data.

**Related Topics**
- Maximum likelihood estimation for continuous distributions
- Joint and conditional PDFs of multiple continuous random variables
- Change of variables and transformations of random variables
- The Normal distribution and the Central Limit Theorem
- Kernel density estimation
- Variational inference and latent variable models

> Correction: This document contains multiple [Unverified] labeled points, including an underived change-of-variables formula, an unconfirmed differentiability edge case for CDF-to-PDF recovery, and unverified claims about specific ML implementations and the MSE-to-Gaussian-likelihood equivalence. These are labeled rather than stated as confirmed fact, per the requirement not to chain unverified claims into stated conclusions.