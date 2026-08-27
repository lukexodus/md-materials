## Complementary Slackness and Primal-Dual Relationships

### Complementary Slackness as the Bridge Between Primal and Dual

Complementary slackness has already appeared twice in this sequence: first as a standalone KKT condition with a shadow-price interpretation, and again as a byproduct falling out of the weak-duality proof when the duality gap closes. This section consolidates both views into a single primal-dual framework, showing precisely how complementary slackness certifies optimality jointly for a primal-feasible point and a dual-feasible point, without needing to solve either problem independently.

### Restating the Condition in Primal-Dual Language

**Key Points**

- Given a primal-feasible $x$ (satisfying $g(x)\le0$, $h(x)=0$) and a dual-feasible $(\mu,\lambda)$ (satisfying $\mu\ge0$), complementary slackness requires:

$$\mu_i \, g_i(x) = 0, \quad \forall i = 1,\dots,m$$

- This is a **pairing condition** between the primal point and the dual point — it is not a property of either one alone, but a joint requirement linking them.
- When complementary slackness holds together with primal feasibility, dual feasibility, and stationarity ($\nabla_x \mathcal L(x,\mu,\lambda)=0$, when differentiable), the pair $(x,\mu,\lambda)$ constitutes a full KKT point — the four conditions together are what "KKT conditions" collectively denotes.

### Deriving Complementary Slackness from the Weak-Duality Chain

Recall the weak-duality proof: for any primal-feasible $x$ and dual-feasible $(\mu,\lambda)$,

$$q(\mu,\lambda) \ \le\ \mathcal{L}(x,\mu,\lambda) \ \le\ f(x)$$

**Key Points**

- If $x^*$ is primal optimal, $(\mu^*,\lambda^*)$ is dual optimal, and **strong duality holds** ($q(\mu^*,\lambda^*) = f(x^*)$, i.e., $d^*=p^*$), then both inequalities in this chain must hold with **equality**.
- The second inequality becoming an equality, $\mathcal L(x^*,\mu^*,\lambda^*) = f(x^*)$, expands to $f(x^*)+\mu^{*T}g(x^*)+\lambda^{*T}h(x^*) = f(x^*)$. Since $\lambda^{*T}h(x^*)=0$ automatically (primal feasibility of equality constraints), this forces $\mu^{*T}g(x^*)=0$.
- Since each term $\mu_i^*g_i(x^*) \le 0$ individually (from $\mu^*\ge0$, $g_i(x^*)\le0$), and their sum is exactly zero, **each individual term must itself be zero**: $\mu_i^*g_i(x^*)=0$ for every $i$ — precisely complementary slackness, derived here purely from the duality argument rather than from direct KKT derivation.
- The first inequality becoming an equality, $q(\mu^*,\lambda^*) = \mathcal L(x^*,\mu^*,\lambda^*)$, additionally forces $x^*$ to be a **global minimizer of $\mathcal L(\cdot,\mu^*,\lambda^*)$ over $x$** — not merely a KKT stationary point of it, a stronger and cleaner conclusion available precisely because of the duality framing.

### The Full Primal-Dual Optimality Certificate

**Key Points**

- Given strong duality, a pair $(x^*,\mu^*,\lambda^*)$ is simultaneously primal- and dual-optimal **if and only if** all of the following hold together:
  1. **Primal feasibility**: $g(x^*)\le0$, $h(x^*)=0$
  2. **Dual feasibility**: $\mu^*\ge0$
  3. **Complementary slackness**: $\mu_i^*g_i(x^*)=0$ for all $i$
  4. **Lagrangian minimization**: $x^*\in\arg\min_x \mathcal L(x,\mu^*,\lambda^*)$
- This four-part characterization is logically equivalent to the standard KKT system when $\mathcal L(\cdot,\mu^*,\lambda^*)$ is differentiable and condition 4 is replaced by its first-order stationarity condition — but the duality-derived version (condition 4 as a **global** minimization) is stronger when $\mathcal L$ is not necessarily convex in $x$, since global minimization is a strictly stronger requirement than merely zero gradient.
- In convex problems, stationarity of $\mathcal L(\cdot,\mu^*,\lambda^*)$ in $x$ **is** sufficient for global minimization (since $\mathcal L(\cdot,\mu^*,\lambda^*)$ is convex in $x$ whenever $f,g_i$ are convex and $\mu^*\ge0$), so the two formulations coincide exactly in the convex case — another instance of convexity unifying what are otherwise distinct conditions in general nonconvex problems.

### Visualizing the Primal-Dual Certificate (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 340">
<text x="370" y="26" font-family="sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Primal-Dual Optimality Certificate (svg_diagram)</text>
<rect x="40" y="60" width="300" height="90" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
<text x="190" y="90" font-family="sans-serif" font-size="13" font-weight="bold" text-anchor="middle" fill="#1e3a8a">Primal point x*</text>
<text x="190" y="110" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#1e3a8a">g(x*) ≤ 0, h(x*) = 0</text>
<text x="190" y="128" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#1e3a8a">(primal feasibility)</text>
<rect x="400" y="60" width="300" height="90" rx="8" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" />
<text x="550" y="90" font-family="sans-serif" font-size="13" font-weight="bold" text-anchor="middle" fill="#14532d">Dual point μ*, λ*</text>
<text x="550" y="110" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#14532d">μ* ≥ 0</text>
<text x="550" y="128" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#14532d">(dual feasibility)</text>
<rect x="180" y="185" width="380" height="90" rx="8" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
<text x="370" y="215" font-family="sans-serif" font-size="13" font-weight="bold" text-anchor="middle" fill="#78350f">Complementary slackness</text>
<text x="370" y="235" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#78350f">μᵢ* gᵢ(x*) = 0 for all i</text>
<text x="370" y="253" font-family="sans-serif" font-size="11" text-anchor="middle" fill="#78350f">links the two sides</text>
<line x1="190" y1="150" x2="300" y2="200" stroke="#333333" stroke-width="2" marker-end="url(#a3)" />
<line x1="550" y1="150" x2="440" y2="200" stroke="#333333" stroke-width="2" marker-end="url(#a3)" />
<rect x="220" y="295" width="300" height="35" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.5" />
<text x="370" y="318" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#4c1d95">Certifies: p* = d*, both optimal</text>
</svg>

### Worked Example: Reading Off Complementary Slackness from a Primal-Dual Pair

Reusing the earlier resource-constraint example: minimize $f(x_1,x_2)=(x_1-3)^2+(x_2-2)^2$ subject to $g(x)=x_1+x_2-4\le0$, with primal optimum $x^*=(2.5,1.5)$ and multiplier $\mu^*=1$.

Check complementary slackness directly: $g(x^*) = 2.5+1.5-4=0$, so $\mu^*g(x^*) = 1\times0=0$ ✓ — consistent with $\mu^*>0$ forcing $g(x^*)=0$ exactly, as required.

Verify condition 4 (Lagrangian minimization) independently: $\mathcal L(x,\mu^*) = (x_1-3)^2+(x_2-2)^2+1\cdot(x_1+x_2-4)$. This is convex in $x$ (sum of convex quadratics plus a linear term), so stationarity is sufficient for global minimization: $\partial\mathcal L/\partial x_1 = 2(x_1-3)+1=0\implies x_1=2.5$; $\partial\mathcal L/\partial x_2=2(x_2-2)+1=0\implies x_2=1.5$ — matches $x^*$ exactly, confirming $x^*$ globally minimizes $\mathcal L(\cdot,\mu^*)$, completing the full primal-dual certificate.

### Complementary Slackness in Linear Programming: The Classical Statement

**Key Points**

- For the LP pair $\min c^Tx$ s.t. $Ax\ge b$, $x\ge0$ (primal) and $\max b^Ty$ s.t. $A^Ty\le c$, $y\ge0$ (dual), the classical complementary slackness theorem states: for optimal $x^*,y^*$: $y_i^*=0$ whenever the $i$-th primal constraint is slack ($a_i^Tx^* > b_i$), and $x_j^*=0$ whenever the $j$-th dual constraint is slack ($a_j^Ty^* < c_j$).
- This two-directional statement (primal slack $\Rightarrow$ dual variable zero, **and** dual slack $\Rightarrow$ primal variable zero) is the LP-specific specialization of the general complementary slackness condition, applied symmetrically to both the primal and its dual simultaneously, since LP duality is itself symmetric (the dual of the dual recovers the primal).
- This symmetric LP statement underlies the simplex method's optimality test: a basic feasible solution is optimal precisely when the associated dual solution (read off from the reduced costs) satisfies dual feasibility, which by complementary slackness is automatically consistent with the primal solution's basic/nonbasic variable structure.

### Using Complementary Slackness to Solve One Problem from the Other

**Key Points**

- If the primal-optimal $x^*$ is known but its associated multipliers are not, complementary slackness provides a **system of equations**: for each active constraint, an unknown multiplier may be nonzero; for each inactive constraint, the multiplier is forced to zero — combined with stationarity, this often yields enough equations to solve directly for the remaining unknown multipliers algebraically, as seen in the worked KKT examples throughout this sequence.
- Conversely, if a dual-optimal $(\mu^*,\lambda^*)$ is known first, complementary slackness restricts which primal constraints can possibly be active (only those with $\mu_i^*>0$ must be active; those with $\mu_i^*=0$ are unconstrained by this condition and could be active or inactive) — this partial information, combined with the Lagrangian-minimization condition, can sometimes be enough to pin down $x^*$ directly, particularly useful in problems where the dual is easier to solve first (e.g., certain large-scale or decomposable problems).

### Degenerate Complementary Slackness and Non-Uniqueness

**Key Points**

- When a constraint is active ($g_i(x^*)=0$) but its multiplier is also zero ($\mu_i^*=0$) — the degenerate case previously discussed — complementary slackness is satisfied, but this constraint contributes no information toward pinning down a unique multiplier vector, and other constraints' multipliers may become non-unique as a consequence in the surrounding linear system.
- This non-uniqueness has a direct primal-dual consequence: **multiple** dual-optimal points $(\mu^*,\lambda^*)$ can correspond to the **same** primal-optimal $x^*$, all satisfying complementary slackness with it equally validly — the primal-dual pairing is not necessarily one-to-one in degenerate cases.
- Conversely, in problems lacking strict convexity, multiple primal-optimal $x^*$ can correspond to the same dual-optimal $(\mu^*,\lambda^*)$ — full primal-dual uniqueness on both sides simultaneously typically requires additional assumptions (e.g., strict convexity of $f$ for primal uniqueness, LICQ for dual uniqueness) beyond complementary slackness and strong duality alone.

### Practical Workflow: Certifying a Candidate Solution

```mermaid
flowchart TD
    A[Candidate primal x, candidate dual mu, lambda] --> B{Primal feasible? g(x) less or equal 0, h(x) = 0}
    B -->|No| C[Reject: not a valid certificate]
    B -->|Yes| D{Dual feasible? mu greater or equal 0}
    D -->|No| C
    D -->|Yes| E{Complementary slackness: mu_i times g_i(x) = 0 for all i?}
    E -->|No| C
    E -->|Yes| F{Does x globally minimize L of dot, mu, lambda over x?}
    F -->|No| C
    F -->|Yes| G[Full certificate confirmed: x is primal optimal, mu lambda is dual optimal, zero gap]
```

### Why This Matters Computationally

**Key Points**

- Primal-dual interior-point methods maintain **approximate** primal feasibility, dual feasibility, and complementary slackness simultaneously throughout their iterations, gradually tightening all three toward exact satisfaction — the algorithm's convergence criterion is essentially "how close is the current point to satisfying this full certificate," making complementary slackness a direct, quantifiable convergence measure (often tracked as the "complementarity gap" $\mu^Tg(x)$ at each iterate, distinct from but related to the overall duality gap).
- In problems solved via decomposition or distributed optimization (e.g., ADMM, dual decomposition), complementary slackness at convergence is exactly the condition that confirms the separately-computed primal and dual pieces have been correctly reconciled into a jointly optimal solution.
- Checking complementary slackness (and the full certificate) is often computationally **cheap** relative to solving either the primal or dual problem from scratch — this makes it a standard, efficient way to verify a candidate solution obtained by any method (heuristic, approximate, or exact) actually attains optimality, rather than merely appearing reasonable.

### Related Topics

- Weak and strong duality theorems
- KKT conditions as the differentiable specialization of the primal-dual certificate
- LP complementary slackness and the simplex method's optimality test
- Primal-dual interior-point methods and the complementarity gap
- Dual decomposition and ADMM for large-scale and distributed optimization
- Degenerate KKT points and multiplier non-uniqueness
- Sensitivity analysis via multipliers as shadow prices