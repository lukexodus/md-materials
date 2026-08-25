## The Power Rule

### Statement of the Rule

The power rule is one of the most fundamental differentiation rules. For a function of the form:

$$f(x) = x^n$$

where $n$ is any real number, the derivative is:

$$f'(x) = n \cdot x^{n-1}$$

### Key Points

- The power rule applies to any real exponent $n$, including negative and fractional values.
- It is one of the most frequently used differentiation rules in machine learning, since polynomial terms appear throughout loss functions, regularization terms, and basis expansions.
- The rule dramatically simplifies differentiation compared to using the limit definition directly.

### Derivation from First Principles (Integer Case)

For a positive integer $n$, the power rule can be derived from the limit definition of the derivative:

$$f'(x) = \lim_{h \to 0} \frac{(x+h)^n - x^n}{h}$$

Expanding $(x+h)^n$ using the binomial theorem:

$$(x+h)^n = x^n + n x^{n-1} h + \binom{n}{2} x^{n-2} h^2 + \dots + h^n$$

Subtracting $x^n$ and dividing by $h$:

$$\frac{(x+h)^n - x^n}{h} = n x^{n-1} + \binom{n}{2} x^{n-2} h + \dots + h^{n-1}$$

As $h \to 0$, all terms containing $h$ vanish, leaving:

$$f'(x) = n x^{n-1}$$

### Extension to Negative and Fractional Exponents

The power rule holds for negative exponents:

$$\frac{d}{dx}\left(x^{-n}\right) = -n \cdot x^{-n-1}$$

**Example:**

$$f(x) = x^{-3} \implies f'(x) = -3x^{-4}$$

It also holds for fractional (rational) exponents, which is how the derivative of root functions is computed:

$$f(x) = x^{1/2} = \sqrt{x} \implies f'(x) = \frac{1}{2}x^{-1/2} = \frac{1}{2\sqrt{x}}$$

[Fact] The general proof for rational exponents typically relies on implicit differentiation or the definition $x^{p/q} = \left(x^{1/q}\right)^p$, combined with the chain rule.

### Worked Examples

**Example 1:**

$$f(x) = x^5 \implies f'(x) = 5x^4$$

**Example 2:**

$$f(x) = x^{-2} \implies f'(x) = -2x^{-3}$$

**Example 3:**

$$f(x) = \sqrt[3]{x} = x^{1/3} \implies f'(x) = \frac{1}{3}x^{-2/3}$$

**Example 4 (constant case, $n = 0$):**

$$f(x) = x^0 = 1 \implies f'(x) = 0 \cdot x^{-1} = 0$$

This matches the general rule that the derivative of any constant is zero.

### Combining with the Constant Multiple Rule

The power rule is frequently used alongside the constant multiple rule:

$$\frac{d}{dx}\left[c \cdot x^n\right] = c \cdot n \cdot x^{n-1}$$

**Example:**

$$f(x) = 4x^3 \implies f'(x) = 12x^2$$

### Applying the Power Rule to Polynomials

Since differentiation is linear, the power rule can be applied term-by-term to polynomials:

$$f(x) = 3x^4 - 2x^3 + 5x - 7$$

$$f'(x) = 12x^3 - 6x^2 + 5$$

### Relevance to Machine Learning

- **Regularization terms:** L2 regularization (weight decay) uses a squared term, $\lambda w^2$, whose derivative via the power rule is $2\lambda w$ — this is the term subtracted during gradient descent updates.
- **Polynomial regression:** Models using polynomial feature expansions (e.g., $x, x^2, x^3, \dots$) rely directly on the power rule to compute gradients with respect to input features or coefficients.
- **Loss function gradients:** Mean squared error involves a squared term, $(y - \hat{y})^2$, and differentiating it (via the power rule combined with the chain rule) produces the familiar factor of $2$ seen in gradient expressions.
- **Cost surface curvature:** Second derivatives of polynomial terms (also computed via repeated application of the power rule) inform curvature-based optimization methods such as Newton's method.

### Visualizing the Power Rule

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
  <text x="250" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Power Rule: f(x) = x² and f'(x) = 2x (svg_diagram)</text>

  
  <line x1="50" y1="270" x2="450" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="250" y1="50" x2="250" y2="270" stroke="#333" stroke-width="1.5" />
  <text x="440" y="290" font-size="12" fill="#333">x</text>
  <text x="260" y="60" font-size="12" fill="#333">y</text>

  
  <path d="M 100,240 Q 250,50 400,240" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="380" y="230" font-size="12" fill="#2563eb">f(x) = x²</text>

  
  <line x1="150" y1="240" x2="350" y2="120" stroke="#dc2626" stroke-width="2" stroke-dasharray="6,3" />
  <text x="355" y="115" font-size="12" fill="#dc2626">f'(x) = 2x</text>

  
  <circle cx="300" cy="150" r="5" fill="#059669" />
  <text x="305" y="150" font-size="11" fill="#065f46">slope at x = 1: f'(1) = 2</text>
</svg>

### Common Pitfalls

- **Forgetting the chain rule:** The power rule alone applies only to $x^n$, not to composite expressions like $(3x+1)^n$. Differentiating $(3x+1)^n$ requires the chain rule: $n(3x+1)^{n-1} \cdot 3$.
- **Sign errors with negative exponents:** A frequent mistake is dropping the negative sign when reducing the exponent by one (e.g., writing $x^{-3-1}$ incorrectly).
- **Misapplying to non-power bases:** The power rule does not apply to expressions like $n^x$ (exponential functions), which require a different differentiation rule (the exponential rule).

### Conclusion

The power rule provides a direct, efficient method for differentiating any term of the form $x^n$, regardless of whether $n$ is a positive integer, negative number, or fraction. Its simplicity makes it foundational for differentiating polynomials, regularization terms, and many components of loss functions used throughout machine learning.

**Related Topics**
- Constant multiple rule and sum/difference rule
- Chain rule for composite functions
- Product rule and quotient rule
- Differentiating polynomial regression models
- Second derivatives and convexity analysis
- Gradient computation for L1 and L2 regularization