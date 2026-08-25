## Derivatives of Exponential Functions

### Core Derivative Formula

For the natural exponential function, the derivative has a uniquely simple form:

$$\frac{d}{dx}\left[e^x\right] = e^x$$

This is the defining property that makes $e$ mathematically special: it is the only base for which the exponential function equals its own derivative.

For a general exponential function with base $a > 0$:

$$\frac{d}{dx}\left[a^x\right] = a^x \ln(a)$$

### Key Points

- The exponential function $e^x$ is the unique function (up to scalar multiples) that is its own derivative, making it foundational throughout calculus and differential equations.
- Exponential functions appear extensively in machine learning: in the sigmoid function, softmax function, exponential decay schedules, and probability distributions such as the Gaussian and exponential families.
- The natural logarithm's base $e$ arises naturally because it eliminates the extra $\ln(a)$ factor present for other bases.

### Derivation of $\frac{d}{dx}[e^x] = e^x$

Using the limit definition of the derivative:

$$\frac{d}{dx}\left[e^x\right] = \lim_{h \to 0} \frac{e^{x+h} - e^x}{h} = \lim_{h \to 0} \frac{e^x \cdot e^h - e^x}{h} = e^x \cdot \lim_{h \to 0} \frac{e^h - 1}{h}$$

The key step relies on the standard limit:

$$\lim_{h \to 0} \frac{e^h - 1}{h} = 1$$

[Fact] This limit is often taken as part of the definition of $e$ itself in many calculus treatments, or derived from the definition $e = \lim_{n \to \infty}\left(1+\frac{1}{n}\right)^n$. Substituting:

$$\frac{d}{dx}\left[e^x\right] = e^x \cdot 1 = e^x$$

### Derivation for General Base $a^x$

Rewriting $a^x$ using the identity $a^x = e^{x \ln a}$ (since $a = e^{\ln a}$):

$$\frac{d}{dx}\left[a^x\right] = \frac{d}{dx}\left[e^{x \ln a}\right]$$

Applying the chain rule, with the inner function $x \ln a$ having derivative $\ln a$:

$$\frac{d}{dx}\left[a^x\right] = e^{x \ln a} \cdot \ln a = a^x \ln a$$

This confirms the general formula, and shows why $e^x$ is the special case where $\ln(e) = 1$, eliminating the extra factor.

### Worked Examples

**Example 1:**

$$f(x) = e^{3x}$$

Using the chain rule:

$$f'(x) = 3e^{3x}$$

**Example 2:**

$$f(x) = 2^x$$

$$f'(x) = 2^x \ln(2)$$

**Example 3:**

$$f(x) = e^{-x^2/2}$$

Using the chain rule, with inner derivative $-x$:

$$f'(x) = -x \cdot e^{-x^2/2}$$

This exact form appears in the derivative of the unnormalized Gaussian density function.

**Example 4:**

$$f(x) = x^2 e^x$$

Using the product rule:

$$f'(x) = 2xe^x + x^2e^x = xe^x(2+x)$$

### Visualizing $e^x$ and Its Derivative

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">f(x) = eˣ Equals Its Own Derivative (svg_diagram)</text>

  <line x1="40" y1="260" x2="480" y2="260" stroke="#333" stroke-width="1.5" />
  <line x1="120" y1="50" x2="120" y2="260" stroke="#333" stroke-width="1.5" />

  
  <path d="M 120,255 C 200,250 280,200 340,120 C 380,70 410,55 440,50" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="360" y="70" font-size="12" fill="#2563eb">f(x) = eˣ = f'(x)</text>

  
  <circle cx="320" cy="150" r="5" fill="#dc2626" />
  <line x1="260" y1="220" x2="380" y2="80" stroke="#dc2626" stroke-width="2" stroke-dasharray="5,3" />
  <text x="380" y="75" font-size="11" fill="#dc2626">tangent slope = eˣ at that point</text>

  <text x="260" y="285" font-size="12" text-anchor="middle" fill="#555">The slope at every point equals the function's value there</text>
</svg>

### The Sigmoid Derivative Revisited

As established through the quotient rule, the sigmoid function's derivative:

$$\sigma(x) = \frac{1}{1+e^{-x}}, \qquad \sigma'(x) = \sigma(x)(1-\sigma(x))$$

relies fundamentally on the exponential derivative $\frac{d}{dx}[e^{-x}] = -e^{-x}$, obtained via the chain rule applied to $e^x$.

### The Softmax Function and Its Derivative

The softmax function generalizes the sigmoid to multiple classes:

$$\text{softmax}(x_i) = \frac{e^{x_i}}{\sum_{j=1}^{n} e^{x_j}}$$

Differentiating softmax with respect to its inputs requires both the exponential derivative and the quotient rule. For $i = j$:

$$\frac{\partial \, \text{softmax}(x_i)}{\partial x_i} = \text{softmax}(x_i)\big(1 - \text{softmax}(x_i)\big)$$

For $i \neq j$:

$$\frac{\partial \, \text{softmax}(x_i)}{\partial x_j} = -\text{softmax}(x_i) \cdot \text{softmax}(x_j)$$

[Fact] This Jacobian structure is standard in the derivation of the softmax gradient used in multi-class classification models.

### Relevance to Machine Learning

- **Sigmoid and softmax activations:** As shown above, both rely directly on the exponential derivative for their gradient computations during backpropagation.
- **Softmax combined with cross-entropy loss:** [Fact] When softmax is paired with cross-entropy loss, the combined gradient with respect to the pre-activation logits simplifies elegantly to $(\hat{y} - y)$, a widely cited simplification in classification model derivations, due to cancellation between the softmax and log-likelihood derivative terms.
- **Exponential decay in learning rate schedules:** Many learning rate schedules use exponential decay of the form $\eta(t) = \eta_0 e^{-\lambda t}$; understanding its derivative is relevant when analyzing how the learning rate changes over training steps.
- **Gaussian and exponential family distributions:** Many probability distributions used in probabilistic machine learning (Gaussian, Poisson, exponential) involve exponential terms in their density functions, and differentiating their log-likelihoods for maximum likelihood estimation relies on exponential derivative rules.
- **Batch normalization and exponential moving averages:** [Inference] Techniques that maintain running statistics using exponential moving averages implicitly rely on exponential decay behavior, though the moving average update itself is typically implemented as a discrete recurrence rather than through continuous differentiation.

### Common Pitfalls

- **Forgetting the $\ln(a)$ factor for non-natural bases:** A frequent error is writing $\frac{d}{dx}[2^x] = 2^x$ instead of $2^x \ln(2)$.
- **Mishandling negative exponents in the chain rule:** When differentiating $e^{-x}$, forgetting to include the negative sign from the inner derivative is a common mistake.
- **Confusing $e^x$ with $x^e$:** These are fundamentally different functions; $x^e$ is a power function differentiated via the power rule, not the exponential rule.
- **Errors in the softmax Jacobian:** Since softmax's derivative has different forms for $i=j$ versus $i \neq j$, incorrectly applying a single formula across all index pairs is a common source of error in manual derivations.

### Conclusion

The derivative of $e^x$ being equal to itself is one of the most distinctive properties in calculus, and it underlies a large portion of the differentiable operations used throughout machine learning — from activation functions like sigmoid and softmax to probability density functions and learning rate schedules. Because so many ML components are built from exponential expressions, fluency with exponential differentiation rules is essential for understanding gradient-based training.

**Related Topics**
- Derivatives of logarithmic functions and their relation to exponentials
- Softmax gradient and its interaction with cross-entropy loss
- Gaussian distributions and log-likelihood derivatives
- Learning rate schedules and exponential decay
- Chain rule applications in composite exponential expressions
- Exponential family distributions in probabilistic machine learning