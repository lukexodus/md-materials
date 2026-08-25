## NFS (Network File System)


### Architecture Overview

NFS implements a stateless (NFSv2/v3) or stateful (NFSv4+) client-server architecture for remote file access over IP networks. The protocol exposes POSIX-like file system semantics through RPC-based operations, presenting remote file systems as locally mounted directories while maintaining server-side storage authority.

**Core architectural components:**

- **NFS Server**: Exposes file system namespaces through export policies, manages file handles, enforces access control, executes I/O operations against underlying storage (local file systems, block devices, distributed storage backends)
- **NFS Client**: Mounts remote exports into local namespace, translates VFS operations to NFS RPC calls, implements caching layers (page cache, attribute cache, directory cache), manages file handle mapping
- **RPC Layer**: Sun RPC (ONC RPC) provides transport abstraction, typically over TCP (NFSv4+) or UDP (legacy NFSv2/v3), handles XDR serialization, manages connection state
- **File Handle System**: Server-generated opaque identifiers uniquely reference file system objects, remain valid across client crashes (stateless model) or encode generation numbers (stateful model)
- **Lock Manager**: Separate NLM service (NFSv2/v3) or integrated protocol operations (NFSv4+) coordinate distributed file locking

### State Management Models

**NFSv2/v3 Stateless Design:**

Server retains no per-client state between operations. Each RPC contains complete context (file handle, offset, credentials). Client crash recovery requires no server-side cleanup. Write operations include `UNSTABLE`, `DATA_SYNC`, `FILE_SYNC` commit modes trading latency for durability guarantees. Idempotency requirements complicate operations like non-idempotent writes, necessitating client-side duplicate request caches.

**NFSv4+ Stateful Design:**

Server maintains per-client state including open file contexts, lock ownership, delegation grants, session bindings (NFSv4.1+). Introduces lease-based state reclamation: clients must renew leases via periodic operations or lose state. Grace period after server restart allows clients to reclaim locks and opens before new requests accepted. State management overhead exchanged for improved semantic fidelity (true OPEN/CLOSE operations, byte-range locking integrated into protocol).

### Consistency Model

NFS implements **close-to-open consistency** as baseline semantic guarantee:

- Changes flushed to server on file close
- Subsequent opens by any client observe previous writes
- Concurrent access without intervening close/open provides no ordering guarantees
- Attribute caching (ac timeo parameters) introduces bounded staleness windows

[Inference] Most production deployments accept attribute cache staleness of 3-60 seconds as typical configuration trade-off between consistency and performance.

**Cache coherency mechanisms:**

- **Attribute Revalidation**: Clients validate cached attributes via GETATTR operations, comparing change attributes (ctime, mtime, file size). Cache invalidated on mismatch.
- **Data Cache Coherency**: NFSv4 delegations grant clients temporary authority over files with callback-based revocation when conflicting access occurs. Read delegations allow aggressive client-side caching; write delegations permit client-side write buffering without synchronous server interaction.
- **Directory Coherency**: Directory entry caching relies on attribute timeout mechanisms. Directory delegations (NFSv4.1+) improve scalability for read-heavy directory workloads.

**Consistency limitations:**

- No distributed lock ordering across clients without explicit locking
- Metadata operations (create, rename, unlink) not atomic across network failures
- Page cache on different clients may observe different file content within cache validity windows
- O_DIRECT bypasses client cache but still subject to server buffer cache behavior

### Failure Modes and Recovery

**Network Partition Handling:**

Stateless NFSv3: Clients retry indefinitely (hard mount) or return EIO after timeout (soft mount—**not recommended for data integrity**). Partial writes may succeed server-side while client observes failure, requiring application-level idempotency.

Stateful NFSv4: Lease expiration during partition causes server to revoke client state. Client must detect partition, wait out lease period, then reclaim state during grace period or receive STALE state errors.

**Server Failure Recovery:**

- **NFSv3**: Stateless design allows immediate retry after server restart. Lock manager state (NLM) lost; applications holding locks may proceed without mutual exclusion.
- **NFSv4**: Clients must reclaim state during server grace period (typically 90 seconds). RECLAIM operations re-establish opens and locks. State not reclaimed within grace period permanently lost.

**Split-Brain Scenarios:**

NFS provides no distributed consensus. Multiple servers exporting same underlying storage concurrently causes divergent state. Requires external coordination:

- Shared storage clustering with fencing/STONITH mechanisms
- Distributed lock managers (DLM) coordinating server failover
- Pacemaker/Corosync or similar HA frameworks ensuring single active server

**Byzantine Failures:**

Protocol assumes cooperative failure model. Silent data corruption, byzantine server behavior, or compromised servers not detectable through protocol mechanisms. Requires defense-in-depth: filesystem checksums (ZFS, Btrfs), end-to-end checksums in applications, cryptographic integrity verification.

### Performance Characteristics

**Latency Profile:**

Synchronous operations (fsync, O_SYNC writes, metadata operations) experience full network RTT + server I/O latency. Typical LAN RTT ~0.1-1ms; datacenter network ~0.05-0.5ms. Metadata-heavy workloads (compilation, git operations) severely impacted by synchronous RPC latency amplification.

**Throughput Scaling:**

Single-client bandwidth limited by:

- Network capacity (1GbE: ~900 Mbps; 10GbE: ~9 Gbps; 40/100GbE possible)
- Server CPU capacity for RPC processing
- Server storage backend throughput
- Read-ahead/write-behind effectiveness (client-side rsize/wsize tuning)

Aggregate throughput scales linearly with independent clients accessing non-overlapping files until server resource saturation (CPU, storage IOPS, network bandwidth).

**Caching Effectiveness:**

Attribute cache hit rates >90% typical for stable directory hierarchies. Data cache effectiveness highly workload-dependent:

- Read-mostly workloads: Excellent (near-local filesystem performance)
- Write-heavy: Poor (synchronous write commitment dominates)
- Mixed concurrent access: Moderate (cache invalidation traffic increases)

### Scalability Constraints

**Vertical Scaling Limits:**

Single NFS server typically saturates at:

- 100K-500K IOPS (metadata-heavy, server CPU bound)
- 10-50 GB/s aggregate bandwidth (network/storage backend limited)
- 1000-10000 concurrent clients (connection state, lock manager overhead)

**Horizontal Scaling Approaches:**

**Namespace Partitioning**: Multiple independent servers export non-overlapping directory trees. Clients mount multiple exports. Requires application-aware data placement or manual partitioning.

**Referrals (NFSv4)**: Servers redirect clients to alternate servers for specific namespace subtrees. Enables dynamic load distribution and transparent namespace aggregation. Limited adoption due to client support requirements.

**pNFS (Parallel NFS, NFSv4.1+)**: Separates metadata operations (to metadata server) from data operations (direct client-to-storage communication). Layout types include:

- **File Layout**: Clients access storage via NFS protocol to data servers
- **Block Layout**: Clients perform block I/O directly to storage arrays
- **Object Layout**: Clients use object storage protocols (OSD)
- **Flex Files Layout**: Enhanced file layout with mirroring and load balancing

[Inference] pNFS production adoption concentrated in specialized HPC and large-scale storage vendor solutions due to complexity of layout management and storage backend requirements.

**Distributed File System Integration**: NFS serves as frontend protocol for distributed storage backends (GlusterFS, Ceph, GPFS, Lustre). Backend handles replication, consistency, and scale-out; NFS provides POSIX compatibility layer.

### Replication and Consistency

NFS protocol itself provides no replication. Replication strategies implemented at different layers:

**Storage-Layer Replication:**

- **Block Replication**: DRBD, storage array synchronous/asynchronous replication beneath NFS server
- **Filesystem Replication**: ZFS replication, Btrfs send/receive
- **Distributed Storage**: Backend like Ceph or GlusterFS manages replica placement

**Application-Layer Replication:**

Applications replicate data across multiple NFS servers using application-specific logic. NFS serves as storage abstraction only.

**Consistency Guarantees:**

No cross-server consistency coordination. Each NFS server operates independently. Applications requiring strong consistency across replicas must implement coordination externally (distributed locks, consensus protocols, primary-backup election).

### Security Architecture

**Authentication:**

- **AUTH_SYS (AUTH_UNIX)**: Client-asserted UID/GID transmitted in clear. Trivially spoofable; requires trusted network environment.
- **RPCSEC_GSS**: Kerberos-based mutual authentication. Provides cryptographic identity verification. Requires Kerberos infrastructure (KDC, keytab distribution, ticket management).

**Authorization:**

Server-side enforcement based on UNIX permission model (user/group/other, ACLs). NFSv4 supports richer ACL model (NFSv4 ACLs) similar to Windows ACLs with explicit allow/deny entries.

**Export Security:**

- **Host-Based**: Restrict exports to specific IP addresses/networks (insecure with IP spoofing)
- **Kerberos Required**: Enforce RPCSEC_GSS for export access
- **Root Squashing**: Map root UID to anonymous/nobody, preventing privileged client operations

**Transport Security:**

- **NFSv3**: No encryption. RPCSEC_GSS provides integrity/privacy but rarely deployed due to performance overhead.
- **NFSv4.x**: RPCSEC_GSS privacy mode encrypts RPC payloads. Performance overhead 20-50% typical [Unverified: specific overhead depends on cipher choice, hardware acceleration, workload characteristics].

**Security Limitations:**

- Client kernel compromise grants full user impersonation capability
- No server-side cryptographic verification of data integrity by default
- Network eavesdropping possible without encryption
- Denial-of-service via resource exhaustion (open file handles, lock state)

### Operational Characteristics

**Mount Options:**

Critical tuning parameters affecting reliability and performance:

- `hard` vs `soft`: Hard mount retries indefinitely; soft mount returns I/O errors after timeout. Soft mounts risk data corruption and should be avoided for writable filesystems.
- `intr`: Allow signal interruption of hung NFS operations (deprecated in favor of timeout mechanisms)
- `timeo`/`retrans`: RPC timeout and retry configuration
- `rsize`/`wsize`: Read/write transfer size (typically 1MB with modern kernels)
- `ac`/`noac`: Enable/disable attribute caching
- `actimeo`: Unified attribute cache timeout
- `lookupcache`: Directory lookup cache behavior (all, none, pos, positive)
- `local_lock`: Use client-side locking only (for single-client scenarios)

**Monitoring and Observability:**

Key metrics for distributed tracing and performance analysis:

- **Client-Side**: `/proc/self/mountstats` exposes per-mount RPC statistics (operations/sec, RTT histograms, retransmits, timeouts), VFS operation counts
- **Server-Side**: `nfsstat` command reports operation counts, `/proc/net/rpc/nfsd` thread statistics
- **Network**: Packet capture analysis for RPC call/reply patterns, retransmission rates

**Failure Detection:**

Client detects server unavailability through RPC timeout. No active health checking. Timeout-based detection introduces unavailability windows measured in seconds to minutes depending on `timeo` configuration.

**Capacity Planning:**

Server dimensioning considerations:

- CPU: 0.5-2 cores per 10K IOPS (metadata operations)
- Memory: 1-2 GB per 1000 clients for connection state
- Network: Aggregate client bandwidth + 20-30% overhead for RPC framing
- Storage IOPS: Match or exceed aggregate client demand accounting for write amplification

### Data Flow Architecture

**Read Path:**

1. Client VFS layer receives read() syscall
2. Page cache lookup: cache hit returns immediately
3. Cache miss triggers NFS READ RPC with file handle, offset, length
4. Server validates file handle, checks permissions
5. Server performs I/O against underlying storage
6. Response transmitted to client with data payload
7. Client populates page cache, returns data to application
8. Attribute cache updated with response metadata

**Write Path:**

1. Client VFS layer receives write() syscall
2. Data written to client page cache (write-back caching)
3. Async writeback (pdflush/writeback) or explicit sync triggers NFS WRITE RPC
4. Server receives write operation with data payload
5. Server performs I/O; behavior depends on stable storage requirement:
    - UNSTABLE: Write to volatile cache, return immediately
    - FILE_SYNC: Write to stable storage before reply
6. Client tracks uncommitted writes
7. Explicit fsync() or close() triggers COMMIT operation verifying stable storage
8. Server responds with verifier; mismatch requires retransmit of uncommitted writes

**Metadata Operations:**

Synchronous RPC for each operation (LOOKUP, GETATTR, SETATTR, CREATE, REMOVE, RENAME). No metadata caching beyond attribute cache. Serialized execution at server. High metadata operation rates require low-latency networks and fast server storage for directory and inode operations.

### Partitioning and Sharding Strategies

NFS natively provides no automatic sharding. Partitioning strategies implemented externally:

**Manual Namespace Partitioning:**

Administrator divides namespace across multiple servers by subdirectory. Applications or users explicitly mount appropriate exports. Requires application awareness or user training.

**Automounter Integration:**

Automount (autofs) dynamically mounts NFS exports on access based on configuration maps. Enables transparent distribution of namespace across servers with client-side mount point unification.

**NFSv4 Referrals:**

Server exports contain referral entries pointing to other servers. Client transparently follows referrals on access. Enables hierarchical namespace distribution and dynamic rebalancing through referral updates.

**DNS-Based Distribution:**

Round-robin DNS or SRV records distribute clients across multiple servers. Provides coarse-grained load distribution but no namespace unification; each server exports independent namespace.

### Trade-Offs and Design Constraints

**CAP Theorem Positioning:**

[Inference] NFS prioritizes availability and partition tolerance over strong consistency. During network partition, clients continue operations with cached state (availability) but may diverge from server state (weak consistency). Close-to-open consistency represents eventual consistency guarantee with bounded staleness windows.

**PACELC Analysis:**

[Inference]

- **PA/EL**: Under partition (P), NFS chooses availability (A) allowing continued operation with stale cache. In normal operation (E), chooses lower latency (L) through aggressive caching over strict consistency (C).
- Trade-off explicitly tunable via cache timeout parameters and delegation policies.

**Latency vs Consistency:**

Aggressive client caching (high attribute cache timeouts, write-back caching, delegations) reduces latency but increases staleness windows. Synchronous operations and short cache timeouts improve consistency at latency cost.

**Scalability vs Consistency:**

Stateless NFSv3 design scales better (no per-client state, simpler failover) but provides weaker semantics (no true open/close, external lock manager). Stateful NFSv4 improves consistency (integrated locking, delegations) but complicates state management and failover.

**Complexity vs Feature Richness:**

NFSv4.1+ features (pNFS, referrals, advanced ACLs, sessions) enable sophisticated deployments but significantly increase implementation complexity, operational overhead, and troubleshooting difficulty compared to simpler NFSv3.

### Related Architectural Patterns and Systems

- SMB/CIFS (Server Message Block)
- AFS (Andrew File System)
- Lustre
- GPFS (General Parallel File System)
- Ceph Filesystem
- GlusterFS
- Distributed lock managers (DLM)
- Primary-backup replication
- Cache coherence protocols
- Lease-based coordination

---

