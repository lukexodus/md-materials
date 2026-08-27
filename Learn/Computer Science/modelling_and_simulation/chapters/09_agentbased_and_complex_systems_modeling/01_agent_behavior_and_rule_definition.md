## Agent Behavior and Rule Definition

### Overview

Agent behavior and rule definition is the process of specifying how individual agents perceive their environment, make decisions, and act within an agent-based model (ABM). It forms the computational core of agent-based simulation: the collection of states, rules, and decision logic that determines what an agent does at each time step. Well-defined agent behavior is what allows simple, local rules to generate complex, often unpredictable, system-level (emergent) patterns.

### Core Components of an Agent

**Attributes (State Variables)**
Internal properties that define an agent's current condition. These may be static (fixed at creation) or dynamic (changing over the simulation).

- Identity attributes: unique ID, type/class, spatial position
- Physical/resource attributes: energy, health, wealth, inventory
- Cognitive/social attributes: beliefs, memory, strategy, social ties
- Status attributes: alive/dead, infected/susceptible, employed/unemployed

**Perception (Sensing)**
The mechanism by which an agent gathers information from its environment or from other agents. Perception is usually bounded — agents typically do not have global knowledge.

- Local neighborhood sensing (e.g., Moore or von Neumann neighborhoods on a grid)
- Radius-based or vision-based sensing in continuous space
- Network-based sensing (information from connected agents in a graph)
- Global/environmental sensing (rare, used sparingly to preserve realism)

**Decision-Making Logic**
The rule set that maps perceived state to an action. This is the "behavior" in agent behavior.

**Action (Effectors)**
The set of possible operations an agent can perform: move, communicate, reproduce, consume resources, change state, or modify the environment.

### Types of Agent Rules

**Reactive (Condition-Action) Rules**
The simplest and most common form, expressed as IF-THEN statements.

```plaintext
IF local_density > threshold THEN move_away
IF energy < critical_level THEN seek_food
IF neighbor_infected AND random() < transmission_rate THEN become_infected
```

Reactive rules are computationally cheap and form the basis of classic ABMs such as Schelling's segregation model and Conway's Game of Life.

**Finite State Machine (FSM) Behavior**
Agents transition between a fixed set of discrete states based on triggering conditions. Useful when an agent's behavior qualitatively changes depending on its current mode.

$$
S = \{s_1, s_2, \dots, s_n\}, \quad \delta: S \times E \rightarrow S
$$

where $S$ is the set of states, $E$ is the set of possible events/inputs, and $\delta$ is the transition function.

Example states for an epidemiological agent: `Susceptible → Exposed → Infectious → Recovered`.

**Utility-Based / Optimization Rules**
Agents evaluate multiple possible actions and select the one that maximizes (or satisfices) a utility function.

$$
a^* = \arg\max_{a \in A} \, U(a \mid s_t)
$$

where $A$ is the action set, $s_t$ is the agent's current state, and $U$ is a utility function. Common in economic ABMs (e.g., agents choosing between buy/sell/hold).

**Probabilistic / Stochastic Rules**
Behavior is governed by probability distributions rather than deterministic conditions, capturing uncertainty or heterogeneity.

```plaintext
p_move = 0.3
p_stay = 0.5
p_reproduce = 0.2
```

**Rule-Based Systems with Priorities**
When multiple rules could fire simultaneously, a priority or conflict-resolution scheme is required.

- First-match wins (ordered rule list)
- Highest-priority rule wins (weighted rules)
- Most-specific rule wins (specificity resolution, as in production systems like CLIPS/Drools)

**Learning-Based Behavior**
Agents adapt their rules over time using reinforcement learning, genetic algorithms, or other adaptive mechanisms, rather than following fixed rules.

- Q-learning: agents update an action-value table based on reward feedback
- Genetic/evolutionary rule adaptation: rule sets are mutated and selected across generations
- Imitation/social learning: agents copy successful strategies of neighbors

### The Agent Decision Cycle

Most simulation platforms implement agent behavior as a repeating cycle executed each time step (or tick).

```mermaid
flowchart TD
    A[Sense Environment (svg_diagram)] --> B[Update Internal State]
    B --> C{Evaluate Rules}
    C -->|Condition Met| D[Select Action]
    C -->|No Condition Met| E[Default / Idle Action]
    D --> F[Execute Action]
    E --> F
    F --> G[Modify Environment / Self]
    G --> H[Advance Time Step]
    H --> A
```

This sense–think–act loop is analogous to the perception–cognition–action cycle used in classical agent architectures (e.g., BDI — Belief-Desire-Intention).

### BDI (Belief-Desire-Intention) Architecture

A widely used cognitive framework for more sophisticated agent behavior, especially in social simulation.

- **Beliefs**: the agent's model of the world (may be incomplete or outdated)
- **Desires**: goals the agent would like to achieve
- **Intentions**: the committed plan of action chosen to pursue selected desires

```mermaid
flowchart LR
    Bel[Beliefs (svg_diagram)] --> Delib[Deliberation]
    Des[Desires] --> Delib
    Delib --> Int[Intentions]
    Int --> Plan[Plan Selection]
    Plan --> Exec[Execution]
    Exec -->|Feedback| Bel
```

BDI is useful when agents must persist toward goals over multiple time steps rather than react only to the immediate environment.

### Rule Scope and Interaction Types

**Individual Rules**
Depend only on the agent's own internal state (e.g., aging, energy depletion).

**Local Interaction Rules**
Depend on nearby agents or environment cells (e.g., predator-prey encounter rules, opinion averaging with neighbors).

**Global Rules**
Depend on system-wide variables (e.g., market price, aggregate population), used sparingly since heavy reliance on global information can undermine the "local rules, emergent behavior" premise of ABM.

**Environment-Mediated Rules**
Agents interact indirectly through shared environmental modification — a mechanism known as **stigmergy**.

$$
\text{Agent}_i \rightarrow \text{Environment} \rightarrow \text{Agent}_j
$$

Classic example: ant pheromone trails, where agents deposit and follow chemical signals rather than communicating directly.

### Example: Predator-Prey Agent Rule Set

**Prey agent:**
```plaintext
IF energy <= 0 THEN die
IF predator within perception_radius THEN flee(away_from_predator)
ELSE IF food within perception_radius THEN move_toward(food)
ELSE move_random()
energy -= movement_cost
IF energy > reproduction_threshold AND random() < p_reproduce THEN reproduce()
```

**Predator agent:**
```plaintext
IF energy <= 0 THEN die
IF prey within perception_radius THEN pursue(nearest_prey)
IF distance_to(prey) < capture_radius THEN capture(prey); energy += energy_gain
ELSE move_random()
energy -= movement_cost
```

This simple rule pair, when simulated across a population, generates the well-documented Lotka–Volterra-like population oscillations as an emergent, system-level outcome — no individual agent "knows" about the cycle; it arises from the aggregate of local rules. [Inference: the qualitative oscillatory pattern is well-established in ABM literature, but exact periodicity and amplitude depend heavily on chosen parameters and stochastic implementation, so specific numeric outcomes should be verified empirically for any given model configuration.]

### Handling Rule Conflicts and Consistency

When an agent has multiple candidate rules that could fire in the same step:

- **Precondition partitioning**: design rule conditions to be mutually exclusive where possible
- **Priority ranking**: assign explicit priority values; highest priority executes
- **Weighted stochastic selection**: assign firing probabilities and sample when multiple rules are eligible
- **Hierarchical rule sets**: group rules into layers (e.g., survival rules override social rules), evaluated top-down

### Synchronous vs. Asynchronous Rule Execution

**Synchronous update**: all agents sense the current state, then all agents act simultaneously based on that snapshot (as in Conway's Game of Life). Prevents order-dependent bias but requires buffering old and new states.

**Asynchronous update**: agents act one at a time (in fixed, random, or priority order) and each subsequent agent sees the updated state. Can better represent real-world sequential processes but introduces order-dependence that must be controlled (commonly via randomized activation order each tick).

### Common Pitfalls in Rule Definition

- **Over-specification**: encoding too much detail per agent, making the model computationally expensive without adding explanatory value
- **Under-specification**: omitting edge cases (e.g., what happens when two "highest priority" rules tie), leading to undefined or platform-dependent behavior
- **Implicit global knowledge leakage**: accidentally giving agents access to system-wide information via shared variables, undermining the locality assumption central to ABM
- **Update-order artifacts**: asynchronous execution order unintentionally biasing outcomes (e.g., agents processed first always "winning" contested resources)
- **Parameter conflation**: bundling multiple conceptually distinct behavioral thresholds into a single tunable parameter, which obscures sensitivity analysis

### Platforms and Rule Specification Approaches

| Platform | Rule Definition Style |
|---|---|
| NetLogo | Procedural, agent-centric scripting language (`ask turtles [...]`) |
| Repast | Java/Python-based, supports scheduling and behavior trees |
| MASON | Java-based, discrete-event scheduling of agent `step()` methods |
| GAMA | GAML language, declarative species/behavior blocks with reflexes |
| Mesa (Python) | Object-oriented `step()` methods per agent class |

[Unverified: specific version-dependent syntax and feature sets for each platform change over time; consult current platform documentation before implementation.]

### Key Points

- Agent behavior is defined by the sense → decide → act cycle, repeated each simulation step
- Rule types range from simple reactive IF-THEN logic to complex adaptive/learning behavior
- Rule scope (individual, local, global, environment-mediated) affects how faithfully the model preserves the emergence principle
- Conflict resolution and execution order (synchronous vs. asynchronous) materially affect simulation outcomes and must be deliberately designed, not left as implementation accidents

**Related Topics**
- Environment Representation (grids, continuous space, networks, GIS-based)
- Emergence and Self-Organization in Complex Systems
- Agent Interaction Protocols and Communication
- Scheduling and Time Management in Discrete-Event vs. Agent-Based Simulation
- Calibration, Validation, and Sensitivity Analysis for ABMs
- Multi-Agent Reinforcement Learning
- Stigmergy and Swarm Intelligence
- Model Verification: Replicating Known Emergent Patterns (e.g., Schelling, Boids)