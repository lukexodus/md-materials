## Continuous-Time Optimal Control

### Definition and Core Idea

Continuous-time optimal control is the framework for finding a control trajectory $a(t)$ that steers a dynamical system, evolving continuously over time according to a differential equation, so as to minimize (or maximize) a specified performance criterion over a time interval $[0, T]$. Unlike discrete-time dynamic programming, where the system moves through a countable sequence of stages, continuous-time optimal control treats time as a continuous variable, and the system's evolution is governed by an ordinary differential equation (ODE) or, in the stochastic case, a stochastic differential equation (SDE). This framework generalizes the Bellman equation and Principle of Optimality to the continuous setting, giving rise to two complementary solution approaches: the Hamilton-Jacobi-Bellman equation (a dynamic programming perspective) and Pontryagin's Minimum Principle (a variational/necessary-conditions perspective).

### Formal Problem Statement

A standard continuous-time optimal control problem is specified as:

$$\min_{a(\cdot)} \; J[a(\cdot)] = \int_0^T c(s(t), a(t), t) \, dt + g(s(T))$$

subject to the state dynamics:

$$\dot{s}(t) = f(s(t), a(t), t), \qquad s(0) = s_0$$

and control constraints $a(t) \in A$ for all $t \in [0, T]$. Here $s(t)$ is the state trajectory, $a(t)$ is the control trajectory, $c(\cdot)$ is the running cost, $g(\cdot)$ is the terminal cost, and $f(\cdot)$ governs the instantaneous rate of change of the state. The goal is to find the control function $a^*(t)$ that minimizes $J$ subject to the dynamics being satisfied at every instant.

### Two Solution Approaches

Continuous-time optimal control problems are classically solved via one of two mathematically related but distinct approaches:

- **Dynamic programming / Hamilton-Jacobi-Bellman (HJB) equation**: derives a partial differential equation for the value function $V(s,t)$, from which the optimal control can be recovered pointwise at every state and time. This is the direct continuous-time analogue of the discrete Bellman equation.
- **Pontryagin's Minimum Principle (PMP)**: derives a set of necessary conditions (a two-point boundary value problem involving state and costate/adjoint variables) that any optimal trajectory must satisfy, based on calculus-of-variations reasoning.

Both approaches are grounded in the same underlying Principle of Optimality, but they differ substantially in mathematical form and in the type of problem for which each is more computationally tractable.

### The Hamilton-Jacobi-Bellman Equation

Define the value function $V(s, t)$ as the optimal cost-to-go from state $s$ at time $t$:

$$V(s,t) = \min_{a(\cdot)} \int_t^T c(s(\tau), a(\tau), \tau) \, d\tau + g(s(T))$$

Applying the Principle of Optimality over an infinitesimal time step and taking the limit yields the HJB partial differential equation:

$$-\frac{\partial V}{\partial t}(s,t) = \min_{a \in A} \left\{ c(s,a,t) + \nabla_s V(s,t)^T f(s,a,t) \right\}$$

with terminal (boundary) condition $V(s, T) = g(s)$. The HJB equation is solved backward in time from $t = T$ to $t = 0$, directly paralleling the backward induction of discrete-time DP, but as a PDE rather than a finite recursion. Once $V(s,t)$ is known, the optimal control at any state and time is recovered as:

$$a^*(s,t) = \arg\min_{a \in A} \left\{ c(s,a,t) + \nabla_s V(s,t)^T f(s,a,t) \right\}$$

### The Hamiltonian Function

Both the HJB approach and Pontryagin's principle make use of the **Hamiltonian**:

$$H(s, a, \lambda, t) = c(s, a, t) + \lambda^T f(s, a, t)$$

where $\lambda(t)$ is the **costate** (or adjoint) variable, playing a role analogous to $\nabla_s V(s,t)$ in the HJB equation — in fact, along an optimal trajectory, $\lambda(t) = \nabla_s V(s(t), t)$, which is the key link connecting the two solution approaches.

### Pontryagin's Minimum Principle

Pontryagin's Minimum Principle states that if $a^*(t)$ is optimal with corresponding state trajectory $s^*(t)$, then there exists a costate trajectory $\lambda(t)$ such that the following conditions hold for all $t \in [0,T]$:

$$\dot{s}^*(t) = \frac{\partial H}{\partial \lambda} = f(s^*(t), a^*(t), t) \qquad \text{(state equation)}$$



$$\dot{\lambda}(t) = -\frac{\partial H}{\partial s} = -\nabla_s c(s^*(t), a^*(t), t) - \left(\frac{\partial f}{\partial s}\right)^T \lambda(t) \qquad \text{(costate equation)}$$



$$a^*(t) = \arg\min_{a \in A} \; H(s^*(t), a, \lambda(t), t) \qquad \text{(minimum condition)}$$

with boundary conditions $s^*(0) = s_0$ and $\lambda(T) = \nabla_s g(s^*(T))$ (for a free terminal state; fixed terminal state problems instead specify $s(T)$ directly). This system forms a **two-point boundary value problem**: the state equation has a known initial condition, and the costate equation has a known terminal condition, requiring the two to be solved jointly since neither can be integrated independently from a single endpoint.

### Diagram: HJB vs. Pontryagin Approaches

===MERMAID_DIAGRAM===

flowchart TD

A["Continuous-Time Optimal (svg_diagram)<br/>Control Problem"] --> B["Hamilton-Jacobi-Bellman<br/>(Dynamic Programming)"]

A --> C["Pontryagin's Minimum<br/>Principle (Variational)"]

B --> B1["Solve PDE for V(s,t)<br/>backward from t=T"]

B1 --> B2["Recover a*(s,t) pointwise<br/>via feedback policy"]

C --> C1["Solve Two-Point<br/>Boundary Value Problem<br/>(state + costate ODEs)"]

C1 --> C2["Recover a*(t) along<br/>a single optimal trajectory"]

B2 --> D["Optimal Control Solution"]

C2 --> D

### Comparing the Two Approaches

- **HJB / dynamic programming** yields a **feedback (closed-loop) policy**: $a^*(s,t)$, valid for every possible state, not just the one actually visited. This is more informative but requires solving a PDE over the full state space, which suffers from the curse of dimensionality for high-dimensional states.
- **Pontryagin's Minimum Principle** yields an **open-loop trajectory**: $a^*(t)$ along the specific optimal path from the given initial condition $s_0$. This avoids solving a PDE over the full state space (the boundary value problem is in terms of ODEs, with dimension equal to twice the state dimension), making it more computationally tractable for high-dimensional but specific-initial-condition problems, at the cost of not directly providing a policy valid for other initial states.

[Inference] In practice, PMP is often preferred when a single trajectory from a known starting point is needed (e.g., trajectory optimization in aerospace applications), while HJB/dynamic programming is preferred when a feedback control law valid across a range of operating states is required (e.g., control systems that must respond to disturbances), though this preference reflects computational tractability rather than any difference in the correctness of either method.

### Linear-Quadratic Regulator (LQR): A Solvable Special Case

A widely used special case where both approaches yield closed-form solutions is the **Linear-Quadratic Regulator**: linear dynamics $\dot{s} = As + Ba$ and quadratic cost $J = \int_0^T (s^T Q s + a^T R a)\, dt + s(T)^T Q_T s(T)$, with $Q, Q_T \succeq 0$ and $R \succ 0$. The HJB equation reduces to a **Riccati differential equation** for a matrix $P(t)$, with the value function taking the quadratic form $V(s,t) = s^T P(t) s$, and the optimal control taking the linear feedback form:

$$a^*(t) = -R^{-1}B^T P(t)\, s(t)$$

This closed-form linear feedback structure is a well-documented, standard result and is one of the primary reasons LQR remains a foundational tool in control engineering: it provides an exact, computationally cheap solution (solving a matrix Riccati equation rather than a general nonlinear PDE) for an important class of problems.

### Practical Example

**Example**

Consider a simplified resource extraction problem: a firm extracts a resource from a stock $s(t)$ (e.g., barrels remaining) at rate $a(t) \geq 0$, with dynamics $\dot{s}(t) = -a(t)$, $s(0) = s_0$. Revenue from extraction is $\sqrt{a(t)}$ per unit time (reflecting diminishing marginal revenue), discounted at rate $\rho$, over a fixed horizon $T$, with no terminal value for remaining stock. The problem is:

$$\max_{a(t) \geq 0} \int_0^T e^{-\rho t} \sqrt{a(t)} \, dt \quad \text{s.t.} \quad \dot{s} = -a, \; s(0) = s_0, \; s(t) \geq 0$$

Applying Pontryagin's Minimum Principle (converted to a maximization Hamiltonian $H = e^{-\rho t}\sqrt{a} - \lambda a$): the first-order condition $\partial H / \partial a = 0$ gives $\frac{1}{2}e^{-\rho t} a^{-1/2} = \lambda(t)$, and the costate equation $\dot\lambda = -\partial H/\partial s = 0$ implies $\lambda(t)$ is constant over time (since the Hamiltonian does not depend explicitly on $s$ in this formulation).

**Output**

With $\lambda(t) = \lambda_0$ constant, solving the first-order condition for $a(t)$ gives $a^*(t) = \frac{e^{-2\rho t}}{4\lambda_0^2}$, an extraction rate that declines over time due to discounting. The constant $\lambda_0$ is then determined by the boundary condition that total extraction over $[0,T]$ exhausts (or optimally depletes) the initial stock $s_0$, i.e., $\int_0^T a^*(t)\,dt = s_0$, which pins down $\lambda_0$ in terms of $s_0$, $\rho$, and $T$. This qualitative pattern — a declining extraction rate driven by discounting — is a standard, well-known feature of this class of resource-depletion models.

### Numerical Solution Methods

Exact closed-form solutions (as in LQR) are the exception rather than the rule; most practical continuous-time optimal control problems require numerical methods, broadly divided into two families:

- **Indirect methods**: numerically solve the two-point boundary value problem arising from Pontryagin's Minimum Principle (e.g., via shooting methods or collocation), which requires deriving the costate equations analytically first.
- **Direct methods**: discretize the continuous control and state trajectories over a time grid and convert the entire problem into a finite-dimensional nonlinear programming (NLP) problem, solved with standard NLP solvers. Common direct approaches include direct collocation and direct multiple shooting.

[Unverified] The relative advantage of indirect versus direct methods depends heavily on problem smoothness, presence of path constraints, and the specific NLP or ODE solver used, so no single method is uniformly best across all continuous-time optimal control applications.

### Applications Across Fields

- **Aerospace engineering**: trajectory optimization for spacecraft and aircraft (e.g., minimum-fuel or minimum-time trajectories).
- **Economics**: optimal growth models (e.g., the Ramsey-Cass-Koopmans model), resource extraction, and optimal consumption-investment problems.
- **Robotics**: trajectory planning and feedback control design for robotic manipulators and autonomous vehicles.
- **Finance**: continuous-time portfolio optimization (Merton's problem), typically solved via the stochastic HJB equation.
- **Epidemiology and biology**: optimal intervention strategies (e.g., vaccination or treatment rates) in compartmental disease models.

### Computational Considerations

- **Curse of dimensionality in HJB**: solving the HJB PDE numerically over a discretized state space suffers the same exponential scaling with state dimension as discrete-time dynamic programming, often limiting direct numerical HJB solutions to low-dimensional state spaces (roughly up to 3-4 dimensions for standard grid-based PDE solvers).
- **Sensitivity in shooting methods**: indirect methods based on shooting can be numerically sensitive to the initial guess for the costate's initial value, sometimes requiring careful initialization or continuation methods to achieve convergence.
- **Constraint handling**: path constraints (state or control inequality constraints holding throughout $[0,T]$, not just at the terminal time) complicate both the PMP conditions (introducing additional multiplier terms) and direct methods (adding constraints at each discretized time point), and are generally more straightforward to handle within the direct-method/NLP framework.

### Common Pitfalls

- Applying Pontryagin's Minimum Principle without correctly specifying boundary conditions for the costate, particularly for problems with free (rather than fixed) terminal states or free terminal time, where the correct transversality conditions differ from the fixed-terminal-state case.
- Attempting a direct grid-based numerical solution of the HJB equation for a state space of more than a few dimensions without recognizing the computational infeasibility this introduces.
- Treating the Hamiltonian minimization condition as sufficient for optimality; in general, Pontryagin's principle provides necessary conditions, and additional convexity assumptions are required for these conditions to also be sufficient.
- Confusing open-loop solutions (a single trajectory, valid only for the specific initial condition solved) with closed-loop/feedback solutions (a policy valid across the state space), which are not interchangeable in applications requiring robustness to disturbances or model uncertainty.

**Related Topics**

- Bellman equation and the Principle of Optimality
- Discrete-time dynamic programming
- Pontryagin's Minimum Principle in depth
- Linear-Quadratic Regulator and Riccati equations
- Stochastic optimal control and the stochastic HJB equation
- Direct transcription methods for trajectory optimization
- Calculus of variations
- Model predictive control