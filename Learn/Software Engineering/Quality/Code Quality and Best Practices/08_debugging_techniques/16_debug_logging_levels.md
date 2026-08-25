## Debug logging levels


Effective logging is a critical component of maintainable software, serving as the primary window into a running application's internal state. Choosing the correct logging level ensures that logs remain actionable without overwhelming the storage or obscuring critical errors with noise.

**Key Points**

- **Semantic Precision:** Each level conveys a specific urgency and audience (developer vs. operator). Misusing levels (e.g., logging errors as info) breaks monitoring alerts.
    
- **Performance Impact:** Lower levels (Trace/Debug) generate high volume. They must be gated to avoid CPU and I/O overhead in production.
    
- **Signal-to-Noise Ratio:** Production logs should default to `INFO` or `WARN`. `DEBUG` and `TRACE` are for active troubleshooting.
    
- **Security:** Detailed levels often inadvertently expose PII or secrets (e.g., dumping a full user object).
    

**Standard Levels and Usage**

1. **TRACE**
    
    - **Definition:** The most granular level of information.
        
    - **Usage:** Captures flow through algorithms, loop iterations, or individual query results. Used solely for chasing elusive bugs during development or highly targeted debugging sessions.
        
    - **Code Quality Check:** Should never be enabled globally in production.
        
2. **DEBUG**
    
    - **Definition:** Diagnostic information valuable for software engineers to understand state changes.
        
    - **Usage:** Entering/exiting functions, payload contents (sanitized), conditional path decisions.
        
    - **Code Quality Check:** Ensure expensive string concatenations or object serialization inside Debug logs are guarded by a check (e.g., `if (log.isDebugEnabled())`) or use lazy evaluation (lambda suppliers) to prevent unnecessary processing when the level is disabled.
        
3. **INFO**
    
    - **Definition:** High-level operational events showing the application is functioning as expected.
        
    - **Usage:** Application startup/shutdown, configuration loaded, periodic jobs completed, major state transitions (e.g., "Order #1234 confirmed").
        
    - **Code Quality Check:** These logs are for operators and auditors. They should be concise and meaningful. Avoid "heartbeat" spam.
        
4. **WARN**
    
    - **Definition:** An unexpected event occurred, but the application can continue functioning.
        
    - **Usage:** Use of deprecated APIs, poor performance triggers (e.g., query took > 2s), recoverable issues (e.g., connection lost, retrying), or fallback defaults used.
        
    - **Code Quality Check:** A warning implies actionable technical debt or a configuration issue. If a warning triggers frequently, it is either an Error or normal Info; "warning fatigue" leads to ignoring real issues.
        
5. **ERROR**
    
    - **Definition:** A functionality failed. The user request could not be completed, or a background process crashed.
        
    - **Usage:** Database connection failures, unhandled exceptions, constraint violations.
        
    - **Code Quality Check:** Errors must trigger alerts. Do not log an exception as an Error and then re-throw it (Log and Throw anti-pattern), as this creates duplicate noise in the logs.
        
6. **FATAL**
    
    - **Definition:** Severe error that prevents the application from continuing to run.
        
    - **Usage:** Out of memory, missing critical configuration files, port binding failures.
        
    - **Code Quality Check:** The application usually exits immediately after this log.
        

**Example**

The following pseudo-code demonstrates appropriate level selection and performance guards.

Java

```
public void processTransaction(Transaction tx) {
    // TRACE: granular flow detail
    logger.trace("Entering processTransaction for ID: {}", tx.getId());

    try {
        if (!validate(tx)) {
            // WARN: Business logic rejection, not a system crash
            logger.warn("Transaction rejected due to validation failure. ID: {}", tx.getId());
            return;
        }

        // DEBUG: State prior to complex operation
        // Use a supplier/lambda to avoid toString() cost if DEBUG is off
        logger.debug("Processing payload: {}", () -> tx.getPayload().sanitize());

        performTransfer(tx);

        // INFO: Significant business event
        logger.info("Transaction completed successfully. ID: {}", tx.getId());

    } catch (DatabaseException e) {
        // ERROR: System failure requiring intervention
        logger.error("Failed to commit transaction ID: " + tx.getId(), e);
    }
}
```

**Anti-Patterns in Logging Levels**

- **The "Everything is Error" approach:** Logging validation failures or user errors (e.g., "Wrong Password") as `ERROR`. This pollutes error tracking tools and wakes up on-call engineers for non-critical issues.
    
- **Swallowing Exceptions:** Catching an exception, logging it at `DEBUG` or `INFO`, and continuing as if nothing happened. This hides critical failures.
    
- **Sensitive Data Leaks:** Logging raw HTTP requests at `DEBUG` level which contain Authorization headers or passwords.
    

Next Steps

Audit the current codebase for "Log and Throw" occurrences and refactor them to log only at the boundary where the exception is finally handled.

---

