## Differentiability and Its Relation to Continuity

### Definition of Differentiability

A function $f$ is differentiable at a point $x = a$ if the following limit exists:

$$f'(a) = \lim_{h \to 0} \frac{f(a+h) - f(a)}{h}$$

If this limit exists and is finite, $f$ is said to be differentiable at $a$. If $f$ is differentiable at every point in an interval, it is differentiable on that interval.

### Key Points

- Differentiability is a stronger condition than continuity.
- A function must first be continuous at a point to have any chance of being differentiable there.
- Differentiability implies the existence of a well-defined tangent line (a unique instantaneous rate of change) at that point.
- In machine learning, differentiability is essential because gradient-based optimization methods (like gradient descent) require derivatives to exist at the points being evaluated.

### The Formal Relationship

**Theorem:** If $f$ is differentiable at $a$, then $f$ is continuous at $a$.

**Proof sketch:**

$$\lim_{h \to 0} \big[f(a+h) - f(a)\big] = \lim_{h \to 0} \left[\frac{f(a+h) - f(a)}{h} \cdot h\right] = f'(a) \cdot 0 = 0$$

This shows $\lim_{h \to 0} f(a+h) = f(a)$, which is precisely the definition of continuity at $a$.

**Important caveat:** The converse is false. Continuity does **not** imply differentiability. A function can be continuous at a point yet fail to have a derivative there.

### Why Continuity Does Not Guarantee Differentiability

A function can be continuous but non-differentiable in several ways:

1. **Sharp corners (kinks)** — the left-hand and right-hand derivatives exist but disagree.
2. **Vertical tangents** — the derivative limit diverges to infinity.
3. **Cusps** — the slope approaches $+\infty$ from one side and $-\infty$ from the other.
4. **Highly oscillatory behavior** — pathological functions where no derivative exists anywhere despite continuity everywhere. [Unverified — specific classical examples such as the Weierstrass function are well documented, but claims about their exact oscillatory structure should be checked against a primary real-analysis reference.]

### Classic Example: The Absolute Value Function

Consider $f(x) = |x|$ at $x = 0$.

- **Continuity check:** $\lim_{x \to 0} |x| = 0 = f(0)$, so $f$ is continuous at $0$.
- **Differentiability check:**
  - Right-hand derivative: $\lim_{h \to 0^+} \frac{|h| - 0}{h} = \lim_{h \to 0^+} \frac{h}{h} = 1$
  - Left-hand derivative: $\lim_{h \to 0^-} \frac{|h| - 0}{h} = \lim_{h \to 0^-} \frac{-h}{h} = -1$

Since the one-sided derivatives disagree ($1 \neq -1$), $f'(0)$ does not exist. The function is continuous but not differentiable at $x = 0$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
  <text x="250" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Continuous but Non-Differentiable Point (svg_diagram)</text>

  
  <line x1="50" y1="270" x2="450" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="250" y1="60" x2="250" y2="270" stroke="#333" stroke-width="1.5" />
  <text x="440" y="290" font-size="12" fill="#333">x</text>
  <text x="260" y="70" font-size="12" fill="#333">y</text>

  
  <polyline points="120,80 250,270 380,80" fill="none" stroke="#2563eb" stroke-width="3" />

  
  <circle cx="250" cy="270" r="6" fill="#dc2626" />
  <text x="260" y="255" font-size="12" fill="#dc2626">Corner: f continuous, f' undefined</text>

  
  <text x="130" y="150" font-size="12" fill="#2563eb">slope = -1</text>
  
  <text x="330" y="150" font-size="12" fill="#2563eb">slope = +1</text>

  <text x="250" y="300" font-size="12" text-anchor="middle" fill="#555">f(x) = |x|</text>
</svg>

### Piecewise-Defined Functions and Differentiability

To check differentiability of a piecewise function at a boundary point, three conditions must all hold:

1. The function is continuous at the boundary point.
2. The left-hand derivative exists.
3. The right-hand derivative exists and equals the left-hand derivative.

**Example:**

$$f(x) = \begin{cases} x^2 & x \leq 1 \\ 2x - 1 & x > 1 \end{cases}$$

- **Continuity at $x=1$:** $f(1) = 1$, and $\lim_{x \to 1^+} (2x-1) = 1$. Continuous.
- **Left derivative:** $f'(x) = 2x \Rightarrow f'(1^-) = 2$
- **Right derivative:** $f'(x) = 2 \Rightarrow f'(1^+) = 2$

Since both one-sided derivatives match, $f$ is differentiable at $x = 1$, with $f'(1) = 2$.

### Relevance to Machine Learning

- **Loss functions:** Many common loss functions (mean squared error, cross-entropy) are differentiable everywhere or almost everywhere, enabling gradient-based optimization.
- **Non-differentiable activation functions:** The ReLU function, $f(x) = \max(0, x)$, is continuous everywhere but not differentiable at $x = 0$. In practice, frameworks typically assign a **subgradient** (commonly $0$ or $1$) at that point to allow training to proceed. [Inference — this is standard engineering practice in most deep learning frameworks, though exact subgradient conventions can vary by implementation.]
- **Hinge loss** (used in SVMs) similarly has a non-differentiable kink, handled via subgradient methods.
- **Optimization implications:** Non-differentiable points can cause instability or undefined behavior in naive gradient descent implementations unless explicitly handled (e.g., via subgradients or smoothing approximations). Behavior may vary depending on the specific solver, learning rate, and numerical precision used.

### Visualizing the Logical Relationship

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 260">
  <text x="250" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Continuity vs. Differentiability (svg_diagram)</text>

  
  <ellipse cx="250" cy="150" rx="200" ry="90" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="120" y="90" font-size="13" fill="#1e3a8a">Continuous Functions</text>

  
  <ellipse cx="270" cy="160" rx="110" ry="55" fill="#bbf7d0" stroke="#059669" stroke-width="2" />
  <text x="230" y="160" font-size="13" fill="#065f46">Differentiable</text>

  <text x="120" y="220" font-size="11" fill="#1e3a8a">e.g., f(x) = |x|, ReLU</text>
  <text x="230" y="185" font-size="11" fill="#065f46">e.g., f(x) = x², sin(x)</text>
</svg>

### Sufficient Conditions for Differentiability

While continuity alone is insufficient, the following provide stronger guarantees:

- If $f$ has a derivative that exists and is continuous on an interval, $f$ is said to be **continuously differentiable** ($C^1$) on that interval.
- Polynomial, exponential, and sine/cosine functions are differentiable at every point in their domains. [Fact]
- Rational functions are differentiable everywhere except where the denominator is zero. [Fact]

### Conclusion

Differentiability is a strictly stronger property than continuity: every differentiable function is continuous, but not every continuous function is differentiable. This distinction matters directly in machine learning, where the choice of activation and loss functions must account for points of non-differentiability, often resolved through subgradients or smooth approximations to keep gradient-based training stable.

**Related Topics**
- Partial derivatives and differentiability in multivariable functions
- Subgradients and subdifferentials for non-smooth optimization
- Smooth approximations of non-differentiable functions (e.g., softplus as a smooth ReLU)
- The Mean Value Theorem and its applications
- Higher-order derivatives and $C^n$ smoothness classes
- Gradient descent behavior near non-differentiable points