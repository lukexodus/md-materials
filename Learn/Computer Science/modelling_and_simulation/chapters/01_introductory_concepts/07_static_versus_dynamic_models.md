## Static versus Dynamic Models

### Definitions

A **static model** represents a system at a single point in equilibrium or at a fixed instant, with no explicit representation of time. The relationships in the model are expressed as algebraic or steady-state equations: given a set of inputs, the model returns a set of outputs, without reference to how the system arrived at that state or how it will evolve afterward.

A **dynamic model** represents a system whose state changes over time. The model explicitly includes time (or a time-like index) as a variable, and its behavior is typically expressed through differential equations (continuous time) or difference equations (discrete time), where the current state depends on previous states.

The defining distinction is not complexity or realism — it is whether **time is a first-class variable** in the model's formulation.

### Static Models

**Key Points**
- Output depends only on current input values, not on history.
- No memory of past states; no state variables persist between evaluations.
- Typically solved with algebraic methods, linear algebra, or optimization at a single instant.
- Common in steady-state analysis: the system is assumed to have already settled.

**Example**

A simple static model of electrical resistance under Ohm's Law:

$$V = IR$$

Given $I$ and $R$, $V$ is fully determined. There is no notion of "how $V$ got there" or "what $V$ will be next" — the equation holds instantaneously and independently of time.

Another common static model is a linear regression relating input $x$ to output $y$:

$$y = \beta_0 + \beta_1 x + \varepsilon$$

This describes a relationship, not a trajectory.

### Dynamic Models

**Key Points**
- Output at time $t$ depends on the system's state at earlier times (or on the immediately preceding state, in discrete formulations).
- State variables persist and evolve; the model has "memory."
- Solved via integration (continuous) or iteration (discrete), typically requiring initial conditions.
- Used to study transient behavior, stability, oscillation, growth/decay, and system response over time.

**Example**

A continuous-time dynamic model of a charging capacitor in an RC circuit:

$$\frac{dV(t)}{dt} = \frac{1}{RC}\left(V_{source} - V(t)\right)$$

This requires an initial condition $V(0)$ and describes how $V$ evolves toward $V_{source}$ over time — the trajectory itself is the object of interest, not just the final value.

A discrete-time dynamic model, such as a simple population growth difference equation:

$$P_{n+1} = P_n + r P_n (1 - P_n / K)$$

Here $P_{n+1}$ explicitly depends on $P_n$; the model has state that carries forward across iterations.

### Structural Comparison

| Aspect | Static Model | Dynamic Model |
|---|---|---|
| Time representation | Absent or implicit | Explicit (continuous or discrete) |
| State variables | None persist | Persist and evolve |
| Typical equations | Algebraic | Differential / difference |
| Solution method | Direct evaluation, root-finding, optimization | Integration, iteration, numerical solvers |
| Requires initial conditions | No | Yes |
| Captures transient behavior | No | Yes |
| Example domains | Steady-state circuit analysis, cross-sectional statistical models | Control systems, epidemiology, structural vibration |

### Relationship Between the Two

A dynamic model's **equilibrium points** — where the state stops changing — can often be recovered by setting the time-derivative (or the difference) to zero and solving algebraically, which effectively yields a static model as a special case.

For the RC circuit example, setting $\frac{dV}{dt} = 0$:

$$0 = \frac{1}{RC}\left(V_{source} - V\right) \implies V = V_{source}$$

This recovers the static steady-state result. [Inference] In general, a static model can often be interpreted as the equilibrium (fixed-point) solution of some underlying dynamic model, though not every static model is derived this way in practice — some are constructed directly from empirical or cross-sectional relationships with no dynamic counterpart ever formulated.

### Diagram: Conceptual Distinction

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Static vs Dynamic Model Behavior (svg_diagram)</text>

  
  <rect x="40" y="60" width="320" height="240" fill="none" stroke="#888" stroke-width="1.5" />
  <text x="200" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Static Model</text>
  <line x1="70" y1="260" x2="330" y2="260" stroke="#333" stroke-width="1.5" />
  <line x1="70" y1="260" x2="70" y2="100" stroke="#333" stroke-width="1.5" />
  <text x="200" y="285" text-anchor="middle" font-size="11" fill="#333">Input</text>
  <text x="50" y="180" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 50 180)">Output</text>
  <circle cx="150" cy="200" r="5" fill="#2563eb" />
  <circle cx="220" cy="150" r="5" fill="#2563eb" />
  <circle cx="280" cy="120" r="5" fill="#2563eb" />
  <text x="200" y="320" text-anchor="middle" font-size="10" fill="#666">Each point: one input to one output, instantaneously</text>

  
  <rect x="400" y="60" width="320" height="240" fill="none" stroke="#888" stroke-width="1.5" />
  <text x="560" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Dynamic Model</text>
  <line x1="430" y1="260" x2="690" y2="260" stroke="#333" stroke-width="1.5" />
  <line x1="430" y1="260" x2="430" y2="100" stroke="#333" stroke-width="1.5" />
  <text x="560" y="285" text-anchor="middle" font-size="11" fill="#333">Time</text>
  <text x="410" y="180" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 410 180)">State</text>
  <path d="M 430 240 C 480 235, 500 150, 560 130 C 620 115, 660 108, 690 105" fill="none" stroke="#dc2626" stroke-width="2" />
  <text x="560" y="320" text-anchor="middle" font-size="10" fill="#666">Trajectory: state evolves continuously from initial condition</text>
</svg>

### Selection Criteria: Which Model Type to Use

**Key Points**
- Use a **static model** when only the end-state or equilibrium behavior matters, and transient/time-dependent behavior is irrelevant to the question being asked.
- Use a **dynamic model** when the process of change itself is the subject of study — startup transients, oscillations, delays, feedback effects, or time-to-reach-equilibrium.
- [Inference] In practice, many simulation studies begin with a static model to validate steady-state behavior against known values, then extend to a dynamic formulation once the static case is confirmed correct — though this sequencing is a methodological convention rather than a strict requirement.

### Common Pitfalls

- Treating a dynamic system with a static model when transients matter (e.g., analyzing inrush current in a motor using only steady-state Ohm's Law will miss the current spike at startup).
- Failing to specify initial conditions for a dynamic model, which makes the model under-determined and unsolvable.
- Assuming a static model's equilibrium is always reachable or stable — a dynamic system may have an equilibrium point that is never actually reached, or is unstable and diverges from it. [Inference] This depends on the specific dynamics (e.g., eigenvalues of a linearized system) and cannot be assumed from the static model alone.

**Related Topics**
- Continuous-time versus discrete-time dynamic models
- State-space representation of dynamic systems
- Equilibrium and stability analysis
- Deterministic versus stochastic models
- Linear versus nonlinear models
- Numerical integration methods for solving dynamic models (Euler, Runge-Kutta)
- Steady-state versus transient analysis in engineering contexts