## Exponential and Logarithmic Functions

### Exponential Functions

An exponential function has the general form:

$$f(x) = a \cdot b^x, \quad b > 0, \ b \neq 1$$

The most common base in calculus and machine learning is Euler's number $e \approx 2.71828$:

$$f(x) = e^x$$

**Key Points**

- Domain: $\mathbb{R}$
- Range: $(0, \infty)$
- Always positive, never zero, regardless of input sign
- Strictly increasing if $b > 1$; strictly decreasing if $0 < b < 1$
- $e^0 = 1$ for all valid bases

#### Defining Property: Derivative Equals Itself

$$\frac{d}{dx}e^x = e^x$$

This is a defining characteristic of the natural exponential function and is why $e$ is the preferred base in calculus-based derivations. This is a verifiable mathematical property, not [Inference].

For a general base $b$:

$$\frac{d}{dx}b^x = b^x \ln(b)$$

**Example**

$$\frac{d}{dx}(3^x) = 3^x \ln(3)$$

### Logarithmic Functions

The logarithm is the inverse of the exponential function. For base $b$:

$$y = \log_b(x) \iff b^y = x$$

The **natural logarithm** (base $e$) is denoted $\ln(x)$:

$$y = \ln(x) \iff e^y = x$$

**Key Points**

- Domain: $(0, \infty)$
- Range: $\mathbb{R}$
- $\ln(1) = 0$
- $\ln(e) = 1$
- Undefined for $x \le 0$

#### Derivative of the Natural Logarithm

$$\frac{d}{dx}\ln(x) = \frac{1}{x}, \quad x > 0$$

This is a verifiable calculus result, not [Inference].

### Graphs of $e^x$ and $\ln(x)$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Exponential and Logarithm as Inverses (svg_diagram)</text>

  <line x1="60" y1="280" x2="650" y2="280" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="30" x2="350" y2="300" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="285" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="35" font-size="11" font-family="sans-serif">y</text>

  <line x1="80" y1="300" x2="620" y2="60" stroke="#9ca3af" stroke-width="1" stroke-dasharray="4,4" />
  <text x="600" y="55" font-size="10" font-family="sans-serif" fill="#9ca3af">y = x</text>

  <path d="M 100 300 Q 300 290 350 250 Q 450 180 620 60" fill="none" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="560" y="90" font-size="11" font-family="sans-serif" fill="#1d4ed8">y = eˣ</text>

  <path d="M 300 300 Q 320 200 400 150 Q 500 100 620 75" fill="none" stroke="#15803d" stroke-width="2.5" />
  <text x="500" y="130" font-size="11" font-family="sans-serif" fill="#15803d">y = ln(x)</text>

  <circle cx="350" cy="252" r="4" fill="#1d4ed8" />
  <text x="358" y="265" font-size="9" font-family="sans-serif">(0,1)</text>
  <circle cx="420" cy="280" r="4" fill="#15803d" />
  <text x="428" y="295" font-size="9" font-family="sans-serif">(1,0)</text>
</svg>

### Logarithm and Exponent Rules

| Rule | Exponential Form | Logarithmic Form |
|---|---|---|
| Product | $b^x \cdot b^y = b^{x+y}$ | $\log_b(xy) = \log_b(x) + \log_b(y)$ |
| Quotient | $\dfrac{b^x}{b^y} = b^{x-y}$ | $\log_b\left(\dfrac{x}{y}\right) = \log_b(x) - \log_b(y)$ |
| Power | $(b^x)^y = b^{xy}$ | $\log_b(x^y) = y\log_b(x)$ |
| Change of base | — | $\log_b(x) = \dfrac{\ln(x)}{\ln(b)}$ |
| Inverse identity | $e^{\ln(x)} = x$ | $\ln(e^x) = x$ |

These are standard algebraic identities and are verifiable, not [Inference].

**Example**

Simplify $\ln(e^3 \cdot e^2)$:

$$\ln(e^3 \cdot e^2) = \ln(e^5) = 5$$

### Relevance to Machine Learning

#### Sigmoid Function

$$\sigma(x) = \frac{1}{1 + e^{-x}}$$

Built directly from the exponential function. Its inverse, the **logit function**, uses the natural logarithm:

$$\text{logit}(p) = \ln\left(\frac{p}{1-p}\right)$$

This inverse relationship is an algebraic derivation and can be verified directly by substitution.

#### Softmax Function

$$\text{softmax}(x_i) = \frac{e^{x_i}}{\sum_{j} e^{x_j}}$$

Uses exponentials to convert real-valued scores into a probability distribution that sums to 1. This is a defining property of the formula's construction, verifiable algebraically ($\sum_i \text{softmax}(x_i) = 1$ follows directly from the definition).

#### Cross-Entropy / Log-Loss

$$L = -\sum_i y_i \ln(\hat{y}_i)$$

Uses the natural logarithm to penalize incorrect predictions. As $\hat{y}_i \to 0$ for a class where $y_i = 1$, the loss value increases without bound, since $\ln(x) \to -\infty$ as $x \to 0^+$. This is a mathematical limit property, verifiable directly from the definition of $\ln(x)$.

**Key Points**

- [Inference] Because $\ln(x)$ is undefined at $x = 0$ and approaches $-\infty$ as $x \to 0^+$, numerical instability (such as `NaN` or `inf` values) may occur in cross-entropy computations when predicted probabilities are very close to 0. Whether a specific software library applies internal safeguards (such as clipping or adding a small epsilon) is implementation-specific. [Unverified] whether any particular framework does this without checking that framework's current documentation directly.

#### Gradient Descent and Log-Likelihood

Many optimization objectives in machine learning are expressed as negative log-likelihoods because:

$$\log(a \cdot b) = \log(a) + \log(b)$$

This converts products of probabilities (common in likelihood functions for independent data) into sums, which are generally easier to differentiate. This is a standard mathematical motivation found in statistics and optimization literature, though I cannot verify without a specific citation which exact source first documented this rationale.

#### Exponential Decay in Learning Rate Schedules

A common learning rate schedule form is:

$$\eta_t = \eta_0 \cdot e^{-\lambda t}$$

where $\eta_0$ is the initial learning rate, $\lambda$ is a decay constant, and $t$ is the training step or epoch. [Unverified] whether this exact schedule is the specific default in any given machine learning library, since defaults vary by framework and version.

### Growth Rate Comparison

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Growth Rate Comparison (svg_diagram)</text>

  <line x1="60" y1="220" x2="650" y2="220" stroke="#334155" stroke-width="1.5" />
  <line x1="60" y1="40" x2="60" y2="230" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="225" font-size="11" font-family="sans-serif">x</text>

  <path d="M 60 218 L 200 210 L 350 195 L 500 175 L 620 155" fill="none" stroke="#15803d" stroke-width="2.5" />
  <text x="550" y="145" font-size="10" font-family="sans-serif" fill="#15803d">log(x)</text>

  <path d="M 60 220 L 200 190 L 350 150 L 500 100 L 620 55" fill="none" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="550" y="70" font-size="10" font-family="sans-serif" fill="#1d4ed8">x (linear)</text>

  <path d="M 60 220 L 200 215 L 300 190 L 380 140 L 440 90 L 480 55" fill="none" stroke="#b91c1c" stroke-width="2.5" />
  <text x="450" y="45" font-size="10" font-family="sans-serif" fill="#b91c1c">eˣ (exponential)</text>
</svg>

This diagram illustrates the qualitative ordering of growth rates ($\log(x) < x < e^x$ for large $x$), which is a standard mathematical result. Exact numerical scaling in the illustration is approximate and intended for conceptual comparison, not precise plotting.

### Summary Table

| Property | $e^x$ | $\ln(x)$ |
|---|---|---|
| Domain | $\mathbb{R}$ | $(0, \infty)$ |
| Range | $(0, \infty)$ | $\mathbb{R}$ |
| Derivative | $e^x$ | $1/x$ |
| Monotonicity | Strictly increasing | Strictly increasing |
| Value at key point | $e^0 = 1$ | $\ln(1) = 0$ |
| Behavior at boundary | $\lim_{x\to-\infty} e^x = 0$ | $\lim_{x\to 0^+}\ln(x) = -\infty$ |

**Related Topics**

- Derivatives of exponential and logarithmic functions (formal proofs)
- Sigmoid and softmax functions in depth
- Cross-entropy loss and maximum likelihood estimation
- L'Hôpital's rule for indeterminate forms involving $e^x$ and $\ln(x)$
- Numerical stability techniques (log-sum-exp trick)