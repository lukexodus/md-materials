## Load Balancing Techniques


### DNS-Based Load Balancing

Returns multiple A/AAAA records with varying TTLs to distribute client connections across backend IP addresses. Client-side DNS resolver selects from returned set, typically round-robin or random selection.

**Architectural Characteristics:**

- Coarse-grained distribution at connection establishment
- No application-layer awareness or session affinity
- TTL-bound stickiness creating uneven distribution during scale events
- Geographic steering via GeoDNS with latency-based or proximity-based record selection
- Failure detection relies on health-check-driven record removal with TTL-based propagation delay
- Horizontal partition across availability zones or regions without single control plane

**Limitations:**

- DNS caching at resolver and client layers prevents real-time traffic shifting
- No per-request granularity or adaptive weighting
- Split-brain risk during network partitions affecting authoritative nameservers
- Client connection pooling bypasses DNS layer after initial resolution

### Layer 4 (Transport Layer) Load Balancing

Operates on TCP/UDP packet headers, routing based on 5-tuple (source IP, source port, destination IP, destination port, protocol) without application protocol awareness.

**Connection Handling Models:**

- **Direct Server Return (DSR):** Load balancer rewrites destination MAC, backend responds directly to client. Asymmetric flow eliminates return-path bottleneck. Requires L2 adjacency or tunneling.
- **NAT Mode:** Load balancer performs destination NAT on inbound, source NAT on outbound. Symmetric flow enables cross-subnet backends but creates stateful bottleneck.
- **Tunneling (IP-in-IP):** Encapsulates original packet, backend decapsulates and responds directly. Preserves client IP without NAT state.

**Session Persistence:**

- Source IP hashing with consistent hashing ring for backend changes
- 5-tuple hashing for finer granularity
- Connection tracking table with expiration timers

**Failure Detection:**

- Active TCP health checks (connect, optionally send probe)
- Passive monitoring via connection attempt tracking
- Circuit breaker patterns with exponential backoff

**Scalability Characteristics:**

- Stateful connection tracking limits horizontal scale without distributed state
- Connection table size constraints with memory bounds
- ECMP (Equal-Cost Multi-Path) routing distributes across L4 load balancer instances with per-flow hashing, but flow rehashing during topology changes breaks sessions

### Layer 7 (Application Layer) Load Balancing

Terminates client connections, parses application protocols (HTTP/1.1, HTTP/2, HTTP/3, gRPC), makes routing decisions based on request content, establishes separate backend connections.

**Request Routing Dimensions:**

- URI path, query parameters, headers (Host, User-Agent, custom)
- HTTP method
- Request body inspection (limited by buffering constraints)
- TLS SNI or ALPN
- Protocol-specific attributes (gRPC service/method, GraphQL operation)

**Backend Selection Algorithms:**

- **Round Robin:** Sequential iteration, no load awareness
- **Weighted Round Robin:** Static weight assignment per backend
- **Least Connections:** Active connection count minimization, requires global view
- **Least Response Time:** Exponentially weighted moving average (EWMA) of latency, adaptive but sensitive to transient spikes
- **Peak EWMA:** Combines connection count and response time
- **Random:** Stateless, probabilistically fair at scale
- **Power of Two Choices:** Random sample of two backends, select least loaded, near-optimal with O(1) overhead
- **Consistent Hashing:** Maps request attributes to hash ring with virtual nodes, minimizes backend reassignment during scale events

**Session Affinity Mechanisms:**

- Cookie-based (injected or application-provided)
- Header-based routing
- Consistent hashing on client identifier
- IP-based with timeout windows

**Connection Management:**

- **Connection Pooling:** Maintains persistent backend connections, amortizes TCP/TLS handshake overhead
- **HTTP/2 Multiplexing:** Single TCP connection for multiple concurrent requests, head-of-line blocking at TCP layer
- **HTTP/3 (QUIC):** Stream multiplexing without head-of-line blocking, faster connection establishment, connection migration

**Advanced Request Manipulation:**

- Header injection/removal (X-Forwarded-For, X-Request-ID)
- Request/response buffering with size limits
- Protocol translation (HTTP/1.1 ↔ HTTP/2 ↔ gRPC)
- Request retries with idempotency detection
- Circuit breaking per backend with failure threshold and timeout
- Rate limiting (token bucket, leaky bucket) per client, route, or backend

**Traffic Shaping:**

- **Traffic Splitting:** Percentage-based routing for canary deployments, A/B testing
- **Shadow Traffic:** Duplicate requests to secondary backends without impacting client response
- **Traffic Mirroring:** Replay production traffic to staging environments

**Failure Handling:**

- Active HTTP health checks with custom endpoints, status code validation, response body matching
- Passive health checks via error rate tracking (5xx responses, connection failures, timeouts)
- Outlier detection with consecutive failure thresholds
- Automatic backend ejection and gradual reintroduction

**Observability:**

- Per-route, per-backend metrics (request rate, error rate, latency percentiles)
- Distributed tracing integration (trace context propagation)
- Access logging with structured formats

**Scalability and Availability:**

- Stateless request processing enables horizontal scaling
- Configuration state (routes, backends, health status) requires distributed coordination
- Control plane (config distribution) vs data plane (request forwarding) separation
- Clustered deployments with RAFT or Paxos for configuration consensus
- Active-active multi-region with anycast or GeoDNS

**Security Considerations:**

- TLS termination with certificate management
- Mutual TLS (mTLS) for backend authentication
- Rate limiting and DDoS mitigation
- Request validation and sanitization

### Client-Side Load Balancing

Client application maintains backend registry, performs selection and health tracking without intermediary load balancer.

**Backend Discovery:**

- Service registry integration (Consul, etcd, ZooKeeper)
- DNS SRV records with periodic polling
- Configuration file with dynamic reload

**Selection Logic:**

- Embedded algorithms (round robin, least loaded, random)
- Adaptive retry with exponential backoff and jitter
- Local circuit breaker per backend

**Architectural Trade-offs:**

- Eliminates single point of failure and latency overhead of proxy layer
- Client library complexity and version skew risk
- Inconsistent load distribution due to client-local view
- Backend health state divergence across clients
- Coordination overhead for global load awareness

**Failure Modes:**

- Thundering herd during mass backend recovery
- Split-brain during network partition with stale backend lists
- Client-side connection pool exhaustion under load

### Sidecar Proxy Pattern

Per-instance proxy co-located with application, intercepts outbound connections, provides transparent load balancing, observability, and policy enforcement without application code changes.

**Data Plane Characteristics:**

- L7 protocol awareness (Envoy, Linkerd)
- Automatic service discovery via control plane
- Mutual TLS between sidecars
- Per-request routing with dynamic configuration

**Control Plane Integration:**

- Centralized policy distribution (Istio, Consul Connect)
- Certificate management and rotation
- Traffic routing rules and load balancing configuration
- Observability data aggregation

**Scalability Considerations:**

- Per-pod resource overhead (CPU, memory, network)
- Control plane scalability bottleneck with large fleets
- Configuration propagation latency

### Hardware Load Balancers

Purpose-built appliances with ASIC or FPGA acceleration for high-throughput, low-latency packet processing.

**Architectural Characteristics:**

- Multi-Gbps/Tbps throughput with sub-millisecond latency
- L4 and L7 processing with hardware offload
- High availability via active-passive or active-active clustering with state synchronization
- Session table synchronization across cluster members

**Operational Constraints:**

- Vendor lock-in and proprietary configuration
- Limited horizontal scalability
- Physical footprint and power requirements
- Cost envelope at hyperscale

### Software Load Balancers

User-space implementations on commodity hardware (HAProxy, NGINX, Envoy, Traefik).

**Deployment Models:**

- Single-instance with DNS failover
- Active-passive with VRRP or keepalived
- Active-active cluster with ECMP or BGP anycast
- Containerized with orchestrator-managed lifecycle

**Scalability Patterns:**

- Multi-threaded event loop with lock-free data structures
- Connection migration between worker threads
- Kernel bypass (DPDK, XDP) for packet processing acceleration
- eBPF-based programmable packet filtering

### Global Server Load Balancing (GSLB)

Distributes traffic across geographically distributed data centers based on client location, backend health, and policy.

**Routing Strategies:**

- **Geographic Proximity:** Client-to-PoP latency minimization via IP geolocation
- **Latency-Based:** Real User Monitoring (RUM) or synthetic probes for latency measurement
- **Failover:** Primary-secondary with health-check-driven failover
- **Load-Based:** Cross-region load distribution with feedback loop

**Implementation Approaches:**

- DNS-based with GeoDNS and health check integration
- Anycast with BGP route advertisement, backend withdrawals trigger route changes
- HTTP redirect or proxy-based with application-layer decision

**Consistency and Coordination:**

- Health state propagation delay across regions
- Split-brain during inter-region network partition
- Session affinity challenges with regional failover

**CAP Trade-offs:**

- Availability prioritization with eventual consistency of health state
- Partition tolerance via independent regional operation
- Consistency sacrificed for liveness during network partition

### Rate Limiting and Quota Enforcement

Controls request rate per client, tenant, or API endpoint to prevent resource exhaustion and ensure fair sharing.

**Token Bucket Algorithm:**

- Fixed capacity bucket, refill at constant rate
- Allows burst traffic up to bucket size
- Distributed implementation with Redis or similar coordination store
- Race conditions during concurrent token consumption require atomic operations (Lua scripts, INCR)

**Leaky Bucket:**

- Queue with fixed processing rate
- Smooth traffic without bursts
- Queue overflow as backpressure mechanism

**Fixed Window Counters:**

- Per-window counter with reset at boundary
- Boundary synchronization creates burst potential at window edge
- Low overhead, eventual consistency acceptable

**Sliding Window Log:**

- Maintains timestamped request log
- Evicts expired entries on each request
- Accurate but memory-intensive

**Distributed Rate Limiting:**

- Sharded counters with per-node quotas (risk of unfair distribution)
- Centralized coordination with consensus (latency overhead)
- Gossip-based eventually consistent counters
- Hierarchical quotas (global → regional → instance)

### Request Hedging and Adaptive Retry

Mitigates tail latency by issuing redundant requests to multiple backends.

**Hedging Strategy:**

- Issue initial request, start timer
- At percentile latency threshold (e.g., P95), issue hedged request to different backend
- Cancel slower request upon first response
- Resource amplification factor vs latency improvement trade-off

**Retry Logic:**

- Exponential backoff with jitter to prevent thundering herd
- Idempotency enforcement (unique request ID, deduplication)
- Retry budget to limit resource amplification (e.g., max 10% additional load)
- Selective retry based on error class (connection failure vs application error)

**Coordination:**

- Request ID propagation for duplicate detection
- Backend-side deduplication with bloom filters or distributed cache

### Consistent Hashing for Stateful Backends

Maps requests to backends with minimal reassignment during topology changes, critical for cache hit rate preservation or session affinity.

**Virtual Nodes:**

- Each physical backend assigned multiple positions on hash ring
- Improves load distribution uniformity
- Virtual node count tuning (100-1000 per backend) balances overhead and evenness

**Bounded Load Consistent Hashing:**

- Caps load per backend to prevent hotspots
- Fallback to secondary ring positions when primary overloaded
- Requires load feedback mechanism

**Failure Handling:**

- Backend removal redistributes keys to clockwise neighbors
- Addition inserts at ring position, claims subset of keys
- Rebalancing latency vs cache miss trade-off

**Replication Factor:**

- Store keys on R successive backends on ring
- Read-write quorum (W+R > N) for consistency
- Sloppy quorum with hinted handoff during failure

### Active-Active vs Active-Passive Load Balancer Clustering

**Active-Passive:**

- Primary handles traffic, secondary standby monitors via heartbeat
- VRRP (Virtual Router Redundancy Protocol) for virtual IP failover
- Session state synchronization (incremental or batch) to secondary
- Failover delay (heartbeat timeout + takeover)
- Wasted capacity on standby
- Split-brain prevention via quorum or fencing

**Active-Active:**

- All instances handle traffic, distributed via ECMP or anycast
- Stateless request processing or distributed session store (Redis, Hazelcast)
- Session affinity breakage risk during instance failure
- Better resource utilization
- Requires consistent hashing or session replication for statefulness
- Partition tolerance via independent instance operation

### Cross-Region Failover and Traffic Shifting

**DNS-Based Failover:**

- Health check triggers DNS record update
- TTL-bound propagation creates blackout window
- Client-side retry required during transition

**Anycast Failover:**

- Regional PoPs advertise same IP prefix
- Prefix withdrawal triggers BGP reconvergence (seconds)
- In-flight connections broken, application-layer retry required

**Application-Layer Redirection:**

- Primary region returns HTTP 307 redirect to secondary
- Client follows redirect transparently
- Redirection hop increases latency

**Traffic Shifting:**

- Gradual percentage-based migration between regions
- Observability validation at each increment
- Rollback capability via traffic dial-back

### Load Balancing for Streaming Protocols

**WebSocket:**

- Long-lived bidirectional connection
- Sticky session required to maintain connection to same backend
- Connection draining during backend scale-down (send close frame, allow graceful termination)
- Health check via ping/pong frames

**gRPC Streaming:**

- HTTP/2 stream per RPC, multiple streams per connection
- Backend scaling requires application-level load balancing (gRPC LoadBalancer API, Envoy)
- L4 load balancer creates connection-level affinity, preventing stream-level distribution

**QUIC/HTTP/3:**

- Connection migration preserves session across IP/port changes
- Connection ID routing at load balancer without 5-tuple dependence
- Load balancer must maintain connection ID to backend mapping

### Failure Modes and Degradation Strategies

**Cascading Failure:**

- Backend failure increases load on remaining instances
- Triggers additional failures via resource exhaustion
- Mitigation: aggressive circuit breaking, load shedding, capacity headroom

**Retry Storm:**

- Clients retry failed requests, amplifying load on recovering backends
- Mitigation: exponential backoff with jitter, retry budget, backpressure signaling

**Split-Brain:**

- Network partition creates multiple active primaries (active-passive) or inconsistent state (active-active)
- Mitigation: quorum-based fencing, partition detection with external arbiter

**Configuration Propagation Failures:**

- Control plane unavailable or partitioned
- Mitigation: data plane continues with last-known-good configuration, eventual consistency acceptable for routing rules

**Health Check Flapping:**

- Transient failures trigger rapid backend state changes
- Mitigation: hysteresis (require N consecutive failures/successes), exponential backoff on failures

### Related Patterns and Topics

- Service Mesh Architecture
- API Gateway Pattern
- Backend for Frontend (BFF)
- Circuit Breaker Pattern
- Bulkhead Isolation
- Rate Limiting and Throttling
- Content Delivery Networks (CDN)
- Edge Computing and Regional PoPs
- Autoscaling and Capacity Planning
- Connection Pooling
- Request Coalescing
- Distributed Tracing
- Blue-Green and Canary Deployments

---

