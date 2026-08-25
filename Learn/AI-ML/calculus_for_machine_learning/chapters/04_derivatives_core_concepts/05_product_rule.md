## The Product Rule

### Statement of the Rule

The product rule is used to differentiate the product of two functions. If $f(x) = u(x) \cdot v(x)$, where $u$ and $v$ are both differentiable functions, then:

$$f'(x) = u'(x) \cdot v(x) + u(x) \cdot v'(x)$$

This is often written more compactly as:

$$(uv)' = u'v + uv'$$

### Key Points

- The derivative of a product is **not** simply the product of the derivatives — this is a common misconception.
- The product rule generalizes to more than two factors and is essential when differentiating expressions built from multiple interacting components.
- In machine learning, the product rule appears whenever a model or loss function involves the multiplication of two functions of the same variable, such as attention mechanisms, weighted terms, or probability density products.

### Derivation from First Principles

Starting from the limit definition of the derivative:

$$f'(x) = \lim_{h \to 0} \frac{u(x+h)v(x+h) - u(x)v(x)}{h}$$

A key algebraic technique is to add and subtract the term $u(x+h)v(x)$ in the numerator:

$$f'(x) = \lim_{h \to 0} \frac{u(x+h)v(x+h) - u(x+h)v(x) + u(x+h)v(x) - u(x)v(x)}{h}$$

Grouping terms:

$$f'(x) = \lim_{h \to 0} \left[ u(x+h) \cdot \frac{v(x+h) - v(x)}{h} + v(x) \cdot \frac{u(x+h) - u(x)}{h} \right]$$

Taking the limit as $h \to 0$, and using the fact that $u(x+h) \to u(x)$ by continuity (since $u$ is differentiable, it is also continuous):

$$f'(x) = u(x) \cdot v'(x) + v(x) \cdot u'(x)$$

which matches the standard formula.

### Worked Examples

**Example 1:**

$$f(x) = x^2 \cdot \sin(x)$$

Let $u(x) = x^2$, $v(x) = \sin(x)$, so $u'(x) = 2x$, $v'(x) = \cos(x)$.

$$f'(x) = 2x \sin(x) + x^2 \cos(x)$$

**Example 2:**

$$f(x) = (3x+1)(x^2 - 4)$$

Let $u(x) = 3x+1$, $v(x) = x^2 - 4$, so $u'(x) = 3$, $v'(x) = 2x$.

$$f'(x) = 3(x^2-4) + (3x+1)(2x) = 3x^2 - 12 + 6x^2 + 2x = 9x^2 + 2x - 12$$

**Example 3 (verifying via expansion):**

Expanding directly: $f(x) = 3x^3 + x^2 - 12x - 4$

$$f'(x) = 9x^2 + 2x - 12$$

This matches the product rule result, confirming correctness.

### Extension to Three or More Functions

For a product of three differentiable functions, $f(x) = u(x)v(x)w(x)$:

$$f'(x) = u'vw + uv'w + uvw'$$

Each term differentiates one factor while leaving the others unchanged, then all terms are summed.

### Visualizing the Product Rule

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 300">
  <text x="250" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Product Rule Structure (svg_diagram)</text>

  
  <rect x="100" y="60" width="300" height="60" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="250" y="95" font-size="18" text-anchor="middle" fill="#1e3a8a">(uv)' = u'v + uv'</text>

  
  <line x1="180" y1="120" x2="150" y2="180" stroke="#059669" stroke-width="2" />
  <rect x="70" y="180" width="160" height="50" rx="6" fill="#bbf7d0" stroke="#059669" stroke-width="2" />
  <text x="150" y="210" font-size="13" text-anchor="middle" fill="#065f46">Differentiate u, keep v</text>

  
  <line x1="320" y1="120" x2="350" y2="180" stroke="#d97706" stroke-width="2" />
  <rect x="270" y="180" width="160" height="50" rx="6" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="350" y="210" font-size="13" text-anchor="middle" fill="#92400e">Keep u, differentiate v</text>

  
  <text x="250" y="270" font-size="14" text-anchor="middle" fill="#1a1a1a">Sum both terms</text>
</svg>

### Relevance to Machine Learning

- **Weighted feature interactions:** When a model output involves the product of two functions of a shared input (e.g., a gating function multiplied by a feature transformation), the product rule is required to compute gradients correctly.
- **Attention mechanisms:** [Inference] Components of attention-based architectures often involve products of learned weights and value vectors as functions of shared parameters; differentiating such expressions during backpropagation relies on the product rule, though the exact computational graph structure varies by implementation.
- **Likelihood functions:** In maximum likelihood estimation, the joint likelihood of independent observations is a product of individual probability densities. Differentiating this product directly would require repeated application of the product rule — which is precisely why the **log-likelihood** is used instead, converting the product into a sum via logarithm properties and avoiding repeated product-rule differentiation.
- **Regularized loss terms:** Some custom loss functions multiply a base loss by a scaling or masking function that also depends on the model's parameters, requiring the product rule during gradient derivation.

### Common Pitfalls

- **Assuming $(uv)' = u'v'$:** This is incorrect and one of the most common errors when first learning differentiation rules.
- **Forgetting to apply the chain rule within a factor:** If $u(x)$ or $v(x)$ is itself a composite function, its derivative must be computed using the chain rule before being substituted into the product rule formula.
- **Sign errors when factors involve subtraction:** Careful expansion and distribution of terms is needed, especially in examples like Example 2 above.

### Relationship to the Quotient Rule

The product rule and quotient rule are closely related; the quotient rule can be derived from the product rule combined with the chain rule, by rewriting $\frac{u}{v}$ as $u \cdot v^{-1}$ and differentiating:

$$\frac{d}{dx}\left[u \cdot v^{-1}\right] = u'v^{-1} + u \cdot (-1)v^{-2}v' = \frac{u'v - uv'}{v^2}$$

This produces the standard quotient rule formula.

### Conclusion

The product rule is essential whenever two differentiable functions are multiplied together, and its formula — differentiate one factor while holding the other constant, then sum both contributions — appears throughout machine learning wherever multiplicative interactions between parameterized functions must be differentiated, such as in likelihood functions, gating mechanisms, and weighted loss terms.

**Related Topics**
- Quotient rule for differentiating ratios of functions
- Chain rule for composite functions
- Log-likelihood and its role in simplifying products during differentiation
- Differentiating attention and gating mechanisms in neural networks
- Higher-order derivatives of products (generalized Leibniz rule)
- Partial derivatives of multiplicative terms in multivariable functions