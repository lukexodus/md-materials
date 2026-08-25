## JSON Configuration


### Schema Validation and Type Safety

For enterprise-grade applications, relying on implicit structure in JSON configuration files is a critical vulnerability. Implementation must utilize **JSON Schema** (Draft 2020-12 or Draft 07) to enforce strict contract testing between the configuration file and the consuming application.

**Implementation Standards:**

- **Strict Typing:** Explicitly define `type` for every property. Avoid `any` types or loose definitions that allow type coercion during parsing.
    
- **Prohibit Unknown Properties:** Set `"additionalProperties": false` at the root and nested object levels. This prevents "config drift" where deprecated or typoed keys remain in the file, misleading developers into believing settings are active.
    
- **Enum vs. Free Text:** Use `enum` for finite sets of configuration options to eliminate magic strings and invalid state injection.
    
- **CI/CD Integration:** Validate configuration files against their schemas during the build pipeline. Use tools like `ajv-cli` to fail builds if configuration files violate the schema.
    

JSON

```
{
  "$schema": "./config-schema.json",
  "type": "object",
  "properties": {
    "retryPolicy": {
      "type": "object",
      "properties": {
        "maxAttempts": { "type": "integer", "minimum": 1, "maximum": 5 },
        "backoffStrategy": { "type": "string", "enum": ["linear", "exponential"] }
      },
      "required": ["maxAttempts", "backoffStrategy"],
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

### Separation of Secrets and Configuration

A pervasive anti-pattern is embedding sensitive credentials (API keys, database passwords) directly within JSON configuration files committed to Version Control Systems (VCS).

**Architectural Enforcement:**

- **Externalization:** JSON configuration should strictly define _structural_ and _behavioral_ settings. Secrets must be injected at runtime via environment variables or fetched from a dedicated secrets manager (e.g., HashiCorp Vault, AWS Secrets Manager).
    
- **Placeholder Syntax:** If the JSON parser supports preprocessing, use a strict placeholder syntax (e.g., `${DB_PASSWORD}`) that fails the application startup if the corresponding environment variable is missing.
    
- **GitHooks:** Implement pre-commit hooks (e.g., `git-secrets`, `talisman`) to scan JSON files for high-entropy strings or known key patterns before commits are accepted.
    

### Immutability and Runtime Loading

Configuration state should be immutable once the application initializes. Modifying the in-memory representation of the JSON config during runtime leads to unpredictable behavior, race conditions, and debugging complexity.

**Best Practices:**

- **Singleton Pattern:** Load and validate the JSON configuration exactly once at the application entry point.
    
- **Object Freezing:** In languages supporting it (e.g., JavaScript/Node.js `Object.freeze()`, Java `Collections.unmodifiableMap`), deep-freeze the configuration object immediately after parsing.
    
- **Hot Reloading Constraints:** If hot reloading is required, it must be handled via a discrete event-driven mechanism that swaps the entire configuration instance atomically, rather than mutating properties of the existing instance.
    

### Linting and Formatting Standards

JSON syntax is unforgiving. To maintain code quality and prevent syntax errors that halt deployment, enforce rigorous linting rules.

- **Standardization:** Enforce strict formatting using tools like Prettier. Inconsistent indentation or line breaks creates noise in code reviews.
    
- **Syntax Constraints:**
    
    - **Trailing Commas:** Standard JSON (RFC 8259) prohibits trailing commas. Ensure linters flag this to prevent parser failures in strict environments.
        
    - **Comments:** JSON does not support comments. Do not attempt to use "hacky" keys like `"_comment": "..."` as this pollutes the data model. If comments are strictly necessary for documentation, switch to **JSON5** or **JSONC** (JSON with Comments) and add a transpilation step in the build process to output valid standard JSON.
        

### Handling Large Configuration Files

Monolithic `config.json` files exceeding 500 lines create merge conflicts and cognitive overload.

**Modularization Strategy:**

- **File Splitting:** Decompose configuration by domain (e.g., `logging.json`, `database.json`, `features.json`).
    
- **Aggregator Pattern:** Implement a configuration loader that merges these disparate files into a single internal configuration object at runtime.
    
- **Hierarchical Overrides:** Implement a strictly defined override order (e.g., `default.json` < `environment.json` < `local-override.json`). Ensure the merge logic performs a **deep merge** rather than a shallow replacement to preserve nested default settings.
    

### Numeric Precision and Parsing Risks

JSON specifications do not distinguish between integers and floating-point numbers. This ambiguity can lead to precision loss when handling large integers (e.g., 64-bit IDs) in environments like JavaScript or older browsers, which treat all numbers as IEEE 754 double-precision floats.

**Mitigation:**

- **String Serialization:** Always serialize 64-bit integers, monetary values, or high-precision IDs as **strings** in the JSON file.
    
- **Parser Configuration:** Configure backend parsers (e.g., Jackson in Java, `json.Decoder` in Go) to strictly fail on type mismatches rather than attempting implicit coercion.

---

