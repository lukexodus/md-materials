## Function Composition and Inverses

### Function Composition

Function composition combines two functions where the output of one becomes the input of the other.

$$(f \circ g)(x) = f(g(x))$$

- $g$ is applied first, then $f$ is applied to the result
- The domain of $f \circ g$ requires $x$ to be in the domain of $g$, and $g(x)$ to be in the domain of $f$

$$\text{Domain}(f \circ g) = \{x \in \text{Domain}(g) : g(x) \in \text{Domain}(f)\}$$

**Key Points**

- Composition is generally not commutative: $f(g(x)) \neq g(f(x))$ in most cases
- Composition is associative: $f \circ (g \circ h) = (f \circ g) \circ h$
- The identity function $\text{id}(x) = x$ satisfies $f \circ \text{id} = \text{id} \circ f = f$

**Example**

Let $f(x) = x^2$ and $g(x) = x + 1$.

$$(f \circ g)(x) = f(g(x)) = (x+1)^2$$

$$(g \circ f)(x) = g(f(x)) = x^2 + 1$$

These are different functions, demonstrating non-commutativity.

### Composition in Machine Learning: Neural Network Layers

A feedforward neural network is structurally a composition of functions, where each layer applies a linear transformation followed by a nonlinear activation.

$$\hat{y} = f_L(f_{L-1}(\cdots f_1(x) \cdots))$$

where each $f_i(x) = \sigma(W_i x + b_i)$ for weight matrix $W_i$, bias $b_i$, and activation function $\sigma$.

**Key Points**

- Each layer's output domain must be compatible with the next layer's expected input domain
- [Inference] The chain rule for derivatives, used in backpropagation, is a direct mathematical consequence of how derivatives behave under function composition. This is a mathematical property of differentiation itself, not a claim about any specific software implementation.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 220">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Neural Network as Function Composition (svg_diagram)</text>

  <rect x="30" y="90" width="80" height="50" rx="6" fill="#dbeafe" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="70" y="120" font-size="12" text-anchor="middle" font-family="sans-serif">x</text>

  <line x1="110" y1="115" x2="160" y2="115" stroke="#334155" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="160" y="90" width="100" height="50" rx="6" fill="#bfdbfe" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="210" y="115" font-size="11" text-anchor="middle" font-family="sans-serif">f₁(x)</text>
  <text x="210" y="130" font-size="9" text-anchor="middle" font-family="sans-serif">layer 1</text>

  <line x1="260" y1="115" x2="310" y2="115" stroke="#334155" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="310" y="90" width="100" height="50" rx="6" fill="#93c5fd" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="360" y="115" font-size="11" text-anchor="middle" font-family="sans-serif">f₂(f₁(x))</text>
  <text x="360" y="130" font-size="9" text-anchor="middle" font-family="sans-serif">layer 2</text>

  <line x1="410" y1="115" x2="460" y2="115" stroke="#334155" stroke-width="2" marker-end="url(#arrow1)" />

  <text x="480" y="120" font-size="16" text-anchor="middle" font-family="sans-serif">...</text>

  <line x1="500" y1="115" x2="550" y2="115" stroke="#334155" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="550" y="90" width="110" height="50" rx="6" fill="#60a5fa" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="605" y="115" font-size="11" text-anchor="middle" font-family="sans-serif" fill="white">ŷ = f_L(...)</text>
  <text x="605" y="130" font-size="9" text-anchor="middle" font-family="sans-serif" fill="#1e293b">output</text>

  </svg>

### Inverse Functions

The inverse of a function $f$, denoted $f^{-1}$, reverses the mapping of $f$:

$$f^{-1}(f(x)) = x \quad \text{and} \quad f(f^{-1}(y)) = y$$

An inverse exists **only if** $f$ is bijective (both injective and surjective) over the domain and codomain being considered.

**Key Points**

- If $f$ is not one-to-one, an inverse function does not exist unless the domain is restricted
- The graph of $f^{-1}$ is the reflection of the graph of $f$ across the line $y = x$
- $(f^{-1})^{-1} = f$

**Example**

$f(x) = 2x + 3$ is bijective over $\mathbb{R}$.

To find $f^{-1}$:

$$y = 2x + 3 \implies x = \frac{y - 3}{2}$$

$$f^{-1}(x) = \frac{x - 3}{2}$$

Verification: $f(f^{-1}(x)) = 2\left(\frac{x-3}{2}\right) + 3 = x - 3 + 3 = x$ ✓

### Restricting Domains to Create Invertibility

Some functions are not globally invertible but become invertible when the domain is restricted.

**Example**

$f(x) = x^2$ is not injective over $\mathbb{R}$ (since $f(-2) = f(2) = 4$).

Restricting the domain to $[0, \infty)$ makes it injective, giving:

$$f^{-1}(x) = \sqrt{x}, \quad \text{domain } [0, \infty)$$

**Relevance to Machine Learning**

[Inference] Activation functions such as sigmoid and tanh are chosen partly because they are monotonic and therefore invertible over their domains, which is relevant to certain model classes (e.g., normalizing flows) that require invertible transformations. I cannot verify the specific design rationale stated by any particular paper or author without a cited source.

### Derivative of an Inverse Function

If $f$ is differentiable and invertible near a point, the derivative of its inverse is given by:

$$(f^{-1})'(y) = \frac{1}{f'(f^{-1}(y))}$$

This holds provided $f'(f^{-1}(y)) \neq 0$.

**Example**

For $f(x) = e^x$, the inverse is $f^{-1}(x) = \ln(x)$.

$$f'(x) = e^x \implies (f^{-1})'(y) = \frac{1}{e^{\ln(y)}} = \frac{1}{y}$$

This confirms the known result $\frac{d}{dx}\ln(x) = \frac{1}{x}$.

### Composition and the Chain Rule (Preview)

Since neural networks are compositions of functions, differentiating them requires the chain rule:

$$\frac{d}{dx}f(g(x)) = f'(g(x)) \cdot g'(x)$$

**Key Points**

- This rule extends to multivariable compositions using the multivariable chain rule (relevant to backpropagation through multiple layers and parameters)
- [Unverified] Specific automatic differentiation frameworks may implement this via forward-mode, reverse-mode, or hybrid strategies; the exact computational approach varies by library and is not addressed by the mathematical chain rule itself

I cannot verify implementation-specific details of any particular software framework without checking current documentation directly.

### Invertibility Table for Common ML-Relevant Functions

| Function | Invertible over $\mathbb{R}$? | Restricted Domain for Invertibility | Inverse |
|---|---|---|---|
| $f(x) = x^2$ | No | $[0, \infty)$ | $\sqrt{x}$ |
| $f(x) = e^x$ | Yes | $\mathbb{R}$ | $\ln(x)$ |
| $f(x) = \sin(x)$ | No | $[-\pi/2, \pi/2]$ | $\arcsin(x)$ |
| $f(x) = \text{sigmoid}(x)$ | Yes | $\mathbb{R}$ | $\text{logit}(x) = \ln\left(\frac{x}{1-x}\right)$ |
| $f(x) = \tanh(x)$ | Yes | $\mathbb{R}$ | $\text{arctanh}(x)$ |

**Related Topics**

- Chain rule for derivatives (multivariable case)
- Monotonicity and its relationship to invertibility
- Logarithmic and exponential function properties
- Backpropagation as repeated application of the chain rule
- Jacobian matrices for vector-valued compositions