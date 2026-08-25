## The Chain Rule in Multiple Dimensions

### Overview

The multivariable chain rule generalizes the single-variable chain rule to functions of several variables. It describes how to differentiate a composite function when intermediate variables themselves depend on other variables — a situation that arises constantly in machine learning, particularly in backpropagation through neural network layers.

### Single-Variable Chain Rule Recap

For a composite function $y = f(g(x))$, the derivative is:

$$\frac{dy}{dx} = \frac{dy}{du} \cdot \frac{du}{dx}$$

where $u = g(x)$. This is the foundation the multivariable version builds on.

### The General Multivariable Chain Rule

Suppose $z = f(x, y)$, where $x = x(t)$ and $y = y(t)$ are both functions of a single variable $t$. The total derivative of $z$ with respect to $t$ is:

$$\frac{dz}{dt} = \frac{\partial z}{\partial x} \cdot \frac{dx}{dt} + \frac{\partial z}{\partial y} \cdot \frac{dy}{dt}$$

This says: the total rate of change of $z$ is the sum of the contributions from each path through which $t$ influences $z$.

### Case: Multiple Intermediate Variables, Multiple Inputs

If $z = f(x, y)$, where $x = x(s, t)$ and $y = y(s, t)$, then the partial derivatives with respect to each independent variable are:

$$\frac{\partial z}{\partial s} = \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial s} + \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial s}$$

$$\frac{\partial z}{\partial t} = \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial t} + \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial t}$$

Each equation sums over all intermediate variables that depend on the given independent variable.

### General Form (Tree Diagram Logic)

For a function $z = f(x_1, x_2, \dots, x_n)$ where each $x_i = x_i(t_1, t_2, \dots, t_m)$, the partial derivative with respect to any $t_j$ is:

$$\frac{\partial z}{\partial t_j} = \sum_{i=1}^{n} \frac{\partial z}{\partial x_i} \cdot \frac{\partial x_i}{\partial t_j}$$

This is often visualized using a dependency tree, where each path from $z$ to $t_j$ contributes one term to the sum.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Chain Rule Dependency Tree (svg_diagram)</text>

  <circle cx="320" cy="80" r="28" fill="#4A90D9" />
  <text x="320" y="86" text-anchor="middle" font-size="16" fill="#fff">z</text>

  <circle cx="180" cy="190" r="26" fill="#7FB77E" />
  <text x="180" y="196" text-anchor="middle" font-size="15" fill="#fff">x</text>

  <circle cx="460" cy="190" r="26" fill="#7FB77E" />
  <text x="460" y="196" text-anchor="middle" font-size="15" fill="#fff">y</text>

  <circle cx="110" cy="310" r="24" fill="#E8A33D" />
  <text x="110" y="316" text-anchor="middle" font-size="14" fill="#fff">s</text>

  <circle cx="250" cy="310" r="24" fill="#E8A33D" />
  <text x="250" y="316" text-anchor="middle" font-size="14" fill="#fff">t</text>

  <circle cx="390" cy="310" r="24" fill="#E8A33D" />
  <text x="390" y="316" text-anchor="middle" font-size="14" fill="#fff">s</text>

  <circle cx="530" cy="310" r="24" fill="#E8A33D" />
  <text x="530" y="316" text-anchor="middle" font-size="14" fill="#fff">t</text>

  <line x1="305" y1="105" x2="195" y2="168" stroke="#333" stroke-width="2" />
  <line x1="335" y1="105" x2="445" y2="168" stroke="#333" stroke-width="2" />

  <line x1="170" y1="213" x2="120" y2="288" stroke="#333" stroke-width="2" />
  <line x1="190" y1="213" x2="245" y2="288" stroke="#333" stroke-width="2" />

  <line x1="450" y1="213" x2="395" y2="288" stroke="#333" stroke-width="2" />
  <line x1="470" y1="213" x2="525" y2="288" stroke="#333" stroke-width="2" />

  <text x="235" y="140" font-size="12" fill="#555">∂z/∂x</text>
  <text x="400" y="140" font-size="12" fill="#555">∂z/∂y</text>
  <text x="115" y="250" font-size="12" fill="#555">∂x/∂s</text>
  <text x="230" y="250" font-size="12" fill="#555">∂x/∂t</text>
  <text x="400" y="250" font-size="12" fill="#555">∂y/∂s</text>
  <text x="500" y="250" font-size="12" fill="#555">∂y/∂t</text>

  <text x="320" y="355" text-anchor="middle" font-size="13" fill="#777">Sum all root-to-leaf products sharing the same bottom variable</text>
</svg>

### Vector Form: The Jacobian Formulation

For vector-valued functions, the chain rule is expressed compactly using Jacobian matrices. If $\mathbf{z} = f(\mathbf{y})$ and $\mathbf{y} = g(\mathbf{x})$, where $\mathbf{x} \in \mathbb{R}^n$, $\mathbf{y} \in \mathbb{R}^m$, $\mathbf{z} \in \mathbb{R}^k$, then:

$$J_{z}(x) = J_{z}(y) \cdot J_{y}(x)$$

where $J_z(x)$ is the $k \times n$ Jacobian of $z$ with respect to $x$, obtained by multiplying the $k \times m$ Jacobian of $z$ with respect to $y$ by the $m \times n$ Jacobian of $y$ with respect to $x$.

This matrix formulation is the mathematical backbone of backpropagation in neural networks, where each layer's transformation contributes one Jacobian factor to the overall gradient computation.

### Worked Example

Let $z = x^2 y + y^3$, where $x = t^2$ and $y = \sin(t)$. Find $\frac{dz}{dt}$.

**Step 1 — Compute partial derivatives of $z$:**

$$\frac{\partial z}{\partial x} = 2xy, \quad \frac{\partial z}{\partial y} = x^2 + 3y^2$$

**Step 2 — Compute derivatives of intermediate variables:**

$$\frac{dx}{dt} = 2t, \quad \frac{dy}{dt} = \cos(t)$$

**Step 3 — Apply the chain rule:**

$$\frac{dz}{dt} = (2xy)(2t) + (x^2 + 3y^2)(\cos t)$$

**Step 4 — Substitute back $x = t^2$, $y = \sin t$:**

$$\frac{dz}{dt} = 4t^3 \sin t + (t^4 + 3\sin^2 t)\cos t$$

This final expression is fully in terms of $t$.

### Relevance to Machine Learning: Backpropagation

In a neural network, the loss $L$ depends on the output layer, which depends on the previous layer's weights and activations, which depend on the layer before that, and so on back to the input. The multivariable chain rule is applied repeatedly to compute:

$$\frac{\partial L}{\partial w_{ij}^{(l)}} = \frac{\partial L}{\partial a^{(L)}} \cdot \frac{\partial a^{(L)}}{\partial a^{(L-1)}} \cdots \frac{\partial a^{(l)}}{\partial w_{ij}^{(l)}}$}$$

Each factor corresponds to one layer's local Jacobian or gradient, and the full gradient is the product of these factors — precisely mirroring the tree-diagram summation shown above.

[Inference] Frameworks such as PyTorch and TensorFlow implement this via automatic differentiation, which programmatically applies the chain rule at each computational graph node rather than deriving a symbolic closed-form expression. Exact internal implementation details vary by framework version and are not covered here.

### Common Pitfalls

- Forgetting to sum over **all** paths when a variable influences the output through more than one intermediate variable
- Confusing partial derivatives ($\partial$) with total/ordinary derivatives ($d$) — the distinction matters when some variables are held constant versus when everything ultimately depends on a single parameter
- Misordering matrix multiplication in the Jacobian chain rule; matrix multiplication is not commutative, so $J_z(y) \cdot J_y(x) \neq J_y(x) \cdot J_z(y)$ in general

### Key Points

- The multivariable chain rule sums contributions across every dependency path from output to input variable
- The vector/Jacobian form generalizes this to functions between spaces of arbitrary dimension
- This rule is the direct mathematical basis for backpropagation in neural networks
- Careful bookkeeping of which variables are held constant is essential for correct differentiation

**Related Topics**
- Jacobian Matrices and Their Role in Vector Calculus
- Backpropagation Derived from First Principles
- Computational Graphs and Automatic Differentiation
- Gradient Descent and the Role of Partial Derivatives
- Hessian Matrices and Second-Order Chain Rule Extensions