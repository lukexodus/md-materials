## Model-Based Trust Region Derivative-Free Methods

### Overview

Model-based trust region derivative-free methods combine two ideas covered previously: the **trust region framework** for globalizing optimization (build a local model, constrain the step, adapt the radius based on model reliability) and **derivative-free evaluation** (construct that local model from function values alone, without gradients or Hessians). Representative algorithms include **COBYLA** (Constrained Optimization BY Linear Approximation), **BOBYQA** (Bound Optimization BY Quadratic Approximation), and more general frameworks such as **DFO-TR** and **NEWUOA**. These methods are generally more sample-efficient than direct search methods (Nelder-Mead, pattern search) because they actively reuse past function evaluations to build and refine a surrogate model, rather than discarding information outside a simplex or pattern.

### Core Idea

**Key Points**

- At each iteration $k$, maintain an **interpolation set** $\{y_1, \dots, y_p\}$ of previously evaluated points near the current iterate $x_k$.
- Fit a local model $m_k(x)$ — typically linear or quadratic — that interpolates (or approximates in a least-squares sense) $f$ at these points:

$$m_k(x_k + s) = c_k + g_k^T s + \frac{1}{2} s^T H_k s$$

where $c_k \approx f(x_k)$, and $g_k$, $H_k$ play the role of an approximate gradient and Hessian, **derived entirely from function values at the interpolation points** rather than from any differentiation.

- Solve the trust region subproblem exactly as in derivative-based trust region methods:

$$\min_{s} \; m_k(s) \quad \text{subject to} \quad \|s\| \le \Delta_k$$

- Evaluate $f$ at the candidate point $x_k + s_k$, compute the ratio $\rho_k$ of actual to predicted reduction (identical in form to the derivative-based case), and accept/reject the step and update $\Delta_k$ accordingly.

### Building the Local Model: Interpolation Requirements

- A fully determined **quadratic** model in $n$ dimensions has $\frac{(n+1)(n+2)}{2}$ free coefficients (constant, $n$ linear, $\frac{n(n+1)}{2}$ quadratic terms), requiring that many interpolation points to pin down uniquely.
- A fully determined **linear** model requires only $n+1$ points, making it far cheaper to construct — this is the choice used by COBYLA.
- Since acquiring enough points for a fully determined quadratic model can be expensive (especially as $n$ grows), many practical methods (e.g., NEWUOA, BOBYQA) use an **underdetermined quadratic model** with fewer points than the full quadratic requires, resolving the resulting non-uniqueness by minimizing the change in model Hessian between iterations (a "minimum Frobenius norm" or "least change" update), which tends to produce numerically stable, well-behaved models across iterations.

$$p_{\min} = n+1 \le p \le \frac{(n+1)(n+2)}{2} = p_{\max}$$

where $p$ is the number of interpolation points actually used.

### Algorithm Flow

```mermaid
flowchart TD
    A[Initialize interpolation set of points near x_0] --> B[Fit local model m_k from function values]
    B --> C[Solve trust region subproblem: minimize m_k(s), norm s less than Delta_k]
    C --> D[Evaluate f at candidate point x_k + s_k]
    D --> E[Compute ratio rho_k of actual to predicted reduction]
    E --> F{rho_k acceptable?}
    F -- Yes --> G[Accept step, update interpolation set with new point]
    G --> H[Expand or maintain Delta_k]
    F -- No --> I[Reject step]
    I --> J{Model considered accurate near x_k?}
    J -- Yes --> K[Shrink Delta_k]
    J -- No --> L[Improve model geometry via geometry-improving step]
    H --> M{Convergence criteria met?}
    K --> M
    L --> M
    M -- No --> B
    M -- Yes --> N[Terminate, return best point]
```

### The Geometry Problem: Poised Interpolation Sets

**Key Points**

- A critical and distinctive challenge in model-based DFO (absent from derivative-based trust region methods) is ensuring the interpolation set is **well-poised** — geometrically well-distributed enough that the resulting model is a reliable local approximation of $f$, not just an interpolant that happens to fit noise or an unrepresentative sample of points.
- A badly poised set (e.g., points nearly collinear or clustered in a lower-dimensional subspace) can produce a model with wildly inaccurate gradient/curvature estimates even though it interpolates the sampled function values exactly.
- Poisedness is typically quantified via constants bounding **Lagrange polynomials** associated with the interpolation set; a well-poised set keeps these Lagrange polynomial bounds small over the trust region.
- When the trust region ratio test fails **and** the model geometry is suspected to be the cause (rather than simply an oversized radius), the algorithm performs a **model-improvement step**: evaluate $f$ at a new point specifically chosen to improve poisedness, rather than to directly reduce $f$. This distinguishes model-based DFO's iteration structure from derivative-based trust region methods, which never need a step whose sole purpose is improving model geometry.

### Illustrative Comparison: Poised vs. Ill-Poised Interpolation Sets

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 380" font-family="Helvetica, Arial, sans-serif">
  <text x="400" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Well-Poised vs. Ill-Poised Interpolation Sets (svg_diagram)</text>

  
  <circle cx="200" cy="220" r="100" fill="#eaf2fb" stroke="#2980b9" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="200" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#2980b9">Well-Poised Set</text>
  <circle cx="200" cy="220" r="5" fill="#c0392b" />
  <text x="200" y="240" text-anchor="middle" font-size="10" fill="#333">x_k</text>
  <circle cx="270" cy="180" r="5" fill="#2980b9" />
  <circle cx="150" cy="160" r="5" fill="#2980b9" />
  <circle cx="240" cy="280" r="5" fill="#2980b9" />
  <circle cx="140" cy="270" r="5" fill="#2980b9" />
  <text x="200" y="340" text-anchor="middle" font-size="11" fill="#333">Points well-spread around x_k</text>

  
  <circle cx="600" cy="220" r="100" fill="#fbeaea" stroke="#c0392b" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="600" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#c0392b">Ill-Poised Set</text>
  <circle cx="600" cy="220" r="5" fill="#c0392b" />
  <text x="600" y="240" text-anchor="middle" font-size="10" fill="#333">x_k</text>
  <circle cx="640" cy="215" r="5" fill="#c0392b" />
  <circle cx="660" cy="212" r="5" fill="#c0392b" />
  <circle cx="620" cy="217" r="5" fill="#c0392b" />
  <circle cx="675" cy="210" r="5" fill="#c0392b" />
  <text x="600" y="340" text-anchor="middle" font-size="11" fill="#333">Points nearly collinear — unreliable model</text>

  <text x="400" y="370" text-anchor="middle" font-size="12" fill="#555">Poisedness governs whether the fitted model is trustworthy, independent of interpolation accuracy at sampled points</text>
</svg>

### COBYLA (Constrained Optimization BY Linear Approximation)

**Key Points**

- Developed by Powell (1994), COBYLA builds **linear** models of both the objective and any constraint functions using $n+1$ interpolation points (a simplex, geometrically similar to Nelder-Mead's structure, but used to construct an explicit linear model rather than being reflected/expanded/contracted directly).
- The trust region subproblem becomes a linearly constrained linear program at each iteration, solved to find the step that most improves the linear model of $f$ while respecting the linearized constraints and the trust region bound.
- COBYLA natively supports general nonlinear constraints (via their linear approximations), making it one of the few classical DFO methods designed from the outset for constrained (not just bound-constrained) problems.
- Because the model is only linear, COBYLA generally converges more slowly than quadratic-model methods once near a solution, but requires far fewer function evaluations per model update.

### BOBYQA (Bound Optimization BY Quadratic Approximation)

**Key Points**

- Also developed by Powell (2009), BOBYQA builds **underdetermined quadratic** models using $p$ interpolation points where $n+2 \le p \le \frac{(n+1)(n+2)}{2}$ (a common default is $p = 2n+1$), resolving underdetermination via the minimum-Frobenius-norm update mentioned above.
- Handles **bound constraints** ($l \le x \le u$) natively within the trust region subproblem solution, but not general nonlinear constraints (unlike COBYLA).
- Generally achieves faster local convergence than COBYLA due to the quadratic model capturing curvature information, at the cost of requiring more interpolation points and more careful geometry management.
- Widely regarded as one of the most effective derivative-free solvers for smooth, moderately-sized ($n$ up to a few hundred, [Unverified] — exact practical scaling limits are implementation- and problem-dependent) bound-constrained problems.

### NEWUOA and DFO-TR: General Unconstrained Frameworks

- **NEWUOA** (Powell, 2006) is the unconstrained predecessor to BOBYQA, using the same underdetermined quadratic modeling and minimum-Frobenius-norm update strategy, without bound-handling.
- **DFO-TR** and related academic frameworks generalize the same model-based trust region philosophy, with variants supporting regression-based models (least-squares fit rather than exact interpolation) for handling **noisy** function evaluations, where exact interpolation of noisy values would fit the noise rather than the underlying trend.

### Comparison: Model-Based Trust Region DFO vs. Direct Search Methods

| Aspect | Model-Based Trust Region DFO | Direct Search (Nelder-Mead, Pattern Search) |
|---|---|---|
| Uses past evaluation history | Yes — actively reused to build/refine model | Limited (Nelder-Mead discards replaced vertices; pattern search doesn't build a model at all) |
| Sample efficiency (evaluations needed) | Generally higher for smooth problems | Generally lower, especially in higher dimensions |
| Convergence guarantee | Yes, under standard smoothness and poisedness-maintenance assumptions | Nelder-Mead: none in general; GPS/GSS: yes, but typically slower |
| Robustness to noisy evaluations | Requires regression variants; exact interpolation can overfit noise | Comparatively more robust in some noisy settings, since no model is fit to noise directly, though the noise still corrupts comparisons and step acceptance |
| Handles general nonlinear constraints | COBYLA: yes; BOBYQA: bounds only | Generally requires penalty/barrier extensions |
| Implementation and tuning complexity | Higher — geometry management, model-improvement steps | Lower — simpler mechanics |

### Convergence Theory

**Key Points**

- Global convergence for model-based trust region DFO methods (to a first-order stationary point) has been rigorously established, most notably in the framework developed by **Conn, Scheinberg, and Vicente** (summarized in their book *Introduction to Derivative-Free Optimization*, 2009), under assumptions including: $f$ continuously differentiable with Lipschitz continuous gradient, the interpolation sets remaining well-poised (maintained via the model-improvement mechanism), and the trust region step achieving at least a Cauchy-point-equivalent fraction of decrease relative to the model gradient.
- This places model-based DFO on a similar theoretical footing to derivative-based trust region methods, a notable strength relative to Nelder-Mead's lack of general guarantees.
- Local convergence rates are generally slower than gradient-based Newton-type methods (since the model gradient/Hessian are only approximations, with error depending on interpolation set geometry and spacing), but can approach superlinear behavior in favorable, well-poised, low-noise settings. [Inference] the degree to which superlinear-like behavior is actually observed in practice depends heavily on problem smoothness, dimension, and noise level, and is not guaranteed in general.

### Practical Considerations

- **Dimension scaling**: the cost of constructing and maintaining a quadratic model grows with $n$ (both in required interpolation points and in the trust region subproblem's linear algebra), so model-based DFO is generally most attractive for small-to-moderate dimensional problems where each function evaluation is expensive enough to justify the model-fitting overhead.
- **Initial interpolation set construction**: typically built via a coordinate-based perturbation scheme similar to Nelder-Mead's initial simplex, though the specific point count and pattern differ by method (e.g., BOBYQA's default of $2n+1$ points).
- **When to prefer over direct search**: model-based DFO is generally preferred when function evaluations are expensive enough that maximizing information extracted per evaluation (via the fitted model) outweighs the additional per-iteration bookkeeping and geometry management cost.
- **Software availability**: implementations are widely available and mature — e.g., `scipy.optimize.minimize(method='COBYLA')`, Powell's original Fortran implementations of BOBYQA/NEWUOA (with various language wrappers), and the PyBOBYQA / DFO-LS packages, the latter specifically designed for noisy least-squares problems.

### Common Pitfalls

- Using exact interpolation model-based methods (standard BOBYQA/NEWUOA) directly on noisy objectives without accounting for noise — the exact interpolation assumption can cause the model to fit noise rather than the true underlying trend, degrading step quality; noise-aware regression variants exist specifically to address this.
- Underestimating the cost of quadratic model maintenance in higher dimensions, where the number of required interpolation points grows quadratically with $n$.
- Neglecting the distinction between step rejection due to an oversized trust region versus step rejection due to poor model geometry — conflating these can lead to shrinking the radius when a geometry-improving step was actually needed, slowing convergence unnecessarily.
- Choosing COBYLA for a purely bound-constrained (no general nonlinear constraints) smooth problem where BOBYQA's quadratic model would generally offer faster local convergence.

**Related Topics**

- COBYLA algorithmic details and linear programming subproblem formulation
- BOBYQA's minimum-Frobenius-norm quadratic model update mechanics
- Poisedness, Lagrange polynomials, and model-improvement algorithms
- Regression-based DFO for noisy objectives (DFO-LS, noise-aware trust region methods)
- Conn-Scheinberg-Vicente convergence theory for model-based DFO
- Comparison with derivative-based trust region methods (revisiting trust region fundamentals in the black-box setting)