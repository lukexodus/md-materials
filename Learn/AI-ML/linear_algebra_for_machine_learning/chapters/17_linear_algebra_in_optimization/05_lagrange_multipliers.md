## Lagrange Multipliers

### Overview

The method of Lagrange multipliers converts a constrained optimization problem into an unconstrained one by introducing auxiliary variables — the multipliers — that absorb the effect of each constraint into a single combined objective. This topic focuses on the multipliers themselves: their interpretation, sign conventions, and behavior beyond the basic setup already covered.

### Interpretation as Shadow Prices

**Key Points**
- The optimal multiplier $\lambda^*$ has a direct interpretation as the sensitivity of the optimal objective value to a small relaxation of the constraint, formally $\lambda^* = \dfrac{\partial f(\mathbf{w}^*)}{\partial b}$ for a constraint of the form $g(\mathbf{w}) = b$
- This is often called the "shadow price" of the constraint, since it quantifies how much the optimal value would improve per unit of constraint relaxation
- This sensitivity interpretation is a standard result in optimization theory (an application of the envelope theorem) [Inference: the general result is well established mathematically; the specific numerical sensitivity value in any given application depends on the problem being smooth and the optimum being non-degenerate]

### Sign Conventions

**Key Points**
- For equality constraints, the sign of $\lambda$ is not restricted, since the constraint can be tightened or loosened in either direction without changing feasibility
- For inequality constraints written as $g(\mathbf{w}) \le 0$ in a minimization problem, the associated multiplier must satisfy $\mu \ge 0$, as covered under the KKT dual feasibility condition
- Sign convention differs across textbooks depending on whether the Lagrangian is written as $f - \lambda g$ or $f + \lambda g$; this is a notational choice, not a substantive mathematical difference, and [Unverified] which convention is more common varies by field and source

### Second-Order Conditions: The Bordered Hessian

A stationary point of the Lagrangian is not automatically a constrained minimum — it could be a constrained maximum or saddle. The bordered Hessian tests which case applies.

$$\bar{H} = \begin{bmatrix} 0 & \nabla g^T \\ \nabla g & H_{\mathcal{L}} \end{bmatrix}$$

where $H_{\mathcal{L}}$ is the Hessian of the Lagrangian with respect to $\mathbf{w}$.

**Key Points**
- The signs of the leading principal minors of $\bar{H}$ determine whether the stationary point is a constrained minimum, maximum, or saddle, following a specific alternating-sign pattern derived in constrained optimization theory
- This generalizes the unconstrained second-derivative test (via the ordinary Hessian, covered under Newton's Method) to the constrained case by restricting the test to directions tangent to the constraint surface
- Because the Lagrange stationarity condition alone is only a first-order necessary condition, relying on it without a second-order check can misidentify a saddle point of the Lagrangian as a solution [Inference: this is a structural consequence of Lagrange multiplier theory, not a claim about any specific solver's behavior]

### Multiple Constraints and the Constraint Qualification

**Key Points**
- With multiple active constraints, the requirement that constraint gradients be linearly independent at the candidate optimum (linear independence constraint qualification, LICQ) ensures the multipliers $\lambda_i$ are uniquely determined
- If this condition fails — for example, if two constraint gradients are parallel at the candidate point — the multipliers may not be unique, or the standard first-order conditions may fail to characterize the optimum correctly [Inference: this is a known edge case documented in constrained optimization theory; how a specific numerical solver handles a failed constraint qualification is implementation-dependent and not addressed by the theory itself]

### Worked Example with Interpretation

Minimize $f(w_1, w_2) = w_1^2 + w_2^2$ subject to $w_1 + w_2 = b$ for general $b$ (extending the earlier $b=1$ example).

Following the same stationarity conditions: $w_1 = w_2 = b/2$, and $\lambda = 2w_1 = b$.

$$f(\mathbf{w}^*) = 2(b/2)^2 = b^2/2$$

Checking the shadow price interpretation: $\dfrac{d}{db}\left(\dfrac{b^2}{2}\right) = b = \lambda$, confirming $\lambda^* = \dfrac{\partial f(\mathbf{w}^*)}{\partial b}$ for this example.

### Relationship to Duality

**Key Points**
- The Lagrangian $\mathcal{L}(\mathbf{w}, \lambda)$ can be minimized over $\mathbf{w}$ first to produce the dual function $q(\lambda) = \min_{\mathbf{w}} \mathcal{L}(\mathbf{w}, \lambda)$, whose maximization gives the dual problem
- Weak duality — the dual optimal value is a lower bound on the primal optimal value for minimization problems — holds generally; strong duality — the two values are equal — holds under specific conditions such as Slater's condition for convex problems [Inference: these are established results in convex optimization theory; whether strong duality holds for a specific non-convex problem is not guaranteed by these conditions and would need separate justification]
- This duality connection is the same mechanism used to derive the SVM dual formulation referenced under constrained optimization

### Related Topics

- Constrained optimization with linear algebra
- KKT conditions for inequality-constrained problems
- Duality in convex optimization
- Support vector machines and the kernel trick
- Newton's method and the Hessian (for unconstrained second-order conditions)
- Quadratic programming

===END_SYLLABOT_RESPONSE_7e9b7036a62647bc===