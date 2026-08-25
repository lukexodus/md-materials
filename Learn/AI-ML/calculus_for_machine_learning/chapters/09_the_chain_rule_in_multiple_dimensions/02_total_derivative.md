## The Total Derivative

### Overview

The total derivative captures the complete rate of change of a multivariable function when all of its input variables are allowed to change simultaneously, each along a specified direction or path. It differs from a partial derivative, which measures change with respect to only one variable while holding the others fixed. The total derivative accounts for every channel through which change can propagate into the output.

### Definition

For a function $z = f(x, y)$ where both $x$ and $y$ depend on a variable $t$, the total derivative with respect to $t$ is:

$$\frac{dz}{dt} = \frac{\partial z}{\partial x} \frac{dx}{dt} + \frac{\partial z}{\partial y} \frac{dy}{dt}$$

More generally, for $f(x_1, x_2, \dots, x_n)$ with each $x_i$ depending on $t$:

$$\frac{df}{dt} = \sum_{i=1}^{n} \frac{\partial f}{\partial x_i} \frac{dx_i}{dt}$$

This is a direct application of the multivariable chain rule, summing the contribution of each variable's rate of change weighted by how sensitive $f$ is to that variable.

### Total Differential

Closely related is the **total differential**, which expresses the infinitesimal change in $f$ due to infinitesimal changes in each input variable, without reference to a specific parameter $t$:

$$df = \frac{\partial f}{\partial x} dx + \frac{\partial f}{\partial y} dy$$

For $n$ variables:

$$df = \sum_{i=1}^{n} \frac{\partial f}{\partial x_i} dx_i$$

The total differential is the linear approximation of the change in $f$ for small changes $dx_i$ in each input, and it forms the basis of first-order Taylor expansions in multiple dimensions.

### Total Derivative vs. Partial Derivative

| Aspect | Partial Derivative | Total Derivative |
|---|---|---|
| Variables varied | One, others held fixed | All, according to their dependencies |
| Notation | $\partial f / \partial x$ | $df/dt$ or $df$ |
| Captures indirect effects | No | Yes |
| Typical use | Sensitivity analysis along one axis | Rate of change along a path or trajectory |

A key distinction: if $x$ and $y$ are both functions of $t$, then $\partial z/\partial x$ only measures direct sensitivity of $z$ to $x$, while $dz/dt$ measures the full downstream effect, including how $x$ and $y$ jointly evolve with $t$.

### Geometric Interpretation

The total differential $df$ represents the value of the best linear approximation to $f$ at a point, given a small displacement vector $(dx, dy, \dots)$. This is equivalent to the dot product between the gradient of $f$ and the displacement vector:

$$df = \nabla f \cdot d\mathbf{x}$$

where $\nabla f = \left( \frac{\partial f}{\partial x_1}, \dots, \frac{\partial f}{\partial x_n} \right)$ and $d\mathbf{x} = (dx_1, \dots, dx_n)$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 340">
  <text x="300" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Total Differential as Linear Approximation (svg_diagram)</text>

  <line x1="60" y1="280" x2="560" y2="280" stroke="#999" stroke-width="1.5" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#999" stroke-width="1.5" />
  <text x="565" y="285" font-size="12" fill="#666">x</text>
  <text x="45" y="60" font-size="12" fill="#666">f(x)</text>

  <path d="M 80 260 Q 250 90 520 130" stroke="#4A90D9" stroke-width="2.5" fill="none" />

  <circle cx="300" cy="170" r="5" fill="#222" />
  <text x="300" y="160" font-size="12" fill="#222" text-anchor="middle">point (x₀, f(x₀))</text>

  <line x1="220" y1="230" x2="400" y2="120" stroke="#E8622C" stroke-width="2" stroke-dasharray="5,3" />
  <text x="410" y="115" font-size="12" fill="#E8622C">tangent line: df = f'(x₀)dx</text>

  <line x1="300" y1="170" x2="360" y2="170" stroke="#7FB77E" stroke-width="2" />
  <line x1="360" y1="170" x2="360" y2="135" stroke="#7FB77E" stroke-width="2" />
  <text x="320" y="185" font-size="11" fill="#7FB77E">dx</text>
  <text x="368" y="155" font-size="11" fill="#7FB77E">df</text>
</svg>

### Total Derivative Along a Parametrized Path

If a point moves through space along a path $\mathbf{r}(t) = (x(t), y(t), z(t))$, and $f$ is a scalar field, the total derivative of $f$ along this path is:

$$\frac{df}{dt} = \nabla f \big( \mathbf{r}(t) \big) \cdot \mathbf{r}'(t)$$

This expresses the rate of change of $f$ as observed by someone moving along the path — combining the gradient of $f$ (direction of steepest increase) with the velocity vector of the path.

### Worked Example

Let $f(x, y) = x^2 y + \ln(y)$, with $x(t) = e^t$ and $y(t) = t^2 + 1$. Find $\dfrac{df}{dt}$ at $t = 0$.

**Step 1 — Partial derivatives of $f$:**

$$\frac{\partial f}{\partial x} = 2xy, \qquad \frac{\partial f}{\partial y} = x^2 + \frac{1}{y}$$

**Step 2 — Derivatives of the parametrized inputs:**

$$\frac{dx}{dt} = e^t, \qquad \frac{dy}{dt} = 2t$$

**Step 3 — Apply the total derivative formula:**

$$\frac{df}{dt} = (2xy)(e^t) + \left(x^2 + \frac{1}{y}\right)(2t)$$

**Step 4 — Evaluate at $t = 0$:** $x(0) = 1$, $y(0) = 1$

$$\frac{df}{dt}\Big|_{t=0} = (2 \cdot 1 \cdot 1)(1) + \left(1 + 1\right)(0) = 2$$

### Relevance to Machine Learning

In gradient-based optimization, model parameters are often updated along a trajectory defined by an optimizer (e.g., gradient descent, momentum-based methods). The total derivative formalism describes how the loss changes as **all** parameters move together during an update step, rather than analyzing each parameter's partial contribution in isolation.

[Inference] In automatic differentiation frameworks, the computation of gradients used for backpropagation is conceptually structured around repeated application of total-derivative-style accumulation across a computational graph. This is a reasoned connection based on how the chain rule generalizes to computational graphs, not a confirmed description of any specific framework's internal source code. I do not have access to verified implementation details of any particular library's internals, so this should be treated as [Inference] rather than a factual claim about software behavior, and behavior may vary across frameworks and versions.

### Common Pitfalls

- Treating $\partial f/\partial x$ as equivalent to $df/dt$ when $x$ is not the only variable changing with $t$
- Omitting a term in the sum when a variable indirectly affects $f$ through more than one path
- Confusing the total differential (an approximation) with the exact change $\Delta f$, which is only equal to $df$ in the limit as the displacement approaches zero

### Key Points

- The total derivative sums the effects of every variable's dependence on a single parameter, weighted by partial derivatives
- The total differential $df$ is the linear approximation of change and equals $\nabla f \cdot d\mathbf{x}$
- Partial derivatives isolate one variable's direct effect; total derivatives capture the full, compounded effect
- This concept underlies how loss functions are analyzed as all parameters shift together during optimization

**Related Topics**
- Gradient Vectors and Directional Derivatives
- Taylor Series Expansion in Multiple Variables
- Jacobian Matrices and Their Role in Vector Calculus
- Implicit Differentiation for Multivariable Systems
- Computational Graphs and Automatic Differentiation