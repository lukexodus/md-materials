## Feature Flags


### Decoupling Deployment from Release

The primary architectural advantage of feature flags is the separation of code deployment (binary installation) from feature release (user exposure). This capability is foundational to Continuous Delivery (CD).

- **Dark Launching:** Code is deployed to production in a dormant state. This eliminates long-lived feature branches and merge hell, allowing developers to merge into `main` frequently (Trunk-Based Development).
    
- **Granularity:** Releases can be targeted to specific user segments (internal testers, beta users, percentage rollouts) rather than an all-or-nothing switch.
    
- **Kill Switch Mechanism:** Operational flags act as circuit breakers. If a newly released feature causes latency spikes or error rate regression, it can be disabled instantly without rolling back the entire binary, preserving system stability.
    

### Taxonomy and Longevity

Misclassifying flags leads to technical debt. Flags must be categorized by their intended lifespan and volatility.

- **Release Toggles:** Short-lived. Used to hide incomplete features. **Must** be removed immediately after the feature is successfully released to 100% of users.
    
- **Experiment Toggles (A/B Testing):** Short-to-medium lifespan. Used for multivariate testing. Require removal once the experiment concludes and a winner is determined.
    
- **Ops Toggles:** Long-lived. Control operational aspects (e.g., log verbosity, detailed tracing, disabling non-critical subsystems under load). These become permanent system configuration.
    
- **Permission Toggles:** Long-lived. Manage feature availability based on user tiers (e.g., Premium vs. Free). These essentially function as dynamic authorization logic.
    

### Technical Debt and Lifecycle Management

Stale feature flags are a primary source of cyclomatic complexity and dead code.

- **Expiration Strategy:** Every temporary flag must have an associated expiration date or a "time-to-live" metadata tag. CI/CD pipelines should trigger alerts or fail builds if active flags exceed their allowed lifespan.
    
- **Code Cleanup:** The definition of "Done" for a feature includes the removal of the flag. This involves deleting the `if/else` block and the flag definition from the configuration store.
    
- **Limiting Concurrency:** Limit the number of active flags in the system. High flag concurrency creates a combinatorial explosion of system states ($2^n$), making the system impossible to reason about or fully test.
    

### Implementation Patterns

- **Router/Middleware Injection:** Evaluate flags at the edge or middleware layer rather than deep within business logic. This keeps domain code clean and agnostic of the flagging infrastructure.
    
- **Strategy Pattern:** Encapsulate flag logic using the Strategy design pattern. Instead of scattering `if (flag.enabled)` checks, inject different implementations of an interface based on the flag state.
    
- **Contextual Evaluation:** Flag evaluation must be context-aware. Pass a context object (containing User ID, Tenant ID, Region, Device Type) to the evaluation engine to enable granular targeting rules (e.g., "Enable for 10% of users in `us-east-1` on iOS").
    

### Database Schema Evolution (Expand-Contract)

Feature flags cannot instantly toggle database schema changes. The **Expand-Contract (Parallel Change)** pattern is required for stateful features.

1. **Expand:** Add new columns/tables. The application writes to **both** old and new locations but reads from the old.
    
2. **Migrate:** Backfill data from old to new structures.
    
3. **Toggle Read:** Flip the feature flag to read from the new location.
    
4. **Contract:** Remove the old columns/tables and the double-writing logic once the feature is stable.
    

### Testing Strategies

Testing every permutation of feature flags is computationally infeasible.

- **Default State:** Unit tests should run with flags in their default production state.
    
- **Toggle-Specific Tests:** Explicitly configure the test harness to force specific flags `on` or `off` only when testing the specific code paths guarded by those flags.
    
- **Production Parity:** Integration/E2E tests in staging environments must mimic the current production flag configuration to catch regression issues related to flag interactions.
    

### Performance and Reliability

- **Local Caching:** Network calls to a remote feature flag management service (SaaS or centralized DB) for every flag evaluation introduce unacceptable latency. Implement aggressive local caching (in-memory) with streaming updates or short TTLs for synchronization.
    
- **Fallback Defaults:** The flag evaluation client must have hardcoded fallback values (`true`/`false`) to use in the event of a connection failure with the flag management system. The application must fail open or fail closed deterministically.
    
- **Consistency (Sticky Sessions):** For percentage-based rollouts, use deterministic hashing (e.g., `hash(userID + flagKey) % 100`) to ensure a user remains in the same bucket across multiple requests and server instances. Random number generation at runtime is an anti-pattern for user-facing consistency.

---

