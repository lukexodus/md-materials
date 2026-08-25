## Distributed Caching


### Architectural Topology Models

**Client-Side Caching** Cache instances embedded within application processes. Data locality eliminates network hops for cache hits. Invalidation complexity increases with client count. Memory footprint scales linearly with client instances. Consistency model typically eventual or best-effort. Suitable for read-heavy immutable or reference data with tolerable staleness.

**Proxy/Sidecar Caching** Cache deployed as co-located process sharing node resources with application. Service mesh integration common (Envoy, Linkerd). Request interception at network boundary. Reduces application-level cache client complexity. Memory contention with application workload. Failure domain shared with application process. Observability integrated into mesh control plane.

**Dedicated Cache Cluster** Standalone cache tier with independent scaling, failure domains, and resource allocation. Client libraries handle cluster topology awareness, request routing, and connection pooling. Operational isolation from application and data tiers. Network latency becomes critical path component. Supports multi-tenancy with resource partitioning.

### Partitioning and Data Distribution

**Consistent Hashing** Hash ring distribution with virtual nodes (vnodes) for load balancing. Ketama algorithm common for deterministic client-side routing. Partition key hashing determines node assignment. Rebalancing on node addition/removal affects only adjacent partitions (average K/N keys where K=total keys, N=nodes). Virtual node count trades memory overhead for distribution uniformity. Jump hash and rendezvous hashing alternatives offer O(1) rebalancing computation.

**Range Partitioning** Keyspace divided into ordered ranges assigned to nodes. Enables efficient range scans and ordered iteration. Hotspot risk with non-uniform key distribution or temporal locality. Requires metadata service for range-to-node mapping. Splitting and merging ranges for load balancing increases coordination overhead. Cassandra token ranges and HBase region splits implement this model.

**Hash Slot Distribution** Fixed slot count (Redis Cluster: 16384 slots) mapped via CRC16 or similar. Slots assigned to nodes with rebalancing via slot migration. Client maintains slot-to-node mapping via gossip or centralized configuration. Enables fine-grained migration units without rehashing. Resharding operation moves slots between nodes with minimal client impact.

### Replication Topologies

**Primary-Replica (Master-Slave)** Single writable primary per partition, multiple read replicas. Write path serialized through primary. Replication lag introduces read-your-writes consistency issues. Failover requires replica promotion with potential data loss window. Anti-entropy mechanisms (Redis: replication offset tracking) detect inconsistencies. Suitable for read-heavy workloads with acceptable staleness bounds.

**Multi-Primary (Active-Active)** Multiple nodes accept writes for same key namespace. Conflict resolution required: last-write-wins (LWW) with vector clocks or causal timestamps, CRDTs for convergent semantics, or application-level merge functions. Coordination-free writes maximize availability. Network partition creates divergent state requiring reconciliation. Riak, Cassandra with LWW, DynamoDB with version vectors implement variants.

**Quorum-Based Replication** Configurable read (R) and write (W) quorum sizes with replication factor (N). Strong consistency when R + W > N. Sloppy quorums with hinted handoff maintain availability during node failures. Read repair and anti-entropy (Merkle trees, hash trees) converge replicas. Tunable consistency-availability trade-off per operation. Dynamo-style systems foundational model.

### Consistency Models and Coordination

**Eventual Consistency** No ordering guarantees across replicas. Convergence to identical state given sufficient time without updates. Read-your-writes not guaranteed without session affinity. Monotonic reads require client-side version tracking. Reduces coordination overhead, maximizes availability. Suitable for commutative operations, analytics, and append-only workloads.

**Strong Consistency** Linearizability or sequential consistency guarantees. Requires coordination protocols: Paxos, Raft, or distributed locking. Coordination latency proportional to replica geographic distribution. Reduces availability during network partitions (CP in CAP). Consensus-based caches (etcd, Consul) or external coordination (ZooKeeper, Chubby) enable strong semantics.

**Causal Consistency** Preserves happens-before relationships via vector clocks or causal timestamps. Concurrent operations may be observed in different orders. Weaker than strong, stronger than eventual. Requires per-client or per-session metadata. COPS, Eiger implement causal+ consistency for geo-distributed caching.

**Session/Client Consistency** Monotonic reads, monotonic writes, read-your-writes, and writes-follow-reads guarantees within session boundary. Client-side version vectors or sticky routing to replicas. Session termination resets consistency scope. Redis with read-from-replica and session affinity implements subset of guarantees.

### Cache Invalidation and Coherence

**Time-to-Live (TTL) Expiration** Deterministic expiration after fixed duration. Passive expiration on access or active background scanning. Lazy deletion reduces write amplification. Clock skew across distributed nodes creates inconsistent expiration timing. Requires NTP synchronization or logical clocks. Stale reads possible until expiration.

**Write-Through Invalidation** Application invalidates cache synchronously with database write. Serialization point on write path increases latency. Cache-aside pattern with explicit invalidation common. Partial failure requires idempotent invalidation or compensating transactions. Invalidation fanout for multi-key dependencies (graph invalidation, tag-based) amplifies coordination cost.

**Write-Behind (Write-Back) Invalidation** Asynchronous invalidation decouples write latency from invalidation propagation. Message queue or event stream for invalidation commands. Eventual consistency window between write and invalidation. Duplicate invalidation handling required (idempotency). Ordering guarantees complex with partitioned invalidation streams.

**Change Data Capture (CDC)** Database binlog, WAL, or CDC stream drives invalidation. Decouples cache from application write path. Transactional boundaries preserved via log sequence numbers (LSN). Lag monitoring critical for consistency SLOs. Debezium, Maxwell, Databus enable CDC-driven invalidation patterns.

**Cache Coherence Protocols** Directory-based or snooping protocols adapted from CPU cache coherence. MESI (Modified, Exclusive, Shared, Invalid) state machine per cache line. Invalidation broadcast or point-to-point messaging. Requires low-latency interconnect, rarely practical in distributed caching beyond research contexts. Shared-nothing architectures avoid coherence overhead.

### Eviction Policies and Memory Management

**LRU/LFU and Approximations** Least Recently Used with doubly-linked list and hash map: O(1) access, O(1) eviction. Memory overhead per entry. Approximations: segmented LRU (Redis), CLOCK, random sampling reduce metadata cost. Least Frequently Used requires frequency counters with decay to handle temporal shifts. Count-Min Sketch approximates frequency with bounded error.

**Adaptive Replacement Cache (ARC)** Dual LRU lists (recent, frequent) with dynamic sizing. Ghost entries track evicted metadata without values. Self-tuning to workload characteristics. Patent encumbered, alternatives include CAR (Clock with Adaptive Replacement) and LIRS (Low Inter-reference Recency Set).

**Probabilistic Eviction** Random sampling selects eviction candidates. Redis samples configurable key count, evicts lowest TTL or LRU estimate. O(1) eviction complexity. Quality degrades with skewed access patterns. Suitable for large datasets where exact LRU overhead prohibitive.

**Segmented/Tiered Memory** Hot/warm/cold classification with different eviction policies. NVM (3D XPoint, Optane) as cache tier between DRAM and SSD. Promotes hot data to faster tier, demotes cold data. Page cache integration for kernel-managed memory tiers. Intel Memory Drive Technology, Memcached extstore implement multi-tier models.

### Data Structures and Storage Engines

**Hash Table Implementations** Chained hashing with linked lists or open addressing (linear probing, quadratic probing, double hashing). Lock-free variants with CAS operations for concurrent access. Hopscotch hashing optimizes cache-line locality. Resizing triggers rehashing, may require incremental migration (Redis progressive rehashing). Memory allocator integration (jemalloc, tcmalloc) reduces fragmentation.

**Log-Structured Storage** Append-only log with in-memory index. Write amplification minimized, read amplification via compaction. Segmented logs enable garbage collection of expired entries. RocksDB, WiredTiger backends for persistent caches. LSM-tree structure with memtable and SSTables. Bloom filters reduce read amplification.

**Memory-Mapped Files** Kernel page cache integration via mmap. OS handles memory pressure and eviction. Double-buffering eliminated, reduces memory copies. Transparent huge pages (THP) improve TLB efficiency. Page fault latency on cold reads. Persistence without explicit fsync in crash-consistent implementations (LMDB).

**B+ Tree Variants** LMDB (Lightning Memory-Mapped Database) copy-on-write B+ tree. MVCC via page-level versioning. Ordered key iteration and range scans. Higher read latency than hash tables, lower write amplification than LSM. Lock-free reads, writers serialize on single write transaction.

### Network Protocols and Communication

**Binary Protocols** Redis RESP (REdis Serialization Protocol): length-prefixed arrays and bulk strings. Memcached binary protocol: fixed header with opcode, key length, extras. Protocol Buffers, Thrift, or custom serialization for type safety and evolution. Pipelining multiple commands reduces round-trip latency. Request/response correlation via sequence numbers.

**Connection Pooling and Multiplexing** Client maintains persistent TCP connections across requests. Connection pool per backend node. Idle connection reaping and health checks. HTTP/2 or QUIC multiplexing for multiple concurrent requests over single connection. Connection stickiness for session affinity.

**Async I/O and Event-Driven Models** Non-blocking sockets with epoll, kqueue, or io_uring. Single-threaded event loop (Redis, Memcached) or multi-threaded with sharding (Memcached multi-threaded mode). Thread-per-core architecture avoids context switches. Kernel bypass (DPDK, RDMA) for microsecond latency requirements.

**Serialization Overhead** Native language serialization (Java Serialization, Python pickle) vs zero-copy formats (FlatBuffers, Cap'n Proto). Compression (LZ4, Snappy, Zstd) trades CPU for bandwidth. Schema evolution compatibility (forward, backward, full). Protobufs with field numbers enable non-breaking schema changes.

### Failure Detection and Recovery

**Heartbeat and Gossip Protocols** Periodic heartbeat messages detect node failures. Gossip-based cluster membership (SWIM protocol: Scalable Weakly-consistent Infection-style Membership). Failure detector properties: completeness (all failures detected) vs accuracy (no false positives). Phi Accrual Failure Detector adapts to network jitter. Redis Cluster gossip bus for topology propagation.

**Split-Brain Prevention** Quorum-based cluster membership decisions. Fencing tokens or generation numbers prevent zombie nodes. Coordination service (ZooKeeper, etcd) as external authority. Network partition detection via majority vote. Redis Sentinel for failover coordination without split-brain.

**Data Recovery and Rebuild** Replica rebuild from primary via full synchronization or incremental (Redis PSYNC with replication offset). Hinted handoff stores writes for temporarily unavailable nodes. Anti-entropy via Merkle tree comparison (Cassandra, DynamoDB). Checkpointing and snapshot transfer for large datasets.

**Circuit Breaker and Bulkheading** Client-side circuit breaker prevents cascading failures. Open/half-open/closed states based on error thresholds. Connection pool limits (bulkheads) isolate failure domains. Fail-fast semantics with fallback to origin or stale data. Hystrix, Resilience4j patterns applied to cache clients.

### Observability and Monitoring

**Performance Metrics** Hit rate, miss rate, eviction rate per key pattern or tenant. Latency percentiles (p50, p95, p99, p999) for GET/SET operations. Throughput (requests per second, bytes per second). Memory utilization and fragmentation ratio. Connection count and pool saturation.

**Consistency Metrics** Replication lag (seconds behind primary). Stale read ratio (reads served from lagging replicas). Conflict rate for multi-primary topologies. Anti-entropy repair volume. Read-your-writes violation rate.

**Distributed Tracing** OpenTelemetry or Zipkin integration for request flow across cache and origin. Trace context propagation via headers. Cache hit/miss spans correlated with database query spans. Latency attribution and critical path analysis.

**Anomaly Detection** Sudden hit rate degradation indicates application changes or cache warming issues. Elevated eviction rate signals memory pressure or TTL misconfiguration. Hotkey detection via key access histograms. Slow log for outlier latencies.

### Security and Isolation

**Authentication and Authorization** ACL per key pattern or namespace (Redis 6+ ACL with user/password/command restrictions). TLS for encrypted transport. Certificate-based mutual authentication. Token-based auth with JWT or OAuth2 integration.

**Multi-Tenancy and Isolation** Logical databases or keyspace prefixing per tenant. Resource quotas (memory, connection limits, throughput) via cgroups or kernel limits. noisy neighbor mitigation via QoS tagging or separate cache clusters. Data residency requirements enforce geographic placement.

**Data Encryption** Encryption at rest via OS-level (dm-crypt, LUKS) or cache-native mechanisms. Per-key encryption with key management service (KMS) integration. Encryption in transit via TLS 1.3. Performance overhead: symmetric encryption (AES-GCM) adds ~10-20% CPU.

**Cache Poisoning and Abuse** Input validation prevents cache key collisions via injection. Rate limiting per client or API key. Bloom filter or count-min sketch detect abnormal key distribution. Cache stampede mitigation via probabilistic early expiration or locking.

### Advanced Patterns and Optimizations

**Cache-Aside vs Read-Through/Write-Through** Cache-aside: application manages cache population, provides fine-grained control, couples application to cache logic. Read-through: cache loader function fetches on miss, simplifies application. Write-through: synchronous cache update on write, strong consistency. Write-behind: asynchronous batching, higher throughput, eventual consistency.

**Negative Caching** Cache absence of key (null value) to prevent repeated origin queries. Shorter TTL than positive entries. Mitigates cache penetration attacks. Requires disambiguation between cached null and cache miss.

**Probabilistic Data Structures** Bloom filters reduce cache-aside misses for non-existent keys. Count-Min Sketch for frequency estimation in LFU. HyperLogLog for cardinality estimation. Cuckoo filters enable deletion unlike Bloom filters. False positive rate tunable via bit array size and hash function count.

**Thundering Herd Mitigation** Request coalescing for concurrent misses on same key. Per-key mutex or semaphore in application. Probabilistic early expiration (jittered TTL) staggers refetches. Stale-while-revalidate serves stale data during background refresh.

**Geo-Distributed Caching** Regional cache clusters with routing via Anycast or GeoDNS. Active-active replication for low-latency local writes. Conflict-free replicated data types (CRDTs) for convergence without coordination. Cross-region replication lag monitoring. Cost optimization via tiered regional vs global cache.

**Warming and Preloading** Database scan and bulk load on startup. Gradual traffic ramp to populate cache organically. Key prediction via ML models on access patterns. Scheduled warming for known traffic spikes (e.g., events). Incremental warming avoids origin overload.

### Implementation Technologies

**Redis** Single-threaded event loop, append-only file (AOF) or RDB snapshots for persistence. Cluster mode with hash slot sharding. Sentinel for high availability. Pub/sub, streams, modules (RedisJSON, RedisGraph). IO threads for socket read/write in Redis 6+.

**Memcached** Multi-threaded with lock-free hash table. Extstore for SSD-backed storage. No persistence or replication (application-managed). Simple protocol, minimal features. Consistent hashing client libraries (libmemcached, spymemcached).

**Hazelcast** In-memory data grid with distributed map, queue, topic. Automatic partitioning and replication. WAN replication for geo-distribution. Near cache (local cache in client). Embedded or client-server deployment.

**Apache Ignite** Distributed database and caching platform. SQL queries over cache. ACID transactions with two-phase commit. Native persistence (write-ahead log, page memory). Compute grid for co-located processing.

**Couchbase** Document-oriented with memory-first architecture. Memcached binary protocol compatible. XDCR (Cross Data Center Replication) for geo-distribution. N1QL query language. Mobile Sync Gateway for edge caching.

### Related Topics

- Content Delivery Networks (CDN) Edge Caching
- Database Query Result Caching
- Materialized Views and Incremental Maintenance
- HTTP Caching (ETags, Cache-Control)
- Object Storage Tiering and Caching Layers
- Distributed Session Storage
- API Gateway Response Caching
- Proxy Caching (Varnish, Sqarnish, nginx)
- Full-Page Caching in Web Applications
- GraphQL Query Result Caching
- Lambda/Edge Compute Caching

---

