## Generalized Reduced Gradient Method

### Overview and Historical Context

**Key Points**

The Generalized Reduced Gradient (GRG) method is one of the earliest and most widely deployed methods for nonlinear constrained optimization, predating much of the SQP and interior-point machinery developed in the preceding topics but sharing a conceptual root with the null space method from the Quadratic Programming topic: both work by partitioning variables and effectively eliminating a subset of them using the constraints, reducing the problem to one over a smaller set of free variables. GRG extends this idea from the linear-constraint QP setting to fully **nonlinear** constraints, using a first-order (gradient-based) reduced problem rather than a quadratic model. It remains in active practical use, notably as the algorithm underlying the "GRG Nonlinear" solving method in widely available spreadsheet optimization tools.

### Variable Partitioning: Basic and Nonbasic Variables

**Key Points**

Consider the equality-constrained problem (inequality constraints are converted to equalities via slack variables, as is standard practice in GRG):

$$\min_{x\in\mathbb{R}^n} \quad f(x) \quad \text{subject to} \quad c(x) = 0, \quad c:\mathbb{R}^n\to\mathbb{R}^m$$

GRG partitions the $n$ variables into two groups:

$$x = (x_B, x_N), \quad x_B \in \mathbb{R}^m \ \text{(basic/dependent variables)}, \quad x_N \in \mathbb{R}^{n-m} \ \text{(nonbasic/independent variables)}$$

chosen so that the $m\times m$ Jacobian submatrix $\partial c/\partial x_B$ (evaluated at the current point) is nonsingular. By the **implicit function theorem**, this nonsingularity guarantees that, at least locally, the constraint equations $c(x_B,x_N)=0$ can in principle be solved for $x_B$ as an implicit function of $x_N$: $x_B = x_B(x_N)$, even though this function is not generally available in closed form for nonlinear $c$ (in contrast to the linear-constraint QP null-space method, where the analogous relationship _is_ available in closed form via $Z$).

This is the central structural distinction from the linear null space method: GRG must _numerically_ enforce $c(x_B,x_N)=0$ at each trial point (typically via Newton's method on the basic variables, holding $x_N$ fixed), rather than satisfying it exactly and automatically via a fixed linear null-space basis.

### The Reduced Gradient

**Key Points**

Given the implicit relationship $x_B(x_N)$, the objective becomes, in principle, a function of $x_N$ alone: $F(x_N) = f(x_B(x_N), x_N)$. Differentiating via the chain rule (and using implicit differentiation on the constraint to express $\partial x_B/\partial x_N$) yields the **reduced gradient**:

$$\nabla F(x_N) = \nabla_{x_N}f - \left(\frac{\partial c}{\partial x_N}\right)^T\left(\frac{\partial c}{\partial x_B}\right)^{-T}\nabla_{x_B}f$$

This expression is structurally identical in form to the reduced-cost / reduced-gradient formulas familiar from the simplex method for linear programming (indeed, "reduced gradient" terminology and the basic/nonbasic partitioning language are directly inherited from that lineage), generalized here to nonlinear $f$ and $c$. The reduced gradient $\nabla F(x_N)$ measures the rate of change of the objective with respect to the nonbasic variables **after accounting for the compensating adjustment** that the basic variables must undergo (via the constraints) as $x_N$ changes — precisely analogous to the role of $Z^Tg$ in the null space QP method, but now recomputed at each iterate rather than fixed by a constant $Z$.

### Search Direction and Line Search

**Key Points**

Using the reduced gradient, a search direction in the nonbasic variables is chosen — most simply, the steepest-descent direction $d_N = -\nabla F(x_N)$, though quasi-Newton variants (analogous to BFGS applied to the reduced problem) are used in practical implementations for better convergence. A line search is then performed along $d_N$:

$$x_N(\alpha) = x_N + \alpha, d_N$$

For each trial $\alpha$, the corresponding $x_B(\alpha)$ must be **recomputed** by solving $c(x_B,x_N(\alpha))=0$ for $x_B$ — typically via Newton's method initialized from the previous $x_B$ (a "constraint restoration" step nested inside the line search). This is the key computational cost distinguishing GRG from linear-constraint methods: **every** trial point along the line search requires its own nonlinear system solve to restore feasibility, not just the final accepted step.

### GRG Iteration Structure

```mermaid
flowchart TD
    A[Select basic/nonbasic partition x_B, x_N] --> B[Compute reduced gradient at current feasible point]
    B --> C[Determine search direction d_N in nonbasic variables]
    C --> D[Choose trial step alpha, update x_N]
    D --> E[Solve c(x_B, x_N)=0 for x_B via Newton's method]
    E --> F{Constraint restoration converged?}
    F -->|No| G[Adjust alpha or repartition basic variables]
    G --> D
    F -->|Yes| H{Sufficient decrease in objective achieved?}
    H -->|No| G
    H -->|Yes| I[Accept step, update x_B, x_N]
    I --> J{Reduced gradient norm below tolerance?}
    J -->|No| B
    J -->|Yes| K[Return solution x*]
```

### Handling Variable Bounds and Inequality Constraints

**Key Points**

GRG naturally extends to problems with explicit bound constraints on variables ($l \leq x \leq u$) using logic reminiscent of active-set methods: a nonbasic variable at its bound is held fixed (its component of the search direction set to zero) unless the reduced gradient indicates that moving away from the bound would improve the objective, in which case it is released and allowed to move — directly paralleling active-set logic from QP, but applied here to the reduced (nonbasic) variable space rather than the full variable space.

General inequality constraints $c_j(x)\geq0$ are converted to equalities via slack variables $s_j$ (with $s_j\geq0$ treated as a bound), exactly as in the interior-point and SQP topics, after which the same basic/nonbasic machinery applies uniformly to the augmented equality-constrained system.

### Choosing and Updating the Basic Variable Set

**Key Points**

A practical subtlety not present in the fixed-basis linear null-space method is that the choice of which variables are "basic" versus "nonbasic" may need to **change during the course of the algorithm** — if the Jacobian submatrix $\partial c/\partial x_B$ for the current basic set becomes ill-conditioned or singular (e.g., because the current basic variables have reached values where their constraint sensitivity vanishes), a different subset of variables must be selected as the new basis. This repartitioning decision is analogous in spirit (though not mechanically identical) to a basis change in the simplex method, and its careful, numerically-aware handling is a significant part of what distinguishes robust GRG implementations from naive ones. [Inference] The specific pivoting/repartitioning heuristics used are implementation-specific and not fully standardized across GRG solver codes, though the underlying requirement — maintaining a well-conditioned, invertible basic Jacobian submatrix — is universal to the method.

### Worked Example

**Example**

Minimize $f(x_1,x_2) = (x_1-2)^2+(x_2-2)^2$ subject to $c(x) = x_1x_2 - 1 = 0$ (a nonlinear equality constraint), starting from the feasible point $x^{(0)}=(1,1)$ (since $1\cdot1-1=0$).

**Partition**: choose $x_B = x_1$, $x_N=x_2$ (requiring $\partial c/\partial x_1 = x_2 \neq 0$, satisfied at $x_2=1$).

**Reduced gradient computation**: $\nabla_{x_1}f = 2(x_1-2) = -2$, $\nabla_{x_2}f = 2(x_2-2)=-2$. $\partial c/\partial x_2 = x_1 = 1$, $\partial c/\partial x_1 = x_2=1$.

$$\nabla F(x_2) = \nabla_{x_2}f - \left(\frac{\partial c}{\partial x_2}\right)\left(\frac{\partial c}{\partial x_1}\right)^{-1}\nabla_{x_1}f = -2 - (1)(1)^{-1}(-2) = -2+2 = 0$$

**Output**

The reduced gradient is zero at $x^{(0)}=(1,1)$, indicating this point already satisfies the first-order optimality condition for the reduced problem — consistent with $(1,1)$ in fact being the true constrained minimizer of this problem (by symmetry of $f$ and $c$ about $x_1=x_2$, and since $(1,1)$ is the point on the curve $x_1x_2=1$ closest to $(2,2)$ in this symmetric configuration). No further line search iteration is required from this particular starting point, illustrating the reduced-gradient stationarity check but not exercising the constraint-restoration machinery that would be needed from a less fortunately chosen starting point.

### Comparison: GRG vs. Null Space QP Method vs. SQP

|Aspect|Null Space Method (QP)|GRG|SQP|
|---|---|---|---|
|Constraint type|Linear (fixed $A$)|Nonlinear, general|Nonlinear, linearized per iteration|
|Basis/null-space computation|Once, via QR or partitioning|Repeated implicit solves per trial point|Re-linearized Jacobian per outer iteration|
|Feasibility maintenance|Automatic (via $Z$)|Requires explicit Newton restoration at every trial point|Only approximately maintained via linearization; true feasibility not required mid-iteration|
|Curvature model|Explicit quadratic ($G$)|Typically first-order (steepest descent) or quasi-Newton on reduced problem|Explicit quadratic ($B_k$) on full Lagrangian|
|Convergence rate|Exact for QP (one step)|Typically linear to superlinear (quasi-Newton variants)|Superlinear to quadratic near solution|
|Historical/practical niche|QP subroutine within other methods|Long-standing spreadsheet/engineering solver standard|Modern general-purpose NLP standard|

### Convergence Properties

**Key Points**

- With steepest-descent search directions in the reduced space, GRG inherits the (typically linear) convergence rate characteristic of steepest descent applied to the reduced problem, which can be slow on ill-conditioned reduced problems — a similar concern to plain steepest descent in unconstrained optimization.
- Quasi-Newton variants applied to the reduced gradient (approximating the reduced Hessian, conceptually parallel to $Z^TGZ$ in the null-space QP method, but built up iteratively rather than known in closed form) typically achieve superlinear local convergence, comparable to quasi-Newton SQP.
- [Inference] GRG's global convergence properties are generally considered less thoroughly characterized in the modern theoretical literature than SQP or interior-point methods' filter/merit-function-based guarantees, in part because of GRG's earlier historical development predating much of that later convergence theory; this does not mean GRG lacks convergence guarantees, but that the theoretical treatment has historically been less unified than for the more recently systematized SQP and interior-point frameworks.

### Practical Considerations and Modern Standing

**Key Points**

- **Cost per iteration**: the repeated Newton-based constraint restoration at every trial line-search point makes GRG's per-iteration cost sensitive to how expensive constraint evaluation and the restoration Newton solve are — for problems with cheap, well-behaved constraints this is a minor overhead, but it can dominate cost for expensive or ill-conditioned constraint systems.
- **Robustness to poor starting points**: because GRG requires a **feasible** starting point (or a Phase I-style procedure to obtain one) and maintains feasibility (approximately) throughout via restoration, its behavior from infeasible or poorly chosen starting points depends heavily on the reliability of that restoration Newton solve, which is not guaranteed to converge from arbitrary starting configurations for highly nonlinear constraints.
- **Continued relevance**: [Inference] despite the development of more theoretically unified modern frameworks (SQP, interior-point), GRG remains widely used in practice — particularly embedded within general-purpose optimization tools and engineering design software — due to its conceptual simplicity, long implementation track record, and adequate performance on many moderately sized nonlinear problems; it is less commonly the method of choice for very large-scale or highly degenerate problems where modern SQP or interior-point solvers' more sophisticated globalization and conditioning-management machinery tends to be preferred.

### Conclusion

The Generalized Reduced Gradient method extends the variable-elimination philosophy of the linear-constraint null space method to fully nonlinear constraints, partitioning variables into basic and nonbasic groups and using the implicit function theorem to define a reduced objective over the nonbasic variables alone. Because the basic-variable relationship cannot generally be written in closed form for nonlinear constraints, GRG must repeatedly solve a nonlinear system (constraint restoration via Newton's method) at every trial point along its line search, a structural cost not present in the fixed-basis linear case. Despite predating much of the systematic convergence theory developed for SQP and interior-point methods, GRG remains a practically significant and widely implemented algorithm, particularly well known as the engine behind common spreadsheet-based nonlinear solvers, and it illustrates how the core reduced-space idea introduced for quadratic programming generalizes, with meaningful added complexity, to the fully nonlinear setting.

**Related Topics**

- Implicit function theorem foundations for constraint reduction
- Quasi-Newton updates applied to the reduced Hessian
- Active-set logic for bound-constrained nonbasic variables
- Basis repartitioning and pivoting strategies in GRG
- Comparison of GRG, SQP, and interior-point methods on benchmark problems
- Phase I feasibility procedures for nonlinear constraint restoration
- Spreadsheet and engineering-tool implementations of GRG (e.g., GRG2-style solvers)
- Convergence theory gaps between classical and modern nonlinear programming methods

