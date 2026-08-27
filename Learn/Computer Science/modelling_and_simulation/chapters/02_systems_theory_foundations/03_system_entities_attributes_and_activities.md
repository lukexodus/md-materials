## System Entities, Attributes, and Activities

### Definitions

An **entity** is an individual object or actor within a system that is distinguishable from other objects and is represented explicitly in the model. Entities are the "things" the model tracks — customers, machines, vehicles, documents, messages — as opposed to the environment or aggregate quantities surrounding them.

An **attribute** is a property that characterizes a particular entity, distinguishing it from other entities of the same type or describing its current condition. Attributes belong to entities; changing an entity's attribute does not, by itself, change the system's structure.

An **activity** is a defined process or operation that takes place over a span of time and changes the state of the system — typically by changing one or more entities' attributes, creating or destroying entities, or altering relationships between entities. An activity represents "what happens" between two points in time, as opposed to an **event**, which represents an instantaneous change at a single point in time (an event typically marks the start or end of an activity).

### Entities

**Key Points**
- Entities may be **permanent**, existing for the full duration of the simulation (a machine on a factory floor), or **temporary**, created and destroyed during the simulation run (a customer who arrives, is served, and departs).
- Entities are typically classified into **types** (or classes), where all entities of a given type share the same set of attributes, even though the attribute *values* differ between individual entities.
- The choice of what counts as a distinct entity, versus what is aggregated or abstracted away, follows directly from the level of abstraction chosen for the model, discussed previously.

**Example**

In a bank branch simulation: **customers** are temporary entities (created at arrival, destroyed at departure), while **tellers** are permanent entities (present for the full simulation, regardless of whether any customer is currently being served).

### Attributes

**Key Points**
- Attributes may be **static** (fixed for the entity's lifetime, e.g., a customer's transaction type set at arrival) or **dynamic** (changing during the simulation, e.g., a customer's current wait time, which increases as time passes).
- Attributes distinguish individual entities of the same type from one another — without attributes, all entities of a type would be behaviorally identical, which is rarely an accurate representation of a real system with individual variation.
- Attributes are typically what stochastic elements (introduced earlier) are attached to — e.g., a customer's service-time attribute might be drawn from a probability distribution at the moment the entity is created.

**Example**

A customer entity in the bank simulation might carry attributes: `arrival_time`, `transaction_type` (deposit, withdrawal, loan inquiry), `service_time` (drawn from a distribution depending on `transaction_type`), and `priority` (e.g., whether the customer has an appointment).

### Activities

**Key Points**
- An activity has a defined duration — it begins at one event and ends at a later event, and the system's state during the intervening interval reflects the activity being "in progress."
- Activity durations are frequently modelled as random variables, connecting directly to the stochastic modelling concepts discussed earlier — e.g., a service activity's duration might be drawn from an exponential or lognormal distribution.
- Multiple activities can occur concurrently for different entities (two tellers each serving a different customer simultaneously), or sequentially for the same entity (a customer's activity sequence: wait → be served → leave).

**Example**

The activity "teller serves customer" begins at the event "service starts" (when a teller becomes available and a customer begins being served) and ends at the event "service ends" (when the transaction is complete). During the activity, the teller's state is "busy" and the customer's state is "in service."

### Diagram: Entities, Attributes, and Activity Timeline

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 340">
  <text x="370" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Entity Lifecycle and Activity Timeline (svg_diagram)</text>

  
  <rect x="40" y="55" width="200" height="130" fill="#eff6ff" stroke="#2563eb" stroke-width="1.5" />
  <text x="140" y="78" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Entity: Customer #47</text>
  <text x="55" y="100" font-size="10" fill="#333">arrival_time = 09:14</text>
  <text x="55" y="117" font-size="10" fill="#333">transaction_type = deposit</text>
  <text x="55" y="134" font-size="10" fill="#333">service_time = 4.2 min</text>
  <text x="55" y="151" font-size="10" fill="#333">priority = normal</text>
  <text x="55" y="172" font-size="9" fill="#666" font-style="italic">(attributes)</text>

  
  <line x1="300" y1="230" x2="700" y2="230" stroke="#333" stroke-width="1.5" />
  <text x="500" y="255" text-anchor="middle" font-size="11" fill="#333">Time</text>

  
  <circle cx="330" cy="230" r="5" fill="#16a34a" />
  <text x="330" y="210" text-anchor="middle" font-size="10" fill="#16a34a">Arrival event</text>

  <circle cx="450" cy="230" r="5" fill="#d97706" />
  <text x="450" y="210" text-anchor="middle" font-size="10" fill="#d97706">Service starts</text>

  <circle cx="620" cy="230" r="5" fill="#dc2626" />
  <text x="620" y="210" text-anchor="middle" font-size="10" fill="#dc2626">Service ends</text>

  
  <rect x="330" y="270" width="120" height="20" fill="#fef3c7" stroke="#d97706" stroke-width="1" />
  <text x="390" y="284" text-anchor="middle" font-size="9" fill="#1a1a1a">Waiting (activity)</text>

  <rect x="450" y="270" width="170" height="20" fill="#fee2e2" stroke="#dc2626" stroke-width="1" />
  <text x="535" y="284" text-anchor="middle" font-size="9" fill="#1a1a1a">In service (activity)</text>

  <path d="M240 120 L 300 120" stroke="#666" stroke-width="1" stroke-dasharray="3,2" />
</svg>

### Relationship to Broader System Concepts

| Concept (this topic) | Relationship to earlier topics |
|---|---|
| Entity | Corresponds to what was called a component/element when discussing system structure |
| Attribute | A specific instance of a state variable, scoped to one entity, as introduced under system boundaries |
| Activity | The mechanism by which behavior (discussed previously) is actually generated over time |
| Event | The instantaneous marker separating one system state from the next, connecting directly to the static-versus-dynamic distinction — a system's state is piecewise constant between events |

### State Variables versus Attributes

**Key Points**
- Not every state variable is an entity attribute — some state variables describe the system as a whole rather than any single entity (e.g., "number of customers currently in the branch" is a system-level state variable, not an attribute of any individual customer).
- The full system state at any point in time is typically the combination of all entity attributes plus any system-level state variables plus the status of ongoing activities.
- [Inference] This distinction matters practically because entity attributes are usually tracked per-entity in a simulation's data structures (often as a record or object per entity), while system-level state variables are typically tracked separately as global or aggregate quantities — though the specific implementation approach depends on the simulation framework or language used.

### Common Pitfalls

- Conflating entity attributes with system-level state variables, leading to double-counting or inconsistent updates when an activity changes both.
- Failing to distinguish events (instantaneous) from activities (durational), which can produce ambiguity about what the system's state is at a given moment — particularly whether an entity should be considered to have "started" or "finished" a process at the boundary instant.
- Omitting an attribute that later turns out to drive behavior of interest, requiring rework of the entity definition after the model is already substantially built.
- Assigning attribute values without justifying their distributions or sources, which undermines the validity of any stochastic elements attached to those attributes (connecting back to the input-characterization concerns raised in the discussion of system boundaries).
- Treating all entities of a type as attribute-identical when real variation between them materially affects the behavior being studied, effectively reintroducing an inappropriate level of abstraction.

**Related Topics**
- Discrete-event simulation mechanics (event scheduling, event lists)
- Entity state charts and lifecycle modelling
- Queueing theory fundamentals
- Random variate generation for entity attributes
- Simulation clock advancement mechanisms
- Resource modelling (servers, queues, capacity constraints)
- Data structures for entity representation in simulation software