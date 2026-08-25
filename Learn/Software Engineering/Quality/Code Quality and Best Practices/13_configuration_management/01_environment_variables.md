## Environment Variables


### Security and Secret Management

While the Twelve-Factor App methodology advocates for storing configuration in environment variables, utilizing them for sensitive secrets (API keys, database credentials, private keys) introduces significant attack vectors in modern infrastructure.

- **Process Exposure:** Environment variables are accessible to any process running under the same user privileges. In compromised containerized environments, an attacker gaining shell access can dump all secrets via `printenv` or by inspecting `/proc/<pid>/environ`.
    
- **Leakage via Logging and Error Reporting:** Standard error handlers and APM (Application Performance Monitoring) tools often capture the process environment snapshot during a crash. Unsanitized environment dumps result in secrets persisting in log aggregators (Splunk, ELK) or third-party error tracking services (Sentry), often in plain text.
    
- **Child Process Inheritance:** By default, child processes inherit the parent's environment. Implicitly passing sensitive tokens to third-party subprocesses (e.g., calling an external CLI tool) violates the principle of least privilege.
    
- **Mitigation Strategy:** Use environment variables strictly for **references** to secrets or non-sensitive configuration (endpoints, timeout values). Retrieve actual secret payloads at runtime from dedicated secret management systems (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) or mount them as tmpfs volumes in Kubernetes to avoid disk persistence.
    

### Strict Schema Validation and Type Coercion

Environment variables are inherently string-based. A common source of runtime failure is ad-hoc parsing and lack of validation at application startup.

- **Fail-Fast Architecture:** Applications must validate the existence and format of all required environment variables immediately upon initialization. Missing configuration should prevent the application from starting (CrashLoopBackOff in Kubernetes) rather than causing `NullReferenceException` or `undefined` errors deep within the business logic during execution.
    
- **Type Safety Layer:** Implement a centralized configuration adapter that reads raw environment strings and marshals them into a strictly typed configuration object. This layer handles type coercion (e.g., parsing "true" to Boolean, "5000" to Integer) and enforces constraints (e.g., port range 1-65535, URL format validity).
    
- **Immutable Configuration:** Once loaded and validated, the configuration object should be immutable (singleton or dependency injected) to prevent runtime mutation of application state.
    

### Infrastructure-as-Code and CI/CD Pipeline Integration

The lifecycle of an environment variable differs significantly between build-time and run-time, impacting build reproducibility and artifact portability.

- **Build-Time vs. Run-Time Injection:**
    
    - **Build-Time (Anti-Pattern for Config):** Baking environment variables into the build artifact (e.g., `ARG` in Dockerfile resulting in hardcoded values in the image) tightly couples the artifact to a specific environment. This requires rebuilding the image for staging, production, or DR.
        
    - **Run-Time (Standard):** Inject configuration during container instantiation. This allows a single "Build Once, Deploy Anywhere" artifact.
        
- **Front-End nuances:** Single Page Applications (SPAs) typically require build-time injection (e.g., `process.env` replacement in Webpack/Vite) because the code executes in the user's browser, which has no access to the server's environment. For dynamic configuration in SPAs, serve a `config.js` generated at container startup or expose a dedicated configuration API endpoint.
    

### Containerization and Orchestration Patterns

In Kubernetes and Docker ecosystems, environment variables serve as the primary bridge between infrastructure definition and application logic.

- **ConfigMap vs. Secret Separation:** Strictly distinguish between non-sensitive data (`ConfigMap`) and sensitive data (`Secret`). Although both can be projected as environment variables, this separation aids in RBAC (Role-Based Access Control) policies—developers may need read access to ConfigMaps but not Secrets.
    
- **Dependent Environment Variables:** Applications should not rely on the order of variable declaration. If `DB_HOST` and `DB_PORT` are defined, the application must construct the connection string internally. Avoid relying on shell expansion within the environment definition itself (e.g., `DB_URL=${DB_HOST}:${DB_PORT}`) unless the orchestration platform explicitly supports dependent variable resolution (e.g., Kubernetes 1.2+ specific features).
    

### Anti-Patterns

- **Hardcoded Fallbacks:** Avoid `const port = process.env.PORT || 3000`. This pattern obscures the dependency on external configuration. If a variable is required, the application should fail if it is missing. If a default exists, it should be defined in a central configuration schema, not scattered throughout usage sites.
    
- **The `.env` Commitment:** Never commit `.env` files to version control. These files are intended for local development overrides only. Use `.env.example` or `.env.template` with sanitized placeholder values to document required keys for other developers.
    
- **Overloading Semantics:** Do not use environment variables to control complex logic flow (e.g., `FEATURE_X_ENABLED=true`). While acceptable for simple toggles, complex feature flagging should be managed via a dedicated Feature Flag management system (LaunchDarkly, Unleash) to allow for granular targeting, percentage rollouts, and runtime toggling without restarts.

---

