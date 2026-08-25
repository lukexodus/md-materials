## YAML Configuration


### Strict Schema Validation

Relying on implicit structure is a primary cause of configuration drift and runtime failures. Implementing rigorous schema validation is mandatory for production-grade systems.

- **JSON Schema Integration:** Since YAML is a superset of JSON, JSON Schema should be utilized to define strict contracts for YAML files. CI pipelines must reject any configuration that does not validate against the defined schema.
    
- **Type Enforcement:** Explicitly define types for all keys. Ambiguity between strings, integers, and booleans (e.g., `version: 1.10` parsed as floating point `1.1` vs. string `"1.10"`, or country codes like `NO` parsed as boolean `false`) must be mitigated through schema constraints.
    
- **Required Fields and Defaults:** The schema must distinguish between optional and required fields. Defaults should be applied at the application logic layer or via a pre-processing step, not implicitly assumed by the consumer, to maintain determinism.
    

### Structural Integrity and Modularity

Monolithic configuration files degrade maintainability and increase the blast radius of erroneous changes.

- **Modularization Strategy:** Decompose large configurations into domain-specific files (e.g., `database.yaml`, `logging.yaml`). Use aggregation tools (like Kustomize for Kubernetes or Spring Boot's profile mechanism) to compose the final runtime configuration.
    
- **Anchors and Aliases (`&` and `*`):**
    
    - **Usage:** Use anchors to adhere to DRY (Don't Repeat Yourself) principles for repeated data structures.
        
    - **Constraint:** Limit anchor usage to within a single file context. Over-reliance on complex inheritance chains via anchors reduces readability and makes debugging configuration parsing errors difficult.
        
    - **Merge Keys (`<<`):** Use merge keys sparingly to override specific values in inherited maps. Be aware of the limitations regarding list merging, which standard YAML parsers often handle by replacement rather than appending.
        

### Type Safety and Quoting Rules

YAML's flexibility in type inference is a liability in strict environments.

- **Explicit Quoting:**
    
    - **Strings:** Always quote strings that contain special characters, resemble booleans (`"true"`, `"false"`, `"yes"`, `"no"`, `"on"`, `"off"`), or resemble numbers (versions like `"1.20"`).
        
    - **Octal/Hex:** Be cautious of unquoted numbers starting with `0`, which some parsers interpret as octal.
        
- **Boolean Literals:** Adhere to the strict YAML 1.2 boolean specification (`true`, `false`) and avoid 1.1 compatibilities (`yes`, `no`) to prevent parser-specific behavior discrepancies.
    

### Secrets Management Integration

Configuration files committed to version control must **never** contain plaintext secrets.

- **Externalization:** References to secrets should use placeholder tokens or lookup keys (e.g., `password: ${VAULT_KEY}`).
    
- **Encryption at Rest:** If secrets must reside within the YAML file (e.g., GitOps workflows), use tools like SOPS (Secrets OPerationS) or Sealed Secrets to encrypt values while keeping keys plaintext.
    
- **Environment Variable Substitution:** Design the configuration loader to support environment variable expansion syntax (e.g., `${ENV_VAR:-default}`) to facilitate 12-Factor App principles.
    

### Linting and Static Analysis

Automated enforcement of style guides prevents formatting wars and syntax errors.

- **Tooling:** Integrate `yamllint` into the pre-commit hook and CI process.
    
- **Rule Configuration:**
    
    - **Indentation:** Enforce 2 spaces strictly. Tab characters are forbidden in YAML and result in parsing errors.
        
    - **Line Length:** Enforce soft wrapping or explicit line breaks for long strings using scalar block styles (`|` for preserving newlines, `>` for folding).
        
    - **Key Ordering:** While maps are unordered, enforcing alphabetical key sorting in output files (if generated) aids in diff readability during code reviews.
        

### Versioning and Evolution

Configuration schemas evolve. Managing backward compatibility is critical for service reliability.

- **ApiVersion Pattern:** Include a mandatory `apiVersion` or `schemaVersion` field at the root of the YAML document. This allows the parsing logic to select the correct deserialization strategy or migration path.
    
- **Deprecation Policy:** When deprecating fields, the parser should emit warnings (logs) when encountering obsolete keys, rather than failing silently or crashing, allowing for a grace period for updates.
    

### Anti-Patterns

- **Logic in Configuration:** Avoid embedding complex logic or executable code within YAML strings. If conditional logic is required, push it to the templating engine (Helm, Jinja2) or the application code.
    
- **Deep Nesting:** excessive nesting (depth > 4) indicates poor schema design and should be flattened to improve readability and cognitive load.
    
- **Implicit Key Overwrites:** When merging multiple YAML files, ensure the merge strategy (deep merge vs. shallow replace) is explicitly defined and documented to prevent accidental data loss.

---

