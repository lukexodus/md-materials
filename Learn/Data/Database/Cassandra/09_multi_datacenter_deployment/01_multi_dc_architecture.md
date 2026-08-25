## Multi-DC Architecture


### NetworkTopologyStrategy Configuration

#### Replication Factor Planning

NetworkTopologyStrategy enables datacenter-aware replication by specifying replica counts per datacenter. This topology-aware approach ensures data availability even during complete datacenter failures while optimizing network traffic patterns.

**Key points**: Replication factors should account for consistency requirements, query patterns, and disaster recovery objectives across datacenters.

The strategy requires explicit replica counts for each datacenter in the keyspace definition. Odd replica counts within each datacenter help avoid split-brain scenarios during network partitions, while even counts may be appropriate when using `LOCAL_QUORUM` consistency levels.

**Example**: A three-datacenter deployment might use `{'DC1': 3, 'DC2': 3, 'DC3': 2}` to provide strong consistency in primary datacenters while maintaining a backup copy in the third datacenter.

#### Snitch Configuration

The snitch component determines node placement within the network topology hierarchy. `GossipingPropertyFileSnitch` is commonly used for multi-datacenter deployments as it combines rack and datacenter information with dynamic gossip updates.

PropertyFileSnitch requires manual configuration of the `cassandra-topology.properties` file on each node, specifying datacenter and rack assignments. This approach provides precise control but requires careful maintenance during cluster changes.

**Key points**: Snitch consistency across all nodes is critical for proper replica placement and query routing.

#### Keyspace Alteration

Modifying NetworkTopologyStrategy settings requires careful planning to avoid data loss or consistency issues. Increasing replication factors triggers streaming operations to create additional replicas, while decreasing factors may leave orphaned data.

The `ALTER KEYSPACE` statement with NetworkTopologyStrategy changes initiates background streaming to achieve the new replica topology. During this process, consistency levels may behave unpredictably until streaming completes.

### Datacenter-Aware Load Balancing

#### Driver Configuration

Client drivers support datacenter-aware load balancing policies that prefer local datacenter nodes for query execution. The `DCAwareRoundRobinPolicy` routes queries to the local datacenter first, falling back to remote datacenters only when necessary.

**Key points**: Proper driver configuration significantly reduces cross-datacenter traffic and improves application response times.

Token-aware load balancing can be combined with datacenter awareness to route queries directly to nodes owning the requested data within the preferred datacenter. This optimization minimizes coordinator overhead and network hops.

#### Consistency Level Impact

Datacenter-aware consistency levels like `LOCAL_QUORUM` and `LOCAL_ONE` operate within single datacenters, reducing latency and improving availability during cross-datacenter network issues.

`EACH_QUORUM` requires quorum achievement in every datacenter, providing strong consistency across all locations but potentially impacting availability during datacenter failures.

**Example**: An application using `LOCAL_QUORUM` writes and `LOCAL_ONE` reads can continue operating normally even if other datacenters become unreachable, though this may create temporary inconsistencies.

#### Connection Pooling

Driver connection pools should be configured per datacenter to optimize resource utilization and failover behavior. Separate pools enable fine-tuned connection limits and timeout settings based on network characteristics between application and datacenter.

### Cross-Datacenter Replication

#### Streaming Operations

Cross-datacenter streaming occurs during repair operations, bootstrap procedures, and topology changes. These operations consume significant bandwidth and should be scheduled during off-peak hours when possible.

**Key points**: Streaming throttling controls bandwidth usage to prevent network saturation during large data transfers between datacenters.

The `stream_throughput_outbound_megabits_per_sec` and `inter_dc_stream_throughput_outbound_megabits_per_sec` settings limit streaming rates for intra-datacenter and cross-datacenter transfers respectively.

#### Incremental Repair Strategy

Multi-datacenter incremental repairs track repaired data separately from unrepaired data, enabling more efficient consistency maintenance across geographically distributed nodes.

**Example**: Running `nodetool repair -pr` on each node in rotation ensures all data is repaired while minimizing cross-datacenter traffic through primary range restrictions.

#### Compression and Internode Encryption

Cross-datacenter communication benefits significantly from compression due to typically higher latency and lower bandwidth compared to intra-datacenter links. Internode compression reduces network utilization at the cost of CPU overhead.

Encryption adds security for cross-datacenter links but introduces additional latency and CPU costs. The trade-off between security and performance should be evaluated based on network trust boundaries.

### Consistency Across Datacenters

#### Eventual Consistency Model

Multi-datacenter Cassandra deployments operate on an eventual consistency model where updates propagate across datacenters asynchronously. The time to consistency depends on network characteristics and repair frequency.

**Key points**: Applications must be designed to handle temporary inconsistencies between datacenters gracefully.

Read repair and anti-entropy repair operations gradually converge data across datacenters. The repair frequency and scope determine how quickly inconsistencies are resolved.

#### Conflict Resolution

Last-write-wins semantics based on timestamp ordering resolve conflicts when the same data is modified simultaneously in different datacenters. Clock synchronization across datacenters becomes critical for predictable conflict resolution.

**Example**: If two datacenters update the same row simultaneously, the update with the higher timestamp prevails regardless of which datacenter processed the write first.

#### Monitoring Consistency

[Unverified] Consistency monitoring across datacenters typically involves comparing data checksums or running validation queries against multiple datacenters to detect divergence.

Tools like `nodetool repair -vd` provide verbose output showing data differences discovered during repair operations, helping identify consistency issues between datacenter replicas.

### Network Topology Considerations

#### Bandwidth Requirements

Cross-datacenter bandwidth requirements depend on write volume, repair frequency, and streaming operations. Peak bandwidth usage occurs during node bootstrap, major repairs, or datacenter recovery scenarios.

**Key points**: Network capacity planning must account for both steady-state replication traffic and burst requirements during operational events.

Typical deployments require sustained bandwidth of 10-20% of peak write throughput for cross-datacenter replication, with burst capacity of 5-10x for recovery operations.

#### Latency Impact

Network latency between datacenters affects cross-datacenter read operations and global consistency levels. Applications using global consistency must account for round-trip times in their timeout configurations.

**Example**: A global `QUORUM` read spanning datacenters separated by 100ms latency will experience minimum response times of 200ms plus processing overhead.

#### Network Partitioning

Multi-datacenter deployments are more resilient to network partitions as each datacenter can continue operating independently using local replicas. However, partition detection and recovery procedures become more complex.

**Key points**: Datacenter-level partitions require different handling than single-node failures, as entire regions may become unreachable simultaneously.

#### Security Considerations

Cross-datacenter links often traverse untrusted networks requiring encryption and authentication. Certificate management becomes critical for maintaining secure inter-datacenter communication.

[Inference] Network security policies should account for Cassandra's gossip protocol requirements, as firewall rules blocking gossip traffic can cause split-brain scenarios.

#### Quality of Service

Network QoS policies can prioritize Cassandra traffic types differently, such as giving higher priority to client queries over repair traffic. This helps maintain application performance during intensive background operations.

**Conclusion**: Multi-datacenter Cassandra architectures provide excellent availability and disaster recovery capabilities but require careful planning of network topology, replication strategies, and consistency models. Success depends on understanding the trade-offs between consistency, availability, and partition tolerance across geographically distributed deployments.

Important related subtopics include disaster recovery procedures, backup strategies across datacenters, capacity planning for multi-region deployments, and monitoring strategies for distributed clusters.

---

