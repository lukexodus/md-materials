## Pontryagin's Maximum Principle

### Definition and Core Idea

Pontryagin's Maximum Principle (PMP) provides a set of necessary conditions that any optimal control trajectory must satisfy in a continuous-time optimal control problem. Developed by Lev Pontryagin and coworkers, it generalizes the classical calculus of variations (Euler-Lagrange equations) to problems with control constraints, allowing the control variable $a(t)$ to be restricted to a bounded or otherwise constrained set $A$, rather than requiring it to range freely as in unconstrained variational problems. The principle converts an infinite-dimensional optimization problem (finding an optimal function $a(t)$ over a continuum of time) into a pointwise optimization condition at each instant, combined with a coupled system of differential equations for the state and an auxiliary "costate" variable. This is the same principle introduced alongside the Hamilton-Jacobi-Bellman equation in the continuous-time optimal control formulation; this entry develops it in full depth.

### Maximum vs. Minimum Principle: A Note on Convention

The principle is stated here for a **maximization** problem, consistent with Pontryagin's original formulation (hence "Maximum" Principle). For a minimization problem, the identical logic applies with the Hamiltonian minimized instead of maximized — this is simply a sign convention, and both forms appear throughout the literature depending on whether the source problem is posed as a cost minimization or reward maximization. Care should be taken to match the convention (max or min) consistently throughout a given derivation, since mixing conventions is a common source of sign errors.

### Formal Problem Statement

Consider the problem:

$$\max_{a(\cdot)} \; J[a(\cdot)] = \int_0^T c(s(t), a(t), t) \, dt + g(s(T))$$

subject to:

$$\dot{s}(t) = f(s(t), a(t), t), \qquad s(0) = s_0, \qquad a(t) \in A \; \forall t \in [0,T]$$

where $s(t) \in \mathbb{R}^n$ is the state, $a(t) \in A \subseteq \mathbb{R}^m$ is the control (constrained to a fixed set $A$, which may be a bounded interval, e.g., $a(t) \in [a_{\min}, a_{\max}]$), $c$ is the running reward, and $g$ is the terminal reward.

### The Hamiltonian and Costate Variables

Define the Hamiltonian:

$$H(s, a, \lambda, t) = c(s, a, t) + \lambda^T f(s, a, t)$$

where $\lambda(t) \in \mathbb{R}^n$ is the costate (adjoint) vector, one component for each state variable, representing the marginal value of an additional unit of state $s_i$ at time $t$ along the optimal trajectory — analogous to a shadow price in static constrained optimization, but evolving over time.

### Statement of the Necessary Conditions

If $a^*(t)$ is optimal with corresponding optimal state trajectory $s^*(t)$, then there exists a costate trajectory $\lambda(t)$, not identically zero, such that for almost every $t \in [0,T]$:

**1. State equation** (recovers the original dynamics):

$$\dot{s}^*(t) = \frac{\partial H}{\partial \lambda}(s^*(t), a^*(t), \lambda(t), t) = f(s^*(t), a^*(t), t)$$

**2. Costate (adjoint) equation**:

$$\dot{\lambda}(t) = -\frac{\partial H}{\partial s}(s^*(t), a^*(t), \lambda(t), t)$$

**3. Maximum condition** (also called the Hamiltonian maximization condition):

$$H(s^*(t), a^*(t), \lambda(t), t) = \max_{a \in A} H(s^*(t), a, \lambda(t), t)$$

**4. Boundary/transversality conditions**:

$$s^*(0) = s_0 \qquad \text{(given initial state)}$$



$$\lambda(T) = \nabla_s g(s^*(T)) \qquad \text{(for a free terminal state)}$$

If instead the terminal state is fixed at a specified value $s(T) = s_T$, the transversality condition on $\lambda(T)$ is dropped and replaced by the fixed terminal state constraint itself.

### Diagram: PMP Solution Structure

===MERMAID_DIAGRAM===

flowchart TD

A["Optimal Control Problem (svg_diagram)<br/>with constraint set A"] --> B["Form Hamiltonian<br/>H = c + λᵀf"]

B --> C["State Equation<br/>ṡ* = ∂H/∂λ"]

B --> D["Costate Equation<br/>λ̇ = -∂H/∂s"]

B --> E["Maximum Condition<br/>a* = argmax_a H(s*,a,λ,t)"]

C --> F["Two-Point Boundary<br/>Value Problem"]

D --> F

E --> F

F --> G["s(0) = s₀<br/>λ(T) = ∇g(s*(T))"]

G --> H["Solve Jointly for<br/>s*(t), λ(t), a*(t)"]

### Why the Maximum Condition Matters for Constrained Controls

The key advantage of PMP over the classical calculus of variations is the maximum condition's handling of control constraints. When $A$ is an interval $[a_{\min}, a_{\max}]$ and the Hamiltonian is linear in $a$, the maximum condition typically yields a **bang-bang control**: the optimal control jumps between its extreme values $a_{\min}$ and $a_{\max}$, switching whenever the sign of the coefficient on $a$ in the Hamiltonian (often called the **switching function**) changes sign. When the Hamiltonian is strictly concave in $a$ (for maximization) and unconstrained optimum lies within $A$, the maximum condition instead reduces to the interior first-order condition $\partial H/\partial a = 0$, recovering the smooth control law seen in unconstrained variational problems.

### Bang-Bang Control: Illustrative Structure

For a Hamiltonian of the form $H = c(s,t) + \lambda(t) f_0(s,t) + \lambda(t) f_1(s,t) \, a$, linear in $a \in [0, a_{\max}]$, the maximum condition gives:

$$a^*(t) = \begin{cases} a_{\max} & \text{if } \lambda(t) f_1(s^*(t), t) > 0 \\ 0 & \text{if } \lambda(t) f_1(s^*(t), t) < 0 \\ \text{undetermined (singular)} & \text{if } \lambda(t) f_1(s^*(t), t) = 0 \end{cases}$$

The case where the switching function is identically zero over an interval of time is called a **singular control** and requires additional analysis (typically involving higher-order derivatives of the switching function) to determine the optimal control on that interval, since the maximum condition alone does not pin down $a^*(t)$ there.

### Pontryagin's Principle with Path Constraints

When the problem includes state constraints (e.g., $s(t) \geq 0$ for all $t$) or mixed state-control constraints, the necessary conditions are extended by introducing additional Lagrange-multiplier-like terms into the Hamiltonian (or an augmented Hamiltonian/Lagrangian), active only when the constraint is binding. [Unverified] The precise form of these additional conditions — and whether multipliers are treated as measures (for pure state constraints) or ordinary functions (for mixed constraints) — depends on the specific type of constraint and regularity conditions assumed, and is a substantially more technical extension of the basic unconstrained-state PMP presented above.

### Free Terminal Time Problems

If the terminal time $T$ is itself a decision variable (free rather than fixed), an additional necessary condition applies at the optimal terminal time $T^*$:

$$H(s^*(T^*), a^*(T^*), \lambda(T^*), T^*) = 0$$

(for problems with no explicit time-dependence in the terminal cost $g$; more generally this condition includes an additional term involving $\partial g/\partial t$ if $g$ depends explicitly on the terminal time). This condition, together with the state and costate equations and the maximum condition, provides enough equations to solve for both the optimal trajectory and the optimal terminal time simultaneously.

### Practical Example

**Example**

Consider a simple bang-bang control problem: a cart with position $s_1(t)$ and velocity $s_2(t)$ must be brought from a given initial position and velocity to rest at the origin ($s_1(T) = s_2(T) = 0$) in **minimum time**, with dynamics $\dot{s}_1 = s_2$, $\dot{s}_2 = a$, and control constraint $a(t) \in [-1, 1]$ (bounded acceleration). The objective is $\min T$, equivalently $\max \int_0^T (-1) \, dt$.

The Hamiltonian is $H = -1 + \lambda_1 s_2 + \lambda_2 a$. The maximum condition gives $a^*(t) = \text{sign}(\lambda_2(t))$, a bang-bang control (since $H$ is linear in $a$ and $A = [-1,1]$ is a bounded interval). The costate equations are $\dot\lambda_1 = -\partial H/\partial s_1 = 0$ and $\dot\lambda_2 = -\partial H/\partial s_2 = -\lambda_1$, giving $\lambda_1(t) = \lambda_1(0)$ constant and $\lambda_2(t) = \lambda_2(0) - \lambda_1(0) t$, a linear function of time.

**Output**

Since $\lambda_2(t)$ is linear in $t$, it changes sign **at most once** over $[0,T]$, meaning the optimal control $a^*(t) = \text{sign}(\lambda_2(t))$ switches sign **at most once**: the classical result for this "double integrator" minimum-time problem is a bang-bang control with at most one switch — full acceleration in one direction, then full acceleration in the opposite direction (braking) to arrive at rest exactly at the origin. This is a standard, well-known result in optimal control theory for the time-optimal double-integrator problem.

### Relationship to the Hamilton-Jacobi-Bellman Equation

Pontryagin's Maximum Principle and the HJB equation are connected through the costate variable: along an optimal trajectory, $\lambda(t) = \nabla_s V(s^*(t), t)$, where $V$ is the HJB value function. This means PMP's costate equation can be derived by differentiating the HJB equation along the optimal trajectory, and the maximum condition in PMP corresponds directly to the pointwise maximization embedded in the HJB equation. PMP can therefore be understood as characterizing the same optimality structure as HJB, but expressed along a single trajectory via ODEs rather than over the entire state space via a PDE — the tradeoff between the two approaches discussed in the continuous-time optimal control formulation.

### Necessary vs. Sufficient Conditions

A crucial caveat: Pontryagin's Maximum Principle provides **necessary** conditions for optimality, not sufficient ones. A trajectory satisfying the state equation, costate equation, maximum condition, and boundary conditions is a candidate for optimality (sometimes called an **extremal**), but is not guaranteed to be optimal without additional assumptions. Sufficient conditions (such as the **Mangasarian sufficiency conditions**) typically require joint concavity of the Hamiltonian in $(s,a)$ (for maximization problems), under which any extremal satisfying PMP's conditions is guaranteed to be globally optimal. Without such concavity, multiple extremals may exist, and additional analysis (or comparison of objective values across candidate extremals) is needed to identify the true optimum.

### Numerical Solution via Indirect Methods

Because PMP reduces the problem to a two-point boundary value problem (state equation with initial condition, costate equation with terminal condition), it is commonly solved numerically via:

- **Single shooting**: guess the unknown initial costate $\lambda(0)$, integrate the state and costate equations forward using the maximum condition to determine $a^*(t)$ at each step, and adjust the guess for $\lambda(0)$ (e.g., via Newton's method) until the terminal condition on $\lambda(T)$ is satisfied.
- **Multiple shooting**: divides $[0,T]$ into subintervals to improve numerical stability relative to single shooting, particularly for problems with sensitive or unstable dynamics.
- **Collocation methods**: discretize the entire boundary value problem on a time grid and solve the resulting system of nonlinear equations simultaneously, rather than via forward integration.

[Inference] Single shooting is generally the simplest to implement but can be numerically unstable for longer time horizons or highly nonlinear dynamics, since small errors in the guessed initial costate can grow substantially over the forward integration — this instability is a commonly cited motivation for using multiple shooting or collocation instead.

### Applications

- **Aerospace trajectory optimization**: minimum-fuel or minimum-time spacecraft and missile trajectories, frequently exhibiting bang-bang thrust control structure.
- **Economic growth theory**: optimal savings and investment rules in models such as the Ramsey-Cass-Koopmans growth model, where the costate variable corresponds to the shadow price of capital.
- **Resource economics**: optimal extraction paths for exhaustible or renewable resources (as in the extraction example under continuous-time optimal control).
- **Epidemic control**: optimal timing and intensity of interventions (e.g., vaccination, quarantine) in compartmental epidemic models, often yielding bang-bang or singular control structures.
- **Robotics and vehicle control**: minimum-time or minimum-energy trajectory planning subject to actuator constraints.

### Computational Considerations

- **Sensitivity to initial costate guess**: shooting-method implementations of PMP can be highly sensitive to the initial guess for $\lambda(0)$, particularly for unstable or chaotic dynamics, sometimes requiring continuation methods (solving a sequence of related, easier problems that gradually approach the target problem) to obtain convergence.
- **Detecting switching structure**: for bang-bang or singular control problems, correctly identifying the number and timing of switches is often the primary numerical challenge, since standard ODE solvers do not automatically detect discontinuities in the control without specialized event-detection logic.
- **Verifying necessary vs. sufficient conditions**: because PMP yields necessary conditions only, numerical solutions should be checked against sufficiency conditions (or compared across multiple candidate extremals) when the Hamiltonian is not known to be concave, to avoid mistaking a non-optimal extremal for the true optimum.

### Common Pitfalls

- Mixing the maximum and minimum principle sign conventions within a single derivation, leading to costate equations or maximum conditions with incorrect signs.
- Treating a solution satisfying PMP's necessary conditions as automatically optimal, without checking sufficiency conditions or the possibility of multiple extremals.
- Overlooking singular control intervals (where the switching function vanishes identically over a nonzero-length interval), which require additional analysis beyond the basic maximum condition.
- Misspecifying transversality conditions for free terminal time or free terminal state problems, which differ from the fixed-terminal-state case and are a frequent source of setup errors.

**Related Topics**

- Hamilton-Jacobi-Bellman equation and dynamic programming
- Continuous-time optimal control formulation
- Bang-bang control and singular control theory
- Calculus of variations and Euler-Lagrange equations
- Two-point boundary value problem numerical methods
- Linear-Quadratic Regulator and Riccati equations
- Optimal control with state and path constraints
- Economic growth theory and shadow pricing