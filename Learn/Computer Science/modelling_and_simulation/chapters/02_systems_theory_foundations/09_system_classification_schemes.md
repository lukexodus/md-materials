## System Classification Schemes

### Definition and Conceptual Basis

System classification schemes are the organizing frameworks used to categorize systems according to fundamental structural or behavioral properties. Rather than describing a single dichotomy, this topic consolidates the major independent classification axes used throughout modelling and simulation, since a given real-world system is typically positioned somewhere along each axis simultaneously rather than falling into a single overarching category.

Understanding these axes jointly is essential because the choice of modelling formalism (differential equations, discrete-event simulation, cellular automata, agent-based models) follows directly from where a system sits on each axis.

### Overview of the Major Classification Axes

| Axis | Categories | Primary Distinguishing Question |
| --- | --- | --- |
| Environmental exchange | Open / Closed | Does the system exchange matter, energy, or information with its environment? |
| State-transition structure | Linear / Nonlinear | Does the system obey superposition? |
| Time representation | Continuous-time / Discrete-time / Discrete-event | How does the state evolve with respect to time? |
| State-space cardinality | Discrete-state / Continuous-state / Hybrid | Are state variables drawn from a countable or continuous set? |
| Determinism | Deterministic / Stochastic | Does identical input and initial state always produce identical output? |
| Time invariance | Time-invariant / Time-varying | Do the system's governing functions themselves change over time? |
| Parameter/structure stability | Static / Dynamic (structure-changing) | Does the system's structure (components, connections) change during operation? |
| Composition | Lumped-parameter / Distributed-parameter | Are state variables independent of spatial position, or do they vary continuously across space? |

### Continuous, Discrete-Time, and Discrete-Event Systems

This axis concerns how the model represents the progression of time and the corresponding state changes.

- **Continuous-time systems:** State variables change continuously over a continuous time domain, typically modelled by ordinary or partial differential equations.
- **Discrete-time systems:** State variables are updated only at fixed, regularly spaced time intervals, typically modelled by difference equations.
- **Discrete-event systems:** State variables change only at irregular, event-triggered instants determined by the occurrence of discrete events, with no change assumed between events.

**Key Points**

- Continuous-time models require numerical integration (Euler, Runge-Kutta) for simulation unless an analytical solution exists.
- Discrete-time models are naturally suited to digital computation and are common in control systems implemented on digital hardware (sampled-data systems).
- Discrete-event systems (queueing networks, manufacturing systems) are simulated using event-scheduling or process-interaction paradigms, advancing simulated time directly from one event to the next rather than in fixed steps.
- A single real-world system may be represented using different time paradigms depending on the modeller's chosen level of abstraction — for instance, a manufacturing line can be modelled with continuous fluid-flow approximations or as discrete part-by-part events. [Inference]

### Diagrammatic Representation: Time Representation Axis

===MERMAID_DIAGRAM===

flowchart TB

subgraph CT["Continuous-Time (svg_diagram)"]

direction LR

CT1["t"] --> CT2["State changes continuously"]

end

subgraph DT["Discrete-Time (svg_diagram)"]

direction LR

DT1["t = 0, Δt, 2Δt, ..."] --> DT2["State updates at fixed intervals"]

end

subgraph DE["Discrete-Event (svg_diagram)"]

direction LR

DE1["Event-triggered instants"] --> DE2["State updates only at events"]

end

### Discrete-State, Continuous-State, and Hybrid Systems

This axis concerns the nature of the state-variable domain itself, independent of how time is represented.

- **Continuous-state systems:** State variables take values from a continuous set (typically real numbers or vectors of real numbers).
- **Discrete-state systems:** State variables take values from a finite or countably infinite set (e.g., integers, symbolic states).
- **Hybrid systems:** Combine both continuous-state dynamics (governed by differential equations) and discrete-state transitions (governed by a finite-state automaton or similar discrete logic), often with discrete transitions triggered by continuous variables crossing thresholds.

**Example**

A thermostatically controlled heating system is a hybrid system: room temperature is a continuous-state variable evolving according to a differential equation, while the heater's on/off mode is a discrete state that switches according to a threshold condition on temperature (a discrete transition triggered by a continuous variable crossing a boundary).

**Key Points**

- Hybrid systems require specialized simulation techniques that interleave continuous integration with discrete-event detection (often called "zero-crossing detection" for threshold-triggered transitions).
- Many real-world control and cyber-physical systems are naturally hybrid, since digital controllers (discrete logic) act on physical plants (continuous dynamics). [Inference]

### Deterministic and Stochastic Systems

This axis concerns whether randomness is present in the system's transition or output structure.

- **Deterministic systems:** Given a fixed initial state and input trajectory, the resulting state and output trajectories are always uniquely determined — repeated simulation runs with identical inputs produce identical outputs.
- **Stochastic systems:** The transition or output function incorporates random variables, so identical initial state and input can produce different outcomes across repeated runs.

**Key Points**

- Stochastic systems require multiple simulation replications to characterize the distribution of possible outcomes, rather than relying on a single run.
- Randomness can enter a model through random inputs (exogenous noise), random parameters, or random transition rules (e.g., probabilistic state transitions in a Markov chain).
- A model can be nominally deterministic in structure but treated as stochastic in practice if key parameters are uncertain and modelled via probability distributions in a Monte Carlo framework. [Inference]

### Time-Invariant and Time-Varying Systems

This axis concerns whether the system's governing functions themselves depend explicitly on time, separate from their dependence on the current state and input.

- **Time-invariant systems:** The transition and output functions $\delta$ and $\lambda$ do not depend explicitly on the time variable $t$; the same input applied at any two different times produces the same output shape, merely time-shifted.
- **Time-varying systems:** The transition and/or output functions depend explicitly on $t$, so identical inputs applied at different times can produce qualitatively different outputs.

**Example**

A spacecraft with constant mass and thruster response is well-approximated as time-invariant over a short window, but the same system becomes explicitly time-varying if fuel consumption is included, since decreasing mass changes the system's response to a given thrust input as the mission progresses.

**Key Points**

- Time-invariant linear systems (LTI systems) admit especially powerful analytical tools, including transfer functions and frequency-domain analysis, which do not directly apply to time-varying systems.
- Distinguishing time-variance from nonlinearity is important: a system can be linear yet time-varying (coefficients change with $t$ but remain linear in state/input at each instant), or nonlinear yet time-invariant. [Inference]

### Static (Structure-Fixed) and Dynamic-Structure Systems

This axis, distinct from the state dynamics themselves, concerns whether the system's own components and their interconnections change during the period of study.

- **Fixed-structure systems:** The set of components and their coupling relationships remain constant throughout the simulation.
- **Dynamic-structure systems:** Components can be created, destroyed, or re-coupled during simulation execution (e.g., agents entering/leaving an agent-based model, network nodes joining/leaving a communication network).

**Key Points**

- Dynamic-structure systems require simulation frameworks capable of modifying the model's component graph at runtime, which is more complex than executing a fixed set of coupled equations.
- The DEVS formalism has extensions (Dynamic Structure DEVS) specifically to support structural change during simulation execution, since the base DEVS formalism assumes fixed structure. [Unverified — specific formalism extension names and scope should be confirmed against current DEVS literature.]

### Lumped-Parameter and Distributed-Parameter Systems

This axis concerns whether spatial variation within the system is explicitly represented.

- **Lumped-parameter systems:** State variables are treated as spatially uniform, represented by a finite set of state variables independent of position (typically modelled with ordinary differential equations).
- **Distributed-parameter systems:** State variables vary continuously across spatial dimensions, requiring representation as functions of both time and space (typically modelled with partial differential equations).

**Example**

Modelling the temperature of a small, well-stirred tank of liquid as a single value is a lumped-parameter approximation; modelling the temperature distribution along a long, unstirred metal rod — where temperature varies continuously with position — requires a distributed-parameter (partial differential equation) representation.

**Key Points**

- The lumped-parameter approximation is valid when spatial variation within the system is negligible relative to the scale of interest; otherwise, it can introduce significant modelling error. [Inference]
- Distributed-parameter models are computationally more demanding, often requiring spatial discretization techniques (finite difference, finite element) to simulate numerically.

### Composite Classification in Practice

Real systems are typically classified along several axes simultaneously, and the combination determines the appropriate simulation formalism and toolset.

===MERMAID_DIAGRAM===

flowchart TD

A["Real-World System (svg_diagram)"] --> B{"Environmental Exchange?"}

B -->|Open| C{"Time Representation?"}

B -->|Closed| C

C -->|Continuous| D{"State Domain?"}

C -->|Discrete-Time| D

C -->|Discrete-Event| D

D -->|Continuous-State| E{"Determinism?"}

D -->|Discrete-State| E

D -->|Hybrid| E

E -->|Deterministic| F["Candidate Formalism Selection"]

E -->|Stochastic| F

**Example**

A telecommunications network handling packet traffic is typically: open (exchanges data with external networks), discrete-event (state changes at packet arrival/departure events), discrete-state (queue lengths are integer-valued), stochastic (arrival times follow probability distributions), and potentially dynamic-structure (nodes and links can join or leave). This combination points directly toward a discrete-event stochastic simulation formalism rather than a continuous differential-equation approach.

### Implications for Formalism Selection

| System Profile | Typical Formalism |
| --- | --- |
| Continuous-state, continuous-time, deterministic, linear | State-space ODEs, transfer functions |
| Continuous-state, continuous-time, deterministic, nonlinear | Nonlinear ODEs, numerical integration |
| Discrete-state, discrete-event, stochastic | Discrete-event simulation (queueing, DEVS) |
| Discrete-state, discrete-time, stochastic | Markov chains, discrete-time stochastic processes |
| Continuous-state and discrete-state combined | Hybrid automata, hybrid DEVS |
| Distributed spatial variation | Partial differential equations, cellular automata, finite-element methods |

### Common Pitfalls

- **Treating axes as mutually exclusive:** Assuming a system must be purely one category or another along a single axis, rather than recognizing that most real systems require a joint classification across multiple axes simultaneously.
- **Ignoring hybrid behavior:** Forcing a genuinely hybrid system into a purely continuous or purely discrete formalism, which can obscure threshold-triggered behavior central to the system's actual dynamics. [Inference]
- **Overlooking time-variance:** Applying time-invariant analytical tools (e.g., standard transfer functions) to a system whose parameters meaningfully change over the simulation horizon.
- **Default assumption of determinism:** Modelling an inherently stochastic system deterministically by using only mean or expected values, thereby losing information about variability and risk that may be central to the study's purpose.

**Related Topics**

- System Environment and Interfaces
- Open versus Closed Systems
- Linear versus Nonlinear Systems
- Feedback Loops and Causality
- Discrete-Event Simulation Fundamentals
- Hybrid Systems and Zero-Crossing Detection
- Markov Chains and Stochastic Processes in Simulation
- Partial Differential Equations for Distributed-Parameter Systems