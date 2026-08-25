## Move Refactoring


### Architectural Drivers and Cohesion Analysis

Move Refactoring—encompassing Move Method, Move Field, Move Class, and Move Module—is the primary mechanism for realigning a codebase with evolving domain models. The architectural objective is to maximize **functional cohesion** (code that changes together stays together) and minimize **efferent coupling** (dependencies on external modules).

**Indicators for Refactoring:**

- **Feature Envy:** A method accesses the data of another object more frequently than its own data. This indicates the method resides in the wrong context and should be moved to the data owner.
    
- **Divergent Change:** A single class is modified for multiple unrelated reasons (e.g., business logic updates vs. serialization updates). This necessitates splitting and moving responsibilities to new delegates.
    
- **Shotgun Surgery:** A single domain change requires small edits across many distinct classes. This suggests the logic is fragmented and should be centralized (Move Method/Field) into a coherent unit.
    

### Execution Strategy: The Parallel Change Pattern

In complex or distributed systems, "Stop the World" refactoring is unfeasible. A non-breaking, incremental approach using the Parallel Change (Expand-Contract) pattern is required.

1. **Expand (Copy & Adapt):** Copy the target artifact (method/class) to the new location. Adapt specific references (e.g., changing `this.field` to `source.field`).
    
2. **Deprecate (Forward):** Modify the original artifact to act as a proxy or forwarding stub. It should delegate execution to the new location. Add deprecation warnings (`@Deprecated`, `DeprecationWarning`) to signal consumers.
    
3. **Migrate:** Update internal call sites to use the new location. For public APIs, this phase allows external consumers time to update.
    
4. **Contract (Delete):** Once usage drops to zero (verified via static analysis or runtime logging), remove the original forwarding stub.
    

### Handling State and Dependencies

Move Field (Data Locality):

Moving state is riskier than moving behavior. When moving a field:

- **Encapsulation:** Ensure the field is accessed via getters/setters in the source class before the move to create a seam.
    
- **Synchronization:** If the field is involved in concurrent operations, moving it alters the locking scope. A lock held on the source object will no longer protect the field in the target object.
    
- **Lifecycle Mismatches:** Ensure the target object has a lifecycle equal to or longer than the source. Moving a field from a Singleton to a Request-Scoped bean typically violates scoping rules.
    

Circular Dependencies:

Moving a class or function often triggers import cycles, particularly in languages like Python or Go.

- **Extraction:** If moving A to B causes a cycle because B depends on A, extract the shared dependencies into a generic module C, then have both A and B import C.
    
- **Interface Segregation:** Define an interface in the consumer module and implement it in the dependency module to invert the control flow.
    

### Risks and Edge Cases

Reflection and Dynamic Binding:

Standard IDE refactoring tools usually fail to identify references embedded in strings or configuration files.

- **Dependency Injection Containers:** XML or JSON configurations often reference classes by fully qualified names (e.g., `com.app.Service`). Moving the class breaks the application startup.
    
- **ORM Mappings:** Hibernate/JPA or ActiveRecord definitions may rely on directory structure or naming conventions that break upon relocation.
    
- **Serialization:** Moving a class changes its serialization UID or fully qualified name. Deserializing objects persisted prior to the move will fail unless migration hooks or aliases are implemented.
    

Version Control History:

Git tracks file movements heuristically based on content similarity.

- **Atomic Moves:** Do not modify code logic in the same commit as a file move. If the content changes significantly (>50%) simultaneously with a rename, Git will record it as a "Delete + Add," severing the `git blame` history.
    
- **Procedure:** `git mv old_path new_path` -> Commit -> Refactor content -> Commit.
    

### Anti-Patterns in Relocation

- **Tramp Data:** Moving a method to a new class but passing the original class as a "god object" parameter to resolve dependencies. This increases coupling. The method should only receive the specific data it requires.
    
- **Orphaned Tests:** Moving production code without moving the corresponding unit tests. Tests must be effectively "moved" (renamed and updated) to maintain the documentation link between the unit and its specification.
    
- **Utility Dumpsters:** Moving logic that doesn't fit the current class into a generic `Utils` or `Helpers` class. This destroys cohesion. Logic should be moved to a domain concept, even if it requires creating a new Value Object or Service.
    

Related Topics: Dependency Injection, Domain-Driven Design (DDD), Cyclic Dependency Resolution, Static Analysis Tools.

---

