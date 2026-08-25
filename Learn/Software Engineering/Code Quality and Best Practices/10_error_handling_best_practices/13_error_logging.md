## Error Logging


### Structured Logging and Observability

Legacy plaintext logging requires expensive regex parsing at ingestion. Modern architecture mandates **Structured Logging** (JSON) to treat logs as event streams.

- **Schema Enforcement:** Enforce a strict schema for log payloads. Fields such as `correlation_id`, `timestamp_utc`, `service_name`, `environment`, and `log_level` must be mandatory.
    
- **Context Propagation:** Implement `MDC` (Mapped Diagnostic Context) or `ThreadContext` to automatically inject request-scoped metadata (Trace IDs, User IDs, IP addresses) into every log entry generated within that execution context. This eliminates manual string concatenation of context in individual log calls.
    
- **High-Cardinality Anti-Patterns:**
    
    - _Avoid:_ `logger.info("User " + userId + " not found")` — This creates infinite unique log messages, breaking aggregation grouping.
        
    - _Enforce:_ `logger.info("User not found", { "userId": userId })` — This allows log aggregation systems (ELK, Splunk, Datadog) to index the event type "User not found" efficiently while retaining the variable data as queryable fields.
        

### Asynchronous Logging and Backpressure

Synchronous logging is a blocking I/O operation that degrades throughput.

- **Async Appenders:** Use ring-buffer based asynchronous loggers (e.g., Log4j2 AsyncLogger with LMAX Disruptor). The application thread pushes the log event to a memory buffer and returns immediately. A separate I/O thread processes the buffer.
    
- **Drop Strategies:** Define explicit behavior for buffer saturation. In high-load scenarios, prefer **dropping** `DEBUG`/`INFO` logs over blocking the application thread. `ERROR`/`FATAL` logs should generally block or switch to a synchronous failover to ensure persistence.
    

### Security and PII Sanitization

- **Data Masking Pipelines:** Implement middleware or custom serializers that automatically scrub Personally Identifiable Information (PII) and secrets (API keys, passwords, credit card numbers) before the log leaves the application memory.
    
- **Allow-listing vs. Block-listing:** Prefer allow-listing safe fields for logging over block-listing sensitive fields. New fields added to a data object are sensitive by default until explicitly marked safe for logging.
    

