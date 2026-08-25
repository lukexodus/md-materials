## Twelve-Factor Configuration


### Strict Decoupling of Code and Configuration

The fundamental tenet of the Twelve-Factor App methodology regarding configuration is the absolute separation of executable code from configuration data.1 Configuration is defined as anything that varies between deploys (staging, production, developer environments), while code remains static.2

**Violation Criteria:**

- Any constant in the codebase that distinguishes environments (e.g., hardcoded IP addresses, domain names, or credentials).
    
- Configuration files committed to the Version Control System (VCS) that contain environment-specific values (e.g., `config/production.yaml` vs. `config/development.yaml`).
    

Architectural Standard:

A codebase acts as a "Twelve-Factor App" only if the source code can be open-sourced immediately without compromising any credentials or leaking environment-specific logic.

### Environment Variables as the Source of Truth

Configuration must be stored in **environment variables** (env vars), not in flat files managed within the project directory.3

**Technical Rationale:**

- **Language Agnosticism:** Env vars are a standard supported by every operating system and programming language.
    
- **Granularity:** They allow granular control over individual configuration parameters without modifying file structures.
    
- **Orthogonality:** They are orthogonal to the language-specific configuration parsers (e.g., Java Properties, Python ConfigParser), decoupling the deployment mechanism from the application runtime.
    

Implementation Constraint:

Do not group environment variables under a single "environment" bucket (e.g., setting only APP_ENV=production). This leads to brittle logic where the application implicitly assumes settings based on the environment name. Instead, explicitly define every dependent variable: DB_HOST, REDIS_PORT, FEATURE_X_ENABLED.

### Backing Services as Attached Resources

All backing services (databases, message queues, SMTP servers, caching layers) must be treated as attached resources accessed via configuration.4 The application code must make no distinction between a local MySQL database and a managed RDS instance.

Best Practice:

Use strict resource locators (DSNs or Connection Strings) stored in environment variables.

- **Bad:** Storing `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME` separately and constructing the connection string in code. This couples the code to a specific database driver's format.
    
- **Good:** `DATABASE_URL=postgres://user:pass@host:5432/dbname`. 5The application simply passes this string to the connection adapter.
    

### Build, Release, Run Separation

Configuration must be strictly injected during the **Run** phase, never the **Build** phase.

- **Build Phase:** Converts code to an executable bundle (artifact).6 This artifact must be immutable.
    
- **Release Phase:** Combines the immutable build artifact with the specific configuration for the target environment.7
    

CI/CD Impact:

Embedding configuration files or using "build-time" environment variables (e.g., Webpack DefinePlugin for backend logic) violates this principle. If a configuration change requires a rebuild of the application binary or container image, the architecture is non-compliant.

### Managing Internal Configuration State

While the source of configuration is environment variables, the internal application representation should be a strongly-typed, immutable structure validated at startup.

**The Configuration Singleton Pattern:**

1. **Read:** On startup, read all relevant `process.env` (or equivalent) values.
    
2. **Validate:** Assert presence and type correctness (e.g., ensure `MAX_THREADS` is an integer). Fail the process immediately if validation fails ("Crash Fast").
    
3. **Map:** Convert valid inputs into an immutable internal configuration object.
    
4. **Inject:** Pass this object via Dependency Injection to components.
    

_Anti-Pattern:_ Accessing `os.getenv('VAR_NAME')` deep within business logic methods. This hides dependencies and makes testing difficult.

### Handling Secrets and Sensitive Data

Twelve-Factor configuration inherently supports secret management best practices by keeping secrets out of the repo.8

Runtime Injection:

In containerized environments (Kubernetes, Docker Swarm), secrets should be mounted as environment variables at the process level.

- **Kubernetes:** Map `Secret` objects to `env` directives in the Pod spec.
    
- **Security Note:** Be cautious of environment variable leakage in logs or process dumps. Configure loggers to sanitize output and ensure strict permissions on the `/proc` filesystem in Linux environments to prevent unauthorized inspection of process environments.

---

