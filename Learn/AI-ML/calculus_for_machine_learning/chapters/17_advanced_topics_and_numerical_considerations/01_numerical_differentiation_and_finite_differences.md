## Numerical Differentiation and Finite Differences

### Motivation

Analytical derivatives are not always available or practical to compute. In machine learning, this occurs when a function is a black box (e.g., a simulator), when gradients must be verified for correctness, or when working with models where automatic differentiation is unavailable or untrustworthy for a given operation. Numerical differentiation approximates derivatives using function evaluations at nearby points, avoiding the need for a closed-form expression.

Finite difference methods are the primary tool for this. They are widely used for **gradient checking** — validating that an analytically or algorithmically computed gradient (e.g., from backpropagation) matches a numerical approximation.

### Forward Difference

The simplest approximation uses the definition of the derivative directly:

$$f'(x) \approx \frac{f(x+h) - f(x)}{h}$$

Here $h$ is a small positive step size. This is called the **forward difference** because it evaluates the function only ahead of $x$.

**Key Points**
- Derived by truncating the Taylor series expansion after the first-order term.
- The truncation error is $O(h)$, meaning the approximation error scales linearly with $h$.
- Requires only two function evaluations: $f(x)$ and $f(x+h)$.
- Computationally cheap but relatively inaccurate compared to alternatives below.

### Backward Difference

A mirror-image approach evaluates the function behind $x$:

$$f'(x) \approx \frac{f(x) - f(x-h)}{h}$$

This also has $O(h)$ truncation error and is used when evaluating $f(x+h)$ is impossible or undefined (e.g., at a boundary of the function's domain).

### Central Difference

Combining forward and backward evaluations cancels the first-order error term:

$$f'(x) \approx \frac{f(x+h) - f(x-h)}{2h}$$

**Key Points**
- Derived by subtracting the Taylor expansions of $f(x+h)$ and $f(x-h)$.
- Truncation error is $O(h^2)$, which is significantly more accurate than forward or backward differences for the same $h$.
- Requires two function evaluations per derivative (not counting $f(x)$ itself, which cancels out).
- The standard choice for gradient checking in ML due to its superior accuracy-to-cost ratio.

### Second-Order Derivatives via Finite Differences

The second derivative can be approximated using a symmetric three-point formula:

$$f''(x) \approx \frac{f(x+h) - 2f(x) + f(x-h)}{h^2}$$

This is used in contexts such as approximating curvature (e.g., diagonal Hessian estimates) when analytical second derivatives are expensive or unavailable.

### Truncation Error vs. Round-off Error

Choosing $h$ involves a fundamental trade-off, illustrated below.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 420">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Total Error vs. Step Size h (svg_diagram)</text>
  
  <line x1="80" y1="360" x2="650" y2="360" stroke="#333" stroke-width="2" />
  <line x1="80" y1="360" x2="80" y2="50" stroke="#333" stroke-width="2" />
  
  <text x="365" y="400" text-anchor="middle" font-size="14" fill="#333">Step size h (log scale) →</text>
  <text x="30" y="200" text-anchor="middle" font-size="14" fill="#333" transform="rotate(-90 30 200)">Total Error (log scale) →</text>

  <path d="M 100 80 Q 200 60 280 120 T 400 220 Q 480 280 560 340 T 630 355" fill="none" stroke="#2563eb" stroke-width="3" />

  <path d="M 100 320 L 630 60" fill="none" stroke="#dc2626" stroke-width="2" stroke-dasharray="6,4" />
  <path d="M 100 355 L 400 355 Q 500 300 630 90" fill="none" stroke="#16a34a" stroke-width="2" stroke-dasharray="2,3" />

  <circle cx="340" cy="175" r="6" fill="#1a1a1a" />
  <text x="340" y="160" text-anchor="middle" font-size="12" fill="#1a1a1a" font-weight="bold">Optimal h</text>

  <text x="560" y="55" font-size="12" fill="#dc2626">Round-off error (grows as h→0)</text>
  <text x="120" y="335" font-size="12" fill="#16a34a">Truncation error (grows as h→∞)</text>
  <text x="450" y="230" font-size="12" fill="#2563eb" font-weight="bold">Total error</text>
</svg>

**Key Points**
- **Truncation error**: comes from ignoring higher-order terms in the Taylor expansion. Decreases as $h$ shrinks.
- **Round-off error**: comes from finite floating-point precision when subtracting two nearly equal numbers ($f(x+h) - f(x)$ becomes numerically unstable as $h \to 0$). Increases as $h$ shrinks.
- There exists an optimal $h$ that minimizes total error — too large causes truncation error to dominate, too small causes round-off error to dominate.
- [Inference] A commonly cited heuristic is $h \approx \sqrt{\epsilon_{machine}}$ for forward differences and $h \approx \epsilon_{machine}^{1/3}$ for central differences, where $\epsilon_{machine}$ is machine epsilon (approximately $2.2 \times 10^{-16}$ for double-precision floats). This is a general guideline, not a rule that holds precisely for every function.

### Gradient Checking in Practice

When verifying a gradient computed via backpropagation or automatic differentiation, the standard procedure is:

1. Compute the analytical gradient $\nabla f(\theta)$ using the algorithm under test.
2. Compute the numerical gradient using central differences for each parameter $\theta_i$:

$$\left(\nabla f(\theta)\right)_i \approx \frac{f(\theta + h e_i) - f(\theta - h e_i)}{2h}$$

where $e_i$ is the unit vector in the $i$-th coordinate direction.

3. Compare using the **relative error** rather than absolute error:

$$\text{relative error} = \frac{|f'_{analytical} - f'_{numerical}|}{\max(|f'_{analytical}|, |f'_{numerical}|)}$$

**Key Points**
- Relative error is preferred over absolute error because it accounts for the scale of the gradient values.
- A common practical threshold: relative error below $10^{-7}$ is considered a good match; above $10^{-4}$ typically indicates a bug. [Unverified — these thresholds are widely used conventions but vary by source and numerical precision context.]
- Gradient checking should be performed with double precision when possible, since single precision amplifies round-off error and can produce false positives for bugs.
- Should only be used during development/debugging, not in production training loops, since it is computationally expensive (requires $O(n)$ extra function evaluations for $n$ parameters).

### Computational Cost

For a function with $n$ parameters, computing the full gradient via finite differences requires $O(n)$ function evaluations (two per parameter for central differences), compared to a single backward pass for reverse-mode automatic differentiation. This makes finite differences impractical as a primary gradient computation method for large neural networks, but well-suited for spot-checking a small subset of parameters.

**Example**

For $f(x) = x^3$ at $x = 2$, with $h = 0.01$:

Analytical: $f'(x) = 3x^2 = 12$

Central difference:
$$f'(2) \approx \frac{f(2.01) - f(1.99)}{0.02} = \frac{8.120601 - 7.880599}{0.02} = \frac{0.240002}{0.02} = 12.0001$$

The small discrepancy (0.0001) reflects the $O(h^2)$ truncation error inherent to the method.

### Limitations

- Sensitive to noise: if $f$ has any stochastic component (e.g., dropout, mini-batch sampling), finite differences can produce misleading results unless the source of randomness is fixed/seeded during checking.
- Not suitable for functions with discontinuities or non-differentiable points (e.g., ReLU at zero), where finite differences may return a value even though the true derivative is undefined or the function is non-smooth there.
- Scales poorly with dimensionality, making it unsuitable as a general-purpose training gradient method.
- [Inference] For higher-order derivatives or mixed partial derivatives, finite difference stencils grow more complex and accumulate error faster, generally making them less reliable than for first derivatives.

**Next Steps**
- Automatic differentiation: forward mode vs. reverse mode
- Computational graphs and the chain rule in backpropagation
- Hessian-vector products and their numerical approximation
- Floating-point precision and numerical stability in optimization
- Symbolic differentiation as a contrast to numerical methods
- Taylor series expansions and their role in error analysis