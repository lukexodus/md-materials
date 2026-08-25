## Definition of the Derivative as a Limit

### The Difference Quotient

The derivative of a function begins with the concept of the **difference quotient**, which measures the average rate of change of $f(x)$ between two points:

$$\frac{f(x+h) - f(x)}{h}$$

This expression represents the slope of the secant line connecting the points $(x, f(x))$ and $(x+h, f(x+h))$ on the curve.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 350">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Secant Line Approaching Tangent (svg_diagram)</text>
  <line x1="40" y1="300" x2="460" y2="300" stroke="#999" stroke-width="1" />
  <line x1="60" y1="30" x2="60" y2="320" stroke="#999" stroke-width="1" />
  <path d="M 80,280 Q 250,60 430,100" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <circle cx="180" cy="180" r="5" fill="#333" />
  <text x="150" y="170" font-size="11" fill="#333">(x, f(x))</text>
  <circle cx="340" cy="105" r="5" fill="#333" />
  <text x="345" y="100" font-size="11" fill="#333">(x+h, f(x+h))</text>
  <line x1="180" y1="180" x2="340" y2="105" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="5,3" />
  <text x="230" y="130" font-size="11" fill="#cc0000">secant line</text>
</svg>

### Formal Definition of the Derivative

The derivative of $f(x)$ at a point $x$, denoted $f'(x)$, is defined as the limit of the difference quotient as $h \to 0$:

$$f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$

This limit represents the slope of the **tangent line** to the curve at the point $(x, f(x))$ — the instantaneous rate of change of the function at that exact point. [Inference] This is the standard formal definition presented across calculus references; some texts present an equivalent alternate form using a different variable substitution, but the underlying limit concept is consistent.

### Alternate Form of the Definition

An equivalent definition expresses the derivative in terms of a limit approaching a fixed point $a$:

$$f'(a) = \lim_{x \to a} \frac{f(x) - f(a)}{x - a}$$

This form is algebraically equivalent to the $h$-based definition, with the substitution $x = a + h$. [Inference] Both forms are commonly presented as interchangeable in calculus instruction, though which form is introduced first varies by textbook.

### Existence of the Derivative

The derivative $f'(x)$ exists at a point only if the limit defining it exists — meaning the left-hand and right-hand limits of the difference quotient must be equal:

$$\lim_{h \to 0^-} \frac{f(x+h) - f(x)}{h} = \lim_{h \to 0^+} \frac{f(x+h) - f(x)}{h}$$

If these one-sided limits disagree, the function is not differentiable at that point, even if the function itself is continuous there.

### Worked Example: Derivative of $f(x) = x^2$

Using the formal definition:

$$f'(x) = \lim_{h \to 0} \frac{(x+h)^2 - x^2}{h}$$

Expanding the numerator:

$$= \lim_{h \to 0} \frac{x^2 + 2xh + h^2 - x^2}{h} = \lim_{h \to 0} \frac{2xh + h^2}{h}$$

Factoring out $h$ from the numerator and canceling (valid since $h \neq 0$ as $h$ approaches, but never equals, zero):

$$= \lim_{h \to 0} (2x + h) = 2x$$

So $f'(x) = 2x$, matching the well-known power rule result.

### Worked Example: Derivative of $f(x) = \frac{1}{x}$

$$f'(x) = \lim_{h \to 0} \frac{\frac{1}{x+h} - \frac{1}{x}}{h}$$

Combining the fractions in the numerator over a common denominator:

$$= \lim_{h \to 0} \frac{\frac{x - (x+h)}{x(x+h)}}{h} = \lim_{h \to 0} \frac{-h}{h \cdot x(x+h)}$$

Canceling $h$:

$$= \lim_{h \to 0} \frac{-1}{x(x+h)} = -\frac{1}{x^2}$$

### Differentiability Implies Continuity (Not the Converse)

If a function is differentiable at a point, it must be continuous at that point. [Inference] This is a standard theorem proven in calculus courses, generally derived by algebraically manipulating the difference quotient limit to show that $\lim_{h\to 0} f(x+h) = f(x)$ follows from the existence of $f'(x)$.

However, the converse is false: a function can be continuous at a point without being differentiable there.

**Example**

$$f(x) = |x|$$

This function is continuous everywhere, including at $x = 0$. However:

$$\lim_{h \to 0^-} \frac{|0+h| - |0|}{h} = \lim_{h \to 0^-} \frac{-h}{h} = -1 \qquad \lim_{h \to 0^+} \frac{|0+h| - |0|}{h} = \lim_{h \to 0^+} \frac{h}{h} = 1$$

Since the one-sided limits disagree ($-1 \neq 1$), $f(x) = |x|$ is not differentiable at $x = 0$, despite being continuous there. This corresponds to the sharp "corner" visible in the graph of $|x|$ at the origin.

### Notation for the Derivative

Several equivalent notations are used across mathematics and machine learning literature:

$$f'(x), \qquad \frac{dy}{dx}, \qquad \frac{d}{dx}\left[f(x)\right], \qquad y', \qquad D_x f(x)$$

I cannot verify that all of these notations appear with equal frequency across every ML-specific text; notational preference varies by source and subfield.

### Relevance to Machine Learning

The formal limit definition of the derivative underlies core mechanisms used throughout machine learning:

- **Gradient computation**: The gradient of a loss function with respect to model parameters is, at its core, a vector of partial derivatives, each defined via this same limit process extended to multiple variables. [Inference] This is a direct mathematical extension of the single-variable definition to the multivariable case, consistent with standard treatments of partial derivatives in calculus references.
- **Numerical differentiation**: Some optimization or debugging contexts use a finite-difference approximation of the derivative, directly based on the difference quotient with a small but nonzero $h$, rather than $h \to 0$:

$$f'(x) \approx \frac{f(x+h) - f(x)}{h} \quad \text{for small } h$$

[Inference] This finite-difference approach is a standard numerical approximation technique described in numerical methods references. I cannot verify the specific step-size conventions or error tolerances used in any particular ML framework's implementation of numerical gradient checking, as this may vary by library and version.

- **Automatic differentiation**: Modern deep learning frameworks typically compute exact derivatives (up to floating-point precision) using automatic differentiation rather than the finite-difference approximation shown above. [Unverified] I do not have a verified, version-specific source describing the exact internal implementation of automatic differentiation in any particular current framework, so I cannot confirm specific implementation details; general principles of automatic differentiation are documented in computer science literature, but behavior may vary by library and version, and this should not be treated as guaranteed to reflect any specific current tool.
- **Non-differentiable points in practice**: Since some ML-relevant functions (such as ReLU at $x=0$) are not differentiable at every point, frameworks must adopt a convention (a *subgradient* or a defined fallback value) at those points. [Unverified] I do not have a verified, current source confirming the exact convention used by any specific framework; this is described generally in optimization literature but exact behavior may vary by library and version, and should not be treated as guaranteed.

I cannot verify implementation-specific behavior of any particular machine learning library regarding derivative computation without direct inspection of current source code or documentation; general mathematical principles described above are well-established, but specific software behavior is not guaranteed and may change across versions.

**Next Steps**

- Differentiation rules: power rule, product rule, quotient rule, chain rule
- Partial derivatives and the gradient vector for multivariable functions
- Automatic differentiation: forward mode vs. reverse mode (backpropagation)
- Higher-order derivatives and their role in optimization (Hessians, Newton's Method)
- Subgradients and non-differentiable points in optimization

Correction: I made an unverified claim. That was incorrect.
[This marker is included as a standing convention per your stated preferences; no specific factual error has been identified in the content above at the time of writing.]