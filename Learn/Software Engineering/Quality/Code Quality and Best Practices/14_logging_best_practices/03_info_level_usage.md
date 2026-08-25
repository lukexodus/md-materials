## INFO Level Usage


### Operational Philosophy: The System "Pulse"

The INFO log level serves as the operational heartbeat of a software system.1 Unlike DEBUG (diagnostic) or ERROR (failure), INFO records significant, expected lifecycle events that confirm the application is functioning correctly.2 In a production environment, INFO is typically the default effective log level; therefore, every INFO log must have high operational value, typically answering the question: _"What is the state of the system right now?"_ or _"What major unit of work just completed?"3_

**Core Tenet:** INFO logs should be actionable for audit trails and analyzing user behavior patterns but must never trigger on-call alerts.4

### Acceptance Criteria for INFO

A log entry belongs at the INFO level only if it meets at least one of the following criteria:

- **State Change:** The system has successfully transitioned from one major state to another (e.g., `ServiceStarted`, `LeaderElectionWon`, `CacheHydrationCompleted`).
    
- **Unit of Work Completion:** A coarse-grained business transaction has finished (e.g., `OrderProcessed`, `ReportGenerated`, `UserLoggedIn`).
    
- **External Integration:** A significant interaction with a third-party service has occurred (e.g., `PaymentGatewayResponseReceived`).
    
- **Configuration:** Confirmation of effective settings loaded at startup (excluding secrets).
    

**Rejection Criteria (Use DEBUG or WARN instead):**

- **Fine-grained Logic flow:** Entering/exiting functions, loop iterations (Use DEBUG).
    
- **Variable State:** Dumping internal variable values for inspection (Use DEBUG).5
    
- **Recoverable Anomalies:** Retrying a connection, deprecated API usage (Use WARN).
    
- **High Frequency Events:** Health check endpoints called every second (Use TRACE or suppress).
    

### Structured Logging and Schema

Modern log aggregation systems (ELK Stack, Splunk, Datadog) require structured data.6 Unstructured string concatenation is an anti-pattern at the INFO level.

Canonical Schema:

Every INFO log should adhere to a strict JSON schema containing standard correlation identifiers.

JSON

```
{
  "level": "INFO",
  "timestamp": "2023-10-27T10:00:00.000Z",
  "trace_id": "a1b2c3d4e5f6",
  "span_id": "12345678",
  "service": "payment-processor",
  "event": "TransactionCompleted",
  "properties": {
    "amount": 150.00,
    "currency": "USD",
    "merchant_id": "merchant_88",
    "processing_time_ms": 245
  }
}
```

Implementation Rule:

Do not interpolate variables into the message string.

- **Bad:** `log.info(f"User {user_id} purchased item {item_id}")` -> Creates high cardinality index bloat.
    
- **Good:** `log.info("PurchaseCompleted", user_id=user_id, item_id=item_id)` -> constant message, indexed fields.
    

### Anti-Patterns in INFO Usage

#### The "Chatty" INFO (Flooding)

Logging INFO inside tight loops or high-frequency request paths (e.g., middleware for every HTTP request). This causes "Log DOS," filling disk space and exhausting ingestion quotas.

- **Remediation:** Implement **Sampling**. Log only 1% of success paths at INFO level, or use "Aggregated Logging" (log once per 1000 items processed).
    

#### The "Silent" Error

Logging a caught exception as INFO without re-throwing or elevating to ERROR.

- **Example:** `catch (Exception e) { log.info("Failed to save, retrying..."); }`
    
- **Risk:** This hides system degradation. If an operation fails, it is by definition not a successful "normal" event. Use WARN for handled retries, ERROR for failures.
    

#### Sensitive Data Leakage (PII/Secrets)

Because INFO is the default production level, it is the most common vector for data leaks.

- **Strict Prohibition:** Never log headers (Authorization tokens), PII (email, phone), or payloads containing raw user input at INFO level.
    
- **Mitigation:** Use rigorous "Object Sanitizers" or "Masking Policies" in the logging middleware that automatically redact fields like `password`, `token`, `ssn`.
    

### Advanced High-Volume Strategies

#### Log Sampling and Throttling

For high-throughput systems (thousands of RPS), logging every successful request at INFO is unsustainable.

- **Rate Limiting:** Configure the logger to drop messages if they exceed a threshold (e.g., 50 logs/sec).
    
- **Probabilistic Sampling:** Log 100% of ERROR/WARN, but only a statistically significant sample (e.g., 0.1%) of successful INFO transactions for baseline metrics.
    

#### Event ID/Code Usage

Assign a unique alphanumeric code to distinct INFO events (e.g., `EVT-001`). This decouples the log query from the message text, allowing the text to be refactored without breaking dashboards or alerts.

### Storage and Retention Policy

INFO logs have a distinct lifecycle compared to ERROR logs:

- **Hot Storage (Index):** Keep for 7-14 days. Used for immediate troubleshooting and "yesterday's deployment" comparison.
    
- **Cold Storage (Archive):** Offload to S3/Blob Storage after 14 days. Retain for compliance/audit (e.g., 1 year) but remove from expensive search indexes.

---

