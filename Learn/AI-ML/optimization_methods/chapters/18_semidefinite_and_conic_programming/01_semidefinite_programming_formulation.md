## Semidefinite Programming Formulation

### Standard Form

A semidefinite program (SDP) is a convex optimization problem over the cone of symmetric positive semidefinite matrices. The **primal standard form** is:

$$\min_{X \in \mathcal{S}^n} \; \langle C, X \rangle \quad \text{subject to} \quad \langle A_i, X \rangle = b_i, \; i = 1, \dots, m, \quad X \succeq 0$$

where $\mathcal{S}^n$ denotes the space of $n \times n$ real symmetric matrices, $C, A_1, \dots, A_m \in \mathcal{S}^n$ are given symmetric data matrices, $b \in \mathbb{R}^m$, $\langle C, X \rangle = \operatorname{tr}(CX) = \sum_{i,j} C_{ij} X_{ij}$ is the trace inner product, and $X \succeq 0$ denotes that $X$ is positive semidefinite (equivalently, all eigenvalues of $X$ are nonnegative).

**Key Points**

- The decision variable is an entire symmetric matrix $X$, not a vector, distinguishing SDP from linear programming (LP) even though both share the same linear-objective, linear-constraint structure.
- The constraint set $\{X : \langle A_i, X\rangle = b_i \,\forall i\} \cap \{X \succeq 0\}$ is convex, because it is the intersection of an affine subspace with the PSD cone, and the PSD cone is convex (a nonnegative combination of PSD matrices is PSD).
- LP is a special case of SDP restricted to diagonal matrices: constraining $X$ to be diagonal reduces $X \succeq 0$ to elementwise nonnegativity of the diagonal entries, recovering standard LP.

### Dual Form

Associated with the primal SDP is a dual semidefinite program:

$$\max_{y \in \mathbb{R}^m} \; b^T y \quad \text{subject to} \quad \sum_{i=1}^m y_i A_i \preceq C$$

equivalently written using a slack matrix $S = C - \sum_i y_i A_i \succeq 0$ as:

$$\max_{y \in \mathbb{R}^m, \, S \in \mathcal{S}^n} \; b^T y \quad \text{subject to} \quad \sum_{i=1}^m y_i A_i + S = C, \quad S \succeq 0$$

**Key Points**

- Weak duality always holds: for any primal-feasible $X$ and dual-feasible $y$, $b^T y \le \langle C, X \rangle$, giving a certificate that bounds the optimal value from both sides.
- Unlike linear programming, **strong duality (zero duality gap) is not automatic for SDP**; it requires a constraint qualification, most commonly **Slater's condition** — existence of a strictly feasible point (a point with $X \succ 0$ for the primal, or $S \succ 0$ for the dual) — to guarantee zero duality gap and attainment of both optima.
- [Unverified] The specific behavior when Slater's condition fails (e.g., whether a duality gap actually appears, or merely cannot be ruled out) is instance-dependent and should be checked for the specific problem rather than assumed; pathological SDPs with a nonzero duality gap despite feasibility are a well-documented phenomenon in the literature, but do not occur in most well-posed applied formulations.

```mermaid
flowchart TD
    A[Primal SDP: minimize trace(C X)] --> B{Slater condition holds? Strictly feasible X exists}
    B -->|Yes| C[Strong duality holds: primal optimal = dual optimal]
    B -->|No/Unknown| D[Only weak duality guaranteed: dual optimal less than or equal primal optimal]
    C --> E[Solve via primal-dual interior-point method]
    D --> E
    E --> F[Recover optimal X and y, S]
```

### Reformulating Constraints as Linear Matrix Inequalities (LMIs)

A central practical skill in SDP formulation is recognizing when a constraint can be written as a **Linear Matrix Inequality (LMI)** — a constraint of the form $F_0 + \sum_i x_i F_i \succeq 0$, affine in the decision variables and constrained to the PSD cone.

**Key Points**

- **Second-order cone constraints** ($\|Ax + b\| \le c^Tx + d$) can be embedded into SDP form using the Schur complement, since $\|z\| \le t$ (for $t \ge 0$) is equivalent to the LMI $\begin{pmatrix} tI & z \\ z^T & t \end{pmatrix} \succeq 0$; this is why SDP is sometimes described as strictly more general than second-order cone programming (SOCP), which is itself more general than LP.
- **Eigenvalue constraints** (e.g., bounding the largest eigenvalue of a matrix $M(x)$ depending affinely on $x$) are naturally LMIs: $\lambda_{\max}(M(x)) \le t \iff tI - M(x) \succeq 0$.
- The **Schur complement** is the single most widely used tool for converting a nonlinear (often quadratic or rational) constraint into an equivalent LMI: for a block matrix $\begin{pmatrix} A & B \\ B^T & D \end{pmatrix}$ with $D \succ 0$, positive semidefiniteness of the whole block is equivalent to $D \succ 0$ and $A - BD^{-1}B^T \succeq 0$, which lets a constraint like $A \succeq BD^{-1}B^T$ (nonlinear via the inverse) be written as a single linear matrix inequality.

### Example: SDP Formulation via Schur Complement

Suppose a design problem requires enforcing $Q - \frac{1}{r} pp^T \succeq 0$ for a symmetric matrix $Q$, vector $p$, and scalar $r > 0$, where $p$ and $r$ are also decision variables (making the constraint nonlinear/nonconvex as literally written, due to the $\frac{1}{r}pp^T$ term). Applying the Schur complement in reverse converts this into the equivalent LMI:

$$\begin{pmatrix} Q & p \\ p^T & r \end{pmatrix} \succeq 0$$

**Output**

This block matrix constraint is now affine in $Q$, $p$, and $r$ jointly, and constrained to the PSD cone — precisely the LMI form required for direct input into a standard-form SDP solver, whereas the original expression involving $r^{-1}$ was not directly representable as an LP or a simple convex constraint.

### Solution Methods

**Key Points**

- **Primal-dual interior-point methods** are the standard general-purpose approach for solving SDPs to high accuracy, extending the barrier-function machinery of LP interior-point methods to the PSD cone via a log-determinant barrier ($-\log \det X$), and typically converge in a number of iterations that grows slowly (polynomially, and in practice often nearly independent of problem size within a wide range) as accuracy requirements tighten.
- Interior-point methods for SDP scale considerably worse in matrix dimension $n$ than LP methods scale in vector dimension, since each iteration generally requires forming and factorizing a dense system related to the $n \times n$ matrix structure; this makes large-scale SDPs (large $n$) substantially more computationally demanding than comparably-sized LPs.
- For large-scale SDPs where interior-point methods become impractical, **first-order methods** (e.g., alternating direction method of multipliers (ADMM)-based solvers, or the Burer–Monteiro low-rank factorization approach that reparametrizes $X = RR^T$ for a thin factor $R$ to reduce the effective number of variables) are commonly used, trading some accuracy/certified optimality for substantially better scalability.
- [Inference] The Burer–Monteiro approach reintroduces nonconvexity into the SDP subproblem (since the factorized problem in $R$ is not convex), so any resulting local solution generally requires a separate certificate (e.g., checking a dual/KKT-based optimality condition on the recovered $X = RR^T$) to confirm global optimality of the underlying convex SDP; this caveat is specific to the low-rank factorization technique rather than a property of SDP formulations generally.

### Relationship to Global and Nonconvex Optimization

**Key Points**

- The SDP formulation machinery described here (standard/dual form, LMIs, Schur complements) is the same underlying toolset used to construct the SDP relaxations of nonconvex QCQPs discussed previously; the relaxation itself is simply an SDP formulated by lifting a quadratic problem, then solved using exactly these general-purpose SDP methods.
- Because SDP formulation is fundamentally about **recognizing and exposing PSD-cone structure** in a problem, the same reformulation skill set (Schur complements, LMI recognition) underlies robust optimization (robust counterparts of uncertain linear/quadratic constraints), control theory (Lyapunov stability conditions expressed as LMIs), and the base level of the Sum-of-Squares/Lasserre polynomial optimization hierarchy.

**Conclusion**

The semidefinite programming formulation generalizes linear programming by replacing the nonnegative orthant with the cone of positive semidefinite matrices, yielding a convex problem class expressive enough to capture second-order cone constraints, eigenvalue bounds, and — crucially for nonconvex optimization — the lifted relaxations of quadratic programs. Mastery of SDP formulation centers on recognizing when a constraint admits an LMI representation, most often via the Schur complement, and on understanding the duality theory (particularly the role of Slater's condition) that determines whether the resulting convex program can be solved with a certified, gap-free optimality guarantee.

**Related Topics**

- Interior-point methods: barrier functions and complexity
- Schur complement techniques in convex reformulation
- Second-order cone programming (SOCP) as an SDP special case
- Lyapunov stability analysis via LMIs
- Burer–Monteiro low-rank SDP factorization
- Robust optimization and SDP-based robust counterparts
- Duality theory and constraint qualifications in conic programming