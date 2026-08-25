## ERROR Level Usage


### Definition of Severity: The Actionability Criterion

The `ERROR` log level is reserved exclusively for events that affect the functionality of the application or the integrity of data and require **immediate or near-term human intervention**.

- **Service Unavailability:** Critical dependencies (database, external API, cache) are unreachable after exhaustion of retry policies.
    
- **Data Integrity Loss:** Data corruption, failure to persist critical transactions, or schema mismatches that prevent data processing.
    
- **Program Crash:** Unhandled exceptions that cause a thread, request handler, or the entire process to terminate unexpectedly.
    

**Constraint:** Do not use `ERROR` for anticipated business logic failures (e.g., "User not found," "Validation failed"). These are operational states, not system errors, and belong in `INFO` or `WARN`.

### Signal-to-Noise Ratio and Alerting

In high-maturity observability ecosystems, an `ERROR` log is a direct trigger for an alert.

- **The "Wake Up" Rule:** If an event is logged as `ERROR`, it implies that an on-call engineer should potentially be paged. If the team ignores the alert or filters the log because "it happens all the time," the level is misclassified and should be downgraded to `WARN`.
    
- **SLO Impact:** `ERROR` logs typically correlate directly with a dip in Service Level Indicators (SLIs), such as Availability or Error Rate.
    
- **Zero-Error Policy:** The goal for a healthy production system is zero `ERROR` logs under normal operation. Any recurring `ERROR` is a bug that must be prioritized.
    

### Contextual Completeness (Structured Logging)

An `ERROR` log is useless without context. When an error occurs, the log entry must act as a standalone forensic artifact.

- **Mandatory Fields:**
    
    - `correlation_id` / `trace_id`: To trace the request across distributed services.
        
    - `stack_trace`: Full stack trace is mandatory for `ERROR` (unlike `INFO`).
        
    - `input_parameters`: The arguments provided to the function that failed (sanitized of PII/secrets).
        
    - `user_id` / `tenant_id`: Identifying the affected customer scope.
        
    - `system_state`: Relevant state variables (e.g., `connection_pool_usage=98%`).
        
- **Structured Format:** Use JSON structured logging. Plain text logs require complex regex parsing and often truncate stack traces.
    
    - _Example (JSON):_
        
        JSON
        
        ```
        {
          "level": "ERROR",
          "message": "Transaction commit failed",
          "error_code": "DB_COMMIT_TIMEOUT",
          "trace_id": "a1b2c3d4",
          "duration_ms": 5002,
          "stack_trace": "java.sql.SQLTimeoutException: ...",
          "component": "OrderProcessor"
        }
        ```
        

### Anti-Patterns in Error Logging

#### 1. Log and Ignore (Swallowing)

Catching an exception, logging it as `ERROR`, and then proceeding as if nothing happened (or returning null) leaves the system in an inconsistent state.

- _Correction:_ If the application cannot recover, the exception should be re-thrown or the process terminated. If it _can_ recover (fallback), it is likely a `WARN`, not an `ERROR`.
    

#### 2. Double Logging

Logging the exception at the catch block and then re-throwing it to the caller.

- _Consequence:_ The same error appears multiple times in the logs (once per layer of the stack), artificially inflating error counts and cluttering the log aggregator.
    
- _Correction:_ Log **only** at the point where the error is finally handled (the "top-level" handler). Lower-level layers should wrap and re-throw exceptions (e.g., wrapping `SQLException` in `RepositoryException`) to preserve causality without logging.
    

#### 3. Logging Transient Failures as Errors

Logging an `ERROR` immediately upon a network timeout.

- _Consequence:_ Spikes in alerts during minor network blips.
    
- _Correction:_ Wrap operations in Retry Logic. Log `WARN` on failed attempts. Log `ERROR` **only** when the retry budget is exhausted and the operation definitively fails.
    

### Handling Sensitive Data in Error Traces

Stack traces and exception messages often inadvertently capture sensitive data (e.g., "SQL Syntax Error: ... value='password123'").

- **Sanitization Filters:** Implement log appenders or filters that regex-match and redact patterns resembling credit cards, API keys, or passwords before the log is flushed.
    
- **Exception Wrapping:** Custom exception classes should override `getMessage()` to exclude sensitive fields found in the root cause, or strictly control what data is passed into the exception constructor.

---

