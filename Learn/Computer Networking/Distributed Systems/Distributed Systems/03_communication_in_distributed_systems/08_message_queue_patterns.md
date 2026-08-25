## Message Queue Patterns


Message queues decouple producers and consumers through asynchronous, persistent message buffering. Queues provide point-to-point delivery semantics where each message is consumed by exactly one consumer from a competing consumer group. The queue acts as a buffer absorbing load spikes and enabling temporal decoupling—producers and consumers operate independently without requiring simultaneous availability.

### Queue Semantics and Guarantees

**Delivery Guarantees**

- At-most-once: Messages may be lost, never duplicated. Acknowledgment before processing.
- At-least-once: Messages never lost but may duplicate. Acknowledgment after processing with idempotent consumers required.
- Exactly-once: Messages delivered once without loss or duplication. Requires distributed transactions (2PC) or idempotent processing with deduplication.

**Message Ordering**

- FIFO queues: Strict ordering per producer or message group. Requires single-threaded consumption or partitioning.
- Priority queues: Messages consumed by priority rather than arrival order. Can cause starvation of low-priority messages.
- Unordered queues: No ordering guarantees. Maximizes throughput through parallel consumption.
- Partial ordering: Ordering within partitions or message groups, no global ordering.

**Visibility and Locking**

- Visibility timeout: Message invisible to other consumers during processing window.
- Lock extension: Consumer extends lock while processing long-running operations.
- Poison message handling: Messages exceeding retry threshold moved to dead-letter queue.
- Message expiration: Time-to-live (TTL) causing automatic deletion.

### Queue Architecture Variants

**Simple Queue** Single logical queue with FIFO semantics. All consumers compete for messages. Bottleneck at high throughput due to single partition.

**Partitioned Queue** Queue logically split into independent partitions. Messages routed by partition key (hash, range, or explicit). Ordering preserved per partition. Enables horizontal scaling of consumption.

**Priority Queue** Multiple underlying queues per priority level. Higher priority queues consumed before lower. Risk of priority inversion if low-priority messages block resources.

**Delayed Queue** Messages become visible after configured delay. Implementation via scheduled delivery timestamp. Use cases: retry with exponential backoff, scheduled task execution.

**Dead-Letter Queue (DLQ)** Repository for messages that failed processing repeatedly. Prevents poison messages from blocking queue. Requires monitoring and manual intervention or automated replay.

### Message Delivery Patterns

**Competing Consumers** Multiple consumer instances process messages concurrently. Load distribution via round-robin or least-loaded. Requires idempotent processing for at-least-once delivery.

**Message Dispatcher** Central coordinator assigns messages to specific consumers based on routing rules, consumer capability, or load. Adds single point of coordination but enables sophisticated routing.

**Selective Consumer** Consumers filter messages using predicates or message properties. Inefficient if most messages discarded—consider routing before enqueue.

**Transactional Outbox** Messages written to database table in same transaction as business logic. Background process reads outbox and publishes to queue. Guarantees atomicity between database and message queue without distributed transactions.

### Persistence and Durability

**Storage Backends**

- In-memory: Lowest latency, no durability, data loss on crash.
- Write-ahead log (WAL): Append-only log with sequential writes, fsync for durability.
- Embedded databases: RocksDB, LevelDB for indexed access with compaction.
- Distributed storage: Replicated across nodes (HDFS, S3, distributed filesystems).

**Replication Strategies**

- Synchronous replication: Write acknowledged after replicating to N replicas. Strong durability, higher latency.
- Asynchronous replication: Write acknowledged immediately, replication eventual. Lower latency, potential data loss.
- Quorum writes: Write acknowledged after W replicas, readable from R replicas where R + W > N. Tunable consistency-latency trade-off.

**Durability Levels**

- No persistence: In-memory only, maximum throughput.
- Write-behind: Batched asynchronous flush to disk. Configurable flush interval vs. data loss window.
- Fsync per message: Immediate disk synchronization. Strongest durability, lowest throughput.
- Group commit: Batched fsync across multiple messages. Balances durability and throughput.

### Flow Control and Backpressure

**Consumer-Side Backpressure**

- Prefetch limits: Consumer fetches bounded number of messages. Prevents overwhelming slow consumers.
- Acknowledgment batching: Consumer acknowledges multiple messages together, reducing protocol overhead.
- Negative acknowledgment (NACK): Explicit rejection returns message to queue.

**Producer-Side Backpressure**

- Queue depth limits: Reject or block producers when queue full.
- Rate limiting: Token bucket or leaky bucket limiting ingress rate.
- Quotas: Per-producer or per-tenant throughput limits.
- Dynamic throttling: Adaptive rate adjustment based on consumer lag.

**Credit-Based Flow Control** Consumer advertises available capacity (credits) to broker. Broker sends messages up to credit limit. Prevents consumer overload while maximizing throughput.

### Routing and Filtering

**Content-Based Routing** Messages routed to queues based on message properties or payload content. Requires broker to parse and evaluate routing predicates. Higher computational overhead than key-based routing.

**Header-Based Routing** Routing decisions based on message headers without payload inspection. More efficient than content-based. Supports declarative routing rules.

**Topic-to-Queue Binding** Single topic fans out to multiple queues via bindings. Each binding specifies routing key pattern or filter expression. Enables hybrid pub/sub and queueing.

### Scalability Dimensions

**Horizontal Scaling**

- Partition count: Increasing partitions enables parallel consumption. Rebalancing required when adding partitions.
- Consumer instances: Adding consumers improves throughput up to partition count.
- Broker instances: Distributing partitions across brokers for load distribution.

**Vertical Scaling**

- Broker resources: CPU, memory, network bandwidth per broker.
- Disk I/O: NVMe SSDs reducing persistence latency.
- Network interface: 10GbE, 25GbE, 100GbE reducing network bottlenecks.

**Bottlenecks**

- Single partition throughput: Limited by single-threaded consumption.
- Hot partitions: Skewed key distribution causing uneven load.
- Broker leadership: Single broker handling all writes for partition.
- Consumer processing: Slow consumers causing backlog growth.

### Failure Modes and Recovery

**Broker Failures**

- Leader failover: Controller elects new partition leader from in-sync replicas (ISR).
- Replica lag: Follower replicas lag behind leader, reducing durability.
- Split-brain: Network partition causing multiple leaders. Requires epoch/generation numbers for fencing.

**Consumer Failures**

- Crash during processing: Message redelivered after visibility timeout.
- Zombie consumers: Consumer loses lock but continues processing. Requires fencing tokens or message versioning.
- Consumer group rebalance: Partition reassignment causing processing pauses.

**Message Loss Scenarios**

- Asynchronous replication: Leader failure before replication completes.
- Ack-before-process: Consumer acknowledges before processing, then crashes.
- Disk corruption: Silent data corruption without checksums or replication.

**Recovery Strategies**

- ISR-based leader election: Only in-sync replicas eligible as leader.
- Unclean leader election: Allow out-of-sync replica as leader when no ISR available. Risks message loss but improves availability.
- Consumer checkpointing: Periodic commit of processed offsets for exactly-once semantics.

---

