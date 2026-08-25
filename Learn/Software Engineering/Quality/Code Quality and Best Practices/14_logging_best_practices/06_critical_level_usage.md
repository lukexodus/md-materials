## CRITICAL Level Usage


In the hierarchy of structured logging and observability, the `CRITICAL` (or `FATAL`) level represents a specific, high-severity classification reserved for events that compromise the application's core invariants or operating capability. Misuse of this level directly contributes to observability noise and alert fatigue.

### Semantic Definition and Thresholds

The distinction between `ERROR` and `CRITICAL` is binary based on the necessity of immediate human intervention.

- **ERROR:** A specific operation or request failed, but the application lifecycle continues. The system is degraded but functional (e.g., a single request timeout, a 500 Internal Server Error returned to a client).
    
- **CRITICAL:** The application state is corrupted, or a dependency essential for startup/operation is unreachable. The system cannot fulfill its primary function.
    

**Criteria for CRITICAL classification:**

1. **Data Corruption:** Detection of inconsistent states in persistent storage or memory that violates database constraints or business invariants.
    
2. **Resource Exhaustion:** Complete depletion of connection pools, heap memory (OOM), or disk space where recovery is impossible without external intervention.
    
3. **Security Breaches:** definitive detection of an active intrusion attempt or compromised secrets.
    
4. **Unrecoverable Startup Failure:** Inability to bind to a port or connect to a primary configuration source.
    

### Operational Integration

The `CRITICAL` level acts as a direct trigger for Site Reliability Engineering (SRE) workflows.

- **Paging Policy:** Unlike `ERROR` logs, which typically aggregate into dashboards or tickets, a `CRITICAL` log event must trigger a synchronous alert (PagerDuty, OpsGenie) to the on-call engineer.
    
- **Process Termination:** In containerized environments (Kubernetes), a `CRITICAL` error usually implies the application has entered an undefined state. The architectural best practice is often to log the event and immediately terminate the process (`exit(1)`), allowing the orchestrator to restart the pod to a known clean state (Fail Fast).
    

### Contextual Enrichment Requirements

A `CRITICAL` log entry is a forensic artifact. It must contain the maximum available context to reduce Mean Time To Resolution (MTTR).

- **Full Stack Trace:** Mandatory.
    
- **System State:** Snapshot of relevant memory stats, thread dumps, or internal metrics at the moment of failure.
    
- **Correlation Identifiers:** Trace IDs and Span IDs to link the failure to specific distributed transactions.
    
- **Configuration Snapshot:** The active configuration values that might have contributed to the failure (redacting secrets).
    

### Anti-Patterns

- **Alert Fatigue:** Classifying transient network glitches or recoverable external API failures as `CRITICAL`. If the system automatically retries and succeeds, it was never `CRITICAL`.
    
- **Swallowed Criticals:** Logging an event as `CRITICAL` but allowing the application to continue execution. This creates "zombie" processes that appear functional but operate on corrupted data.
    
- **Redundant Logging:** Logging the same exception at multiple levels of the stack. A `CRITICAL` error should be handled and logged exactly once at the top-level exception handler or crash reporter.
    

**Related Topics:**

- Structured Logging Standards
    
- Observability and Tracing
    
- Circuit Breaker Patterns
    
- Error Handling Strategies

---

