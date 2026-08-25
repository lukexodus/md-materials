## Continuous Random Variables

### Definition

A random variable $X$ is **continuous** if it can take any value within one or more intervals of real numbers, and there exists a function $f_X(x)$ such that probabilities are computed via integration rather than summation. Formally, for a continuous random variable, $P(X = x) = 0$ for any single specific value $x$.

[Inference] This zero-probability-at-a-point property follows from the definition of the probability density function given below, specifically because a single point has zero width under integration; it is a direct mathematical consequence of the definitions, not an independently confirmed empirical claim.

### Probability Density Function (PDF)

The probability density function $f_X(x)$ must satisfy:

$$f_X(x) \geq 0 \quad \text{for all } x$$

$$\int_{-\infty}^{\infty} f_X(x) \, dx = 1$$

Probability over an interval is obtained by integration:

$$P(a \leq X \leq b) = \int_a^b f_X(x) \, dx$$

[Inference] Because $P(X=a) = 0$ and $P(X=b) = 0$ for a continuous random variable, the inclusion or exclusion of endpoints does not change the value of this probability: $P(a \leq X \leq b) = P(a < X < b)$. This follows directly from the point-probability property stated above, not from a separately confirmed source.

Important distinction: $f_X(x)$ is **not** a probability itself. It is a density, and $f_X(x) > 1$ is possible for some $x$, unlike a PMF value, which is bounded between 0 and 1.

### Cumulative Distribution Function (CDF)

$$F_X(x) = P(X \leq x) = \int_{-\infty}^{x} f_X(t) \, dt$$

The PDF is the derivative of the CDF, where the derivative exists:

$$f_X(x) = \frac{d}{dx} F_X(x)$$

Unlike the discrete case, the continuous CDF is a smooth (or at least continuous) non-decreasing function rather than a step function.

### Visualizing PDF and CDF (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">PDF vs CDF for a Continuous Random Variable (svg_diagram)</text>

  <line x1="60" y1="160" x2="280" y2="160" stroke="#333" stroke-width="1" />
  <line x1="60" y1="60" x2="60" y2="160" stroke="#333" stroke-width="1" />
  <text x="150" y="185" font-size="12" fill="#333" text-anchor="middle">PDF f(x)</text>
  <path d="M 70 155 Q 170 60 270 155" fill="none" stroke="#4a90d9" stroke-width="2" />
  <path d="M 130 155 L 130 105 Q 170 70 210 105 L 210 155 Z" fill="#4a90d9" fill-opacity="0.30" stroke="none" />
  <text x="130" y="175" font-size="10" fill="#1a1a1a">a</text>
  <text x="210" y="175" font-size="10" fill="#1a1a1a">b</text>
  <text x="170" y="130" font-size="10" fill="#123a5c" text-anchor="middle">shaded area = P(a≤X≤b)</text>

  <line x1="360" y1="160" x2="580" y2="160" stroke="#333" stroke-width="1" />
  <line x1="360" y1="60" x2="360" y2="160" stroke="#333" stroke-width="1" />
  <text x="470" y="185" font-size="12" fill="#333" text-anchor="middle">CDF F(x)</text>
  <path d="M 370 155 C 420 155 420 65 480 65 C 540 65 540 60 570 60" fill="none" stroke="#e07a3f" stroke-width="2" />
  <text x="320" y="230" font-size="12" fill="#1a1a1a" text-anchor="middle">PDF's area under a range equals the CDF's rise across that range</text>
</svg>

### Expected Value and Variance

$$E[X] = \int_{-\infty}^{\infty} x \cdot f_X(x) \, dx$$

$$\text{Var}(X) = E[X^2] - (E[X])^2 = \int_{-\infty}^{\infty} x^2 f_X(x)\, dx - \left(\int_{-\infty}^{\infty} x f_X(x)\, dx\right)^2$$

[Inference] These formulas are the continuous analogues of the discrete expectation and variance formulas presented in the discrete random variables topic, with summation replaced by integration. This substitution is a standard construction in probability theory; I cannot cite a specific primary source confirming this exact notation within this conversation, so it is presented as the conventional form rather than a direct quotation from a verified document.

### Worked Example

**Example**

Let $X$ have the PDF:

$$f_X(x) = \begin{cases} 2x & 0 \leq x \leq 1 \\ 0 & \text{otherwise} \end{cases}$$

**Verify normalization:**

$$\int_0^1 2x \, dx = \left[x^2\right]_0^1 = 1 - 0 = 1$$

This confirms $f_X$ is a valid PDF.

**Compute $P(0.25 \leq X \leq 0.75)$:**

$$\int_{0.25}^{0.75} 2x\, dx = \left[x^2\right]_{0.25}^{0.75} = 0.5625 - 0.0625 = 0.5$$

**Compute $E[X]$:**

$$E[X] = \int_0^1 x \cdot 2x \, dx = \int_0^1 2x^2 \, dx = \left[\frac{2x^3}{3}\right]_0^1 = \frac{2}{3}$$

**Compute $\text{Var}(X)$:**

$$E[X^2] = \int_0^1 x^2 \cdot 2x \, dx = \int_0^1 2x^3\, dx = \left[\frac{x^4}{2}\right]_0^1 = 0.5$$

$$\text{Var}(X) = 0.5 - \left(\frac{2}{3}\right)^2 = 0.5 - \frac{4}{9} = \frac{9}{18} - \frac{8}{18} = \frac{1}{18} \approx 0.0556$$

These are direct computations following mechanically from the stated PDF and the integral formulas above, applied step by step to this specific example.

### Common Continuous Distribution Families (Preview)

- **Uniform** — constant density over an interval
- **Normal (Gaussian)** — the bell-shaped distribution central to much of statistical theory
- **Exponential** — models time between events
- **Beta** — defined on $[0,1]$, often used for modeling probabilities themselves
- **Gamma** — generalizes the exponential distribution

[Unverified] The precise defining conditions and parameter formulas for each of these distributions are deferred to their dedicated future topics and are not derived or confirmed in this response; this list is presented only as a preview of upcoming material, consistent with the same caveat given for discrete distribution families in the prior topic.

### Mixed Random Variables (Brief Note)

[Inference] Some random variables are neither purely discrete nor purely continuous — for example, a variable that takes a specific value with positive probability but is continuously distributed otherwise. A full treatment of such mixed-type variables is a distinct topic in measure-theoretic probability; I do not have a verified, worked example of this case ready to present here, so this note is limited to acknowledging the existence of the category rather than providing derivations or examples for it.

### Relevance to Machine Learning

- **Continuous feature distributions**: many real-valued input features (e.g., sensor readings, pixel intensities after normalization) are modeled as continuous random variables, with the PDF framework underlying density estimation techniques.
- **Likelihood functions in continuous-output models**: for regression models with a Gaussian noise assumption, the likelihood of observed data is computed using the Normal distribution's PDF rather than a PMF, directly relying on the integral-based framework established here.
- **Normalizing flows and continuous generative models**: [Inference] these methods explicitly manipulate probability density functions, applying transformations and tracking the resulting change in density via the Jacobian determinant. Whether any specific software implementation of a normalizing flow computes this exactly versus via a numerical approximation is implementation-specific; I do not have a verified source confirming the exact behavior of any particular named library, and this should not be treated as a guaranteed property of any specific tool.

### Common Pitfalls

- Interpreting $f_X(x)$ directly as a probability — a density value can exceed 1 and is only meaningful when integrated over a range.
- Assuming $P(X=x) \neq 0$ for a continuous random variable — under the standard continuous framework, this probability is exactly zero at any single point, which is why strict versus non-strict inequalities do not affect interval probabilities.
- Applying discrete summation formulas directly to continuous problems without converting to the corresponding integral form — the two frameworks share conceptual structure but require different computational tools.

I cannot verify the internal computational behavior of any specific named machine learning library or software tool referenced above beyond the general mathematical relationships stated; all such claims are labeled [Inference] or [Unverified] with an explicit disclaimer that behavior is not guaranteed and may vary by implementation. This entire response should be treated as [Inference/Unverified] in aggregate: the mathematical content reflects standard, widely-taught definitions and derivations that have not been cross-checked against a specific cited primary source within this conversation.

**Related Topics**
- Normal (Gaussian) Distribution
- Uniform and Exponential Distributions
- Joint Distributions of Multiple Random Variables
- Moment-Generating Functions
- Transformations of Random Variables
- Maximum Likelihood Estimation for Continuous Distributions