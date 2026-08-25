## Error Recovery Strategies


### Transient Fault Handling

Exponential Backoff with Jitter

Simple retry mechanisms often exacerbate system load during outages, causing "Retry Storms" or resource resonance.

- **Algorithm:** `WaitTime = min(Cap, Base * 2^Attempt) + Random(0, Jitter)`
    
- **Implementation:** The randomization (jitter) decouples the retry attempts of concurrent clients, spreading the load over time.
    
- **Best Practice:** Define a strict `MaxRetries` budget. Infinite retries on non-transient errors (e.g., 401 Unauthorized, 400 Bad Request) waste resources and delay failure propagation.
    

Idempotency

Retries are unsafe without idempotency guarantees. A network timeout during the response phase of a write operation leaves the client uncertain if the server processed the request.

- **Mechanism:** Clients generate and send a unique `Idempotency-Key` header.
    
- **Server Logic:** The server checks a high-speed store (Redis/Memcached) for the key.
    
    - _Key Exists:_ Return the stored response immediately without re-processing.
        
    - _Key Absent:_ Process request, store the result atomically with the key, and return.
        
- **Scope:** Essential for non-idempotent verbs (POST, PATCH) in distributed systems.
    

### Stability Patterns

Circuit Breaker

Prevents an application from repeatedly trying to execute an operation that's likely to fail, allowing the failing service time to recover.

- **State Transitions:**
    
    - **Closed:** Requests pass through. Failure counters track error rates.
        
    - **Open:** Threshold exceeded (e.g., 50% failure rate over 10s). Requests fail fast with a specific exception (e.g., `CircuitBreakerOpenException`) without invoking the backend.
        
    - **Half-Open:** After a sleep window, a limited number of "test" requests are permitted. Success resets to _Closed_; failure reverts to _Open_.
        
- **Advanced Config:** Differentiate between "System Errors" (5xx) which trip the breaker, and "Application Errors" (4xx) which typically shouldn't.
    

Bulkhead Isolation

Partitions service resources to prevent a failure in one part of the system from bringing down the entire application.

- **Thread Pool Isolation:** dedicated thread pools for distinct downstream dependencies. If Service A hangs, it exhausts only its specific pool, leaving Service B's pool operational.
    
- **Semaphore Isolation:** Limits the number of concurrent calls to a dependency without the overhead of thread management.
    
- **Anti-Pattern:** Using a single global thread pool for all external integrations.
    

### Distributed Consistency & Compensation

Saga Pattern (Compensating Transactions)

In microservices, distributed ACID transactions (2PC/XA) are often too locking-intensive. Sagas use local ACID transactions combined with compensating actions.

- **Workflow:** A sequence of local transactions. If step $T_n$ fails, the system executes compensating transactions $C_{n-1}, \dots, C_1$ to undo changes.
    
- **Choreography:** Services publish events to trigger the next step. Recovery is decentralized but harder to observe.
    
- **Orchestration:** A central coordinator (StateMachine) directs steps and triggers compensations. Preferred for complex workflows requiring clear observability of the recovery path.
    
- **Data Requirement:** Compensating actions must be idempotent and commutativity is beneficial.
    

### Asynchronous Recovery

Dead Letter Queues (DLQ)

Handling "Poison Messages"—malformed input that causes a consumer to crash or loop indefinitely.

- **Mechanism:** After $N$ delivery attempts, the message broker moves the message to a separate DLQ.
    
- **Operational Procedure:** DLQs require active monitoring. Recovery involves manual inspection, patching the consumer logic, and **Shoveling** (replaying) messages back to the main queue.
    
- **Metadata:** Preserve original exception headers and timestamps in the DLQ message to aid root cause analysis.
    

Checkpointing and Journaling

For long-running batch processes or stream processing (e.g., Kafka, Flink).

- **Journaling:** Record the intent to perform an action (Write-Ahead Log) before execution. On restart, the system replays the log to restore state.
    
- **Checkpointing:** Periodically persist the current state (cursor position, offset) to durable storage.
    
- **Recovery:** On failure, the consumer resumes reading from the last committed checkpoint rather than the beginning, minimizing duplicate processing.
    

### Graceful Degradation

Fallback Strategies

When a dependency is unavailable or the circuit is open, the system provides a sub-optimal but functional response.

- **Stubbed Fallback:** Return a static, safe default value (e.g., empty list `[]` instead of `null`).
    
- **Cached Fallback:** Return slightly stale data from a local cache or CDNs.
    
- **Functional degradation:** Disable specific non-critical features (e.g., recommendations widget) while keeping the core checkout flow operational.

---

