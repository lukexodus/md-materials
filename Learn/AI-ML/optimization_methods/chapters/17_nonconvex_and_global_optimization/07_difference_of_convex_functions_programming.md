## Difference of Convex Functions Programming

### Definition and Problem Structure

Difference of Convex functions (DC) programming addresses optimization problems where the objective and/or constraint functions can be expressed as the difference of two convex functions. A DC program has the general form:

$$\min_{x \in \mathbb{R}^n} \; g(x) - h(x)$$

subject to $x \in D$, where $g(x)$ and $h(x)$ are both convex (and typically finite-valued) functions on $D$, and $D$ itself is a convex set. The function $f(x) = g(x) - h(x)$ is called a **DC function**, and the pair $(g, h)$ is a **DC decomposition** of $f$. A remarkable property underlying this framework is that a very broad class of functions — including all twice continuously differentiable functions on a compact convex set, and more generally, functions merely continuous on such a set (by density arguments) — admit a DC decomposition. This makes DC programming a surprisingly general framework for nonconvex optimization, despite the objective itself generally being nonconvex.

**Key Points**

- $f = g - h$ is generally nonconvex even though both $g$ and $h$ are convex; the nonconvexity arises entirely from the subtraction.
- DC decompositions are **not unique**: given one decomposition $(g, h)$, another valid decomposition is $(g + p, h + p)$ for any convex function $p$, since $(g+p) - (h+p) = g - h$.
- The tightness of a DC decomposition (how "well-conditioned" $g$ and $h$ are, e.g., in terms of curvature) directly affects the practical performance of DC algorithms, even though it does not affect the theoretical DC representability of $f$.

### DC Decomposition Techniques

**Key Points**

- **Quadratic augmentation**: for any $f$ with bounded Hessian eigenvalues (i.e., $\rho I \preceq \nabla^2 f(x) \preceq LI$ for all $x$ in the domain), a valid decomposition is $g(x) = f(x) + \frac{\rho}{2}\|x\|^2$ and $h(x) = \frac{\rho}{2}\|x\|^2$, since adding a sufficiently convex quadratic to $f$ makes the result convex.
- **Separable decomposition**: for a separable function $f(x) = \sum_i f_i(x_i)$, each univariate term $f_i$ can be decomposed independently, since the DC property is preserved under sums of DC functions.
- **Explicit known decompositions**: many common nonconvex functions used in machine learning and signal processing (e.g., certain sparsity-inducing penalties, ranking losses, and robust loss functions) have DC decompositions documented directly in the optimization literature rather than derived from a generic recipe.
- [Inference] In practice, the choice of decomposition is often guided by which choice yields a $h(x)$ that is easy to handle in the subproblem (e.g., piecewise linear or having an easily computable subgradient), rather than by any single canonical procedure, since the decomposition is not unique.

### The DC Algorithm (DCA)

The DC Algorithm (DCA) is the standard iterative method for solving DC programs. It exploits the structure $f = g - h$ by linearizing the concave part $-h(x)$ at each iterate and solving the resulting convex subproblem. Given a current iterate $x^k$, DCA proceeds as follows:

1. Compute a subgradient $y^k \in \partial h(x^k)$ of the convex function $h$ at $x^k$.
2. Solve the convex subproblem:

$$x^{k+1} \in \arg\min_{x \in D} \; g(x) - \left[ h(x^k) + \langle y^k, x - x^k \rangle \right]$$

Since $h(x^k) + \langle y^k, x - x^k \rangle$ is an affine (and hence convex) minorant of $h$, the subproblem $g(x) - \langle y^k, x \rangle$ (dropping the constant terms) is a convex optimization problem, solvable using standard convex methods.

**Key Points**

- DCA is a **descent method**: the sequence $f(x^k)$ is monotonically non-increasing, because the linearization of $-h$ produces an upper bound on $f$ that is tight at $x^k$ and minimized (or decreased) at each step.
- DCA typically converges to a **critical point** of the DC program (satisfying $\partial g(x^*) \cap \partial h(x^*) \ne \emptyset$), not necessarily the global minimum, reflecting the nonconvex nature of the overall problem.
- [Unverified] Whether a given critical point found by DCA coincides with a local minimum, or merely a stationary point of the DC structure, generally depends on the specific decomposition and problem instance, and is not guaranteed a priori without further problem-specific analysis.
- Multiple restarts from different initial points are commonly used in practice to improve the chances of finding a high-quality local solution, since DCA itself provides no global optimality guarantee.

```mermaid
flowchart TD
    A[Start with x_k] --> B[Compute subgradient y_k in partial h at x_k]
    B --> C[Form affine minorant of h at x_k using y_k]
    C --> D[Solve convex subproblem: minimize g(x) minus affine minorant]
    D --> E[Obtain x_k+1]
    E --> F{Convergence criterion met?}
    F -->|No| G[Set k = k+1]
    G --> B
    F -->|Yes| H[Return x_k+1 as critical point]
```

### Geometric Interpretation

At each DCA iteration, the concave function $-h(x)$ is replaced by its tangent hyperplane (a global overestimator of a concave function, since a concave function always lies below its tangent). This means the DCA subproblem minimizes a convex **majorant** of the original nonconvex objective $f(x) = g(x) - h(x)$, tight at the current point $x^k$. This places DCA within the broader family of majorization-minimization (MM) algorithms.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 420" font-family="sans-serif">
<text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold">DCA majorization at iterate x_k (svg_diagram)</text>
<line x1="60" y1="360" x2="580" y2="360" stroke="black" stroke-width="2" />
<line x1="60" y1="360" x2="60" y2="60" stroke="black" stroke-width="2" />
<text x="580" y="380" font-size="13">x</text>
<text x="35" y="65" font-size="13">f(x) = g(x) - h(x)</text>

<path d="M 80 300 Q 180 90 280 220 T 420 150 Q 500 250 560 200" stroke="`#1f77b4`" stroke-width="3" fill="none" />

<text x="440" y="120" fill="`#1f77b4`" font-size="13" font-weight="bold">f(x) (nonconvex)</text>

<path d="M 100 340 Q 280 60 460 320" stroke="#d62728" stroke-width="3" fill="none" />
<text x="330" y="90" fill="#d62728" font-size="13" font-weight="bold">majorant: g(x) - [affine minorant of h]</text>
<circle cx="280" cy="220" r="5" fill="black" />
<text x="255" y="245" font-size="12">x_k</text>
<circle cx="380" cy="180" r="5" fill="#2ca02c" />
<text x="370" y="200" font-size="12" fill="#2ca02c">x_k+1</text>
<line x1="280" y1="220" x2="280" y2="360" stroke="#888" stroke-width="1" stroke-dasharray="4 3" />
<line x1="380" y1="180" x2="380" y2="360" stroke="#888" stroke-width="1" stroke-dasharray="4 3" />
</svg>

**Example**

Consider the nonconvex function $f(x) = |x| - x^2$ on $D = [-2, 2]$, which is a DC function with $g(x) = |x|$ (convex) and $h(x) = x^2$ (convex). At $x^k = 1$, a subgradient of $h(x) = x^2$ is $y^k = 2x^k = 2$. The DCA subproblem becomes:

$$\min_{x \in [-2,2]} \; |x| - \left[1 + 2(x - 1)\right] = \min_{x \in [-2,2]} \; |x| - 2x + 1$$

This is a convex piecewise-linear minimization, solvable directly: for $x \ge 0$, the objective is $-x + 1$, decreasing in $x$, so the minimizer over $[0,2]$ is at $x = 2$, giving value $-1$; for $x < 0$, the objective is $-3x + 1$, decreasing as $x$ decreases, so the minimum on $[-2, 0)$ approaches $x=-2$ giving value $7. Comparing candidates, $x^{k+1} = 2
 is the subproblem minimizer.

### Relationship to Other Nonconvex Frameworks

**Key Points**

- DC programming subsumes many nonconvex problem classes as special cases, including concave minimization over polyhedra, certain quadratic programs (through eigenvalue-based DC decompositions of indefinite quadratic forms), and $\ell_0$/sparsity-penalized problems approximated via DC surrogates (e.g., the DC approximation of the $\ell_0$ pseudo-norm using \ell_1 - $ (capped-
  \ell_1$)-type constructions).
- DCA is closely related to **Convex-Concave Procedure (CCCP)**, which is essentially the same algorithmic idea applied specifically in a machine-learning context; the two are generally regarded as equivalent or near-equivalent instances of the majorization-minimization principle applied to DC-structured objectives.
- Compared to branch-and-bound global optimization methods (which provide certified global bounds via underestimation/overestimation, as in the alpha-BB and McCormick frameworks), DCA is a **local** method: it is typically far more computationally efficient per iteration but does not certify global optimality.

**Conclusion**

Difference of Convex functions programming provides a structural decomposition — $f = g - h$ — that turns an otherwise opaque nonconvex problem into a sequence of tractable convex subproblems via linearization of the concave part. Its generality (nearly any sufficiently smooth or well-behaved function admits a DC decomposition) combined with the practical efficiency of DCA/CCCP-style algorithms makes it one of the most widely used frameworks for structured nonconvex optimization, particularly when a certified global bound is not required and a good local solution obtained efficiently is the practical goal.

**Related Topics**

- Convex-Concave Procedure (CCCP) in machine learning
- Majorization-Minimization (MM) algorithms
- DC decomposition of quadratic and indefinite forms
- Global DC optimization (Branch-and-Bound with DC relaxations)
- Sparse optimization via DC approximations of $\ell_0$
- Subgradient calculus for nonsmooth convex functions
- Convergence analysis of nonconvex descent methods