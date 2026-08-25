## Correlation IDs


### Standardization and W3C Compliance

While `X-Correlation-ID` and `X-Request-ID` are de facto industry standards, modern distributed tracing architectures should align with the **W3C Trace Context** specification. This ensures interoperability between heterogeneous monitoring tools (e.g., Dynatrace, New Relic, OpenTelemetry).

**Implementation Strategy:**

- **Primary Header:** Support `traceparent` as the authoritative source of truth.
    
- **Fallback Support:** Maintain backward compatibility by checking for `X-Correlation-ID`. If `traceparent` is absent but `X-Correlation-ID` exists, synthesize a W3C-compliant trace context using the legacy ID.
    
- **Egress:** All downstream HTTP calls must propagate the identified ID. Do not generate a new ID for internal service-to-service hops unless starting a completely distinct transaction.
    

### Context Propagation in Asynchronous Runtimes

Passing correlation IDs as method arguments is a severe architectural anti-pattern known as "argument drilling." It couples business logic to infrastructure concerns.

**Thread-Local and Async Storage:**

- **Java/JVM:** Utilize **MDC (Mapped Diagnostic Context)**. Implement a servlet filter that extracts the header and puts it into the MDC at the start of the request. Ensure the MDC is cleared in a `finally` block to prevent memory leaks in thread-pooled environments (e.g., Tomcat, Jetty).
    
- **Node.js:** Use `AsyncLocalStorage` (from the `async_hooks` module). Store the correlation ID in the store immediately upon request ingress. This ensures the ID remains accessible across asynchronous callbacks and Promises without explicit passing.
    
- **.NET:** Leverage `System.Diagnostics.Activity` or `AsyncLocal<T>`.
    

### Event-Driven Architecture (EDA) Continuity

In systems utilizing message brokers (Kafka, RabbitMQ, SQS), the trace context is often lost at the producer/consumer boundary.

**Serialization Standards:**

- **Header Injection:** Never embed correlation IDs in the message _payload_ (body). This pollutes the domain model.
    
- **Metadata:** Inject the ID into the message **headers** or **attributes**.
    
- **Consumer Context:** The consumer application must implement an interceptor that reads the header from the incoming message and seeds its local logging context (MDC/AsyncLocal) _before_ the message processing logic executes. This preserves the lineage from the HTTP trigger through to the background worker.
    

### Log Aggregation and Structured Logging

A correlation ID is useless if it is not machine-parsable. Plain text logs require expensive Regex parsing.

**Formatting Rules:**

- **JSON Logging:** Configuration must output logs in JSON format. The correlation ID must be a top-level key (e.g., `"correlationId": "..."` or `"traceId": "..."`).
    
- **Indexability:** Ensure the logging backend (Elasticsearch, Splunk, Datadog) indexes this field.
    
- **Client Response:** Always return the Correlation ID in the HTTP Response headers (e.g., `X-Correlation-ID`). This allows client-side applications to log the ID on error, enabling support teams to map a specific user report to the exact backend trace.
    

### ID Generation and Collision Avoidance

- **Algorithm:** Use **UUID v4** for high entropy. Avoid sequential IDs (e.g., database auto-increment) as they leak information about request volume and are difficult to generate in a distributed, lock-free manner.
    
- **ULID Alternative:** For systems requiring sortable traces (e.g., debugging chronological order of high-velocity events), **ULID** (Universally Unique Lexicographically Sortable Identifier) is superior to UUID. It combines a timestamp with random bits, allowing database indexing optimization.
    
- **Ingress Validation:** If a request arrives with an existing Correlation ID from an untrusted client (public internet), validate it against a strictly defined Regex (e.g., `^[a-fA-F0-9-]{36}$`). If the format is invalid, discard it and generate a new one to prevent log injection attacks or formatting errors in downstream systems.

---

