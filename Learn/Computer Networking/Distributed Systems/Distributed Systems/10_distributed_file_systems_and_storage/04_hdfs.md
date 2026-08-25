## HDFS


### Architecture Overview

HDFS implements a master-worker architecture with a single active NameNode (metadata server) and multiple DataNodes (storage servers). The NameNode maintains the file system namespace, directory tree, and file-to-block mappings in memory. DataNodes store actual data blocks and report block inventories to the NameNode via periodic heartbeats (default 3-second intervals) and block reports (default hourly).

**[Inference]** The design prioritizes high-throughput sequential read/write operations over random access, making HDFS unsuitable for low-latency workloads or applications requiring POSIX-level file system semantics.

### Block Storage Model

HDFS partitions files into fixed-size blocks (default 128 MB, configurable up to 256 MB or higher). Each block is replicated across multiple DataNodes (default replication factor: 3). Block size selection involves trade-offs:

- Larger blocks reduce NameNode memory pressure (fewer metadata entries) and minimize seek overhead
- Smaller blocks increase parallelism for MapReduce tasks but increase metadata management costs

Block placement follows rack-awareness policies. Default replica placement strategy:

1. First replica: writer's DataNode (if writer is a DataNode) or random node
2. Second replica: different rack from first replica
3. Third replica: same rack as second replica, different node

This topology balances reliability against cross-rack bandwidth consumption.

### NameNode Metadata Management

The NameNode maintains three primary data structures in memory:

- **Namespace image (FSImage):** Complete file system metadata snapshot
- **Edit log:** Transaction log recording all metadata mutations
- **Block map:** In-memory mapping of blocks to DataNode locations

FSImage is persisted to disk but loaded entirely into RAM at startup. Edit log records are periodically merged into FSImage by the Secondary NameNode (or Standby NameNode in HA configurations) through checkpointing operations.

**Memory requirements:** Approximately 150-200 bytes per file/block metadata entry. A NameNode managing 100 million files with 300 million blocks requires approximately 60-80 GB RAM minimum.

### Data Integrity and Failure Detection

HDFS employs CRC32C checksums (512-byte chunks per 64 KB data) for data integrity verification. Checksums are stored separately and validated during read operations. Corrupt blocks trigger:

1. Client notification of corruption
2. NameNode marking block as corrupt
3. Re-replication from healthy replicas
4. DataNode removal of corrupt block after successful re-replication

DataNode failures are detected via heartbeat timeouts (default: 10 minutes without heartbeat marks DataNode as dead). The NameNode initiates under-replicated block re-replication with configurable priority levels based on replication factor deficit.

### Write Pipeline and Consistency Model

**Write path:**

1. Client requests block allocation from NameNode
2. NameNode returns pipeline of DataNodes for block replicas
3. Client establishes write pipeline to first DataNode
4. First DataNode forwards data to second, second to third (chain replication topology)
5. Acknowledgments flow backward through pipeline
6. Client commits block to NameNode after all replicas acknowledge

HDFS provides **strong consistency** for single-writer semantics. The write-once-read-many model enforces:

- No concurrent writers to the same file
- Append operations supported but with restricted semantics
- Readers see committed data only after explicit `hsync()` or `hflush()` calls

**[Inference]** Uncommitted data written by a client may not be visible to readers until the file is closed or explicitly synced, introducing visibility lag in streaming scenarios.

### High Availability Architecture

HA deployments use active-passive NameNode pairs with shared edit log storage (typically on a quorum-based journal cluster using Quorum Journal Manager - QJM). ZooKeeper-based ZKFC (ZooKeeper Failover Controller) processes monitor NameNode health and coordinate failover.

**Failover mechanism:**

1. ZKFC detects active NameNode failure
2. Standby NameNode reads latest edit log entries
3. Standby transitions to active after acquiring exclusive lock in ZooKeeper
4. Clients retry connections to new active NameNode

**[Unverified]** Failover completion time varies based on edit log replay duration, typically ranging from seconds to minutes depending on uncommitted transaction volume.

DataNodes send block reports and heartbeats to both NameNodes. The standby maintains block location mappings in memory but does not issue replication or deletion commands.

### Federation

HDFS Federation allows multiple independent NameNodes to share the DataNode pool. Each NameNode manages a separate namespace volume. Benefits:

- Horizontal scaling of namespace capacity
- Isolation of namespace failures
- Independent scaling of metadata management resources

ViewFS or mount table implementations provide unified namespace presentation across federated NameNodes.

### Read Path and Short-Circuit Reads

**Standard read path:**

1. Client requests block locations from NameNode
2. NameNode returns sorted list of DataNodes (proximity-based, typically network topology distance)
3. Client reads directly from DataNode (NameNode not involved in data transfer)
4. Client checksums verification during read

**Short-circuit reads:** When client and DataNode are co-located, data is read directly from local file system bypassing TCP stack, using UNIX domain sockets or shared memory mechanisms. This reduces CPU and latency for data-local reads.

### Erasure Coding

HDFS 3.x introduced erasure coding (EC) as an alternative to replication for cold data. Reed-Solomon codes (e.g., RS-6-3: 6 data blocks, 3 parity blocks) provide storage efficiency improvements over 3x replication (1.5x overhead vs 3x).

**Trade-offs:**

- Storage efficiency: 50% overhead vs 200% for replication
- Write amplification: Requires reading data blocks for parity computation
- Reconstruction overhead: EC block recovery requires reading multiple blocks
- Network bandwidth: Higher cross-rack bandwidth consumption during reconstruction

EC is recommended for cold/warm data with infrequent modifications. Hot data typically remains replicated.

### NameNode Startup and Safe Mode

NameNode startup sequence:

1. Load FSImage from disk into memory
2. Replay edit log transactions
3. Enter Safe Mode
4. Await block reports from DataNodes (default: 99.9% of blocks must be minimally replicated)
5. Exit Safe Mode after threshold met and extension period elapsed (default: 30 seconds)

During Safe Mode, HDFS is read-only. Clients cannot write or delete data. Safe Mode prevents premature under-replication detection when DataNodes have not yet reported.

### Scalability Constraints

**NameNode limitations:**

- Single JVM memory constraints (heap size limitations, GC pause impacts)
- Metadata operations serialized through single edit log
- Block report processing creates periodic load spikes
- File count and block count directly constrain scalability

**[Inference]** Typical production deployments scale to approximately 200-400 million files and 500 million to 1 billion blocks per NameNode before encountering operational challenges.

### Network Topology and Rack Awareness

HDFS models network topology as a tree with configurable depth (default: 2 levels - datacenter/rack). Topology script maps IP addresses to network locations. Distance calculation:

- Same node: distance 0
- Same rack: distance 2
- Different racks: distance 4
- Different datacenters: distance 6

Rack awareness influences block placement, replica selection for reads, and task scheduling in MapReduce.

### Lease Management and Failure Recovery

Clients acquire exclusive write leases (default: 60-second soft limit, 600-second hard limit) for files being written. Soft limit is renewed via heartbeats. Hard limit expiration triggers lease recovery:

1. NameNode closes file and commits completed blocks
2. Partial last block may be truncated to last acknowledged position
3. New client can reopen file for append

**[Inference]** Lease recovery can cause data loss for uncommitted portions of the last block if the original writer crashes without proper cleanup.

### Snapshot and Backup Capabilities

HDFS snapshots are read-only point-in-time copies of the file system directory tree. Implementation uses copy-on-write semantics:

- Metadata-only operation (instant snapshot creation)
- Modified blocks are copied before overwrite (blocks referenced by snapshots are not deleted)
- Snapshots can be taken on any directory

DistCp (Distributed Copy) is used for cross-cluster replication and backup. It launches MapReduce jobs to parallelize file copying across clusters.

### Storage Policies and Heterogeneous Storage

HDFS supports multiple storage types (DISK, SSD, ARCHIVE, RAM_DISK) within the same cluster. Storage policies define placement preferences:

- Hot: Store all replicas on DISK
- Warm: One replica on DISK, others on ARCHIVE
- Cold: All replicas on ARCHIVE
- All_SSD: All replicas on SSD
- One_SSD: One replica on SSD, others on DISK

Storage policy satisfaction is best-effort. DataNode heterogeneity enables tiered storage architectures.

### DataNode Architecture

Each DataNode manages multiple storage volumes (typically one per physical disk). Block storage uses native file system (ext4, XFS). DataNode operations:

- Block scanner: Background verification of checksums for all blocks
- Volume failure tolerance: Continues operation if subset of volumes fail (configurable threshold)
- Block balancing: Participates in cluster-wide balancing operations

Block files and metadata files are stored in structured directory hierarchies to avoid single-directory scaling limitations.

### Security Model

HDFS security mechanisms:

- Kerberos authentication for RPC layer
- Delegation tokens for MapReduce task authentication (avoiding per-task Kerberos operations)
- Block access tokens for DataNode authorization (time-limited capabilities issued by NameNode)
- HDFS permissions model (POSIX-like user/group/other with read/write/execute bits)
- Transparent encryption at-rest using encryption zones (per-directory key management)

**[Inference]** Security overhead introduces latency penalties, particularly for Kerberos ticket acquisition and token validation operations.

### Performance Characteristics

**Throughput:**

- Sequential write: Typically limited by network bandwidth to single DataNode divided by replication factor
- Sequential read: Aggregates across multiple DataNodes, scales with parallelism
- Small file problem: Metadata overhead dominates, throughput degrades significantly for files smaller than block size

**Latency:**

- First block read latency: NameNode RPC + DataNode connection establishment (~10-100ms)
- Block-local read latency: Dominated by disk seek + transfer time
- Write latency: Minimum 1.5x RTT to farthest replica in pipeline

### Operational Failure Modes

**NameNode failure scenarios:**

- Heap exhaustion from excessive metadata operations or memory leaks
- Edit log disk failures preventing transaction commits
- Corrupted FSImage preventing startup
- Split-brain scenarios in HA configurations (fencing mechanisms required)

**DataNode failure scenarios:**

- Disk failures causing volume decommissioning
- Network partitions causing false-positive death detection
- Slow DataNodes creating write pipeline stragglers
- Storage exhaustion preventing new block allocations

### Related Architectural Patterns and Systems

- GFS (Google File System)
- Ceph distributed file system
- Amazon S3 object storage model
- Azure Data Lake Storage
- Colossus (GFS successor)
- Quantcast File System (QFS)
- Lustre parallel file system
- GlusterFS
- Alluxio (Tachyon) distributed cache layer
- Ozone (HDFS object store alternative)

---

