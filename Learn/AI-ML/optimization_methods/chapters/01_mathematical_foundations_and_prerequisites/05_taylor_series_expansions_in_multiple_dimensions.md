## Taylor Series Expansions in Multiple Dimensions

### Single-Variable Review

Before generalizing, recall the single-variable Taylor expansion of $f: \mathbb{R} \to \mathbb{R}$ around a point $x$:

$$f(x + h) = f(x) + f'(x) h + \frac{1}{2!} f''(x) h^2 + \frac{1}{3!} f'''(x) h^3 + \dots$$

Multivariable Taylor expansion generalizes each term using gradients, Hessians, and higher-order tensors in place of scalar derivatives, with the same underlying purpose: approximating a function locally by a polynomial that is easy to analyze and optimize.

### First-Order (Linear) Expansion

For $f: \mathbb{R}^n \to \mathbb{R}$ differentiable at $x$, the first-order Taylor expansion around $x$ in direction $\Delta x$ is:

$$f(x + \Delta x) = f(x) + \nabla f(x)^T \Delta x + o(\|\Delta x\|)$$

where $o(\|\Delta x\|)$ denotes a remainder term that vanishes faster than $\|\Delta x\|$ as $\Delta x \to 0$. Dropping the remainder gives the linear (tangent-plane) approximation:

$$f(x + \Delta x) \approx f(x) + \nabla f(x)^T \Delta x$$

This is the basis of gradient descent: since this linear model is only accurate locally, the update step is taken in the direction that decreases the linear model most, then re-evaluated — $x_{k+1} = x_k - \alpha \nabla f(x_k)$, with step size $\alpha$ controlling how far the linear approximation can be trusted.

### Second-Order (Quadratic) Expansion

Assuming $f$ is twice continuously differentiable, the second-order expansion is:

$$f(x + \Delta x) = f(x) + \nabla f(x)^T \Delta x + \frac{1}{2} \Delta x^T \nabla^2 f(x) \, \Delta x + o(\|\Delta x\|^2)$$

Dropping the remainder gives the quadratic model:

$$q(\Delta x) = f(x) + \nabla f(x)^T \Delta x + \frac{1}{2} \Delta x^T \nabla^2 f(x) \, \Delta x$$

This quadratic model is the theoretical foundation of nearly all second-order optimization:

- **Newton's method** minimizes $q(\Delta x)$ exactly by setting its gradient to zero: $\nabla f(x) + \nabla^2 f(x) \Delta x = 0 \implies \Delta x = -\nabla^2 f(x)^{-1} \nabla f(x)$.
- **Trust-region methods** minimize $q(\Delta x)$ subject to $\|\Delta x\| \leq \Delta$, using the quadratic model only within a region where it is trusted to be accurate.
- **Quasi-Newton methods** (BFGS, L-BFGS) build and refine an approximation to $\nabla^2 f(x)$ using only gradient information, then apply this same quadratic-minimization logic.

### Exact Form with Remainder (Taylor's Theorem)

For a rigorous statement, Taylor's theorem with the Lagrange form of the remainder states that for some $t \in (0, 1)$:

$$f(x + \Delta x) = f(x) + \nabla f(x)^T \Delta x + \frac{1}{2} \Delta x^T \nabla^2 f(x + t\Delta x) \, \Delta x$$

Here the Hessian is evaluated at an intermediate point $x + t\Delta x$ rather than at $x$ itself, making this an *exact* equality rather than an approximation (assuming sufficient smoothness). This exact form underlies convergence proofs for Newton-type methods, since bounding the Hessian's variation between $x$ and $x + t\Delta x$ (e.g., via a Lipschitz continuity assumption on $\nabla^2 f$) is what allows convergence rate guarantees to be established rigorously.

### Multi-Index Notation for Higher Orders

For expansions beyond second order, multi-index notation compactly handles the growing number of terms. A multi-index $\alpha = (\alpha_1, \dots, \alpha_n)$ with $|\alpha| = \sum_i \alpha_i$ allows the general Taylor expansion to be written:

$$f(x + \Delta x) = \sum_{|\alpha| \geq 0} \frac{1}{\alpha!} D^\alpha f(x) \, \Delta x^\alpha$$

where $D^\alpha f = \frac{\partial^{|\alpha|} f}{\partial x_1^{\alpha_1} \cdots \partial x_n^{\alpha_n}}$, $\alpha! = \alpha_1! \cdots \alpha_n!$, and $\Delta x^\alpha = \Delta x_1^{\alpha_1} \cdots \Delta x_n^{\alpha_n}$. [Inference — standard notation from multivariable analysis, included for completeness; most optimization methods in practice use only first- and second-order terms, since third-order tensors are rarely tractable to compute or store]

### Directional Taylor Expansion

A useful equivalent formulation restricts the expansion along a single direction $d$ (with $\|d\|=1$) and scalar step $\alpha$, reducing the multivariable problem to a single-variable one:

$$\phi(\alpha) = f(x + \alpha d), \quad \phi(\alpha) = \phi(0) + \phi'(0)\alpha + \frac{1}{2}\phi''(0)\alpha^2 + \dots$$

where $\phi'(0) = \nabla f(x)^T d$ and $\phi''(0) = d^T \nabla^2 f(x) \, d$. This directional reduction is exactly the mathematical device used inside line-search methods: once a search direction $d$ is chosen, finding a good step size $\alpha$ becomes a one-dimensional optimization problem, and the Taylor expansion of $\phi(\alpha)$ underlies the Armijo and Wolfe conditions used to certify sufficient decrease.

### Error Bounds and Model Trust

The gap between the true function $f(x + \Delta x)$ and the quadratic model $q(\Delta x)$ is bounded (for $\nabla^2 f$ Lipschitz continuous with constant $L$) by:

$$|f(x + \Delta x) - q(\Delta x)| \leq \frac{L}{6} \|\Delta x\|^3$$

[Inference — standard result under Lipschitz-Hessian assumptions, commonly used in trust-region and cubic-regularization convergence analysis; the specific constant and exponent depend on the exact smoothness assumption imposed]

This cubic-order error bound is precisely what justifies trust-region radius adjustment rules: if the actual decrease in $f$ closely matches the predicted decrease from $q(\Delta x)$, the model is trustworthy and the region can expand; if not, the region contracts, since the mismatch signals the step exceeded where the quadratic approximation remains accurate.

### Illustration: Taylor Model Order vs. Optimization Method (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 260">
  <text x="280" y="22" text-anchor="middle" font-size="16" font-weight="bold" fill="#111">Taylor Order and Corresponding Methods (svg_diagram)</text>

  <line x1="60" y1="220" x2="500" y2="220" stroke="#333" stroke-width="1.5" />
  <text x="280" y="245" text-anchor="middle" font-size="12" fill="#333">Δx (step)</text>

  <path d="M 60,150 C 200,120 350,90 500,60" fill="none" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="505" y="60" font-size="11" fill="#888">f(x+Δx) true</text>

  <line x1="60" y1="150" x2="500" y2="70" stroke="#2980b9" stroke-width="2" />
  <text x="505" y="72" font-size="11" fill="#2980b9">1st-order (linear)</text>

  <path d="M 60,150 Q 280,55 500,110" fill="none" stroke="#c0392b" stroke-width="2" />
  <text x="505" y="112" font-size="11" fill="#c0392b">2nd-order (quadratic)</text>

  <circle cx="60" cy="150" r="3.5" fill="#111" />
  <text x="45" y="170" font-size="11" fill="#111">x</text>
</svg>

### Illustration: From Taylor Expansion to Optimization Method

```mermaid
flowchart TD
    A[Taylor Expansion of f at x] --> B[1st-order: f(x) + grad^T Δx]
    A --> C[2nd-order: + 1/2 Δx^T Hess Δx]
    B --> D[Minimize linear model in a direction]
    D --> E[Gradient Descent]
    C --> F[Minimize quadratic model exactly]
    F --> G[Newton's Method]
    C --> H[Minimize quadratic model within trust radius]
    H --> I[Trust-Region Methods]
```

### Related Topics

- **Gradients, Jacobians, and Hessians**: the derivative objects populating each expansion order
- **Newton's method**: exact minimization of the second-order Taylor model
- **Trust-region methods**: constrained minimization of the quadratic model with adaptive radius
- **Line search methods and Wolfe conditions**: directional Taylor expansion applied to step-size selection
- **Lipschitz continuity assumptions**: smoothness conditions enabling rigorous convergence rate proofs