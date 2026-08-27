## System Definition and Boundaries

### Definitions

A **system**, in the context of modelling and simulation, is a set of interrelated entities (components, elements, actors) that interact with one another to produce collective behavior, considered together for the purpose of a particular study. What counts as "the system" is not an inherent property of the physical world — it is a choice made by the modeller, scoped to the questions the model is intended to answer.

A **system boundary** is the explicit delineation between what is included inside the system (and therefore represented within the model) and what is excluded and treated as external. Everything outside the boundary that still affects the system is captured, if at all, only through its influence crossing the boundary — not through its own internal behavior being modelled.

### Why Boundaries Must Be Defined Explicitly

**Key Points**
- No system exists in true isolation; every real system interacts with something beyond itself (energy sources, surrounding environment, other systems, external actors).
- Without an explicit boundary, it is unclear which interactions must be modelled explicitly and which can be simplified or ignored, leading to either unbounded model scope or arbitrary, undocumented omissions.
- The boundary determines what appears as an **input** (something crossing into the system from outside) versus an **internal state or process** (something represented and evolving within the model).
- Boundary choice interacts directly with the abstraction level chosen for the model: a wider boundary generally requires representing more entities and interactions, increasing model scope and complexity.

**Example**

Modelling a single manufacturing plant's production throughput:

- **Inside the boundary**: machines, workstations, in-plant material handling, worker shift schedules, production scheduling logic.
- **Outside the boundary, treated as inputs**: raw material deliveries (represented as an arrival process, not modelled as the supplier's own internal operations), electricity supply (represented as available/unavailable, not modelled as the power grid's generation and distribution), customer orders (represented as a demand stream, not modelled as the customer's own decision process).

If the study question changes — for example, to "how does supplier reliability affect plant throughput" — the boundary must be redrawn to bring supplier behavior inside the system, since it is no longer acceptable to treat it as a black-box input.

### Components of a System Description

**Key Points**
- **Entities**: the individual objects or actors within the system (machines, customers, vehicles, agents).
- **Attributes**: properties characterizing each entity (a machine's processing rate, a customer's arrival time).
- **State variables**: the set of variables whose values, at any given time, fully describe the condition of the system as relevant to the study.
- **Inputs (exogenous variables)**: quantities originating outside the boundary that affect the system but are not affected by it (assuming no feedback crosses back out).
- **Outputs**: quantities produced by the system, of interest to the study, that may cross the boundary outward.
- **Environment**: everything outside the boundary that can influence the system's inputs but is not itself modelled in detail.

### Diagram: System, Boundary, and Environment

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">System Boundary and Environment (svg_diagram)</text>

  
  <rect x="40" y="60" width="620" height="290" fill="#fafafa" stroke="#999" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="60" y="82" font-size="12" fill="#666">Environment (outside boundary, not modelled in detail)</text>

  
  <rect x="180" y="120" width="340" height="180" fill="#eff6ff" stroke="#2563eb" stroke-width="2" />
  <text x="350" y="145" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">System</text>

  
  <circle cx="260" cy="200" r="24" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="260" y="204" text-anchor="middle" font-size="10" fill="#1a1a1a">Entity A</text>

  <circle cx="350" cy="230" r="24" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="350" y="234" text-anchor="middle" font-size="10" fill="#1a1a1a">Entity B</text>

  <circle cx="440" cy="190" r="24" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="440" y="194" text-anchor="middle" font-size="10" fill="#1a1a1a">Entity C</text>

  <line x1="280" y1="210" x2="330" y2="225" stroke="#333" stroke-width="1" />
  <line x1="370" y1="220" x2="420" y2="200" stroke="#333" stroke-width="1" />

  
  <path d="M 80 210 L 175 210" stroke="#16a34a" stroke-width="2" marker-end="url(#arrowIn)" />
  <text x="128" y="200" text-anchor="middle" font-size="10" fill="#16a34a">Input</text>

  
  <path d="M 525 210 L 610 210" stroke="#dc2626" stroke-width="2" marker-end="url(#arrowOut)" />
  <text x="568" y="200" text-anchor="middle" font-size="10" fill="#dc2626">Output</text>

  <text x="350" y="335" text-anchor="middle" font-size="10" fill="#666">Interactions crossing the boundary are inputs/outputs; internal interactions are modelled explicitly</text>
</svg>

### Open Systems versus Closed Systems

| Aspect | Open System | Closed System |
|---|---|---|
| Boundary interaction | Exchanges inputs/outputs with environment | No exchange with environment (idealized) |
| Realism | Most real-world systems modelled this way | Rare in practice; a simplifying idealization |
| Example | A factory (receives materials, ships products) | An idealized isolated thermodynamic system |
| Modelling implication | Must define and characterize inputs from environment | Environment can be omitted entirely from the model |

[Inference] Most systems studied in practical modelling and simulation work are open systems, since a fully closed system that exchanges nothing with its environment is rarely an accurate representation of anything a study would need to examine — closed systems tend to appear mainly as simplifying idealizations within a larger analysis, rather than as the object of study itself.

### Factors Governing Where the Boundary Is Drawn

**Key Points**
- **Study objectives**: the boundary must be wide enough to include every entity and interaction whose behavior materially affects the answer to the study's question, and no wider.
- **Feedback loops**: if an entity outside a candidate boundary is significantly affected by the system's output, and that effect in turn feeds back to affect the system, excluding it may misrepresent the system's dynamic behavior; such feedback is a strong signal that the entity belongs inside the boundary.
- **Available data and control**: entities that cannot be observed, measured, or meaningfully modelled with available data may need to remain outside the boundary and be represented as a simplified input, even if their inclusion would in principle improve fidelity.
- **Level of abstraction chosen**: a coarser abstraction level can sometimes justify a narrower boundary, since interactions with excluded entities may be adequately captured through simplified aggregate inputs rather than detailed representation.

### Common Pitfalls

- Drawing the boundary too narrowly, excluding an entity whose interaction with the system materially affects the behavior being studied — producing a model that appears internally consistent but does not answer the intended question.
- Drawing the boundary too widely, incorporating entities whose behavior does not affect the study's outputs, adding unnecessary complexity and data requirements without improving the answer.
- Treating the boundary as fixed regardless of a change in study objective — a boundary appropriate for one question may be inappropriate once the question changes, as shown in the supplier-reliability example above.
- Failing to explicitly characterize inputs crossing the boundary (their distribution, variability, or dependency on system outputs), which can silently reintroduce the errors that a poorly chosen boundary was meant to avoid.
- Ignoring feedback loops that cross the boundary in both directions, which can cause a model to miss dynamics that only emerge from the interaction between system and environment.

**Related Topics**
- Entities, attributes, and state variables in system modelling
- Model scope and requirements definition
- Feedback loops and closed-loop system behavior
- Input characterization and exogenous variable modelling
- System decomposition and hierarchical modelling
- Conceptual modelling as a precursor to simulation design