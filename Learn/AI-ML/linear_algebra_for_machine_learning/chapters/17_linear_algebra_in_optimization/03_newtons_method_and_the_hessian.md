## Newton's Method and the Hessian

### Overview

Newton's method is a second-order optimization algorithm that uses curvature information, captured by the Hessian matrix, to take more direct steps toward a minimum than gradient descent. Where gradient descent uses only the slope (first derivative) of a function, Newton's method incorporates the rate of change of that slope, allowing it to account for the shape of the loss surface.

### The Update Rule

For a function $f: \mathbb{R}^n \to \mathbb{R}$, the Newton's method update is:

$$\mathbf{w}_{t+1} = \mathbf{w}_t - H^{-1}(\mathbf{w}_t) \nabla f(\mathbf{w}_t)$$

where $H(\mathbf{w}_t)$ is the Hessian matrix of $f$ evaluated at $\mathbf{w}_t$, and $\nabla f(\mathbf{w}_t)$ is the gradient vector.

**Key Points**
- $H^{-1}\nabla f$ replaces the scalar learning rate of gradient descent with a matrix transformation of the gradient
- This rescales and rotates the gradient direction according to the local curvature of $f$, rather than moving uniformly in the raw gradient direction
- No separate learning rate hyperparameter is required in the basic form, since the Hessian inverse determines both direction and step size

### Derivation from a Second-Order Taylor Expansion

Newton's method arises from approximating $f$ near $\mathbf{w}_t$ with a second-order Taylor expansion:

$$f(\mathbf{w}) \approx f(\mathbf{w}_t) + \nabla f(\mathbf{w}_t)^T(\mathbf{w} - \mathbf{w}_t) + \frac{1}{2}(\mathbf{w} - \mathbf{w}_t)^T H(\mathbf{w}_t) (\mathbf{w} - \mathbf{w}_t)$$

**Key Points**
- This quadratic approximation is minimized analytically by setting its gradient (with respect to $\mathbf{w}$) to zero
- Solving $\nabla f(\mathbf{w}_t) + H(\mathbf{w}_t)(\mathbf{w} - \mathbf{w}_t) = 0$ for $\mathbf{w}$ yields the Newton update directly
- Because the update is derived from a quadratic approximation, a single Newton step exactly minimizes a truly quadratic function, converging in one iteration

**Example**

For $f(\mathbf{w}) = \mathbf{w}^T A \mathbf{w}$ with symmetric positive definite $A$:

$$\nabla f(\mathbf{w}) = 2A\mathbf{w}, \qquad H = 2A$$

$$\mathbf{w}_{t+1} = \mathbf{w}_t - (2A)^{-1}(2A\mathbf{w}_t) = \mathbf{w}_t - \mathbf{w}_t = \mathbf{0}$$

A single step reaches the minimum exactly, illustrating the one-step convergence property on exactly quadratic objectives.

### The Hessian Matrix

$$H_{ij} = \frac{\partial^2 f}{\partial w_i \partial w_j}$$

**Key Points**
- $H$ is an $n \times n$ matrix for a function of $n$ variables, in contrast to the gradient, which is an $n \times 1$ vector
- For functions with continuous second partial derivatives, $H$ is symmetric, by Clairaut's theorem (equality of mixed partials)
- $H$ describes local curvature: its eigenvalues indicate how steeply $f$ curves along each corresponding eigenvector direction

### Diagram: Gradient Descent vs Newton's Method Path

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">First-Order vs Second-Order Update Paths (svg_diagram)</text>

  <text x="175" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Gradient Descent</text>
  <ellipse cx="175" cy="210" rx="140" ry="55" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="175" cy="210" rx="100" ry="38" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="175" cy="210" rx="60" ry="20" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <path d="M 60 110 L 100 160 L 128 190 L 148 202 L 160 208 L 168 210" stroke="#2563eb" stroke-width="2.5" fill="none"/>
  <circle cx="60" cy="110" r="4" fill="#1e3a8a"/>
  <circle cx="175" cy="210" r="4" fill="#16a34a"/>
  <text x="175" y="290" text-anchor="middle" font-size="12" fill="#555">Multiple small steps,</text>
  <text x="175" y="306" text-anchor="middle" font-size="12" fill="#555">follows local slope only</text>

  <text x="525" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Newton's Method</text>
  <ellipse cx="525" cy="210" rx="140" ry="55" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="525" cy="210" rx="100" ry="38" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="525" cy="210" rx="60" ry="20" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <line x1="410" y1="110" x2="525" y2="210" stroke="#dc2626" stroke-width="2.5"/>
  <circle cx="410" cy="110" r="4" fill="#7f1d1d"/>
  <circle cx="525" cy="210" r="4" fill="#16a34a"/>
  <text x="525" y="290" text-anchor="middle" font-size="12" fill="#555">Direct step,</text>
  <text x="525" y="306" text-anchor="middle" font-size="12" fill="#555">accounts for curvature</text>
</svg>

This diagram is a conceptual illustration, not a plot from a specific numerical run [Inference]. On a truly quadratic surface Newton's method reaches the minimum in one step, as shown analytically above; on non-quadratic surfaces the path typically requires multiple steps, and the exact trajectory depends on the specific function.

### Role of the Hessian in Step Direction and Size

**Key Points**
- The term $H^{-1}\nabla f$ can be decomposed conceptually into a direction change and a magnitude change relative to plain gradient descent, since $H^{-1}$ both rotates the gradient (accounting for interactions between variables via off-diagonal Hessian entries) and rescales it (accounting for curvature magnitude via eigenvalues)
- In directions of high curvature (large eigenvalues of $H$), the effective step size is reduced
- In directions of low curvature (small eigenvalues of $H$), the effective step size is increased
- This adaptive scaling is why Newton's method is largely insensitive to the poor conditioning that slows gradient descent on elongated loss surfaces [Inference: this is a well-established theoretical property of Newton's method under standard convexity assumptions, though practical performance also depends on how accurately the Hessian is computed and how well-conditioned the Hessian itself is]

### Convergence Properties

**Key Points**
- Near a strict local minimum where $H$ is positive definite, Newton's method exhibits quadratic convergence under standard smoothness assumptions, meaning the number of accurate digits in the solution roughly doubles each iteration [Inference: this is a standard result from numerical optimization theory under the stated assumptions; actual observed convergence rate depends on how close the starting point is to the minimum and how well the local quadratic approximation matches the true function]
- This is substantially faster, in terms of iteration count, than the linear convergence typical of gradient descent on ill-conditioned problems
- Faster convergence per iteration does not necessarily mean faster convergence in wall-clock time, since each Newton iteration requires computing and inverting (or solving a linear system involving) the full $n \times n$ Hessian

### Positive Definiteness and Saddle Points

**Key Points**
- If $H$ is positive definite at $\mathbf{w}_t$, the Newton step moves toward a minimum
- If $H$ is indefinite (mixed-sign eigenvalues), the raw Newton step can move toward a saddle point rather than a minimum, since the quadratic approximation being minimized may not have a well-defined minimum in that region
- If $H$ is negative definite, the unmodified Newton update moves toward a local maximum rather than a minimum, since it is following the stationary point of the local quadratic approximation regardless of whether that point is a minimum or maximum
- These failure modes are a primary motivation for modified variants that regularize or approximate the Hessian to maintain positive definiteness

### Computational Cost and Practical Limitations

**Key Points**
- Computing the full Hessian requires $O(n^2)$ storage and, depending on the method used, $O(n^2)$ to $O(n^3)$ computation for construction and inversion, which becomes prohibitive for the large parameter counts typical of deep learning models [Inference: these complexity figures reflect standard dense-matrix computation costs; actual computational cost in a given implementation depends on matrix sparsity, hardware, and the specific linear algebra routines used]
- This cost is the primary reason Newton's method is rarely used directly for training large neural networks, in contrast to first-order methods like SGD and Adam
- The Hessian must also be inverted (or a linear system solved) at every iteration, adding further computational overhead compared to the vector-only updates of gradient descent

### Quasi-Newton Methods

Quasi-Newton methods approximate the Hessian or its inverse using only gradient information gathered across iterations, avoiding direct computation of $H$.

**Key Points**
- BFGS (Broyden–Fletcher–Goldfarb–Shanno) is the most widely used quasi-Newton method, maintaining and updating an approximation to $H^{-1}$ using rank-two matrix updates at each step
- L-BFGS (Limited-memory BFGS) stores only a limited history of past updates rather than the full $n \times n$ approximation matrix, reducing memory requirements from $O(n^2)$ to $O(n)$ per stored vector, making it more feasible for higher-dimensional problems than standard BFGS [Inference: this memory reduction is a direct, well-established consequence of the L-BFGS algorithm's design, though the number of stored vectors and resulting practical memory savings depend on the chosen history length]
- These methods trade some convergence speed for substantially reduced per-iteration cost relative to exact Newton's method

### Related Topics

- Convexity and positive semi-definite Hessians
- Gradient descent as vector updates
- Quadratic forms and eigenvalue classification
- Condition number and optimization convergence
- Quasi-Newton and limited-memory optimization methods
- Second-order methods in deep learning (natural gradient, K-FAC)
