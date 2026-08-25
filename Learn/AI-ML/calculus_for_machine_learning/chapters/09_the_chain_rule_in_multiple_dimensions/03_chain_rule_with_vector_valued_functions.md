## Chain Rule with Vector-Valued Functions

### Overview

When both the input and output of a function are vectors rather than scalars, the chain rule takes the form of matrix multiplication between Jacobians. This generalization is essential for understanding how gradients propagate through layered systems such as neural networks, where each layer is itself a vector-valued function of a vector input.

### Setup: Vector-to-Vector Functions

Consider a composite function built from two vector-valued mappings:

$$\mathbf{g}: \mathbb{R}^n \to \mathbb{R}^m, \qquad \mathbf{f}: \mathbb{R}^m \to \mathbb{R}^k$$

$$\mathbf{y} = \mathbf{g}(\mathbf{x}), \qquad \mathbf{z} = \mathbf{f}(\mathbf{y}) = \mathbf{f}(\mathbf{g}(\mathbf{x}))$$

Here $\mathbf{x} \in \mathbb{R}^n$, $\mathbf{y} \in \mathbb{R}^m$, and $\mathbf{z} \in \mathbb{R}^k$. Each component of $\mathbf{z}$ can depend on every component of $\mathbf{y}$, and each component of $\mathbf{y}$ can depend on every component of $\mathbf{x}$.

### The Jacobian Matrix

For a vector-valued function $\mathbf{f}(\mathbf{y}) = (f_1(\mathbf{y}), \dots, f_k(\mathbf{y}))$, the Jacobian is the $k \times m$ matrix of all first-order partial derivatives:

$$J_f = \frac{\partial \mathbf{z}}{\partial \mathbf{y}} = \begin{bmatrix} \dfrac{\partial f_1}{\partial y_1} & \cdots & \dfrac{\partial f_1}{\partial y_m} \\ \vdots & \ddots & \vdots \\ \dfrac{\partial f_k}{\partial y_1} & \cdots & \dfrac{\partial f_k}{\partial y_m} \end{bmatrix}$$

Each row corresponds to one output component; each column corresponds to one input component.

### The Chain Rule as Matrix Multiplication

The chain rule for the composite $\mathbf{z} = \mathbf{f}(\mathbf{g}(\mathbf{x}))$ states:

$$\frac{\partial \mathbf{z}}{\partial \mathbf{x}} = \frac{\partial \mathbf{z}}{\partial \mathbf{y}} \cdot \frac{\partial \mathbf{y}}{\partial \mathbf{x}}$$

In matrix form:

$$J_{f \circ g}(\mathbf{x}) = J_f(\mathbf{g}(\mathbf{x})) \cdot J_g(\mathbf{x})$$

where $J_f$ is $k \times m$ and $J_g$ is $m \times n$, producing a $k \times n$ product — the Jacobian of the full composite. Each entry of this product matrix is:

$$\left( \frac{\partial \mathbf{z}}{\partial \mathbf{x}} \right)_{ij} = \frac{\partial z_i}{\partial x_j} = \sum_{l=1}^{m} \frac{\partial z_i}{\partial y_l} \cdot \frac{\partial y_l}{\partial x_j}$$

This is the direct matrix generalization of the scalar sum-of-products form of the chain rule.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Vector Chain Rule: Jacobian Composition (svg_diagram)</text>

  <rect x="40" y="120" width="110" height="70" rx="8" fill="#4A90D9" />
  <text x="95" y="160" text-anchor="middle" font-size="16" fill="#fff">x ∈ Rⁿ</text>

  <rect x="265" y="120" width="110" height="70" rx="8" fill="#7FB77E" />
  <text x="320" y="160" text-anchor="middle" font-size="16" fill="#fff">y ∈ Rᵐ</text>

  <rect x="490" y="120" width="110" height="70" rx="8" fill="#E8A33D" />
  <text x="545" y="160" text-anchor="middle" font-size="16" fill="#fff">z ∈ Rᵏ</text>

  <line x1="150" y1="155" x2="265" y2="155" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="375" y1="155" x2="490" y2="155" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />

  <text x="207" y="140" text-anchor="middle" font-size="13" fill="#555">g (Jg: m×n)</text>
  <text x="432" y="140" text-anchor="middle" font-size="13" fill="#555">f (Jf: k×m)</text>

  <path d="M 95 190 Q 320 260 545 190" stroke="#E8622C" stroke-width="2" fill="none" stroke-dasharray="6,3" />
  <text x="320" y="280" text-anchor="middle" font-size="13" fill="#E8622C">f∘g — Jacobian = Jf · Jg (k×n)</text>
</svg>

### Special Case: Scalar Output

When $k = 1$ (i.e., $\mathbf{f}$ produces a scalar $z$), the Jacobian $J_f$ reduces to a row vector — the transpose of the gradient:

$$J_f = \nabla_y z^T = \left( \frac{\partial z}{\partial y_1}, \dots, \frac{\partial z}{\partial y_m} \right)$$

The chain rule then becomes:

$$\nabla_x z = J_g^T \nabla_y z$$

This form — a matrix transpose applied to a gradient vector — appears directly in backpropagation, where gradients are pushed backward through each layer's Jacobian transpose.

### Special Case: Scalar Input (Path Derivative)

When $n = 1$, i.e., $\mathbf{x} = t$ is a single scalar parameter and $\mathbf{y}(t)$, $\mathbf{z}(t)$ trace out paths, the chain rule reduces to a matrix-vector product:

$$\frac{d\mathbf{z}}{dt} = J_f(\mathbf{y}) \cdot \frac{d\mathbf{y}}{dt}$$

Here $\dfrac{d\mathbf{y}}{dt}$ is a column vector (the velocity of the path in $\mathbb{R}^m$), and $J_f$ maps it into a velocity vector in $\mathbb{R}^k$.

### Worked Example

Let $\mathbf{g}(x_1, x_2) = (x_1 + x_2,\; x_1 x_2)$, so $\mathbf{y} = (y_1, y_2) = (x_1 + x_2,\; x_1 x_2)$.

Let $\mathbf{f}(y_1, y_2) = (y_1^2,\; y_1 + y_2)$, so $\mathbf{z} = (z_1, z_2) = (y_1^2,\; y_1 + y_2)$.

**Step 1 — Jacobian of $\mathbf{g}$:**

$$J_g = \begin{bmatrix} \dfrac{\partial y_1}{\partial x_1} & \dfrac{\partial y_1}{\partial x_2} \\ \dfrac{\partial y_2}{\partial x_1} & \dfrac{\partial y_2}{\partial x_2} \end{bmatrix} = \begin{bmatrix} 1 & 1 \\ x_2 & x_1 \end{bmatrix}$$

**Step 2 — Jacobian of $\mathbf{f}$:**

$$J_f = \begin{bmatrix} \dfrac{\partial z_1}{\partial y_1} & \dfrac{\partial z_1}{\partial y_2} \\ \dfrac{\partial z_2}{\partial y_1} & \dfrac{\partial z_2}{\partial y_2} \end{bmatrix} = \begin{bmatrix} 2y_1 & 0 \\ 1 & 1 \end{bmatrix}$$

**Step 3 — Multiply $J_f \cdot J_g$:**

$$J_{f \circ g} = \begin{bmatrix} 2y_1 & 0 \\ 1 & 1 \end{bmatrix} \begin{bmatrix} 1 & 1 \\ x_2 & x_1 \end{bmatrix} = \begin{bmatrix} 2y_1 & 2y_1 \\ 1 + x_2 & 1 + x_1 \end{bmatrix}$$

**Step 4 — Substitute $y_1 = x_1 + x_2$:**

$$J_{f \circ g} = \begin{bmatrix} 2(x_1+x_2) & 2(x_1+x_2) \\ 1 + x_2 & 1 + x_1 \end{bmatrix}$$

This matrix gives all four partial derivatives of $z_1, z_2$ with respect to $x_1, x_2$ simultaneously.

### Relevance to Machine Learning: Layered Composition

A feedforward neural network is a composition of vector-valued functions, one per layer:

$$\mathbf{z} = f_L\big(f_{L-1}(\cdots f_1(\mathbf{x}) \cdots)\big)$$

The Jacobian of the full network with respect to the input is the product of each layer's Jacobian, applied in reverse order during backpropagation:

$$J_{\text{total}} = J_{f_L} \cdot J_{f_{L-1}} \cdots J_{f_1}$$

[Inference] Automatic differentiation systems are generally understood to compute this product incrementally, layer by layer, rather than forming the full Jacobian product explicitly, since intermediate Jacobians can be very large. This is a reasoned inference based on the mathematical structure of the problem and general knowledge of how reverse-mode differentiation is described in academic literature, not a confirmed description of any specific software implementation. I cannot verify the internal implementation details of any particular library, and behavior may vary across frameworks, versions, and configurations.

### Common Pitfalls

- Multiplying Jacobians in the wrong order — matrix multiplication is not commutative, so $J_f \cdot J_g \neq J_g \cdot J_f$ in general
- Mismatching dimensions — the number of columns in $J_f$ must equal the number of rows in $J_g$ for the product to be defined
- Confusing the Jacobian (matrix of all partials) with the gradient (a special case only defined for scalar-valued functions)
- Assuming elementwise multiplication when matrix multiplication is required

### Key Points

- The chain rule for vector-valued functions is expressed as multiplication of Jacobian matrices
- Dimensions must align: an $m \times n$ Jacobian composed with a $k \times m$ Jacobian yields a $k \times n$ result
- The scalar-output case reduces to a gradient computed via a Jacobian-transpose–vector product, directly relevant to backpropagation
- [Inference] Practical automatic differentiation is widely believed, based on published descriptions of reverse-mode algorithms, to avoid forming full Jacobian matrices explicitly for large-scale networks, though this is not independently confirmed here for any specific library and behavior may vary

**Related Topics**
- Jacobian Matrices and Their Role in Vector Calculus
- Backpropagation Derived from First Principles
- Reverse-Mode vs. Forward-Mode Automatic Differentiation
- Hessian Matrices and Second-Order Derivatives
- Computational Graphs as Directed Acyclic Graphs