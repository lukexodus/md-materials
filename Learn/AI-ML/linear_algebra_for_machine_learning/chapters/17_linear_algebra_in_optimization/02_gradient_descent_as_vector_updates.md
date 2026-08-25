## Gradient Descent as Vector Updates

### Overview

Gradient descent is an iterative optimization algorithm that minimizes a function by repeatedly moving parameters in the direction of steepest decrease. Framed in linear algebra terms, each iteration is a vector update: the parameter vector is adjusted by subtracting a scaled version of the gradient vector.

### The Basic Update Rule

$$\mathbf{w}_{t+1} = \mathbf{w}_t - \eta \nabla f(\mathbf{w}_t)$$

where $\mathbf{w}_t \in \mathbb{R}^n$ is the parameter vector at step $t$, $\eta$ is the learning rate (a positive scalar), and $\nabla f(\mathbf{w}_t)$ is the gradient of the loss function at $\mathbf{w}_t$.

**Key Points**
- $\nabla f(\mathbf{w}_t)$ is a vector in $\mathbb{R}^n$, the same dimensionality as the parameter vector, pointing in the direction of steepest increase of $f$
- Subtracting the gradient moves the parameter vector in the direction of steepest decrease
- $\eta$ controls step size along that direction; it is a scalar multiplying every component of the gradient vector uniformly

### The Gradient as a Vector of Partial Derivatives

For $f: \mathbb{R}^n \to \mathbb{R}$, the gradient is defined as:

$$\nabla f(\mathbf{w}) = \begin{bmatrix} \dfrac{\partial f}{\partial w_1} \\ \dfrac{\partial f}{\partial w_2} \\ \vdots \\ \dfrac{\partial f}{\partial w_n} \end{bmatrix}$$

**Key Points**
- Each component measures the rate of change of $f$ with respect to one parameter, holding others fixed
- The gradient direction is the direction of maximum increase of $f$ at that point; this follows from the Cauchy-Schwarz inequality applied to the directional derivative $\nabla f(\mathbf{w}) \cdot \mathbf{u}$, which is maximized when unit vector $\mathbf{u}$ aligns with $\nabla f(\mathbf{w})$
- The magnitude $\|\nabla f(\mathbf{w})\|$ indicates the steepness of the function at that point; near a minimum, this magnitude typically approaches zero

**Example**

For $f(w_1, w_2) = w_1^2 + w_2^2$:

$$\nabla f(\mathbf{w}) = \begin{bmatrix} 2w_1 \\ 2w_2 \end{bmatrix}$$

At $\mathbf{w} = [3, 4]$, $\nabla f(\mathbf{w}) = [6, 8]$. With $\eta = 0.1$:

$$\mathbf{w}_{1} = [3, 4] - 0.1 \cdot [6, 8] = [3, 4] - [0.6, 0.8] = [2.4, 3.2]$$

### Geometric Interpretation

#### Diagram: Gradient Descent Path on a Loss Surface

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Gradient Descent as Sequential Vector Updates (svg_diagram)</text>

  <circle cx="350" cy="210" r="140" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <circle cx="350" cy="210" r="100" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <circle cx="350" cy="210" r="60" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <circle cx="350" cy="210" r="20" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <circle cx="350" cy="210" r="4" fill="#16a34a"/>
  <text x="350" y="240" text-anchor="middle" font-size="12" fill="#16a34a">minimum</text>

  <line x1="150" y1="90" x2="230" y2="130" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow)"/>
  <line x1="230" y1="130" x2="280" y2="165" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow)"/>
  <line x1="280" y1="165" x2="315" y2="190" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow)"/>
  <line x1="315" y1="190" x2="335" y2="203" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow)"/>

  <circle cx="150" cy="90" r="4" fill="#1e3a8a"/>
  <text x="140" y="75" text-anchor="middle" font-size="12" fill="#333">w0</text>
  <circle cx="230" cy="130" r="4" fill="#1e3a8a"/>
  <text x="240" y="118" text-anchor="middle" font-size="12" fill="#333">w1</text>
  <circle cx="280" cy="165" r="4" fill="#1e3a8a"/>
  <text x="292" y="155" text-anchor="middle" font-size="12" fill="#333">w2</text>
  <circle cx="315" cy="190" r="4" fill="#1e3a8a"/>
  <text x="327" y="182" text-anchor="middle" font-size="12" fill="#333">w3</text>

  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#2563eb"/>
    </marker>
  </defs>

  <text x="350" y="360" text-anchor="middle" font-size="12" fill="#555">Each step is a vector subtraction: w(t+1) = w(t) − η∇f(w(t))</text>
</svg>

This diagram is a conceptual illustration of the update trajectory, not a plot from a specific numerical run. [Inference] Actual paths depend on the loss surface shape, learning rate, and starting point, and are not guaranteed to resemble this idealized picture in every case.

### Learning Rate as a Scalar Multiplier

**Key Points**
- Too small a learning rate produces slow convergence, since each vector step covers little distance toward the minimum
- Too large a learning rate can cause the update to overshoot the minimum, potentially producing oscillation or divergence, particularly on ill-conditioned loss surfaces
- The relationship between learning rate and convergence behavior is influenced by the eigenvalues of the Hessian matrix of $f$; specifically, for quadratic $f$, convergence of standard gradient descent requires $\eta < 2/\lambda_{\max}$, where $\lambda_{\max}$ is the largest eigenvalue of the Hessian [Inference: this bound is a standard, well-established result in convex optimization theory for quadratic objectives, though it may not directly apply to non-quadratic or non-convex loss surfaces without modification]

### Variants as Modified Vector Updates

#### Stochastic Gradient Descent (SGD)

Replaces the full gradient with an estimate computed from a single sample or mini-batch.

$$\mathbf{w}_{t+1} = \mathbf{w}_t - \eta \nabla f_i(\mathbf{w}_t)$$

**Key Points**
- $\nabla f_i(\mathbf{w}_t)$ is a noisy estimate of the true gradient, computed on a subset of the data rather than the entire dataset
- The vector update structure is unchanged; only the source of the gradient vector differs

#### Momentum

Introduces a velocity vector that accumulates a running average of past gradients.

$$\mathbf{v}_{t+1} = \beta \mathbf{v}_t + (1-\beta)\nabla f(\mathbf{w}_t)$$
$$\mathbf{w}_{t+1} = \mathbf{w}_t - \eta \mathbf{v}_{t+1}$$

**Key Points**
- $\mathbf{v}_t$ is a vector of the same dimensionality as $\mathbf{w}_t$, accumulated via a weighted vector sum across iterations
- $\beta \in [0,1)$ controls how much past gradient direction persists, smoothing the update path and often reducing oscillation on ill-conditioned surfaces [Inference: this smoothing effect is a widely observed and theoretically motivated property of momentum methods, though the degree of improvement is problem-dependent and not automatic in every case]

#### Adam (Adaptive Moment Estimation)

Maintains per-parameter estimates of both the first moment (mean) and second moment (uncentered variance) of the gradient, using them to rescale each component of the update vector individually.

$$\mathbf{m}_{t+1} = \beta_1 \mathbf{m}_t + (1-\beta_1)\nabla f(\mathbf{w}_t)$$
$$\mathbf{v}_{t+1} = \beta_2 \mathbf{v}_t + (1-\beta_2)\left(\nabla f(\mathbf{w}_t)\right)^2$$
$$\mathbf{w}_{t+1} = \mathbf{w}_t - \eta \frac{\hat{\mathbf{m}}_{t+1}}{\sqrt{\hat{\mathbf{v}}_{t+1}} + \epsilon}$$

**Key Points**
- The squaring and square-root operations here are element-wise, not matrix operations, applied independently to each component of the gradient vector
- This gives each parameter its own effective learning rate, based on the historical magnitude of its gradient component
- $\hat{\mathbf{m}}$ and $\hat{\mathbf{v}}$ denote bias-corrected versions of $\mathbf{m}$ and $\mathbf{v}$, a correction used to offset their initialization at zero

### Matrix Form for Batch Updates

For linear regression with loss $f(\mathbf{w}) = \|X\mathbf{w} - \mathbf{y}\|_2^2$, the gradient has a closed matrix form:

$$\nabla f(\mathbf{w}) = 2X^T(X\mathbf{w} - \mathbf{y})$$

so the update becomes:

$$\mathbf{w}_{t+1} = \mathbf{w}_t - 2\eta X^T(X\mathbf{w}_t - \mathbf{y})$$

**Key Points**
- $X \in \mathbb{R}^{m \times n}$ is the data matrix, $\mathbf{y} \in \mathbb{R}^m$ the target vector
- $X\mathbf{w}_t - \mathbf{y}$ is the residual vector in $\mathbb{R}^m$; left-multiplying by $X^T$ maps this residual back into parameter space $\mathbb{R}^n$
- This expresses each gradient descent step entirely in terms of matrix-vector products, connecting the optimization update directly to linear algebra operations

### Convergence Behavior and Conditioning

**Key Points**
- The rate of convergence of gradient descent on a quadratic objective depends on the condition number of the Hessian, $\kappa = \lambda_{\max}/\lambda_{\min}$
- A large condition number (ill-conditioned problem) produces a narrow, elongated loss surface, causing gradient descent to zigzag rather than move directly toward the minimum
- Feature normalization (see prior topic) directly affects this condition number, since it changes the relative scale of the Hessian's eigenvalues [Inference: this connection between feature scaling and Hessian conditioning is a standard result in optimization theory, though the exact numerical improvement depends on the specific dataset and model]

### Related Topics

- Convexity and its role in gradient descent guarantees
- Normalization techniques and their effect on optimization conditioning
- Eigenvalues, eigenvectors, and the Hessian matrix
- Newton's method and second-order optimization
- Backpropagation as repeated application of the chain rule to gradient vectors
- Learning rate scheduling and adaptive optimization methods

