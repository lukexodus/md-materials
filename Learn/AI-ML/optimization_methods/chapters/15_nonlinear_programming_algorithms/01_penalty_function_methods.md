## Penalty Function Methods

### Problem Setup

Consider the general constrained optimization problem:

$$\min_{x \in \mathbb{R}^n} \quad f(x) \quad \text{subject to} \quad c_i(x) = 0,\ i \in \mathcal{E}, \quad c_j(x) \geq 0,\ j \in \mathcal{I}$$

Penalty function methods convert this constrained problem into a **sequence of unconstrained (or simpler) problems** by adding a term to the objective that penalizes constraint violation. Instead of solving the constrained problem directly, one solves:

$$\min_{x \in \mathbb{R}^n} \quad f(x) + \rho \, P(x)$$

for one or more values of a penalty parameter $\rho > 0$, where $P(x)$ is a penalty term constructed so that $P(x) = 0$ when $x$ is feasible and $P(x) > 0$ (growing with the degree of violation) when $x$ is infeasible. As $\rho \to \infty$ (or is driven along a suitable sequence), the minimizer of the penalized problem is intended to approach the minimizer of the original constrained problem.

### Motivation

**Key Points**

Penalty methods are attractive because they replace a constrained optimization problem — which generally requires specialized machinery (active-set logic, KKT systems, feasible-region tracking) — with a sequence of unconstrained problems solvable by standard unconstrained techniques (gradient descent, Newton's method, quasi-Newton methods, conjugate gradient). This simplicity is the core appeal, though as discussed below it comes with important trade-offs in conditioning and, for some penalty types, exactness.

### Quadratic Penalty Method

**Key Points**

The most common penalty for equality constraints is the **quadratic penalty**:

$$P(x) = \frac{1}{2}\sum_{i \in \mathcal{E}} c_i(x)^2$$

giving the penalized objective:

$$Q(x;\rho) = f(x) + \frac{\rho}{2}\sum_{i \in \mathcal{E}} c_i(x)^2$$

For inequality constraints $c_j(x) \geq 0$, the corresponding term penalizes only violations:

$$P(x) = \sum_{j \in \mathcal{I}} \left[\min(0, c_j(x))\right]^2$$

so satisfied constraints ($c_j(x) \geq 0$) contribute zero penalty, while violated ones ($c_j(x) < 0$) contribute a smooth quadratic cost.

**Algorithm**

The quadratic penalty method solves a sequence of unconstrained problems for an increasing sequence $\rho_k \to \infty$:

1. Choose $\rho_1 > 0$ and starting point $x_0^s$.
2. For $k = 1, 2, \dots$: find (approximately) $x_k = \arg\min_x Q(x;\rho_k)$, starting the unconstrained solver from $x_{k-1}$.
3. Increase $\rho_{k+1} > \rho_k$ (e.g., $\rho_{k+1} = \gamma \rho_k$ for some $\gamma > 1$, commonly $\gamma \in [4, 10]$).
4. Stop when constraint violation is sufficiently small.

**Key property**: for finite $\rho$, the minimizer $x(\rho)$ of $Q(x;\rho)$ is generally **not** exactly feasible — it lies at a point where the marginal benefit of reducing $f$ balances the marginal cost of constraint violation. Only in the limit $\rho \to \infty$ does $x(\rho) \to x^*$, the true constrained solution [Inference: this limiting behavior holds under standard regularity/constraint-qualification assumptions; convergence rate and behavior for particular problems can vary].

### Ill-Conditioning in the Quadratic Penalty

**Key Points**

A well-known drawback of the quadratic penalty method is that the Hessian of $Q(x;\rho)$ becomes increasingly **ill-conditioned** as $\rho \to \infty$. Specifically:

$$\nabla^2_{xx} Q(x;\rho) = \nabla^2 f(x) + \rho \sum_i c_i(x)\nabla^2 c_i(x) + \rho \sum_i \nabla c_i(x)\nabla c_i(x)^T$$

The term $\rho \sum_i \nabla c_i(x)\nabla c_i(x)^T$ grows without bound in directions aligned with the constraint gradients, while remaining bounded in directions orthogonal to them. This creates a Hessian whose eigenvalues span an increasingly wide range as $\rho$ grows, which:

- Slows convergence of gradient-based unconstrained solvers (their convergence rate depends on the condition number).
- Causes numerical difficulties for Newton-type methods, since the linear systems being solved become increasingly ill-conditioned.

This ill-conditioning is the central practical weakness of the pure quadratic penalty approach and is the primary motivation for the augmented Lagrangian method (which mitigates it by combining the penalty with an explicit multiplier estimate, avoiding the need to send $\rho \to \infty$).

### Exact Penalty Functions (ℓ1 Penalty)

**Key Points**

An alternative class of penalty functions is designed to be **exact**: for a finite (not infinite) value of $\rho$, the minimizer of the penalized problem coincides exactly with the constrained solution $x^*$. The most common exact penalty is the **$\ell_1$ penalty**:

$$\phi_1(x;\rho) = f(x) + \rho \sum_{i \in \mathcal{E}} |c_i(x)| + \rho \sum_{j \in \mathcal{I}} \max(0, -c_j(x))$$

**Exactness condition**: under standard assumptions (e.g., $x^*$ satisfies second-order sufficient conditions and the linear independence constraint qualification), $x^*$ is a local minimizer of $\phi_1(x;\rho)$ for any $\rho > \rho^* $, where $\rho^*$ must exceed the largest magnitude among the optimal Lagrange multipliers $|\lambda_i^*|$, $|\mu_j^*|$ associated with $x^*$. This is a substantial practical advantage: a single unconstrained (or bound-appropriate) minimization at a sufficiently large fixed $\rho$ suffices in principle, avoiding the $\rho \to \infty$ sequence of the quadratic penalty.

**Trade-off — non-smoothness**: the price of exactness is that $\phi_1$ is **non-smooth** at points where any $c_i(x) = 0$ (equality constraints) or where $c_j(x) = 0$ for active inequalities, because $|\cdot|$ and $\max(0,\cdot)$ are non-differentiable there. This precludes the direct use of standard smooth unconstrained solvers (which assume differentiability) and requires either:
- Specialized non-smooth optimization techniques (subgradient methods, bundle methods).
- Reformulation as a smooth constrained problem (e.g., introducing slack variables to convert $\ell_1$-penalized problems into smooth QPs — this is in fact one of the standard motivations for the $S\ell_1QP$ / SLQP family of methods).

Other exact penalty choices include the $\ell_\infty$ penalty, which shares the non-smoothness trade-off.

### Comparison: Quadratic vs. Exact ($\ell_1$) Penalty

| Aspect | Quadratic Penalty | Exact ($\ell_1$) Penalty |
|---|---|---|
| Smoothness | Smooth (differentiable) | Non-smooth at constraint boundaries |
| Exactness | Requires $\rho \to \infty$ for exact feasibility | Exact for any finite $\rho > \rho^*$ |
| Conditioning | Increasingly ill-conditioned as $\rho$ grows | Conditioning issues avoided by fixed finite $\rho$, but non-smoothness introduces different numerical difficulties |
| Solver compatibility | Standard smooth unconstrained solvers | Requires non-smooth optimization or reformulation |
| Typical use | Building block for augmented Lagrangian | Basis for merit functions in SQP; standalone exact penalty solvers |

### Structure of the Penalty Method Loop

```mermaid
flowchart TD
    A[Choose initial rho, starting point] --> B[Form penalized objective f(x) + rho times P(x)]
    B --> C[Solve unconstrained minimization approximately]
    C --> D{Constraint violation small enough?}
    D -->|No| E[Increase rho, e.g. rho = gamma times rho]
    E --> F[Warm-start next minimization from current x]
    F --> B
    D -->|Yes| G[Return approximate solution]
```

### Worked Example — Quadratic Penalty

**Example**

Minimize $f(x) = x^2$ subject to $c(x) = x - 1 = 0$ (trivial equality-constrained problem with known solution $x^* = 1$).

The penalized objective:

$$Q(x;\rho) = x^2 + \frac{\rho}{2}(x-1)^2$$

Setting the derivative to zero:

$$\frac{dQ}{dx} = 2x + \rho(x-1) = 0 \implies x(2+\rho) = \rho \implies x(\rho) = \frac{\rho}{2+\rho}$$

**Output**

| $\rho$ | $x(\rho)$ | Distance from $x^*=1$ |
|---|---|---|
| 1 | 0.333 | 0.667 |
| 10 | 0.833 | 0.167 |
| 100 | 0.980 | 0.020 |
| 1000 | 0.998 | 0.002 |

As $\rho \to \infty$, $x(\rho) \to 1 = x^*$, confirming convergence to the true constrained solution, but only in the limit — for any finite $\rho$, the penalized minimizer remains strictly infeasible ($x(\rho) \neq 1$). This finite-$\rho$ infeasibility is exactly the behavior described above as characteristic of the quadratic penalty, in contrast to an exact penalty which would return $x=1$ for a sufficiently large finite $\rho$.

### Penalty Trajectory Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420" font-family="Helvetica, Arial, sans-serif">
  <text x="400" y="28" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Quadratic Penalty Minimizer Trajectory as rho Increases (svg_diagram)</text>

  <line x1="80" y1="360" x2="740" y2="360" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="360" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="410" y="395" font-size="13" text-anchor="middle" fill="#333">x (penalized minimizer)</text>
  <text x="35" y="210" font-size="13" text-anchor="middle" fill="#333" transform="rotate(-90 35 210)">rho (increasing)</text>

  <line x1="700" y1="60" x2="700" y2="360" stroke="#15803d" stroke-width="1.5" stroke-dasharray="5,4" />
  <text x="700" y="50" font-size="12" text-anchor="middle" fill="#15803d">x* = 1 (feasible target)</text>

  <path d="M 120 350 Q 300 300 450 200 T 690 75" fill="none" stroke="#c2410c" stroke-width="2.5" />

  <circle cx="120" cy="350" r="5" fill="#c2410c" />
  <text x="120" y="372" font-size="11" text-anchor="middle" fill="#333">rho=1</text>

  <circle cx="330" cy="270" r="5" fill="#c2410c" />
  <text x="330" y="292" font-size="11" text-anchor="middle" fill="#333">rho=10</text>

  <circle cx="520" cy="150" r="5" fill="#c2410c" />
  <text x="520" y="172" font-size="11" text-anchor="middle" fill="#333">rho=100</text>

  <circle cx="670" cy="85" r="5" fill="#c2410c" />
  <text x="670" y="107" font-size="11" text-anchor="middle" fill="#333">rho=1000</text>

  <text x="410" y="415" font-size="12" text-anchor="middle" fill="#555">Minimizer approaches x* asymptotically but never reaches it for finite rho</text>
</svg>

### Practical Difficulties and Remedies

**Key Points**

- **Choosing the penalty schedule**: too slow a growth in $\rho_k$ wastes iterations on nearly-feasible-but-not-quite solutions; too fast a growth immediately triggers severe ill-conditioning. [Inference] A geometric growth schedule with moderate factors (commonly cited in the range of 4 to 10) is a widely used heuristic balance, though optimal schedules are problem-dependent.
- **Warm-starting**: each unconstrained subproblem should be initialized from the previous subproblem's solution, since consecutive penalized problems are close to one another for a well-chosen $\rho$ schedule — this significantly reduces the number of inner iterations needed.
- **Termination**: since exact minimization of each subproblem is computationally wasteful (especially for early, small $\rho$), practical implementations solve each subproblem only to a loose tolerance that tightens as $\rho$ grows.
- **Numerical breakdown at large $\rho$**: because of the conditioning issue discussed above, most modern solvers avoid driving $\rho \to \infty$ in a pure quadratic penalty scheme, using it instead as one ingredient inside the augmented Lagrangian method, where a multiplier estimate does most of the work of enforcing feasibility and $\rho$ need only reach a moderate, bounded value.

### Relationship to Other Methods

**Key Points**

- **Augmented Lagrangian**: adds an explicit multiplier term $-\lambda^Tc(x)$ to the quadratic penalty, i.e. $f(x) - \lambda^Tc(x) + \frac{\rho}{2}\|c(x)\|^2$, which achieves exact feasibility at finite (often modest) $\rho$ by updating $\lambda$ alongside $x$, directly addressing the ill-conditioning weakness of the pure quadratic penalty.
- **Barrier methods**: a related but distinct family (interior-point methods) that penalizes *approaching* the boundary of inequality-feasible regions from the interior, rather than penalizing violation from outside — conceptually complementary to exterior penalty methods described here.
- **SQP merit functions**: the $\ell_1$ exact penalty function reappears directly as a merit function for globalizing SQP steps, linking this topic back to the SQP subproblem material.

### Conclusion

Penalty function methods reformulate constrained optimization as a sequence of unconstrained (or simpler) problems by adding a term that penalizes constraint violation. The quadratic penalty is smooth and easy to work with but requires driving the penalty parameter to infinity to achieve exact feasibility, at the cost of increasing ill-conditioning of the resulting unconstrained subproblems. Exact penalty functions such as the $\ell_1$ penalty avoid this by achieving exact feasibility at a finite (sufficiently large) penalty parameter, but introduce non-smoothness that complicates their direct unconstrained minimization. These trade-offs directly motivate more advanced approaches — most notably the augmented Lagrangian method — that aim to combine the practical simplicity of penalty methods with better conditioning and exactness properties.

**Related Topics**
- Augmented Lagrangian methods
- Barrier and interior-point methods
- Non-smooth optimization: subgradient and bundle methods
- Exact penalty functions as SQP merit functions
- Lagrange multiplier estimation techniques
- Constraint qualification conditions (LICQ, MFCQ)
- Convergence rate analysis for penalty parameter sequences
- Slack-variable reformulations of non-smooth penalties