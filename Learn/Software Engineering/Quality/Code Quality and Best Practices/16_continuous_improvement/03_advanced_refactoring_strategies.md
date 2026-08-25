## Advanced Refactoring Strategies


### Architectural Refactoring Patterns

Refactoring at the architectural level requires strategies that maintain system uptime and data integrity while fundamentally altering structure.

1. The Parallel Change (Expand-Migrate-Contract)

Used for breaking API changes or database schema modifications where downtime is unacceptable. This pattern decouples the release of the interface from the implementation.

- **Phase 1: Expand (Additive Change):** Introduce the new parameter, method, or database column alongside the existing one. The system must write to _both_ but read from the _old_.
    
- **Phase 2: Migrate:** Update all call sites (clients) to use the new signature. For databases, run background jobs to backfill data from the old column to the new one. Switch read operations to the new source.
    
- **Phase 3: Contract (Destructive Change):** Once monitoring confirms 0% traffic on the old path, remove the old code/schema.
    
- **Constraint:** Requires three separate deployment cycles.
    

2. Branch by Abstraction

An alternative to long-lived feature branches when replacing a core component (e.g., swapping an ORM or a payment gateway).

- **Abstraction Layer:** Create an interface that wraps the _existing_ legacy implementation.
    
- **Client Retargeting:** Refactor all client code to call the interface, not the concrete legacy class.
    
- **New Implementation:** Build the new concrete implementation of the interface in isolation within the main trunk.
    
- **Toggle Switching:** Use a Feature Flag to route traffic to the new implementation dynamically, enabling granular rollouts (e.g., 1% traffic) and instant rollback.
    

3. Strangler Fig Pattern

Specific to Monolith-to-Microservice migration.

- **Facade Injection:** Place an API Gateway or HTTP proxy in front of the legacy monolith.
    
- **Route Interception:** Identify a specific bounded context (e.g., "User Profile"). Build a new microservice for this context.
    
- **Traffic Routing:** Configure the proxy to route `/user` requests to the new service while defaulting all other traffic to the monolith.
    
- **Attrition:** Gradually "strangle" the monolith by migrating contexts one by one until the monolith is redundant.
    

### Targeted Code-Level Techniques

Replace Conditional with Polymorphism

Addresses the "Switch Statement Smell" where code inspects type codes to determine behavior.

- **Detection:** High Cyclomatic Complexity in a single method checking `if (type == A) ... else if (type == B)`.
    
- **Implementation:**
    
    1. Create an abstract base class or interface.
        
    2. Create subclasses for each case in the conditional.
        
    3. Move the specific logic into the overridden method of the subclass.
        
    4. Replace the switch statement with a factory that instantiates the correct subclass.
        
- **Benefit:** Adheres to the Open/Closed Principle; adding a new type requires adding a class, not modifying existing logic.
    

Extract Method Object

Applied when a method is too large and local variables differ in scope, making standard "Extract Method" impossible due to parameter passing overhead.

- **Procedure:**
    
    1. Create a new class named after the method.
        
    2. Promote the method's local variables to private fields of the new class.
        
    3. Move the method's logic into a `.compute()` or `.invoke()` method on the new class.
        
    4. Refactor the original method to instantiate the object and call `.compute()`.
        
- **Enabler:** This isolates the complex logic, allowing further refactoring (like extracting helper methods) without passing parameters, as they share the object's state.
    

Introduce Parameter Object

Fixes "Data Clumps" where groups of parameters (e.g., startDate, endDate) are passed together across multiple methods.

- **Action:** Create an immutable DTO (Data Transfer Object) or Record (Java 14+/C# 9+) to encapsulate these fields.
    
- **Advanced Application:** Move behavior related to those data points _into_ the new object. For example, a `DateRange` object can validate that `start < end`, moving validation logic out of the service layer and into the domain model (Domain-Driven Design).
    

### Refactoring Legacy Code (The "Seams" Approach)

When refactoring code without tests, standard techniques are dangerous. The priority is establishing a "Seam"—a place to alter behavior without editing source code.

**Link Seams**

- **Technique:** Overriding the classpath or library linking to substitute a dependency with a mock during testing.
    
- **Use Case:** C/C++ or Java environments where a production `.jar` or `.o` file can be replaced by a test double at compile/link time.
    

**Object Seams**

- **Technique:** Subclassing a legacy class and overriding a method that has hard-coded external dependencies.
    
- **Example:** A `save()` method calls a static `Database.connect()`.
    
    - _Refactor:_ Extract `Database.connect()` into a protected method `getDatabaseConnection()`.
        
    - _Test:_ Create a `TestableSave` subclass that overrides `getDatabaseConnection()` to return a mock.
        

### Refactoring Anti-Patterns

**Refactoring Tunneling**

- **Symptom:** Developer enters a refactoring loop, losing track of the original goal. The codebase remains in a broken state for days.
    
- **Correction:** The "Mikado Method." Set a goal. Try to implement it. If the compiler fails, revert changes, note the prerequisite, and solve the prerequisite first. Repeat until the goal is achievable in one atomic step.
    

**Shotgun Surgery**

- **Symptom:** A single refactoring action forces minor changes in many different classes.
    
- **Root Cause:** Poor cohesion. The responsibility is distributed rather than centralized.
    
- **Remediation:** "Move Method" and "Move Field" to consolidate the logic into a single governing class before modifying the behavior.
    

**Refactoring with Feature Development**

- **Violation:** Mixing refactoring commits with behavior-changing commits (features or bug fixes).
    
- **Risk:** If the feature introduces a bug, the git bisect process becomes difficult because the refactoring noise obscures the logic change.
    
- **Standard:** The "Two Hats" metaphor (Kent Beck). You wear the Refactoring Hat (structure change, behavior static) OR the Feature Hat (structure static, behavior change). Never both simultaneously.
    

### Metrics-Driven Refactoring

Refactoring efforts must be quantifiable to justify resource allocation.

- **Churn vs. Complexity Graph:** Focus refactoring on files with _High Churn_ (frequently changed) and _High Complexity_. Files with high complexity but low churn are "stable junk" and should be ignored (ROI is low).
    
- **Distance from Main Sequence (DMS):** Measures the balance between abstractness and instability. Refactor packages that are "Zones of Pain" (highly stable, highly concrete) to be more abstract (introduce interfaces).

---

