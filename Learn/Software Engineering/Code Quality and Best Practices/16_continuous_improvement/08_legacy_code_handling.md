## Legacy Code Handling


Effective management of legacy code requires a shift from "rewrite vs. maintain" binary thinking to a strategic approach involving stabilization, encapsulation, and incremental modernization. Legacy code is defined in this context not merely as "old" code, but as code that lacks automated tests, possesses high coupling, or exhibits high cognitive load, hindering rapid deployment.

### Strategic Assessment and Metrics

Before any code modification, an architectural audit must quantify technical debt and risk.

- **Hotspot Analysis:** Correlate file change frequency (churn) with cyclomatic complexity. High-churn, high-complexity modules are the primary candidates for refactoring. Code that is complex but rarely touched should be encapsulated, not rewritten.
    
- **Dependency Mapping:** Use static analysis tools (e.g., NDepend, Structure101) to generate directed graphs of module dependencies. Identify cycles and "god classes" that serve as coupling hubs.
    
- **Seam Identification:** Following Michael Feathers' methodology, identify "seams"—places where behavior can be altered without editing source code (e.g., through interface polymorphism, link substitution, or preprocessing directives).
    

### Stabilization via Characterization Tests

Refactoring without a safety net is negligent. Since legacy systems often lack requirements documentation, the current behavior _is_ the specification.

**The Golden Master Pattern:**

1. **Capture:** Record the inputs and outputs of a legacy component for a wide range of scenarios (the "Golden Master").
    
2. **Lock:** Treat this recorded state as the immutable truth.
    
3. **Refactor:** Make changes to the internal structure.
    
4. **Verify:** continuous regression testing against the Golden Master to ensure output parity.
    

Tools like **Approval Tests** or **Snapshots** are preferred over asserting specific values manually, as they can handle complex object graphs or large text outputs.

### Architectural Patterns for Modernization

#### Strangler Fig Pattern

Instead of a "Big Bang" rewrite, the Strangler Fig pattern incrementally replaces specific functionality.

1. **Intercept:** Place a proxy or routing facade in front of the legacy system.
    
2. **Route:** Direct traffic for new features or migrated endpoints to the new microservice/module.
    
3. **Fallback:** Default to the legacy system for unmigrated features.
    
4. **Eliminate:** Once the legacy system's traffic drops to zero for a specific module, decommission that code path.
    

#### Anti-Corruption Layer (ACL)

When integrating modern subsystems with legacy models, prevent the legacy domain model from leaking into the new architecture.

- **Implementation:** Create a translation layer (Adapter/Facade) that converts legacy data structures into clean, domain-centric entities used by the new system.
    
- **Benefit:** Allows the new system to evolve independently of the legacy schema's idiosyncrasies.
    

### Tactical Refactoring Techniques

When modification of the legacy source is unavoidable, specific techniques minimize the risk of regression.

#### Sprout Method / Class

Do not insert new logic directly into a massive, tangled method.

1. **Sprout:** Write the new logic in a completely new method or class, TDD-style.
    
2. **Call:** Insert a call to this new code from the legacy location.
    

- _Advantage:_ The new code is tested and clean; the legacy code changes are minimal (one line).
    

#### Wrap Method

Used when adding behavior before or after an existing legacy method call is required.

1. **Rename:** Rename the existing method `legacy_method()`.
    
2. **Create:** Create a new method with the original name.
    
3. **Delegate:** Call `legacy_method()` inside the new method, placing new logic before or after the call.
    

### Database Evolution: Expand and Contract

Database refactoring in legacy systems requires zero-downtime deployments. The **Parallel Run** (or Expand-Contract) pattern is standard:

1. **Expand:** Add the new column/table. Update the application to write to _both_ the old and new locations, but read from the old.
    
2. **Migrate:** Run a background script to copy historical data from old to new structures.
    
3. **Switch (Contract Phase 1):** Update the application to read from the new location.
    
4. **Cleanup (Contract Phase 2):** Remove the code writing to the old location and drop the old schema elements.
    

### Anti-Patterns in Legacy Handling

- **The "Big Rewrite" Delusion:** attempting to rebuild the entire system from scratch while the legacy system continues to evolve. This almost always results in a "feature chase" where the rewrite never catches up to the legacy system's feature set.
    
- **Shotgun Surgery:** Making small changes across many classes to implement a single feature. This indicates low cohesion and requires introducing a facade or mediator to centralize the logic before modification.
    
- **Refactoring Without Baseline:** modifying logic to "clean it up" without first establishing a failing test or a characterization test suite. This is effectively introducing bugs by definition.
    

Related Topics:

- Refactoring Patterns
    
- Domain-Driven Design (DDD)
    
- Test Driven Development (TDD)
    
- Microservices Migration Strategies

---

