## Breaking Change Management


### Semantic Versioning (SemVer) Enforcement

Strict adherence to SemVer (Major.Minor.Patch) is the foundational contract for dependency management.

- **Major (X.y.z):** Incompatible API changes.
    
- **Minor (x.Y.z):** Backward-compatible functionality additions.
    
- **Patch (x.y.Z):** Backward-compatible bug fixes.
    

Automated Enforcement:

Do not rely on human discipline to determine version bumps.

- **Conventional Commits:** Enforce a commit message standard (e.g., Angular convention). Commits containing `BREAKING CHANGE:` in the footer must trigger a major version bump in the CI pipeline.
    
- **API Diffing Tools:** Integrate tools like `Revapi` (Java), `ApiCompat` (.NET), or `Microsoft.OpenApi.Hidi` into the build process. These tools compare the public API surface of the current build against the previous release. The build must fail if a breaking change is detected without a corresponding major version increment.
    

### The Parallel Support (N-1 Compatibility) Strategy

Breaking changes must never be instantaneous "switch-over" events in distributed systems. A "Expand and Contract" (or Parallel Change) pattern is required.

Phase 1: Expansion (Additive Changes)

Introduce the new implementation alongside the old one. The API or library supports both the old and new signatures/endpoints simultaneously.

- **Database:** Add a new column; do not rename the old one. Write to both, read from the new (with fallback to old).
    
- **API:** Introduce `/v2/resource` while `/v1/resource` remains active.
    

Phase 2: Deprecation (Warning Phase)

Mark the old implementation as deprecated.

- **Code:** Use language-specific attributes (`@Deprecated` in Java, `[Obsolete]` in C#, `@deprecated` JSDoc).
    
- **Runtime:** Inject warning headers (e.g., `Deprecation` or `Sunset` HTTP headers per RFC 8594) into responses from the old API endpoints. Include a specific date for end-of-life (EOL).
    
- **Logs:** Log usage of deprecated features on the server side to monitor adoption rates of the new version.
    

Phase 3: Contraction (Removal)

Once metrics confirm zero (or acceptable) traffic on the old path, remove the legacy code. This cleanup prevents technical debt accumulation.

### API Evolution Without Versioning (GraphQL & gRPC)

Strict versioning (v1, v2) is often considered an anti-pattern in modern RPC frameworks like gRPC and query languages like GraphQL, which favor continuous evolution.

- **Field Deprecation:** Mark fields as deprecated rather than removing them.
    
    - _GraphQL:_ Use the `@deprecated` directive on schema fields. Clients requesting these fields receive a warning in the `extensions` part of the response.
        
    - _Protobuf:_ Use the `deprecated = true` option. Reserve the field number of deleted fields using `reserved 2, 15, 9 to 11;` to prevent future reuse, which would cause data corruption if an old binary talks to a new binary.
        
- **Additive-Only Schema:** New requirements must be met by adding new fields, not modifying existing types. If a field's type must change, introduce a new field with a new name (e.g., `userId` (int) -> `userIdString` (string)).
    

### Database Schema Evolution

Database migrations are the most frequent source of breaking changes in monolithic and microservice architectures.

- **Locking Hazards:** `ALTER TABLE` operations on large tables can lock the database, causing downtime.
    
    - **Best Practice:** Use tools like `gh-ost` (GitHub Online Schema Transitions) or `pt-online-schema-change` to perform non-blocking schema changes.
        
- **Destructive Changes:**
    
    - **Renaming Columns:** Never rename a column in a single deployment. The application code will query the old name while the DB has the new name.
        
    - **Correct Flow:** Add new column -> Backfill data -> Change code to read/write new column -> Remove old column.
        
    - **Not Null Constraints:** Adding a `NOT NULL` constraint to an existing column is a breaking change if the table is not empty. Default values must be applied first.
        

### Consumer-Driven Contracts (CDC)

In a microservices environment, a provider service does not know which fields its consumers rely on. "Guessing" if a change is breaking is risky.

- **Pact Testing:** Implement Consumer-Driven Contract testing (e.g., using Pact). Consumers define expectations (contracts) for the provider's API.
    
- **Pipeline Verification:** The provider's CI pipeline runs these contracts against the new build. If a change breaks a specific consumer's contract, the build fails, preventing the deployment of the breaking change.
    
- **Benefit:** Allows the provider to safely remove unused fields (if no contract exists for them) and strictly prevents breaking active consumers.
    

### Feature Flags and Toggles

Decouple deployment from release.

- **Kill Switches:** Wrap the new logic in a feature flag. If the "breaking" change introduces unexpected side effects (e.g., performance regression), it can be instantly disabled via configuration without a rollback deployment.
    
- **Canary Releases:** Enable the breaking change for a small percentage of internal traffic first, then gradually roll out to the user base.
    

### Anti-Patterns

- **Silent Failures:** Changing behavior without changing the contract. For example, changing the time zone of a timestamp field from Local to UTC without renaming the field or changing the data type. This breaks downstream logic without triggering schema validation errors.
    
- **"Big Bang" Migrations:** Requiring the database schema and application code to be deployed at the exact same millisecond. This guarantees downtime.
    
- **Breaking the Build:** Committing breaking changes to the `main` branch without a version bump, causing all dependent internal projects to fail their builds immediately upon update.
    

### Related Topics

- Semantic Versioning Specification
    
- Blue-Green and Canary Deployment Strategies
    
- Database Refactoring Patterns
    
- Microservices Contract Testing
    
- API Gateway Versioning Strategies

---

