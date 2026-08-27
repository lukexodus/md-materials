## Lagrangian Function Construction

### Purpose of the Lagrangian

The Lagrangian function is the central algebraic device that converts a constrained optimization problem into an unconstrained (or more tractable) stationarity problem. It absorbs the constraints into the objective via multiplier terms, so that the constrained optimality conditions can be read off from ordinary partial derivatives of a single scalar function, rather than requiring separate geometric reasoning about the feasible set for every problem instance.

### General Construction

For the standard-form nonlinear program:

$$\min_{x \in \mathbb{R}^n} f(x) \quad \text{s.t.} \quad g_i(x) \le 0,\ i=1,\dots,m, \qquad h_j(x) = 0,\ j=1,\dots,p$$

the Lagrangian is defined as:

$$\mathcal{L}(x,\mu,\lambda) = f(x) + \sum_{i=1}^m \mu_i\, g_i(x) + \sum_{j=1}^p \lambda_j\, h_j(x)$$

where $\mu = (\mu_1,\dots,\mu_m) \in \mathbb{R}^m$ are the multipliers for inequality constraints, and $\lambda = (\lambda_1,\dots,\lambda_p) \in \mathbb{R}^p$ are the multipliers for equality constraints.

### Sign Conventions and Why They Matter

**Key Points**

- The construction above requires $\mu_i \ge 0$ for the inequality-constraint terms; this sign restriction is what makes complementary slackness and the KKT sign conditions come out consistently, and it is tied directly to the direction of the inequality ($g_i(x) \le 0$, i.e., feasibility means $g_i$ nonpositive).
- If instead the constraint is written as $g_i(x) \ge 0$, the corresponding term must enter with a **negative** sign convention (or equivalently the multiplier restricted to $\mu_i \le 0$) to preserve the same geometric meaning — different textbooks adopt different default conventions, so consistency between the constraint direction and the multiplier's sign restriction must always be checked before applying any stated KKT theorem.
- Equality-constraint multipliers $\lambda_j$ carry **no sign restriction** — since $h_j(x)=0$ can be perturbed in either direction while remaining a well-posed equality, there is no natural "one-sided" restriction analogous to $\mu_i \ge 0$.
- Some formulations use $-\mu_i$ or place the constraint terms with different overall signs (e.g., $\mathcal L = f(x) - \sum_i \mu_i g_i(x)$ paired with $g_i(x)\ge0$ constraints); the underlying content is identical, but blind formula-copying across differing conventions is a frequent source of sign errors in derivations.

### Step-by-Step Construction Procedure

**Key Points**

- **Step 1**: Write the problem in standard form, ensuring every inequality constraint is expressed as "$\le 0$" and every equality constraint as "$=0$" (rearranging as needed, e.g., $x_1 \ge 5$ becomes $5 - x_1 \le 0$).
- **Step 2**: Assign one multiplier per constraint — $\mu_i$ for each inequality, $\lambda_j$ for each equality — matching the indexing of the constraint list exactly.
- **Step 3**: Form the sum $f(x) + \sum_i \mu_i g_i(x) + \sum_j \lambda_j h_j(x)$, adding each constraint function (not its negative, given the standard-form sign convention above) multiplied by its assigned multiplier.
- **Step 4**: Record the multiplier sign restrictions ($\mu_i \ge 0$ for all $i$; $\lambda_j$ free) alongside the Lagrangian, since these restrictions are essential data used later in stationarity, dual feasibility, and complementary slackness — omitting them turns $\mathcal L$ into an incomplete object.

### Worked Example: Mixed Constraint Types

Minimize $f(x_1,x_2) = x_1^2 + x_2^2$ subject to $x_1 + x_2 \ge 2$ and $x_1 - x_2 = 1$.

**Step 1 — standard form.** Rewrite $x_1+x_2\ge2$ as $g(x) = 2 - x_1 - x_2 \le 0$. Rewrite $x_1-x_2=1$ as $h(x) = x_1 - x_2 - 1 = 0$.

**Step 2 — assign multipliers.** $\mu$ for $g$, $\lambda$ for $h$.

**Step 3 — form the sum.**

$$\mathcal{L}(x_1,x_2,\mu,\lambda) = x_1^2 + x_2^2 + \mu(2 - x_1 - x_2) + \lambda(x_1 - x_2 - 1)$$

**Step 4 — record restrictions.** $\mu \ge 0$, $\lambda$ free.

This $\mathcal L$ is now ready for stationarity: $\partial \mathcal L/\partial x_1 = 2x_1 - \mu + \lambda = 0$, $\partial \mathcal L/\partial x_2 = 2x_2 - \mu - \lambda = 0$, alongside the original constraints and complementary slackness $\mu(2-x_1-x_2)=0$.

### The Lagrangian as a Function of Two Groups of Variables

**Key Points**

- $\mathcal L(x,\mu,\lambda)$ is a function of $n + m + p$ variables total: the $n$ primal variables $x$, and the $m+p$ dual variables (multipliers) $\mu,\lambda$.
- Differentiating $\mathcal L$ with respect to $x$ (holding $\mu,\lambda$ fixed) and setting the result to zero recovers the **stationarity condition** of KKT.
- Differentiating $\mathcal L$ with respect to $\lambda_j$ and setting to zero recovers exactly the original equality constraint $h_j(x)=0$ — this is a structural feature of the construction, not a coincidence: $\partial \mathcal L/\partial \lambda_j = h_j(x)$.
- Differentiating with respect to $\mu_i$ gives $\partial \mathcal L/\partial \mu_i = g_i(x)$, which recovers the inequality constraint expression itself, though the inequality's feasibility ($\le0$) and the multiplier's sign ($\ge0$) and their product condition (complementary slackness) must be imposed as *separate* conditions — unlike the equality case, simply setting this partial derivative to zero is not the correct condition to impose here.

### Visualizing the Lagrangian's Role (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 320">
<text x="360" y="26" font-family="sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Lagrangian Construction Pipeline (svg_diagram)</text>
<rect x="30" y="60" width="180" height="60" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
<text x="120" y="85" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#1e3a8a">Objective f(x)</text>
<text x="120" y="103" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#1e3a8a">to be minimized</text>
<rect x="270" y="20" width="180" height="60" rx="8" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" />
<text x="360" y="45" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#14532d">Inequality g_i(x) ≤ 0</text>
<text x="360" y="63" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#14532d">weighted by μ_i ≥ 0</text>
<rect x="270" y="100" width="180" height="60" rx="8" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
<text x="360" y="125" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#78350f">Equality h_j(x) = 0</text>
<text x="360" y="143" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#78350f">weighted by λ_j (free)</text>
<rect x="510" y="60" width="180" height="60" rx="8" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.5" />
<text x="600" y="85" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#4c1d95">Lagrangian L(x,μ,λ)</text>
<text x="600" y="103" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#4c1d95">unified scalar function</text>
<line x1="210" y1="90" x2="505" y2="90" stroke="#333333" stroke-width="2" marker-end="url(#lg)" />
<line x1="450" y1="50" x2="505" y2="80" stroke="#333333" stroke-width="2" marker-end="url(#lg)" />
<line x1="450" y1="130" x2="505" y2="100" stroke="#333333" stroke-width="2" marker-end="url(#lg)" />

<rect x="140" y="220" width="440" height="70" rx="8" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" />
<text x="360" y="245" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#7f1d1d">∂L/∂x = 0 → stationarity</text>
<text x="360" y="263" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#7f1d1d">∂L/∂λ_j = 0 → recovers h_j(x)=0</text>
<text x="360" y="280" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#7f1d1d">(inequality side needs μ≥0, μᵢgᵢ=0 separately)</text>
<line x1="600" y1="120" x2="360" y2="215" stroke="#333333" stroke-width="2" marker-end="url(#lg)" />
</svg>

### Special Case: Linear Programming Lagrangian

For the LP $\min c^Tx$ s.t. $Ax \le b$, $x \ge 0$:

Rewrite as $g(x) = Ax - b \le 0$ (vector inequality) and $-x \le 0$. Assign multiplier vectors $\mu \ge 0$ for $Ax-b\le0$ and $\nu \ge 0$ for $-x \le 0$:

$$\mathcal{L}(x,\mu,\nu) = c^Tx + \mu^T(Ax-b) + \nu^T(-x) = c^Tx + \mu^T(Ax-b) - \nu^Tx$$

**Key Points**

- This construction, when combined with stationarity $\partial\mathcal L/\partial x = c + A^T\mu - \nu = 0$, directly yields the dual feasibility constraint $A^T\mu \ge c$ (upon eliminating $\nu \ge 0$), a direct link between Lagrangian construction and LP duality theory.
- The nonnegativity constraints $x\ge0$ are just as much "constraints" requiring their own multipliers as any other inequality — a common oversight is forgetting to Lagrangian-ize variable bound constraints separately from the main constraint matrix $A$.

### Special Case: Equality-Only (Classical Lagrange Multiplier) Problems

**Key Points**

- When a problem has only equality constraints (the classical setting Lagrange originally studied), the construction simplifies to $\mathcal L(x,\lambda) = f(x) + \sum_j \lambda_j h_j(x)$, with no sign restriction on any multiplier and no complementary slackness condition needed (since equality constraints are always "active" by definition).
- This is the setting where the Lagrangian first arose historically, and it remains the cleanest illustration of the technique — full inequality-constrained KKT theory can be viewed as a substantial generalization built on top of this equality-only foundation, layering in sign restrictions and complementary slackness to handle the additional case distinctions inequality constraints introduce.

### Constructing the Lagrangian for Vector-Valued Constraints

**Key Points**

- When constraints are naturally grouped as vector-valued functions ($g: \mathbb{R}^n \to \mathbb{R}^m$, $h:\mathbb{R}^n\to\mathbb{R}^p$), the same construction applies using inner products: $\mathcal L(x,\mu,\lambda) = f(x) + \mu^Tg(x) + \lambda^Th(x)$, with $\mu \in \mathbb{R}^m_{\ge0}$, $\lambda \in \mathbb{R}^p$ — algebraically identical to the summation form, just written compactly.
- This compact notation is standard in convex optimization texts and is essential once problems involve matrix constraints (e.g., semidefinite programming), where the "inner product" generalizes to a trace inner product $\langle \mu, g(x)\rangle = \text{tr}(\mu^Tg(x))$ for matrix-valued $g$.

### Constructing the Lagrangian Dual Function

**Key Points**

- Once $\mathcal L(x,\mu,\lambda)$ is constructed, the **Lagrangian dual function** is defined by minimizing over the primal variable: $q(\mu,\lambda) = \inf_x \mathcal L(x,\mu,\lambda)$.
- This minimization step is what converts the Lagrangian (a function of both primal and dual variables) into a function purely of the dual variables, setting up the dual problem $\max_{\mu\ge0,\lambda} q(\mu,\lambda)$.
- $q(\mu,\lambda)$ is concave in $(\mu,\lambda)$ **regardless of the convexity of the original primal problem** — this is a structural property of taking an infimum over $x$ of a family of functions affine in $(\mu,\lambda)$, and it is one of the most useful facts to emerge directly from the Lagrangian construction, independent of any assumptions on $f, g, h$.

### Common Construction Mistakes

**Key Points**

- **Sign inconsistency**: mixing a "$g(x)\le0$" convention for one constraint with a "$g(x)\ge0$, multiplier $\le0$" convention for another within the same problem, without adjusting the Lagrangian terms accordingly — this silently breaks the KKT sign conditions downstream.
- **Omitting variable bound constraints**: treating constraints like $x_i \ge 0$ as implicit rather than explicitly Lagrangian-izing them; this is fine only if the subsequent analysis is adjusted to handle them as a special non-negativity-constrained variable set (as in some specialized derivations), but it is not fine if standard KKT formulas are then applied assuming all constraints were included in $\mathcal L$.
- **Forgetting multiplier sign restrictions after construction**: writing down $\mathcal L$ correctly, but then treating $\mu_i$ as an unrestricted variable when solving the stationarity equations — the restriction $\mu_i\ge0$ must be carried through the entire KKT solution process, not just noted once at construction time.
- **Confusing the Lagrangian with the Lagrangian dual function**: $\mathcal L(x,\mu,\lambda)$ still depends on $x$; only after minimizing out $x$ does one obtain $q(\mu,\lambda)$, a function of the multipliers alone — these are related but distinct objects serving different roles (primal-dual stationarity vs. duality theory).

### Related Topics

- KKT conditions and their direct derivation from Lagrangian stationarity
- Lagrangian duality: weak duality, strong duality, and duality gaps
- Complementary slackness and its algebraic origin in the Lagrangian's inequality terms
- Sensitivity analysis via multipliers as Lagrangian byproducts
- Semidefinite programming and matrix-valued Lagrangian constructions
- Saddle-point characterization of the Lagrangian at an optimum
- Augmented Lagrangian methods and penalty-based reformulations