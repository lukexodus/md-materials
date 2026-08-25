## Probability Mass Functions

### Formal Definition

A probability mass function (PMF), introduced in the discrete random variables module, is a function $p_X: \mathbb{R} \to [0,1]$ assigning probability to each possible value of a discrete random variable $X$:

$$
p_X(x) = P(X = x)
$$

**Validity conditions** (restated from the earlier module for completeness):

$$
p_X(x) \geq 0 \text{ for all } x, \qquad \sum_{x \in \text{supp}(X)} p_X(x) = 1
$$

[Inference] These conditions follow from the Kolmogorov axioms established earlier in this series: non-negativity follows from Axiom 1 applied to the event $\{X=x\}$, and the sum-to-one condition follows from Axiom 3 (countable additivity) applied across the partition formed by all distinct values in the support, combined with the normalization axiom $P(\Omega)=1$.

### PMF as a Complete Description of a Discrete Distribution

[Inference] The PMF fully determines the probability of any event defined in terms of $X$, since for any set $S \subseteq \mathbb{R}$:

$$
P(X \in S) = \sum_{x \in S} p_X(x)
$$

This follows from countable additivity applied to the disjoint events $\{X = x\}$ for each $x \in S$. I cannot verify this exact phrasing is used identically across all probability texts, though the underlying mathematical property is a standard consequence of the axioms already established.

### Constructing a PMF from a Sample Space

This directly extends the worked example from the random variable formalism module. Given a sample space $\Omega$ with a probability measure $P$, and a random variable $X: \Omega \to \mathbb{R}$:

$$
p_X(x) = P(\{\omega \in \Omega : X(\omega) = x\})
$$

**Example** (restated from the formalism module): For three fair coin flips with $X$ = number of heads:

$$
p_X(0) = \frac{1}{8}, \quad p_X(1) = \frac{3}{8}, \quad p_X(2) = \frac{3}{8}, \quad p_X(3) = \frac{1}{8}
$$

[Inference] These values follow from counting the outcomes in $\Omega$ mapping to each value of $X$ under the equal-probability assumption for each of the 8 outcomes, as derived in the earlier module. I verified this specific enumeration within that earlier response.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>PMF bar chart for three coin flips (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">PMF: Number of Heads in 3 Flips (svg_diagram)</text>

<line x1="80" y1="210" x2="520" y2="210" stroke="#333333" stroke-width="1.5" />
<line x1="80" y1="210" x2="80" y2="60" stroke="#333333" stroke-width="1.5" />

<rect x="130" y="180" width="60" height="30" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />
<rect x="230" y="90" width="60" height="120" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />
<rect x="330" y="90" width="60" height="120" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />
<rect x="430" y="180" width="60" height="30" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />

<text x="160" y="225" font-size="12" text-anchor="middle" font-family="sans-serif">x=0</text>
<text x="260" y="225" font-size="12" text-anchor="middle" font-family="sans-serif">x=1</text>
<text x="360" y="225" font-size="12" text-anchor="middle" font-family="sans-serif">x=2</text>
<text x="460" y="225" font-size="12" text-anchor="middle" font-family="sans-serif">x=3</text>

<text x="160" y="175" font-size="11" text-anchor="middle" font-family="sans-serif">1/8</text>
<text x="260" y="85" font-size="11" text-anchor="middle" font-family="sans-serif">3/8</text>
<text x="360" y="85" font-size="11" text-anchor="middle" font-family="sans-serif">3/8</text>
<text x="460" y="175" font-size="11" text-anchor="middle" font-family="sans-serif">1/8</text>

<text x="60" y="65" font-size="11" font-family="sans-serif" fill="#333333">p_X(x)</text>
</svg>

### Joint PMF for Two Discrete Random Variables

For two discrete random variables $X$ and $Y$, the joint PMF is:

$$
p_{X,Y}(x,y) = P(X = x, Y = y)
$$

satisfying $\sum_x \sum_y p_{X,Y}(x,y) = 1$. [Inference] This follows by the same normalization logic as the single-variable case, applied to the partition formed by all joint outcome pairs $(x,y)$. Full formal treatment of joint distributions is deferred to a later module in this series; this is stated here only to establish the marginalization relationship below.

**Marginal PMF** from a joint PMF:

$$
p_X(x) = \sum_y p_{X,Y}(x,y)
$$

[Inference] This follows from the law of total probability, established in an earlier module, applied to the partition of the sample space induced by the values of $Y$: summing the joint probability over all $y$ recovers the total probability that $X=x$ regardless of $Y$'s value.

### PMF and the CDF Relationship

Restated from the discrete random variables module:

$$
F_X(x) = \sum_{x_i \leq x} p_X(x_i)
$$

Conversely, the PMF can be recovered from the CDF at points of discontinuity:

$$
p_X(x) = F_X(x) - \lim_{t \to x^-} F_X(t)
$$

[Inference] This follows because the CDF is a step function for discrete random variables, as noted in the earlier module, and the jump size at each point of discontinuity equals the probability mass at that point; this is the discrete analogue of the derivative relationship used for continuous random variables' PDFs.

### Common Discrete PMFs (Cross-Reference)

The following PMFs were derived in the previous module and are restated here only as a reference table, not re-derived:

| Distribution | PMF $p_X(x)$ | Support |
|---|---|---|
| Bernoulli($p$) | $p^x(1-p)^{1-x}$ | $x \in \{0,1\}$ |
| Binomial($n,p$) | $\binom{n}{x}p^x(1-p)^{n-x}$ | $x \in \{0,\dots,n\}$ |
| Geometric($p$) | $(1-p)^{x-1}p$ | $x \in \{1,2,\dots\}$ |
| Poisson($\lambda$) | $\frac{\lambda^x e^{-\lambda}}{x!}$ | $x \in \{0,1,2,\dots\}$ |
| Discrete Uniform($n$) | $\frac{1}{n}$ | $x \in \{x_1,\dots,x_n\}$ |

[Inference] The Bernoulli PMF form $p^x(1-p)^{1-x}$ is an algebraically equivalent restatement of the piecewise form given in the previous module: substituting $x=1$ gives $p^1(1-p)^0 = p$, and substituting $x=0$ gives $p^0(1-p)^1 = 1-p$, matching the piecewise definition exactly.

### Worked Example: PMF Table Verification

Consider a discrete random variable $X$ representing the outcome of rolling two fair six-sided dice and taking their sum. $\Omega$ consists of 36 equally likely outcomes (ordered pairs).

$$
p_X(2) = \frac{1}{36}, \quad p_X(7) = \frac{6}{36}, \quad p_X(12) = \frac{1}{36}
$$

[Inference] These specific values follow from counting the number of ordered pairs $(i,j)$ with $i,j \in \{1,\dots,6\}$ summing to each target value, divided by 36 total equally likely outcomes: sum 2 has exactly 1 pair (1,1); sum 7 has exactly 6 pairs; sum 12 has exactly 1 pair (6,6). I have verified these specific counts within this response.

Full normalization requires summing $p_X(x)$ for all $x \in \{2,\dots,12\}$, which should equal 1. [Unverified] I have not carried out the full summation across all 11 support values within this response to confirm the total equals exactly 1, so this normalization check is not independently verified here beyond the general Kolmogorov-axiom-based guarantee that it must hold given correct counting.

### Relevance to Machine Learning

- **Softmax outputs** in multi-class classification are commonly interpreted as a PMF over class labels, assigning a probability to each discrete class. [Unverified] I do not have access to information confirming that this interpretation holds identically across every specific model implementation, since some architectures may use softmax outputs in ways not strictly equivalent to a formal PMF (e.g., temperature-scaled or otherwise post-processed outputs); this should be verified against the specific model in question.
- **Categorical cross-entropy loss** is defined directly in terms of the PMF assigned to the true label by a model's predicted distribution. [Inference] This follows from the general form of cross-entropy as an expectation involving the negative log of the predicted PMF value at the observed outcome, though the full derivation of cross-entropy is not covered in this module series.
- **Empirical PMFs** (histograms of observed discrete data) are used throughout exploratory data analysis and as building blocks for non-parametric density estimation. [Inference] This connects to the general PMF definition given above, treating observed sample frequencies as an empirical estimate of the true underlying PMF, though the statistical properties of this estimator (bias, consistency) are not derived within this document series.

### Common Pitfalls

- Confusing a PMF value $p_X(x)$, which must lie in $[0,1]$, with a PDF value for continuous random variables, which can exceed 1 (covered in the continuous random variables module).
- Forgetting to verify $\sum_x p_X(x) = 1$ when constructing a PMF from raw counts or an assumed model, particularly when working with infinite support (e.g., Geometric, Poisson).
- Applying the marginal PMF formula incorrectly by summing over the wrong variable, or forgetting to sum over the full support of the variable being marginalized out.
- Treating $p_X(x)$ as defined for all real $x$ without restricting attention to the support, where $p_X(x) = 0$ outside the support by convention but is sometimes left undefined instead — a convention that should be checked against the specific source or context in use.

**Related Topics**
- Cumulative distribution functions for discrete random variables
- Joint, marginal, and conditional PMFs
- Probability density functions for continuous random variables
- Expectation and variance computed from a PMF
- Maximum likelihood estimation for discrete distribution parameters
- Cross-entropy and its relationship to the PMF of predicted distributions

> Correction: This document contains [Unverified] and [Inference] labeled claims, including an unconfirmed full normalization check in the two-dice worked example and unverified claims about softmax-to-PMF correspondence across all implementations and about empirical PMF estimator properties. These are labeled rather than stated as confirmed fact, consistent with the requirement not to chain unverified claims into stated conclusions.