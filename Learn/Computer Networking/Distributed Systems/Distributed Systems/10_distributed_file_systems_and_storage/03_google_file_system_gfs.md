## Google File System (GFS)


### Architecture Overview

GFS operates as a distributed file system optimized for large sequential reads/writes and append operations on multi-TB datasets across commodity hardware clusters. The architecture separates metadata management from data transfer through a single master coordinating multiple chunkservers that store actual file data as fixed-size chunks.

**Core Components:**

- **Master**: Single centralized metadata server maintaining namespace, access control, chunk-to-chunkserver mappings, chunk lease management, garbage collection, and chunk migration decisions
- **Chunkservers**: Distributed storage nodes hosting 64MB chunks on local disk, serving read/write requests directly to clients after master-mediated handshake
- **Clients**: Application-level library implementing filesystem API, caching metadata, interacting with master for control operations and chunkservers for data operations

### Chunk Management

Files decompose into fixed 64MB chunks identified by immutable 64-bit globally unique chunk handles assigned at creation. Each chunk replicates across configurable number of chunkservers (default 3, higher for critical data). Large chunk size reduces metadata volume at master, enables efficient sequential operations, and amortizes network overhead.

**Chunk Replica Placement:**

- Spread across racks for fault isolation against correlated failures
- Balance disk utilization across chunkservers
- Limit write traffic per chunkserver to prevent hotspots
- Master rebalances replicas based on disk space, load distribution, and rack-level failure domains

### Consistency Model

GFS provides relaxed consistency guarantees trading strong consistency for availability and performance under the working assumption that applications can tolerate stale or duplicate data through application-level reconciliation.

**Consistency Guarantees:**

- **Defined**: All clients see same data regardless of replica read location
- **Consistent**: All clients see same data but not necessarily latest mutation result
- **Inconsistent**: Different clients may see different data

**Record Append Semantics:**

Atomic at-least-once append operation guarantees atomicity at record boundaries but permits padding and duplicates. GFS guarantees append writes to at least one replica atomically at offset chosen by GFS. Applications must handle duplicate detection through embedded checksums or unique identifiers within records.

**Mutation Ordering:**

Master grants chunk leases to primary replica establishing mutation order. Primary assigns consecutive serial numbers to all mutations, applies locally in serial order, forwards order to secondaries. All replicas apply mutations in identical serial order ensuring consistent ordering across replicas.

### Write Pipeline and Lease Mechanism

**Lease-Based Write Coordination:**

Master grants 60-second renewable chunk lease to one replica (primary) establishing mutation authority. Primary orders all mutations during lease period. Lease mechanism decouples control flow (master) from data flow (client to chunkservers) enabling master to remain off critical data path.

**Write Flow:**

1. Client requests chunk locations and current lease holder from master
2. Master responds with primary and secondary replica locations
3. Client pushes data to all replicas in arbitrary order, each chunkserver caches data in LRU buffer
4. After all replicas acknowledge data receipt, client sends write request to primary
5. Primary assigns consecutive serial number, applies mutation locally
6. Primary forwards write request with serial number to secondaries
7. Secondaries apply mutation in serial number order, acknowledge to primary
8. Primary responds to client indicating success or failure

Data flows linearly along chunkserver chain to maximize network bandwidth utilization through pipelined forwarding. Each chunkserver forwards data to nearest unvisited chunkserver in network topology while simultaneously receiving data from predecessor.

### Master Operations and Metadata Management

Master maintains three types of metadata in memory:

- **Namespace**: File and directory hierarchy with per-directory locks for concurrent mutations
- **File-to-chunk mappings**: Persistent mapping stored in operation log
- **Chunk replica locations**: Reconstructed at startup and maintained through chunkserver heartbeats (not persisted)

**Operation Log:**

Historical record of critical metadata changes serving as logical timeline for concurrent operations and persistent state recovery. Master batches log entries before flushing to disk and replicates to remote backup masters before responding to clients. Checkpoints at regular intervals enable fast recovery through replaying log from last checkpoint.

**Shadow Masters:**

Read-only replicas lag slightly behind primary master, serving read requests to reduce master load. Shadow masters apply operation log entries with slight delay (typically subsecond) providing near-current filesystem view for applications tolerating bounded staleness.

### Garbage Collection

**Lazy Deletion:**

File deletion renames file to hidden name including deletion timestamp. Master regular scan removes hidden files exceeding configurable retention (default 3 days). Chunk metadata deleted only after file metadata removal. Orphaned chunks (no longer reachable from any file) identified during regular master-chunkserver heartbeat exchanges and reclaimed.

Lazy approach provides undelete window, batches storage reclamation, and merges reclamation with regular master-chunkserver communication reducing overhead.

### Failure Recovery and High Availability

**Master Failure:**

External monitoring restarts master process within seconds. Master recovers state from operation log and checkpoint, polls chunkservers for replica locations. New master may temporarily serve stale data during chunk location reconstruction window until all chunkservers report. Backup masters maintain near-current replicas of operation log enabling rapid failover with minimal data loss (seconds of operations).

**Chunkserver Failure:**

Master detects failure through missed heartbeats (typically 10 heartbeats at 1Hz intervals). Master re-replicates affected chunks to maintain replication factor. Priority re-replication for chunks with replication count below threshold, recently accessed chunks, and chunks blocking client progress.

**Data Integrity:**

Each 64KB block within chunk has 32-bit checksum stored persistently. Chunkservers verify checksums on every read before returning data. Checksum mismatches trigger re-replication from alternate replica and corrupt replica deletion. Checksumming occurs during idle periods minimizing read latency impact.

### Scalability Characteristics

**Master Scalability Limits:**

Single master bottlenecks at metadata operation throughput (~thousands of operations per second depending on operation mix). Large chunk size (64MB) reduces metadata volume per TB stored. Clients cache metadata reducing master query rate. Read-only operations serve from shadow masters.

**Namespace Scaling:**

Prefix compression in namespace representation enables tens of millions of files. Per-directory locks permit concurrent namespace mutations. Namespace stored entirely in master memory limiting scale to master RAM capacity.

**Chunkserver Scaling:**

Horizontal scaling through adding chunkservers. Linear capacity scaling limited only by master's ability to track chunk metadata and coordinate replica placement. Master typically manages thousands of chunkservers storing petabytes.

### Network Partition Handling

Single master architecture with lease-based write coordination prevents split-brain scenarios during network partitions. Chunkservers unable to reach master cannot renew leases, preventing write acceptance during partition. Master availability determines write availability trading consistency for availability under CAP constraints.

**Partition Tolerance Limitations:**

Master unreachability prevents all writes even if chunkservers mutually reachable. Reads continue from cached metadata and direct chunkserver contact. Applications must implement retry logic and timeout handling for master unavailability scenarios.

### Performance Optimization Techniques

**Data Flow Separation:**

Control messages (small) flow through master. Data flow (large) directly between clients and chunkservers. Separation prevents master bandwidth saturation and enables full bisection bandwidth utilization between clients and chunkservers.

**Pipelined Data Transfer:**

TCP connection chain between chunkservers enables full-duplex pipelined forwarding. Each chunkserver immediately forwards received data to next chunkserver while receiving from previous, achieving near-theoretical network throughput.

**Batching and Coalescing:**

Master batches responses to multiple client requests. Operation log entries batch before disk flush. Chunk creation and deletion batch during regular master-chunkserver heartbeats.

**Replica Placement Awareness:**

Clients preferentially read from closest replica (typically same rack) minimizing cross-rack bandwidth consumption. Master tracks network topology for optimal replica placement and client routing.

### Operational Failure Modes

**Master Memory Exhaustion:**

Namespace or chunk metadata exceeding master memory halts file creation. Mitigation through increasing chunk size, namespace compaction, or master memory expansion.

**Hotspot Chunks:**

Highly concurrent reads to single chunk (e.g., popular file) saturate chunk replica bandwidth. Replication factor increase or application-level caching mitigates. Inherent architecture limitation for small-file random access patterns.

**Lease Timeout Ambiguity:**

Network partition preventing lease renewal from primary to master creates window where both master and primary believe lease validity status differs. Lease timeout conservatively prevents write acceptance under ambiguity.

**Correlated Rack Failures:**

Power loss or top-of-rack switch failure creates multiple simultaneous chunkserver failures. Under-replicated chunks during recovery window risk data loss if additional failures occur. Higher replication factor for critical data mitigates but increases storage overhead.

**Master Failover Window:**

Master failure creates write unavailability until backup assumes control (typically 10-30 seconds). Read availability continues but may serve stale metadata. Applications requiring higher write availability must implement external coordination.

### Related Patterns and Systems

- Hadoop Distributed File System (HDFS)
- Colossus (GFS successor)
- Ceph File System
- Primary-Backup Replication
- Lease-Based Coordination
- Chain Replication
- Centralized Metadata Management

---

