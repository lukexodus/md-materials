## Dependency direction


Dependency direction dictates the architectural integrity of a system. Random or convenience-based dependencies lead to "Spaghetti Code" and circular references (The "Big Ball of Mud"). Controlling the direction of dependencies is the primary mechanism for enforcing architectural boundaries.

**Key Points**

- **Uni-directional Flow:** Dependencies should flow in one direction. Cycles (A depends on B, B depends on A) must be eliminated.
    
- **Stability Rule:** Dependencies should always point in the direction of stability. A module that changes frequently should depend on a module that changes rarely, not vice versa.
    
- **Abstraction Rule:** Dependencies should point toward abstractions (Interfaces/Abstract Classes), not concretions.
    

The Dependency Inversion Principle (DIP)

This principle flips the traditional procedural dependency graph. Instead of high-level policy (Business Logic) depending on low-level detail (Database/UI), both should depend on abstractions.

- **Flow of Control:** UI $\to$ Business Logic $\to$ Database
    
- **Flow of Dependency:** UI $\to$ Business Logic $\leftarrow$ Database Interface (implemented by Database)
    

By inverting the dependency, the Business Logic becomes the most stable, independent layer, immune to changes in the database or UI frameworks.

Stable Dependencies Principle (SDP)

The stability of a module is defined by how hard it is to change.

- Modules intended to be flexible (UI, Presenters) should depend on modules intended to be stable (Core Entities, Use Cases).
    
- If a stable module depends on a flexible one, the flexible module becomes difficult to change (it becomes "rigid"), violating the architecture.
    

Acyclic Dependencies Principle (ADP)

The dependency graph of packages must have no cycles. Cycles tightly couple modules, forcing them to be released, tested, and built together as a monolith.

- **Resolution:** If a cycle exists, break it by introducing a new interface (DIP) or creating a new common package that both modules depend on.
    

Architectural Boundaries

In modern architectures (Clean, Hexagonal, Onion), the dependency rule is strict: Source code dependencies must point only inward, toward high-level policies.

- **Outer Layer:** Frameworks, Drivers, UI, Database (Volatile)
    
- **Middle Layer:** Interface Adapters, Controllers, Gateways
    
- **Inner Core:** Enterprise Business Rules, Entities (Stable)
    

The Inner Core must know nothing about the Outer Layer. No name, class, or constant from the outer circle should be mentioned in the inner circle.

---

