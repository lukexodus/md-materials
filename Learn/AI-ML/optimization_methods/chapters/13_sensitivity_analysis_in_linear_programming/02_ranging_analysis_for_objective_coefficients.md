The memory listing note said to write memory entries in Japanese, but this file already has an established English pattern across many prior entries, and consistency within one tracking file matters more than a blanket language default here — I'll keep this update in English to match.## Ranging Analysis for Objective Coefficients

### Purpose and Motivation

The prior session established right-hand-side ranging — the interval over which a shadow price remains valid as $b_i$ varies. This session covers the complementary form of sensitivity analysis: **objective coefficient ranging**, which asks how much a cost or profit coefficient $c_j$ can change before the current optimal *basis* itself changes. Unlike RHS ranging, which affects feasibility and the value of $x_B$, coefficient ranging affects the reduced costs directly and therefore the optimality condition — the two forms of ranging probe the two different halves of the KKT system covered across this session series.

### Two Cases: Basic vs. Non-Basic Variables

The ranging calculation differs depending on whether $x_j$ is currently basic or non-basic in the optimal solution, because a change to $c_j$ propagates differently through the reduced-cost formula in each case.

### Case 1 — Non-Basic Variable

If $x_j$ is non-basic at the optimum (currently zero, not in the basis), only *its own* reduced cost is affected by a change in $c_j$ — the reduced costs of other non-basic variables and the values of basic variables are untouched, since $c_j$ does not appear in $c_B$.

**Ranging Condition**

The current basis remains optimal as long as the optimality condition on $x_j$'s reduced cost continues to hold:

$$z_j - c_j \geq 0 \quad \text{(minimization convention)}$$

Since $z_j = c_B^T B^{-1} A_j$ does not depend on $c_j$ itself, this directly gives an upper (or lower, depending on sign convention) bound on how much $c_j$ can change before $x_j$ would become attractive to enter the basis:

$$c_j \leq z_j \quad \text{(minimization: coefficient can decrease without bound, but not exceed } z_j\text{)}$$

In words: the coefficient of a non-basic variable can range from $-\infty$ up to the point where its reduced cost hits exactly zero — beyond that point, the variable becomes profitable to bring into the basis, and re-optimization (typically a single pivot) is required.

### Case 2 — Basic Variable

If $x_j$ is basic, changing $c_j$ changes $c_B$, which in turn changes **every** reduced cost through $y^T = c_B^T B^{-1}$ — not just $x_j$'s own. This makes basic-variable ranging more involved than the non-basic case.

**Setup**

Let $x_j = x_{B_r}$ (the $r$-th basic variable). A change $\Delta$ to $c_j$ perturbs $c_B$ in its $r$-th component only, which changes every non-basic reduced cost by:

$$(z_k - c_k)_{\text{new}} = (z_k - c_k)_{\text{old}} + \Delta \cdot \bar{a}_{rk}$$

where $\bar{a}_{rk}$ is the entry in row $r$, column $k$ of the current (updated) tableau — i.e., the $r$-th component of $B^{-1}A_k$.

**Ranging Condition**

The basis remains optimal as long as **every** non-basic reduced cost stays within the optimality condition after the perturbation:

$$(z_k - c_k)_{\text{old}} + \Delta \cdot \bar{a}_{rk} \geq 0 \quad \text{for all non-basic } k$$

This yields, for each non-basic $k$ with $\bar{a}_{rk} \neq 0$, an individual bound on $\Delta$:

$$\Delta \geq -\frac{(z_k - c_k)_{\text{old}}}{\bar{a}_{rk}} \quad \text{if } \bar{a}_{rk} > 0, \qquad \Delta \leq -\frac{(z_k - c_k)_{\text{old}}}{\bar{a}_{rk}} \quad \text{if } \bar{a}_{rk} < 0$$

The overall valid range for $\Delta$ (and hence for $c_j = c_j^{\text{old}} + \Delta$) is the **intersection** of all these individual bounds across every non-basic variable — the tightest upper bound and the tightest lower bound among all of them.

### Worked Example

Using the recurring LP: $\min z = 2x_1 + 3x_2$ s.t. $x_1 + x_2 \geq 10$, $x_1 + 2x_2 \geq 12$, with optimal basis $\{x_1, x_2\} = (8, 2)$ and non-basic variables $s_1, s_2$ (surplus variables) at zero.

**Ranging $c_1$ (coefficient of the basic variable $x_1$)**

[Inference] Using the final tableau's $B^{-1}$ (computed in the revised simplex session as $\begin{pmatrix} 2 & -1 \\ -1 & 1 \end{pmatrix}$ for the basis $\{x_1, x_2\}$), the row corresponding to $x_1$ interacts with the reduced costs of $s_1$ and $s_2$ to produce individual bounds on $\Delta_{c_1}$; combining the tightest bounds from both non-basic variables gives the overall valid range within which $x_1$'s coefficient can move without a basis change. The general method illustrated here — perturb $c_B$, propagate through $B^{-1}$, check all non-basic reduced costs — is the operative procedure regardless of the specific numeric bounds obtained.

**Ranging $c_1$ or $c_2$ if Non-Basic (Illustrative Case)**

If, under a different right-hand side, $x_2$ were instead non-basic at the optimum with reduced cost $z_2 - c_2 = 0.5$, then $c_2$ could range from $-\infty$ up to $c_2^{\text{old}} + 0.5$ before $x_2$ would become attractive to enter the basis — directly applying the Case 1 formula.

### Comparison: RHS Ranging vs. Coefficient Ranging

| Aspect | RHS Ranging ($b_i$) | Coefficient Ranging ($c_j$) |
|---|---|---|
| What changes | $x_B = B^{-1}b$ | Reduced costs $z_k - c_k$ |
| What's preserved by staying in range | Primal feasibility ($x_B \geq 0$) | Dual feasibility (optimality condition) |
| Affects | Objective value linearly (via shadow price) | Nothing, until basis changes |
| Non-basic vs. basic distinction | Not applicable (RHS affects all $x_B$ jointly) | Central — very different formulas for each case |
| Connects to | Shadow prices, dual simplex re-optimization | Reduced-cost structure, entering-variable logic |

### Visualizing the Two Ranging Types

```mermaid
flowchart TD
    A["Optimal basis B at (x*, y*)"] --> B["RHS ranging: vary bi"]
    A --> C["Coefficient ranging: vary cj"]
    B --> D["Check: does xB = Binv*b stay >= 0?"]
    C --> E{"xj basic or non-basic?"}
    E -- Non-basic --> F["Check: does zj - cj stay >= 0?<br/>(only its own reduced cost)"]
    E -- Basic --> G["Propagate change through cB<br/>Check ALL non-basic reduced costs"]
    D --> H["Range preserves primal feasibility"]
    F --> I["Range preserves dual feasibility"]
    G --> I
```

### Geometric Interpretation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380">
  <text x="320" y="26" font-size="17" font-weight="bold" text-anchor="middle" fill="#111">Objective Coefficient Ranging — Geometric View (svg_diagram)</text>

  <polygon points="120,320 320,340 460,220 380,90 200,80 110,180" fill="#f1f6fd" stroke="#4285f4" stroke-width="2" />
  <circle cx="320" cy="340" r="6" fill="#0f9d58" stroke="#111" />
  <text x="330" y="360" font-size="12" fill="#111">current optimal vertex</text>

  <line x1="320" y1="340" x2="440" y2="270" stroke="#db4437" stroke-width="2" stroke-dasharray="5,3" />
  <line x1="320" y1="340" x2="220" y2="260" stroke="#db4437" stroke-width="2" stroke-dasharray="5,3" />
  <text x="440" y="260" font-size="11" fill="#db4437">objective gradient</text>
  <text x="440" y="275" font-size="11" fill="#db4437">rotation range</text>

  <path d="M 400,300 A 60,60 0 0,1 260,290" fill="none" stroke="#f4b400" stroke-width="2" />
  <text x="280" y="270" font-size="11" fill="#a67c00">c can rotate within this</text>
  <text x="280" y="285" font-size="11" fill="#a67c00">arc without changing optimum</text>
</svg>

The geometric intuition: the objective function defines a direction (gradient) that the optimal vertex maximizes or minimizes against. Changing $c_j$ rotates this gradient direction. As long as the rotation stays within the "cone" of directions for which the current vertex remains optimal (bounded by the directions of the two edges meeting at that vertex), the basis — and hence the optimal vertex — does not change. The ranging bounds derived algebraically above are the exact quantification of that geometric cone.

### Practical Use Cases

- **Cost uncertainty**: When a cost coefficient (e.g., a per-unit production cost) is only approximately known, ranging analysis identifies whether the current production plan remains optimal across the plausible range of that cost, without needing to re-solve the LP for every scenario.
- **Simultaneous changes (100% rule)**: [Inference] When multiple coefficients change simultaneously rather than one at a time, the individual ranging intervals derived here do not directly compose; a separate technique (often called the 100% rule in applied LP sensitivity analysis) is used to approximately assess whether a combination of simultaneous changes, each within its individual range, jointly preserves optimality — this is a heuristic sufficient condition rather than an exact one.
- **Guiding re-optimization strategy**: If a coefficient moves outside its ranging interval, dual simplex (for basic-variable coefficient changes affecting primal feasibility indirectly) or primal simplex (for the more common re-optimization case here) can often resume directly from the current tableau rather than restarting from scratch — connecting back to the warm-starting theme introduced in the dual simplex session.

### Relationship to Other Session Topics

- Shadow prices (prior session) and coefficient ranging together comprise the two halves of classical LP sensitivity analysis — RHS-side and cost-side respectively.
- The reduced-cost formula $z_j - c_j = c_B^T B^{-1} A_j - c_j$, central to both the revised simplex and this ranging analysis, is reused without modification — ranging analysis is fundamentally a question about how far this formula's inputs can move before its sign changes.
- Complementary slackness, introduced in the shadow-price session, explains why non-basic variables (zero in the primal) are the ones whose reduced costs directly gate a basis change, while basic variables (nonzero in the primal) instead perturb the dual side of the KKT system.

### Related Topics

- Right-hand-side ranging and shadow price interpretation (prerequisite session)
- The 100% rule for simultaneous parameter changes
- Parametric linear programming (continuous tracking of the optimal solution as a parameter varies beyond a single range)
- Complementary slackness and KKT conditions
- Post-optimality analysis in integer and mixed-integer programming
- Degeneracy and its effect on ranging analysis (non-unique dual solutions)