## Hamilton-Jacobi-Bellman Equation

### Definition and Core Idea

The Hamilton-Jacobi-Bellman (HJB) equation is a nonlinear partial differential equation that characterizes the value function of a continuous-time optimal control problem. It is the continuous-time analogue of the discrete-time Bellman equation, obtained by applying the Principle of Optimality over an infinitesimal time increment and taking the limit as that increment shrinks to zero. Solving the HJB equation yields the optimal value function $V(s,t)$ over the entire state space and time horizon, from which an optimal feedback control law $a^*(s,t)$ can be extracted pointwise. This entry develops the HJB equation in depth, building on its introduction alongside Pontryagin's Maximum Principle in the continuous-time optimal control formulation.

### Derivation from the Principle of Optimality

Consider the value function $V(s,t)$, defined as the optimal cost-to-go from state $s$ at time $t$:

$$V(s,t) = \min_{a(\cdot)} \int_t^T c(s(\tau), a(\tau), \tau)\, d\tau + g(s(T))$$

Applying the Principle of Optimality over a small time increment $\Delta t$, the optimal cost from $(s,t)$ can be split into the cost incurred over $[t, t+\Delta t]$ plus the optimal cost-to-go from the resulting state at $t + \Delta t$:

$$V(s,t) = \min_{a} \Big\{ c(s,a,t)\, \Delta t + V(s + f(s,a,t)\Delta t,\, t+\Delta t) \Big\} + o(\Delta t)$$

Expanding $V(s + f\Delta t, t + \Delta t)$ via a first-order Taylor expansion around $(s,t)$:

$$V(s,t) \approx \min_a \Big\{ c(s,a,t)\Delta t + V(s,t) + \nabla_s V(s,t)^T f(s,a,t) \Delta t + \frac{\partial V}{\partial t}(s,t)\Delta t \Big\}$$

Subtracting $V(s,t)$ from both sides, dividing by $\Delta t$, and letting $\Delta t \to 0$ yields the HJB equation:

$$-\frac{\partial V}{\partial t}(s,t) = \min_{a \in A} \left\{ c(s,a,t) + \nabla_s V(s,t)^T f(s,a,t) \right\}$$

with terminal boundary condition $V(s,T) = g(s)$, reflecting that no further decisions remain at the final time.

### The HJB Equation in Hamiltonian Form

Using the Hamiltonian $H(s, a, p, t) = c(s,a,t) + p^T f(s,a,t)$, where $p$ plays the role of $\nabla_s V$, the HJB equation is often written compactly as:

$$-\frac{\partial V}{\partial t}(s,t) = \min_{a \in A} H(s, a, \nabla_s V(s,t), t) = H^*(s, \nabla_s V(s,t), t)$$

where $H^*(s,p,t) = \min_{a \in A} H(s,a,p,t)$ is the **minimized Hamiltonian**, obtained by solving the pointwise minimization over $a$ for fixed $s$, $p$, and $t$. This formulation emphasizes that the HJB equation is a PDE purely in terms of $V(s,t)$ and its derivatives, once the minimization over $a$ has been carried out analytically or numerically for each $(s,p,t)$.

### Diagram: HJB Equation Structure

===MERMAID_DIAGRAM===

flowchart TD

A["Value Function V(s,t) (svg_diagram)<br/>optimal cost-to-go"] --> B["Apply Principle of<br/>Optimality over Δt"]

B --> C["Taylor Expand and<br/>Take Limit Δt → 0"]

C --> D["HJB PDE:<br/>-∂V/∂t = min_a H(s,a,∇V,t)"]

D --> E["Terminal Condition<br/>V(s,T) = g(s)"]

D --> F["Solve Backward in Time"]

F --> G["Extract Feedback Policy<br/>a*(s,t) = argmin_a H(s,a,∇V,t)"]

### Recovering the Optimal Control

Once $V(s,t)$ is known (or approximated) over the relevant domain, the optimal control at any state $s$ and time $t$ is recovered as:

$$a^*(s,t) = \arg\min_{a \in A} \left\{ c(s,a,t) + \nabla_s V(s,t)^T f(s,a,t) \right\}$$

This is a **feedback (closed-loop) control law**: it specifies the optimal action for every possible state, not merely along one specific trajectory. This is the key structural advantage of the HJB approach relative to Pontryagin's Maximum Principle, which yields an open-loop trajectory valid only for one particular initial condition.

### Verification Theorem

A central theoretical result, the **verification theorem**, establishes that if a sufficiently smooth function $W(s,t)$ satisfies the HJB equation with the correct terminal condition, and $a^*(s,t) = \arg\min_a H(s,a,\nabla_s W, t)$ is well-defined and admissible, then $W$ equals the true value function $V$, and the feedback law derived from $W$ is indeed optimal. This provides a **sufficient condition** for optimality — a useful complement to Pontryagin's Maximum Principle, which provides only necessary conditions. In practice, the verification theorem is used to confirm that a candidate solution obtained by solving the HJB equation (whether analytically or numerically) is genuinely optimal, provided the required smoothness and admissibility conditions hold.

### Stochastic HJB Equation

For systems with dynamics governed by a stochastic differential equation (an Itô diffusion):

$$ds(t) = f(s(t), a(t), t)\, dt + \sigma(s(t), a(t), t)\, dW(t)$$

where $W(t)$ is a standard Brownian motion, Itô's lemma introduces an additional second-order term into the HJB equation, reflecting the diffusion's contribution to the expected change in $V$:

$$-\frac{\partial V}{\partial t} = \min_{a \in A} \left\{ c(s,a,t) + \nabla_s V^T f(s,a,t) + \frac{1}{2}\text{tr}\left(\sigma(s,a,t)\sigma(s,a,t)^T \nabla_s^2 V(s,t)\right) \right\}$$

This is now a **second-order** nonlinear PDE (due to the Hessian term $\nabla_s^2 V$), in contrast to the first-order PDE of the deterministic case. The stochastic HJB equation underlies continuous-time stochastic control applications such as Merton's portfolio problem in mathematical finance.

### Viscosity Solutions

A significant technical subtlety in HJB theory is that the value function $V(s,t)$ is often **not differentiable everywhere**, even when the problem data ($c$, $f$, $g$) is smooth — for example, at points where multiple optimal controls yield the same cost, or across switching surfaces in bang-bang control problems. Since the classical HJB equation requires $V$ to be differentiable to even write $\nabla_s V$, a weaker solution concept, the **viscosity solution**, was developed to make sense of the HJB equation at points of non-differentiability. [Unverified] The full technical theory of viscosity solutions (existence, uniqueness, and stability results) is mathematically involved and is typically addressed as a specialized topic within PDE theory rather than in introductory treatments of optimal control, though the core motivating issue — non-differentiability of the value function — arises naturally even in simple examples like bang-bang control.

### Practical Example

**Example**

Return to the Linear-Quadratic Regulator (LQR) introduced under continuous-time optimal control: dynamics $\dot{s} = As + Ba$, cost $J = \int_0^T (s^TQs + a^TRa)\,dt + s(T)^T Q_T s(T)$, with $Q, Q_T \succeq 0$, $R \succ 0$. Guess a quadratic value function ansatz $V(s,t) = s^T P(t)\, s$ for a symmetric matrix $P(t)$. The HJB equation's inner minimization over $a$ (unconstrained, since $A = \mathbb{R}^m$ for standard LQR) gives, from $\partial H/\partial a = 0$: $2Ra + 2B^T P(t) s = 0, so $a^*(t) = -R^{-1}B^T P(t)\, s(t)
.

Substituting this optimal $a^*$ and the ansatz $V = s^TPs$ back into the HJB equation, and matching terms (since the equation must hold for all $s$), yields a matrix differential equation for $P(t)$:

$$-\dot{P}(t) = A^TP(t) + P(t)A - P(t)BR^{-1}B^TP(t) + Q, \qquad P(T) = Q_T$$

**Output**

This is the well-known **matrix Riccati differential equation**, solved backward in time from the terminal condition $P(T) = Q_T$. Once $P(t)$ is obtained (numerically, via standard ODE integration, since a closed-form solution generally does not exist except in special cases), the optimal feedback control $a^*(t) = -R^{-1}B^TP(t)\,s(t)$ is fully determined at every state and time — this quadratic-ansatz approach, verified via the verification theorem, is the standard method for solving the LQR problem and is a well-established, textbook result in control theory.

### Numerical Solution Methods

Because closed-form solutions to the HJB equation exist only for special problem classes (such as LQR), most applications require numerical methods:

- **Finite difference methods**: discretize the state space onto a grid and approximate spatial derivatives with finite differences, solving the resulting system backward in time. Directly analogous to the curse-of-dimensionality-limited grid methods discussed for discrete-time dynamic programming, and similarly constrained to low-dimensional state spaces (typically up to 3-4 dimensions in practice).
- **Semi-Lagrangian schemes**: combine grid-based spatial discretization with a discrete-time approximation of the optimal trajectory, often providing improved stability properties relative to naive finite differences for certain problem classes.
- **Policy iteration for HJB**: an extension of discrete-time policy iteration to the continuous PDE setting, alternating between solving a linear PDE for a fixed policy and updating the policy greedily.
- **Neural network / deep learning approximations**: approximate $V(s,t)$ with a neural network trained to satisfy the HJB equation (e.g., via physics-informed neural network approaches), aiming to sidestep grid-based discretization and its associated curse of dimensionality for higher-dimensional state spaces. [Speculation] Whether such approximation methods reliably scale to the very high-dimensional state spaces sometimes claimed in this line of research, while retaining verifiable solution accuracy, remains an active area of research rather than a settled matter.

### Relationship to Pontryagin's Maximum Principle

As established previously, along an optimal trajectory the costate variable from Pontryagin's Maximum Principle equals the state-gradient of the value function: $\lambda(t) = \nabla_s V(s^*(t), t)$. This connection means PMP's costate and maximum conditions can be derived by differentiating the HJB equation along the optimal path, making PMP effectively a "characteristic curve" method for the HJB PDE — the two frameworks describe the same optimality structure, viewed either globally over the state space (HJB) or along a single optimal path (PMP).

### Applications

- **Mathematical finance**: Merton's optimal consumption-portfolio problem, option pricing and hedging under various risk criteria, and optimal execution problems, typically formulated via the stochastic HJB equation.
- **Robotics and autonomous systems**: feedback control law synthesis for systems requiring robustness to state perturbations and disturbances, where a closed-loop policy is preferred over an open-loop trajectory.
- **Economics**: continuous-time macroeconomic models with optimizing agents (e.g., continuous-time versions of the Ramsey growth model), where the HJB equation characterizes the optimal consumption/savings policy as a function of the current capital stock.
- **Differential games**: extensions of the HJB framework to multi-agent settings (Isaacs' equation), used in pursuit-evasion games and other adversarial dynamic settings.

### Computational Considerations

- **Curse of dimensionality**: the dominant practical limitation of grid-based HJB solution methods, since computational cost grows exponentially with state dimension, mirroring the same challenge in discrete-time dynamic programming.
- **Choice between HJB and PMP for a given problem**: for problems requiring a feedback policy valid across a range of states, HJB is generally necessary despite its computational cost; for problems where only a single trajectory from a known initial state is needed, PMP-based indirect or direct methods are typically more computationally efficient.
- **Boundary and terminal condition specification**: correctly specifying the terminal condition $V(s,T) = g(s)$ (and any boundary conditions on the spatial domain, if the state space is bounded) is essential for a well-posed numerical PDE problem, and errors here are a common source of incorrect numerical solutions.

### Common Pitfalls

- Assuming the value function is everywhere differentiable, which can be violated in problems with bang-bang optimal controls or non-convex cost structures, requiring the viscosity solution framework for a fully rigorous treatment.
- Attempting grid-based finite-difference HJB solutions for state spaces beyond roughly 3-4 dimensions without recognizing the resulting computational infeasibility.
- Omitting the second-order (diffusion) term when adapting a deterministic HJB derivation to a stochastic setting, which produces an equation that does not correctly account for the stochastic dynamics.
- Treating a function that merely satisfies the HJB equation as automatically optimal without invoking the verification theorem's full conditions (smoothness and admissibility of the resulting control), which are required for the sufficiency argument to hold rigorously.

**Related Topics**

- Pontryagin's Maximum Principle
- Continuous-time optimal control formulation
- Linear-Quadratic Regulator and Riccati equations
- Stochastic optimal control and Merton's portfolio problem
- Viscosity solutions of Hamilton-Jacobi equations
- Discrete-time dynamic programming and the curse of dimensionality
- Differential games and the Isaacs equation
- Numerical PDE methods for optimal control