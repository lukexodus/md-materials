## Distributed File System Concepts


### Namespace Management

**Global Namespace vs. Federated Namespace**

Global namespace presents unified hierarchical view across storage nodes. Single root directory, coherent path resolution, centralized metadata service. Federated namespace partitions namespace across administrative domains with mount points or junction resolution protocols.

**Metadata Service Architecture**

Centralized metadata servers maintain directory structures, file attributes, access control lists, block mappings. High-availability deployments use primary-backup replication with lease-based failover. Scalability constraints arise from metadata operation serialization and hotspot concentration on popular directories.

Distributed metadata architectures partition namespace by subtree or hash-based distribution. Subtree partitioning assigns directory hierarchies to metadata servers, enabling locality but creating load imbalance. Consistent hashing distributes metadata uniformly but fragments related operations across servers.

**Pathname Resolution**

Multi-hop resolution traverses directory hierarchy across metadata servers. Caching intermediate path components at clients reduces metadata server load. Symbolic links introduce indirection requiring additional metadata lookups. Hard links create multiple namespace entries referencing identical inodes, complicating distributed reference counting and garbage collection.

### Block Storage and Data Placement

**Block vs. Object Storage Interface**

Block-level interface exposes fixed-size blocks with byte-addressable random access. Requires client-side filesystem implementation for namespace and metadata management. Object interface provides key-value semantics with metadata attached to objects, eliminating client filesystem complexity but restricting access patterns.

**Striping Strategies**

Horizontal striping distributes file blocks across storage nodes in round-robin or pseudo-random patterns. Stripe width determines parallelism degree. Narrow stripes increase metadata overhead and coordination cost. Wide stripes reduce small-file parallelism and create load imbalance.

Block-level striping splits individual files across nodes. File-level striping assigns entire files to nodes based on hash or directory affinity. Hybrid approaches stripe large files while placing small files entirely on single nodes.

**Replication Topology**

Primary-backup replication designates authoritative copy receiving all writes. Synchronous replication waits for acknowledgment from replicas before confirming write, ensuring durability at latency cost. Asynchronous replication returns immediately, risking data loss during primary failure.

Chain replication serializes writes through replica sequence. Head receives writes, propagates to successor, tail acknowledges client. Read scaling from tail, write linearizability, simplified recovery protocol. Single-chain throughput bottleneck.

Quorum-based replication requires W replicas acknowledge writes, R replicas for reads, with W + R > N ensuring read-after-write consistency. Tunable consistency-availability trade-off. Sloppy quorums permit temporary replica substitution during failures, sacrificing consistency for availability.

**Erasure Coding**

Reed-Solomon encoding generates k data chunks plus m parity chunks, tolerating m failures with storage overhead (k+m)/k. Lower storage cost than replication at computational expense and reconstruction latency. Unsuitable for frequently updated data due to parity recalculation cost.

Locally Reconstructable Codes reduce reconstruction network traffic by enabling local parity repair. Lower repair bandwidth at increased storage overhead.

### Consistency Models

**Sequential Consistency**

Operations from single client appear in program order. Global operation order consistent across all clients. Requires coordination on every operation, limiting scalability and introducing latency.

**Causal Consistency**

Preserves causally-related operation order. Concurrent operations may appear differently across clients. Vector clocks or version vectors track causality. Reduced coordination compared to sequential consistency but increased metadata overhead.

**Eventual Consistency**

Replicas converge to identical state given sufficient time without updates. No ordering guarantees. Conflict resolution required for concurrent updates. Optimistic replication suitable for high-availability scenarios tolerating temporary divergence.

Last-write-wins uses timestamps for conflict resolution, vulnerable to clock skew. Version vectors enable multi-value returns, pushing resolution to application. CRDTs provide provably convergent data structures with commutative merge operations.

**Session Guarantees**

Read-your-writes ensures client observes own updates. Monotonic reads prevent observing older versions after newer. Monotonic writes preserve client's write ordering at replicas. Writes-follow-reads ensures write operations reflect previously read data.

Implementation via session tokens tracking client operation context, directing subsequent operations to sufficiently updated replicas.

### Cache Coherence

**Client-Side Caching**

Clients cache file data and metadata locally for read performance. Write-through cache propagates updates immediately to servers. Write-back cache batches updates, improving write performance at consistency cost.

**Cache Invalidation Protocols**

Server-driven invalidation sends invalidation messages to clients holding cached data. Callback mechanisms register client interest, servers notify on modifications. Lease-based invalidation grants time-bounded cache validity, eliminating explicit invalidation for expired leases. Reduces server state but requires careful lease duration tuning.

**Write Sharing Detection**

False sharing occurs when multiple clients access non-overlapping file regions within same cache granularity. Block-level caching creates false sharing for concurrent appends. Byte-range locking or optimistic concurrency control reduces false sharing overhead.

### Locking and Concurrency Control

**Distributed Lock Management**

Centralized lock server maintains lock state, serializes conflicting operations. Single point of failure and scalability bottleneck. High-availability via primary-backup replication with lock state persistence.

Distributed lock management partitions lock space across servers. Lock location determined by hash or directory assignment. Lock migration follows data access patterns, reducing remote lock acquisition latency.

**Lock Modes**

Shared locks permit concurrent readers. Exclusive locks serialize writers. Intent locks indicate subtree locking intention, preventing conflicts at higher hierarchy levels without locking entire path.

**Lock Granularity**

File-level locks simplify management but limit concurrency. Byte-range locks enable fine-grained concurrency for large files. Lock escalation aggregates fine-grained locks into coarse-grained locks when threshold exceeded, reducing lock management overhead.

**Lease-Based Locking**

Time-bounded lock grants eliminate explicit release requirement. Lease renewal required for continued access. Lease expiration automatically releases locks during client failure, improving availability. Requires synchronized clocks or conservative timeout estimation.

### Failure Handling

**Failure Detection**

Heartbeat protocols detect node failures via periodic liveness messages. Timeout configuration balances false positive rate against detection latency. Adaptive timeouts adjust based on network conditions, reducing spurious failure declarations.

Phi-accrual failure detectors compute continuous suspicion level rather than binary alive/dead determination. Applications configure suspicion threshold based on availability-consistency trade-off preference.

**Replica Synchronization**

Primary failure requires replica promotion. State transfer from surviving replicas to new primary. Operation log replay reconstructs recent state. Checkpoint-based recovery combines periodic snapshots with incremental logs, reducing recovery time.

Anti-entropy protocols periodically synchronize replicas, correcting divergence. Merkle trees enable efficient difference detection, exchanging tree hashes to identify divergent subtrees. Read repair detects inconsistencies during reads, triggering background reconciliation.

**Split-Brain Prevention**

Network partitions create multiple components unable to communicate. Majority quorum prevents split-brain by permitting only partition containing majority to operate. Minority partition blocks writes, preserving consistency. Requires odd replica count or external arbitration.

Fencing tokens provide monotonically increasing operation identifiers. Stale primaries attempting post-recovery operations carry obsolete tokens, enabling storage nodes to reject out-of-date requests.

### Data Migration and Rebalancing

**Load-Based Migration**

Hotspot detection identifies overloaded nodes based on throughput, latency, or queue depth metrics. Data migration moves frequently accessed files or blocks to underutilized nodes. Cold data movement to archival storage tiers reduces cost.

Migration coordination requires atomic metadata updates and data transfer. Two-phase protocol freezes source, transfers data, updates metadata, activates destination. Read redirection during migration maintains availability.

**Consistent Hashing for Rebalancing**

Virtual nodes distribute data across physical nodes. Node addition/removal affects only adjacent virtual nodes in hash ring, minimizing data movement. Replication factor determines number of clockwise successors storing replicas.

Heterogeneous node capacity accommodated via weighted virtual node distribution. More capable nodes receive proportionally more virtual nodes.

### Security and Access Control

**Authentication Mechanisms**

Kerberos provides ticket-based authentication with centralized key distribution. Client obtains ticket-granting ticket from authentication server, exchanges for service tickets. Time-bounded tickets limit exposure window. Clock synchronization required across distributed components.

Capability-based access control embeds authorization in unforgeable tokens. Token possession grants access rights. Revocation requires token expiration or centralized validation.

**Authorization Models**

Access Control Lists specify permitted principals per file. Centralized policy management but high metadata storage cost and evaluation overhead. Inheritance propagates permissions through directory hierarchy.

Attribute-Based Access Control evaluates policies against principal attributes and resource properties. Flexible policy expression but complex policy evaluation and potential performance impact.

**Encryption**

Data-at-rest encryption protects against storage media compromise. Per-file keys encrypted with master keys, enabling key rotation without data re-encryption. Hardware security modules protect master keys.

Data-in-transit encryption via TLS prevents network eavesdropping. Certificate management complexity in large-scale deployments. Mutual authentication ensures both client and server identity verification.

### Metadata Scalability Techniques

**Metadata Caching**

Clients cache metadata reducing server load. Attribute caching stores file metadata (size, timestamps, permissions). Directory entry caching stores name-to-inode mappings. Metadata lease grants time-bounded validity, servers send early invalidation for modifications.

**Metadata Partitioning**

Subtree partitioning assigns directory subtrees to metadata servers. Maintains locality for hierarchical operations but vulnerable to hotspots. Dynamic subtree migration balances load.

Hash-based partitioning distributes inodes uniformly across servers. Eliminates hotspots but fragments hierarchical operations requiring multiple server round-trips.

**Metadata Logging**

Append-only metadata logs batch modifications, reducing synchronous disk writes. Periodic checkpointing compacts logs. Log-structured merge trees optimize write throughput for metadata updates. Compaction background processes merge incremental updates into base metadata structures.

### Network Protocols and Communication Patterns

**RPC vs. RDMA**

Remote Procedure Call abstracts network communication as function invocation. Marshaling overhead and context switching latency. TCP-based reliability with flow control.

Remote Direct Memory Access bypasses CPU for network transfers. User-space networking eliminates kernel context switches. Requires RDMA-capable NICs. Lower latency and CPU utilization for large transfers. Connection state management complexity.

**Batching and Pipelining**

Request batching amortizes network round-trip cost across multiple operations. Increases latency for individual operations but improves throughput. Adaptive batching tunes batch size based on queue depth and latency targets.

Pipelining issues multiple requests without waiting for responses. Overlap computation and communication. Out-of-order completion requires correlation identifiers. Flow control prevents receiver overwhelm.

### Observability and Monitoring

**Distributed Tracing**

Request identifiers propagate through system, correlating operations across components. Spans represent individual operation segments with timing and metadata. Parent-child span relationships reconstruct request execution path.

Sampling reduces tracing overhead. Head-based sampling decides at request initiation. Tail-based sampling selects based on observed characteristics (errors, high latency).

**Performance Metrics**

Throughput measured as operations/second at storage nodes and aggregate system level. Per-client fairness metrics detect resource hogging.

Latency percentiles (p50, p95, p99) characterize tail latency. Mean latency misleading due to long-tail distributions. Latency breakdown by operation stage (client, network, server, storage) identifies bottlenecks.

Utilization metrics track CPU, memory, network bandwidth, disk I/O. Saturation indicators (queue depths, thread pool occupancy) predict imminent overload.

**Failure Mode Analysis**

Partial failure scenarios isolate failure impact. Graceful degradation strategies maintain reduced functionality during failures. Cascading failure detection identifies component interdependencies causing avalanche effects.

Mean Time Between Failures (MTBF) and Mean Time To Recovery (MTTR) quantify system reliability. Failure injection testing validates fault tolerance mechanisms.

### Related Topics

- Google File System (GFS) architecture
- Hadoop Distributed File System (HDFS) architecture
- Ceph distributed storage architecture
- Network File System (NFS) protocol versions
- Server Message Block (SMB) protocol
- Parallel Virtual File System (PVFS)
- Lustre high-performance filesystem
- Object storage systems (S3, Swift)
- Content-Addressable Storage
- Byzantine fault tolerance in distributed storage
- Consensus protocols (Paxos, Raft) for metadata management
- Distributed transaction protocols for multi-file operations

---

