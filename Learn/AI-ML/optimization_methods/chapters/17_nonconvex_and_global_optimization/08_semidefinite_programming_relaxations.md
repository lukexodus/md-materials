## Semidefinite Programming Relaxations

### Definition and Role in Nonconvex Optimization

Semidefinite programming (SDP) relaxation is a technique for obtaining tractable, provably valid bounds on nonconvex optimization problems — particularly those involving quadratic objectives and/or quadratic constraints — by lifting the problem into a higher-dimensional space of symmetric matrices and relaxing a rank constraint. A standard semidefinite program has the form:

$$\min_{X \in \mathcal{S}^n} \; \langle C, X \rangle \quad \text{subject to} \quad \langle A_i, X \rangle = b_i,\; i = 1,\dots,m, \quad X \succeq 0$$

where $\mathcal{S}^n$ is the space of $n \times n$ symmetric matrices, $\langle C, X \rangle = \operatorname{tr}(CX)$, and $X \succeq 0$ denotes that $X$ is positive semidefinite. This is a convex program (the PSD cone is convex, and the constraints are linear), solvable in polynomial time to arbitrary accuracy using interior-point methods.

The relaxation idea arises because many nonconvex quadratic problems can be exactly rewritten using a rank-1 matrix variable $X = xx^T$, and then relaxed by dropping the (nonconvex) rank-1 constraint while retaining $X \succeq 0$, yielding a convex SDP whose optimal value bounds the original problem's optimal value.

**Key Points**

- The SDP relaxation is obtained via a **lifting** step ($x \mapsto X = xx^T$) followed by a **relaxation** step (dropping $\operatorname{rank}(X) = 1$).
- Because the feasible region of the relaxed SDP strictly contains the lifted feasible region of the original problem, the SDP relaxation's optimal value is always a valid bound (a lower bound for minimization, upper bound for maximization) on the true nonconvex optimum.
- The gap between the SDP relaxation value and the true optimal value is called the **relaxation gap**; when this gap is zero, the relaxation is said to be **tight** or **exact**.

### Lifting a Quadratically Constrained Quadratic Program (QCQP)

Consider a (generally nonconvex) QCQP:

$$\min_{x \in \mathbb{R}^n} \; x^T Q_0 x + 2 c_0^T x \quad \text{subject to} \quad x^T Q_i x + 2 c_i^T x + d_i \le 0,\; i = 1,\dots,m$$

Using the substitution $X = xx^T$ and noting that $x^T Q x = \operatorname{tr}(Q x x^T) = \operatorname{tr}(QX) = \langle Q, X \rangle$, each quadratic term becomes linear in $X$. Introducing the homogenizing variable via the block matrix

$$Y = \begin{pmatrix} 1 & x^T \\ x & X \end{pmatrix} \succeq 0, \quad Y_{11} = 1$$

the QCQP becomes exactly equivalent to an SDP over $Y$ with the added nonconvex constraint $\operatorname{rank}(Y) = 1$. Dropping this rank constraint yields the standard SDP relaxation.

**Key Points**

- The constraint $Y \succeq 0$ combined with $Y_{11} = 1$ ensures $Y$ is a valid "second-moment-like" matrix consistent with some $x$ only when rank-1; the relaxation permits $Y$ to represent, informally, a probability distribution over $x$ rather than a single point. [Inference] This probabilistic interpretation is most rigorously formalized for specific well-studied classes such as the Max-Cut/Boolean QCQP relaxation, where $Y$ corresponds exactly to a second-moment matrix of a randomized rounding distribution; for general QCQPs the "distributional" reading is a useful intuition rather than always a formally derived object.
- This construction, sometimes called the **Shor relaxation**, is one of the most widely used SDP relaxation schemes for nonconvex quadratic programs.

```mermaid
flowchart TD
    A[Nonconvex QCQP in x] --> B[Lift: define X = x x^T]
    B --> C[Rewrite quadratic terms as linear in X]
    C --> D[Add rank(Y) = 1 constraint on block matrix Y]
    D --> E[Relax: drop rank(Y) = 1, keep Y is positive semidefinite]
    E --> F[Solve convex SDP relaxation]
    F --> G{Optimal Y has rank 1?}
    G -->|Yes| H[Relaxation is tight: extract exact x from Y]
    G -->|No| I[Relaxation gap exists: use rounding or branch-and-bound]
```

### Example: SDP Relaxation of Max-Cut

The Max-Cut problem seeks a partition of a graph's vertices into two sets maximizing the total weight of edges crossing the partition. It can be written as a nonconvex quadratic program over $x \in \{-1, +1\}^n$:

$$\max_{x \in \{-1,1\}^n} \; \frac{1}{4} \sum_{(i,j) \in E} w_{ij} (1 - x_i x_j)$$

Since $x_i \in \{-1,1\}$ is equivalent to $x_i^2 = 1$, this is a QCQP. Lifting via $X = xx^T$ (so $X_{ii} = 1$ and $X_{ij} = x_i x_j$) gives the Goemans–Williamson SDP relaxation:

$$\max_{X \succeq 0} \; \frac{1}{4} \sum_{(i,j) \in E} w_{ij}(1 - X_{ij}) \quad \text{subject to} \quad X_{ii} = 1 \; \forall i$$

**Output**

Solving this SDP gives an upper bound on the Max-Cut value. The classical Goemans–Williamson result establishes that rounding the SDP solution via a random hyperplane (assigning $x_i = \operatorname{sign}(v_i^T r)$ for vectors $v_i$ obtained from a factorization $X = V^TV$ and a random Gaussian vector $r$) yields, in expectation, a cut of weight at least $\approx 0.878$ times the SDP relaxation value, giving a provable approximation guarantee for the original NP-hard problem. [Inference] The precise constant $0.87856\ldots$ arises from a specific integral involving the arccosine function connecting the angle between lifted vectors to rounding probability; this is a well-documented, specific numerical result from the original Goemans–Williamson analysis rather than a general property of all SDP relaxations.

### Tightness Conditions and Exactness

**Key Points**

- A sufficient condition commonly cited for SDP relaxation tightness in certain structured QCQPs (e.g., problems with a specific sign pattern or "hidden convexity," such as the S-procedure/S-lemma setting with a single constraint) is that strong duality holds between the QCQP and its SDP relaxation.
- The **S-lemma** (S-procedure) provides an exact (lossless) characterization for QCQPs with a single quadratic constraint, guaranteeing the SDP relaxation is tight under mild conditions (e.g., existence of a strictly feasible point). This is one of the few general classes where exactness is guaranteed rather than merely empirically observed.
- [Unverified] For QCQPs with two or more general quadratic constraints, the SDP relaxation is generally not guaranteed to be tight, and whether the gap is zero for a specific problem instance typically must be checked numerically (e.g., verifying whether the optimal $Y$ recovered is rank-1) rather than assumed from problem structure alone.
- When the SDP relaxation is not tight, common recovery strategies include randomized rounding (as in Max-Cut), eigenvalue-based rounding (using the dominant eigenvector of the optimal $X$), and embedding the SDP bound inside a branch-and-bound scheme as a lower-bounding subroutine, refining the relaxation on subregions of the branch-and-bound tree.

### Relationship to Other Relaxation Hierarchies

**Key Points**

- SDP relaxations are the base level of the **Lasserre/Sum-of-Squares (SOS) hierarchy**, a sequence of increasingly tight SDP relaxations for general polynomial optimization problems, parameterized by a relaxation order that increases the size (and tightness) of the semidefinite constraint as more moment/localizing conditions are imposed.
- Compared to linear programming (LP) relaxations of the same nonconvex problem, SDP relaxations are generally tighter (provide better bounds) because the PSD cone captures more of the underlying quadratic structure than linear inequalities alone, though at the cost of higher per-iteration computational expense for the resulting convex solver.
- Within the branch-and-bound framework for nonconvex global optimization discussed previously (using convex underestimators/concave overestimators such as $\alpha$BB or McCormick envelopes), SDP relaxations serve as an alternative, often tighter, bounding mechanism specifically suited to problems with quadratic structure.

**Conclusion**

Semidefinite programming relaxation is a lifting-based technique that converts nonconvex quadratic optimization problems into convex, polynomial-time-solvable semidefinite programs by relaxing a rank-1 constraint on a matrix variable. While the resulting bound is not always exact, in several important structured cases (the S-lemma setting, and via randomized rounding in combinatorial problems like Max-Cut) the relaxation provides either exact recovery or a provable approximation guarantee. This makes SDP relaxation one of the most theoretically well-developed and practically impactful tools in nonconvex and combinatorial optimization, and the foundational building block of the broader Sum-of-Squares hierarchy for polynomial optimization.

**Related Topics**

- Sum-of-Squares (SOS) and Lasserre moment hierarchies
- The S-lemma (S-procedure) for single-constraint QCQPs
- Goemans–Williamson randomized rounding
- Interior-point methods for semidefinite programs
- Rank-constrained optimization and low-rank recovery
- Robust optimization via SDP (S-lemma-based robust counterparts)
- Combinatorial optimization relaxations (Max-Cut, graph coloring, stable set)