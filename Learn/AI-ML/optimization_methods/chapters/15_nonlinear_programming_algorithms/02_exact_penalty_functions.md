## Exact Penalty Functions

### Definition and Purpose

An **exact penalty function** is a penalty-based reformulation of a constrained optimization problem for which a minimizer of the penalized problem coincides _exactly_ with a minimizer of the original constrained problem, for some **finite** value of the penalty parameter $\rho$. This distinguishes exact penalty functions from the quadratic penalty method, where exact feasibility is only achieved asymptotically as $\rho \to \infty$.

For the general constrained problem:

$$\min_{x \in \mathbb{R}^n} \quad f(x) \quad \text{subject to} \quad c_i(x) = 0,\ i \in \mathcal{E}, \quad c_j(x) \geq 0,\ j \in \mathcal{I}$$

an exact penalty function seeks $\rho^* < \infty$ such that, for all $\rho > \rho^_$, any local solution $x^_$ of the constrained problem is also a local unconstrained minimizer of the penalized objective.

### The ℓ1 Exact Penalty Function

**Key Points**

The most widely used exact penalty is the $\ell_1$ penalty:

$$\phi_1(x;\rho) = f(x) + \rho \sum_{i \in \mathcal{E}} |c_i(x)| + \rho \sum_{j \in \mathcal{I}} \max(0, -c_j(x))$$

Each term measures constraint violation using an absolute-value (equality) or hinge-type (inequality) penalty, both of which are zero exactly on the feasible region and grow linearly with the magnitude of violation elsewhere.

**Exactness Theorem (informal statement)**

Under standard regularity assumptions — $x^_$ is a local solution satisfying the linear independence constraint qualification (LICQ) and second-order sufficient conditions, with associated Lagrange multipliers $\lambda_i^_$ (equalities) and $\mu_j^* \geq 0$ (active inequalities) — $x^*$ is a local minimizer of $\phi_1(x;\rho)$ for every:

$$\rho > \rho^* = \max\left(\max_{i \in \mathcal{E}} |\lambda_i^_|,\ \max_{j \in \mathcal{I}} \mu_j^_\right)$$

That is, the required penalty threshold is governed by the largest-magnitude Lagrange multiplier at the solution. This is the essential mechanism of exactness: the penalty parameter must be large enough to "outweigh" the marginal rate at which the objective could be improved by violating any constraint, and the Lagrange multipliers precisely quantify that marginal rate.

[Inference] Because $\rho^*$ depends on the unknown optimal multipliers, in practice $\rho$ is typically chosen adaptively or conservatively large, since it cannot be computed exactly in advance without already knowing the solution; specific adaptive strategies vary across implementations.

### Why Exactness Requires Non-Smoothness

**Key Points**

The $\ell_1$ penalty's exactness is closely tied to its non-smoothness (a "kink") exactly at the feasible boundary. Intuitively, for the penalized minimizer to sit precisely at a boundary point $c_i(x)=0$ rather than drift slightly across it, the penalty function needs a _discontinuous change in slope_ there — a smooth penalty (like the quadratic penalty) cannot produce this because its gradient vanishes to first order at the boundary, giving no resistance strong enough to pin the minimizer exactly on the constraint at any finite $\rho$.

Formally, $\phi_1(x;\rho)$ is non-differentiable wherever $c_i(x) = 0$ for $i \in \mathcal{E}$, or wherever $c_j(x) = 0$ for $j \in \mathcal{I}$ (active inequality). At such points, one must work with **subgradients** rather than gradients. The optimality condition for $x^*$ to be a local minimizer of $\phi_1$ becomes:

$$0 \in \partial \phi_1(x^*;\rho)$$

where $\partial \phi_1$ denotes the subdifferential, a set-valued generalization of the gradient at non-smooth points.

### Other Exact Penalty Forms

**Key Points**

- **$\ell_\infty$ exact penalty**: $\phi_\infty(x;\rho) = f(x) + \rho \max\left(\max_{i}|c_i(x)|,\ \max_j \max(0,-c_j(x))\right)$. Shares the non-smoothness and exactness properties of $\ell_1$, with a different (max-based rather than sum-based) aggregation of violations.
- **Fletcher's exact (differentiable) penalty function**: a smooth exact penalty constructed for equality-constrained problems by incorporating a least-squares multiplier estimate directly into the penalty term, e.g. roughly of the form $f(x) - \lambda(x)^Tc(x) + \frac{\rho}{2}|c(x)|^2$ where $\lambda(x)$ is a multiplier estimate that varies smoothly with $x$ (typically obtained via a least-squares fit using the constraint Jacobian). [Inference] Fletcher's penalty achieves exactness while remaining differentiable, but the cost of evaluating $\lambda(x)$ and its derivatives (which require Jacobian and sometimes Hessian information) makes it more expensive per iteration than $\ell_1$; this cost-benefit trade-off is why it has seen less widespread adoption in general-purpose solvers compared to augmented Lagrangian or $\ell_1$-based approaches.

### Comparison of Exact Penalty Variants

|Aspect|$\ell_1$ Penalty|$\ell_\infty$ Penalty|Fletcher's Penalty|
|---|---|---|---|
|Smoothness|Non-smooth at boundary|Non-smooth at boundary|Smooth (differentiable)|
|Aggregation|Sum of violations|Max of violations|Least-squares multiplier estimate embedded|
|Computational cost|Low (no extra derivative work)|Low|Higher (requires Jacobian-based multiplier estimate)|
|Common use|SQP merit functions, SLQP|Alternative aggregation in some solvers|Largely of theoretical/specialized interest|

### Relationship to SQP Merit Functions

**Key Points**

The $\ell_1$ exact penalty function reappears directly in Sequential Quadratic Programming as the standard **merit function** used to globalize the SQP step (as introduced in the SQP subproblem topic). There, $\phi_1(x;\rho)$ is used not to solve the problem outright via unconstrained minimization, but to _evaluate candidate steps_ $p_k$ produced by the QP subproblem — accepting a step if it produces sufficient decrease in $\phi_1$. This connects the exact penalty concept to two different algorithmic roles:

1. **Standalone exact penalty method**: minimize $\phi_1(x;\rho)$ directly (via non-smooth optimization techniques) as the primary solution strategy.
2. **Merit function inside SQP**: use $\phi_1(x;\rho)$ only as an acceptance criterion for steps generated by a separate mechanism (the QP subproblem), not as the objective being directly minimized.

The exactness property is valuable in both roles: in role 1, it guarantees the unconstrained minimizer is the true constrained solution; in role 2, it ensures that a sufficiently good step toward the true solution will, for large enough $\rho$, always be judged as improving the merit function — preventing the line search from rejecting genuinely good steps due to penalty parameter mismatch. [Inference] The Maratos effect, mentioned in the SQP topic, is a case where even with a formally exact penalty and correctly sized $\rho$, the non-smooth merit function can still — under certain curvature conditions — reject a good step; this is a known limitation of naive line-search application of exact penalties rather than a failure of exactness itself.

### Worked Example

**Example**

Minimize $f(x) = x^2$ subject to $c(x) = x - 1 = 0$ (same problem used previously for the quadratic penalty comparison).

The Lagrangian stationarity condition at the true solution $x^_=1$: $\nabla f(x^_) = \lambda^* \nabla c(x^_) \implies 2(1) = \lambda^_(1) \implies \lambda^* = 2$.

So the exactness threshold is $\rho^* = |\lambda^_| = 2$. Choose $\rho = 3 > \rho^_$:

$$\phi_1(x;3) = x^2 + 3|x-1|$$

For $x < 1$: $\phi_1(x;3) = x^2 + 3(1-x) = x^2 - 3x + 3$, with derivative $2x - 3$, zero at $x=1.5$ — but this is outside the region $x<1$ where this branch applies, so no interior critical point exists on this branch (the function is decreasing throughout $x<1$ since $2x-3<0$ there, so it monotonically decreases toward $x=1$).

For $x > 1$: $\phi_1(x;3) = x^2 + 3(x-1) = x^2 + 3x - 3$, with derivative $2x+3 > 0$ for all $x>1$ — strictly increasing, so the function increases moving away from $x=1$.

**Output**

Since $\phi_1$ is decreasing for $x<1$ and increasing for $x>1$, the minimum occurs exactly at the kink $x=1=x^_$, confirming exactness at $\rho=3 > \rho^_=2$.

Contrast with $\rho = 1 < \rho^* = 2$ (below threshold): for $x<1$, derivative is $2x - 1$, zero at $x = 0.5$, which **is** within $x<1$ — so the penalized problem has its minimizer at $x=0.5 \ne x^_=1$, demonstrating that exactness fails below the threshold $\rho^_$.

### Exactness Threshold Illustration

<svg viewBox="0 0 800 440" xmlns="http://www.w3.org/2000/svg" font-family="Helvetica, Arial, sans-serif"> <text x="400" y="28" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Exact Penalty: Minimizer Location vs Penalty Parameter (svg_diagram)</text> <line x1="80" y1="380" x2="740" y2="380" stroke="#333" stroke-width="1.5"/> <line x1="80" y1="380" x2="80" y2="60" stroke="#333" stroke-width="1.5"/> <text x="410" y="415" font-size="13" text-anchor="middle" fill="#333">rho (penalty parameter)</text> <text x="35" y="220" font-size="13" text-anchor="middle" fill="#333" transform="rotate(-90 35 220)">Minimizer x(rho)</text> <line x1="80" y1="140" x2="740" y2="140" stroke="#15803d" stroke-width="1.5" stroke-dasharray="5,4"/> <text x="750" y="145" font-size="12" fill="#15803d">x* = 1</text> <line x1="330" y1="60" x2="330" y2="380" stroke="#94a3b8" stroke-width="1" stroke-dasharray="3,3"/> <text x="330" y="400" font-size="12" text-anchor="middle" fill="#555">rho* = 2</text> <path d="M 100 350 Q 200 300 330 140" fill="none" stroke="#c2410c" stroke-width="2.5"/> <path d="M 330 140 L 720 140" fill="none" stroke="#c2410c" stroke-width="2.5"/> <circle cx="180" cy="290" r="5" fill="#c2410c"/> <text x="180" y="270" font-size="11" text-anchor="middle" fill="#333">rho=1, x=0.5</text> <circle cx="330" cy="140" r="5" fill="#c2410c"/> <text x="330" y="120" font-size="11" text-anchor="middle" fill="#333">rho=2, x=1</text> <circle cx="500" cy="140" r="5" fill="#c2410c"/> <text x="500" y="120" font-size="11" text-anchor="middle" fill="#333">rho=3, x=1 (exact)</text>

<text x="410" y="435" font-size="12" text-anchor="middle" fill="#555">Below rho*: minimizer strictly infeasible. At/above rho*: minimizer exactly feasible.</text> </svg>

### Algorithmic Approaches for Minimizing Non-Smooth Exact Penalties

**Key Points**

Since $\phi_1(x;\rho)$ is non-smooth, direct application of gradient-based unconstrained solvers is not valid at kink points. Practical approaches include:

- **Smooth reformulation via slack variables**: introduce $s_i \geq 0$ with $c_i(x) \leq s_i$ and $-c_i(x) \leq s_i$ (for equalities), converting the $\ell_1$-penalized problem into an equivalent smooth problem with linear inequality constraints, solvable by standard smooth constrained methods (this is the basis of the $S\ell_1QP$ formulation).
- **Subgradient methods**: directly minimize using generalized gradients, though typically with slow (sublinear) convergence.
- **Semismooth Newton methods**: exploit the piecewise-smooth structure of $\phi_1$ to retain fast local convergence despite non-differentiability.
- **Sequential Linear/Quadratic Programming (SLQP/SQP with $\ell_1$ merit)**: rather than minimizing $\phi_1$ directly, use it only as an acceptance test for steps generated by smooth subproblems, sidestepping the need to differentiate $\phi_1$ itself, as discussed above.

### Conclusion

Exact penalty functions, most notably the $\ell_1$ penalty, achieve exact correspondence between the penalized unconstrained (or simply-constrained) problem's minimizer and the original constrained problem's solution at a finite penalty parameter, in contrast to the quadratic penalty's need for $\rho \to \infty$. This exactness comes at the structural cost of non-smoothness at the feasible boundary, which is in fact the mechanism enabling exactness, since a smooth penalty cannot pin the minimizer precisely onto a constraint. The required threshold $\rho^*$ is governed by the magnitude of the optimal Lagrange multipliers, tying the penalty method directly back to KKT theory. Beyond their use as standalone solution methods, exact penalty functions are foundational to the merit functions used to globalize SQP, linking this topic directly to the practical globalization strategies of that method.

**Related Topics**

- Augmented Lagrangian methods
- Subgradient and semismooth Newton methods for non-smooth optimization
- SQP merit functions and the Maratos effect
- Fletcher's smooth exact penalty function
- Slack-variable / $S\ell_1QP$ reformulations
- Lagrange multiplier sensitivity and estimation
- Constraint qualification conditions (LICQ, MFCQ)
- Filter methods as an alternative to penalty-parameter tuning

