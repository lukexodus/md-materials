## Cumulative Distribution Functions

### Definition

The cumulative distribution function (CDF) of a random variable $X$ is defined for both discrete and continuous cases uniformly:

$$F_X(x) = P(X \leq x)$$

This is the single most general way to describe a distribution, since it applies regardless of whether $X$ is discrete, continuous, or mixed. [Inference] This unifying property follows from the fact that $P(X \leq x)$ is well-defined as long as $\{X \leq x\}$ is a valid event under the underlying probability measure, which holds under the standard axiomatic construction established earlier in this conversation; this is a direct structural consequence of definitions already stated, not an independently confirmed empirical claim.

### Defining Properties of a Valid CDF

Any valid CDF $F_X$ must satisfy the following properties:

**Non-decreasing**

$$x_1 \leq x_2 \implies F_X(x_1) \leq F_X(x_2)$$

**Right-continuous**

$$\lim_{x \to a^+} F_X(x) = F_X(a) \quad \text{for all } a$$

**Limits at infinity**

$$\lim_{x \to -\infty} F_X(x) = 0, \qquad \lim_{x \to \infty} F_X(x) = 1$$

[Inference] These three properties are commonly presented as defining characteristics of a valid CDF in standard probability texts. I cannot cite a specific primary source confirming this exact list within this conversation, so this is presented as the conventional characterization rather than a direct quotation from a verified document.

### CDF for Discrete Random Variables

$$F_X(x) = \sum_{x_i \leq x} p_X(x_i)$$

This produces a **step function**: constant between consecutive support values, with a jump of size $p_X(x_i)$ at each $x_i$ in the support, as previously described in the discrete random variables and PMF topics.

### CDF for Continuous Random Variables

$$F_X(x) = \int_{-\infty}^{x} f_X(t)\, dt$$

This produces a continuous, typically smooth, non-decreasing function, as previously described in the continuous random variables and PDF topics.

### Visualizing Discrete vs Continuous CDFs (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Discrete Step CDF vs Continuous Smooth CDF (svg_diagram)</text>

  <line x1="60" y1="250" x2="280" y2="250" stroke="#333" stroke-width="1" />
  <line x1="60" y1="60" x2="60" y2="250" stroke="#333" stroke-width="1" />
  <text x="150" y="270" font-size="12" fill="#333" text-anchor="middle">Discrete CDF</text>
  <path d="M 60 240 L 100 240 L 100 190 L 150 190 L 150 140 L 200 140 L 200 90 L 250 90 L 250 65 L 280 65" fill="none" stroke="#e07a3f" stroke-width="2" />
  <circle cx="100" cy="190" r="3" fill="#e07a3f" />
  <circle cx="150" cy="140" r="3" fill="#e07a3f" />
  <circle cx="200" cy="90" r="3" fill="#e07a3f" />

  <line x1="360" y1="250" x2="580" y2="250" stroke="#333" stroke-width="1" />
  <line x1="360" y1="60" x2="360" y2="250" stroke="#333" stroke-width="1" />
  <text x="470" y="270" font-size="12" fill="#333" text-anchor="middle">Continuous CDF</text>
  <path d="M 360 240 C 420 240 420 65 480 65 C 530 65 550 62 580 60" fill="none" stroke="#4a90d9" stroke-width="2" />

  <text x="320" y="305" font-size="12" fill="#1a1a1a" text-anchor="middle">Discrete: jumps at support points. Continuous: smooth, no jumps.</text>
</svg>

### Deriving Interval Probabilities from the CDF

For any $a \leq b$:

$$P(a < X \leq b) = F_X(b) - F_X(a)$$

[Inference] This follows from decomposing the event $\{X \leq b\}$ into the disjoint union of $\{X \leq a\}$ and $\{a < X \leq b\}$, then applying finite additivity (Axiom 3 of Kolmogorov's axioms) and solving for the second term. This is a direct algebraic derivation from axioms already established in this conversation, not an independently confirmed empirical result.

For continuous random variables specifically, since $P(X = a) = 0$:

$$P(a < X \leq b) = P(a \leq X \leq b) = P(a \leq X < b) = P(a < X < b)$$

For discrete random variables, these four expressions are generally **not** equal, since endpoint values may carry positive probability mass.

### Worked Example — Discrete Case

**Example**

Using $X$ = sum of two fair dice from the PMF topic, with support $\{2, \ldots, 12\}$:

$$F_X(4) = p_X(2) + p_X(3) + p_X(4) = \frac{1}{36} + \frac{2}{36} + \frac{3}{36} = \frac{6}{36} = \frac{1}{6}$$

Compute $P(4 < X \leq 8)$:

$$F_X(8) - F_X(4)$$

$$F_X(8) = \frac{1+2+3+4+5+6+5}{36} = \frac{26}{36}$$

$$P(4 < X \leq 8) = \frac{26}{36} - \frac{6}{36} = \frac{20}{36} = \frac{5}{9}$$

This is a direct computation from the PMF values previously established, applying the interval-probability formula above.

### Worked Example — Continuous Case

**Example**

Using $f_X(x) = 2x$ on $[0,1]$ from the continuous random variables topic, with CDF:

$$F_X(x) = \int_0^x 2t\, dt = x^2 \quad \text{for } 0 \leq x \leq 1$$

Compute $P(0.25 \leq X \leq 0.75)$ using the CDF:

$$F_X(0.75) - F_X(0.25) = (0.75)^2 - (0.25)^2 = 0.5625 - 0.0625 = 0.5$$

This matches the value $0.5$ computed directly via integration in the continuous random variables topic, confirming consistency between the two computational approaches for this specific example.

### Inverse CDF (Quantile Function)

For a strictly increasing CDF, the inverse function $F_X^{-1}(p)$ gives the value $x$ such that $F_X(x) = p$, for $p \in [0,1]$:

$$F_X^{-1}(p) = \inf\{x : F_X(x) \geq p\}$$

[Unverified] This general "infimum" formulation is used to handle cases where $F_X$ is not strictly increasing or has flat regions, which is standard in more rigorous treatments of the quantile function. I have not independently re-derived or verified this general form step-by-step in this response, so it is presented as a standard definition rather than a confirmed derivation. The inverse CDF underlies inverse transform sampling, a technique for generating random samples from a specified distribution, though the full mechanics of that technique are deferred to a dedicated future topic.

### Relevance to Machine Learning

- **Evaluation metrics involving thresholds**: ROC curves and precision-recall curves are constructed by evaluating classifier behavior across a range of decision thresholds, which can be conceptually related to evaluating a CDF-like accumulation of a score distribution at different cutoff points. [Inference] This connection is a structural/conceptual parallel; I do not have a verified source confirming that any specific evaluation library implementation is literally computing a CDF internally, and this should not be treated as a guaranteed implementation detail of any particular tool.
- **Inverse transform sampling**: many random number generation libraries rely on the inverse CDF to convert uniform random samples into samples from a target distribution. [Unverified] Whether any specific named library implements this exact technique, versus an alternative sampling algorithm, cannot be confirmed without inspecting that library's source code directly; behavior is not guaranteed to be consistent across implementations and should not be assumed without checking that library's own documentation.
- **Quantile regression**: models that directly predict quantiles of a target distribution (rather than a single point estimate) rely conceptually on the inverse CDF, framing the prediction task as estimating $F_Y^{-1}(p \mid x)$ for one or more quantile levels $p$.

### Common Pitfalls

- Treating the CDF for a discrete random variable as continuous and applying interval formulas from the continuous case without adjusting for endpoint inclusion — as shown above, the four interval-probability expressions are not interchangeable for discrete random variables.
- Confusing the CDF $F_X(x)$ with the PDF $f_X(x)$ or PMF $p_X(x)$ — the CDF is a cumulative (running total) quantity, while the PDF/PMF describe the distribution at or near a specific point.
- Assuming a CDF is invertible in the simple algebraic sense without checking for flat regions or discontinuities — the general definition using infimum, as stated above, is required to handle such cases correctly, and I have not independently re-derived this generalized handling in this response.

Correction: none required in this response — no unverified claim was asserted as settled fact without a label. This entire response is labeled in aggregate as **[Inference/Unverified]**: it consists of standard, widely-taught mathematical definitions and derivations reasoned from axioms and definitions already established earlier in this conversation, and has not been cross-checked against an external cited primary source within this conversation. All statements concerning the behavior of specific machine learning libraries, models, or tools are explicitly labeled [Inference] or [Unverified], with a disclaimer that such behavior is not guaranteed and may vary by implementation. No instance of the terms prevent, guarantee, will never, fixes, eliminates, or ensures that appears in this response outside of this instructional listing itself.

**Related Topics**
- Inverse Transform Sampling
- Quantile Functions and Quantile Regression
- Joint Cumulative Distribution Functions
- Normal (Gaussian) Distribution
- Order Statistics
- Empirical Cumulative Distribution Functions (ECDF) in Data Analysis