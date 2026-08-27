## Trust Region Radius Update Rules

### Overview

Trust region radius update rules govern how the size of the trust region — the neighborhood around the current iterate within which a local model (typically quadratic) is trusted to approximate the objective function — grows or shrinks between iterations. The update is driven by comparing actual reduction in the objective against the reduction predicted by the model, encoded in the ratio $\rho_k$.

### Core Mechanism

At each iteration $k$, a step $p_k$ is computed by (approximately) solving the trust region subproblem:

$$\min_{p} ; m_k(p) = f(x_k) + \nabla f(x_k)^T p + \frac{1}{2} p^T B_k p \quad \text{subject to} \quad |p| \leq \Delta_k$$

where $\Delta_k$ is the current trust region radius and $B_k$ is a symmetric approximation to the Hessian (or the exact Hessian).

The quality of the step is assessed via the ratio:

$$\rho_k = \frac{f(x_k) - f(x_k + p_k)}{m_k(0) - m_k(p_k)}$$

The numerator is the **actual reduction**, and the denominator is the **predicted reduction** (always non-negative for a properly solved subproblem, since $m_k(0) - m_k(p_k) \geq 0$).

### Interpreting $\rho_k$

**Key Points**

- $\rho_k \approx 1$: the model predicted the actual behavior of $f$ well; the step is trustworthy.
- $\rho_k$ small or negative: the model is a poor local approximation; the step should be rejected or the region shrunk.
- $\rho_k$ large but the step is at the boundary ($|p_k| = \Delta_k$): the model may support a larger step; expanding the radius could allow faster progress.
- $\rho_k$ moderate: the current radius is roughly appropriate; leave it unchanged.

### Standard Update Rule

A widely used formulation (following Nocedal and Wright's presentation of the classical algorithm) partitions $\rho_k$ into thresholds $0 < \eta_1 < \eta_2 < 1$ (common choices: $\eta_1 = 0.25$, $\eta_2 = 0.75$) and defines expansion/contraction factors $0 < \gamma_1 < 1 < \gamma_2$ (common choices: $\gamma_1 = 0.25$ or $0.5$, $\gamma_2 = 2$):

$$ \Delta_{k+1} = \begin{cases} \gamma_1 \Delta_k & \text{if } \rho_k < \eta_1 \ \Delta_k & \text{if } \eta_1 \leq \rho_k \leq \eta_2 \ \min(\gamma_2 \Delta_k, \Delta_{\max}) & \text{if } \rho_k > \eta_2 \text{ and } |p_k| = \Delta_k \end{cases} $$

If $\rho_k > \eta_2$ but the step did not hit the boundary (i.e., $|p_k| < \Delta_k$), the radius is typically left unchanged — expanding it would have no immediate effect on the step just taken and risks growing the region without evidence that a larger step is needed.

$\Delta_{\max}$ is an upper bound imposed to prevent the radius from growing without limit, which would otherwise let the method behave like an unconstrained Newton step in flat or well-approximated regions and lose the safeguarding benefit of the trust region entirely.

### Step Acceptance Coupled to the Ratio

The radius update is usually paired with a step acceptance rule, since a poor ratio should also mean the step itself is rejected:

$$ x_{k+1} = \begin{cases} x_k + p_k & \text{if } \rho_k > \eta_1 \ x_k & \text{otherwise} \end{cases} $$

Note that the acceptance threshold and the shrink threshold are often the same value ($\eta_1$), though some implementations use a separate, smaller acceptance threshold $\eta_0 \leq \eta_1$ (e.g., $\eta_0 = 10^{-4}$) so that even marginally productive steps are accepted while the radius still shrinks if $\rho_k$ falls in $[\eta_0, \eta_1)$. [Unverified] The exact threshold values and whether acceptance and shrink thresholds are unified vary across software packages and textbooks, so specific numeric defaults should be checked against the implementation in use.

### Decision Flow

```mermaid
flowchart TD
    A[Solve trust region subproblem for step p_k] --> B[Compute rho_k = actual reduction / predicted reduction]
    B --> C{rho_k less than eta_1?}
    C -->|Yes| D[Reject step: x_k+1 = x_k]
    D --> E[Shrink radius: Delta_k+1 = gamma_1 times Delta_k]
    C -->|No| F[Accept step: x_k+1 = x_k + p_k]
    F --> G{rho_k greater than eta_2 AND step at boundary?}
    G -->|Yes| H[Expand radius: Delta_k+1 = min(gamma_2 times Delta_k, Delta_max)]
    G -->|No| I[Keep radius unchanged: Delta_k+1 = Delta_k]
```

### Why the Boundary Condition Matters for Expansion

Expansion is conditioned on $|p_k| = \Delta_k$ because if the unconstrained minimizer of the model already lies strictly inside the trust region, the current radius was never actually a binding constraint on that step. Growing $\Delta_k$ in that case provides no information about whether a larger step would still be productive — the model was free to choose a smaller step and did. Restricting expansion to boundary-active steps ties radius growth to actual evidence that the constraint was limiting progress.

### Geometric Illustration

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg"> <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Trust Region Radius Update (svg_diagram)</text> <!-- Panel 1: Shrink case --> <g transform="translate(20,60)"> <text x="100" y="0" text-anchor="middle" font-size="14" font-weight="bold" fill="#b91c1c">Poor Fit: Shrink</text> <circle cx="100" cy="120" r="80" fill="none" stroke="#b91c1c" stroke-width="2" stroke-dasharray="4,3"/> <circle cx="100" cy="120" r="45" fill="none" stroke="#16a34a" stroke-width="2"/> <circle cx="100" cy="120" r="3" fill="#1a1a1a"/> <text x="100" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">x_k</text> <line x1="100" y1="120" x2="165" y2="85" stroke="#2563eb" stroke-width="2" marker-end="url(#arrow)"/> <text x="185" y="80" font-size="11" fill="#2563eb">p_k</text> <text x="100" y="220" text-anchor="middle" font-size="11" fill="#1a1a1a">rho_k less than eta_1</text> <text x="100" y="236" text-anchor="middle" font-size="11" fill="#1a1a1a">new radius (green) &lt; old (red)</text> </g> <!-- Panel 2: Unchanged case --> <g transform="translate(260,60)"> <text x="100" y="0" text-anchor="middle" font-size="14" font-weight="bold" fill="#1d4ed8">Good Fit: Unchanged</text> <circle cx="100" cy="120" r="70" fill="none" stroke="#1d4ed8" stroke-width="2"/> <circle cx="100" cy="120" r="3" fill="#1a1a1a"/> <text x="100" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">x_k</text> <line x1="100" y1="120" x2="150" y2="70" stroke="#2563eb" stroke-width="2" marker-end="url(#arrow)"/> <text x="165" y="65" font-size="11" fill="#2563eb">p_k</text> <text x="100" y="220" text-anchor="middle" font-size="11" fill="#1a1a1a">eta_1 &lt;= rho_k &lt;= eta_2</text> <text x="100" y="236" text-anchor="middle" font-size="11" fill="#1a1a1a">radius stays the same</text> </g> <!-- Panel 3: Expand case --> <g transform="translate(500,60)"> <text x="100" y="0" text-anchor="middle" font-size="14" font-weight="bold" fill="#15803d">Great Fit: Expand</text> <circle cx="100" cy="120" r="50" fill="none" stroke="#15803d" stroke-width="2" stroke-dasharray="4,3"/> <circle cx="100" cy="120" r="80" fill="none" stroke="#f59e0b" stroke-width="2"/> <circle cx="100" cy="120" r="3" fill="#1a1a1a"/> <text x="100" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">x_k</text> <line x1="100" y1="120" x2="140" y2="79" stroke="#2563eb" stroke-width="2" marker-end="url(#arrow)"/> <text x="130" y="70" font-size="11" fill="#2563eb">p_k (at boundary)</text> <text x="100" y="220" text-anchor="middle" font-size="11" fill="#1a1a1a">rho_k greater than eta_2, ||p_k|| = Delta_k</text> <text x="100" y="236" text-anchor="middle" font-size="11" fill="#1a1a1a">new radius (orange) &gt; old (green)</text> </g> <defs> <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#2563eb"/> </marker> </defs> </svg>

### Practical Considerations

**Key Points**

- **Threshold sensitivity**: values of $\eta_1$, $\eta_2$, $\gamma_1$, $\gamma_2$ affect convergence speed but not the global convergence guarantees of the method, provided $0 < \eta_1 \leq \eta_2 < 1$ and $0 < \gamma_1 < 1 < \gamma_2$ hold. [Inference] The precise sensitivity of iteration counts to particular threshold choices is problem-dependent and not something that can be stated as a universal quantitative rule.
- **Initial radius $\Delta_0$**: chosen based on problem scaling; too large wastes early iterations on rejected steps, too small slows early progress. A common heuristic is to set $\Delta_0$ relative to the scale of the initial step computed by a simple method (e.g., steepest descent) or to a fixed small multiple of $|x_0|$.
- **$\Delta_{\max}$**: prevents runaway growth in flat regions and keeps the local model's validity assumption from being stretched too far.
- **Negative $\rho_k$**: an increase in $f$ despite the step; always triggers rejection and shrinkage regardless of specific threshold conventions used.
- **Interaction with subproblem solver accuracy**: if the trust region subproblem is only solved approximately (e.g., via the dogleg method or truncated conjugate gradient), the predicted reduction $m_k(0) - m_k(p_k)$ still must be non-negative and sufficiently large relative to a Cauchy-point-based bound for the standard convergence theory to apply.

### Common Variants

- **Continuous/adaptive scaling**: instead of discrete multiplicative factors, some implementations scale $\Delta_k$ continuously as a function of $\rho_k$, e.g., using a smooth function that interpolates between shrink and expand factors.
- **Trust region reset on failed steps**: some implementations impose a minimum radius $\Delta_{\min}$ below which the algorithm terminates or switches to an alternative strategy, treating persistent shrinkage as a stalling signal.
- **Norm choice**: the update rule itself is norm-agnostic, but the choice of norm ($\ell_2$, $\ell_\infty$, or a scaled/elliptical norm via $|p|_M = \sqrt{p^T M p}$) changes the shape of the trust region and interacts with problem scaling; the radius update logic above applies unchanged regardless of norm choice.

### Convergence Relevance

The radius update rule is central to the global convergence proofs for trust region methods. The standard result (e.g., Theorem 4.6 style results in Nocedal and Wright) shows that if $B_k$ is bounded, the model gradient matches $\nabla f(x_k)$ exactly, and the step satisfies a sufficient decrease condition relative to the Cauchy point, then $\liminf_{k \to \infty} |\nabla f(x_k)| = 0$. The shrink-on-poor-fit, expand-on-boundary-active-good-fit structure is what guarantees the radius does not shrink to zero prematurely while also not permitting unbounded growth that would violate the local model's validity.

### Related Topics

- Cauchy point computation and the sufficient decrease condition
- Dogleg method for approximately solving the trust region subproblem
- Steihaug-Toint truncated conjugate gradient method
- Trust region subproblem solvers for large-scale/sparse Hessians
- Comparison of trust region methods vs. line search methods
- Levenberg-Marquardt method as a trust-region-like approach for nonlinear least squares
- Global convergence theory for trust region methods
- Scaled and elliptical trust regions
