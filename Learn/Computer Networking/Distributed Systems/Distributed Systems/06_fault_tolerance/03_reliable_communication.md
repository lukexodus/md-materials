## Reliable Communication


### Fundamental Failure Models

**Crash-stop failures**: Process halts and does not resume. Simplest model for reasoning about correctness. Enables fail-stop semantics where failed nodes are detectable and permanently excluded.

**Crash-recovery failures**: Process halts but may restart with partial or full state recovery. Requires durable storage and recovery protocols. Introduces complexity around message replay, duplicate detection, and state reconstruction.

**Omission failures**: Messages sent but not delivered, or delivered but not processed. Subdivides into send-omission (sender-side) and receive-omission (receiver-side). Network partitions manifest as sustained bidirectional omissions.

**Timing failures**: Messages or computations exceed expected latency bounds. Relevant in partially synchronous and real-time systems. May trigger timeout-based failure detection, potentially causing false positives.

**Byzantine failures**: Arbitrary behavior including message corruption, malicious actions, or incorrect computation. Requires cryptographic authentication, quorum-based validation, and redundant verification paths.

### Delivery Guarantees

**At-most-once**: Message delivered zero or one time. Achieved via fire-and-forget or non-idempotent operations with no retry. Minimizes duplicate processing at cost of potential data loss. Suitable for lossy telemetry, best-effort notifications.

**At-least-once**: Message delivered one or more times. Sender retries until acknowledgment received. Requires idempotent receivers or duplicate detection mechanisms. Default for most reliable messaging systems due to implementation simplicity.

**Exactly-once**: Message effects applied precisely once. Semantic guarantee, not transport guarantee. Implemented via idempotency keys, transactional outbox pattern, or distributed transactions coordinating send and processing. Requires coordination between sender, transport, and receiver state machines.

**Exactly-once processing**: Stronger variant ensuring side effects occur once even under retries. Combines idempotency with state checkpointing. Stream processing systems (Kafka Streams, Flink) implement via epoch-based barriers and transactional state updates.

### Acknowledgment Protocols

**Synchronous acknowledgments**: Sender blocks until receiver confirms delivery. Provides strong delivery guarantees with high latency cost. RPC semantics typically synchronous. Tight coupling between sender availability and receiver availability.

**Asynchronous acknowledgments**: Sender continues after send; acknowledgment processed separately. Decouples sender and receiver execution. Requires correlation identifiers and timeout-based retransmission logic. Higher throughput, weaker latency guarantees.

**Cumulative acknowledgments**: Single acknowledgment confirms delivery of all messages up to sequence number. Reduces acknowledgment traffic. TCP uses cumulative ACKs. Delays retransmission detection if acknowledgment lost.

**Selective acknowledgments**: Receiver explicitly acknowledges each message or range. Enables faster retransmission of specific missing segments. SACK TCP extension, QUIC acknowledgment frames. Higher metadata overhead, faster recovery.

**Negative acknowledgments (NACKs)**: Receiver explicitly requests retransmission of missing messages. Reduces acknowledgment traffic in high-reliability scenarios. Requires receiver to detect gaps via sequence numbers. Multicast protocols (PGM) use NACKs to minimize sender-side state.

### Timeout and Retry Strategies

**Fixed retry intervals**: Simplest strategy. Retry after constant delay. Vulnerable to thundering herd if many clients retry simultaneously. Suitable only for low-concurrency or non-shared resources.

**Exponential backoff**: Retry delay doubles after each failure. Standard approach (e.g., 1s, 2s, 4s, 8s). Reduces load on failing systems. Requires maximum backoff cap and total retry limit. Used in AWS SDKs, gRPC, Kafka producers.

**Exponential backoff with jitter**: Adds randomness to retry delay to desynchronize clients. Full jitter (`random(0, base * 2^attempt)`) or decorrelated jitter. Proven to minimize collision probability and reduce tail latencies. AWS recommends decorrelated jitter.

**Adaptive timeouts**: Timeout values adjust based on observed latency distributions. Track percentile latencies (p50, p99) and set timeout at p99 + margin. Responds to changing network conditions. Requires continuous measurement and statistical tracking.

**Deadline propagation**: Client specifies absolute deadline; intermediaries enforce. gRPC deadlines, AWS X-Ray tracing deadlines. Prevents cascading retries exceeding user-facing SLO. Each hop reduces remaining budget.

**Circuit breaker pattern**: After threshold of consecutive failures, stop attempting requests for cooldown period. Prevents resource exhaustion on cascading failures. States: closed (normal), open (failing), half-open (testing recovery). Hystrix, Resilience4j implementations.

### Idempotency and Deduplication

**Natural idempotency**: Operations inherently idempotent (SET, DELETE, PUT with full replacement). Simplest approach requiring no additional infrastructure. Not applicable to increment, append, or read-modify-write operations.

**Idempotency keys**: Client generates unique identifier per logical operation. Server stores key with result in durable storage. Duplicate requests return cached result. Stripe API uses idempotency keys for payment processing. Requires key expiration policy and storage overhead.

**Sequence numbers**: Monotonically increasing per-sender sequence number. Receiver tracks highest processed sequence per sender. Duplicates detected as sequence ≤ highest processed. Requires per-sender state at receiver. Kafka offset tracking, TCP sequence numbers.

**Bloom filters for deduplication**: Probabilistic data structure for membership testing. Space-efficient duplicate detection with false positive rate. Cannot remove entries (use counting Bloom filter variant). Suitable for high-throughput streaming where occasional false positives acceptable.

**Transactional outbox pattern**: Write message and state change in single local transaction. Separate process reads outbox table and publishes to message broker. Guarantees atomicity of state update and message send. Requires polling or change-data-capture on outbox table.

**Distributed transaction coordinators**: Two-phase commit (2PC) or three-phase commit (3PC) protocols. Coordinator collects prepare votes, then issues commit or abort. Blocking protocol vulnerable to coordinator failure. Used in XA transactions, distributed databases with ACID guarantees.

### Message Ordering Guarantees

**Per-partition ordering**: Messages within same partition key delivered in send order. Kafka topic partitions, Kinesis shards. Sender selects partition via hash(key). Ordering not guaranteed across partitions. Scalability limited by partition count.

**Total ordering**: All messages delivered in same order to all receivers. Requires global coordination. Implemented via single-leader replication, atomic broadcast, or consensus protocols (Paxos, Raft). Latency cost proportional to coordination overhead.

**Causal ordering**: Messages causally related delivered in causal order; concurrent messages may arrive in any order. Captures happened-before relation. Implemented via vector clocks, version vectors, or causal broadcast protocols. Weaker than total ordering, cheaper to implement.

**FIFO ordering**: Messages from same sender delivered in send order. No cross-sender ordering guarantees. Cheapest ordering guarantee. Requires per-sender sequence numbers. Sufficient for many application scenarios (user action sequences, session events).

**No ordering guarantees**: Messages may arrive in arbitrary order. Enables maximum parallelism and lowest latency. Application must handle reordering or use commutative operations. Suitable for metrics aggregation, independent events.

### Failure Detection

**Heartbeat mechanisms**: Periodic liveness messages from monitored process. Timeout indicates suspected failure. False positives occur on network delays or receiver overload. Heartbeat interval vs timeout trade-off: shorter interval increases network traffic, shorter timeout increases false positive rate.

**Gossip-based failure detection**: Nodes exchange membership information via epidemic protocols. SWIM protocol uses direct probes and indirect probes via random nodes. Tunable detection time vs network overhead. Cassandra, Consul cluster membership.

**Phi Accrual Failure Detector**: Adaptive failure detector using continuous suspicion value (phi) rather than binary up/down. Phi calculated from arrival time distribution of heartbeats. Threshold phi value determines failure declaration. Adapts to network conditions. Used in Akka, Cassandra.

**Perfect failure detector**: Theoretical construct guaranteeing eventual detection of all failures, no false positives. Not implementable in asynchronous systems (FLP impossibility). Requires synchrony assumptions or partial synchrony.

**Eventually perfect failure detector**: Eventually detects all failures and eventually stops suspecting correct processes. Sufficient for solving consensus in partially synchronous systems. Practical approximation via adaptive timeouts.

### Request-Reply Patterns

**Synchronous RPC**: Client blocks until response received or timeout. Simple programming model but tight coupling. gRPC unary calls, HTTP request-response. Load on caller during long-running operations. Connection held during processing.

**Asynchronous RPC**: Client receives future/promise immediately, continues execution. Response arrives asynchronously via callback or polling. gRPC async stubs, Finagle Futures. Requires correlation between request and response. Better resource utilization.

**Request-reply via messaging**: Client sends request message, includes reply-to address and correlation ID. Server processes and sends reply to specified destination. Decouples client and server lifetimes. RabbitMQ reply-to, JMS correlation ID. Enables load balancing, routing, and offline processing.

**Saga pattern**: Long-running transaction decomposed into local transactions with compensating actions. Coordinator manages execution sequence. Forward recovery (retry) or backward recovery (compensate) on failure. Choreography (event-driven) or orchestration (coordinator-driven) variants.

### Compensation and Rollback

**Compensating transactions**: Business logic to undo effects of completed transaction. Not true rollback; semantic inverse operation. Example: credit account to compensate debit. Requires domain-specific compensation logic. Saga pattern building block.

**Forward recovery**: On failure, continue attempting operation or alternative path. Assumes operation will eventually succeed. Retry with backoff, failover to replica, degrade to eventual consistency.

**Backward recovery**: On failure, undo changes and restore previous state. Requires state snapshots or operation logs. Checkpoint-based recovery in stream processing. Higher consistency guarantees but complexity cost.

**Invariant preservation**: Ensure system invariants maintained across failures. Example: account balance never negative despite concurrent operations. Requires coordination (locks, CAS operations) or conflict-free replicated data types.

### Quorum-Based Replication

**Read and write quorums**: Write to W replicas, read from R replicas where R + W > N (total replicas). Guarantees overlap between read and write sets. Dynamo-style systems (Cassandra, Riak). Trade-off between consistency, availability, and latency.

**Strict quorums**: R + W > N ensures read observes latest write. Sloppy quorums (R + W ≤ N) sacrifice consistency for availability during partitions. Hinted handoff delivers writes to reachable nodes outside primary replica set.

**Quorum intersection properties**: Overlapping quorum sets enable consistent reads. Non-overlapping quorums risk reading stale data. Flexible quorum configurations for read-heavy vs write-heavy workloads.

**Conflict resolution**: Last-write-wins (timestamp-based), vector clocks (causal ordering), CRDTs (convergent resolution), or application-specific merge functions. Dynamo vector clocks, Riak sibling resolution.

### End-to-End Argument

**Core principle**: Reliability functions should be implemented at application endpoints rather than intermediate layers. Lower layers provide best-effort service; endpoints add reliability mechanisms (acknowledgments, retries, checksums).

**Implications for architecture**: Network layer may drop packets; TCP provides reliable stream. TCP may reorder; application adds sequence numbers. Disk may corrupt; application checksums data. Intermediate caching or proxying cannot guarantee end-to-end properties without endpoint cooperation.

**Trade-offs**: Lower-layer reliability reduces retransmissions but adds latency and complexity. End-to-end checksums detect corruption across all layers. Application-layer acknowledgments ensure business-level processing completion.

### Network Partition Handling

**Partition detection**: Nodes unable to communicate form separate components. Detection via failure detectors, heartbeat loss, or lack of quorum. Ambiguous in asynchronous systems (partition vs slow network vs crashed node).

**Split-brain prevention**: Multiple components independently process writes, creating divergent state. Prevention via quorum requirements, fencing tokens, or generation numbers. ZooKeeper epoch numbers, Raft term numbers, Paxos ballot numbers.

**Quorum approaches**: Operate only if majority reachable. Minority partition becomes unavailable. Prevents split-brain but sacrifices availability in minority partition. Consistent hashing with virtual nodes distributes keys across partitions.

**Primary component election**: During partition, elect single component as primary via consensus. Only primary accepts writes. Other partitions become read-only or unavailable. Group membership protocols, virtual synchrony.

**Last-write-wins conflict resolution**: Use timestamps to resolve concurrent writes. Vulnerable to clock skew. Requires synchronized clocks or logical timestamps (Lamport, vector). Cassandra default strategy.

**CRDT-based merge**: Conflict-free replicated data types guarantee convergence without coordination. Replicas independently accept writes and merge via deterministic, commutative, associative operations. Riak datatypes, Redis CRDTs, Automerge. Limited operation set (counters, sets, registers, maps).

### Fencing and Distributed Locks

**Fencing tokens**: Monotonically increasing token issued by lock service. Client includes token in requests to protected resource. Resource rejects requests with stale tokens. Prevents zombie clients with expired locks from corrupting state.

**Distributed lock services**: ZooKeeper, etcd, Consul provide distributed locking. Ephemeral nodes tied to client sessions. Lock released on session timeout. Requires lease-based sessions with keepalive heartbeats.

**Lock-free coordination**: Compare-and-swap (CAS), optimistic concurrency control, or MVCC avoid locks. Reduced contention and deadlock elimination. Higher retry rate under contention. DynamoDB conditional writes, etcd compare-and-swap.

**Lease-based exclusivity**: Time-bounded lock with automatic expiration. Client renews lease before expiration. Balances availability (automatic release) and safety (prevents split-brain if client partitioned). Chubby, HDFS lease-based file writes.

### Session Management and State Transfer

**Session affinity (sticky sessions)**: Route requests from same client to same server. Simplifies server-side state management. Reduces load balancer flexibility. Server failure loses sessions. Not recommended for high availability.

**Session state externalization**: Store session state in shared data store (Redis, Memcached). Stateless application servers. Adds latency for state access. Requires serialization and network round-trips. Scales horizontally.

**State transfer on failover**: Primary replicates session state to backup. On failure, backup assumes primary role with current state. Warm standby or hot standby configurations. Requires state synchronization protocol. Used in telecom, financial systems.

**Session reconstruction**: On failover, client resends necessary state or operations. Stateless servers reconstruct transient state from persistent sources. Idempotent operations enable safe replay. JWT tokens encode session state.

### Checksums and Data Integrity

**End-to-end checksums**: Application calculates checksum on write, verifies on read. Detects corruption in memory, disk, network. Stronger than per-layer checksums. HBase, Cassandra use CRC32 per block.

**Cryptographic hashes**: SHA-256, SHA-3 provide collision resistance. Verify data integrity across untrusted networks. Git content-addressable storage, blockchain merkle trees. Higher CPU cost than CRC.

**Parity and erasure coding**: Distribute data and parity across multiple nodes. Tolerate loss of k nodes with m parity chunks. Reed-Solomon coding in HDFS RAID, Ceph erasure coding. Space overhead vs replication: (n + m) / n vs replication factor.

**Scrubbing and repair**: Periodically verify checksums and repair corrupted data from replicas. Background process to detect silent corruption. Cassandra nodetool repair, HDFS fsck. Balances detection latency and resource utilization.

### Observability for Reliability

**Request tracing**: Distributed traces span service boundaries with correlation IDs. Capture timing, errors, retries across call graph. OpenTelemetry, Jaeger, Zipkin. Identify retry amplification, timeout misconfigurations.

**Error budgets**: SLO-based allowance for failures. Reliability target (e.g., 99.9%) implies 0.1% error budget. Track error budget consumption. Informs trade-offs between feature velocity and reliability investment.

**Retry amplification metrics**: Measure retry rate at each tier. Upstream timeout shorter than downstream timeout causes exponential retry amplification. Monitor retry ratio (retries / initial requests) per service.

**Latency percentiles**: Track p50, p95, p99, p99.9 latencies. Timeouts should exceed p99 to minimize false failures. Tail latency amplification occurs when aggregating many parallel requests.

### Related Topics

- Consensus protocols (Paxos, Raft, Zab)
- Causal consistency and COPS protocol
- Chain replication and primary-backup replication
- Gossip protocols and epidemic algorithms
- Leader election algorithms
- State machine replication
- Byzantine fault tolerance (PBFT, HoneyBadger BFT)
- Logical clocks and vector clocks
- Merkle trees for anti-entropy
- Atomic commitment protocols (2PC, 3PC)
- Distributed snapshot algorithms (Chandy-Lamport)
- Self-stabilizing systems
- Linearizability and serializability
- Session guarantees in distributed systems
- Conflict-free replicated data types (CRDTs)

---

