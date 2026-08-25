## Failure Handling


### Failure Detection

**Heartbeat Mechanisms**

Periodic heartbeat messages signal liveness. Timeout expiration marks nodes as suspected failed. Adaptive timeout adjustment compensates for variable network latency (Phi Accrual Failure Detector). False positive rate increases with aggressive timeouts. Heartbeat aggregation reduces network overhead in large clusters. Indirect heartbeats through intermediaries improve failure detection accuracy under partial connectivity.

**Gossip-Based Membership**

SWIM protocol propagates membership updates via epidemic dissemination. Suspicion mechanism delays node removal, allowing false failure recovery. Incarnation numbers resolve conflicting membership states. Piggyback dissemination attaches membership updates to existing messages. Ring-based gossiping ensures O(log N) propagation latency. Firewall traversal challenges require relay nodes.

**Lease-Based Detection**

Time-bounded leases grant temporary resource ownership. Lease expiration revokes privileges without explicit revocation messages. Clock synchronization bounds (NTP, PTP) affect lease duration safety margins. Lease renewal protocols balance detection latency vs. network overhead. Fencing tokens prevent split-brain scenarios when leases expire during network partitions.

### Replication Strategies

**Synchronous Replication**

Primary waits for acknowledgment from all replicas before commit. Provides strongest durability guarantees. Write latency bounded by slowest replica. Single slow or unavailable replica blocks all writes. Quorum-based synchronous replication (majority acknowledgment) balances availability and consistency. Chain replication serializes writes through replica chain.

**Asynchronous Replication**

Primary commits locally, replicates asynchronously. Minimizes write latency. Potential data loss on primary failure before replication completes. Replication lag affects read-after-write consistency. Tunable replication factor trades durability vs. throughput. Cross-datacenter replication typically asynchronous due to WAN latency.

**Semi-Synchronous Replication**

Primary waits for at least one replica acknowledgment. Balances latency and durability. MySQL semi-sync waits for single replica before commit. Fallback to asynchronous mode if no replica available. Replication lag on lagging replicas doesn't block writes. Aurora storage layer uses quorum writes (4 of 6 copies).

### Consensus and Leader Election

**Raft Consensus**

Leader handles all client requests, replicates log entries to followers. Log replication uses AppendEntries RPCs with consistency checks. Election safety via term numbers and log completeness checks. Committed entries appear on majority of servers. Leader election timeout randomization prevents split votes. Log compaction via snapshotting bounds log growth.

**Multi-Paxos**

Distinguished proposer serializes proposals, reducing message complexity. Prepare phase establishes proposer leadership. Accept phase replicates values to acceptors. Learners observe chosen values. Stable leader optimization skips prepare phase for subsequent proposals. Reconfiguration protocol changes quorum membership.

**ZooKeeper Atomic Broadcast (ZAB)**

Primary-backup replication with strong ordering guarantees. Leader election via fast leader election (FLE) protocol. Transaction log replication with ZXID (epoch + counter) ordering. Crash recovery synchronizes followers with leader's committed log. Ephemeral nodes and watches enable coordination primitives. Two-phase commit for leader election ensures unique leader per epoch.

### Checkpoint and Recovery

**Distributed Snapshotting**

Chandy-Lamport algorithm captures globally consistent snapshot without stopping computation. Markers flow through communication channels to delineate snapshot boundary. Each process records local state and in-flight messages. Causal consistency ensures snapshot reflects possible execution. Flink and Spark use variants for stateful stream processing recovery.

**Write-Ahead Logging (WAL)**

All mutations logged before applying to in-memory structures. Sequential writes optimize disk I/O. Log sequence numbers (LSN) track write ordering. Checkpoints periodically flush dirty pages, truncating log. Redo log enables crash recovery by replaying committed transactions. Undo log for rollback during recovery (ARIES protocol).

**State Machine Replication**

Replicas apply deterministic operations in identical order. Consensus protocol orders operations across replicas. State machine determinism ensures replica convergence. Snapshot transfer for new replicas joining cluster. Optimizations: speculative execution, state partitioning, batching.

### Failure Isolation and Containment

**Bulkhead Pattern**

Isolate resource pools (threads, connections, memory) by service or tenant. Failure in one compartment doesn't exhaust shared resources. Thread pool per downstream service prevents cascading failures. Circuit breakers per bulkhead enable fine-grained failure handling. Kubernetes namespaces with resource quotas enforce bulkheads.

**Shuffle Sharding**

Assign each customer to subset of backend servers. Limits blast radius—single server failure affects only customers assigned to it. Reduces correlation between customer workloads. Increases isolation at cost of reduced statistical multiplexing. AWS service implementations use shuffle sharding for fault isolation.

**Cell-Based Architecture**

Partition infrastructure into independent failure domains (cells). Each cell handles subset of customer traffic. Cell failures isolated—no cross-cell dependencies. Cell placement strategies balance load and failure independence. Routing layer directs requests to healthy cells. Reduces scale of coordinated deployments.

### Degraded Mode Operations

**Graceful Degradation**

Disable non-critical features during overload or partial failures. Serve cached or stale data when authoritative source unavailable. Reduce data freshness guarantees (eventual consistency vs. strong consistency). Skip expensive computations (personalization, recommendations). Static fallback responses for unavailable dynamic content.

**Load Shedding**

Reject requests exceeding capacity to protect system stability. Admission control at edge proxies or service entry points. Priority-based shedding preserves critical traffic. Rate limiting per tenant or API key. Exponential backoff for rejected clients. Connection limiting prevents resource exhaustion.

**Retry Budgets**

Limit retry attempts to prevent retry storms. Per-request retry budget decrements with each retry. Global retry rate limiting across fleet. Exponential backoff with jitter randomizes retry timing. Idempotency tokens ensure safe retries for non-idempotent operations. Circuit breakers open after budget exhaustion.

### Chaos Engineering

**Controlled Fault Injection**

Terminate processes or containers randomly (chaos monkey). Inject network latency or packet loss. Induce resource exhaustion (CPU, memory, disk). Simulate clock skew or drift. Trigger cascading failures across service boundaries. Gradually increase fault intensity (blast radius expansion).

**Observability Under Failure**

SLO monitoring during experiments validates resilience targets. Distributed tracing identifies failure propagation paths. Anomaly detection baselines establish normal vs. degraded behavior. Canary metrics compare experiment vs. control populations. Automated experiment halt when SLOs violated.

**Hypothesis-Driven Testing**

Formulate steady-state hypothesis (e.g., "request success rate > 99.9%"). Define failure injection scenario. Run experiment, measure deviation from steady state. Analyze failure modes and mitigations. Iterate on system improvements. Document runbooks from experiment outcomes.

### Failure Recovery Patterns

**Retry with Exponential Backoff**

Immediate retry for transient failures. Exponential delay increase reduces load on struggling backend. Jitter (randomization) prevents thundering herd. Maximum retry count prevents infinite loops. Idempotency requirements for safe retries. Circuit breaker integration halts retries during sustained failures.

**Compensating Transactions**

Saga pattern coordinates distributed transactions across services. Each step has compensating action for rollback. Forward recovery: continue saga with alternative paths. Backward recovery: undo completed steps via compensating transactions. Semantic lock prevents concurrent modifications during saga execution. Idempotent compensations handle retry scenarios.

**Leader Re-election**

Detect leader failure via heartbeat timeout or explicit abdication. Follower initiates election with incremented term/epoch. Candidate solicits votes from quorum of peers. Vote grant based on log completeness and term currency. New leader synchronizes followers to consistent state. Client requests redirect to new leader after election.

**Quorum Reconfiguration**

Add new replicas to replace failed nodes. Gradual membership change (Raft joint consensus) avoids split-brain. New members catch up via log replay or snapshot transfer. Old member removal after new members fully synchronized. Maintain quorum availability during reconfiguration. Automated replacement for cloud environments.

### Cascading Failure Prevention

**Timeout Propagation**

Upstream timeout shorter than downstream timeout. Prevents request queuing at each tier. Deadline propagation in RPC metadata (gRPC, Finagle). Cancel inflight requests when client disconnects. Abort long-running operations when deadline exceeded. Resource cleanup on timeout prevents leaks.

**Adaptive Concurrency Limiting**

Measure backend latency and error rate. Adjust concurrency limit to maintain target latency (Little's Law). Gradient algorithms (TCP Vegas-style) probe for optimal concurrency. Reject requests exceeding concurrency limit. Per-backend limits in load balancers. Feedback loop stabilizes under load spikes.

**Downstream Failure Isolation**

Circuit breakers per downstream dependency. Fallback logic provides degraded functionality. Caching shields backends from repeated failures. Asynchronous workflows decouple caller from callee availability. Queued requests with TTL prevent unbounded growth. Bulkheads prevent single dependency exhaustion of resources.

### Data Durability and Recovery

**Redundant Storage**

RAID configurations (mirroring, parity) protect against disk failures. Erasure coding (Reed-Solomon) distributes data across nodes with redundancy. Object stores (S3) replicate across availability zones. Quorum-based writes ensure durability before acknowledging. Scrubbing detects and repairs silent corruption. Geographic replication protects against regional failures.

**Point-in-Time Recovery**

Continuous WAL archival enables recovery to arbitrary timestamp. Snapshot plus incremental log replay restores state. Retention policies balance storage cost vs. recovery granularity. Cross-region log shipping for disaster recovery. Logical replication enables selective table recovery. Backup validation via periodic restore tests.

**Multi-Region Failover**

Active-passive: standby region receives asynchronous replication. Active-active: both regions serve traffic, bidirectional replication. RPO (recovery point objective) determined by replication lag. RTO (recovery time objective) determined by failover automation. DNS or global load balancer redirects traffic. Data consistency challenges with active-active under partition.

**Related Topics**

Byzantine fault tolerance, distributed consensus, epidemic protocols, self-stabilization, failure detectors, checkpointing algorithms, distributed debugging

---

