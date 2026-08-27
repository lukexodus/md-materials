## Economic Interpretation of Dual Variables

### Overview

Dual variables (Lagrange multipliers) carry a well-established economic reading as **shadow prices**: the marginal value of relaxing a constraint by one unit. This interpretation connects optimization theory directly to microeconomics — resource pricing, marginal cost, and equilibrium analysis — and provides intuition that is often more immediately useful in applied settings than the purely geometric or algebraic view of duality.

### Shadow Prices: The Core Idea

Consider a general constrained optimization problem parameterized by a right-hand-side vector $b$:

$$v(b) = \min_x \ f(x) \quad \text{s.t.} \quad g(x) \leq b$$

Here $v(b)$ is the **optimal value function**, expressing how the best achievable objective depends on the constraint bound $b$. The shadow price of constraint $i$ at a given $b$ is the sensitivity of $v(b)$ to a small change in $b_i$.

**[Confirmed]** Under standard regularity conditions (strong duality holds, and $v$ is differentiable at $b$), the optimal Lagrange multiplier $\lambda_i^*$ satisfies:

$$\lambda_i^* = -\frac{\partial v(b)}{\partial b_i}$$

**[Inference]** The sign convention here depends on how the constraint and Lagrangian are written; with $g(x) \le b$ rewritten as $g(x) - b \le 0$ and multiplier $\lambda_i \ge 0$ attached to that form, loosening the constraint (increasing $b_i$) can only help or leave unchanged the minimum, so $v(b)$ is non-increasing in $b_i$, giving $\partial v/\partial b_i \le 0$ and hence $\lambda_i^* = -\partial v/\partial b_i \ge 0$, consistent with the multiplier's sign restriction. Texts differ on whether they define $v(b)$ with $g(x) \le b$ or $g(x) + s = b$ or other sign conventions, so the exact sign in the formula should always be checked against the source's Lagrangian convention.

### Derivation via the Envelope Theorem

The envelope theorem formalizes why the multiplier equals this sensitivity, without needing to re-solve the optimization problem for each perturbation of $b$.

Define the Lagrangian $\mathcal{L}(x, \lambda, b) = f(x) + \lambda^T(g(x) - b)$. At the optimum $x^*(b)$, $\lambda^*(b)$, we have $v(b) = \mathcal{L}(x^*(b), \lambda^*(b), b)$ (since complementary slackness makes the multiplier term vanish at feasibility). Differentiating totally with respect to $b_i$:

$$\frac{dv}{db_i} = \frac{\partial \mathcal{L}}{\partial x} \cdot \frac{\partial x^*}{\partial b_i} + \frac{\partial \mathcal{L}}{\partial \lambda} \cdot \frac{\partial \lambda^*}{\partial b_i} + \frac{\partial \mathcal{L}}{\partial b_i}$$

**[Confirmed]** At an optimum satisfying first-order (KKT) stationarity, $\partial \mathcal{L}/\partial x = 0$. Also, $\partial \mathcal{L}/\partial \lambda = g(x^*) - b = 0$ by complementary slackness at binding constraints (or the term is multiplied by zero at non-binding ones). This eliminates the first two terms entirely, leaving only the **direct** partial derivative of the Lagrangian with respect to $b_i$:

$$\frac{dv}{db_i} = \frac{\partial \mathcal{L}}{\partial b_i} = -\lambda_i^*$$

This is the essence of the envelope theorem: the total derivative of the optimal value collapses to the partial derivative, because the indirect effects through $x^*(b)$ and $\lambda^*(b)$ vanish at a stationary optimum. This is precisely why the multiplier can be read off directly as a marginal value without differentiating through the solution mapping.

### Interpretation: Price of a Resource

**[Confirmed]** In a resource-allocation problem where $g(x) \leq b$ represents a resource capacity constraint (e.g., labor hours, budget, raw material), $\lambda_i^*$ represents the **marginal value of one additional unit of resource $i$** — how much the optimal objective would improve if the capacity were relaxed infinitesimally.

**Key Points**

- If $\lambda_i^* = 0$, the constraint is not binding at the optimum (there is slack), so additional units of that resource have zero marginal value — consistent with complementary slackness.
- If $\lambda_i^* > 0$, the constraint is binding and tight, and the resource is scarce enough that relaxing it strictly improves the objective.
- The magnitude of $\lambda_i^*$ quantifies exactly how valuable that marginal unit is, in the same units as the objective function.

### Worked Example: Production Planning

A firm produces two products using labor and machine hours:

$$\max_{x_1, x_2} \ 40x_1 + 30x_2$$



$$\text{s.t.} \quad 2x_1 + x_2 \leq 100 \ \text{(labor hours)}$$



$$\quad x_1 + x_2 \leq 80 \ \text{(machine hours)}$$



$$\quad x_1, x_2 \geq 0$$

Solving (via standard LP techniques — vertex enumeration on the two binding constraints): setting $2x_1 + x_2 = 100$ and $x_1 + x_2 = 80$ simultaneously gives $x_1 = 20$, $x_2 = 60$, with objective value $40(20) + 30(60) = 800 + 1800 = 2600$.

**[Confirmed]** Both constraints bind at this vertex, so both shadow prices are generally nonzero. Solving the dual (or equivalently, using the fact that at a nondegenerate LP vertex the multipliers solve a linear system derived from the active constraint gradients):

$$\begin{pmatrix} 2 & 1 \\ 1 & 1 \end{pmatrix}^T \begin{pmatrix} \lambda_1 \\ \lambda_2 \end{pmatrix} = \begin{pmatrix} 40 \\ 30 \end{pmatrix}$$

Solving this $2\times 2$ system: from the two equations $2\lambda_1 + \lambda_2 = 40$ and $\lambda_1 + \lambda_2 = 30$, subtracting gives $\lambda_1 = 10$, and back-substituting gives $\lambda_2 = 20$.

**Output**

- $\lambda_1 = 10$: each additional labor hour is worth **$10** to the firm at the margin.
- $\lambda_2 = 20$: each additional machine hour is worth **$20** to the firm at the margin — machine time is the more constraining, valuable resource here.

**Verification (finite-difference check).** **[Confirmed]** Increasing machine hours from 80 to 81 and re-solving: $2x_1+x_2=100, $x_1+x_2=81 \Rightarrow x_1=19, x_2=62
, objective $= 40(19)+30(62)=760+1860=2620$, an increase of exactly $20$ — matching $\lambda_2$. This finite-difference check confirms the marginal interpretation for this specific unit change, consistent with linearity of the LP value function between vertices of the feasible region.

### Complementary Slackness as an Economic Statement

**[Confirmed]** Complementary slackness — $\lambda_i^* \cdot (g_i(x^*) - b_i) = 0$ — has a direct economic reading: a resource is only priced (has positive shadow value) if it is fully utilized. Idle capacity commands zero price, since acquiring more of an already-abundant resource does not improve the optimum.

**[Inference]** This mirrors the economic intuition of competitive equilibrium pricing, where a good's price is driven to zero once supply exceeds demand at the margin — the mathematical statement and the informal supply-demand intuition align, though the formal equivalence requires the specific structure of a competitive market model (e.g., in general equilibrium theory) rather than following automatically from complementary slackness alone.

### Diagram: Shadow Price as Marginal Sensitivity

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 650 380">
\<style\>
.lbl { font-family: sans-serif; font-size: 13px; fill: #1a1a1a; }
.lbl-sm { font-family: sans-serif; font-size: 11px; fill: #444; }
.title { font-family: sans-serif; font-size: 15px; font-weight: bold; fill: #1a1a1a; }
.axis { stroke: #333; stroke-width: 1.5; }
.curve { stroke: #3b6ea5; stroke-width: 2.5; fill: none; }
.tangent { stroke: #a53b3b; stroke-width: 1.5; stroke-dasharray: 5,3; }
\</style\>
<text x="325" y="26" text-anchor="middle" class="title">Optimal Value Function v(b) and Shadow Price (svg_diagram)</text>

<line x1="80" y1="320" x2="580" y2="320" class="axis" />
<line x1="80" y1="320" x2="80" y2="60" class="axis" />
<text x="580" y="340" text-anchor="middle" class="lbl">b (resource capacity)</text>
<text x="45" y="60" text-anchor="middle" class="lbl">v(b)</text>

<path d="M 100 300 Q 250 120 550 90" class="curve" />

<line x1="200" y1="380" x2="450" y2="60" class="tangent" />

<circle cx="320" cy="165" r="5" fill="#a53b3b" />
<text x="335" y="150" class="lbl">b*</text>
<text x="335" y="185" class="lbl-sm">slope = lambda* (shadow price)</text>


<text x="130" y="290" class="lbl-sm">Slack region:</text>

<text x="130" y="305" class="lbl-sm">lambda = 0 (flat)</text>

<text x="380" y="110" class="lbl-sm">Binding region:</text>

<text x="380" y="125" class="lbl-sm">lambda &gt; 0 (rising)</text>

</svg>

### Duality Gap as Economic Inefficiency

**[Inference]** In integer or nonconvex problems where a duality gap exists (as discussed in Lagrangian relaxation), the economic interpretation weakens: the shadow price derived from the Lagrangian dual no longer exactly equals the true marginal value of relaxing the constraint by one integer unit, because $v(b)$ may not be differentiable, or the relevant "derivative" may not exist in the classical sense at integer points. In these cases, $\lambda^*$ is better understood as the marginal value of relaxing the constraint in the **convexified** version of the problem (i.e., relative to $\text{conv}(X)$), which can differ from the marginal value in the true discrete problem — a point worth flagging explicitly whenever shadow prices are quoted for integer programs.

### Applications Across Domains

**[Confirmed]** The shadow-price interpretation recurs across many applied fields:

- **Production economics**: shadow prices of labor, capital, and material constraints, as in the worked example — this is the classical linear programming application.
- **Electricity markets**: locational marginal prices (LMPs) in power systems are literally the dual variables of power-balance constraints in the economic dispatch optimization problem, computed and published by grid operators.
- **Portfolio optimization**: the multiplier on a budget constraint gives the marginal utility of an additional dollar of investable capital.
- **Environmental economics**: multipliers on emissions or resource-cap constraints are interpreted as the marginal abatement cost or the implicit carbon price consistent with a given cap.
- **Water resource management**: multipliers on reservoir or allocation constraints give the marginal value of an additional unit of water across competing uses.

### Caveats on the Interpretation

**[Inference]** Several caveats are worth keeping in mind when using the shadow-price interpretation in practice:

- The interpretation is strictly **local/marginal** — it describes the effect of an infinitesimal change in $b_i$, and for LPs it is valid over the range of $b_i$ for which the current optimal basis remains optimal (the "right-hand-side ranging" interval); outside that range, the shadow price itself changes.
- Degeneracy in the primal (multiple optimal bases at the same vertex) can make the dual solution, and hence the shadow price, non-unique, requiring care in reporting a single "the" shadow price.
- The interpretation assumes strong duality holds; when it does not (e.g., nonconvex problems with a genuine gap), the multiplier should be interpreted relative to the relaxed/convexified problem, as noted above, not the original.

### Conclusion

Dual variables in constrained optimization are not merely algebraic devices for enforcing constraints — they carry a precise economic meaning as marginal values, or shadow prices, of the resources or requirements those constraints represent. The envelope theorem justifies this reading rigorously, showing that the optimal multiplier equals the sensitivity of the optimal objective to a constraint perturbation, with indirect effects through the optimal solution vanishing at a stationary point. This interpretation underlies applications from production planning to electricity pricing, though it requires care regarding locality, degeneracy, and the presence of duality gaps in nonconvex settings.

**Related Topics**

- Envelope theorem in parametric optimization
- Sensitivity analysis and right-hand-side ranging in linear programming
- Complementary slackness and KKT conditions
- Locational marginal pricing in electricity markets
- Degenerate LP solutions and multiplier non-uniqueness
- Shadow prices under duality gaps (nonconvex/integer programs)