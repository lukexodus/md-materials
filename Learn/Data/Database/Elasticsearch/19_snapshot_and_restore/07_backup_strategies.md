## Backup Strategies

### Overview and Goals

A backup strategy for Elasticsearch is the overall plan governing what gets backed up, how often, where it's stored, how long it's retained, and how recovery is tested — as distinct from the mechanics of any single snapshot operation. Good strategy design balances recovery point objective (RPO — how much data loss is acceptable) and recovery time objective (RTO — how quickly the cluster must be operational again) against storage cost and operational complexity.

### Core Backup Mechanism: Snapshots

Elasticsearch's native backup mechanism is the snapshot and restore API, backed by a registered repository (filesystem, S3, Azure Blob Storage, GCS, or HDFS). Snapshots are:

**Key Points**
- Taken at the shard level, capturing Lucene segment files
- Incremental by default — only new or changed segments since the last snapshot in the same repository are copied, reducing storage growth and transfer time
- Consistent as of the point the snapshot process begins, without blocking ongoing indexing (in-flight documents are handled via Lucene's own commit/flush semantics)
- Restorable to the same or a different cluster, provided version compatibility rules are respected

### Manual Snapshot Example

```
PUT _snapshot/backup_repo/manual-snapshot-2026-08-24
{
  "indices": "logs-*,orders-*",
  "ignore_unavailable": true,
  "include_global_state": true
}
```

Restoring:

```
POST _snapshot/backup_repo/manual-snapshot-2026-08-24/_restore
{
  "indices": "orders-*",
  "rename_pattern": "orders-(.+)",
  "rename_replacement": "restored-orders-$1"
}
```

The `rename_pattern`/`rename_replacement` pair allows restoring into new index names, useful for verifying a snapshot's integrity without overwriting live indices.

### Automating Backups with SLM

Manually running snapshot commands does not scale as an operational practice. Snapshot Lifecycle Management (SLM) is the standard way to automate scheduling and retention, and most production backup strategies are built around one or more SLM policies rather than ad hoc snapshot calls. (See the dedicated SLM material for full policy syntax and retention semantics.)

### Choosing What to Back Up

**Key Points**
- **Full cluster snapshots** (`indices: "*"`, `include_global_state: true`) — simplest to reason about, captures everything including cluster settings, templates, and ILM/SLM policies themselves.
- **Selective index patterns** — useful when some indices are reproducible from a source of truth (e.g., data re-indexed from an external database) and don't need the same backup cadence as irreplaceable data.
- **Separating hot data from cold/frozen tiers** — data already offloaded to searchable snapshots in a cold or frozen tier is, in effect, already durably stored in the repository; backup strategy for those tiers focuses more on repository durability than on additional snapshotting.

### The 3-2-1 Principle Applied to Elasticsearch

A commonly cited general backup principle — three copies of data, on two different media types, with one copy off-site — maps onto Elasticsearch as follows:

**Key Points**
- The live cluster itself is one copy.
- A snapshot repository (ideally cloud object storage) constitutes a second, independent copy.
- Cross-region replication of that repository, or a second repository in a different region/provider, satisfies the off-site requirement.

[Inference] This mapping is a general adaptation of a widely used backup heuristic rather than an Elasticsearch-specific guarantee or feature; actual resilience depends on how the repository itself is configured for redundancy (e.g., S3 cross-region replication settings), which is outside Elasticsearch's own control.

### Repository Redundancy Considerations

**Key Points**
- A snapshot repository is only as durable as its underlying storage backend's own redundancy guarantees (e.g., an object store's replication across availability zones or regions).
- Relying on a single repository with no redundancy plan means a storage-provider-level outage or data loss event could compromise all snapshots simultaneously.
- Some organizations register two repositories (e.g., primary + secondary in different regions or providers) and run parallel SLM policies to each, trading storage cost for backup redundancy.

### Testing Restores

**Key Points**
- A backup strategy that has never been restored is unverified in practice — periodic restore drills into a scratch/test cluster are the only reliable way to confirm snapshots are actually usable.
- Testing should include restoring both data indices and, separately, the global state (templates, ILM policies), since a common oversight is only validating data recovery.
- Version compatibility matters: a snapshot taken on one Elasticsearch version may have restrictions on which versions it can be restored into. [Unverified] The exact cross-version restore compatibility window has varied across Elasticsearch's release history, so the target cluster's documentation should be checked for the specific source and destination versions in use.

### Disaster Recovery Scenarios

**Key Points**
- **Full cluster loss** — requires restoring a full snapshot (including global state) onto a newly provisioned cluster.
- **Accidental index deletion** — a targeted restore of just the affected index/indices from the most recent snapshot preceding the deletion.
- **Data corruption from a bad ingest pipeline or bulk update** — often requires restoring to a point-in-time snapshot taken before the problematic write, which is why retention windows need to be long enough to cover realistic detection lag (the time between a bad write occurring and someone noticing it).

### Backup Strategy Decision Flow

```plaintext
===MERMAID_DIAGRAM===
flowchart TD
    A[Define RPO and RTO requirements] --> B[Select repository type and location]
    B --> C[Design SLM policy schedule and retention]
    C --> D{Full cluster or selective indices?}
    D -- Full --> E[include_global_state: true, indices: '*']
    D -- Selective --> F[Scope indices, separate policies per data class]
    E --> G[Consider repository redundancy]
    F --> G
    G --> H[Schedule periodic restore drills]
    H --> I{Restore succeeds within RTO?}
    I -- Yes --> J[Strategy validated]
    I -- No --> K[Revise schedule, repository, or retention]
    K --> C
```

### Illustration: Layered Backup Architecture

<svg viewBox="0 0 760 340" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
  <text x="380" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Layered Backup Architecture (svg_diagram)</text>

  <rect x="280" y="55" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5"/>
  <text x="380" y="90" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Live Cluster</text>

  <line x1="380" y1="115" x2="380" y2="150" stroke="#555" stroke-width="1.5" marker-end="url(#b1)"/>
  <text x="400" y="138" font-size="10" fill="#777">SLM policy</text>

  <rect x="150" y="150" width="200" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5"/>
  <text x="250" y="185" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Primary Repository</text>

  <rect x="410" y="150" width="200" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5"/>
  <text x="510" y="185" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Secondary Repository</text>

  <line x1="380" y1="115" x2="250" y2="145" stroke="#555" stroke-width="1.5" marker-end="url(#b1)"/>
  <line x1="380" y1="115" x2="510" y2="145" stroke="#555" stroke-width="1.5" marker-end="url(#b1)"/>

  <rect x="150" y="245" width="200" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5"/>
  <text x="250" y="272" text-anchor="middle" font-size="12" fill="#1a1a1a">Region A / Provider A</text>
  <text x="250" y="290" text-anchor="middle" font-size="11" fill="#555">off-site copy</text>

  <rect x="410" y="245" width="200" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5"/>
  <text x="510" y="272" text-anchor="middle" font-size="12" fill="#1a1a1a">Region B / Provider B</text>
  <text x="510" y="290" text-anchor="middle" font-size="11" fill="#555">redundant copy</text>

  <line x1="250" y1="210" x2="250" y2="240" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3"/>
  <line x1="510" y1="210" x2="510" y2="240" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3"/>

  <defs>
    <marker id="b1" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#555"/></marker>
  </defs>
</svg>

### Cost and Retention Trade-offs

**Key Points**
- Longer retention windows and more frequent snapshots increase storage cost, though incremental snapshotting mitigates this compared to full copies each time.
- Cold/frozen tier data already living in searchable snapshots reduces the marginal cost of "backing it up again," since the repository copy already serves as both the queryable and durable form of that data.
- Aligning snapshot frequency with actual business RPO avoids over-provisioning: a system that can tolerate 24 hours of data loss doesn't need hourly snapshots.

### Common Mistakes

**Key Points**
- Treating a single repository as sufficient redundancy without considering the storage backend's own failure modes.
- Never testing a restore, so a broken policy (wrong indices, expired credentials, insufficient retention) goes unnoticed until an actual disaster.
- Forgetting `include_global_state` when the goal is a true full-cluster disaster recovery snapshot, resulting in a restore that has data but is missing templates, ILM/SLM policies, and other cluster-level configuration.
- Confusing snapshots with cross-cluster replication (CCR): CCR provides near-real-time replication for read availability and failover, but is not a substitute for point-in-time backup and typically doesn't protect against logical corruption that gets replicated to the follower cluster.

**Related Topics**
- Snapshot Lifecycle Management (SLM) policy configuration and retention rules
- Snapshot and Restore APIs in depth
- Cross-cluster replication (CCR) vs. backup
- Searchable snapshots and cold/frozen tier storage
- Repository plugins (S3, Azure, GCS, HDFS) and their configuration specifics
- Disaster recovery runbooks and restore drill procedures