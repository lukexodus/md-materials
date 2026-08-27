## Simulated Annealing Algorithm and Cooling Schedules

### Overview

Simulated annealing is a stochastic local search metaheuristic for combinatorial and continuous optimization, inspired by the physical process of annealing in metallurgy: heating a material and then cooling it slowly enough to reach a low-energy, defect-free crystalline state. The algorithm accepts worsening moves with a probability that decreases over time, allowing escape from local optima early in the search while converging toward pure greedy descent as the process "cools." Unlike the exact methods surveyed for MINLP and combinatorial optimization, simulated annealing provides no optimality guarantee — its value lies in scalability to large, poorly structured, or black-box objective landscapes where exact methods are computationally infeasible.

### Core Algorithm

#### Metropolis Acceptance Criterion

At each iteration, given current solution $s$ with cost $E(s)$, generate a neighboring candidate $s'$ (via a problem-specific move operator) with cost $E(s')$. Accept $s'$ unconditionally if $E(s') < E(s)$ (an improving move). If $E(s') \ge E(s)$ (a worsening move), accept it with probability:

$$P(\text{accept}) = \exp\left(-\frac{E(s') - E(s)}{T}\right)$$

where $T > 0$ is the current temperature.

**Key Points**

- At high $T$, acceptance probability for worsening moves approaches 1, so the search behaves close to a random walk over the solution space
- At low $T$, acceptance probability for worsening moves approaches 0, so the search behaves close to greedy descent (hill climbing that only accepts improvements)
- The Metropolis criterion is borrowed directly from statistical mechanics, where it models the probability of a physical system transitioning to a higher-energy state at thermal equilibrium

#### Basic Algorithm Structure

**Key Points**

- Initialize a starting solution $s_0$ and initial temperature $T_0$
- At each temperature level, perform a number of iterations (sometimes called the Markov chain length at that temperature) applying the Metropolis criterion
- Decrease $T$ according to a cooling schedule and repeat until a stopping condition (minimum temperature, iteration budget, or lack of improvement) is met
- Return the best solution encountered during the entire search, since the current solution at termination may not be the best found if later worsening moves were accepted

### Simulated Annealing Flow

```mermaid
flowchart TD
    A[Initialize solution s0 and temperature T0] --> B[Generate neighbor s prime via move operator]
    B --> C[Compute cost difference delta E = E(s prime) minus E(s)]
    C --> D{delta E less than 0?}
    D -- Yes --> E[Accept s prime unconditionally]
    D -- No --> F[Accept s prime with probability exp(-delta E / T)]
    E --> G[Update best solution if improved]
    F --> G
    G --> H{Iterations at this temperature complete?}
    H -- No --> B
    H -- Yes --> I[Decrease T per cooling schedule]
    I --> J{Stopping condition met?}
    J -- No --> B
    J -- Yes --> K[Return best solution found]
```

### Acceptance Probability Behavior (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
\<style\>
.axis { stroke: var(--text-secondary, #666); stroke-width: 1.5; }
.curve_hot { fill: none; stroke: var(--text-primary, #222); stroke-width: 2.5; }
.curve_cold { fill: none; stroke: var(--text-secondary, #888); stroke-width: 2.5; stroke-dasharray: 6,3; }
.label { font-family: sans-serif; font-size: 13px; fill: var(--text-primary, #222); text-anchor: middle; }
\</style\>
<text x="320" y="24" class="label" font-size="16" font-weight="bold">Metropolis Acceptance Probability vs. Cost Increase (svg_diagram)</text>
<line x1="80" y1="250" x2="580" y2="250" class="axis" />
<line x1="80" y1="250" x2="80" y2="60" class="axis" />
<text x="330" y="280" class="label">Cost increase (delta E)</text>
<text x="35" y="155" class="label" transform="rotate(-90 35 155)">Acceptance probability</text>
<path d="M80,90 C200,120 350,190 580,235" class="curve_hot" />
<text x="470" y="150" class="label" font-size="12">High T (accepts many worsening moves)</text>
<path d="M80,90 C110,180 150,235 580,248" class="curve_cold" />
<text x="220" y="220" class="label" font-size="12">Low T (near-greedy)</text>
</svg>

### Cooling Schedules

The cooling schedule — how $T$ decreases over iterations — is the primary lever controlling the exploration/exploitation trade-off and is the most-studied design choice in simulated annealing.

#### Linear Cooling

$$T_{k+1} = T_k - \Delta T$$

**Key Points**

- Simplest to implement and reason about, but rarely used in practice for serious applications since it cools too quickly at low temperatures relative to geometric schedules, reducing the time spent in the regime where fine-grained local refinement is most valuable

#### Geometric (Exponential) Cooling

$$T_{k+1} = \alpha \cdot T_k, \quad \alpha \in (0,1)$$

**Key Points**

- The most widely used schedule in practice due to its simplicity and generally good empirical performance
- Typical $\alpha$ values are close to 1 (e.g., 0.8–0.99), with smaller $\alpha$ cooling faster and larger $\alpha$ cooling more slowly, giving more iterations for the search to explore at each temperature level
- [Inference] The trade-off is direct: slower cooling (larger $\alpha$) increases solution quality on average at the cost of more iterations, though the specific quality-versus-time trade-off is problem- and instance-dependent

#### Logarithmic Cooling

$$T_k = \frac{T_0}{\ln(k + 2)}$$

**Key Points**

- Associated with a theoretical guarantee (Hajek's theorem, 1988): under a logarithmic schedule with a sufficiently large constant, simulated annealing converges to the global optimum with probability 1 as the number of iterations approaches infinity, provided the neighborhood structure satisfies certain connectivity conditions
- [Unverified] Despite the theoretical guarantee, logarithmic cooling is rarely used in practice because it cools far too slowly to be computationally practical on any realistic iteration budget — the asymptotic guarantee is not actionable at finite, practical iteration counts
- Serves primarily as a theoretical benchmark establishing that simulated annealing *can* converge in principle, motivating confidence in faster empirical schedules rather than being used directly

#### Adaptive Cooling

Adjusts the cooling rate dynamically based on observed search behavior — e.g., slowing cooling when the acceptance rate of worsening moves drops too quickly, or reheating (temporarily increasing $T$) if the search appears trapped without recent improvement.

**Key Points**

- Reheating strategies are sometimes distinguished as a separate technique, "simulated annealing with restarts" or "adaptive simulated annealing," and can help escape deep local optima that a monotonic cooling schedule would leave the search stuck near
- Requires more implementation complexity and problem-specific tuning than fixed schedules, trading simplicity for potentially better adaptivity to a specific landscape's structure

### Cooling Schedule Comparison (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
\<style\>
.axis { stroke: var(--text-secondary, #666); stroke-width: 1.5; }
.linear { fill: none; stroke: var(--text-primary, #222); stroke-width: 2; }
.geometric { fill: none; stroke: var(--text-secondary, #555); stroke-width: 2; stroke-dasharray: 6,3; }
.logarithmic { fill: none; stroke: var(--text-secondary, #999); stroke-width: 2; stroke-dasharray: 2,2; }
.label { font-family: sans-serif; font-size: 12px; fill: var(--text-primary, #222); text-anchor: middle; }
\</style\>
<text x="320" y="24" class="label" font-size="16" font-weight="bold">Temperature vs. Iteration by Schedule Type (svg_diagram)</text>
<line x1="80" y1="250" x2="580" y2="250" class="axis" />
<line x1="80" y1="250" x2="80" y2="60" class="axis" />
<text x="330" y="280" class="label">Iteration</text>
<text x="35" y="155" class="label" transform="rotate(-90 35 155)">Temperature T</text>
<path d="M80,80 L400,250" class="linear" />
<text x="420" y="235" class="label">Linear</text>
<path d="M80,80 Q250,90 400,150 Q500,190 580,230" class="geometric" />
<text x="500" y="170" class="label">Geometric</text>
<path d="M80,80 Q250,100 400,140 Q500,165 580,190" class="logarithmic" />
<text x="560" y="205" class="label">Logarithmic</text>
</svg>

### Parameter Selection

#### Initial Temperature

**Key Points**

- Commonly set so that the initial acceptance rate for worsening moves is high (e.g., 80–95%), estimated empirically by sampling a batch of random moves and computing the temperature that yields the target acceptance rate
- Too low an initial temperature causes the search to behave like greedy descent from the start, losing the exploration benefit that motivates annealing in the first place
- Too high an initial temperature wastes early iterations on effectively random search before the schedule cools enough to matter

#### Markov Chain Length (Iterations per Temperature)

**Key Points**

- Fixed-length schedules apply a constant number of iterations at each temperature; adaptive-length schedules extend the chain length at a given temperature until an equilibrium-like condition is detected (e.g., acceptance rate or cost variance stabilizing)
- Longer chains at each temperature improve exploration quality at each level at the cost of total runtime — a similar trade-off to the cooling rate parameter, since both control how thoroughly the search explores before moving to a colder regime

#### Stopping Criteria

**Key Points**

- Common criteria: a minimum temperature threshold, a fixed total iteration or evaluation budget, or a number of consecutive temperature levels with no improvement to the best solution found
- [Inference] In practice, evaluation-budget-based stopping is often preferred in applied settings where wall-clock time matters more than reaching a specific temperature threshold, though the appropriate criterion depends on whether the priority is solution quality or bounded runtime

### Neighborhood and Move Operators

**Key Points**

- The move operator generating $s'$ from $s$ is entirely problem-specific: for TSP, common moves include 2-opt (reversing a tour segment) or swapping two cities; for scheduling, swapping two job positions; for knapsack, flipping an item's inclusion
- Move operator design significantly affects performance independent of the cooling schedule — a move operator that produces overly disruptive neighbors makes the Metropolis criterion's fine control less effective, while overly conservative moves can slow exploration regardless of temperature
- [Inference] Because move operator quality and cooling schedule interact, tuning them independently can be misleading; practical implementations often tune them jointly against representative problem instances

### Simulated Annealing vs. Exact Methods

**Key Points**

- Provides no optimality guarantee and no certified bound on solution quality, unlike branch and bound, outer approximation, or GBD — this is the fundamental trade-off for its applicability to problems where exact methods are computationally infeasible or where the objective function itself is a black box (not expressible in closed algebraic form)
- Scales to very large instances and non-differentiable, discontinuous, or noisy objective functions where gradient-based or MILP/MINLP-based methods do not directly apply
- Commonly used as a heuristic to find good incumbent solutions that seed or bound exact methods (e.g., providing an initial upper bound for branch and bound), combining the strengths of both approaches rather than treating them as mutually exclusive

### Applications

- Combinatorial problems where exact methods scale poorly: large TSP instances, VLSI circuit placement and routing
- Scheduling problems with complex, non-convex objective and constraint structures
- Continuous and mixed black-box optimization, including hyperparameter tuning and engineering design where the objective requires expensive simulation rather than a closed-form expression
- Statistical physics and computational chemistry, the algorithm's original domain of application

### Related Topics

- Tabu search and other trajectory-based metaheuristics
- Genetic algorithms and other population-based metaheuristics
- Local search and neighborhood structures in combinatorial optimization
- Metropolis-Hastings algorithm and Markov chain Monte Carlo methods
- Hyperparameter tuning for metaheuristics
- Hybrid metaheuristic/exact method approaches (e.g., matheuristics)