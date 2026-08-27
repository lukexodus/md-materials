## Model Predictive Control

### Definition and Core Idea

Model Predictive Control (MPC) is an optimization-based control strategy in which, at each control interval, a finite-horizon optimal control problem is solved using a model of the system's dynamics, but only the **first** control action from the resulting optimal sequence is applied. At the next time step, the horizon is shifted forward, new state measurements are incorporated, and the entire optimization is re-solved — a procedure known as the **receding horizon** principle. This repeated re-optimization allows MPC to explicitly handle state and control constraints (unlike the closed-form Linear-Quadratic Regulator) and to correct for disturbances, model inaccuracies, or nonlinearities that would otherwise degrade an open-loop or fixed-feedback-gain control law over a long horizon.

### The Receding Horizon Principle

At each sampling instant $k$, given the current measured (or estimated) state $s_k$, MPC solves a finite-horizon optimal control problem over a prediction horizon of length $N$:

$$\min_{a_k, a_{k+1}, \ldots, a_{k+N-1}} \; \sum_{i=0}^{N-1} \ell(s_{k+i}, a_{k+i}) + V_f(s_{k+N})$$

subject to:

$$s_{k+i+1} = f(s_{k+i}, a_{k+i}), \qquad s_k \; \text{given (measured)}$$



$$s_{k+i} \in \mathcal{S}, \quad a_{k+i} \in \mathcal{A}, \quad i = 0, \ldots, N-1$$

where $\ell$ is the stage cost, $V_f$ is a terminal cost (or penalty), $\mathcal{S}$ and $\mathcal{A}$ are state and control constraint sets, and $f$ is the (possibly nonlinear) system model. Only the first control action $a_k^*$ from the resulting optimal sequence is applied to the actual system; at the next sampling instant $k+1$, the horizon shifts forward by one step, the new state $s_{k+1}$ is measured, and the optimization is solved again from scratch.

### Diagram: Receding Horizon Structure

===MERMAID_DIAGRAM===

flowchart TD

A["Measure Current State (svg_diagram)<br/>s_k"] --> B["Solve Finite-Horizon<br/>Optimal Control Problem<br/>over [k, k+N]"]

B --> C["Obtain Optimal Sequence<br/>a_k*, a_(k+1)*, ..., a_(k+N-1)*"]

C --> D["Apply Only First Action<br/>a_k* to the System"]

D --> E["System Evolves to<br/>State s_(k+1)"]

E --> F["Shift Horizon Forward<br/>by One Step"]

F --> A

### Why Only the First Action Is Applied

Re-solving at every step, rather than executing the full optimal sequence computed at time $k$, is what distinguishes MPC from a simple open-loop optimal control solution (e.g., from Pontryagin's Maximum Principle applied once at $t=0$). By discarding the remainder of the planned sequence and re-optimizing from the newly measured state, MPC effectively becomes a **feedback control law**, correcting for any discrepancy between the predicted and actual state trajectory — whether due to disturbances, measurement noise, or inaccuracies in the model $f$ — that would otherwise accumulate uncorrected over an open-loop implementation.

### Relationship to Linear-Quadratic Regulator

When the system dynamics are linear, the cost is quadratic, and no constraints are active, MPC with an infinite prediction horizon reduces exactly to the infinite-horizon LQR feedback law. MPC's practical value over standard LQR arises specifically from two features LQR's closed-form solution cannot accommodate directly:

- **Explicit constraint handling**: state constraints ($s \in \mathcal{S}$) and control constraints ($a \in \mathcal{A}$) are incorporated directly into the finite-horizon optimization at each step, rather than being ignored (as in unconstrained LQR) or handled only approximately.
- **Finite computational horizon with re-optimization**: rather than requiring a single global closed-form solution, MPC solves a new, moderately-sized optimization problem at each step, which is often more tractable for nonlinear or constrained systems than attempting a single global nonlinear optimal control solution.

### Terminal Cost and Terminal Constraint

Because MPC solves only a finite-horizon problem at each step, ignoring behavior beyond the horizon can lead to poor long-run performance or even instability, since the optimizer has no incentive to consider consequences past $k+N$. Two standard remedies are used, often together:

- **Terminal cost $V_f(s_{k+N})$**: an additional penalty on the state at the end of the prediction horizon, often chosen as the value function of an associated infinite-horizon LQR problem (linearized around the target operating point), providing an approximation of the cost-to-go beyond the horizon.
- **Terminal constraint**: a constraint requiring the predicted state at the end of the horizon, $s_{k+N}$, to lie within a specified "safe" terminal set (often invariant under a known stabilizing local feedback law), which prevents the optimizer from choosing trajectories that end near instability or infeasibility.

These terminal ingredients are central to the theoretical stability analysis of MPC, since without them, standard MPC formulations do not automatically guarantee that the closed-loop system will be stable.

### Nonlinear MPC

When the system dynamics $f$ are nonlinear, the finite-horizon optimization at each step becomes a **nonlinear program (NLP)** rather than a quadratic program, since the underlying prediction model is nonlinear. Solving this NLP at every sampling instant, often under strict real-time computational deadlines, is the central computational challenge of **Nonlinear MPC (NMPC)**. Common solution approaches include:

- **Direct multiple shooting**: discretizes the control trajectory over the horizon and simulates the nonlinear dynamics forward in segments, converting the continuous-time NMPC problem into a structured NLP solved via sequential quadratic programming (SQP) or interior-point methods.
- **Direct collocation**: discretizes both state and control trajectories over the horizon using polynomial approximations, converting the problem into a large but sparse NLP.
- **Real-time iteration schemes**: exploit the similarity between consecutive MPC problems (since the horizon shifts by only one step each time) to warm-start the NLP solver with the previous solution, substantially reducing the computation required at each step relative to solving each NLP from scratch.

### Linear MPC

When dynamics are linear and constraints are polyhedral (linear inequalities), the finite-horizon optimization reduces to a **quadratic program (QP)**, which can be solved reliably and efficiently using standard QP solvers, and for which real-time computational guarantees are considerably easier to establish than in the nonlinear case. Linear MPC is the most widely deployed variant in industrial process control, owing to this favorable computational structure.

### Stability Theory

A central theoretical concern in MPC is whether the receding-horizon, re-optimized control law actually stabilizes the closed-loop system, since MPC does not solve the true infinite-horizon problem exactly at any single step. Standard sufficient conditions for closed-loop stability include:

- The terminal cost $V_f$ upper-bounds the true infinite-horizon cost-to-go from the terminal set (often satisfied by construction when $V_f$ is derived from a local LQR solution).
- The terminal constraint set is invariant under the associated local terminal control law (i.e., once the state enters the terminal set, a known feedback law keeps it there while decreasing $V_f$).
- The finite-horizon optimization is feasible at the initial time, and **recursive feasibility** holds — meaning that if the problem is feasible at step $k$, it remains feasible at step $k+1$ under the receding-horizon implementation, which is a nontrivial property that must be established (often via the terminal constraint set's invariance) rather than assumed.

[Inference] Establishing recursive feasibility and stability rigorously for a specific nonlinear MPC implementation is often more involved than in the linear case, and is a common reason why practical NMPC deployments sometimes rely on extensive simulation-based validation in addition to (or in lieu of) a complete formal stability proof.

### Practical Example

**Example**

Consider a simplified linear MPC problem for temperature regulation: state $s_k$ is the temperature deviation from a setpoint, dynamics $s_{k+1} = 0.9\, s_k + a_k$ (a discrete-time first-order system), with a heater/cooler input constrained to $a_k \in [-2, 2]$ (limited actuator authority) and a state constraint $s_k \in [-5, 5]$ (avoiding excessive temperature deviation). The stage cost is $\ell(s,a) = s^2 + 0.1\, a^2$, with prediction horizon $N = 10$ and terminal cost $V_f(s) = P_\infty s^2$ derived from the corresponding unconstrained infinite-horizon discrete-time LQR solution.

At each sampling instant, given the measured $s_k$, the QP:

$$\min_{a_k,\ldots,a_{k+9}} \sum_{i=0}^{9} \left(s_{k+i}^2 + 0.1\, a_{k+i}^2\right) + P_\infty\, s_{k+10}^2$$

subject to the linear dynamics and the constraints $a_{k+i} \in [-2,2]$, $s_{k+i} \in [-5,5]$, is solved for the 10-step control sequence, but only $a_k^*$ is applied.

**Output**

When the state is far from the setpoint (large $|s_k|$) and the actuator constraint $a \in [-2,2]$ becomes active, the resulting closed-loop trajectory follows a **constrained** response distinct from the unconstrained LQR solution — the control saturates at $\pm 2$ until the state is brought close enough to the setpoint that the constraint is no longer binding, at which point the behavior approaches the unconstrained LQR feedback law. This constraint-aware behavior, automatically produced by re-solving the finite-horizon QP at each step, is precisely the capability that standard (unconstrained) LQR cannot provide directly.

### Handling Disturbances and Model Uncertainty

Standard (nominal) MPC assumes the model $f$ exactly predicts future states given the planned control sequence, which is rarely true in practice. Extensions addressing this include:

- **Robust MPC**: explicitly accounts for a bounded disturbance or model uncertainty set within the optimization, optimizing against worst-case realizations (conceptually related to the robust optimization approaches discussed for uncertain parameters), often at increased conservatism and computational cost.
- **Stochastic MPC**: incorporates probabilistic descriptions of disturbances, often using chance constraints (as introduced in the discussion of chance-constrained programming and its SAA and distributionally robust variants) to bound the probability of constraint violation rather than guaranteeing it never occurs.
- **Tube-based MPC**: maintains the actual state within a bounded "tube" around a nominal predicted trajectory, using an auxiliary feedback law to reject disturbances around the nominal plan, decoupling the nominal optimization from the disturbance-rejection task.

### Applications

- **Chemical process control**: one of the earliest and most widespread applications, where slow process dynamics allow ample computation time for solving the optimization at each step, and hard constraints on temperatures, pressures, and flow rates are common.
- **Automotive systems**: adaptive cruise control, lane-keeping, and increasingly, full autonomous vehicle trajectory planning, where MPC's constraint-handling capability is used to respect physical and safety limits.
- **Aerospace**: spacecraft rendezvous and docking, and increasingly, real-time trajectory correction for autonomous aerial vehicles.
- **Energy systems**: building climate control, battery management systems, and power grid frequency regulation, where MPC balances competing objectives (comfort, cost, equipment constraints) under forecast uncertainty.
- **Robotics**: real-time trajectory tracking and obstacle avoidance for legged and wheeled robots.

### Computational Considerations

- **Real-time computational budget**: the finite-horizon optimization must be solved within the sampling interval, which places a hard practical limit on prediction horizon length, model complexity, and solver choice, particularly for fast-dynamics applications (e.g., automotive or aerospace systems with millisecond-scale sampling).
- **Horizon length tradeoff**: longer prediction horizons generally improve approximation of the true infinite-horizon optimal behavior and can ease the stability/feasibility burden on the terminal ingredients, but increase the size of the optimization problem solved at each step.
- **Warm-starting**: because consecutive MPC problems differ only by a one-step horizon shift and updated initial state, warm-starting the solver with a shifted version of the previous solution is a standard and effective technique for reducing per-step computation, particularly in real-time iteration NMPC schemes.

### Common Pitfalls

- Omitting terminal cost or terminal constraint ingredients in a nominal MPC formulation and assuming closed-loop stability regardless, when stability is not guaranteed by the receding-horizon principle alone without these (or equivalent) ingredients.
- Assuming recursive feasibility holds automatically; without appropriate terminal constraint design, a feasible solution at step $k$ does not guarantee feasibility at step $k+1$, potentially leading to controller failure when no feasible control action exists.
- Selecting too short a prediction horizon for nonlinear or highly constrained systems, resulting in myopic behavior that performs poorly relative to the true (infinite-horizon) optimal control.
- Neglecting model-plant mismatch in nominal MPC deployments where disturbances or unmodeled dynamics are significant, without considering robust or stochastic MPC variants designed to handle this mismatch explicitly.

**Related Topics**

- Linear-Quadratic Regulator and Riccati equations
- Discrete-time dynamic programming
- Robust optimization and uncertainty sets
- Chance-constrained programming and stochastic MPC
- Nonlinear programming and sequential quadratic programming
- Direct transcription methods for trajectory optimization
- Recursive feasibility and invariant set theory
- Real-time optimization and warm-starting techniques