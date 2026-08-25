## Remote Procedure Call


RPC abstracts distributed communication as local procedure invocation, marshalling parameters across network boundaries to execute logic on remote nodes. The programming model hides network complexity behind synchronous call semantics, though underlying transport remains subject to distributed system failure modes.

### Protocol Architecture

**Stub Generation and Interface Definition** Interface Definition Languages (IDL) specify service contracts independent of implementation language. Protocol Buffers (protobuf), Thrift, and Avro define schema-evolving serialization formats. Code generators produce client stubs and server skeletons from IDL specifications. Stubs handle marshalling, network transport, error translation, and blocking semantics. Language-neutral specifications enable polyglot service ecosystems.

**Marshalling and Serialization** Parameter and return value serialization converts in-memory representations to wire format. Binary protocols (protobuf, Thrift binary, MessagePack) optimize size and parsing speed. Text protocols (JSON-RPC, XML-RPC) provide human readability at bandwidth cost. Zero-copy serialization (FlatBuffers, Cap'n Proto) eliminates deserialization overhead by operating directly on serialized buffers. Schema evolution requires forward/backward compatibility—adding optional fields, deprecating fields, field numbering stability.

**Transport Layer Bindings** RPC frameworks layer over transport protocols with distinct trade-offs. TCP provides reliable ordered delivery with connection overhead and head-of-line blocking. HTTP/1.1 enables proxy traversal and load balancer compatibility but serializes requests. HTTP/2 multiplexes streams over single TCP connection, eliminating head-of-line blocking at application layer. QUIC (HTTP/3) provides stream multiplexing over UDP, reducing connection establishment latency and recovering from packet loss without blocking unaffected streams. Unix domain sockets eliminate network stack overhead for same-host communication.

**Synchronous vs Asynchronous Invocation** Synchronous RPC blocks caller thread until response arrives, simplifying control flow but tying thread resources to network latency. Asynchronous RPC returns futures/promises, enabling concurrent request issuance and non-blocking I/O. Callback-based async RPC inverts control flow. Streaming RPC supports bidirectional streaming—client streaming uploads data streams, server streaming downloads result streams, bidirectional streaming enables full-duplex communication. Streaming amortizes connection overhead across multiple messages and supports backpressure.

### Failure Semantics

**At-Most-Once, At-Least-Once, Exactly-Once** Network failures create ambiguity—request sent but response lost means unknown execution state. At-most-once semantics execute requests zero or one time, appropriate for non-idempotent operations. Requires request deduplication via unique request IDs tracked server-side. At-least-once semantics retry on timeout/failure, executing requests one or more times—safe only for idempotent operations. Exactly-once semantics guarantee single execution through idempotency keys and distributed transactions, trading latency for correctness.

**Timeout Configuration** Client-side timeouts bound request latency but create false failures when server completes after timeout. Aggressive timeouts reduce tail latency at cost of increased retry load. Conservative timeouts increase latency percentiles. Per-method timeout configuration accounts for operation complexity. Adaptive timeouts adjust based on observed latency distributions. Server-side deadline propagation cancels work when client timeout expires, preventing wasted computation.

**Retry Logic and Backoff** Naive retry amplifies cascading failures—thundering herd of retries overwhelms recovering services. Exponential backoff with jitter spaces retry attempts, preventing synchronized retry storms. Idempotency detection prevents duplicate side effects. Non-idempotent operations require explicit idempotency tokens. Retry budgets limit total retry attempts across request lifetime. Hedged requests issue duplicate requests after delay, using first successful response.

**Partial Failure Handling** Server crashes mid-execution leave ambiguous state. Client cannot distinguish network partition from server failure. Timeouts provide failure detection but not failure type. Distributed transactions (2PC) provide atomicity at latency cost. Compensating transactions (Sagas) handle rollback without distributed locks. Request-level tracing enables failure correlation across service boundaries.

**Circuit Breaking** Circuit breakers prevent cascading failures by failing fast when downstream service degraded. Closed state allows requests. Open state immediately rejects requests when failure threshold exceeded. Half-open state periodically probes service health. Failure detection based on error rate, latency percentiles, or consecutive failures. Circuit breaker state shared across service instances via distributed coordination or eventually consistent gossip.

### Performance Optimization

**Connection Pooling and Multiplexing** TCP connection establishment requires three-way handshake—connection pooling amortizes handshake overhead. HTTP/1.1 connection reuse eliminates per-request handshakes. HTTP/2 multiplexes concurrent requests over single connection. gRPC leverages HTTP/2 for stream multiplexing. Connection pool sizing balances resource utilization against connection establishment latency. Per-host pools versus global pools affect connection distribution.

**Load Balancing Strategies** Client-side load balancing eliminates proxy hop but requires service discovery integration. Round-robin distributes requests uniformly. Least-outstanding-requests accounts for in-flight request load. Weighted round-robin handles heterogeneous node capacity. Consistent hashing minimizes backend reassignment during topology changes. Locality-aware routing minimizes cross-region latency. Health-checking removes unhealthy backends from rotation.

**Batching and Pipelining** Request batching amortizes per-request overhead—single RPC carries multiple logical operations. Reduces network round-trips and marshalling overhead. Complicates partial failure handling—batch may partially succeed. Pipelining issues multiple requests without waiting for responses, keeping network saturated. Requires request ordering guarantees or out-of-order completion handling.

**Compression** Payload compression reduces bandwidth consumption at CPU cost. gzip provides strong compression with moderate CPU overhead. Snappy optimizes decompression speed over compression ratio. LZ4 provides fast compression/decompression. Compression effectiveness depends on payload characteristics—structured data compresses well, encrypted/binary data poorly. Compression thresholds prevent overhead for small payloads.

**Header Compression** HTTP/2 HPACK compresses headers via static/dynamic tables, reducing per-request overhead. gRPC leverages HPACK for metadata compression. Custom metadata (tracing context, authentication tokens) incurs per-request serialization cost. Header size limits prevent amplification attacks.

### Observability and Diagnostics

**Distributed Tracing** Trace context propagation across RPC boundaries enables end-to-end request tracking. OpenTelemetry standardizes trace/span semantics. Parent span ID establishes causal relationships. Trace sampling reduces storage overhead—head-based sampling samples at ingress, tail-based sampling retains slow/failed requests. Trace aggregation reconstructs distributed call graphs. Span attributes capture RPC metadata—method name, status code, peer address.

**Metrics and Instrumentation** Request rate, error rate, and latency (RED metrics) characterize RPC health. Latency histograms capture distribution—percentiles (p50, p95, p99) identify tail latency. Per-method granularity isolates problematic operations. Client-side and server-side metrics correlate failures. Connection pool metrics (active connections, wait time) diagnose resource exhaustion.

**Error Categorization** gRPC status codes distinguish error classes—UNAVAILABLE (transient), DEADLINE_EXCEEDED (timeout), INVALID_ARGUMENT (client error), INTERNAL (server error), UNAUTHENTICATED (auth failure). Error codes guide retry logic—transient errors retry, client errors fail immediately. Structured error details provide additional context (error messages, debug info).

**Request/Response Logging** Full payload logging enables debugging but introduces privacy/performance concerns. Sampling logs fraction of requests. Structured logging (JSON) enables automated parsing. Log correlation via request ID links client/server logs. Request metadata logging (headers, method, peer) provides context without payload exposure.

### Security and Authentication

**Transport Security** TLS encrypts in-transit data, preventing eavesdropping and tampering. Mutual TLS (mTLS) provides bidirectional authentication via client certificates. Certificate rotation requires coordination across service fleet. Certificate pinning prevents MITM attacks. ALPN negotiates application protocol (h2 for HTTP/2).

**Authentication Mechanisms** Token-based authentication passes bearer tokens (JWT, OAuth2) in metadata. API keys provide simple authentication. Service-to-service authentication via mTLS or service tokens. Authentication context propagation enables authorization decisions. Token expiration and refresh complicate long-lived connections.

**Authorization and Access Control** Per-method authorization enforces access policies. Role-based access control (RBAC) maps identities to permissions. Attribute-based access control (ABAC) evaluates contextual attributes. Authorization policy enforcement at service boundary prevents unauthorized access. Policy evaluation latency affects request latency—policy caching trades freshness for performance.

**Rate Limiting and Quota** Per-client rate limiting prevents abuse and ensures fair resource allocation. Token bucket algorithm smooths burst traffic. Quota enforcement limits resource consumption over time windows. Distributed rate limiting requires coordination—local limits risk over-admission, global limits require centralized state. Client identification via API keys or source identity.

### Framework-Specific Characteristics

**gRPC Architecture** HTTP/2-based multiplexing enables concurrent bidirectional streams. Protobuf serialization provides schema evolution. Four RPC types—unary (single request/response), server streaming, client streaming, bidirectional streaming. Pluggable authentication, load balancing, retries. Language-specific implementations (C-core, Go, Java). Service mesh integration via xDS protocol.

**Apache Thrift** Multi-protocol support—binary, compact, JSON. Multi-transport support—sockets, HTTP, memory. Code generation for 20+ languages. Asynchronous and synchronous APIs. No built-in streaming. Versioning via optional fields and field IDs.

**JSON-RPC** Text-based protocol over HTTP/WebSocket. Stateless request/response. No schema enforcement—dynamically typed. Batch requests reduce HTTP overhead. Simpler than XML-RPC, less efficient than binary protocols. Browser-compatible for web applications.

### Architectural Trade-offs

**Coupling and Tight Integration** RPC encourages synchronous, request-response patterns creating temporal coupling—caller blocks on callee availability. Direct service dependencies create brittle call chains—cascading failures propagate through call stack. Alternative: message-passing (queues, event buses) decouples services temporally.

**Network Transparency Illusion** RPC abstracts network as local call but underlying network failures persist. Fallacy of transparent distribution encourages ignoring failure modes. Synchronous semantics hide latency costs. Contrast with explicit message-passing where network boundary explicit.

**Latency Amplification** Synchronous RPC chains accumulate latency—total latency equals sum of hop latencies plus queueing. Deep call stacks amplify tail latency—p99 latency compounds across hops. Fan-out patterns multiply latency—parallel calls bound by slowest response. Alternatives: async aggregation, caching, service mesh hedging.

**Schema Evolution Complexity** IDL changes require coordinated deployment across clients/servers. Breaking changes (field removal, type changes) require version negotiation. Non-breaking changes (optional field addition) maintain compatibility. Schema registry centralizes schema versions. Rolling deployments require N and N+1 version compatibility.

**Resource Utilization** Synchronous RPC ties thread to network I/O—thread-per-request model scales poorly. Async I/O (epoll, io_uring) enables high concurrency with fewer threads. Thread pool exhaustion under high latency causes cascading failures. Connection pooling reduces per-request overhead but increases resource holding time.

### Operational Considerations

**Service Discovery Integration** Static configuration couples clients to backend topology. DNS-based discovery provides coarse-grained service location. Consul/etcd/ZooKeeper enable dynamic service registration and health checking. Client-side load balancing requires service discovery integration. Server-side load balancing centralizes discovery logic but adds proxy hop.

**Canary Deployment and Traffic Splitting** Progressive rollouts require traffic routing to version subsets. Header-based routing directs test traffic to canary. Percentage-based splitting requires consistent routing for stateful operations. Metrics comparison between baseline and canary identifies regressions. Automated rollback on SLO violation.

**Cross-Region and Multi-Cluster** Global load balancing routes requests to nearest healthy region. Cross-region latency affects synchronous RPC chains—minimize cross-region calls. Regional failover requires health checking and traffic drain. Data locality concerns—GDPR, data residency. Anycast routing provides transparent failover at DNS layer.

**Version Skew Handling** Rolling deployments create mixed-version clusters. Protocol buffers unknown field preservation enables forward compatibility. Deprecated field handling enables backward compatibility. Version negotiation via capability advertisement. Feature flags enable gradual rollout independent of deployment.

### Related Topics

- Service mesh (Istio, Linkerd, Consul Connect)
- API gateway patterns
- GraphQL federation
- Message queues and asynchronous messaging
- Event-driven architecture
- Saga pattern for distributed transactions
- Service discovery (Consul, etcd, ZooKeeper)
- Load balancing algorithms
- Bulkhead pattern and fault isolation
- OpenTelemetry and distributed tracing
- mTLS and zero-trust networking
- Protocol Buffers, Thrift, Avro schema evolution
- HTTP/2 and HTTP/3 (QUIC)
- Backpressure and flow control

---

