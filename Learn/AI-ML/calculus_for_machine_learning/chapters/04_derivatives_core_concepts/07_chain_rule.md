## The Chain Rule

### Statement of the Rule

The chain rule is used to differentiate composite functions — functions built by applying one function to the output of another. If $f(x) = g(h(x))$, where $g$ and $h$ are both differentiable, then:

$$f'(x) = g'(h(x)) \cdot h'(x)$$

In Leibniz notation, if $y = g(u)$ and $u = h(x)$, this is written as:

$$\frac{dy}{dx} = \frac{dy}{du} \cdot \frac{du}{dx}$$

### Key Points

- The chain rule is arguably the single most important differentiation rule in machine learning, since it forms the mathematical foundation of **backpropagation**.
- The rule states that the derivative of a composite function is the product of the derivative of the outer function (evaluated at the inner function) and the derivative of the inner function.
- The chain rule extends naturally to compositions of many nested functions, which mirrors the layered structure of neural networks.

### Derivation Intuition

The chain rule can be understood intuitively through rates of change. If $y$ changes with respect to $u$ at a certain rate, and $u$ changes with respect to $x$ at another rate, the overall rate of change of $y$ with respect to $x$ is the product of these two rates:

$$\frac{dy}{dx} = \frac{dy}{du} \cdot \frac{du}{dx}$$

[Unverified] A fully rigorous proof requires care around cases where $\frac{\Delta u}{\Delta x}$ is zero for some $\Delta x$ near the point of interest; standard real-analysis treatments handle this using the concept of a differentiable function's local linear approximation rather than direct limit cancellation.

### Worked Examples

**Example 1:**

$$f(x) = (3x + 2)^5$$

Let $h(x) = 3x+2$ (inner function) and $g(u) = u^5$ (outer function).

$$g'(u) = 5u^4, \quad h'(x) = 3$$

$$f'(x) = 5(3x+2)^4 \cdot 3 = 15(3x+2)^4$$

**Example 2:**

$$f(x) = \sin(x^2)$$

Let $h(x) = x^2$, $g(u) = \sin(u)$.

$$g'(u) = \cos(u), \quad h'(x) = 2x$$

$$f'(x) = \cos(x^2) \cdot 2x = 2x\cos(x^2)$$

**Example 3:**

$$f(x) = e^{-x^2}$$

Let $h(x) = -x^2$, $g(u) = e^u$.

$$g'(u) = e^u, \quad h'(x) = -2x$$

$$f'(x) = e^{-x^2} \cdot (-2x) = -2xe^{-x^2}$$

This exact form appears in the derivative of the Gaussian function, relevant to probability density functions used in probabilistic models.

### Extending to Multiple Nested Compositions

For deeply nested functions, such as $f(x) = g(h(k(x)))$, the chain rule extends by successive multiplication:

$$f'(x) = g'(h(k(x))) \cdot h'(k(x)) \cdot k'(x)$$

This generalization is essential in ML because a neural network is fundamentally a long composition of layer functions.

### Visualizing the Chain Rule

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Chain Rule as Composition (svg_diagram)</text>

  
  <rect x="20" y="130" width="90" height="50" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="65" y="160" font-size="14" text-anchor="middle" fill="#1e3a8a">x</text>

  <line x1="110" y1="155" x2="160" y2="155" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />

  
  <rect x="160" y="130" width="100" height="50" rx="6" fill="#bbf7d0" stroke="#059669" stroke-width="2" />
  <text x="210" y="160" font-size="14" text-anchor="middle" fill="#065f46">h(x) = u</text>

  <line x1="260" y1="155" x2="310" y2="155" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />

  
  <rect x="310" y="130" width="100" height="50" rx="6" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="360" y="160" font-size="14" text-anchor="middle" fill="#92400e">g(u) = y</text>

  <line x1="410" y1="155" x2="460" y2="155" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="460" y="130" width="50" height="50" rx="6" fill="#e0e7ff" stroke="#4338ca" stroke-width="2" />
  <text x="485" y="160" font-size="13" text-anchor="middle" fill="#312e81">y</text>

  <text x="260" y="230" font-size="14" text-anchor="middle" fill="#1a1a1a">dy/dx = (dy/du) × (du/dx)</text>
  <text x="260" y="255" font-size="12" text-anchor="middle" fill="#555">Differentiate outer, multiply by derivative of inner</text>
</svg>

### The Chain Rule and Backpropagation

Neural networks compute their output through a composition of layers, where each layer applies a linear transformation followed by a nonlinear activation function. Formally, for a network with layers $L_1, L_2, \dots, L_n$:

$$\hat{y} = L_n(L_{n-1}(\dots L_1(x) \dots))$$

To compute how the loss $\mathcal{L}$ changes with respect to a weight in an early layer, the chain rule is applied repeatedly, layer by layer, moving backward from the output:

$$\frac{\partial \mathcal{L}}{\partial w_1} = \frac{\partial \mathcal{L}}{\partial \hat{y}} \cdot \frac{\partial \hat{y}}{\partial L_{n-1}} \cdots \frac{\partial L_2}{\partial L_1} \cdot \frac{\partial L_1}{\partial w_1}$$

This is precisely the algorithm known as **backpropagation** — the repeated application of the chain rule through a computational graph, propagating gradients from the output layer back to earlier layers.

### Chain Rule Flow in a Simple Network Layer

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 260">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Backpropagation Gradient Flow (svg_diagram)</text>

  <rect x="30" y="90" width="110" height="50" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="85" y="120" font-size="12" text-anchor="middle" fill="#1e3a8a">Layer 1: z1</text>

  <rect x="200" y="90" width="110" height="50" rx="6" fill="#bbf7d0" stroke="#059669" stroke-width="2" />
  <text x="255" y="120" font-size="12" text-anchor="middle" fill="#065f46">Layer 2: z2</text>

  <rect x="370" y="90" width="120" height="50" rx="6" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="430" y="120" font-size="12" text-anchor="middle" fill="#92400e">Loss: L</text>

  <line x1="140" y1="115" x2="200" y2="115" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="310" y1="115" x2="370" y2="115" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />

  
  <line x1="370" y1="170" x2="310" y2="170" stroke="#dc2626" stroke-width="2" marker-end="url(#arrowred)" />
  <line x1="200" y1="170" x2="140" y2="170" stroke="#dc2626" stroke-width="2" marker-end="url(#arrowred)" />

  <text x="340" y="190" font-size="11" fill="#dc2626">∂L/∂z2</text>
  <text x="170" y="190" font-size="11" fill="#dc2626">∂L/∂z1 (chain rule)</text>

  </svg>

### Relevance to Machine Learning

- **Backpropagation:** As described above, the chain rule is the mathematical mechanism that allows gradients to be computed layer-by-layer in neural networks of arbitrary depth.
- **Automatic differentiation:** Modern ML frameworks (e.g., PyTorch, TensorFlow) implement **reverse-mode automatic differentiation**, which is a computational realization of the chain rule applied systematically across a computational graph. [Inference] The specific internal implementation details (e.g., how computational graphs are constructed and traversed) vary by framework and version.
- **Composite loss functions:** When a loss function is composed of nested transformations (e.g., a normalization step followed by a distance metric), the chain rule is required to compute how the final loss responds to changes in the earliest parameters.
- **Vanishing and exploding gradients:** [Inference] Because backpropagation multiplies many derivative terms together across layers via the chain rule, if these terms are consistently small (less than 1) or consistently large (greater than 1), the resulting product can shrink toward zero or grow very large across many layers. This is widely cited as a contributing factor to vanishing and exploding gradient problems in deep networks, though the severity depends on network depth, activation choice, and weight initialization.

### Common Pitfalls

- **Forgetting to multiply by the inner derivative:** A frequent error is differentiating only the outer function and omitting the $h'(x)$ factor entirely.
- **Misidentifying inner vs. outer functions:** In deeply nested expressions, correctly identifying the order of composition is essential before applying the rule.
- **Applying the chain rule when not needed:** For non-composite expressions (e.g., simple polynomials), the chain rule is unnecessary and applying it can introduce confusion or errors.
- **Sign and exponent errors when combined with the power rule:** Since the chain rule is frequently used alongside the power rule (e.g., $(3x+2)^5$), errors often arise from mishandling the exponent reduction or the inner derivative simultaneously.

### Conclusion

The chain rule enables differentiation of composite functions by multiplying the derivative of the outer function by the derivative of the inner function. Its repeated application across the layered structure of neural networks is the mathematical foundation of backpropagation, making it arguably the single most consequential calculus concept underlying modern machine learning training procedures.

**Related Topics**
- Backpropagation algorithm mechanics
- Reverse-mode vs. forward-mode automatic differentiation
- Vanishing and exploding gradient problems
- Computational graphs and their role in gradient computation
- Partial derivatives and the multivariable chain rule
- Derivative of composite loss functions (e.g., cross-entropy with softmax)