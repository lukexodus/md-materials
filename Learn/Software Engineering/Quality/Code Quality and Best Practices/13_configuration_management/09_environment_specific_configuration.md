## Environment-specific configuration


The strict separation of configuration from code is a fundamental tenet of cloud-native architecture (The Twelve-Factor App). Proper environment management ensures that the same immutable build artifact can be deployed across multiple environments (Development, QA, Staging, Production) without modification to the source code or binary.

### Configuration Hierarchy and Precedence

A robust configuration system must support a predictable hierarchy of sources. Values defined in higher-precedence layers must override those in lower layers. A standard precedence order, from highest to lowest, is:

1. **Command-Line Arguments:** Overrides for specific execution instances (e.g., `--port=8080`).
    
2. **Environment Variables:** The standard mechanism for containerized (Docker/Kubernetes) injection.
    
3. **Secrets Management Systems:** Values injected dynamically from vaults (e.g., HashiCorp Vault, AWS Secrets Manager) at runtime.
    
4. **Environment-Specific Configuration Files:** Files targeted to a specific tier (e.g., `config.production.yaml`), usually excluded from version control if they contain secrets.
    
5. **Base/Default Configuration:** Shared values common across all environments (e.g., `config.default.yaml`), committed to version control.
    

### Immutable Build Artifacts

**Principle:** Build artifacts (Docker images, JARs, binaries) must be environment-agnostic.

- **Anti-Pattern:** Building separate artifacts for each environment (e.g., `mvn build -P production`). This introduces the risk that the code tested in Staging is not byte-for-byte identical to the code running in Production.
    
- **Best Practice:** Embed configuration only at runtime. Use entrypoint scripts or orchestrator manifests (Kubernetes ConfigMaps) to inject values into the immutable artifact process.
    

### Type-Safe Configuration and Schema Validation

Treat configuration as an external API. The application must strictly validate the configuration schema upon initialization and fail fast if requirements are not met.

- **Schema Definition:** Define expected keys, data types, and allowed value ranges using strict typing (e.g., Pydantic in Python, Zod in TypeScript, or struct tags in Go).
    
- **Fail-Fast Strategy:** If a required variable (e.g., `DB_CONNECTION_STRING`) is missing or malformed (e.g., invalid URL format), the application must crash immediately during the bootstrap phase rather than failing silently or causing runtime exceptions later in the execution flow.
    

### Handling Secrets

Secrets (API keys, passwords, private keys) require distinct handling from standard configuration parameters.

1. **No Commits:** Never commit `.env` files or hardcoded secrets to version control. Use `.gitignore` and pre-commit hooks (e.g., `git-secrets`, `trufflehog`) to enforce this.
    
2. **Runtime Injection:** Inject secrets as environment variables only for the duration of the process.
    
3. **Memory Scrubbing:** In high-security contexts, ensure secrets are read into memory, used to initialize services, and then scrubbed from memory to prevent leakage via core dumps or heap analysis.
    

### Feature Flags vs. Environment Config

Do not conflate infrastructure configuration with application behavior toggles.

- **Infrastructure Config:** Changes _where_ the app runs or _what_ it connects to (e.g., Database Host, Redis Port).
    
- **Feature Flags:** Changes _how_ the app behaves (e.g., enabling a new UI component).
    

**Anti-Pattern:** Using environment names to drive logic.

JavaScript

```
// BAD: Brittle and hard to test
if (process.env.NODE_ENV === 'production') {
  sendEmail();
}
```

**Best Practice:** Decouple logic from environment names using explicit capability flags.

JavaScript

```
// GOOD: Configurable and testable
if (config.features.enableEmailNotifications) {
  sendEmail();
}
```

This allows "production-like" behavior to be enabled in a staging environment for testing purposes without tricking the application into thinking it is in production.

### Infrastructure as Code (IaC) Integration

In modern DevOps pipelines, environment configuration is often managed alongside infrastructure.

- **Parameter Stores:** Store configuration values in centralized parameter stores (e.g., AWS SSM Parameter Store).
    
- **Templating:** Use tools like Helm or Kustomize to template ConfigMaps and Secrets, ensuring that configuration changes are versioned, reviewed, and audited just like application code.
    

### Edge Cases and Pitfalls

- **Drift:** Over time, environments diverge. Automated provisioning tools (Terraform, Ansible) should be used to enforce state and eliminate configuration drift.
    
- **Logging Leaks:** Configure logging frameworks to automatically redact sensitive configuration keys (e.g., `API_KEY`, `PASSWORD`) from startup logs.
    
- **Lists and Arrays:** Parsing arrays from environment variables is error-prone. Use standard delimiters (e.g., comma-separated strings) and robust parsing logic, or prefer JSON-encoded strings for complex structures passed via environment variables.
    

Related topics: The Twelve-Factor App, Dependency Injection, Secret Management, Feature Toggles, Infrastructure as Code.

---

