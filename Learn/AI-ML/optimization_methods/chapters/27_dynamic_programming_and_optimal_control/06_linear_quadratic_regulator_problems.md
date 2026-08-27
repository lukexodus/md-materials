## Linear-Quadratic Regulator

### Definition and Core Idea

The Linear-Quadratic Regulator (LQR) is a special class of optimal control problem characterized by **linear** system dynamics and a **quadratic** cost function. This combination is significant because it is one of the few general classes of optimal control problems admitting an exact, closed-form (or semi-closed-form) solution, in contrast to the general nonlinear problems requiring numerical solution of the Hamilton-Jacobi-Bellman equation or Pontryagin's Maximum Principle boundary value problem. LQR has been introduced briefly in both the continuous-time optimal control formulation and the HJB equation entries as a worked example; this entry develops the finite-horizon, infinite-horizon, and discrete-time variants comprehensively.

### Continuous-Time Finite-Horizon LQR Formulation

The standard finite-horizon LQR problem is:

$$\min_{a(\cdot)} \; J = \int_0^T \left( s(t)^T Q\, s(t) + a(t)^T R\, a(t) \right) dt + s(T)^T Q_T\, s(T)$$

subject to linear dynamics:

$$\dot{s}(t) = A s(t) + B a(t), \qquad s(0) = s_0$$

where $A \in \mathbb{R}^{n \times n}$, $B \in \mathbb{R}^{n \times m}$ are constant (or time-varying) system matrices, $Q, Q_T \in \mathbb{R}^{n \times n}$ are symmetric positive semi-definite weighting matrices ($Q \succeq 0$, $Q_T \succeq 0$), and $R \in \mathbb{R}^{m \times m}$ is symmetric positive definite ($R \succ 0$). The positive definiteness of $R$ ensures the control cost term is strictly convex, which is essential both for the problem to be well-posed (unbounded control effort would otherwise be costless in some direction) and for the resulting feedback law to be well-defined.

### Solution via the Riccati Differential Equation

As derived in the HJB equation entry, positing the quadratic value function ansatz $V(s,t) = s^T P(t)\, s$ and substituting into the HJB equation yields the **matrix Riccati differential equation**:

$$-\dot{P}(t) = A^T P(t) + P(t) A - P(t) B R^{-1} B^T P(t) + Q, \qquad P(T) = Q_T$$

This is a system of $\frac{n(n+1)}{2}$ coupled nonlinear scalar ODEs (exploiting the symmetry of $P(t)$), solved backward in time from $t=T$ to $t=0$. Once $P(t)$ is obtained, the optimal feedback control law is:

$$a^*(t) = -K(t)\, s(t), \qquad K(t) = R^{-1} B^T P(t)$$

where $K(t)$ is the (generally time-varying) **optimal feedback gain matrix**. The optimal cost from any initial state is $J^* = s_0^T P(0)\, s_0$.

### Diagram: LQR Solution Pipeline

===MERMAID_DIAGRAM===

flowchart TD

A["System Matrices A, B (svg_diagram)<br/>Weights Q, R, Q_T"] --> B["Solve Riccati Equation<br/>Backward from P(T) = Q_T"]

B --> C["Obtain P(t) for<br/>all t in [0,T]"]

C --> D["Compute Feedback Gain<br/>K(t) = R⁻¹Bᵀ P(t)"]

D --> E["Optimal Control<br/>a*(t) = -K(t) s(t)"]

E --> F["Closed-Loop System<br/>ṡ = (A - BK(t)) s"]

### Infinite-Horizon LQR and the Algebraic Riccati Equation

For infinite-horizon problems ($T \to \infty$) with time-invariant $A$, $B$, $Q$, $R$, the Riccati differential equation's solution $P(t)$, under standard stabilizability and detectability conditions on $(A,B)$ and $(A,Q^{1/2})$, converges to a constant steady-state matrix $P_\infty$ as the horizon recedes, satisfying the **Algebraic Riccati Equation (ARE)**:

$$A^T P_\infty + P_\infty A - P_\infty B R^{-1} B^T P_\infty + Q = 0$$

The corresponding optimal control becomes a **time-invariant (stationary) feedback law**:

$$a^*(t) = -K_\infty\, s(t), \qquad K_\infty = R^{-1} B^T P_\infty$$

This stationary structure directly parallels the stationarity of optimal policies in infinite-horizon discrete-time dynamic programming under time-invariant problem data. A key theoretical guarantee is that, under the stabilizability and detectability conditions mentioned above, the resulting closed-loop system $\dot{s} = (A - BK_\infty)s$ is **asymptotically stable** — the state converges to the origin regardless of initial condition — which is a central reason LQR is foundational in control system design, not merely a cost-minimization exercise.

### Stabilizability and Detectability Conditions

- **Stabilizability of $(A,B)$**: there exists some feedback gain $K$ such that $A - BK$ is stable (all eigenvalues have negative real part). This ensures a stabilizing control input exists at all — without it, no finite-cost solution may exist for some initial states.
- **Detectability of $(A, Q^{1/2})$**: informally, any unstable mode of the system must be "seen" by the cost function (i.e., contribute to $Q$), which ensures the optimal control does not ignore instability in state directions that are unpenalized by $Q$ but still physically present.

These two conditions together guarantee existence of a unique stabilizing solution $P_\infty \succeq 0$ to the algebraic Riccati equation, which is the solution of practical interest among the (generally multiple) solutions the ARE can admit.

### Discrete-Time LQR

The discrete-time analogue replaces the continuous dynamics with a linear difference equation:

$$s_{k+1} = A s_k + B a_k, \qquad s_0 \; \text{given}$$

and the cost:

$$J = \sum_{k=0}^{N-1} \left( s_k^T Q s_k + a_k^T R a_k \right) + s_N^T Q_N s_N$$

Applying discrete-time dynamic programming backward induction with a quadratic value function ansatz $V_k(s) = s^T P_k s$ yields the **discrete-time Riccati difference equation**:

$$P_k = Q + A^T P_{k+1} A - A^T P_{k+1} B \left(R + B^T P_{k+1} B\right)^{-1} B^T P_{k+1} A, \qquad P_N = Q_N$$

with optimal feedback gain $K_k = (R + B^T P_{k+1}B)^{-1} B^T P_{k+1} A$ and control $a_k^* = -K_k s_k$. This equation is solved backward from $k=N$ to $k=0$, directly mirroring the continuous-time Riccati differential equation but as a matrix recursion rather than an ODE. As $N \to \infty$ (with time-invariant matrices and the same stabilizability/detectability conditions), $P_k$ converges to a constant $P_\infty$ solving the discrete-time algebraic Riccati equation, analogous to the continuous-time case.

### Extension: Linear-Quadratic Tracking

A common practical extension is the **LQ tracking problem**, where the objective is to track a reference trajectory $s_{\text{ref}}(t)$ rather than regulate the state to the origin:

$$J = \int_0^T \left( (s - s_{\text{ref}})^T Q (s - s_{\text{ref}}) + a^T R a \right) dt + (s(T)-s_{\text{ref}}(T))^T Q_T (s(T)-s_{\text{ref}}(T))$$

This can be solved by the same Riccati equation machinery, but the resulting optimal control includes an additional feedforward term (beyond the feedback term $-K(t)s(t)$) that depends on the reference trajectory and an auxiliary "tracking" vector $\nu(t)$ satisfying its own backward differential equation, since the problem is no longer regulation to a fixed point (the origin) but tracking of a moving target.

### Practical Example

**Example**

Consider a simplified continuous-time cruise control problem: a vehicle's speed deviation from a target cruising speed is the state $s(t)$ (scalar, $n=1$), with dynamics $\dot{s} = -0.1\, s + a$ (representing natural deceleration due to drag, controlled by throttle/brake input $a$). The cost penalizes speed deviation and control effort equally over an infinite horizon: $Q = 1$, $R = 1$ (both scalars since $n=m=1$), with $A = -0.1$, $B = 1$.

The scalar algebraic Riccati equation is:

$$2(-0.1)P_\infty - P_\infty^2 (1)(1) + 1 = 0 \quad \Longrightarrow \quad -P_\infty^2 - 0.2 P_\infty + 1 = 0$$

Solving this quadratic equation for $P_\infty$ (taking the positive root, since $P_\infty \geq 0$ is required):

$$P_\infty = \frac{-0.2 + \sqrt{0.04 + 4}}{2} \approx \frac{-0.2 + 2.010}{2} \approx 0.905$$

**Output**

The optimal feedback gain is $K_\infty = R^{-1}BP_\infty = 1 \times 1 \times 0.905 = 0.905$, giving the stationary optimal control law $a^*(t) = -0.905\, s(t)$: the throttle/brake input is proportional to the current speed deviation, with the closed-loop dynamics $\dot{s} = (-0.1 - 0.905)s = -1.005\, s$, which is stable (negative coefficient) and converges to zero speed deviation faster than the uncontrolled system's natural decay rate of $-0.1$, illustrating the qualitative effect of optimal feedback control on closed-loop stability and convergence speed.

### Numerical Solution of the Algebraic Riccati Equation

While the scalar example above admits a closed-form quadratic-formula solution, the matrix ARE for $n > 1$ generally requires numerical methods:

- **Eigenvalue/eigenvector methods (Schur method)**: constructs a Hamiltonian matrix from $A$, $B$, $Q$, $R$ and extracts $P_\infty$ from its stable eigenspace via a Schur decomposition — the standard, numerically robust approach used in most control software libraries.
- **Iterative methods**: solving the Riccati difference equation backward from an arbitrary $P_N$ (e.g., $P_N = Q_N$ or $P_N=0$) and iterating until convergence to the fixed point, exploiting the fact that under stabilizability/detectability, the discrete-time Riccati recursion converges to $P_\infty$ as the horizon extends.
- **Newton's method for the ARE**: applies Newton-Raphson iteration directly to the matrix quadratic equation, offering faster (quadratic) local convergence than the iterative approach at the cost of requiring a good initial guess.

### Extensions Beyond Standard LQR

- **LQG (Linear-Quadratic-Gaussian) control**: combines LQR with a Kalman filter for state estimation under noisy, partial state observations, exploiting a separation principle that allows the optimal estimator and optimal controller to be designed independently and then combined.
- **$H_\infty$ control**: an alternative to LQR's expected-cost criterion, minimizing the worst-case gain from disturbances to outputs, offering more explicit robustness guarantees against model uncertainty than standard LQR, at the cost of a more involved Riccati-equation-based solution procedure.
- **Constrained LQR / Model Predictive Control**: when state or control constraints must be respected explicitly (which standard LQR cannot handle directly, since its unconstrained quadratic structure is essential to the closed-form solution), Model Predictive Control re-solves a finite-horizon constrained LQ-like problem at each time step using numerical optimization, incorporating constraints that the pure LQR framework omits.

### Applications

- **Aerospace and vehicle control**: attitude control, autopilot design, and cruise control systems, where the linear approximation of dynamics around an operating point and quadratic penalty on deviations and control effort are natural modeling choices.
- **Robotics**: joint-level feedback control for robotic manipulators operating near a nominal trajectory.
- **Economics**: linear-quadratic approximations of dynamic economic models (e.g., linearized versions of optimal growth models) to obtain tractable closed-form policy functions.
- **Power systems**: frequency and voltage regulation control design.

### Computational Considerations

- **Matrix size scaling**: solving the Riccati equation (differential, difference, or algebraic) scales with $O(n^3)$ per iteration or integration step for state dimension $n$, due to the matrix multiplications involved, though this remains far more tractable than grid-based HJB solution for the same state dimension.
- **Numerical conditioning**: the algebraic Riccati equation can become ill-conditioned when $R$ is nearly singular or when $(A,B)$ is close to losing stabilizability, requiring careful numerical implementation (e.g., the Schur method is generally preferred over direct iteration for ill-conditioned cases).
- **Time-varying vs. time-invariant systems**: time-varying $A(t)$, $B(t)$, $Q(t)$, $R(t)$ require solving the full Riccati differential equation rather than the algebraic Riccati equation, and no steady-state simplification is available.

### Common Pitfalls

- Applying the infinite-horizon algebraic Riccati equation to a system that does not satisfy the stabilizability and detectability conditions, which can result in the ARE having no stabilizing solution or multiple solutions without a clear indication of which is the relevant one.
- Assuming the LQR framework directly handles state or control constraints; standard LQR is fundamentally an unconstrained quadratic optimization problem, and constraints require extensions such as Model Predictive Control.
- Confusing the finite-horizon time-varying Riccati solution with the infinite-horizon steady-state solution, particularly when a finite-horizon problem has a long but not infinite time horizon — the time-varying $P(t)$ only approaches $P_\infty$ away from the terminal boundary, not throughout the entire horizon.
- Neglecting that LQR's optimality and stability guarantees rely on the linear dynamics assumption; applying LQR-derived feedback gains to a genuinely nonlinear system without justifying the linear approximation can lead to instability or poor performance away from the linearization point.

**Related Topics**

- Hamilton-Jacobi-Bellman equation
- Continuous-time optimal control formulation
- Discrete-time dynamic programming
- Kalman filtering and LQG control
- Model Predictive Control
- $H_\infty$ robust control
- Algebraic Riccati equation numerical solution methods
- Stability theory for linear time-invariant systems