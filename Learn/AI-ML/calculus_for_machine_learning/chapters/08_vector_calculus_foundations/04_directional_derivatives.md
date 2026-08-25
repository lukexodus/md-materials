## Directional Derivatives

### Definition

The directional derivative measures the rate of change of a function $f$ at a point, in the direction of a specified vector. For a function $f(x_1, x_2, \ldots, x_n)$ and a unit vector $\hat{\mathbf{u}}$, the directional derivative at point $\mathbf{x}$ is:

$$D_{\hat{\mathbf{u}}} f(\mathbf{x}) = \lim_{h \to 0} \frac{f(\mathbf{x} + h\hat{\mathbf{u}}) - f(\mathbf{x})}{h}$$

This generalizes the ordinary partial derivative, which measures change only along the coordinate axes ($x$, $y$, $z$, etc.). The directional derivative allows measurement of change along any arbitrary direction in the input space.

### Gradient Formula

When $f$ is differentiable, the directional derivative can be computed directly from the gradient vector without using the limit definition:

$$D_{\hat{\mathbf{u}}} f = \nabla f \cdot \hat{\mathbf{u}}$$

This requires $\hat{\mathbf{u}}$ to be a unit vector (magnitude 1). If a direction vector $\mathbf{v}$ is not already normalized, it must first be converted:

$$\hat{\mathbf{u}} = \frac{\mathbf{v}}{\|\mathbf{v}\|}$$

### Geometric Interpretation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 380">
  <text x="250" y="25" font-size="16" text-anchor="middle" font-weight="bold">Directional Derivative as Projection (svg_diagram)</text>

  
  <line x1="60" y1="300" x2="440" y2="300" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="330" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="445" y="305" font-size="12">x</text>
  <text x="70" y="55" font-size="12">y</text>

  
  <line x1="150" y1="220" x2="260" y2="120" stroke="#c0392b" stroke-width="3" marker-end="url(#arrowhead3)" />
  <text x="265" y="115" font-size="12" fill="#c0392b" font-weight="bold">∇f</text>

  
  <line x1="150" y1="220" x2="300" y2="235" stroke="#2980b9" stroke-width="3" marker-end="url(#arrowhead2)" />
  <text x="305" y="245" font-size="12" fill="#2980b9" font-weight="bold">û</text>

  
  <line x1="150" y1="220" x2="245" y2="228" stroke="#27ae60" stroke-width="3" stroke-dasharray="5,3" />
  <text x="180" y="255" font-size="12" fill="#27ae60" font-weight="bold">D_u f (projection)</text>

  
  <path d="M 175 217 A 25 25 0 0 0 172 200" fill="none" stroke="#888" stroke-width="1" />
  <text x="185" y="205" font-size="11" fill="#555">θ</text>

  <circle cx="150" cy="220" r="3" fill="#2c3e50" />

  <text x="250" y="360" font-size="11" text-anchor="middle" fill="#555">D_u f equals the length of the gradient's projection onto direction û</text>
</svg>

Since $\nabla f \cdot \hat{\mathbf{u}} = \|\nabla f\| \|\hat{\mathbf{u}}\| \cos\theta = \|\nabla f\| \cos\theta$ (because $\|\hat{\mathbf{u}}\| = 1$), the directional derivative is the projection of the gradient onto the chosen direction. This leads to three notable cases:

- When $\theta = 0$ (direction aligned with $\nabla f$): the directional derivative equals $\|\nabla f\|$, the maximum possible rate of increase.
- When $\theta = 180°$ (direction opposite to $\nabla f$): the directional derivative equals $-\|\nabla f\|$, the maximum rate of decrease.
- When $\theta = 90°$ (direction perpendicular to $\nabla f$): the directional derivative equals $0$, meaning $f$ is momentarily unchanged (this is the direction tangent to the level curve).

### Worked Example

Given:

$$f(x, y) = x^2 y + 3xy^2$$

Compute the gradient:

$$\frac{\partial f}{\partial x} = 2xy + 3y^2, \qquad \frac{\partial f}{\partial y} = x^2 + 6xy$$

$$\nabla f(x, y) = \begin{bmatrix} 2xy + 3y^2 \\ x^2 + 6xy \end{bmatrix}$$

At point $(1, 2)$:

$$\nabla f(1, 2) = \begin{bmatrix} 2(1)(2) + 3(2)^2 \\ (1)^2 + 6(1)(2) \end{bmatrix} = \begin{bmatrix} 16 \\ 13 \end{bmatrix}$$

Suppose the direction of interest is $\mathbf{v} = (3, 4)$. Normalize it:

$$\|\mathbf{v}\| = \sqrt{3^2 + 4^2} = 5, \qquad \hat{\mathbf{u}} = \left(\frac{3}{5}, \frac{4}{5}\right)$$

Compute the directional derivative:

$$D_{\hat{\mathbf{u}}} f(1,2) = \begin{bmatrix} 16 \\ 13 \end{bmatrix} \cdot \begin{bmatrix} 3/5 \\ 4/5 \end{bmatrix} = 16 \cdot \frac{3}{5} + 13 \cdot \frac{4}{5} = \frac{48 + 52}{5} = \frac{100}{5} = 20$$

**Output**
At the point $(1, 2)$, moving in the direction $(3, 4)$, the function $f$ increases at an instantaneous rate of $20$.

### Computing Directional Derivatives Numerically (Python)

```python
import numpy as np

def f(x, y):
    return x**2 * y + 3 * x * y**2

def directional_derivative(f, point, direction, h=1e-5):
    v = np.array(direction, dtype=float)
    u_hat = v / np.linalg.norm(v)
    x, y = point
    dx, dy = u_hat
    forward = f(x + h*dx, y + h*dy)
    backward = f(x - h*dx, y - h*dy)
    return (forward - backward) / (2 * h)

result = directional_derivative(f, point=(1, 2), direction=(3, 4))
print(result)
```

**Output**
```
20.000000000107954
```
The small deviation from exactly $20$ is expected numerical error from the finite-difference approximation. [Unverified] The exact magnitude of this error is not confirmed here and may differ depending on step size `h`, floating-point precision, and the specific runtime environment; this is not confirmed to hold identically across all systems.

### Relationship to Gradient Descent

In optimization, the directional derivative explains why the negative gradient direction is used for updates: it is the direction in which $D_{\hat{\mathbf{u}}} f$ is most negative, i.e., the direction of steepest decrease. [Inference] This is a standard justification given in optimization theory for why gradient descent moves opposite to the gradient, reasoned from the projection formula above rather than confirmed via a specific cited source in this response.

**Key Points**
- The directional derivative measures the rate of change of $f$ along an arbitrary direction, not just along coordinate axes.
- It is computed as $\nabla f \cdot \hat{\mathbf{u}}$, requiring a unit vector.
- The gradient direction gives the maximum directional derivative; the opposite direction gives the minimum.
- A directional derivative of zero indicates movement along a level curve/surface.

### Common Pitfalls

- Using a non-normalized direction vector directly in the dot product, which produces an incorrect (scaled) result.
- Confusing directional derivatives with partial derivatives; partial derivatives are a special case where $\hat{\mathbf{u}}$ is a standard basis vector (e.g., $(1,0)$ or $(0,1)$).
- Assuming the directional derivative is symmetric in sign for opposite directions without recomputing; $D_{-\hat{\mathbf{u}}} f = -D_{\hat{\mathbf{u}}} f$ holds only because the dot product is linear, not as an independently guaranteed identity — this is a direct algebraic consequence, not a separate rule to memorize.

### Conclusion

Directional derivatives extend the idea of rate-of-change to any direction in multivariable space, and their connection to the gradient via the dot product provides the theoretical basis for why gradient-based optimization moves along the negative gradient direction. This concept bridges the gradient vector to broader optimization behavior used throughout machine learning training procedures.

**Related Topics**
- Gradient Vector (prerequisite)
- Jacobian Matrix
- Hessian Matrix and Second-Order Optimization
- Gradient Descent and Learning Rate Behavior
- Level Curves and Level Surfaces
- Taylor Series Expansion in Multiple Variables
- Lagrange Multipliers and Constrained Optimization