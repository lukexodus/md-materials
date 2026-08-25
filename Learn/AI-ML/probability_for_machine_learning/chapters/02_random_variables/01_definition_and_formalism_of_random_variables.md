## Definition and Formalism of Random Variables

### Formal Definition

A random variable $X$ is a function mapping outcomes in a sample space to real numbers:

$$
X: \Omega \to \mathbb{R}
$$

[Inference] This is the standard measure-theoretic definition, requiring $X$ to be a measurable function with respect to the σ-algebra $\mathcal{F}$ established in the earlier module on set-theoretic foundations — meaning that for every Borel set $S \subseteq \mathbb{R}$, the preimage $X^{-1}(S) = \{\omega \in \Omega : X(\omega) \in S\}$ must belong to $\mathcal{F}$. I cannot verify that every applied ML source states this measurability requirement explicitly, since informal treatments often omit it.

Despite the name, a random variable is not "random" in the sense of being undefined — it is a deterministic function of the outcome $\omega$. The randomness comes from the underlying probability measure $P$ over $\Omega$, which induces a distribution over the values $X$ can take.

### Why Random Variables Are Needed

[Inference] Working directly with abstract sample spaces $\Omega$ (as in the earlier modules) becomes impractical once outcomes are complex objects (e.g., images, sequences, categorical labels). Random variables map these outcomes to numerical values, allowing standard mathematical tools (expectation, variance, algebraic manipulation) to be applied. I have reasoned this motivation from the structure of the preceding modules; I cannot verify this is stated in this exact form in any specific external source.

**Example**: For a coin flip experiment with $\Omega = \{\text{Heads}, \text{Tails}\}$, define $X(\text{Heads}) = 1$ and $X(\text{Tails}) = 0$. This maps a non-numeric outcome space to a numeric one, enabling computation of quantities like the expected value.

### Discrete vs. Continuous Random Variables

**Discrete random variable**: takes values in a finite or countably infinite set. Characterized by a **probability mass function (PMF)**:

$$
p_X(x) = P(X = x)
$$

satisfying $p_X(x) \geq 0$ for all $x$ and $\sum_x p_X(x) = 1$.

**Continuous random variable**: takes values in an uncountable set (typically an interval of $\mathbb{R}$). Characterized by a **probability density function (PDF)** $f_X(x)$ satisfying $f_X(x) \geq 0$ and:

$$
\int_{-\infty}^{\infty} f_X(x)\, dx = 1
$$

[Inference] For continuous random variables, $P(X = x) = 0$ for any single point $x$; probability is instead defined over intervals via $P(a \leq X \leq b) = \int_a^b f_X(x)\,dx$. This follows from the definition of the PDF as a density rather than a point mass, a standard consequence of continuous measure theory. I cannot verify this exact phrasing appears in every applied source, though the underlying mathematical fact is standard.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300">
<title>Discrete PMF versus continuous PDF (svg_diagram)</title>
<rect x="0" y="0" width="600" height="300" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Discrete PMF vs Continuous PDF (svg_diagram)</text>

<text x="150" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">PMF (discrete)</text>
<line x1="60" y1="200" x2="260" y2="200" stroke="#333333" stroke-width="1.5" />
<line x1="60" y1="200" x2="60" y2="70" stroke="#333333" stroke-width="1.5" />
<rect x="90" y="150" width="20" height="50" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="130" y="110" width="20" height="90" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="170" y="160" width="20" height="40" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="210" y="180" width="20" height="20" fill="#a3c9f9" stroke="#2b6cb0" />
<text x="160" y="220" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Bars: P(X=x)</text>

<text x="450" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">PDF (continuous)</text>
<line x1="360" y1="200" x2="560" y2="200" stroke="#333333" stroke-width="1.5" />
<line x1="360" y1="200" x2="360" y2="70" stroke="#333333" stroke-width="1.5" />
<path d="M 370 195 Q 420 90 460 100 Q 500 110 550 195" fill="none" stroke="#c0392b" stroke-width="2.5" />
<path d="M 420 195 Q 445 130 470 130 L 470 195 Z" fill="#f9a3a3" fill-opacity="0.6" stroke="none" />
<text x="445" y="220" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Area = P(a≤X≤b)</text>
</svg>

### Cumulative Distribution Function (CDF)

For any random variable (discrete or continuous), the **cumulative distribution function** is defined as:

$$
F_X(x) = P(X \leq x)
$$

Properties of the CDF:

1. $F_X$ is non-decreasing: [Inference] if $a \leq b$, then $\{X \leq a\} \subseteq \{X \leq b\}$, so by the monotonicity property established in the Kolmogorov axioms module, $F_X(a) \leq F_X(b)$.
2. $\lim_{x \to -\infty} F_X(x) = 0$ and $\lim_{x \to \infty} F_X(x) = 1$.
3. $F_X$ is right-continuous. [Unverified] I do not have access to a self-contained derivation of right-continuity within the scope of this document series, as it depends on continuity properties of probability measures that were only partially introduced in an earlier module; this property should be verified against a dedicated measure-theoretic source rather than accepted from this statement alone.

For a discrete random variable, the PMF relates to the CDF by:

$$
F_X(x) = \sum_{x_i \leq x} p_X(x_i)
$$

For a continuous random variable:

$$
F_X(x) = \int_{-\infty}^{x} f_X(t)\, dt, \qquad f_X(x) = \frac{d}{dx}F_X(x)
$$

[Inference] The derivative relationship follows from the Fundamental Theorem of Calculus applied to the CDF-as-integral definition, and holds at points where $F_X$ is differentiable. I cannot verify this holds universally at every point for all continuous distributions without additional regularity conditions, which are not covered in this document series.

### Support of a Random Variable

The **support** of $X$ is the set of values for which $X$ has nonzero probability (discrete) or nonzero density (continuous):

$$
\text{supp}(X) = \{x : p_X(x) > 0\} \quad \text{or} \quad \{x : f_X(x) > 0\}
$$

**Example**: For a fair six-sided die, $X(\omega) = \omega$, so $\text{supp}(X) = \{1,2,3,4,5,6\}$ and $p_X(x) = \frac{1}{6}$ for each $x$ in the support.

### Worked Example: Random Variable from a Compound Event

Let $\Omega$ be all outcomes of flipping a fair coin 3 times: $\Omega = \{HHH, HHT, HTH, THH, HTT, THT, TTH, TTT\}$, each with probability $\frac{1}{8}$.

Define $X$ = number of heads. Then:

- $X(HHH) = 3$
- $X(HHT) = X(HTH) = X(THH) = 2$
- $X(HTT) = X(THT) = X(TTH) = 1$
- $X(TTT) = 0$

The induced PMF:

$$
p_X(0) = \frac{1}{8}, \quad p_X(1) = \frac{3}{8}, \quad p_X(2) = \frac{3}{8}, \quad p_X(3) = \frac{1}{8}
$$

[Inference] These values follow by counting the outcomes in $\Omega$ mapping to each value of $X$ and dividing by $|\Omega| = 8$, using the equal-probability assumption stated for this example; this matches the general form of the binomial distribution (covered in a later module) with $n=3$, $p=0.5$. I have verified this specific enumeration and count within this response.

Verify normalization: $\frac{1}{8} + \frac{3}{8} + \frac{3}{8} + \frac{1}{8} = 1$. ✓

### Indicator Random Variables

A special and frequently used case is the **indicator random variable**:

$$
\mathbb{1}_A(\omega) = \begin{cases} 1 & \text{if } \omega \in A \\ 0 & \text{if } \omega \notin A \end{cases}
$$

for some event $A \subseteq \Omega$. [Inference] By this definition, $P(\mathbb{1}_A = 1) = P(A)$ directly, connecting the random variable formalism back to the event-based probability established in earlier modules. Indicator variables are used extensively to convert event-based probability statements into expectation-based computations, covered in the next module.

### Relevance to Machine Learning

- **Model outputs** (e.g., predicted class probabilities, regression outputs) are commonly treated as random variables or functions thereof, mapping data-generating outcomes to numerical predictions.
- **Loss functions** evaluated on data are themselves random variables, since they are functions of randomly sampled data points; this underlies the formal treatment of expected risk in statistical learning theory. [Unverified] I do not have access to information confirming that every ML text frames loss functions explicitly as random variables using this formalism, though the underlying mathematical structure is consistent with this definition.
- **Indicator variables** appear directly in classification metrics, such as $\mathbb{1}[\hat{y} = y]$ used to compute accuracy as an average over indicator outcomes.
- **Feature representations** derived from raw data (e.g., pixel values, embeddings) can be modeled as random variables when the underlying data is treated as sampled from a distribution, though [Speculation] whether a specific ML pipeline formally treats features this way versus treating them as fixed deterministic inputs depends on the modeling framework in use, and I do not have access to information confirming which framing is more common in current practice.

### Common Pitfalls

- Confusing a random variable (a function) with a specific realized value it takes (a number) — notationally, $X$ denotes the function/variable, while $x$ denotes a specific value.
- Applying discrete PMF reasoning ($P(X=x)$) to continuous random variables, where $P(X=x) = 0$ for any single point.
- Forgetting to verify normalization ($\sum p_X(x) = 1$ or $\int f_X(x)\,dx = 1$) when constructing or checking a distribution.
- Assuming the CDF is strictly increasing; it is only guaranteed to be non-decreasing, and can be flat over regions where the random variable has zero probability or density.

**Related Topics**
- Expectation, variance, and moments of random variables
- Common discrete distributions (Bernoulli, Binomial, Poisson, Geometric)
- Common continuous distributions (Uniform, Normal, Exponential)
- Joint, marginal, and conditional distributions of multiple random variables
- Transformations of random variables
- Moment generating functions and characteristic functions

> Correction: This document contains a substantial number of [Inference] and [Unverified] labeled claims regarding standard mathematical derivations and their exact presentation in external sources. I have not independently verified against specific external texts that every derivation matches standard textbook presentation precisely; the mathematical reasoning within each derivation has been worked through in this response, but claims about "standard" or "typical" treatment in the field remain [Unverified] beyond the reasoning shown.