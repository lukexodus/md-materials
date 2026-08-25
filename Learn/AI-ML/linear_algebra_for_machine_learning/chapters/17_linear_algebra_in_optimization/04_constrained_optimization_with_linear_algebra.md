## Constrained Optimization with Linear Algebra

### Overview

Constrained optimization seeks to minimize or maximize a function subject to equality or inequality restrictions on the variables. Linear algebra provides the machinery — gradient vectors, linear combinations, and matrix representations of constraints — used to characterize and solve these problems, most notably through the method of Lagrange multipliers and the KKT conditions.

### Equality-Constrained Optimization

#### Problem Formulation

$$\min_{\mathbf{w}} f(\mathbf{w}) \quad \text{subject to} \quad g(\mathbf{w}) = 0$$

where $f: \mathbb{R}^n \to \mathbb{R}$ is the objective and $g: \mathbb{R}^n \to \mathbb{R}$ defines the constraint surface.

**Key Points**
- The constraint $g(\mathbf{w}) = 0$ defines a lower-dimensional surface (typically $(n-1)$-dimensional) within $\mathbb{R}^n$
- The unconstrained minimum of $f$ generally does not lie on this surface, so the optimal constrained point is instead found where the objective's decrease is balanced against the constraint's geometry

#### The Lagrange Condition

At a constrained optimum, the gradient of $f$ must be parallel to the gradient of $g$:

$$\nabla f(\mathbf{w}^*) = \lambda \nabla g(\mathbf{w}^*)$$

for some scalar $\lambda$, called the Lagrange multiplier.

**Key Points**
- This condition follows from the fact that any component of $\nabla f$ orthogonal to $\nabla g$ would allow further improvement of $f$ while remaining on the constraint surface, so at an optimum no such component can exist
- $\nabla g(\mathbf{w}^*)$ is a vector normal to the constraint surface at $\mathbf{w}^*$; the parallelism condition states that $\nabla f$ has no component tangent to the constraint surface at the optimum
- This is combined into the Lagrangian function:

$$\mathcal{L}(\mathbf{w}, \lambda) = f(\mathbf{w}) - \lambda g(\mathbf{w})$$

and the optimum is found by solving $\nabla_{\mathbf{w}} \mathcal{L} = 0$ and $\nabla_\lambda \mathcal{L} = 0$ simultaneously.

#### Diagram: Lagrange Condition — Parallel Gradients at the Optimum

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Lagrange Condition: Gradient Alignment (svg_diagram)</text>

  <ellipse cx="350" cy="210" rx="200" ry="90" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="350" cy="210" rx="150" ry="65" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="350" cy="210" rx="100" ry="40" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <text x="530" y="145" font-size="12" fill="#94a3b8">level sets of f</text>

  <path d="M 250 130 Q 350 100, 450 150 Q 470 210, 450 270 Q 350 320, 250 270 Q 230 210, 250 130 Z" fill="none" stroke="#dc2626" stroke-width="2.5"/>
  <text x="250" y="335" font-size="12" fill="#dc2626">constraint g(w) = 0</text>

  <circle cx="447" cy="152" r="5" fill="#16a34a"/>
  <text x="470" y="150" font-size="12" fill="#16a34a">w*</text>

  <line x1="447" y1="152" x2="480" y2="115" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow2)"/>
  <text x="500" y="108" font-size="12" fill="#2563eb">∇f</text>

  <line x1="447" y1="152" x2="475" y2="120" stroke="#7f1d1d" stroke-width="1.5" stroke-dasharray="3" marker-end="url(#arrow3)"/>
  <text x="440" y="105" font-size="12" fill="#7f1d1d">∇g</text>

  <defs>
    <marker id="arrow2" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#2563eb"/>
    </marker>
    <marker id="arrow3" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#7f1d1d"/>
    </marker>
  </defs>

  <text x="350" y="365" text-anchor="middle" font-size="12" fill="#555">At the optimum, ∇f and ∇g point in the same (or opposite) direction</text>
</svg>

This is a conceptual illustration of the tangency condition, not a plot of a specific numerical function. [Inference]

**Example**

Minimize $f(w_1, w_2) = w_1^2 + w_2^2$ subject to $w_1 + w_2 = 1$.

$$\mathcal{L} = w_1^2 + w_2^2 - \lambda(w_1 + w_2 - 1)$$

Setting partial derivatives to zero: $2w_1 = \lambda$, $2w_2 = \lambda$, so $w_1 = w_2$. Combined with the constraint $w_1 + w_2 = 1$, this gives $w_1 = w_2 = 0.5$.

### Multiple Equality Constraints

For $m$ constraints $g_1(\mathbf{w}) = 0, \dots, g_m(\mathbf{w}) = 0$, the Lagrangian generalizes to:

$$\mathcal{L}(\mathbf{w}, \boldsymbol{\lambda}) = f(\mathbf{w}) - \sum_{i=1}^{m} \lambda_i g_i(\mathbf{w})$$

**Key Points**
- The optimality condition becomes $\nabla f(\mathbf{w}^*) = \sum_i \lambda_i \nabla g_i(\mathbf{w}^*)$, meaning $\nabla f$ must lie in the span of the constraint gradients — a direct statement in terms of linear combinations of vectors
- This requires the constraint gradients $\nabla g_1, \dots, \nabla g_m$ to be linearly independent at $\mathbf{w}^*$ for the multipliers to be uniquely determined; this is a standard regularity condition (a constraint qualification) in constrained optimization theory

### Inequality Constraints and KKT Conditions

#### Problem Formulation

$$\min_{\mathbf{w}} f(\mathbf{w}) \quad \text{subject to} \quad g_i(\mathbf{w}) \le 0, \ i = 1, \dots, m$$

#### Karush-Kuhn-Tucker (KKT) Conditions

At an optimum $\mathbf{w}^*$, there exist multipliers $\mu_i \ge 0$ satisfying:

$$\nabla f(\mathbf{w}^*) + \sum_{i=1}^{m} \mu_i \nabla g_i(\mathbf{w}^*) = 0 \quad \text{(stationarity)}$$
$$g_i(\mathbf{w}^*) \le 0 \quad \text{(primal feasibility)}$$
$$\mu_i \ge 0 \quad \text{(dual feasibility)}$$
$$\mu_i \, g_i(\mathbf{w}^*) = 0 \quad \text{(complementary slackness)}$$

**Key Points**
- Complementary slackness states that for each constraint, either the constraint is exactly active ($g_i(\mathbf{w}^*) = 0$) or its multiplier is zero ($\mu_i = 0$) — the constraint cannot be both inactive and influencing the solution
- The non-negativity requirement $\mu_i \ge 0$ reflects that inequality constraints can only push the solution in one direction (into the feasible region), unlike equality constraint multipliers, which are unrestricted in sign
- The KKT conditions are necessary for optimality under standard constraint qualifications, and are also sufficient when $f$ is convex and the feasible region defined by the constraints is convex [Inference: this sufficiency result is a well-established theorem in convex optimization theory, applicable under the stated convexity conditions]

### Connection to Support Vector Machines

The SVM optimization problem is a canonical ML example of constrained optimization with linear algebra structure throughout.

$$\min_{\mathbf{w}, b} \frac{1}{2}\|\mathbf{w}\|_2^2 \quad \text{subject to} \quad y_i(\mathbf{w}^T\mathbf{x}_i + b) \ge 1 \ \ \forall i$$

**Key Points**
- The objective is a quadratic form in $\mathbf{w}$ (a convex function, as covered under quadratic forms and convexity), and the constraints are linear in $\mathbf{w}$ and $b$
- Applying the KKT conditions leads to a dual formulation involving only dot products $\mathbf{x}_i^T \mathbf{x}_j$ between data points, which is the basis for the kernel trick, allowing nonlinear decision boundaries via kernel functions replacing the raw dot product
- Complementary slackness in this setting identifies which training points are support vectors: only points with $\mu_i > 0$ (active constraints) contribute to the final decision boundary, since points that satisfy the margin constraint strictly do not affect the solution

### Projected Gradient Methods

For constrained problems where the feasible set $C$ is convex but complex Lagrangian derivations are impractical, projected gradient descent alternates between a standard gradient step and a projection back onto $C$:

$$\mathbf{w}_{t+1} = \text{proj}_C\left(\mathbf{w}_t - \eta \nabla f(\mathbf{w}_t)\right)$$

**Key Points**
- The projection operation $\text{proj}_C(\mathbf{x}) = \arg\min_{\mathbf{y} \in C} \|\mathbf{x} - \mathbf{y}\|_2$ is well-defined and unique for convex $C$, as established under convexity
- This method avoids explicitly solving for Lagrange multipliers, instead enforcing feasibility directly at each iteration through a distance-minimizing vector operation

### Equality Constraints via Linear Systems

When constraints are linear, $A\mathbf{w} = \mathbf{b}$, and the objective is quadratic, the KKT stationarity conditions reduce to a linear system that can be solved directly using matrix methods:

$$\begin{bmatrix} H & A^T \\ A & 0 \end{bmatrix} \begin{bmatrix} \mathbf{w} \\ \boldsymbol{\lambda} \end{bmatrix} = \begin{bmatrix} -\mathbf{c} \\ \mathbf{b} \end{bmatrix}$$

where $H$ is the Hessian of the quadratic objective and $\mathbf{c}$ relates to its linear term.

**Key Points**
- This block matrix, known as a KKT matrix, allows constrained quadratic programs to be solved via standard linear algebra techniques such as LU decomposition, rather than iterative optimization
- This structure appears in applications such as equality-constrained least squares and certain formulations of quadratic programming used in ML

### Related Topics

- Convexity and linear algebra connections
- Support vector machines and the kernel trick
- Duality in convex optimization
- Quadratic programming
- Newton's method and the Hessian
- Gradient descent as vector updates
