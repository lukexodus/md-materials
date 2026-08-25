## Limits Involving Infinity and Asymptotes

### Definition of Infinite Limits

A limit is said to approach infinity when the value of $f(x)$ grows without bound as $x$ approaches some point $a$. Formally:

$$\lim_{x \to a} f(x) = \infty$$

This notation means that for every $M > 0$, there exists a $\delta > 0$ such that whenever $0 < |x - a| < \delta$, $f(x) > M$. [Inference] This is a standard formalization found in most calculus references, though exact epsilon-delta phrasing may vary slightly by textbook.

Similarly, a limit approaches negative infinity when $f(x)$ decreases without bound:

$$\lim_{x \to a} f(x) = -\infty$$

It is important to note that $\infty$ is not a number — writing $\lim_{x \to a} f(x) = \infty$ describes *behavior*, not a value the function actually reaches.

### Limits at Infinity

A distinct but related concept is the limit *at* infinity, which describes the behavior of $f(x)$ as $x$ itself grows without bound:

$$\lim_{x \to \infty} f(x) = L$$

This means that as $x$ increases indefinitely, $f(x)$ approaches some finite value $L$. This is the mathematical foundation for describing **horizontal asymptotes**.

### Vertical Asymptotes

A vertical asymptote occurs at $x = a$ when:

$$\lim_{x \to a^-} f(x) = \pm\infty \quad \text{or} \quad \lim_{x \to a^+} f(x) = \pm\infty$$

Vertical asymptotes typically occur where a rational function's denominator equals zero while the numerator does not.

**Example**

For $f(x) = \dfrac{1}{x - 2}$:

$$\lim_{x \to 2^-} \frac{1}{x-2} = -\infty, \qquad \lim_{x \to 2^+} \frac{1}{x-2} = +\infty$$

This indicates a vertical asymptote at $x = 2$, with the function diverging in opposite directions from each side.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 400">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Vertical Asymptote at x = 2 (svg_diagram)</text>
  <line x1="50" y1="200" x2="450" y2="200" stroke="#999" stroke-width="1" />
  <line x1="250" y1="30" x2="250" y2="380" stroke="#999" stroke-width="1" />
  <line x1="330" y1="30" x2="330" y2="380" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="335" y="45" font-size="12" fill="#cc0000">x = 2</text>
  <path d="M 60,205 Q 150,210 250,230 T 320,340" stroke="#1a5fb4" stroke-width="2" fill="none" />
  <path d="M 340,60 Q 410,170 450,195" stroke="#1a5fb4" stroke-width="2" fill="none" />
  <text x="60" y="220" font-size="11" fill="#555">x-axis</text>
  <text x="255" y="45" font-size="11" fill="#555">y-axis</text>
</svg>

### Horizontal Asymptotes

A horizontal asymptote occurs when:

$$\lim_{x \to \infty} f(x) = L \quad \text{or} \quad \lim_{x \to -\infty} f(x) = L$$

For rational functions $f(x) = \dfrac{p(x)}{q(x)}$, the horizontal asymptote is determined by comparing the degrees of $p(x)$ and $q(x)$:

- If $\deg(p) < \deg(q)$: horizontal asymptote at $y = 0$
- If $\deg(p) = \deg(q)$: horizontal asymptote at $y = \dfrac{\text{leading coefficient of } p}{\text{leading coefficient of } q}$
- If $\deg(p) > \deg(q)$: no horizontal asymptote (the function may have an oblique/slant asymptote instead)

**Example**

$$\lim_{x \to \infty} \frac{3x^2 + 5x}{x^2 - 1} = 3$$

This follows the equal-degree rule above, giving a horizontal asymptote at $y = 3$.

### Evaluating Limits at Infinity for Rational Functions

The standard technique involves dividing numerator and denominator by the highest power of $x$ present in the denominator.

$$\lim_{x \to \infty} \frac{3x^2 + 5x}{x^2 - 1} = \lim_{x \to \infty} \frac{3 + \frac{5}{x}}{1 - \frac{1}{x^2}} = \frac{3 + 0}{1 - 0} = 3$$

This relies on the fact that $\dfrac{1}{x^n} \to 0$ as $x \to \infty$ for any $n > 0$.

### Oblique (Slant) Asymptotes

When $\deg(p) = \deg(q) + 1$, the function approaches a linear function as $x \to \pm\infty$, found via polynomial long division:

$$f(x) = \frac{x^2 + 1}{x} = x + \frac{1}{x}$$

As $x \to \infty$, $\dfrac{1}{x} \to 0$, so $f(x)$ approaches the line $y = x$. This is the oblique asymptote.

### Asymptotic Behavior in Activation Functions

Several activation functions used in machine learning exhibit asymptotic behavior directly tied to these limit concepts.

**Sigmoid function**

$$\sigma(x) = \frac{1}{1 + e^{-x}}$$

$$\lim_{x \to \infty} \sigma(x) = 1, \qquad \lim_{x \to -\infty} \sigma(x) = 0$$

The sigmoid function has two horizontal asymptotes: $y = 1$ and $y = 0$. This bounded behavior is why sigmoid outputs are often interpreted as probabilities, though the function does not reach these bounds for any finite input. [Inference] This interpretation is common in introductory ML material but the *choice* to interpret sigmoid output as probability is a modeling decision, not a mathematical necessity.

**Softplus function**

$$f(x) = \ln(1 + e^x)$$

$$\lim_{x \to -\infty} f(x) = 0, \qquad \lim_{x \to \infty} f(x) \to \infty \text{ (asymptotically approaching } y = x\text{)}$$

Softplus behaves like an oblique asymptote $y = x$ for large positive $x$, and flattens toward $y = 0$ for large negative $x$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 350">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Sigmoid Function Horizontal Asymptotes (svg_diagram)</text>
  <line x1="40" y1="300" x2="460" y2="300" stroke="#999" stroke-width="1" />
  <line x1="250" y1="30" x2="250" y2="320" stroke="#999" stroke-width="1" />
  <line x1="40" y1="60" x2="460" y2="60" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="465" y="64" font-size="11" fill="#cc0000">y = 1</text>
  <line x1="40" y1="280" x2="460" y2="280" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="465" y="284" font-size="11" fill="#cc0000">y = 0</text>
  <path d="M 40,275 C 150,275 220,60 250,170 C 280,280 350,65 460,65" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <text x="45" y="315" font-size="11" fill="#555">x → -∞</text>
  <text x="410" y="315" font-size="11" fill="#555">x → +∞</text>
</svg>

### Asymptotic Behavior in Loss Functions

Certain loss functions used in training ML models exhibit infinite limits, which affects optimization dynamics.

**Binary cross-entropy loss**

$$L(y, \hat{y}) = -\left[y \ln(\hat{y}) + (1-y)\ln(1-\hat{y})\right]$$

As the predicted probability $\hat{y} \to 0$ while the true label $y = 1$:

$$\lim_{\hat{y} \to 0^+} -\ln(\hat{y}) = \infty$$

This infinite limit is what drives strong gradient signals when predictions are confidently wrong. [Inference] This is a widely cited property of cross-entropy loss in ML literature, though the practical magnitude of the gradient in a specific implementation depends on numerical stability handling (e.g., clipping), and behavior may vary across frameworks and library versions.

### Connection to Gradient Descent and Vanishing/Exploding Gradients

Asymptotic behavior of activation functions relates directly to two well-documented training issues:

- **Vanishing gradients**: When an activation function (such as sigmoid or tanh) approaches a horizontal asymptote, its derivative approaches zero. Since $\sigma'(x) = \sigma(x)(1-\sigma(x))$, and $\sigma(x) \to 0$ or $\sigma(x) \to 1$ at the asymptotes, the gradient shrinks toward zero in those regions. [Unverified] The extent to which this contributes to training difficulty depends on network depth, initialization, and architecture, and general claims should not be treated as universal.
- **Exploding gradients**: Related to functions or weight products that grow without bound rather than approach a horizontal asymptote; this is a distinct phenomenon governed by different limit behavior (unbounded growth rather than asymptotic flattening).

### Determining Asymptotes: General Procedure

1. **Vertical asymptotes**: Find values of $x$ where the function is undefined (typically denominator $= 0$) and check if the one-sided limits diverge to $\pm\infty$.
2. **Horizontal asymptotes**: Evaluate $\lim_{x \to \infty} f(x)$ and $\lim_{x \to -\infty} f(x)$.
3. **Oblique asymptotes**: Check only if no horizontal asymptote exists and $\deg(p) = \deg(q) + 1$; perform polynomial division.

### Worked Example: Full Asymptote Analysis

Given $f(x) = \dfrac{2x^2 - 3x}{x - 1}$:

**Step 1 — Vertical asymptote**: Denominator is zero at $x = 1$, numerator is $2(1)^2 - 3(1) = -1 \neq 0$, so a vertical asymptote exists at $x = 1$.

**Step 2 — Horizontal asymptote**: $\deg(p) = 2$, $\deg(q) = 1$, so $\deg(p) > \deg(q)$ — no horizontal asymptote.

**Step 3 — Oblique asymptote**: Since $\deg(p) = \deg(q) + 1$, perform division:

$$\frac{2x^2 - 3x}{x - 1} = 2x - 1 - \frac{1}{x-1}$$

As $x \to \pm\infty$, the term $-\dfrac{1}{x-1} \to 0$, so the oblique asymptote is $y = 2x - 1$.

### Relevance to Machine Learning Practice

Understanding asymptotic limit behavior supports reasoning about:

- Why certain activation functions saturate and stop learning effectively in deep networks
- Why loss functions are often clipped or regularized numerically (e.g., adding $\epsilon$ inside logarithms) to avoid computing $\ln(0)$
- Why normalization layers (e.g., batch normalization) are used partly to keep activations away from asymptotic saturation regions [Inference] This is a commonly stated motivation in deep learning literature, but batch normalization's full effect on optimization is still an active area of study and should not be treated as fully settled.

**Next Steps**

- Continuity: formal definition, types of discontinuities (removable, jump, infinite)
- The Intermediate Value Theorem and its use in numerical root-finding methods relevant to optimization
- Derivatives: definition via limits, the difference quotient
- L'Hôpital's Rule for indeterminate forms $\frac{0}{0}$ and $\frac{\infty}{\infty}$
- Squeeze Theorem and its application in bounding gradient behavior
- Continuity and differentiability requirements for loss functions used in gradient-based optimization