## Incremental Improvement


### Legacy Decomposition Patterns

Large-scale architectural improvements typically fail when attempted as "Big Bang" rewrites. Success relies on patterns that allow coexistence of legacy and modern implementations.

- **Strangler Fig Pattern:**
    
    - **Implementation:** Intercept calls at the edge (API Gateway or Reverse Proxy). Route traffic to the new microservice or module for specific endpoints while defaulting to the legacy monolith for unmigrated functionality.
        
    - **Edge Case - Shared State:** When the new implementation requires access to the legacy database, utilize a _Change Data Capture (CDC)_ pipeline (e.g., Debezium) to replicate data to the new store, rather than allowing direct shared database access, which couples the architectures.
        
    - **Termination:** The pattern is only complete when the legacy code path is fully dead and removed. Leaving "zombie" legacy code increases cognitive load and security surface area.
        
- **Branch by Abstraction:**
    
    - **Mechanism:** Introduce an abstraction layer (interface or facade) between the client code and the legacy implementation. Create a new implementation of this interface. Use a toggle or factory to switch between implementations at runtime.
        
    - **Application:** Essential for improving code deep within the dependency graph where HTTP routing (Strangler Fig) is inapplicable.
        
    - **Anti-Pattern:** Leaking implementation details of the legacy code into the abstraction interface, forcing the new implementation to mimic the quirks of the old one.
        

### The Mikado Method

For complex refactoring where dependencies form a cyclic or deeply nested graph, the Mikado Method provides a structured approach to prevent "refactoring rabbit holes."

1. **Set Goal:** Define the specific improvement (e.g., "Upgrade Hibernate Version").
    
2. **Experiment:** Attempt the change.
    
3. **Fail & Visualize:** When the build fails, note the immediate cause (the direct dependency blocking the change). Do _not_ fix it yet. Revert the code.
    
4. **Graphing:** Draw the goal and the blocking dependency as a prerequisite node in a directed graph.
    
5. **Iterate:** Make the prerequisite the new goal. Repeat until a leaf node (a change with no blocking dependencies) is found.
    
6. **Commit:** Implement the leaf node change and commit. Work backward up the graph.
    

This ensures the system is always in a deployable state, unlike long-lived feature branches which suffer from merge hell.

### Atomic Refactoring and Commit Strategy

Incremental improvement requires strict discipline in version control hygiene to separate behavioral changes from structural improvements.

- **Refactoring vs. Behavior Modification:**
    
    - **Strict Separation:** A commit should never include both a refactoring (e.g., Extract Method) and a behavior change (e.g., Bug Fix).
        
    - **Rationale:** If a regression occurs, `git bisect` must be able to identify whether the structural change or the logic change caused the issue. Combined commits obfuscate the root cause.
        
- **The "Campground" Constraints:**
    
    - While the Boy Scout Rule implies "leave the code cleaner," unconstrained cleanup leads to **Refactoring Cascades**.
        
    - **Constraint:** cleanup is limited to the _immediate context_ of the task. Modifying a shared utility class while working on a specific feature introduces unrelated risk and complicates code review.
        

### Quality Ratcheting

Automated tooling must be configured to prevent backsliding during the incremental improvement process.

- **The Ratchet Mechanism:**
    
    - Current metrics (e.g., code coverage: 75%) become the hard floor for future builds. If coverage drops to 74.9%, the build fails, even if the global threshold is lower.
        
    - **Implementation:** Tools like SonarQube "New Code" policies or specialized scripts in CI pipelines.
        
- **Deprecation Lifecycles:**
    
    - Mark internal APIs as `@Deprecated` with `forRemoval=true`.
        
    - **Hard Stop:** Configure the compiler or linter to treat usage of deprecated members as errors after a specific date or version milestone. This forces consumers to migrate incrementally rather than ignoring warnings indefinitely.
        

### Parallel Change (Expand and Contract)

Used specifically for database schema changes or API signature updates to ensure zero downtime.

1. **Expand:** Add the new column/method/table. The system writes to _both_ the old and new locations but reads from the old.
    
2. **Migrate:** Run background scripts to backfill data from the old structure to the new one.
    
3. **Switch:** Change the system to read from the new location. Writes still go to both (for rollback safety).
    
4. **Contract:** Stop writing to the old location. Remove the old column/method/table.
    

- **Critical Requirement:** The application must handle the intermediate state where data might be inconsistent if the backfill is lagging. Feature flags are mandatory here.

---

