## Newton's Method for Root Finding

### Definition

Newton's method (also called the Newton–Raphson method) is an iterative numerical technique for approximating roots of a function $f(x) = 0$, using the function's derivative to generate successively better approximations.

### Core Principle

Starting from an initial guess $x_0$, the method generates a sequence of approximations using the update rule:

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

This formula comes from approximating $f$ near $x_n$ using its tangent line and finding where that tangent line crosses the x-axis.

**Derivation:** The tangent line at $x_n$ is:
$$y - f(x_n) = f'(x_n)(x - x_n)$$

Setting $y = 0$ and solving for $x$ gives the next approximation $x_{n+1}$:
$$0 - f(x_n) = f'(x_n)(x - x_n) \implies x = x_n - \frac{f(x_n)}{f'(x_n)}$$

### Procedure

1. **Choose an initial guess** $x_0$ reasonably close to the suspected root.
2. **Compute** $f(x_n)$ and $f'(x_n)$.
3. **Apply the update rule** to get $x_{n+1}$.
4. **Repeat** until a stopping criterion is met (e.g., $|x_{n+1} - x_n| < \varepsilon$ for some small tolerance $\varepsilon$, or $|f(x_n)|$ is sufficiently small).
5. **Check** $f'(x_n) \neq 0$ at each step, since the method is undefined if the derivative is zero at an iterate.

### Newton's Method Iteration Diagram (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Newton's Method: Tangent Line Iteration (svg_diagram)</text>

  <line x1="60" y1="270" x2="640" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="270" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="640" y="290" font-size="12" fill="#555">x</text>
  <text x="45" y="50" font-size="12" fill="#555">y</text>

  <path d="M 150 60 C 250 150, 350 220, 550 260" fill="none" stroke="#1a4fa3" stroke-width="3" />

  <circle cx="480" cy="270" r="5" fill="#1a1a1a" />
  <text x="480" y="290" font-size="12" text-anchor="middle" fill="#1a1a1a">x₀</text>
  <line x1="480" y1="270" x2="480" y2="245" stroke="#999" stroke-width="1" />
  <circle cx="480" cy="245" r="5" fill="#b30000" />

  <line x1="300" y1="270" x2="600" y2="215" stroke="#0a6b0a" stroke-width="2" />
  <text x="600" y="205" font-size="12" fill="#0a6b0a">tangent at x₀</text>

  <circle cx="370" cy="270" r="5" fill="#1a1a1a" />
  <text x="370" y="290" font-size="12" text-anchor="middle" fill="#1a1a1a">x₁</text>
  <line x1="370" y1="270" x2="370" y2="243" stroke="#999" stroke-width="1" />
  <circle cx="370" cy="243" r="5" fill="#b30000" />

  <line x1="280" y1="270" x2="430" y2="200" stroke="#7a3fbf" stroke-width="2" />
  <text x="430" y="190" font-size="12" fill="#7a3fbf">tangent at x₁</text>

  <circle cx="320" cy="270" r="5" fill="#1a1a1a" />
  <text x="320" y="290" font-size="12" text-anchor="middle" fill="#1a1a1a">x₂</text>

  <text x="320" y="250" font-size="11" fill="#555">→ converging toward root</text>
</svg>

### Worked Example

Find a root of $f(x) = x^2 - 2$ (approximating $\sqrt{2}$) using $x_0 = 1$.

**Step 1 — Derivative:**
$$f'(x) = 2x$$

**Step 2 — Update formula:**
$$x_{n+1} = x_n - \frac{x_n^2 - 2}{2x_n}$$

**Iteration 1:**
$$x_1 = 1 - \frac{1^2 - 2}{2(1)} = 1 - \frac{-1}{2} = 1.5$$

**Iteration 2:**
$$x_2 = 1.5 - \frac{1.5^2 - 2}{2(1.5)} = 1.5 - \frac{0.25}{3} = 1.5 - 0.08333... = 1.41667$$

**Iteration 3:**
$$x_3 = 1.41667 - \frac{1.41667^2 - 2}{2(1.41667)} = 1.41667 - \frac{0.00694}{2.83333} \approx 1.41422$$

| Iteration | $x_n$ | $f(x_n)$ |
|---|---|---|
| 0 | 1.00000 | −1.00000 |
| 1 | 1.50000 | 0.25000 |
| 2 | 1.41667 | 0.00694 |
| 3 | 1.41422 | ≈0.00001 |

The true value $\sqrt{2} \approx 1.41421356$. The sequence is converging rapidly toward this value in this example. [Unverified] Whether this convergence rate generalizes to other functions cannot be confirmed without analysis specific to each function; convergence behavior depends on the function's properties near the root.

### Convergence Behavior

Newton's method exhibits quadratic convergence near a simple root, under certain conditions (the function must be sufficiently smooth, and $f'$ must be nonzero at the root). [Inference] This is a general mathematical property described in numerical analysis theory, not a claim verified against a specific implementation in this response.

**Known failure modes** [Inference] — these are documented behaviors in numerical analysis theory, not guarantees about any specific software:
- If $f'(x_n) = 0$ at some iterate, the method is undefined at that step (division by zero).
- Poor initial guesses can cause the sequence to diverge or oscillate rather than converge.
- Near inflection points or flat regions, the method can behave unpredictably, sometimes jumping far from the root.
- Multiple roots (where $f'(x) = 0$ at the root itself) reduce the convergence rate from quadratic to linear. [Inference]

I cannot verify the exact convergence behavior for an arbitrary unspecified function without analyzing that specific function directly.

### Relevance to Machine Learning

[Inference] Newton's method is conceptually related to second-order optimization methods used in some machine learning contexts, though its direct application to ML has notable limitations.

- The multivariable generalization of Newton's method uses the Hessian matrix instead of a scalar second derivative, and the gradient instead of $f'(x)$: $\theta_{n+1} = \theta_n - H^{-1} \nabla L(\theta_n)$. [Inference] This is a standard formulation described in numerical optimization theory.
- [Unverified] Whether any specific ML training pipeline or framework uses this exact Newton's method formulation for parameter updates cannot be confirmed without inspecting that specific system; I do not have access to verify implementation details of particular libraries here.
- [Speculation] Computing and inverting the Hessian matrix for large neural networks is often considered computationally expensive relative to first-order methods like gradient descent, which may be a reason quasi-Newton methods (e.g., BFGS, L-BFGS) or first-order methods are more commonly discussed in deep learning contexts. This is a plausibility-based statement and not a confirmed claim about any specific system's design rationale.
- [Speculation] Root-finding via Newton's method is distinct from loss-minimization optimization, though the underlying tangent-line/quadratic-approximation logic is related; whether this distinction is explicitly taught alongside gradient descent in a specific curriculum cannot be confirmed.

### Limitations

- Newton's method does not guarantee convergence for all functions or initial guesses; behavior depends on the specific function and starting point. [Inference]
- The method requires $f$ to be differentiable, and computing $f'(x)$ analytically or numerically at each step, which may not always be feasible or efficient. [Unverified] Feasibility depends on the specific function and computational context, which this response cannot verify in general.
- This response does not verify convergence behavior for any function other than the single worked example shown; behavior for other functions requires separate analysis. [Unverified]

### Key Points

- Newton's method iteratively approximates roots using $x_{n+1} = x_n - f(x_n)/f'(x_n)$.
- Convergence is not guaranteed in all cases; it depends on the function's smoothness, the initial guess, and whether $f'(x_n) \neq 0$ throughout. [Inference]
- The multivariable generalization using the Hessian matrix is conceptually related to some second-order optimization methods discussed in ML theory. [Inference]
- [Unverified] This response does not confirm whether any specific ML framework or library implements this method in the exact form described.

**Related Topics**
- Quasi-Newton methods (BFGS, L-BFGS)
- Hessian matrix and multivariable Newton's method
- Fixed-point iteration methods
- Convergence rates in numerical methods (linear vs. quadratic)
- Gradient descent and first-order optimization
- Taylor series approximation