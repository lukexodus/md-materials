## Publish-Subscribe Patterns


Publish-subscribe (pub/sub) decouples publishers and subscribers through topics. Publishers emit messages to topics without knowledge of subscribers. Subscribers register interest in topics and receive matching messages. Enables one-to-many and many-to-many communication patterns.

### Topic Models

**Hierarchical Topics** Topics organized in tree structure (e.g., `sensors/temperature/room1`). Wildcards enable subscribing to subtrees (`sensors/+/room1`, `sensors/#`). Simplifies topic management but requires parsing overhead.

**Flat Topics** Non-hierarchical namespace. Exact topic name matching. Simpler implementation but requires explicit subscription to each topic.

**Dynamic Topics** Topics created implicitly on first publish. Simplifies producer logic but complicates capacity planning and access control.

**Partitioned Topics** Logical topic split into partitions for parallelism. Messages routed by partition key. Ordering preserved per partition. Commonly used in log-based systems (Kafka, Pulsar).

### Subscription Types

**Exclusive Subscription** Single consumer receives all messages from topic. Simple model for single-consumer use cases. No load distribution.

**Shared Subscription** Multiple consumers share topic messages with load distribution. Competing consumers pattern. No ordering guarantees across consumers.

**Failover Subscription** Primary consumer receives messages, secondary consumers standby. Failover on primary failure. Preserves ordering during normal operation.

**Key-Shared Subscription** Messages with same key delivered to same consumer. Ordering per key, parallelism across keys. Requires consistent hashing for consumer assignment.

### Delivery Semantics

**Push Model** Broker pushes messages to subscribers. Lower latency, broker controls flow. Risk of overwhelming slow subscribers requires backpressure mechanisms.

**Pull Model** Subscribers poll broker for messages. Subscriber controls consumption rate. Higher latency due to polling overhead. Long-polling reduces latency.

**Streaming Model** Bidirectional persistent connection with flow control. Combines low latency of push with backpressure of pull. Used in gRPC, AMQP.

### Message Retention and Replay

**Retention Policies**

- Time-based: Messages retained for configured duration (hours, days).
- Size-based: Messages retained until total size limit reached, oldest evicted first.
- Compaction: Only latest message per key retained, older versions removed.
- Infinite retention: All messages retained indefinitely. Requires external archival to tiered storage.

**Consumer Offsets** Position in message stream tracked per consumer. Offset types:

- Earliest: Begin from oldest available message.
- Latest: Begin from newest message.
- Timestamp: Begin from specific point in time.
- Stored offset: Resume from last committed position.

**Replay Capabilities**

- Full replay: Reprocess all retained messages.
- Partial replay: Reprocess from specific offset or timestamp.
- Time-travel queries: Access historical message state.

### Filtering and Routing

**Topic-Based Filtering** Subscribers specify topic names or patterns. Broker routes messages based on topic match. No payload inspection required.

**Content-Based Filtering** Subscribers specify predicates evaluated against message content. Broker evaluates expressions (SQL-like, JSONPath). Higher computational cost.

**Hybrid Filtering** Coarse filtering by topic, fine-grained filtering by consumer. Reduces broker load while maintaining flexibility.

### Fan-Out Patterns

**Broker-Side Fan-Out** Broker replicates message to all subscribers. Single message storage, multiple deliveries. Efficient storage utilization.

**Client-Side Fan-Out** Each subscriber independently reads message. Requires separate offset tracking per subscriber. Used in log-based systems.

**Tiered Fan-Out** Hierarchical distribution using subscriber groups. Reduces broker load for large subscriber counts. Increases latency.

### Ordering Guarantees

**Global Ordering** Total order across all messages in topic. Requires single partition, limits parallelism. Strongest guarantee, lowest scalability.

**Partition Ordering** Order within partition, no cross-partition ordering. Enables horizontal scaling. Messages with same key maintain order.

**Causal Ordering** Causally related messages ordered, concurrent messages unordered. Requires vector clocks or Lamport timestamps.

**No Ordering** Messages delivered in arbitrary order. Maximizes throughput and parallelism. Application must handle reordering.

### Durability and Persistence

**Durable Subscriptions** Subscription state persisted, messages retained for offline subscribers. Ensures message delivery to subscribers after reconnection.

**Non-Durable Subscriptions** Ephemeral subscription, messages lost during disconnection. Lower overhead, suitable for real-time streams where historical data irrelevant.

**Message Persistence**

- Persistent messages: Written to disk before acknowledgment.
- Transient messages: In-memory only, lower latency, no durability.
- Hybrid: Async flush with configurable durability-latency trade-off.

### Scalability and Partitioning

**Partition Assignment**

- Static assignment: Consumers pre-assigned to partitions.
- Dynamic assignment: Rebalancing protocol assigns partitions (Kafka consumer group protocol).
- Sticky assignment: Minimize partition movement during rebalancing.

**Partition Count Considerations**

- Too few: Insufficient parallelism, consumer bottleneck.
- Too many: Increased metadata overhead, rebalancing cost.
- Rule of thumb: Partitions = target throughput / single partition throughput.

**Rebalancing Protocols**

- Stop-the-world: All consumers stop during rebalancing. Simple but causes processing gaps.
- Incremental: Partitions reassigned gradually. Minimizes disruption but more complex.
- Cooperative: Consumers continue processing unaffected partitions during rebalancing.

### Multi-Tenancy

**Tenant Isolation**

- Separate topics per tenant: Strong isolation, simple access control, high metadata overhead.
- Shared topics with tenant prefixes: Lower metadata, requires filtering.
- Virtual clusters: Logical isolation within shared infrastructure.

**Quotas and Rate Limiting**

- Producer quotas: Limit ingress rate per tenant.
- Consumer quotas: Limit egress rate per tenant.
- Storage quotas: Limit retained message volume per tenant.
- Connection limits: Prevent resource exhaustion.

**Resource Allocation**

- Dedicated partitions: Partitions reserved per tenant, guaranteed resources.
- Shared partitions: Elastic resource sharing, noisy neighbor risks.
- Priority-based scheduling: Higher-tier tenants receive preferential treatment.

### Security

**Authentication**

- SASL/PLAIN: Username/password authentication.
- SASL/SCRAM: Challenge-response, password not transmitted.
- OAuth 2.0: Token-based authentication with external identity provider.
- Mutual TLS (mTLS): Certificate-based authentication.

**Authorization**

- Topic-level ACLs: Publish/subscribe permissions per topic.
- Consumer group ACLs: Control which consumers join groups.
- IP allowlists: Network-level access control.
- Attribute-based policies: Context-aware authorization (time, location).

**Encryption**

- Transport encryption: TLS for broker-client communication.
- End-to-end encryption: Publishers encrypt, subscribers decrypt, broker sees ciphertext.
- Encryption at rest: Stored messages encrypted on disk.

### Observability

**Metrics**

- Publish rate: Messages per second per topic.
- Consumer lag: Difference between produced and consumed offsets.
- End-to-end latency: Time from publish to consumption.
- Throughput: Bytes per second per partition.
- Error rates: Failed publishes, consumer exceptions.

**Distributed Tracing**

- Trace context propagation: Parent span ID in message headers.
- Producer span: Capture serialization and publish latency.
- Broker span: Capture storage and replication latency.
- Consumer span: Capture processing latency.

**Monitoring**

- Partition balance: Distribution of partitions across brokers.
- Replica lag: Follower replication lag behind leader.
- Under-replicated partitions: Partitions below target replication factor.
- Consumer group health: Members, rebalances, lag.

### Coordination and Consensus

**Group Coordination**

- Coordinator election: Controller elected via consensus protocol.
- Membership protocol: Heartbeats, session timeouts for failure detection.
- Generation/epoch numbers: Fencing for zombie group members.

**Leader Election**

- Preferred leader: Static leader assignment per partition.
- Automatic failover: Controller triggers leader election on failure.
- Leader balancing: Distribute leadership across brokers.

**Metadata Management**

- Centralized metadata store: ZooKeeper, etcd for cluster metadata.
- Embedded metadata: Metadata stored in dedicated internal topic.
- Cache consistency: Metadata caching with invalidation or refresh.

### Integration Patterns

**Change Data Capture (CDC)** Database changes published to topics. Applications consume change streams for derived views, caching, search indexing. Requires transactional guarantees between database and queue.

**Event Sourcing** All state changes captured as immutable events in topics. State reconstructed by replaying events. Enables time-travel debugging and audit trails.

**CQRS (Command Query Responsibility Segregation)** Commands published to topics, read models subscribe and materialize views. Decouples writes and reads for independent scaling.

**Saga Pattern** Distributed transactions implemented as event-driven workflows. Compensating actions published on failure. Eventual consistency with guaranteed completion or compensation.

### Trade-offs and Limitations

**Throughput vs. Latency**

- Batching: Increases throughput, increases latency.
- Compression: Reduces network bandwidth, increases CPU overhead.
- Acknowledgment strategy: Fewer acks improve throughput, weaken durability.

**Consistency vs. Availability**

- Synchronous replication: Strong consistency, reduced availability under partitions.
- Asynchronous replication: High availability, risk of message loss.
- Quorum-based: Tunable trade-off via W and R parameters.

**Ordering vs. Parallelism**

- Strict ordering: Single partition, limited throughput.
- Partition ordering: Parallelism within partitions, no global order.
- No ordering: Maximum parallelism, application complexity.

**Operational Complexity**

- Partition rebalancing: Causes processing pauses, requires coordination.
- Consumer lag monitoring: Requires alerting and capacity planning.
- Version upgrades: Broker and client compatibility management.
- Data migration: Moving topics between clusters or cloud regions.

### Related Architectures and Patterns

- Event-Driven Architecture
- Event Sourcing
- CQRS (Command Query Responsibility Segregation)
- Saga Pattern
- Stream Processing Architecture
- Lambda Architecture
- Kappa Architecture
- Message Broker Architecture (AMQP, MQTT, STOMP)
- Log-Based Architecture (Kafka, Pulsar)
- Reactive Streams
- Dataflow/Streaming Systems (Flink, Spark Streaming)

---

