## Generalized Benders Decomposition

### Overview

Generalized Benders Decomposition (GBD) extends classical Benders decomposition — originally devised for mixed-integer linear programs with a block-angular structure — to convex MINLP. It alternates between a nonlinear subproblem with integer (complicating) variables fixed and a master problem that accumulates cuts derived from the subproblem's dual information, projecting the continuous variables out of the master problem entirely. GBD is closely related to outer approximation but generates weaker, more aggregated cuts, trading cut strength for a smaller and simpler master problem.

### Core Idea: Projection and Duality

Given a convex MINLP

$$\min_{x,y} f(x,y) \quad \text{s.t.} \quad g(x,y) \le 0, \quad x \in X, \; y \in Y \cap \mathbb{Z}^p$$

GBD reformulates by projecting out $x$, defining $v(y) = \min_x \{f(x,y) : g(x,y) \le 0, x \in X\}$ as the optimal value of the NLP subproblem for a fixed $y$. The original problem becomes $\min_y v(y)$, and GBD constructs $v(y)$'s outer approximation using **support functions built from Lagrangian duality** rather than direct linearization of $f$ and $g$ in $(x,y)$-space.

**Key Points**

- This projection is the key structural difference from OA: GBD's master problem contains only $y$ and an auxiliary objective variable, while OA's master problem retains both $x$ and $y$
- The Lagrangian of the NLP subproblem at fixed $y$, $L(x, y, \lambda) = f(x,y) + \lambda^T g(x,y)$, supplies the dual multipliers $\lambda^k$ used to build cuts valid for all $y$, not just the $y^k$ at which they were generated

### Algorithm Structure

#### Step 1: Primal (NLP) Subproblem

Fix $y = y^k$ and solve:

$$v(y^k) = \min_x f(x, y^k) \quad \text{s.t.} \quad g(x, y^k) \le 0, \quad x \in X$$

obtaining the optimal $x^k$ and the associated Lagrange multipliers $\lambda^k$ for the constraints $g(x, y^k) \le 0$.

**Key Points**

- If feasible, $v(y^k)$ gives an upper bound on the MINLP optimum
- If infeasible, a feasibility subproblem is solved instead, yielding multipliers that generate a feasibility cut rather than an optimality cut

#### Step 2: Benders Cut Construction

Using the multipliers $\lambda^k$, form the Lagrangian function evaluated at $x^k$ as a function of $y$ alone:

$$\eta \ge f(x^k, y) + (\lambda^k)^T g(x^k, y)$$

This inequality, added to the master problem, is a valid **support function** (Benders cut) for $v(y)$ at every $y$, not merely at $y^k$ — the defining property that lets the master problem generalize beyond the single point where the cut was generated.

**Key Points**

- Because $f$ and $g$ are convex and $\lambda^k \ge 0$, weak duality guarantees $f(x^k, y) + (\lambda^k)^T g(x^k, y) \le v(y)$ for all feasible $y$, so the cut never excludes the true optimal value
- The cut is evaluated as a function of $y$ with $x$ fixed at $x^k$ — this is what distinguishes it from OA's linearization, which varies both $x$ and $y$ around the linearization point

#### Step 3: Master Problem

$$\min_{y, \eta} \eta \quad \text{s.t.} \quad \eta \ge f(x^j, y) + (\lambda^j)^T g(x^j, y) \quad \forall j \le k, \quad y \in Y \cap \mathbb{Z}^p$$

Solving this MILP (or MINLP, if the Lagrangian retains nonlinearity in $y$) yields a new candidate $y^{k+1}$ and a valid lower bound on the MINLP optimum.

**Key Points**

- If $g$ is nonlinear in $y$, the master problem itself may remain nonlinear (a MINLP rather than MILP), unlike OA's master problem, which is linear in $y$ by construction of direct linearization
- This is a notable practical distinction: GBD's master problem simplification is not guaranteed to be an MILP in general, only when the Lagrangian happens to be linear or when further linearization is applied

### GBD Iteration Flow

```mermaid
flowchart TD
    A[Initial integer assignment y0] --> B[Solve NLP with y fixed, obtain x_k and multipliers lambda_k]
    B --> C{NLP feasible?}
    C -- Yes --> D[Record upper bound v(y_k), form optimality cut from Lagrangian]
    C -- No --> E[Solve feasibility subproblem, form feasibility cut]
    D --> F[Add Benders cut to master problem]
    E --> F
    F --> G[Solve master problem for y and eta]
    G --> H[Obtain new y, and lower bound from master objective]
    H --> I{Lower bound >= best upper bound?}
    I -- No --> B
    I -- Yes --> J[Terminate: return best integer-feasible solution]
```

### GBD Cut Geometry vs. OA (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 660 320">
\<style\>
.curve { fill: none; stroke: var(--text-primary, #222); stroke-width: 2.5; }
.oa_line { stroke: var(--text-secondary, #666); stroke-width: 1.3; stroke-dasharray: 3,3; }
.gbd_line { stroke: var(--text-secondary, #999); stroke-width: 1.8; }
.point { fill: var(--text-primary, #222); }
.label { font-family: sans-serif; font-size: 13px; fill: var(--text-primary, #222); text-anchor: middle; }
\</style\>
<text x="330" y="24" class="label" font-size="16" font-weight="bold">v(y): GBD Support Function vs. OA Linearization (svg_diagram)</text>
<path d="M80,260 Q200,80 330,140 Q460,190 580,90" class="curve" />
<text x="330" y="290" class="label">v(y), the projected value function</text>
<circle cx="330" cy="140" r="5" class="point" />
<line x1="120" y1="270" x2="560" y2="60" class="oa_line" />
<text x="500" y="60" class="label" font-size="11">OA tangent (direct linearization)</text>
<line x1="120" y1="230" x2="560" y2="130" class="gbd_line" />
<text x="500" y="150" class="label" font-size="11">GBD Lagrangian support (looser)</text>
</svg>

### Relationship to Outer Approximation

**Key Points**

- OA cuts are generally at least as tight as GBD cuts at every point, because OA linearizes $f$ and $g$ jointly in $(x,y)$ around the subproblem solution, while GBD's Lagrangian support function is a projection that discards information about how the optimal $x$ would shift as $y$ varies
- [Unverified] This tightness relationship (OA dominates GBD) is a standard result in the MINLP literature, though the practical iteration-count gap between the two methods is instance-dependent and not guaranteed to be large in every case
- GBD's master problem is smaller (only $y$ and $\eta$, versus OA's full $(x, y, \eta)$), which can matter when $x$ is high-dimensional and the master MILP/MINLP solve time dominates
- Both methods share the same finite-convergence argument: a bounded integer set $Y$, monotonically improving bounds, and cuts that permanently exclude previously explored (and now dominated) $y$ values from being re-optimal without new supporting information

### Convergence Properties

**Key Points**

- The lower bound sequence from successive master problem solutions is non-decreasing, since cuts only accumulate and tighten the feasible region for $\eta$
- The upper bound sequence from successive NLP subproblem solutions is non-increasing by construction (only improving feasible solutions are retained)
- Finite convergence follows from $Y \cap \mathbb{Z}^p$ being finite (assuming bounded integer variables) combined with the fact that each iteration either improves the bounds or reveals that no further improvement is possible
- Convexity of $f$ and $g$ in $x$ is essential: it is what makes weak duality yield a valid global underestimator of $v(y)$ from the Lagrangian at any single $(x^k, \lambda^k)$

### When GBD Is Preferred Over OA

**Key Points**

- Favorable when the NLP subproblem has separable or block-decomposable structure across scenarios, since GBD's dual-based cuts naturally aggregate information from decomposed subproblems — a common pattern in two-stage stochastic programming, where GBD generalizes directly to multi-cut variants across scenarios
- Favorable when $x$ is very high-dimensional relative to $y$, since the master problem's size no longer scales with the dimension of $x$
- Less favorable when the weaker cuts translate into materially more iterations, since each iteration still requires a full NLP solve — the same per-iteration cost as OA, but potentially more iterations to converge

### Extensions

#### Nonconvex Generalized Benders Decomposition

When $f$ or $g$ are nonconvex in $x$, weak duality still holds (the Lagrangian dual value always underestimates the primal), but the duality gap may be strictly positive, so the resulting cuts may be **weaker than valid** — they can still be constructed but no longer guarantee that $v(y)$ is never underestimated at the level needed for finite convergence to the true global optimum. [Inference] This is why nonconvex GBD is typically embedded within an outer global-optimization framework (e.g., spatial branch-and-bound) rather than used as a standalone exact method in the nonconvex setting.

#### Multi-Cut GBD for Stochastic Programs

In two-stage stochastic MINLP, GBD naturally decomposes by scenario: each scenario's subproblem is solved independently for a fixed first-stage decision $y$, generating one cut per scenario per iteration (multi-cut) rather than a single aggregated cut, which can improve convergence at the cost of a larger master problem — the same size-versus-strength trade-off seen in OA's multi-cut vs. single-cut variants.

### Comparison Summary

| Aspect | Outer Approximation | Generalized Benders Decomposition |
| --- | --- | --- |
| Master problem variables | $x, y, \eta$ | $y, \eta$ only |
| Cut source | Direct linearization of $f, g$ at $(x^k, y^k)$ | Lagrangian support function using duals $\lambda^k$ |
| Cut strength | Generally tighter | Generally weaker |
| Master problem type | MILP (if $f,g$ linearized) | MILP or MINLP, depending on Lagrangian's linearity in $y$ |
| Best suited for | Moderate-dimension $x$, need for fast convergence | High-dimensional or decomposable $x$ (e.g., stochastic scenarios) |

### Applications

- Two-stage and multi-stage stochastic programming with integer first-stage decisions
- Engineering design problems with high-dimensional continuous state variables and few discrete design choices
- Process synthesis and scheduling problems originally motivating both GBD and OA development

### Related Topics

- Outer approximation methods
- MINLP problem structure and convex vs. nonconvex classification
- Classical (linear) Benders decomposition for MILP
- Lagrangian duality and weak/strong duality in convex optimization
- Extended cutting plane method
- Stochastic programming and scenario decomposition