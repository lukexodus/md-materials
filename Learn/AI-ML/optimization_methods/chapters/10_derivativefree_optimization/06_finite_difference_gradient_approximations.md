## Finite Difference Gradient Approximations

### Overview

Finite difference methods approximate derivatives of a function $f: \mathbb{R}^n \to \mathbb{R}$ using only function evaluations, by exploiting Taylor series expansions. Unlike the derivative-free methods discussed previously (Nelder-Mead, pattern search, model-based trust region DFO), finite differences are not themselves optimization algorithms — they are a technique for *estimating* gradients (and Hessians) so that standard gradient-based optimization methods (steepest descent, Newton, quasi-Newton, trust region) can be applied when analytic derivatives are unavailable but the function is otherwise smooth and reasonably cheap to evaluate. This section covers the mathematical basis, accuracy trade-offs, and practical role of finite differences as a bridge between black-box evaluation and gradient-based optimization.

### Forward Difference Approximation

**Key Points**

The simplest approximation to a partial derivative uses a first-order Taylor expansion:

$$f(x + h e_i) = f(x) + h \frac{\partial f}{\partial x_i}(x) + \frac{h^2}{2} \frac{\partial^2 f}{\partial x_i^2}(\xi) + O(h^3)$$

for some $\xi$ between $x$ and $x + h e_i$. Rearranging gives the **forward difference** formula:

$$\frac{\partial f}{\partial x_i}(x) \approx \frac{f(x + h e_i) - f(x)}{h}$$

- **Truncation error**: $O(h)$ — the approximation error from truncating the Taylor series scales linearly with the step size $h$.
- **Cost**: requires $n+1$ function evaluations total to estimate the full gradient (one evaluation at $x$, reused across all $n$ directions, plus one perturbed evaluation per coordinate).

### Central Difference Approximation

Using both a forward and backward Taylor expansion and subtracting:

$$f(x + h e_i) - f(x - h e_i) = 2h \frac{\partial f}{\partial x_i}(x) + \frac{h^3}{3} \frac{\partial^3 f}{\partial x_i^3}(\xi) + O(h^5)$$

giving the **central difference** formula:

$$\frac{\partial f}{\partial x_i}(x) \approx \frac{f(x + h e_i) - f(x - h e_i)}{2h}$$

- **Truncation error**: $O(h^2)$ — quadratically smaller than forward differences for the same $h$, since the odd-order term cancels in the subtraction.
- **Cost**: requires $2n$ function evaluations (two perturbed evaluations per coordinate; the value at $x$ itself is not needed for this formula).
- The improved accuracy comes at roughly double the evaluation cost relative to forward differences.

### The Fundamental Trade-off: Truncation vs. Roundoff Error

**Key Points**

This is the central practical challenge in finite differences and the reason step size selection is non-trivial.

- **Truncation error** decreases as $h \to 0$ (forward: $O(h)$; central: $O(h^2)$) — smaller steps better approximate the true infinitesimal derivative, in exact arithmetic.
- **Roundoff error** increases as $h \to 0$, because $f(x+h)$ and $f(x)$ become numerically close in floating-point representation, and subtracting two nearly equal finite-precision numbers amplifies relative floating-point error (catastrophic cancellation). This roundoff error scales roughly as $O(\epsilon_{\text{mach}} / h)$, where $\epsilon_{\text{mach}}$ is machine epsilon (unit roundoff).
- Total error is approximately the sum of both effects, and minimizing it requires balancing these opposing trends rather than simply shrinking $h$ indefinitely.

$$\text{Total error (forward)} \approx C_1 h + \frac{C_2 \, \epsilon_{\text{mach}}}{h}$$

Minimizing this expression over $h$ (by setting the derivative with respect to $h$ to zero) gives the classical optimal step size estimates:

$$h^*_{\text{forward}} \approx \sqrt{\epsilon_{\text{mach}}}, \qquad h^*_{\text{central}} \approx \epsilon_{\text{mach}}^{1/3}$$

- In double precision, $\epsilon_{\text{mach}} \approx 2.2 \times 10^{-16}$, giving $h^*_{\text{forward}} \approx 1.5 \times 10^{-8}$ and $h^*_{\text{central}} \approx 6 \times 10^{-6}$ as commonly cited rule-of-thumb values. [Unverified] — these are standard textbook approximations assuming $C_1, C_2 = O(1)$ and well-scaled variables; actual optimal step sizes depend on the specific function's derivative magnitudes and can differ substantially in practice, especially for poorly scaled problems.

### Illustration: Error vs. Step Size Trade-off

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420" font-family="Helvetica, Arial, sans-serif">
  <text x="400" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Truncation vs. Roundoff Error Trade-off (svg_diagram)</text>

  
  <line x1="80" y1="360" x2="740" y2="360" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="360" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="410" y="395" text-anchor="middle" font-size="13" fill="#333">step size h (decreasing to the right →)</text>
  <text x="40" y="210" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 40 210)">total error</text>

  
  <path d="M 700 90 Q 500 100 350 160 Q 250 220 120 340" fill="none" stroke="#2980b9" stroke-width="2.5" />
  <text x="620" y="80" font-size="11" fill="#2980b9">truncation error (∝ h or h²)</text>

  
  <path d="M 120 90 Q 220 110 300 200 Q 400 280 700 345" fill="none" stroke="#c0392b" stroke-width="2.5" />
  <text x="140" y="80" font-size="11" fill="#c0392b">roundoff error (∝ ε/h)</text>

  
  <path d="M 700 100 Q 500 150 420 220 Q 400 240 380 260 Q 360 240 300 190 Q 220 130 120 100" fill="none" stroke="#27ae60" stroke-width="3" stroke-dasharray="6,3" />
  <text x="430" y="215" font-size="11" fill="#27ae60" font-weight="bold">total error</text>

  <circle cx="380" cy="258" r="6" fill="#f39c12" />
  <text x="390" y="280" font-size="12" fill="#f39c12" font-weight="bold">optimal h*</text>

  <text x="400" y="405" text-anchor="middle" font-size="11" fill="#555">Optimal h balances shrinking truncation error against growing floating-point cancellation error</text>
</svg>

### Second-Order Derivatives and Hessian Approximation

Finite differences can also approximate second derivatives, though at substantially higher evaluation cost:

**Diagonal Hessian entries** (central difference):

$$\frac{\partial^2 f}{\partial x_i^2}(x) \approx \frac{f(x + h e_i) - 2f(x) + f(x - h e_i)}{h^2}$$

**Off-diagonal (mixed partial) entries**:

$$\frac{\partial^2 f}{\partial x_i \partial x_j}(x) \approx \frac{f(x + h e_i + h e_j) - f(x + h e_i - h e_j) - f(x - h e_i + h e_j) + f(x - h e_i - h e_j)}{4h^2}$$

- **Key Points**: A full finite-difference Hessian requires $O(n^2)$ function evaluations, making it substantially more expensive than gradient estimation ($O(n)$); this cost is a major reason quasi-Newton methods (which build Hessian approximations from gradient information across iterations rather than direct finite differencing) are generally preferred over direct finite-difference Hessians in optimization practice.
- Second-derivative finite differences also amplify roundoff error more severely than first-derivative formulas, since the numerator involves differences of differences — the optimal step size for second derivatives is generally larger than for first derivatives (a common rule of thumb is $h^* \approx \epsilon_{\text{mach}}^{1/4}$ for central second-difference formulas), reflecting greater sensitivity to cancellation.

### Interaction with Optimization: Gradient-Based Methods Using FD Gradients

**Key Points**

- Standard gradient-based methods (steepest descent, BFGS, Newton-CG, trust region Newton-CG) can be applied essentially unmodified once a finite-difference gradient replaces the analytic gradient — the optimization algorithm itself is unaware of how the gradient was obtained.
- However, FD-estimated gradients introduce **noise-like error** into the optimization process, which interacts with the algorithm's convergence behavior:
  - Line search methods relying on the Wolfe curvature condition may behave erratically if the FD gradient error is comparable in magnitude to the true directional derivative near the current point.
  - Trust region methods' ratio test $\rho_k$ can become unreliable if FD gradient/Hessian errors distort the predicted reduction, potentially causing spurious step rejections or unwarranted radius shrinkage.
- [Inference] In practice, optimization runs using finite-difference gradients often terminate at a looser tolerance than would be reasonable with exact gradients, since driving $\|\nabla f\|$ below the level of FD approximation error is not meaningful — refining $h$ further does not help once roundoff dominates.

### Finite Differences vs. True Derivative-Free Methods: When Each Applies

| Aspect | Finite-Difference Gradients + Gradient-Based Optimizer | True Derivative-Free Methods (Nelder-Mead, pattern search, model-based DFO) |
|---|---|---|
| Applicable when $f$ is smooth and cheap to evaluate | Well-suited | Also applicable, but may be less sample-efficient here |
| Applicable when $f$ is noisy | Poorly suited — differencing amplifies noise | Better suited, especially regression-based model DFO variants |
| Applicable when $f$ is non-smooth | Poorly suited — FD approximates a derivative that may not exist or be meaningful | Better suited (direct search methods tolerate non-smoothness structurally) |
| Function evaluations per gradient/iteration | $n+1$ (forward) or $2n$ (central), every iteration a gradient is needed | Varies by method; model-based DFO reuses history, reducing marginal cost |
| Retains fast local convergence of underlying method | Yes, approximately, if $h$ well-chosen and $f$ smooth | Generally no — DFO methods have their own (typically slower) convergence rates |
| Step size / tuning burden | Requires choosing $h$ (or adaptive step size scheme) per problem/scaling | No analogous per-derivative tuning parameter, though method-specific parameters still exist |

### Automatic Differentiation as an Alternative

- Where source code access permits, **automatic differentiation (AD)** computes derivatives to machine precision (no truncation error at all) at a cost comparable to, or sometimes cheaper than, finite differences — particularly via reverse-mode AD, which can compute a full gradient in a small constant multiple of the cost of one function evaluation, independent of $n$.
- AD is not classified as a derivative-free or finite-difference technique, since it does not rely on Taylor-series approximation, but it is frequently the preferred alternative to finite differences whenever the objective function is implemented in a differentiable programming framework, precisely because it avoids the truncation/roundoff trade-off entirely.
- [Inference] the practical choice between AD and finite differences, when both are technically available, generally favors AD due to its superior accuracy and often comparable or lower cost, though integrating AD into legacy or non-differentiable codebases can itself be a nontrivial engineering effort — which is part of why finite differences and true DFO methods remain relevant despite AD's theoretical advantages.

### Practical Considerations

- **Relative vs. absolute step size**: since $h$ should generally scale with the magnitude of $x_i$, a common practical formula is $h_i = h_{\text{rel}} \cdot \max(|x_i|, x_{\text{typ}})$, where $x_{\text{typ}}$ is a typical scale to avoid $h_i \to 0$ when $x_i$ is near zero.
- **Variable scaling**: poorly scaled variables (differing by many orders of magnitude) compound the difficulty of choosing a single, globally appropriate relative step size; per-variable step sizing or problem rescaling is standard practice.
- **Adaptive step size selection**: some implementations estimate an appropriate $h$ dynamically by monitoring the noise level in $f$ (e.g., sampling $f$ multiple times at the same point, if noise is stochastic) rather than relying solely on the fixed theoretical formulas above.
- **Parallelization**: like pattern search polling, the $n+1$ (or $2n$) function evaluations needed for one finite-difference gradient are mutually independent and can be evaluated in parallel, which can substantially reduce wall-clock time when function evaluations are the dominant cost.

### Common Pitfalls

- Using a single fixed step size $h$ across all variables and problem scales without considering relative scaling, leading to either dominant truncation error (too large) or dominant roundoff/noise error (too small) for at least some variables.
- Applying finite-difference gradients directly to noisy objective functions without adjusting $h$ upward or using noise-aware step-size selection — the differencing operation divides noise by $h$, and small $h$ can produce a "gradient" that is almost entirely noise.
- Driving optimization convergence tolerances tighter than what finite-difference gradient accuracy can actually support, leading to stalling, oscillation, or false non-convergence near the optimum.
- Defaulting to finite differences when automatic differentiation is actually available and applicable, forgoing AD's substantially better accuracy at often comparable cost.
- Using forward differences ($O(h)$ error) when central differences ($O(h^2)$ error) are affordable — the doubled evaluation cost of central differences is often justified by the accuracy improvement, particularly when gradient accuracy affects downstream optimization reliability.

**Related Topics**

- Automatic differentiation (forward-mode and reverse-mode) as an alternative to finite differences
- Complex-step differentiation (an alternative technique avoiding subtractive cancellation entirely for analytic functions)
- Simultaneous Perturbation Stochastic Approximation (SPSA) for gradient estimation under noise
- Quasi-Newton methods (BFGS, L-BFGS) as an alternative to finite-difference Hessians
- Noise-aware and regression-based model DFO methods (revisiting model-based trust region DFO under noise)
- Optimal step size selection theory and adaptive finite-difference schemes