## Linear Approximation and Differentials

### Definition of Linear Approximation

Linear approximation (also called the **tangent line approximation** or **linearization**) uses the tangent line to a function at a point to approximate the function's values near that point. For a differentiable function $f$ at $x = a$, the linear approximation is:

$$L(x) = f(a) + f'(a)(x - a)$$

For values of $x$ close to $a$, $f(x) \approx L(x)$.

### Key Points

- Linear approximation relies on the fact that, near a point of differentiability, a smooth function closely resembles its tangent line — this is the geometric essence of differentiability itself.
- The approximation error grows as $x$ moves farther from $a$, and is generally most accurate for small deviations $x - a$.
- In machine learning, linear approximation is the conceptual foundation of **gradient descent**, where each optimization step relies on a local linear (first-order) model of the loss function.

### Differentials

Closely related to linear approximation is the concept of a **differential**. Given $y = f(x)$, the differential $dy$ is defined as:

$$dy = f'(x)\,dx$$

where $dx$ represents a small change in $x$. The differential $dy$ approximates the actual change in the function, $\Delta y = f(x + dx) - f(x)$, for small $dx$:

$$\Delta y \approx dy = f'(x)\,dx$$

### Geometric Interpretation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 320">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Linear Approximation via Tangent Line (svg_diagram)</text>

  <line x1="40" y1="270" x2="480" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="50" x2="80" y2="270" stroke="#333" stroke-width="1.5" />

  
  <path d="M 100,250 Q 250,60 420,110" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="380" y="95" font-size="12" fill="#2563eb">f(x)</text>

  
  <circle cx="260" cy="120" r="6" fill="#dc2626" />
  <text x="230" y="105" font-size="11" fill="#dc2626">(a, f(a))</text>

  
  <line x1="150" y1="220" x2="370" y2="60" stroke="#059669" stroke-width="2" stroke-dasharray="6,3" />
  <text x="375" y="55" font-size="11" fill="#065f46">L(x) = f(a) + f'(a)(x−a)</text>

  
  <line x1="260" y1="120" x2="330" y2="120" stroke="#d97706" stroke-width="1.5" />
  <line x1="330" y1="120" x2="330" y2="80" stroke="#d97706" stroke-width="1.5" />
  <text x="285" y="135" font-size="11" fill="#92400e">dx</text>
  <text x="340" y="100" font-size="11" fill="#92400e">dy</text>

  <text x="260" y="300" font-size="12" text-anchor="middle" fill="#555">Near x = a, the tangent line closely tracks f(x)</text>
</svg>

### Worked Examples

**Example 1:**

Approximate $\sqrt{4.1}$ using linear approximation.

Let $f(x) = \sqrt{x}$, $a = 4$ (a nearby point where the value is easy to compute).

$$f(a) = \sqrt{4} = 2, \qquad f'(x) = \frac{1}{2\sqrt{x}} \implies f'(4) = \frac{1}{4}$$

$$L(x) = 2 + \frac{1}{4}(x - 4)$$

$$L(4.1) = 2 + \frac{1}{4}(0.1) = 2 + 0.025 = 2.025$$

The actual value is $\sqrt{4.1} \approx 2.0248$, confirming the approximation is accurate to within a small error for this nearby point. [Fact — this specific numerical comparison can be verified by direct computation.]

**Example 2: Using Differentials for Error Estimation**

If a measured quantity $x = 10$ has a possible measurement error of $dx = 0.2$, estimate the resulting error in $f(x) = x^3$.

$$f'(x) = 3x^2 \implies f'(10) = 300$$

$$dy = f'(10)\,dx = 300 \times 0.2 = 60$$

This suggests that a small measurement error of $0.2$ in $x$ could result in an approximate error of $60$ in $f(x)$ near $x=10$ — illustrating how differentials are used to propagate uncertainty through a function.

**Example 3:**

Approximate $\sin(0.05)$ using linear approximation at $a = 0$.

$$f(x) = \sin x, \quad f(0) = 0, \quad f'(x) = \cos x \implies f'(0) = 1$$

$$L(x) = 0 + 1 \cdot (x - 0) = x$$

$$L(0.05) = 0.05$$

This is the basis of the common **small-angle approximation** $\sin\theta \approx \theta$ for small $\theta$ measured in radians.

### Connection to Gradient Descent

Gradient descent updates parameters using a first-order (linear) approximation of the loss function around the current point. Given a loss function $\mathcal{L}(\theta)$, the linear approximation near the current parameters $\theta_t$ is:

$$\mathcal{L}(\theta_t + \Delta\theta) \approx \mathcal{L}(\theta_t) + \nabla\mathcal{L}(\theta_t)^\top \Delta\theta$$

Gradient descent chooses $\Delta\theta = -\eta \nabla\mathcal{L}(\theta_t)$ (a step in the negative gradient direction scaled by learning rate $\eta$), which is the direction that decreases this linear approximation most rapidly for a small step size. [Fact] This is the standard justification for why the negative gradient direction is used, based on directional derivatives and the linear (first-order) approximation of the loss surface.

$$\theta_{t+1} = \theta_t - \eta \nabla\mathcal{L}(\theta_t)$$

### Why Linear Approximation Underlies Gradient Descent

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Linear Approximation in a Gradient Step (svg_diagram)</text>

  <line x1="40" y1="250" x2="480" y2="250" stroke="#333" stroke-width="1.5" />

  
  <path d="M 80,100 Q 260,260 440,110" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="360" y="100" font-size="12" fill="#2563eb">Loss surface L(θ)</text>

  
  <circle cx="150" cy="150" r="6" fill="#dc2626" />
  <text x="100" y="135" font-size="11" fill="#dc2626">θ_t</text>

  
  <line x1="90" y1="200" x2="260" y2="90" stroke="#059669" stroke-width="2" stroke-dasharray="6,3" />
  <text x="200" y="85" font-size="11" fill="#065f46">Local linear approx</text>

  
  <line x1="150" y1="150" x2="230" y2="220" stroke="#d97706" stroke-width="2" marker-end="url(#arrowD)" />
  <text x="235" y="225" font-size="11" fill="#92400e">step: −η∇L(θ_t)</text>

  <text x="260" y="285" font-size="12" text-anchor="middle" fill="#555">Each gradient step trusts the local linear approximation</text>
</svg>

### Relevance to Machine Learning

- **Gradient descent as repeated linearization:** As shown above, every gradient descent step relies on a first-order Taylor (linear) approximation of the loss function around the current parameters, making linear approximation the conceptual core of the entire optimization procedure.
- **Learning rate sensitivity:** [Inference] Because the linear approximation is only accurate near the current point, taking too large a step (too high a learning rate) can move parameters into a region where the linear approximation no longer holds well, potentially causing the loss to increase rather than decrease; this is a commonly cited intuition for why learning rate selection affects training stability, though actual optimizer behavior also depends on curvature, momentum terms, and other algorithmic details.
- **Sensitivity analysis and error propagation:** Differentials are used conceptually to understand how small changes or perturbations in inputs (or parameters) propagate to changes in outputs, which is relevant to robustness analysis and understanding model sensitivity to input noise.
- **First-order Taylor expansion in optimization theory:** Linear approximation is mathematically equivalent to truncating a Taylor series after the first-order term; this concept extends to second-order methods (like Newton's method) that additionally incorporate curvature information for more accurate local models.
- **Jacobian-based local approximations:** [Inference] In multivariable settings, the same linear approximation idea generalizes using the Jacobian matrix to locally approximate how a vector-valued function changes with respect to multiple inputs simultaneously, which is relevant to understanding how small perturbations propagate through layers of a neural network.

### Common Pitfalls

- **Using linear approximation far from the reference point:** Since the tangent line only closely matches the function near $a$, applying $L(x)$ far from $a$ can produce significant errors; the approximation degrades as $|x - a|$ increases.
- **Confusing $\Delta y$ with $dy$:** $\Delta y$ is the actual change in the function's value, while $dy$ is only its linear approximation; these are equal only in the limit as $dx \to 0$, not for finite $dx$.
- **Forgetting to evaluate the derivative at the reference point, not at $x$:** A common error is writing $f'(x)$ instead of $f'(a)$ in the linearization formula.
- **Assuming linear approximation always underestimates or overestimates:** Whether $L(x)$ overestimates or underestimates $f(x)$ depends on the concavity of $f$ near $a$ (related to the sign of $f''(a)$), and is not a fixed universal pattern.

### Conclusion

Linear approximation uses the tangent line at a point to estimate nearby function values, and differentials formalize this idea by relating small input changes ($dx$) to approximate output changes ($dy = f'(x)\,dx$). This concept is far more than a computational shortcut in machine learning — it is the exact mathematical justification for gradient descent, where every optimization step is fundamentally a decision made using a local, first-order linear model of the loss surface.

**Related Topics**
- Gradient descent and first-order optimization methods
- Taylor series and higher-order approximations
- The Jacobian matrix and multivariable linear approximations
- Newton's method and second-order optimization
- Sensitivity analysis and error propagation in models
- Learning rate selection and convergence behavior