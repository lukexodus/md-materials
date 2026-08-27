## Gomory Cuts

### Overview and Historical Context

Gomory cuts, introduced by Ralph Gomory in the late 1950s, were the first general-purpose cutting plane method proven to solve pure integer linear programs to optimality in a finite number of steps. Unlike structure-specific cuts (cover inequalities, clique inequalities), Gomory cuts are derived purely algebraically from the simplex tableau, requiring no special recognition of problem structure such as knapsack or graph relationships. This generality made them historically significant as the first constructive proof that integer programming could, in principle, be solved by a finite sequence of linear programming relaxations.

**Key Points**

- Gomory cuts apply to any pure integer linear program expressed in standard form, without requiring any domain-specific structure to be identified in advance.
- The original Gomory cutting plane algorithm (using only these cuts, with no branching) was of primarily theoretical importance for decades, due to slow practical convergence and numerical instability, though refined variants are now used productively alongside branching in modern solvers.
- Gomory's finite-convergence proof was a landmark result in the theory of integer programming, establishing that a purely algebraic, mechanically generated sequence of cuts suffices for exact solution.

### Derivation from the Simplex Tableau

Consider a linear program in standard equality form with basic feasible solution given by the optimal simplex tableau. For a basic variable $x_i$ that takes a fractional value, its row in the tableau can be written as:

$$x_i + \sum_{j \in N} a_{ij} x_j = b_i$$

where $N$ denotes the set of nonbasic variables (all currently at value zero), and $b_i$ is fractional (i.e., $x_i$ is not integer-valued in the current relaxation solution).

**Step 1 — Split into integer and fractional parts.** Write each coefficient and the right-hand side as the sum of its integer floor and a fractional remainder:

$$a_{ij} = \lfloor a_{ij} \rfloor + f_{ij}, \qquad b_i = \lfloor b_i \rfloor + f_i$$

where $f_{ij} \in [0,1)$ and $f_i \in (0,1)$ (strictly positive since $b_i$ is fractional by assumption).

**Step 2 — Rearrange the tableau row.** Substituting and separating integer from fractional contributions:

$$x_i + \sum_j \lfloor a_{ij}\rfloor x_j - \lfloor b_i \rfloor = f_i - \sum_j f_{ij}x_j$$

Since the left-hand side is an integer for any integer-feasible $x$ (as $x_i$, the $\lfloor a_{ij}\rfloor$, $x_j$, and $\lfloor b_i\rfloor$ are all integers), the right-hand side must also be an integer for such $x$. Because $f_{ij} \ge 0$ and $x_j \ge 0$ for nonbasic variables, the right-hand side $f_i - \sum_j f_{ij}x_j$ is strictly less than $f_i < 1$, and since it must be an integer, it must therefore be less than or equal to $0$.

**Step 3 — State the cut.** This yields the Gomory fractional cut:

$$\sum_{j \in N} f_{ij}x_j \ge f_i$$

**Key Points**

- The cut is derived purely from the numerical entries of a single row of the optimal simplex tableau, requiring no additional problem-specific reasoning.
- The current fractional relaxation solution violates this cut immediately: since all nonbasic variables $x_j$ equal zero at the current vertex, the left-hand side equals $0, which is strictly less than $f_i > 0
  , confirming the cut excludes the current solution.
- Every integer feasible point satisfies the cut, by the integrality argument in Step 2, so adding it to the LP relaxation never removes a valid integer solution.

### Geometric Interpretation

Each Gomory cut corresponds to a hyperplane that slices off a portion of the current LP relaxation's feasible polyhedron containing the fractional vertex, without touching any integer lattice point.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Gomory Cut Removing a Fractional Vertex (svg_diagram)</text>
<polygon points="60,250 350,240 330,90 130,60" fill="#a8d0e6" fill-opacity="0.4" stroke="#2a6f97" stroke-width="1.5" />
<text x="290" y="105" font-size="11" fill="#2a6f97">LP feasible region</text>
<circle cx="330" cy="90" r="4" fill="#bc4b17" />
<text x="300" y="80" font-size="10" fill="#bc4b17">fractional vertex</text>
<line x1="270" y1="60" x2="360" y2="170" stroke="#bc4b17" stroke-width="2.5" stroke-dasharray="5,3" />
<text x="340" y="140" font-size="10" fill="#bc4b17">Gomory cut</text>
<circle cx="130" cy="220" r="3" fill="#1a1a1a" />
<circle cx="280" cy="210" r="3" fill="#1a1a1a" />
<circle cx="160" cy="110" r="3" fill="#1a1a1a" />
<circle cx="200" cy="165" r="3" fill="#1a1a1a" />
<text x="150" y="250" font-size="10" fill="#1a1a1a">integer lattice points remain feasible</text>
</svg>

**Key Points**

- The cut is tangent, in a sense, to the fractional vertex: it passes as close as possible to that vertex while remaining valid, maximizing (for that particular tableau row) how much of the infeasible region near the vertex is removed.
- A single Gomory cut typically removes only a small sliver of the polyhedron near one fractional vertex, which is part of why many rounds of cuts (or a combination with branching) are usually needed to reach the integer hull.
- Different fractional basic variables in the same tableau yield different Gomory cuts; a solver can generate multiple cuts from a single tableau by applying the derivation to each fractional row.

### Gomory Mixed-Integer (GMI) Cuts

The original Gomory cut derivation assumes all variables are integer-restricted. The **Gomory mixed-integer cut** extends the technique to mixed-integer programs, where some nonbasic variables $x_j$ are continuous rather than integer.

For a tableau row with fractional basic variable value $f_i$, the GMI cut treats integer and continuous nonbasic variables differently:

$$\sum_{j \in N_I,\, f_{ij} \le f_i} f_{ij}x_j + \frac{f_i}{1-f_i}\sum_{j\in N_I,\, f_{ij}>f_i}(1-f_{ij})x_j + \sum_{j \in N_C^+} a_{ij}x_j - \frac{f_i}{1-f_i}\sum_{j\in N_C^-} a_{ij}x_j \ge f_i$$

where $N_I$ denotes integer nonbasic variables, and $N_C^+$, $N_C^-$ denote continuous nonbasic variables with positive and negative tableau coefficients respectively.

**Key Points**

- GMI cuts reduce to the standard Gomory fractional cut when all variables are integer, making the pure-integer cut a special case of the more general mixed-integer form.
- GMI cuts are the form actually implemented in essentially all modern MILP solvers, since almost all practical instances are mixed-integer rather than purely integer.
- Despite the more complex-looking formula, GMI cuts are separated with essentially the same computational effort as pure Gomory cuts — directly from the simplex tableau, with no additional combinatorial search required.

### Finite Convergence Property

**Key Points**

- Gomory proved that, for pure integer linear programs, repeatedly re-solving the LP relaxation and adding a Gomory cut derived from a fractional basic variable (using a specific, careful rule for which row to cut from) converges to an integer optimal solution in a finite number of iterations.
- This finite convergence guarantee does not translate into fast practical convergence: the number of cuts needed in the worst case can be very large, and the specific row-selection rule required for the finiteness proof is not necessarily the most numerically effective choice in practice. [Inference] The gap between Gomory's theoretical finite-convergence guarantee and practically fast convergence is well documented; the exact magnitude of that gap is instance-dependent.
- Because of slow and sometimes numerically unstable practical convergence when used in isolation, pure Gomory cutting plane algorithms are rarely used alone in modern practice; instead, GMI cuts are generated at nodes of a branch-and-cut tree, combined with branching whenever cuts alone fail to close the gap quickly enough.

### Numerical Stability Considerations

**Key Points**

- Gomory cuts derived from simplex tableau entries can suffer from numerical sensitivity, since tableau coefficients close to (but not exactly at) an integer value can produce cuts with very small or very large coefficients, potentially causing ill-conditioning in subsequent LP solves.
- Modern implementations apply safeguards such as coefficient rounding thresholds, cut strengthening, and selective application (only generating cuts from rows with sufficiently large fractionality $f_i$) to mitigate these numerical issues. [Inference] The specific safeguard thresholds and heuristics used are implementation details that vary across solver software and versions.
- Because of these practical considerations, GMI cuts in production solvers are typically generated only in a limited number of rounds at the root node or select tree nodes, rather than being applied exhaustively at every node of the search tree.

### Worked Example

Consider the integer program: maximize $x_1 + x_2$ subject to

$$3x_1 + 2x_2 \le 12, \qquad x_1 + 4x_2 \le 10, \qquad x_1, x_2 \ge 0, \; \text{integer}$$

**LP relaxation solution**: Solving the LP relaxation gives an optimal fractional vertex at $x_1 = 2.8$, $x_2 = 1.8$ (the intersection of both constraints, treated as equalities), with objective value $4.6$.

**Deriving a cut from the $x_1$ row**: Converting to standard form with slack variables $s_1, s_2 \ge 0$ and examining the tableau row for basic variable $x_1$ (after pivoting to the optimal basis), suppose the row reads approximately:

$$x_1 + 0.4s_1 - 0.2s_2 = 2.8$$

Splitting into integer and fractional parts: $\lfloor 0.4\rfloor=0$ so $f_{1,s_1}=0.4$; $-0.2 = -1 + 0.8$ so $\lfloor -0.2\rfloor=-1$ and $f_{1,s_2}=0.8$; and $\lfloor 2.8\rfloor = 2$ so $f_1 = 0.8$.

**Resulting Gomory cut**: $0.4,s_1 + 0.8,s_2 \ge 0.8$.

**Output**

Substituting back the slack variable definitions ($s_1 = 12-3x_1-2x_2$ and $s_2=10-x_1-4x_2$) converts this into an inequality directly in $x_1, x_2$, which when added to the LP relaxation excludes the fractional vertex $(2.8, 1.8)$ while retaining every integer feasible point of the original problem, such as $(2,1)$ or $(0,2)$. Re-solving the tightened LP relaxation moves the optimal vertex closer to (or exactly onto) an integer point, and this process would continue — generating further cuts from any remaining fractional rows — until an integer-optimal solution is certified. [Inference] The specific tableau values and resulting cut coefficients shown here are illustrative of the derivation mechanics; the exact optimal tableau for this particular instance would need to be computed via the simplex method to confirm the precise numbers.

### Role in Modern Solvers

**Key Points**

- Gomory (specifically GMI) cuts are one of several automatically generated cut families in modern branch-and-cut solvers, typically applied alongside MIR cuts, cover inequalities, and other structure-specific cuts, with the solver deciding at each node which generated cuts are worth retaining.
- Root-node cut generation (before branching begins) is where Gomory/GMI cuts are most commonly and heavily applied, since the root relaxation often has the most "room" for cuts to tighten before the combinatorial branching process begins.
- Combined with branching, the practical role of Gomory cuts today is to reduce the total size of the branch-and-bound tree by tightening bounds early, rather than to solve the problem via cuts alone as in the original theoretical algorithm.

### Conclusion

Gomory cuts represent the foundational cutting plane technique in integer programming: derived directly and mechanically from the simplex tableau, they apply to any integer program without requiring specialized structure, and their finite-convergence property was a landmark theoretical result. While pure Gomory cutting plane algorithms proved impractical in isolation due to slow convergence and numerical instability, their mixed-integer generalization (GMI cuts) remains a standard and effective component of the cut families generated within modern branch-and-cut solvers, typically deployed heavily at the root node alongside other automatically generated cuts.

**Related Topics**

- Cutting Plane Methods for Integer Programming
- Branch and Bound Algorithm Mechanics
- Linear Relaxation of Integer Programs
- Mixed-Integer Rounding and Flow Cover Inequalities
- Total Unimodularity and Integral Polyhedra
- Numerical Stability in Simplex-Based Solvers
- Branch-and-Cut and Modern MILP Solver Architecture