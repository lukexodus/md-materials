## The Quotient Rule

### Statement of the Rule

The quotient rule is used to differentiate the ratio of two functions. If $f(x) = \dfrac{u(x)}{v(x)}$, where $u$ and $v$ are differentiable and $v(x) \neq 0$, then:

$$f'(x) = \frac{u'(x)v(x) - u(x)v'(x)}{[v(x)]^2}$$

This is often remembered using the mnemonic **"low d-high minus high d-low, over low squared"** — where "low" refers to the denominator and "high" refers to the numerator.

### Key Points

- The order of subtraction in the numerator matters: $u'v - uv'$, not $uv' - u'v$.
- The denominator is always squared, and the rule requires $v(x) \neq 0$ at the point of differentiation.
- The quotient rule can be derived directly from the product rule and chain rule, so it is not strictly a new independent rule, but a specialized consequence of them.

### Derivation from the Product Rule

Rewrite the quotient as a product:

$$f(x) = u(x) \cdot [v(x)]^{-1}$$

Applying the product rule:

$$f'(x) = u'(x) \cdot [v(x)]^{-1} + u(x) \cdot \frac{d}{dx}\left[[v(x)]^{-1}\right]$$

Using the chain rule on the second term:

$$\frac{d}{dx}\left[[v(x)]^{-1}\right] = -[v(x)]^{-2} \cdot v'(x)$$

Substituting back:

$$f'(x) = \frac{u'(x)}{v(x)} - \frac{u(x)v'(x)}{[v(x)]^2}$$

Combining over a common denominator:

$$f'(x) = \frac{u'(x)v(x) - u(x)v'(x)}{[v(x)]^2}$$

### Worked Examples

**Example 1:**

$$f(x) = \frac{x^2 + 1}{x - 3}$$

Let $u(x) = x^2+1$, $v(x) = x-3$, so $u'(x) = 2x$, $v'(x) = 1$.

$$f'(x) = \frac{2x(x-3) - (x^2+1)(1)}{(x-3)^2} = \frac{2x^2 - 6x - x^2 - 1}{(x-3)^2} = \frac{x^2 - 6x - 1}{(x-3)^2}$$

**Example 2:**

$$f(x) = \frac{\sin(x)}{x}$$

Let $u(x) = \sin(x)$, $v(x) = x$, so $u'(x) = \cos(x)$, $v'(x) = 1$.

$$f'(x) = \frac{x\cos(x) - \sin(x)}{x^2}$$

**Example 3:**

$$f(x) = \frac{1}{x^2 + 1}$$

Let $u(x) = 1$, $v(x) = x^2+1$, so $u'(x) = 0$, $v'(x) = 2x$.

$$f'(x) = \frac{0 \cdot (x^2+1) - 1 \cdot 2x}{(x^2+1)^2} = \frac{-2x}{(x^2+1)^2}$$

This particular result is directly relevant to machine learning, since it is the derivative of a component used in the **sigmoid function**.

### Applying the Quotient Rule to the Sigmoid Function

The sigmoid function, widely used as an activation function, is defined as:

$$\sigma(x) = \frac{1}{1 + e^{-x}}$$

Applying the quotient rule with $u(x) = 1$, $v(x) = 1+e^{-x}$, so $u'(x)=0$, $v'(x) = -e^{-x}$:

$$\sigma'(x) = \frac{0 \cdot (1+e^{-x}) - 1 \cdot (-e^{-x})}{(1+e^{-x})^2} = \frac{e^{-x}}{(1+e^{-x})^2}$$

This can be algebraically simplified into the well-known compact form:

$$\sigma'(x) = \sigma(x)\big(1 - \sigma(x)\big)$$

[Fact] This identity is one of the most widely used derivative simplifications in neural network derivations, since it allows the derivative to be computed directly from the sigmoid's output value without recomputing the exponential.

### Visualizing the Quotient Rule

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 300">
  <text x="250" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Quotient Rule Structure (svg_diagram)</text>

  
  <rect x="70" y="60" width="360" height="60" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="250" y="98" font-size="17" text-anchor="middle" fill="#1e3a8a">f' = (u'v − uv') / v²</text>

  
  <line x1="180" y1="120" x2="150" y2="170" stroke="#059669" stroke-width="2" />
  <rect x="60" y="170" width="180" height="50" rx="6" fill="#bbf7d0" stroke="#059669" stroke-width="2" />
  <text x="150" y="200" font-size="12" text-anchor="middle" fill="#065f46">Numerator: u'v − uv'</text>

  
  <line x1="320" y1="120" x2="350" y2="170" stroke="#d97706" stroke-width="2" />
  <rect x="260" y="170" width="180" height="50" rx="6" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="350" y="200" font-size="12" text-anchor="middle" fill="#92400e">Denominator: v squared</text>

  <text x="250" y="265" font-size="13" text-anchor="middle" fill="#1a1a1a">Order of subtraction matters: u'v − uv'</text>
</svg>

### Relevance to Machine Learning

- **Sigmoid and softmax derivatives:** The quotient rule underlies the derivation of the sigmoid derivative shown above, as well as parts of the **softmax function**, since softmax outputs are defined as ratios of exponentials.
- **Normalization layers:** Certain normalization operations (e.g., dividing a value by a norm or sum of values) involve quotient structures whose gradients require the quotient rule during backpropagation.
- **Attention score normalization:** [Inference] Attention mechanisms typically normalize scores using a softmax, which involves a ratio of exponential terms; computing gradients through this normalization step relies on quotient-rule-style differentiation, though modern frameworks compute this via automatic differentiation rather than manual derivation.
- **Precision-recall and evaluation metric derivatives:** Some differentiable approximations of evaluation metrics (used in specialized loss functions) involve ratios of counts or probabilities, requiring the quotient rule when gradients are derived analytically.

### Common Pitfalls

- **Reversing the subtraction order:** Writing $uv' - u'v$ instead of $u'v - uv'$ produces a sign error.
- **Forgetting to square the denominator:** A frequent omission is leaving the denominator as $v(x)$ instead of $[v(x)]^2$.
- **Using the quotient rule unnecessarily:** When the denominator is a constant, it is often simpler to rewrite the expression using the constant multiple rule rather than applying the full quotient rule.
- **Domain restrictions:** The quotient rule does not apply, and the derivative is undefined, at points where $v(x) = 0$.

### Simplification Strategy

In practice, many practitioners prefer to rewrite quotients as products with negative exponents (as in the derivation above) and apply the product and chain rules instead, particularly when the denominator is a more complex expression. This often reduces algebraic errors compared to direct application of the quotient rule formula.

### Conclusion

The quotient rule provides a systematic method for differentiating ratios of functions and is a direct consequence of the product and chain rules. It plays a particularly important role in machine learning through the derivative of the sigmoid function and other normalized outputs such as softmax, both of which are foundational to how gradients propagate through classification models.

**Related Topics**
- Product rule and chain rule (prerequisite building blocks)
- Derivative of the sigmoid and softmax functions
- Derivatives of logarithmic and exponential functions
- Gradient derivation for cross-entropy loss
- Automatic differentiation vs. manual differentiation in ML frameworks
- Normalization layers and their backpropagation behavior