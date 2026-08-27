## Warm-Starting Strategies

### Overview

Warm-starting refers to initializing an optimization algorithm at a solution (or near-solution) from a related, previously solved problem rather than from a generic or cold start point. This is central to constrained optimization software practice in settings where problems are solved repeatedly with small perturbations: sequential quadratic programming (SQP) iterations, model predictive control (MPC), branch-and-bound nodes in mixed-integer programming, parametric sensitivity studies, and interactive re-optimization. A good warm start can reduce iteration counts by an order of magnitude; a poor one can actively slow convergence relative to a cold start, particularly for interior-point methods.

### Why Warm-Starting Matters

**Key Points**
- Solvers pay a large fixed cost to establish feasibility and identify the active set (or interior trajectory) from scratch. Reusing a nearby solution amortizes this cost across a sequence of related problems.
- The benefit is method-dependent: active-set and simplex-type methods (including SQP's inner QP solves) warm-start naturally because they work with a discrete combinatorial object (the active set or basis) that changes little between nearby problems.
- Interior-point methods are comparatively difficult to warm-start well, because a solution near the central path for one problem may be far from centered — and worse, may violate strict interior feasibility — for a perturbed problem.
- In real-time and embedded optimization (MPC being the canonical example), warm-starting is often the difference between meeting a control loop deadline and missing it.

### Warm-Starting Active-Set and Simplex Methods

**Explanation**

Active-set methods (including the QP subproblems inside SQP) maintain a working set of constraints treated as equalities. Warm-starting supplies:
- An initial guess for the active set (which inequality constraints are binding).
- A corresponding basic feasible point or basis matrix (for simplex-type QP/LP solvers).

If the previous solution's active set remains a good guess, the solver may need only a handful of active-set exchanges to reach the new optimum, compared to potentially many more from a cold start. This is why sequential QP solvers, when solving a sequence of QPs across SQP iterations, almost always warm-start the QP subproblem with the previous iterate's active set.

**Practical mechanics**
- Most active-set QP solvers (e.g., `qpOASES`, dense/sparse active-set codes) expose an explicit warm-start API: pass the prior solution's primal point, dual multipliers, and working set index array.
- The number of active-set changes needed is bounded by problem structure, but in practice, for small parameter perturbations, only $O(1)$ exchanges are typically needed — this is the main empirical justification for warm-starting in MPC. [Inference: exact exchange counts are problem-dependent and not guaranteed by theory in the worst case.]
- Degenerate problems (multiple constraints tied at the boundary) can cause cycling or stalling even with warm-starting; anti-cycling rules (e.g., Bland's rule, lexicographic perturbation) remain necessary safeguards.

### Warm-Starting Interior-Point Methods

**Explanation**

Interior-point methods (IPMs) follow a central path parameterized by a barrier parameter $\mu \to 0$. A solution that is well-centered and near-optimal for problem $k$ is not automatically well-centered for a perturbed problem $k+1$, for two structural reasons:

1. **Strict interior requirement.** IPM iterates must stay strictly feasible with respect to inequality constraints (i.e., all slack variables and their dual multipliers strictly positive). A point on or very close to the boundary — typical of a converged IPM solution where $\mu$ is tiny — has almost no room to move if the perturbed problem shifts the boundary even slightly.
2. **Loss of centrality.** The complementarity products $x_i s_i$ for each primal-dual pair should be roughly equal and near $\mu$ along the central path. A converged solution has these products near zero and highly non-uniform, which is a poor centering point for resuming the barrier method.

**Standard mitigation techniques**
- **Push the point back into the interior.** Before resuming, primal and dual iterates are shifted away from the boundary (e.g., increasing small slacks and multipliers by a fixed margin) to restore strict feasibility and centrality, at the cost of some proximity to the exact previous solution.
- **Increase $\mu$ before restarting.** Rather than resuming at the tiny $\mu$ from convergence, the algorithm restarts with a moderately larger barrier parameter, effectively backing up along the central path to a better-centered point.
- **Predictor-corrector warm-start variants.** Some IPM implementations (following approaches related to Mehrotra's predictor-corrector framework) incorporate specialized warm-start heuristics that blend the old solution with a corrective step toward centrality for the new problem.
- **Accept partial benefit.** Even with these adjustments, IPM warm-starting typically yields a moderate iteration reduction (often on the order of 20–50%) rather than the near-immediate convergence sometimes seen with active-set warm-starts. [Inference: the specific range is solver- and problem-dependent and not a guaranteed bound.]

This asymmetry — active-set methods warm-start well, IPMs warm-start only partially — is one of the most-cited practical reasons some real-time optimization practitioners prefer active-set QP solvers for MPC despite IPMs' better worst-case complexity guarantees.

### Warm-Starting in Sequential Quadratic Programming

**Explanation**

Within SQP, each major iteration solves a QP subproblem approximating the nonlinear program locally. Warm-starting operates at two nested levels:

1. **QP-level warm-start:** the QP solver at SQP iteration $k+1$ is warm-started using the active set and multipliers from the QP solved at iteration $k$, since consecutive QP subproblems differ only by small changes in the linearization.
2. **NLP-level warm-start:** when solving a sequence of related NLPs (e.g., in MPC, the NLP at each control step is a shifted/perturbed version of the previous one), the entire SQP trajectory — primal variables, Lagrange multipliers, and often the Hessian approximation (e.g., BFGS state) — is warm-started from the prior NLP's solution.

**Shift warm-starting in MPC**

A widely used MPC-specific technique: after solving the optimization at time $t$, the solution trajectory is shifted forward by one time step to initialize the problem at $t+1$ (dropping the now-past first stage and appending an estimate for the new terminal stage). This exploits the fact that under nominal (undisturbed) prediction, the tail of the previous optimal trajectory remains near-optimal for the shifted horizon.

$$
u^{(t+1)}_{\text{warm}} = \left(u^{(t)}_1, u^{(t)}_2, \ldots, u^{(t)}_{N-1}, u^{(t)}_{N-1}\right)
$$

Here the last control is duplicated (or otherwise heuristically extended) to fill the newly exposed final slot in the receding horizon.

### Warm-Starting in Mixed-Integer and Branch-and-Bound Contexts

**Explanation**
- **Node-level warm-starting:** in branch-and-bound for mixed-integer programs, each node's LP or QP relaxation differs from its parent by one added bound (from branching). Warm-starting the relaxation solver from the parent node's solution/basis is standard practice and is one of the primary reasons dual-simplex methods are favored for the LP relaxations inside MILP solvers — a single bound change typically requires very few dual-simplex pivots to restore optimality.
- **Solution warm-starting across re-solves:** when a MILP is re-solved after a small data change (e.g., rolling-horizon scheduling), a previously found feasible integer solution can be supplied to the solver as a starting incumbent (a "MIP start"), which can prune large parts of the search tree immediately if the warm-start solution is good.
- Most commercial and open-source MILP solvers (branch-and-cut frameworks) expose an explicit interface for supplying an initial feasible solution or partial solution, independent of any LP-level warm-starting happening internally.

### Warm-Starting and Parametric Sensitivity

**Explanation**

Warm-starting is closely related to (but distinct from) parametric sensitivity analysis. Sensitivity analysis uses derivatives of the KKT conditions with respect to problem parameters to predict how the solution changes for small perturbations, without re-solving. Warm-starting uses an available solution (possibly the sensitivity-predicted one) purely as an initial point for a full re-solve.

A common combined workflow:
1. Solve the base problem to obtain $(x^\*, \lambda^\*, \mu^\*)$.
2. Use first-order sensitivity (via the implicit function theorem applied to the KKT system) to predict $x(\theta + \Delta\theta) \approx x^\* + \frac{\partial x}{\partial \theta}\Delta\theta$.
3. Use this predicted point — rather than the unperturbed $x^\*$ — as the warm start for re-solving the perturbed problem.

This combination ("warm-start with a sensitivity-predicted point") generally outperforms warm-starting with the raw unperturbed solution when perturbations are not infinitesimally small. [Inference: the magnitude of improvement depends on the curvature of the solution manifold and the perturbation size; not quantified generically.]

### Diagram: Warm-Start Decision Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 560" font-family="Helvetica, Arial, sans-serif">
  <text x="450" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Warm-Starting Decision Flow (svg_diagram)</text>

  <rect x="350" y="55" width="200" height="50" rx="8" fill="#e8eef7" stroke="#3b5c8f" stroke-width="1.5" />
  <text x="450" y="85" text-anchor="middle" font-size="13" fill="#1a1a1a">New/perturbed problem instance</text>

  <line x1="450" y1="105" x2="450" y2="135" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="330" y="135" width="240" height="55" rx="8" fill="#fdf3e0" stroke="#b8860b" stroke-width="1.5" />
  <text x="450" y="158" text-anchor="middle" font-size="13" fill="#1a1a1a">Is solver active-set / simplex-type?</text>
  <text x="450" y="175" text-anchor="middle" font-size="11" fill="#555">(vs. interior-point)</text>

  <line x1="330" y1="162" x2="150" y2="220" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="220" y="200" font-size="12" fill="#2f6f3e" font-weight="bold">Yes</text>

  <line x1="570" y1="162" x2="750" y2="220" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="700" y="200" font-size="12" fill="#a83232" font-weight="bold">No</text>

  <rect x="40" y="220" width="240" height="65" rx="8" fill="#e6f4ea" stroke="#2f6f3e" stroke-width="1.5" />
  <text x="160" y="243" text-anchor="middle" font-size="12" fill="#1a1a1a">Warm-start with prior</text>
  <text x="160" y="259" text-anchor="middle" font-size="12" fill="#1a1a1a">active set + basis</text>
  <text x="160" y="275" text-anchor="middle" font-size="11" fill="#555">Expect few pivot exchanges</text>

  <rect x="630" y="220" width="240" height="65" rx="8" fill="#fbeaea" stroke="#a83232" stroke-width="1.5" />
  <text x="750" y="243" text-anchor="middle" font-size="12" fill="#1a1a1a">Push iterate into interior</text>
  <text x="750" y="259" text-anchor="middle" font-size="12" fill="#1a1a1a">+ restore centrality</text>
  <text x="750" y="275" text-anchor="middle" font-size="11" fill="#555">Increase barrier parameter</text>

  <line x1="160" y1="285" x2="160" y2="315" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="750" y1="285" x2="750" y2="315" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="40" y="315" width="240" height="55" rx="8" fill="#eef2fb" stroke="#3b5c8f" stroke-width="1.5" />
  <text x="160" y="338" text-anchor="middle" font-size="12" fill="#1a1a1a">Re-solve QP/LP subproblem</text>
  <text x="160" y="354" text-anchor="middle" font-size="11" fill="#555">e.g., SQP inner solve, B&amp;B node</text>

  <rect x="630" y="315" width="240" height="55" rx="8" fill="#eef2fb" stroke="#3b5c8f" stroke-width="1.5" />
  <text x="750" y="338" text-anchor="middle" font-size="12" fill="#1a1a1a">Resume IPM iterations</text>
  <text x="750" y="354" text-anchor="middle" font-size="11" fill="#555">Partial iteration savings</text>

  <line x1="160" y1="370" x2="450" y2="420" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="750" y1="370" x2="450" y2="420" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="330" y="420" width="240" height="55" rx="8" fill="#f5f0fa" stroke="#6a3f9e" stroke-width="1.5" />
  <text x="450" y="443" text-anchor="middle" font-size="12" fill="#1a1a1a">Converged solution for</text>
  <text x="450" y="459" text-anchor="middle" font-size="12" fill="#1a1a1a">current problem instance</text>

  <line x1="450" y1="475" x2="450" y2="505" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="300" y="505" width="300" height="45" rx="8" fill="#fff8dc" stroke="#b8860b" stroke-width="1.5" />
  <text x="450" y="532" text-anchor="middle" font-size="12" fill="#1a1a1a">Shift / adapt for next instance (MPC-style)</text>

  </svg>

### Failure Modes and Practical Safeguards

**Key Points**
- **Infeasible warm start.** If the perturbation is large or the problem structure changes qualitatively (e.g., a constraint that was inactive becomes strongly binding), the warm-start point may be far from feasible. Solvers typically fall back to a feasibility-restoration phase or, if the warm start appears unhelpful, revert to a cold start heuristically.
- **Stale active-set guess.** For active-set methods, an active-set guess that is badly wrong can require more exchanges than a cold start would need, though this is uncommon for small perturbations and is rarely worse in practice than starting from an arbitrary vertex.
- **Warm-start with inconsistent problem dimensions.** In MPC and MILP re-solves, structural changes (added/removed constraints, changed variable counts) require careful re-indexing of the warm-start data; naive reuse can corrupt the solver state. Production implementations typically validate dimensional consistency before accepting a warm-start.
- **Multiplier sign/complementarity violations.** Warm-start dual variables must respect sign constraints (nonnegativity for inequality multipliers) and rough complementarity with their primal slacks; some codes clip or rescale supplied multipliers to enforce this before proceeding. [Unverified: exact clipping/rescaling logic is solver-implementation-specific and not standardized across packages.]

### Worked Illustration: MPC Shift Warm-Start

**Example**

Consider a discrete-time linear MPC problem with horizon $N = 5$, solved at each time step $t$. At $t = 10$, suppose the optimal control sequence found is:

$$
u^{(10)\*} = (2.1,\ 1.8,\ 1.2,\ 0.9,\ 0.5)
$$

At $t = 11$, the horizon shifts forward by one step. The shift warm-start discards $u_1^{(10)\*} = 2.1$ (now applied to the plant) and reuses the remaining four values, appending a duplicate of the last entry to fill the new final slot:

$$
u^{(11)}_{\text{warm}} = (1.8,\ 1.2,\ 0.9,\ 0.5,\ 0.5)
$$

This vector is passed as the initial guess to the QP solver at $t = 11$. Under nominal (disturbance-free) dynamics and no active constraint changes, this warm start is very close to the true optimum of the $t=11$ problem, so the QP solver typically needs only a small number of active-set adjustments to converge. In the presence of disturbances or model mismatch, the warm start is still generally closer to optimal than a naive cold start (e.g., all-zero controls), though the improvement margin shrinks as disturbance magnitude grows.

### Summary Comparison

| Method class | Warm-start object | Typical effectiveness | Main risk |
|---|---|---|---|
| Active-set QP/LP | Active set + basis + multipliers | High for small perturbations | Bad active-set guess costs extra exchanges |
| Interior-point | Primal-dual point, adjusted for interior + centrality | Moderate (partial iteration savings) | Loss of strict feasibility/centrality |
| SQP (NLP-level) | Full iterate: $x$, multipliers, Hessian approx. | High in MPC/sequential settings | Hessian approx. staleness after large steps |
| Branch-and-bound (MILP) | Parent-node LP basis; incumbent solution | High for node re-solves; variable for full MILP | Structural change invalidates basis/solution |

### Related Topics

- Sensitivity analysis via the implicit function theorem applied to KKT systems
- Mehrotra predictor-corrector methods for interior-point solvers
- Dual-simplex methods and their role in branch-and-bound relaxations
- Real-time iteration (RTI) schemes for nonlinear MPC
- BFGS/quasi-Newton Hessian approximation updates across SQP iterations
- Feasibility restoration phases in constrained NLP solvers
- Rolling-horizon and receding-horizon problem formulations
- MIP start / solution pool mechanisms in commercial MILP solvers