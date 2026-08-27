## Model Abstraction and Level of Detail

### Definitions

**Abstraction** in modelling and simulation is the deliberate act of omitting aspects of a real system that are judged irrelevant to the questions the model is meant to answer, while retaining the aspects that are relevant. Every model is necessarily an abstraction — no model reproduces its target system in full, since a perfect one-to-one reproduction would be as complex as the system itself and would offer no analytical or computational advantage.

**Level of detail** (also called resolution or granularity) refers to how finely the retained aspects of the system are represented — how many components are individually modeled, how precisely their behavior is captured, and how fine the time and space discretization is.

Abstraction and level of detail are related but distinct: abstraction decides *what* to include or exclude; level of detail decides *how finely* the included elements are represented.

### Why Abstraction Is Necessary

**Key Points**
- Real systems contain effectively unbounded detail (down to molecular or quantum scales, in the physical limit); no model can or should capture all of it.
- Including irrelevant detail increases computational cost, data requirements, and model complexity without improving the answer to the question being asked.
- Excluding relevant detail produces a model that fails to reproduce the behavior of interest, regardless of how well it's implemented.
- The correct level of abstraction is defined relative to the model's **purpose**, not by an objective standard of "completeness."

**Example**

Modelling a car's fuel consumption for a trip-planning application:

- **Appropriate abstraction**: represent the car as a single point with an average fuel-consumption rate (L/100km) as a function of speed and terrain grade — sufficient for estimating trip fuel usage.
- **Inappropriate under-abstraction** (too coarse): treating fuel consumption as a constant regardless of speed or terrain, which would fail to capture the fact that consumption varies significantly with driving conditions.
- **Inappropriate over-abstraction avoidance** (too fine): individually modelling each cylinder's combustion cycle, fuel injector timing, and airflow dynamics — physically accurate, but computationally unnecessary and irrelevant to a trip-planning question.

### Spectrum of Abstraction Levels

Abstraction exists on a spectrum, not as a binary choice. Consider modelling traffic on a road network:

| Level | Representation | Captures | Typical Use |
|---|---|---|---|
| Microscopic | Individual vehicles, driver behavior, car-following rules | Lane changes, individual acceleration/braking, collision dynamics | Intersection design, driver-assist system testing |
| Mesoscopic | Vehicle groups/platoons, probabilistic transition rules | Aggregate flow patterns, congestion propagation | Corridor-level traffic management |
| Macroscopic | Traffic as a continuous fluid (density, flow, speed fields) | System-wide flow, average travel time | City-wide network planning, long-term infrastructure decisions |

Each level is a legitimate model — the choice depends entirely on what question is being asked. A macroscopic model cannot answer questions about individual driver behavior at an intersection; a microscopic model of an entire city's road network would likely be computationally prohibitive and would provide far more resolution than a network-planning question requires.

### Diagram: Abstraction Level versus Question Scope

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 320">
  <text x="380" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Abstraction Level vs Model Purpose (svg_diagram)</text>

  <line x1="80" y1="270" x2="700" y2="270" stroke="#333" stroke-width="1.5" />
  <text x="390" y="300" text-anchor="middle" font-size="12" fill="#333">Level of Detail (fine → coarse)</text>

  
  <rect x="100" y="180" width="150" height="70" fill="#eff6ff" stroke="#2563eb" stroke-width="1.5" />
  <text x="175" y="210" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">Microscopic</text>
  <text x="175" y="228" text-anchor="middle" font-size="10" fill="#333">Individual vehicles</text>
  <text x="175" y="242" text-anchor="middle" font-size="10" fill="#333">High compute cost</text>

  
  <rect x="305" y="140" width="150" height="70" fill="#f0fdf4" stroke="#16a34a" stroke-width="1.5" />
  <text x="380" y="170" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">Mesoscopic</text>
  <text x="380" y="188" text-anchor="middle" font-size="10" fill="#333">Vehicle groups</text>
  <text x="380" y="202" text-anchor="middle" font-size="10" fill="#333">Moderate cost</text>

  
  <rect x="510" y="100" width="150" height="70" fill="#fef2f2" stroke="#dc2626" stroke-width="1.5" />
  <text x="585" y="130" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">Macroscopic</text>
  <text x="585" y="148" text-anchor="middle" font-size="10" fill="#333">Traffic as fluid</text>
  <text x="585" y="162" text-anchor="middle" font-size="10" fill="#333">Low compute cost</text>

  <path d="M 250 215 L 305 175" stroke="#666" stroke-width="1" marker-end="url(#arrow1)" />
  <path d="M 455 175 L 510 135" stroke="#666" stroke-width="1" marker-end="url(#arrow1)" />

  <text x="175" y="90" text-anchor="middle" font-size="10" fill="#666">Intersection</text>
  <text x="175" y="104" text-anchor="middle" font-size="10" fill="#666">design</text>
  <text x="380" y="90" text-anchor="middle" font-size="10" fill="#666">Corridor</text>
  <text x="380" y="104" text-anchor="middle" font-size="10" fill="#666">management</text>
  <text x="585" y="70" text-anchor="middle" font-size="10" fill="#666">City-wide</text>
  <text x="585" y="84" text-anchor="middle" font-size="10" fill="#666">planning</text>
</svg>

### Factors Governing the Choice of Abstraction Level

**Key Points**
- **Purpose of the model**: the specific question(s) the model must answer is the primary determinant.
- **Required accuracy**: how precise must the output be for the intended decision-making use.
- **Available data**: fine-grained models require fine-grained input data; if such data doesn't exist or can't be obtained, a fine level of detail may not be achievable regardless of intent.
- **Computational budget**: time and resource constraints on running the simulation, especially for models requiring many replications (relevant when combined with stochastic modelling) or real-time operation.
- **Time horizon of interest**: short-term, detailed transient behavior versus long-term aggregate trends.

### The Trade-off: Fidelity versus Tractability

Increasing the level of detail generally increases **fidelity** (how closely the model matches real-system behavior at the level captured) but also increases:

- Computational cost (often nonlinearly, e.g., $O(n^2)$ or worse for models with pairwise interactions between $n$ entities)
- Data collection and calibration burden
- Model complexity, which can introduce more parameters to estimate and more potential sources of error
- Difficulty of verification and validation, since more detailed models have larger state spaces to check

[Inference] This trade-off is often described as a point of diminishing returns: beyond a certain level of detail, additional fidelity contributes little to answering the question at hand while continuing to add cost — though where that point lies is problem-specific and is not derivable from general principles alone; it is typically established empirically through sensitivity analysis on the specific model.

### Common Pitfalls

- **Over-modelling**: including detail that does not affect the answer to the question being asked, wasting computational and development effort, and potentially introducing unnecessary sources of error through parameters that cannot be reliably estimated.
- **Under-modelling**: omitting a mechanism that turns out to materially affect the output, producing a model that appears to run correctly but gives systematically wrong answers.
- Conflating "more detailed" with "more accurate" — a highly detailed model calibrated with poor or insufficient data can be less accurate than a coarser model calibrated well, since detailed models typically have more parameters that each carry estimation uncertainty.
- Choosing the level of abstraction based on what data happens to be available, rather than what the question requires, without acknowledging the resulting limitation on what the model can validly answer.

**Related Topics**
- Model validation and verification
- Sensitivity analysis
- Multi-resolution and multi-scale modelling
- Model calibration and parameter estimation
- Aggregation and disaggregation techniques
- Computational complexity in simulation
- Model purpose and requirements specification