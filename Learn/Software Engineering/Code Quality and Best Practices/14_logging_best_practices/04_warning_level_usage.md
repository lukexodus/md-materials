## WARNING level usage


In the hierarchy of log severity (typically TRACE, DEBUG, INFO, WARNING, ERROR, FATAL), `WARNING` (or `WARN`) is the most semantically ambiguous and frequently misused level. Improper usage leads to "alert fatigue" and the desensitization of operations teams.

Strict adherence to a semantic definition is required to maintain high signal-to-noise ratios in observability pipelines.

### Semantic Definition

A `WARNING` indicates that an unexpected or undesirable event occurred, but the application was able to **recover automatically** or **continue functioning** without immediate human intervention. The system state is suboptimal but operational.

If a specific request fails completely and returns a 5xx status to the client, it is an `ERROR`. If the request succeeds (perhaps via fallback logic) despite an internal failure, it is a `WARNING`.

### Canonical Use Cases

1. Graceful Degradation / Fallback:
    
    The primary downstream dependency failed, but the system successfully fell back to a secondary source, a cache, or a default value.
    
    - _Example:_ The recommendation engine API timed out; the application served a generic "popular items" list instead. The user experience is degraded but intact.
        
2. Transient Instability (Retries):
    
    An operation failed initially but succeeded upon retry. This signals potential network instability or resource contention that warrants investigation before it escalates to a hard failure.
    
    - _Example:_ A database transaction failed with a deadlock victim error but succeeded on the second attempt.
        
3. Near-Capacity Indicators:
    
    Resources are functioning within limits but are approaching thresholds that will cause failure if trends continue.
    
    - _Example:_ Connection pool usage hits 85%, or disk space usage exceeds defined "soft" quotas.
        
4. Deprecation Usage:
    
    Runtime detection of deprecated API usage or configuration parameters. This serves as a passive notification to developers to modernize the code.
    
5. Data Anomalies (Non-Critical):
    
    Input data was malformed or unexpected but could be sanitized or ignored safely without rejecting the entire payload.
    
    - _Example:_ A JSON payload contained an unknown field that was discarded during parsing.
        

### Alerting Strategy

Unlike `ERROR` logs, which often trigger immediate paging of on-call engineers for individual occurrences, `WARNING` logs should trigger alerts based on **heuristics** and **aggregations**.

- **Rate-Based Alerting:** Do not alert on a single `WARNING`. Alert if the rate of warnings exceeds $X$ per minute or deviates by $Y\sigma$ (standard deviations) from the historical baseline.
    
- **Trend Analysis:** Use `WARNING` metrics to populate dashboards for weekly reliability reviews. They represent "technical debt" or "instability" that needs to be addressed during business hours.
    

### Anti-Patterns

1. The "Swallowed Exception" Pattern:
    
    Catching a critical exception, logging it as WARNING, and then doing nothing. This hides bugs.
    
    - _Refactoring:_ If the exception is unexpected and unhandled, it must be an `ERROR`. If it is expected and handled, consider if it is even a `WARNING` (it might be `INFO`).
        
2. Business Logic as Warnings:
    
    Logging valid business scenarios as warnings.
    
    - _Bad Practice:_ Logging `WARNING: User attempted to login with invalid password`. This is a standard user flow (unless it indicates a brute-force attack, which is a security event).
        
    - _Correction:_ Use `INFO` for audit trails.
        
3. Noisy Loops:
    
    Placing a WARNING log inside a tight loop processing millions of records. If a batch job encounters a recurring data issue, the logging system can become the bottleneck (I/O saturation) or the log ingestion quota can be exhausted.
    
    - _Mitigation:_ Implement "One-Per-Process" logging or "Sampled" logging (e.g., log only the first 10 occurrences, then suppress until the summary).
        

### Implementation Standards

- **Structured Logging:** Do not use string concatenation. Pass the exception object and context variables as structured fields (JSON) to allow for aggregation by error type.
    
    JSON
    
    ```
    // GOOD
    {
      "level": "WARN",
      "message": "Dependency timeout, serving fallback",
      "dependency": "pricing-service",
      "latency_ms": 5002,
      "fallback_source": "local-cache"
    }
    ```
    
- **Contextual Clarity:** The log message must explain _why_ it is a warning and _what_ the system did to handle it.
    
    - _Bad:_ `WARN: Connection failed.`
        
    - _Good:_ `WARN: Connection to payment gateway failed; retrying attempt 2 of 3.`
        

Related topics: Structured Logging, Observability Pipelines, Circuit Breaker Pattern, Error Budgeting.

---

