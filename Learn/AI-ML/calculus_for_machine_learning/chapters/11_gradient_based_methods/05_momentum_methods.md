## Momentum Methods

### Motivation

Standard gradient descent updates parameters using only the current gradient:

$$\theta_{t+1} = \theta_t - \eta \nabla J(\theta_t)$$

This approach has well-documented limitations in certain loss landscapes:

- Slow progress along shallow, gently sloped directions
- Oscillation across steep, narrow ravines (common in ill-conditioned loss surfaces)
- Sensitivity to noisy gradients from mini-batch sampling

Momentum methods address these issues by accumulating a moving average of past gradients, allowing updates to build velocity in consistent directions while damping oscillations in inconsistent ones. This is a widely established characterization in optimization literature; specific speedup magnitudes are problem-dependent [Inference].

### Classical Momentum (Polyak's Heavy Ball Method)

**Update Rule**

$$v_{t+1} = \beta v_t + \nabla J(\theta_t)$$

$$\theta_{t+1} = \theta_t - \eta v_{t+1}$$

Where:
- $v_t$ is the velocity (accumulated gradient) at step $t$, initialized as $v_0 = 0$
- $\beta \in [0, 1)$ is the momentum coefficient, typically set around $0.9$
- $\eta$ is the learning rate
- $\nabla J(\theta_t)$ is the gradient of the loss function at the current parameters

**Physical Interpretation**

The method is named after the "heavy ball" analogy: imagine a ball rolling down the loss surface. Its motion is influenced not just by the current slope (gradient) but by the momentum it has built up from previous motion. A heavy ball rolling downhill tends to:

- Continue moving through small bumps or flat regions
- Resist abrupt direction changes
- Accelerate when gradients repeatedly point the same way

**Expanded Form**

Unrolling the recursion shows that $v_{t+1}$ is an exponentially weighted sum of all past gradients:

$$v_{t+1} = \sum_{k=0}^{t} \beta^{k} \nabla J(\theta_{t-k})$$

Older gradients contribute with exponentially decaying weight $\beta^k$, meaning recent gradients dominate the velocity term.

### Geometric Intuition

Consider a loss surface shaped like an elongated valley (high curvature in one direction, low curvature in another). Vanilla gradient descent zig-zags across the narrow direction while making slow progress along the valley floor. Momentum partially cancels the oscillating components (since they alternate in sign and average out) while reinforcing the consistent component (since it repeatedly points the same way).

(svg_diagram) Momentum vs vanilla gradient descent path comparison

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340" font-family="sans-serif">
  <text x="320" y="24" text-anchor="middle" font-size="16" font-weight="bold">Momentum vs Vanilla Gradient Descent (svg_diagram)</text>

  
  <ellipse cx="320" cy="190" rx="270" ry="80" fill="none" stroke="#cccccc" stroke-width="1.5" />
  <ellipse cx="320" cy="190" rx="210" ry="60" fill="none" stroke="#cccccc" stroke-width="1.5" />
  <ellipse cx="320" cy="190" rx="150" ry="42" fill="none" stroke="#cccccc" stroke-width="1.5" />
  <ellipse cx="320" cy="190" rx="90" ry="26" fill="none" stroke="#cccccc" stroke-width="1.5" />
  <ellipse cx="320" cy="190" rx="35" ry="10" fill="none" stroke="#999999" stroke-width="1.5" />

  
  <circle cx="320" cy="190" r="4" fill="#333333" />
  <text x="320" y="212" text-anchor="middle" font-size="11" fill="#333333">minimum</text>

  
  <polyline points="80,110 150,250 200,120 240,235 275,150 300,210 315,185" fill="none" stroke="#d1495b" stroke-width="2.5" stroke-dasharray="0" />
  <text x="90" y="100" font-size="12" fill="#d1495b" font-weight="bold">Vanilla GD (zig-zag)</text>

  
  <polyline points="80,110 140,150 190,168 235,178 270,183 300,187 315,189" fill="none" stroke="#2e86ab" stroke-width="2.5" />
  <text x="90" y="130" font-size="12" fill="#2e86ab" font-weight="bold">Momentum (smoothed)</text>

  
  <circle cx="80" cy="110" r="4" fill="#111111" />
  <text x="55" y="100" font-size="11" fill="#111111">start</text>
</svg>

### Effective Learning Rate Under Momentum

When gradients are consistently aligned (e.g., along a shallow but steady direction), momentum effectively multiplies the step size. In the steady-state case where the gradient is roughly constant at magnitude $g$, the velocity converges toward:

$$v_{\infty} = \frac{g}{1 - \beta}$$

For $\beta = 0.9$, this gives an effective $10\times$ amplification of the step size in that direction. This is a mathematical consequence of the geometric series and holds under the stated steady-gradient assumption; real training gradients are rarely perfectly constant, so actual amplification will differ [Inference].

### Nesterov Accelerated Gradient (NAG)

**Motivation**

Classical momentum computes the gradient at the current position $\theta_t$ and then applies velocity. Nesterov's method instead computes the gradient at a "lookahead" position — where momentum is about to carry the parameters — providing a correction term before the full step is taken.

**Update Rule**

$$v_{t+1} = \beta v_t + \nabla J(\theta_t - \eta \beta v_t)$$

$$\theta_{t+1} = \theta_t - \eta v_{t+1}$$

**Reformulated (commonly implemented) Version**

Many practical implementations use an algebraically equivalent form that avoids a separate gradient evaluation at the lookahead point:

$$v_{t+1} = \beta v_t + \nabla J(\theta_t)$$

$$\theta_{t+1} = \theta_t - \eta(\beta v_{t+1} + \nabla J(\theta_t))$$

Formulation details vary slightly across frameworks and papers; the exact algebraic form implemented in a given library should be checked against that library's documentation [Unverified].

**Key Points**

- NAG can be understood as applying a correction: it "looks ahead" along the current velocity direction before computing the gradient, giving an anticipatory adjustment
- On convex problems, Nesterov's method has a known theoretical convergence rate improvement over standard gradient descent — specifically $O(1/t^2)$ versus $O(1/t)$ for suitable step sizes — a result established in convex optimization theory
- On non-convex loss surfaces typical of deep learning, formal convergence-rate guarantees from convex theory do not directly transfer; empirical benefits are commonly reported but are problem- and architecture-dependent [Inference]

### Comparison: Classical Momentum vs Nesterov

| Aspect | Classical Momentum | Nesterov (NAG) |
|---|---|---|
| Gradient evaluation point | Current position $\theta_t$ | Lookahead position $\theta_t - \eta\beta v_t$ |
| Correction behavior | Reactive (adjusts after overshoot) | Anticipatory (adjusts before overshoot) |
| Convex convergence rate | $O(1/t)$ (standard GD rate) | $O(1/t^2)$ (accelerated rate), per Nesterov's original analysis |
| Typical implementation cost | One gradient evaluation per step | One gradient evaluation per step (in the reformulated version) |

### Worked Numerical Example

Consider minimizing $J(\theta) = \theta^2$, whose gradient is $\nabla J(\theta) = 2\theta$. Let $\eta = 0.1$, $\beta = 0.9$, and $\theta_0 = 10$, $v_0 = 0$.

**Step 1 (Classical Momentum)**

$$v_1 = 0.9(0) + \nabla J(10) = 0 + 20 = 20$$

$$\theta_1 = 10 - 0.1(20) = 10 - 2 = 8$$

**Step 2**

$$v_2 = 0.9(20) + \nabla J(8) = 18 + 16 = 34$$

$$\theta_2 = 8 - 0.1(34) = 8 - 3.4 = 4.6$$

**Step 3**

$$v_3 = 0.9(34) + \nabla J(4.6) = 30.6 + 9.2 = 39.8$$

$$\theta_3 = 4.6 - 0.1(39.8) = 4.6 - 3.98 = 0.62$$

Compare with vanilla gradient descent under the same $\eta = 0.1$:

$$\theta_1 = 10 - 0.1(20) = 8, \quad \theta_2 = 8 - 0.1(16) = 6.4, \quad \theta_3 = 6.4 - 0.1(12.8) = 5.12$$

At step 3, momentum reaches $\theta_3 = 0.62$ versus vanilla GD's $\theta_3 = 5.12$ — faster progress toward the minimum at $\theta = 0$ on this particular quadratic example. This is a deterministic algebraic computation, not an inference; however, generalizing this specific numerical outcome to all loss landscapes would be an overreach — behavior on non-quadratic, high-dimensional, non-convex surfaces can differ substantially [Inference].

### Choosing the Momentum Coefficient

- $\beta = 0$ reduces the method to vanilla gradient descent
- $\beta$ close to $1$ (e.g., $0.99$) produces strong smoothing and long memory of past gradients, but can cause overshooting or slow responsiveness to new gradient directions
- $\beta = 0.9$ is a commonly cited default in deep learning practice [Unverified — specific "default" conventions vary by framework and should be checked against current library documentation]
- Some schedules increase $\beta$ over training (e.g., starting lower and annealing upward), though this is one of several practices reported in the literature rather than a universal standard [Inference]

### Relationship to Exponential Moving Averages

The velocity update $v_{t+1} = \beta v_t + \nabla J(\theta_t)$ is structurally an exponential moving average (EMA) of gradients, unnormalized. This connects momentum conceptually to later adaptive methods (e.g., Adam), which maintain normalized EMAs of both first and second gradient moments. Momentum can be viewed as a foundational building block for those methods rather than a fully separate concept [Inference].

### Common Pitfalls

- **Too high $\beta$ with too high $\eta$**: can cause the parameters to overshoot the minimum repeatedly, sometimes diverging. Divergence conditions depend on the specific loss curvature and are not universally predictable from $\beta$ and $\eta$ alone [Inference]
- **Momentum with poorly scaled features**: unscaled input features can cause gradients to differ by orders of magnitude across dimensions, and momentum will amplify this imbalance rather than correct it — it does not eliminate the need for feature scaling or normalization
- **Confusing momentum's smoothing effect with noise robustness guarantees**: momentum reduces the *visual* oscillation of the parameter path under noisy gradients, but this does not guarantee improved generalization or final model quality — those depend on many additional factors

### Pseudocode

```
initialize θ, v = 0
for t in range(num_steps):
    g = compute_gradient(J, θ)
    v = beta * v + g
    θ = θ - eta * v
return θ
```

### Related Topics

- Nesterov Accelerated Gradient — deeper theoretical derivation and convex convergence proofs
- Adaptive learning rate methods (AdaGrad, RMSProp, Adam)
- Learning rate schedules and warmup strategies
- Second-order optimization methods (Newton's method, quasi-Newton methods)
- Condition number and its effect on gradient descent convergence
- Stochastic gradient descent and mini-batch noise
- Convexity, saddle points, and non-convex optimization landscapes in deep learning