## Discrete-Time Dynamic Programming

### Definition and Core Idea

Discrete-time dynamic programming (DP) is the framework for solving sequential decision problems in which time advances in distinct, countable stages $t = 0, 1, 2, \ldots, T$ (as opposed to continuous time). At each stage, a decision-maker observes the current state, chooses a control/action, incurs a cost or receives a reward, and transitions to a new state at the next stage. Discrete-time DP builds directly on the Bellman equation and the Principle of Optimality, applying backward induction over a finite or countable sequence of stages to compute an optimal policy. It is the setting in which dynamic programming is most commonly introduced, since the discreteness of time avoids the technical machinery (partial differential equations, stochastic calculus) required in the continuous-time analogue.

### Formal Elements of a Discrete-Time DP Model

A discrete-time dynamic programming problem is fully specified by five elements:

- **Stages**: $t = 0, 1, \ldots, T$ (finite horizon) or $t = 0, 1, 2, \ldots$ (infinite horizon).
- **State $s_t \in S_t$**: a sufficient statistic capturing all information relevant to future decisions, satisfying the Markov property.
- **Control/action $a_t \in A_t(s_t)$**: the decision available at stage $t$ given state $s_t$, possibly constrained to a state-dependent feasible set.
- **Transition function**: $s_{t+1} = f_t(s_t, a_t)$ for deterministic problems, or a transition probability $P_t(s_{t+1} \mid s_t, a_t)$ for stochastic problems.
- **Cost/reward function**: $c_t(s_t, a_t)$ per stage, plus a terminal cost/reward $g_T(s_T)$ for finite-horizon problems.

The objective is to choose a policy $\pi = (\pi_0, \pi_1, \ldots)$, a sequence of decision rules mapping states to actions, that minimizes (or maximizes) the total expected cost (or reward) over the horizon.

### Finite-Horizon Formulation

For a finite horizon of length $T$, the total cost under policy $\pi$ starting from initial state $s_0$ is:

$$J_\pi(s_0) = \mathbb{E}\left[ \sum_{t=0}^{T-1} c_t(s_t, \pi_t(s_t)) + g_T(s_T) \right]$$

The optimal cost-to-go (value function) is found via backward induction, as introduced in the Bellman equation discussion:

$$V_T(s_T) = g_T(s_T)$$



$$V_t(s_t) = \min_{a_t \in A_t(s_t)} \left\{ c_t(s_t, a_t) + \mathbb{E}\left[ V_{t+1}(s_{t+1}) \mid s_t, a_t \right] \right\}, \quad t = T-1, \ldots, 0$$

The resulting $V_0(s_0)$ gives the optimal expected cost from any initial state, and the sequence of minimizing actions at each stage and state defines the optimal policy $\pi^*$.

### Diagram: Finite-Horizon Stage Structure

===MERMAID_DIAGRAM===

flowchart LR

S0["State s₀ (svg_diagram)"] -->|"a₀, cost c₀"| S1["State s₁"]

S1 -->|"a₁, cost c₁"| S2["State s₂"]

S2 -->|"a₂, cost c₂"| Dots["..."]

Dots -->|"a_(T-1), cost c_(T-1)"| ST["State s_T<br/>Terminal cost g_T(s_T)"]

### Infinite-Horizon Formulations

When a problem has no natural terminal stage, three standard infinite-horizon formulations are used, distinguished by how the infinite sum of costs is made well-defined:

**Discounted Cost Criterion**

$$J_\pi(s_0) = \mathbb{E}\left[ \sum_{t=0}^{\infty} \gamma^t c_t(s_t, a_t) \right], \quad \gamma \in [0,1)$$

The discount factor $\gamma$ ensures the infinite sum converges (given bounded per-stage costs) and reflects a preference for costs/rewards realized sooner. This is the most common infinite-horizon formulation, particularly in economics, finance, and reinforcement learning.

**Average Cost (Long-Run Average) Criterion**

$$J_\pi = \lim_{T \to \infty} \frac{1}{T} \mathbb{E}\left[ \sum_{t=0}^{T-1} c_t(s_t, a_t) \right]$$

Used when discounting is not natural to the problem (e.g., some queueing and maintenance applications), this criterion evaluates the long-run average cost per stage rather than a discounted total.

**Total Cost (Stochastic Shortest Path) Criterion**

$$J_\pi(s_0) = \mathbb{E}\left[ \sum_{t=0}^{\tau} c_t(s_t, a_t) \right]$$

where $\tau$ is a (possibly random) stopping time at which a terminal/absorbing state is reached. Used for problems with a natural termination condition (e.g., reaching a goal state), without discounting.

[Inference] The choice among these three criteria in a given application is typically dictated by the problem's natural structure (whether costs "expire" over time, whether a terminal absorbing state exists, or whether only long-run behavior matters) rather than by computational convenience, since each requires distinct solution techniques and convergence conditions.

### Stationarity in Infinite-Horizon Problems

A key simplification in infinite-horizon discrete-time DP is that, under time-invariant transition and cost functions ($f_t = f$, $c_t = c$ for all $t$), the optimal policy can be shown to be **stationary** — that is, $\pi_t^*(s) = \pi^*(s)$ for all $t$, depending only on the current state and not on the stage index. This allows the value function to be written without a time subscript, $V(s)$, satisfying the stationary Bellman equation introduced previously, and is what makes value iteration and policy iteration well-defined, time-independent algorithms.

### Solution Methods

**Backward Induction (Finite Horizon)**

The direct method for finite-horizon problems: compute $V_T, V_{T-1}, \ldots, V_0$ sequentially, as described above. This is exact (subject to any state-space discretization) and terminates in a known, finite number of stages.

**Value Iteration (Infinite Horizon)**

Iterates the Bellman operator $V^{(k+1)} = TV^{(k)}$ until convergence, exploiting the contraction property of the discounted Bellman operator. Convergence is geometric, with error after $k$ iterations bounded proportionally to $\gamma^k$, which provides a practical stopping criterion based on a desired accuracy tolerance.

**Policy Iteration (Infinite Horizon)**

Alternates policy evaluation (solving a linear system for $V^\pi$) and policy improvement (greedy update), as previously introduced. Converges in a finite number of iterations for finite state/action spaces.

**Linear Programming Formulation**

The discounted-cost Bellman optimality equation can be reformulated as a linear program: find $V(s)$ satisfying $V(s) \leq c(s,a) + \gamma \mathbb{E}[V(s')]$ for all $(s,a)$, maximizing $\sum_s \mu(s) V(s)$ for any positive weighting $\mu$. This reformulation is less commonly used for direct computation than value/policy iteration but is theoretically important for establishing duality-based results and for connecting DP to the broader linear/convex optimization literature.

### State Space Discretization

Many discrete-time DP applications originate from continuous state variables (e.g., inventory levels treated as continuous quantities, or continuous asset values in finance). To apply DP computationally, the continuous state space is discretized onto a finite grid, introducing an approximation error that generally decreases as the grid is refined, at the cost of an increase in computational effort proportional to the size of the resulting discrete state space — a direct manifestation of the curse of dimensionality discussed previously, since grid size grows exponentially with the number of continuous state dimensions being discretized.

### Practical Example

**Example**

Consider an equipment replacement problem over an infinite horizon with discounting. The state $s_t \in \{0, 1, 2, \ldots, 5\}$ represents the age (in years) of a machine, capped at 5 (beyond which it is treated as fully depreciated). At each stage, the decision $a_t \in \{\text{keep}, \text{replace}\}$ is made. If "keep," the machine ages one year ($s_{t+1} = \min(s_t + 1, 5)$) and incurs a maintenance cost $m(s_t)$ that increases with age. If "replace," a replacement cost $R$ is incurred and the state resets to $s_{t+1} = 0$. The discount factor is $\gamma = 0.9$.

The stationary Bellman equation is:

$$V(s) = \min \Big\{ \underbrace{m(s) + \gamma V(\min(s+1,5))}_{\text{keep}}, \; \underbrace{R + \gamma V(0)}_{\text{replace}} \Big\}$$

Value iteration is applied: starting from $V^{(0)}(s) = 0$ for all $s \in \{0,\ldots,5\}$, the Bellman update is applied repeatedly across all 6 states until the maximum change in $V(s)$ across states falls below a small tolerance (e.g., $10^{-6}$).

**Output**

The converged value function $V^*(s)$ and corresponding optimal policy typically take the form of a **control-limit policy**: keep the machine while $s < s^*$ for some threshold age $s^*$, and replace once $s \geq s^*$. This threshold structure is a well-known qualitative result for this class of replacement problems, though the exact numerical value of $s^*$ depends on the specific maintenance cost function $m(s)$, replacement cost $R$, and discount factor $\gamma$ used.

### Relationship to Markov Decision Processes

Discrete-time DP with stochastic transitions is mathematically equivalent to a **Markov Decision Process (MDP)**: the state, action, transition probability, and cost/reward structure described above are precisely the defining elements of an MDP. The terms are often used interchangeably in the literature, though "dynamic programming" typically emphasizes the solution methodology (backward induction, value/policy iteration), while "MDP" emphasizes the underlying stochastic process model. This equivalence is what allows DP solution methods to be applied directly to reinforcement learning problems, which are formulated as MDPs where the transition probabilities and/or cost function may be unknown and must be learned from interaction with the environment.

### Computational Considerations

- **Finite vs. infinite horizon algorithm choice**: finite-horizon problems are solved by direct backward induction in a fixed number of steps; infinite-horizon problems require iterative methods (value/policy iteration) with convergence criteria.
- **State-action space size**: computational cost per iteration scales with $|S| \times |A|$ (number of states times number of actions), which becomes the binding constraint for large-scale problems, again tied to the curse of dimensionality.
- **Sparsity of transitions**: when the transition function/probability has sparse structure (each state can only transition to a small subset of other states), computational savings can be achieved by exploiting this sparsity rather than treating the transition matrix as dense.

### Common Pitfalls

- Applying a stationary (time-independent) Bellman equation to a problem with genuinely time-varying costs or dynamics, which requires the full finite-horizon, time-indexed recursion instead.
- Choosing an inappropriate infinite-horizon criterion (e.g., using discounted cost when the problem structure calls for average cost), leading to a well-posed but conceptually mismatched formulation.
- Discretizing a continuous state space too coarsely, introducing approximation error that is mistaken for a genuine feature of the optimal policy rather than an artifact of the grid resolution.
- Assuming policy iteration is always faster than value iteration; relative performance depends on the cost of the linear system solve in policy evaluation versus the number of iterations value iteration requires, and this varies by problem.

**Related Topics**

- Bellman equation and the Principle of Optimality
- Markov Decision Processes and reinforcement learning
- Value iteration and policy iteration convergence analysis
- Approximate dynamic programming and function approximation
- Linear programming formulations of MDPs
- Control-limit and threshold policies in operations research
- Continuous-time dynamic programming and the HJB equation
- Curse of dimensionality mitigation techniques