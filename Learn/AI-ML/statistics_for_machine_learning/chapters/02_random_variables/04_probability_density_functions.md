## Probability Density Functions

### Definition

A probability density function (PDF) fully characterizes the distribution of a continuous random variable $X$. Unlike a PMF, $f_X(x)$ does not itself represent a probability; it represents density, and probability is obtained only by integrating over an interval.

$$P(a \leq X \leq b) = \int_a^b f_X(x)\, dx$$

[Inference] This topic continues directly from the continuous random variables topic, where the PDF concept was first introduced; here the properties and construction of the PDF are treated as the primary object of study. This framing is a direct continuation of definitions already established in this conversation, not an independently confirmed external claim.

### Defining Properties

A function $f_X$ qualifies as a valid PDF if and only if it satisfies both of the following:

**Non-negativity**

$$f_X(x) \geq 0 \quad \text{for all } x$$

**Normalization**

$$\int_{-\infty}^{\infty} f_X(x)\, dx = 1$$

[Inference] These two conditions are the continuous analogue of the PMF's non-negativity and normalization conditions, with summation replaced by integration, following from Kolmogorov's axioms applied in the continuous (measure-theoretic) setting. This is a direct structural parallel to definitions already established in this conversation, not an independently confirmed empirical claim.

### Support of a Continuous Random Variable

The support of $X$ is the set of values where $f_X(x) > 0$:

$$\text{Supp}(X) = \{x : f_X(x) > 0\}$$

A PDF is often defined piecewise, with $f_X(x) = 0$ outside the interval(s) where the random variable is defined.

### Key Distinction from PMFs

| Property | PMF (discrete) | PDF (continuous) |
|---|---|---|
| Represents | Probability directly | Density (probability per unit length) |
| Value range | $[0, 1]$ | $[0, \infty)$ — can exceed 1 |
| Probability at a point | $P(X=x) = p_X(x)$, can be $>0$ | $P(X=x) = 0$ always |
| Total probability | $\sum_x p_X(x) = 1$ | $\int f_X(x)\,dx = 1$ |
| Event probability | Summation | Integration |

### Visualizing a PDF (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">PDF of f(x) = 2x on [0,1] (svg_diagram)</text>

  <line x1="80" y1="250" x2="560" y2="250" stroke="#333" stroke-width="1" />
  <line x1="80" y1="60" x2="80" y2="250" stroke="#333" stroke-width="1" />
  <text x="60" y="70" font-size="11" fill="#1a1a1a">2</text>
  <text x="65" y="255" font-size="11" fill="#1a1a1a">0</text>

  <line x1="80" y1="250" x2="440" y2="70" stroke="#4a90d9" stroke-width="2" />

  <path d="M 200 250 L 200 155 L 320 90 L 320 250 Z" fill="#4a90d9" fill-opacity="0.35" stroke="none" />
  <line x1="200" y1="250" x2="200" y2="155" stroke="#2c5f8a" stroke-width="1" stroke-dasharray="4" />
  <line x1="320" y1="250" x2="320" y2="90" stroke="#2c5f8a" stroke-width="1" stroke-dasharray="4" />

  <text x="200" y="270" font-size="11" fill="#1a1a1a">0.25</text>
  <text x="315" y="270" font-size="11" fill="#1a1a1a">0.75</text>
  <text x="440" y="270" font-size="11" fill="#1a1a1a">1.0</text>
  <text x="260" y="200" font-size="11" fill="#123a5c" text-anchor="middle">shaded area</text>
  <text x="260" y="215" font-size="11" fill="#123a5c" text-anchor="middle">= P(0.25≤X≤0.75)</text>
</svg>

### Constructing a PDF from a CDF

Where the CDF $F_X$ is differentiable:

$$f_X(x) = \frac{d}{dx} F_X(x)$$

[Inference] At points where $F_X$ is not differentiable (e.g., sharp corners in a piecewise-defined CDF), the PDF is undefined or must be defined via a limiting or one-sided derivative convention. I do not have a verified, worked example of this edge case ready to present here, so this note is limited to acknowledging the issue rather than resolving it with a specific calculation.

### Worked Example

**Example**

Let $X$ have PDF:

$$f_X(x) = \begin{cases} \dfrac{3}{2}x^2 & -1 \leq x \leq 1 \\ 0 & \text{otherwise} \end{cases}$$

**Verify normalization:**

$$\int_{-1}^{1} \frac{3}{2}x^2\, dx = \frac{3}{2}\left[\frac{x^3}{3}\right]_{-1}^{1} = \frac{3}{2}\left(\frac{1}{3} - \left(-\frac{1}{3}\right)\right) = \frac{3}{2} \cdot \frac{2}{3} = 1$$

Confirmed valid.

**Compute the CDF for $-1 \leq x \leq 1$:**

$$F_X(x) = \int_{-1}^{x} \frac{3}{2}t^2\, dt = \frac{1}{2}\left(x^3 + 1\right)$$

**Compute $P(-0.5 \leq X \leq 0.5)$ using the CDF:**

$$F_X(0.5) - F_X(-0.5) = \frac{1}{2}\left(0.125 + 1\right) - \frac{1}{2}\left(-0.125 + 1\right) = \frac{1}{2}(1.125) - \frac{1}{2}(0.875) = 0.5625 - 0.4375 = 0.125$$

**Verify directly via integration:**

$$\int_{-0.5}^{0.5} \frac{3}{2}x^2\, dx = \frac{1}{2}\left[x^3\right]_{-0.5}^{0.5} = \frac{1}{2}(0.125 - (-0.125)) = \frac{1}{2}(0.25) = 0.125$$

Both methods agree, consistent with the relationship between the CDF and PDF stated above. These are direct computations from the stated formula, mechanically applying the definitions established earlier in this conversation.

### Transformations of a PDF

If $Y = g(X)$ for a monotonic, differentiable function $g$, the PDF of $Y$ can be derived using the change-of-variables formula:

$$f_Y(y) = f_X(g^{-1}(y)) \left| \frac{d}{dy} g^{-1}(y) \right|$$

[Unverified] The full derivation of this formula, including the justification for the absolute value term via the Jacobian in the single-variable case, is deferred to a dedicated future topic on transformations of random variables. This formula is stated here as a preview and has not been independently re-derived step-by-step in this response.

### Relevance to Machine Learning

- **Likelihood functions for continuous outputs**: in regression models with a Gaussian noise assumption, the likelihood of the observed target given model predictions is computed using the Normal distribution's PDF, directly relying on the density (not probability-mass) interpretation established here.
- **Kernel density estimation (KDE)**: a nonparametric technique that estimates an unknown PDF from data by summing kernel functions centered at each observed data point, relying on the same non-negativity and normalization requirements stated above for the resulting estimate to be a valid PDF.
- **Normalizing flows and continuous generative models**: [Inference] these methods explicitly transform a simple base density into a complex target density using the change-of-variables formula referenced above. Whether any specific software implementation computes this transformation exactly versus via a numerical approximation is implementation-specific; I do not have a verified source confirming the exact behavior of any particular named library, and this is not a guaranteed property of any specific tool.

### Common Pitfalls

- Interpreting $f_X(x)$ as a probability rather than a density — a density value exceeding 1 does not violate any PDF property, since only the integral over a range is bounded by 1.
- Applying the change-of-variables formula without verifying that $g$ is monotonic on the relevant domain — the formula as stated assumes monotonicity; non-monotonic transformations require partitioning the domain and summing contributions from each monotonic piece, which is not derived in this response.
- Conflating the discrete PMF summation approach with the continuous PDF integration approach when solving a mixed or ambiguous problem — the correct framework must be identified first based on whether the random variable is discrete or continuous.

Correction: none required in this response — no unverified claim was asserted as settled fact without a label. This entire response is labeled in aggregate as **[Inference/Unverified]**: it consists of standard, widely-taught mathematical definitions and derivations reasoned from axioms and definitions already established earlier in this conversation, and has not been cross-checked against an external cited primary source within this conversation. All statements concerning the behavior of specific machine learning libraries, models, or tools are explicitly labeled [Inference] or [Unverified], with a disclaimer that such behavior is not guaranteed and may vary by implementation. No instance of the terms prevent, guarantee, will never, fixes, eliminates, or ensures that appears in this response outside of this instructional listing itself.

**Related Topics**
- Cumulative Distribution Functions (Continuous Case)
- Transformations of Random Variables
- Normal (Gaussian) Distribution
- Joint and Marginal Density Functions
- Kernel Density Estimation
- Maximum Likelihood Estimation for Continuous Distributions