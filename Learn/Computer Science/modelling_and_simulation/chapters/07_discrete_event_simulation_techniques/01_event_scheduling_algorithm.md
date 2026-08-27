## Event Scheduling Algorithm

The event scheduling algorithm is one of the foundational world-view approaches for implementing discrete-event simulation (DES). It structures a simulation as a chronologically ordered sequence of events, each of which represents an instantaneous change in system state at a specific point in simulated time. Rather than advancing time in fixed increments, the algorithm advances time directly to the moment of the next scheduled event, making it efficient for systems where state changes occur irregularly and are separated by idle periods.

### Core Concept

In the event scheduling world view, a simulation model is decomposed into a set of **events** — instantaneous occurrences that change the state of the system (e.g., "customer arrives," "machine breaks down," "service completes"). Each event is associated with an **event routine**: a block of logic executed when that event occurs, which updates state variables and may schedule new future events as a consequence. The simulation maintains a **future event list (FEL)**, a time-ordered queue of all events that have been scheduled but not yet executed. The simulation clock advances by jumping directly to the timestamp of the next event in the FEL, rather than stepping through time uniformly.

This is the defining characteristic that distinguishes event scheduling from time-slicing (fixed-increment) approaches: computational effort is spent only at moments when the system state actually changes.

### The Future Event List (FEL)

The FEL is the central data structure of the algorithm. Each entry (often called an **event notice**) typically contains:

- The **event time** — the simulated time at which the event is scheduled to occur.
- The **event type** — identifies which event routine should be executed.
- **Associated data** — any entity attributes or parameters needed by the event routine (e.g., which customer, which server).

The FEL must support efficient insertion (as new events are scheduled) and efficient extraction of the minimum-time element (as the next event is processed). Common underlying data structures include:

- **Priority queues / binary heaps** — $O(\log n)$ insertion and extraction, the most common choice in production simulation software.
- **Ordered linked lists** — Simple to implement but $O(n)$ insertion in the worst case.
- **Calendar queues** — A hashing-based structure designed specifically for event-list management, offering near-constant time performance under certain distributional assumptions. [Inference — performance depends on how well the event time distribution matches the calendar queue's bucket-width tuning]

### General Algorithm Structure

The event scheduling algorithm follows a consistent execution loop:

===MERMAID_DIAGRAM===
flowchart TD
    A[Initialize: set clock to 0, initialize state variables, schedule initial events into FEL] --> B{FEL empty or stopping condition met?}
    B -- Yes --> H[Terminate simulation, report statistics]
    B -- No --> C[Remove event with smallest time from FEL]
    C --> D[Advance simulation clock to that event's time]
    D --> E[Execute the event routine: update state variables]
    E --> F[Schedule any new future events triggered by this event]
    F --> G[Update cumulative statistics]
    G --> B
```

### Worked Example: Single-Server Queue

Consider a simple single-server queueing system (e.g., a checkout counter). Two event types govern the system: **arrival** and **departure** (end of service).

**State variables**: server status (idle/busy), number of customers in queue, queue contents.

**Event routines**:

1. **Arrival event**:
   - If server is idle: set server to busy, begin service, schedule a departure event at $t_{\text{current}} + \text{service time}$.
   - If server is busy: add the customer to the queue.
   - Schedule the next arrival event at $t_{\text{current}} + \text{interarrival time}$.

2. **Departure event**:
   - If the queue is non-empty: remove the next customer from the queue, begin their service, schedule a departure event at $t_{\text{current}} + \text{service time}$.
   - If the queue is empty: set server to idle.

**Example**

| Time | Event | Server Status | Queue Length | FEL After Processing |
|------|-------|---------------|---------------|----------------------|
| 0.0 | Initialize | Idle | 0 | Arrival @ 2.1 |
| 2.1 | Arrival | Busy | 0 | Arrival @ 5.4, Departure @ 6.0 |
| 5.4 | Arrival | Busy | 1 | Arrival @ 8.2, Departure @ 6.0 |
| 6.0 | Departure | Busy | 0 | Arrival @ 8.2, Departure @ 9.7 |
| 8.2 | Arrival | Busy | 1 | Arrival @ 11.0, Departure @ 9.7 |
| 9.7 | Departure | Busy | 0 | Arrival @ 11.0, Departure @ 13.5 |

Each row shows the clock jumping directly to the next event time — no computation occurs during the idle gaps between events (e.g., between $t=2.1$ and $t=5.4$), which is the central efficiency advantage of this approach over fixed time-increment simulation.

### Key Points

- The algorithm advances simulated time in variable jumps, moving directly from one event time to the next rather than stepping uniformly, which avoids wasted computation during periods of no state change.
- The future event list (FEL) is the core data structure, and its implementation efficiency (heap, calendar queue, etc.) directly determines the simulation's scalability to large numbers of events. [Inference — the practical impact of FEL implementation choice depends on event volume and event-time distribution characteristics of the specific model]
- Each event routine is self-contained: it updates state and may schedule new events, but does not directly execute other event routines.
- This world view is sometimes called the "event-oriented" approach, in contrast to the "process-oriented" and "activity-oriented" world views, which build on top of the same underlying event scheduling mechanics.

### Comparison with Other DES World Views

Event scheduling is one of three classical world views for structuring discrete-event simulation logic. It is often considered the lowest-level and most general of the three:

- **Event scheduling** — The modeler thinks explicitly in terms of events and writes routines describing what happens at each event. Offers maximum control and efficiency but can become difficult to manage as model complexity grows, since the logic for a single entity's lifecycle is scattered across multiple event routines.
- **Activity scanning** — The modeler thinks in terms of activities (durations) with associated conditions; the simulation engine scans all activities at each time step to determine which can start. Simpler to conceptualize but historically less computationally efficient due to repeated condition-scanning.
- **Process interaction** — The modeler describes the entire lifecycle of an entity (e.g., a customer's full journey through arrival, queueing, service, and departure) as a single process, and the simulation engine internally translates this into events and manages scheduling. This is the most widely used world view in modern simulation software (e.g., SimPy, Arena, Simio) because it is more intuitive to write and read, despite being implemented internally using event scheduling mechanics.

**Key Points**

- Process interaction and activity scanning are typically built as abstractions layered on top of an underlying event scheduling engine, meaning event scheduling remains the mechanical foundation of most DES software even when not exposed directly to the modeler.
- The choice of world view is primarily a modeling convenience trade-off rather than a difference in simulation power — all three are theoretically capable of representing the same class of systems.

### Diagram: Event Scheduling Timeline (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 220">
  <rect x="0" y="0" width="500" height="220" fill="#ffffff" />
  <text x="250" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Event Scheduling: Clock Advances by Jumps (svg_diagram)</text>

  <line x1="40" y1="120" x2="460" y2="120" stroke="#333333" stroke-width="2" />
  <polygon points="460,120 450,115 450,125" fill="#333333" />

  <circle cx="60" cy="120" r="5" fill="#2563eb" />
  <text x="60" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=0.0</text>
  <text x="60" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Init</text>

  <circle cx="150" cy="120" r="5" fill="#16a34a" />
  <text x="150" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=2.1</text>
  <text x="150" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Arrival</text>

  <circle cx="230" cy="120" r="5" fill="#16a34a" />
  <text x="230" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=5.4</text>
  <text x="230" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Arrival</text>

  <circle cx="270" cy="120" r="5" fill="#dc2626" />
  <text x="270" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=6.0</text>
  <text x="270" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Departure</text>

  <circle cx="360" cy="120" r="5" fill="#16a34a" />
  <text x="360" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=8.2</text>
  <text x="360" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Arrival</text>

  <circle cx="410" cy="120" r="5" fill="#dc2626" />
  <text x="410" y="145" text-anchor="middle" font-size="11" fill="#1a1a1a">t=9.7</text>
  <text x="410" y="105" text-anchor="middle" font-size="10" fill="#1a1a1a">Departure</text>

  <path d="M 90 165 Q 120 180 140 165" fill="none" stroke="#999999" stroke-width="1.5" stroke-dasharray="3,3" />
  <text x="115" y="195" text-anchor="middle" font-size="9" fill="#666666">no computation (idle gap)</text>

  <rect x="40" y="20" width="10" height="10" fill="#16a34a" y2="0" />
</svg>

### Advantages and Limitations

**Key Points**

- **Advantages**: Computationally efficient for systems with sparse or irregular event occurrences, since no processing time is spent on intervals with no state change; provides fine-grained, explicit control over system logic; forms a well-understood theoretical foundation with decades of established implementation practice.
- **Limitations**: Model logic for a single entity's behavior can become fragmented across multiple, separately defined event routines, making large models harder to read, debug, and maintain; the modeler is responsible for manually managing all scheduling logic and state transitions, increasing the risk of implementation errors (e.g., forgetting to reschedule an event); less intuitive for modeling entities with complex, multi-stage lifecycles compared to the process interaction world view.

### Implementation Considerations

- **Time representation**: Simulated time is typically stored as a floating-point or fixed-precision numeric value, and care must be taken with tie-breaking rules when multiple events share an identical timestamp (commonly resolved via a secondary priority or insertion-order rule).
- **Event cancellation**: Real-world models often require canceling a previously scheduled event (e.g., a machine breakdown event is canceled if the machine is decommissioned first); this requires the FEL to support efficient removal of arbitrary entries, not just the minimum.
- **Random variate generation**: Event times are frequently generated by sampling from probability distributions (e.g., exponential interarrival times, as introduced in the Monte Carlo paradigm), linking this topic directly to random number generation techniques.
- **Statistics collection**: Since state changes occur only at events, time-weighted statistics (e.g., average queue length over time) must be computed by tracking the duration between events, not by uniform periodic sampling.

### Next Steps

- Process Interaction World View — SimPy and Process-Based Modeling
- Activity Scanning World View
- Future Event List Data Structures — Heaps vs. Calendar Queues
- Discrete-Event Simulation as a Paradigm (parent topic)
- Random Variate Generation for Event Timing
- Queueing Theory Fundamentals for DES Models
- Simulation Clock Management and Time Advance Mechanisms
- Statistical Output Analysis for Discrete-Event Simulations