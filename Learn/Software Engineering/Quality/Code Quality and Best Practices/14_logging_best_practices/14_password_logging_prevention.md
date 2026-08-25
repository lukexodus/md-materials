## Password Logging Prevention


The accidental persistence of plaintext credentials (passwords, API keys, tokens, CVV codes) in system logs constitutes a critical security vulnerability (OWASP Top 10: Security Logging and Monitoring Failures). Prevention requires a defense-in-depth architecture that assumes developer error will occur and implements safeguards at the compilation, runtime, and infrastructure levels.

### Object Serialization and String Representation

The most common leakage vector occurs when developers implicitly or explicitly invoke `toString()` on Data Transfer Objects (DTOs) or Entities containing sensitive fields.

- **Lombok and Boilerplate Risks:** Libraries like Lombok (`@Data`) or IDE-generated `toString()` methods default to including all fields. This is catastrophic for User or Authentication objects.
    
    - **Strict Exclusion:** Use `@ToString.Exclude` (Java/Lombok) or equivalent exclusion markers in other languages on sensitive fields.1
        
    - **Identity-Only logging:** Enforce a policy where entities are logged only by their immutable IDs, never by their state.
        
- **JSON Serialization:** When logging JSON payloads (Structured Logging), the serialization engine (Jackson, Gson, etc.) must be configured to ignore sensitive properties.
    
    - **Annotation Control:** Use `@JsonIgnore` or `@JsonProperty(access = Access.WRITE_ONLY)` to ensure credentials can be deserialized from a request but never serialized into a log message.
        
    - **Mix-ins:** For third-party classes where source code cannot be modified, register Serialization Mix-ins to overlay ignorance rules externally.
        

### Middleware and HTTP Traffic Logging

Logging full HTTP requests/responses for debugging is valuable but dangerous. Standard implementations often blindly dump the `Authorization` header or the JSON body containing the password field.

- **Header Sanitization:** Configure logging filters (e.g., in Spring Boot, Nginx, or Envoy) to explicitly redact or drop specific headers: `Authorization`, `Proxy-Authorization`, `X-Api-Key`, and `Cookie` (specifically session IDs).
    
- **Body Scrubbing:** If payload logging is required:
    
    - **Stream Caching:** The input stream must be wrapped (e.g., `ContentCachingRequestWrapper`) to be read twice (once for the app, once for the log).
        
    - **Field-Level Masking:** Do not dump the raw string. Parse the body, traverse the JSON tree, replace keys matching `*password*`, `*secret*`, or `*token*` with `[REDACTED]`, and then log the result.
        

### Aspect-Oriented Programming (AOP) Risks

Cross-cutting concerns like "Entry/Exit Logging" (tracing method arguments and return values) often bypass manual sanitization logic.

- **Parameter Inspection:** Generic AOP loggers typically iterate over `JoinPoint.getArgs()`. If a method signature is `login(String username, String password)`, the AOP aspect will log the plaintext password.
    
- **Custom Annotations:** Implement a `@LogSensitive` or `@NoLog` annotation. The AOP aspect must inspect parameter annotations before logging. If a parameter is marked sensitive, the logger should output `<PROTECTED>` instead of the value.
    

### Appender-Level Filtering (The Safety Net)

Relying solely on code-level discipline is insufficient. The logging framework itself acts as the final gatekeeper.

- **Regex Replacement:** Configure the logging backend (Log4j2, Logback, Fluentd) with pattern-matching replacers.
    
    - _Pattern:_ `(?i)"?(password|token|secret)"?\s*[:=]\s*"?([^",\s]+)"?`
        
    - _Action:_ Replace capture group 2 with `*****`.
        
    - _Performance Note:_ Regex filtering on the hot path introduces latency. This should be optimized by applying filters only to specific loggers or using high-performance, finite-state machine-based masking libraries instead of generic regex engines.
        

### Anti-Patterns

- **GET Requests for Auth:** Transmitting passwords via query parameters (e.g., `/login?user=x&pass=y`) ensures credentials are permanently recorded in access logs, proxy logs, and browser history. These logs are rarely subject to the same scrubbing rules as application logs.
    
- **Exception Message Leaks:** Throwing exceptions that include the input value in the message (e.g., `throw new InvalidPasswordException("Password " + input + " does not match criteria")`). Exception messages are almost always logged.
    
- **Environment Variable Dumps:** Logging `System.getenv()` or generic configuration maps at startup often exposes `DB_PASSWORD` or `AWS_SECRET_KEY`.
    

Related topics: OWASP A09:2021, PII Data Masking, PCI-DSS Compliance, Zero Trust Architecture.

---

