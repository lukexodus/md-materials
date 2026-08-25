## Redis Cluster


### Cluster Architecture and Hash Slots

#### Fundamental Architecture

Redis Cluster implements a distributed architecture where data is automatically partitioned across multiple Redis nodes without requiring external proxy servers or configuration files. The cluster operates as a mesh of interconnected nodes, each capable of handling both client requests and cluster management operations.

Each cluster node maintains two TCP connections: one for serving client requests on the standard Redis port, and another for inter-node communication on a port offset by 10000. This bus port handles failure detection, configuration updates, and failover authorization through a binary protocol optimized for bandwidth and processing speed.

The cluster architecture supports horizontal scaling by distributing data across multiple master nodes, with each master potentially having one or more replica nodes for high availability. Clients can connect to any node in the cluster, and requests are automatically redirected to the appropriate node containing the requested data.

#### Hash Slots Mechanism

Redis Cluster divides the entire key space into 16384 hash slots, providing a consistent and predictable method for data distribution. Each key is assigned to a specific slot using the CRC16 hash function applied to the key name, with the result modulo 16384 determining the slot assignment.

The hash slot system enables efficient data location and redistribution. When a client requests a key, the receiving node calculates the slot and either serves the request directly or redirects the client to the correct node. This eliminates the need for a centralized directory service while maintaining fast lookup times.

**Hash tags** provide control over key distribution by allowing multiple keys to be assigned to the same slot. Keys containing curly braces use only the content within the braces for hash calculation, enabling related keys to be stored on the same node for atomic operations.

#### Node Roles and Responsibilities

**Master nodes** handle both read and write operations for their assigned hash slots. Each master is responsible for a contiguous range of slots and maintains the authoritative copy of data within those slots.

**Replica nodes** maintain copies of master node data and can serve read requests when configured appropriately. Replicas automatically failover to become masters when their corresponding master fails, ensuring continuous availability.

**Cluster management** responsibilities are distributed among all nodes, with each node maintaining cluster state information and participating in failure detection and recovery processes.

### Cluster Setup and Configuration

#### Initial Cluster Configuration

Cluster setup requires minimum three master nodes to establish a functional cluster with proper failure detection capabilities. Each node must have cluster mode enabled in redis.conf with cluster-enabled set to yes and cluster-config-file specified for persistent cluster state storage.

Configure cluster-node-timeout to define the maximum time a node can be unreachable before being considered failed. This setting directly impacts failover sensitivity and should be tuned based on network conditions and application requirements.

Set cluster-require-full-coverage to control cluster behavior when some hash slots are unavailable. Disabling this setting allows the cluster to serve requests for available slots even when some nodes are down.

#### Node Joining Process

Adding nodes to an existing cluster involves introducing the new node to any existing cluster member using the CLUSTER MEET command. The new node learns the complete cluster topology through gossip protocol communication with existing nodes.

**Slot assignment** for new master nodes requires explicit allocation using CLUSTER ADDSLOTS or through the cluster management tools. Slots must be migrated from existing nodes to achieve balanced distribution.

**Replica assignment** connects new replica nodes to existing masters using CLUSTER REPLICATE. Replicas automatically synchronize with their masters and begin participating in cluster operations.

#### Configuration Parameters

**cluster-migration-barrier** defines the minimum number of replicas a master must retain before allowing replica migration to orphaned masters. This prevents cascading failures during complex failure scenarios.

**cluster-slave-validity-factor** controls how long replicas remain eligible for failover after losing connection to their master. Higher values provide more tolerance for network partitions but may delay necessary failovers.

**cluster-announce-ip** and **cluster-announce-port** settings are crucial for deployments behind NAT or in containerized environments where nodes need to advertise different addresses than their binding addresses.

### Data Distribution and Resharding

#### Automatic Data Distribution

Redis Cluster automatically distributes data based on hash slot assignments, ensuring even distribution across available master nodes. The system calculates key locations deterministically, enabling any node to determine the correct target node for any given key.

**Consistent hashing** through the slot system provides stability during cluster topology changes. Only keys in affected slots need redistribution during node additions or removals, minimizing data movement overhead.

**Load balancing** occurs naturally through the hash function's uniform distribution properties. Applications can influence distribution through strategic key naming or hash tags when specific co-location requirements exist.

#### Manual Resharding Process

Resharding involves moving hash slots between nodes to rebalance data distribution or accommodate cluster topology changes. The process requires careful coordination to maintain data consistency and availability throughout the operation.

**Slot migration** begins by setting the source node to MIGRATING state for specific slots and the destination node to IMPORTING state. This creates a transition period where both nodes coordinate to handle requests during the migration.

**Key migration** occurs incrementally using MIGRATE commands to transfer individual keys from source to destination nodes. The process maintains atomicity by ensuring keys are never duplicated or lost during transfer.

**Slot reassignment** completes when all keys have been migrated, allowing the cluster to update slot assignments and remove the transitional states. All cluster nodes must acknowledge the new slot assignments for the migration to complete successfully.

#### Resharding Tools and Strategies

**redis-cli --cluster reshard** provides automated resharding capabilities with options for specifying source nodes, destination nodes, and the number of slots to move. The tool handles the complex coordination required for safe slot migration.

**Progressive resharding** minimizes impact on cluster performance by moving slots in small batches with pauses between operations. This approach reduces the risk of overwhelming nodes during large-scale redistributions.

**Balanced resharding** strategies consider both slot count and actual data volume when redistributing slots. Tools can analyze memory usage and key counts to achieve more equitable distribution than simple slot counting.

### Handling Cluster Failures

#### Failure Detection Mechanisms

Redis Cluster implements distributed failure detection through a gossip protocol where nodes continuously exchange health information about other cluster members. Each node maintains a view of the entire cluster state and participates in failure detection decisions.

**Node failure detection** occurs when a node becomes unreachable for longer than the cluster-node-timeout period. Multiple nodes must agree on the failure before initiating failover procedures, preventing false positives from temporary network issues.

**Partition detection** identifies scenarios where cluster nodes become isolated from each other, potentially creating split-brain situations. The cluster implements majority-based decision making to ensure only one partition can continue accepting writes.

#### Automatic Failover Process

**Failover initiation** begins when replica nodes detect their master has failed and the failure has been confirmed by a majority of known master nodes. Eligible replicas compete for promotion based on their data freshness and replica priority settings.

**Master election** follows a voting process where replica nodes request votes from other master nodes. The replica with the most recent data and highest priority typically wins the election and becomes the new master.

**Cluster state propagation** ensures all nodes learn about the new master assignment and update their slot mappings accordingly. This process includes updating client redirection tables and internal routing information.

#### Manual Failover Operations

**Planned failover** allows administrators to promote replicas to masters without waiting for failure detection. This capability is valuable for maintenance operations and planned topology changes.

**CLUSTER FAILOVER** command options include FORCE for immediate failover without waiting for master acknowledgment, and TAKEOVER for aggressive failover that bypasses normal safety checks.

**Failover verification** should confirm that the new master has assumed responsibility for all expected slots and that cluster state has converged across all nodes.

#### Recovery and Troubleshooting

**Node recovery** procedures handle scenarios where failed nodes return to service, including data synchronization and slot reassignment validation. Recovered nodes must reconcile their state with the current cluster configuration.

**Split-brain resolution** addresses situations where network partitions create multiple active clusters. Recovery requires careful analysis of data consistency and may involve manual intervention to resolve conflicting updates.

**Cluster repair** tools like redis-cli --cluster check and --cluster fix help identify and resolve common cluster issues including unassigned slots, configuration inconsistencies, and orphaned nodes.

#### Monitoring and Alerting

**Cluster health monitoring** should track node availability, slot coverage, and replication lag to identify potential issues before they impact applications. Key metrics include the number of nodes in fail state and slots without master assignment.

**Performance monitoring** during failures helps understand the impact on application response times and throughput. Monitor redirect rates and cross-slot operation failures to assess cluster health during degraded conditions.

**Alerting strategies** should differentiate between routine maintenance events and critical failures requiring immediate attention. Configure alerts for scenarios like multiple node failures, extended partitions, or slot coverage gaps.

**Key points:** Redis Cluster provides automatic data distribution through hash slots, enabling horizontal scaling across multiple nodes. The architecture supports both automatic and manual failure handling with distributed coordination. Proper configuration and monitoring are essential for maintaining cluster stability and performance.

**Example:** A high-traffic e-commerce platform might deploy a 6-node cluster with 3 masters and 3 replicas, using hash tags to ensure shopping cart data stays on the same node while distributing product catalog across all nodes, with automated monitoring alerting on node failures and resharding during peak traffic periods.

**Conclusion:** Redis Cluster offers robust distributed computing capabilities with automatic failover and data distribution. Success requires understanding the hash slot system, proper configuration of failure detection parameters, and comprehensive monitoring to ensure high availability and performance during both normal operations and failure scenarios.

---

