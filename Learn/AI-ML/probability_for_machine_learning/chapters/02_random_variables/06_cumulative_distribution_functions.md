## Cumulative Distribution Functions

### Formal Definition

The cumulative distribution function (CDF) of a random variable $X$, first introduced in the random variable formalism module, is defined for **any** random variable — discrete, continuous, or mixed — as:

$$
F_X(x) = P(X \leq x), \quad x \in \mathbb{R}
$$

[Inference] This single definition applies uniformly regardless of the underlying type of random variable, unlike the PMF (discrete-only) and PDF (continuous-only) formulations covered in the two preceding modules; this is why the CDF is sometimes treated as a more universal descriptor of a distribution. I cannot verify this framing ("more universal descriptor") is stated in this exact form across all sources, though the definitional applicability to all random variable types follows directly from the stated definition.

### The Three Defining Properties

Any valid CDF must satisfy:

1. **Non-decreasing**: if $a \leq b$, then $F_X(a) \leq F_X(b)$.
2. **Limits**: $\lim_{x \to -\infty} F_X(x) = 0$ and $\lim_{x \to \infty} F_X(x) = 1$.
3. **Right-continuous**: $\lim_{h \to 0^+} F_X(x+h) = F_X(x)$.

[Inference] Property 1 follows from the monotonicity consequence of the Kolmogorov axioms, established in the axioms module: since $a \leq b$ implies $\{X \leq a\} \subseteq \{X \leq b\}$, monotonicity of $P$ gives $F_X(a) \leq F_X(b)$. Property 2 follows from the normalization axiom applied in the limiting cases where the event $\{X \leq x\}$ approaches $\emptyset$ or $\Omega$. [Unverified] I do not have a self-contained derivation of right-continuity (Property 3) within this document series, as noted in the random variable formalism module; this property should be checked against a dedicated measure-theoretic source rather than accepted from this statement alone.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>CDF properties illustrated (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">CDF Properties (svg_diagram)</text>

<line x1="70" y1="210" x2="530" y2="210" stroke="#333333" stroke-width="1.5" />
<line x1="70" y1="210" x2="70" y2="60" stroke="#333333" stroke-width="1.5" />
<line x1="70" y1="80" x2="530" y2="80" stroke="#999999" stroke-width="1" stroke-dasharray="4,3" />
<text x="45" y="84" font-size="11" font-family="sans-serif" fill="#333333">1</text>
<text x="45" y="214" font-size="11" font-family="sans-serif" fill="#333333">0</text>

<path d="M 90 205 C 180 200 220 150 300 120 C 380 95 450 85 510 82" fill="none" stroke="#2b6cb0" stroke-width="2.5" />

<text x="300" y="240" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Non-decreasing, bounded between 0 and 1</text>
</svg>

### CDF Forms for Discrete and Continuous Random Variables

**Discrete** (restated from the discrete random variables module):

$$
F_X(x) = \sum_{x_i \leq x} p_X(x_i)
$$

This produces a right-continuous step function, with jumps at each point of positive probability mass.

**Continuous** (restated from the continuous random variables module):

$$
F_X(x) = \int_{-\infty}^{x} f_X(t)\, dt
$$

This produces a continuous, typically smooth, non-decreasing curve with no jumps, since $P(X=x) = 0$ at every point.

[Inference] The absence of jumps in the continuous case follows directly from $P(X=x)=0$ established in the continuous random variables module: a jump in $F_X$ at a point $x$ would require $P(X=x) > 0$, which contradicts the continuous case's defining property.

### Computing Probabilities from the CDF

For any random variable:

$$
P(X > x) = 1 - F_X(x)
$$

[Inference] This follows from the complement rule established in the Kolmogorov axioms module, since $\{X > x\}$ and $\{X \leq x\}$ are complementary events partitioning $\Omega$.

$$
P(a < X \leq b) = F_X(b) - F_X(a)
$$

[Inference] This follows because $\{X \leq b\} = \{X \leq a\} \cup \{a < X \leq b\}$ is a disjoint union, so by countable additivity (Axiom 3), $F_X(b) = F_X(a) + P(a < X \leq b)$; rearranging gives the stated formula.

For a **discrete** random variable, care is needed regarding strict vs. non-strict inequalities:

$$
P(X < x) = F_X(x) - p_X(x) = \lim_{t \to x^-} F_X(t)
$$

[Inference] This follows because $\{X \leq x\} = \{X < x\} \cup \{X = x\}$ is a disjoint union; subtracting $p_X(x) = P(X=x)$ from $F_X(x) = P(X \leq x)$ isolates $P(X < x)$. This distinction does not arise for continuous random variables, as established in the earlier PDF module, where $P(X=x)=0$ makes $P(X<x) = P(X \leq x) = F_X(x)$.

### Worked Example: Discrete CDF Table

Using the three-coin-flip example restated across earlier modules, where $X$ = number of heads with PMF $p_X(0)=\frac18, p_X(1)=\frac38, p_X(2)=\frac38, p_X(3)=\frac18$:

| $x$ | $F_X(x)$ |
|---|---|
| $x < 0$ | $0$ |
| $0 \leq x < 1$ | $\frac{1}{8}$ |
| $1 \leq x < 2$ | $\frac{1}{8}+\frac{3}{8} = \frac{4}{8}$ |
| $2 \leq x < 3$ | $\frac{4}{8}+\frac{3}{8} = \frac{7}{8}$ |
| $x \geq 3$ | $\frac{7}{8}+\frac{1}{8} = 1$ |

[Inference] This table follows by direct cumulative summation of the PMF values in order, applying the discrete CDF formula stated above. I have verified this specific arithmetic within this response.

### Worked Example: Continuous CDF from a PDF

Using the uniform distribution $X \sim \text{Uniform}(0,10)$ from the PDF module:

$$
F_X(x) = \int_0^x \frac{1}{10}\, dt = \frac{x}{10}, \quad 0 \leq x \leq 10
$$

with $F_X(x) = 0$ for $x < 0$ and $F_X(x) = 1$ for $x > 10$.

Using this, recompute $P(3 \leq X \leq 7)$ from the earlier PDF module via the CDF instead of direct integration:

$$
P(3 \leq X \leq 7) = F_X(7) - F_X(3) = 0.7 - 0.3 = 0.4
$$

[Inference] This matches the value obtained by direct integration in the PDF module, as expected since both methods derive from the same underlying definitions; this cross-check was performed within this response.

### Inverse CDF (Quantile Function)

If $F_X$ is strictly increasing and continuous, its inverse $F_X^{-1}$ is called the **quantile function**:

$$
F_X^{-1}(p) = \inf\{x : F_X(x) \geq p\}, \quad p \in (0,1)
$$

[Unverified] I do not have a derivation within this document series justifying the general infimum-based definition used when $F_X$ is not strictly increasing or not continuous (needed for discrete or mixed random variables); this general form is commonly used to extend the quantile function beyond the strictly-increasing continuous case, but should be checked against a dedicated source rather than accepted from this statement alone.

The **median** of $X$ is $F_X^{-1}(0.5)$, and this generalizes to arbitrary quantiles (e.g., the 0.25 and 0.75 quantiles for quartiles).

### Relevance to Machine Learning

- **Sampling algorithms** frequently use **inverse transform sampling**, which generates samples from an arbitrary distribution by applying $F_X^{-1}$ to samples drawn from a Uniform(0,1) distribution. [Unverified] I do not have a derivation within this document series confirming why this method produces correctly distributed samples, as that requires a probability transformation argument not covered here; this should be checked against a dedicated derivation rather than accepted from this statement alone.
- **Quantile regression** models directly estimate conditional quantiles (values of $F_X^{-1}$) rather than the conditional mean, useful for uncertainty estimation. [Unverified] I do not have access to information confirming implementation-specific details of any particular quantile regression method or library; behavior should be verified against the specific implementation in use.
- **Evaluation metrics** such as the Kolmogorov-Smirnov statistic compare CDFs directly to assess how well a model's predicted distribution matches an empirical or reference distribution. [Unverified] I do not have a derivation of the Kolmogorov-Smirnov statistic within this document series; this is mentioned as a structural connection to the CDF concept, not a full treatment of the test itself.
- **Percentile-based normalization** of features (e.g., mapping raw feature values to their empirical CDF value) is a preprocessing technique connecting directly to the CDF concept defined here. [Inference] This follows from the general definition of the CDF as a cumulative probability, applied to an empirical distribution estimated from a dataset rather than a theoretical one, though I do not have a formal treatment of empirical CDF estimation properties within this document series.

### Common Pitfalls

- Confusing $P(X < x)$ with $P(X \leq x)$ for discrete random variables, where these generally differ by $p_X(x)$; for continuous random variables, they are equal, as established in the PDF module.
- Assuming every CDF has a well-defined inverse in the simple functional sense; this requires strict monotonicity and continuity, which does not hold for discrete or mixed random variables without the more general infimum-based definition.
- Misreading a step-function CDF (discrete case) as if it were smooth, leading to incorrect interpolation of probabilities between jump points.
- Forgetting that the CDF is defined as $P(X \leq x)$ with a **non-strict** inequality by convention; some sources may define related quantities differently, and this should be checked against the specific source in use. [Unverified] I do not have access to information confirming how universally this non-strict convention is applied across all probability texts.

**Related Topics**
- Probability mass functions and probability density functions
- Quantile functions and inverse transform sampling
- Empirical CDFs and the Kolmogorov-Smirnov test
- Order statistics and quantile regression
- Joint and conditional cumulative distribution functions
- Transformations of random variables

> Correction: This document contains multiple [Unverified] labeled points, including an underived right-continuity property, an underived general quantile function definition for non-strictly-increasing CDFs, an underived inverse transform sampling justification, and unverified claims about specific ML tooling and convention universality. These are labeled rather than stated as confirmed fact, consistent with the requirement not to chain unverified claims into stated conclusions.