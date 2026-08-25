Shards and replicas
## Shards and Replicas

---

### Overview

Shards and replicas are the fundamental mechanisms by which Elasticsearch distributes data across a cluster, enables parallel search, and provides fault tolerance. Every index is divided into shards, and every shard can have one or more replica copies. Understanding how shards and replicas work — and how to size them correctly — is one of the most consequential areas of Elasticsearch configuration.

---

### What a Shard Is

A **shard** is a self-contained, fully functional **Lucene index**. It is the atomic unit of data storage and distribution in Elasticsearch.

- Every document in an Elasticsearch index lives in exactly one primary shard
- Every shard is assigned to exactly one node at any given time
- Shards can be relocated between nodes by the master as cluster conditions change
- A shard handles its own indexing, search, and segment management independently

When Elasticsearch receives a search request, it fans the query out to relevant shards across the cluster, collects results, and merges them into a final ranked response. This parallel execution across shards is the primary mechanism behind Elasticsearch's search scalability.

---

### Primary Shards

A **primary shard** is the authoritative copy of a portion of an index's data.

- All write operations (index, update, delete) are directed to the primary shard first
- The primary shard forwards writes to its replica shards after applying them locally
- The number of primary shards is set at **index creation time** and cannot be changed afterward without reindexing

```json
PUT /my-index
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}
```

This creates an index with:
- 3 primary shards
- 1 replica per primary → 3 replica shards
- 6 total shards

#### Default Shard Count

| Elasticsearch Version | Default `number_of_shards` |
|---|---|
| 6.x and earlier | 5 |
| 7.0+ | 1 |

The change from 5 to 1 in 7.0 addressed the widespread problem of over-sharding in clusters where most indices did not need 5 shards.

---

### Replica Shards

A **replica shard** is a copy of a primary shard. Replicas serve two purposes:

1. **Fault tolerance** — if a primary shard's node fails, a replica is promoted to primary
2. **Read throughput** — search requests can be served by both primary and replica shards in parallel

```json
PUT /my-index/_settings
{
  "number_of_replicas": 2
}
```

Unlike `number_of_shards`, `number_of_replicas` **can be changed at any time** on a live index.

#### Replica Placement Rules

The master enforces the following placement constraints:

- A replica shard is **never placed on the same node as its primary**
- Two copies of the same shard (primary + replica, or replica + replica) are never on the same node

This means a single-node cluster cannot have active replicas — replica shards remain unassigned (cluster health `yellow`) until additional nodes are available.

---

### Shard and Replica Placement — Visual Model

**Example:** Index with 3 primary shards, 1 replica each, distributed across 3 nodes.

```
          Node 1          Node 2          Node 3
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ P0       │    │ P1       │    │ P2       │
        │ R1       │    │ R2       │    │ R0       │
        └──────────┘    └──────────┘    └──────────┘

P0 = Primary shard 0     R0 = Replica of shard 0
P1 = Primary shard 1     R1 = Replica of shard 1
P2 = Primary shard 2     R2 = Replica of shard 2
```

Each node holds one primary and one replica (of a different shard). If any single node fails:
- Its primary shards are replaced by the replicas on surviving nodes
- The cluster remains fully operational

---

### Shard Routing — How Documents Are Assigned to Shards

When a document is indexed, Elasticsearch determines which primary shard it belongs to using a **routing formula**:

```
shard = hash(routing_value) % number_of_primary_shards
```

The default routing value is the document's `_id`. This produces a roughly uniform distribution of documents across primary shards.

**Example:**

```json
PUT /my-index/_doc/42
{
  "title": "Introduction to Sharding"
}
```

Elasticsearch hashes `"42"` and takes the modulus of the number of primary shards to determine placement.

#### Why Primary Shard Count Cannot Change

The routing formula depends on `number_of_primary_shards`. If this value changed after documents were indexed, the formula would point to different shards for existing documents — making them unreachable. This is why primary shard count is immutable after index creation. Changing it requires **reindexing** all documents into a new index with the desired shard count.

#### Custom Routing

A custom routing value can override the default `_id`-based routing:

```json
PUT /my-index/_doc/42?routing=user-123
{
  "title": "User-specific document"
}
```

All documents with the same routing value land on the same shard. This can improve query performance for queries scoped to a specific routing value but can cause **shard imbalance** if routing values are not uniformly distributed.

---

### The Write Path — Indexing a Document

When a document is indexed into a multi-shard, multi-replica index:

```
Client
  │
  ▼
Coordinating Node
  │  determines target shard via routing formula
  ▼
Primary Shard (on its node)
  │  writes document locally
  │  applies to in-memory buffer and translog
  ├──► Replica Shard 1 (forwarded in parallel)
  └──► Replica Shard 2 (forwarded in parallel)
         │
         ▼
    All replicas acknowledge
         │
         ▼
Coordinating Node acknowledges to Client
```

#### The Translog

Before writing to the Lucene index, each write is appended to a **transaction log (translog)**. The translog provides durability between Lucene flushes — if a node crashes before a Lucene flush, uncommitted writes can be recovered from the translog on restart.

```json
PUT /my-index/_settings
{
  "index.translog.durability": "request",
  "index.translog.flush_threshold_size": "512mb"
}
```

| `translog.durability` | Behavior | Tradeoff |
|---|---|---|
| `request` (default) | fsync after every operation | Safer; higher write latency |
| `async` | fsync at interval (`sync_interval`) | Higher throughput; small risk of data loss on crash |

---

### The Read Path — Searching Across Shards

Search in Elasticsearch is a **scatter-gather** operation:

```
Client
  │
  ▼
Coordinating Node
  │  fans query out to one copy of each shard
  ├──► Shard 0 (primary or replica)
  ├──► Shard 1 (primary or replica)
  └──► Shard 2 (primary or replica)
         │
         ▼
    Each shard returns local top-N results + scores
         │
         ▼
Coordinating Node merges, re-ranks globally
         │
         ▼
Fetches full _source for global top-N documents
         │
         ▼
Returns final result to Client
```

Replicas directly contribute to read scalability — the coordinating node distributes read requests across all available shard copies (primary and replicas) using a **round-robin** mechanism by default.

[Inference] The exact load balancing strategy across shard copies may vary by version and may be affected by adaptive replica selection settings. Behavior is not guaranteed to be identical across all configurations.

#### Adaptive Replica Selection

Elasticsearch supports **adaptive replica selection** — routing search sub-requests to the shard copy that is likely to respond fastest based on response time statistics.

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.use_adaptive_replica_selection": true
  }
}
```

---

### Shard Sizing

Shard sizing is one of the most operationally significant decisions in Elasticsearch. There is no universally correct shard size, but established guidelines exist.

#### Recommended Shard Size Range

| Guideline | Recommended Range |
|---|---|
| Shard size (general) | 10 GB – 50 GB |
| Shard size (logging/time-series) | 10 GB – 30 GB |
| Maximum shard size (hard limit) | No enforced limit, but >50 GB is generally discouraged |

[Inference] These ranges are widely cited Elastic recommendations. Actual optimal shard size depends on document size, query patterns, hardware, and JVM heap. They are guidelines, not guaranteed performance thresholds.

#### Why Shard Size Matters

**Too small (over-sharding):**
- Each shard has fixed overhead — JVM heap, file handles, segment metadata
- Many small shards increase heap pressure and slow down cluster state management
- Query overhead grows because more shards must be queried and results merged
- Cluster instability can result from excessive shard counts

**Too large (under-sharding):**
- Large shards take longer to recover after node failure
- Fewer shards reduce search parallelism
- Reindexing and shard relocation become slower and more disruptive

#### Heap-to-Shard Ratio

A common operational guideline:

```
Aim for no more than 20 shards per GB of JVM heap
```

**Example:**

```
Node heap: 8 GB
Maximum shards per node: 8 × 20 = 160 shards
```

[Inference] The 20-shards-per-GB guideline is a widely cited operational heuristic, not an enforced limit or guaranteed optimal ratio. Actual shard capacity per GB of heap depends on shard size, query complexity, and indexing throughput. Use as a starting point, not an absolute rule.

As of Elasticsearch 7.x, a hard limit was introduced:

```yaml
# Default maximum shards per node (across all indices)
cluster.max_shards_per_node: 1000
```

This can be adjusted but should not be increased without understanding the underlying resource implications.

---

### Number of Shards — Sizing Guidelines

#### For New Indices

If the final data size of an index is known or estimable:

```
number_of_shards = ceil(expected_index_size_GB / target_shard_size_GB)
```

**Example:**

```
Expected index size: 120 GB
Target shard size: 30 GB
number_of_shards = ceil(120 / 30) = 4
```

For indices whose size is unknown, starting with **1 shard** (the 7.x default) and using the **Split Index API** or **Shrink Index API** later to adjust is a viable approach.

#### For Time-Series Data (Logs, Metrics)

Use **data streams** with **Index Lifecycle Management (ILM)**. ILM rollover creates new indices automatically when a size or age threshold is met, keeping individual backing indices within a target shard size range without manual intervention.

---

### Changing Shard Count After Index Creation

Because `number_of_shards` is immutable, three APIs exist for restructuring shard count post-creation.

#### Split API

Increases the number of primary shards by a factor. The new shard count must be a multiple of the original.

```json
POST /my-index/_split/my-index-split
{
  "settings": {
    "index.number_of_shards": 6
  }
}
```

- Original must be `read_only` before splitting
- Valid only if the target count is a multiple of the source count

#### Shrink API

Reduces the number of primary shards. The new count must be a factor of the original.

```json
POST /my-index/_shrink/my-index-shrunk
{
  "settings": {
    "index.number_of_shards": 1,
    "index.number_of_replicas": 1
  }
}
```

- All primary shards must be on the same node before shrinking
- Index must be `read_only` before shrinking

#### Reindex API

Creates a new index with any desired shard count and copies all documents into it. The most flexible but most resource-intensive option.

```json
POST /_reindex
{
  "source": { "index": "my-index" },
  "dest":   { "index": "my-index-v2" }
}
```

After reindexing, an alias swap makes the transition transparent to clients.

---

### Replica Configuration

#### Setting Replicas at Index Creation

```json
PUT /my-index
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}
```

#### Changing Replicas on a Live Index

```json
PUT /my-index/_settings
{
  "number_of_replicas": 2
}
```

This takes effect immediately. The master begins allocating the new replica shards to available nodes.

#### Setting Replicas to Zero (Bulk Indexing)

During large bulk indexing operations, temporarily setting replicas to zero eliminates the overhead of writing to replica shards:

```json
PUT /my-index/_settings
{
  "number_of_replicas": 0
}
```

After indexing completes, restore replicas:

```json
PUT /my-index/_settings
{
  "number_of_replicas": 1
}
```

> During the period with zero replicas, the index has **no redundancy**. Node failure during this window risks data loss. This tradeoff is acceptable only in controlled bulk-load scenarios.

---

### Replica Promotion — Handling Primary Failure

When a node holding a primary shard becomes unavailable:

1. The master detects the node's absence via fault detection
2. The master selects an eligible replica of that shard on a surviving node
3. The master publishes a cluster state update promoting the replica to primary
4. The promoted shard begins accepting writes immediately
5. If the original node returns, its copy of the shard is demoted to a replica and synced

This process is typically fast (seconds to tens of seconds) for small shards. Recovery time scales with shard size and network throughput for larger shards.

[Inference] Promotion timing depends on fault detection settings, shard size, and cluster load. Behavior is not guaranteed to be uniform across all cluster configurations and versions.

---

### Shard Allocation

The master node controls shard allocation — the assignment of shards to nodes. Allocation decisions are made based on:

- **Node roles** — only nodes with data roles receive shard assignments
- **Disk space** — nodes with insufficient disk space are excluded
- **Allocation filters** — include/exclude rules based on node attributes
- **Balance settings** — Elasticsearch attempts to distribute shards evenly across nodes
- **Awareness settings** — zone or rack awareness rules

#### Allocation Settings

```yaml
# Control which operations trigger reallocation
cluster.routing.allocation.enable: all       # default
# Options: all | primaries | new_primaries | none
```

| Value | Behavior |
|---|---|
| `all` | Allocate all shard types |
| `primaries` | Only allocate primary shards |
| `new_primaries` | Only allocate primaries for newly created indices |
| `none` | Disable all shard allocation |

#### Disk-Based Allocation

Elasticsearch monitors disk usage on each node and applies allocation thresholds:

| Threshold | Default | Behavior When Exceeded |
|---|---|---|
| `low` | 85% | No new shards allocated to this node |
| `high` | 90% | Elasticsearch attempts to relocate shards off this node |
| `flood_stage` | 95% | Index is set to `read_only_allow_delete`; writes blocked |

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.disk.watermark.low": "85%",
    "cluster.routing.allocation.disk.watermark.high": "90%",
    "cluster.routing.allocation.disk.watermark.flood_stage": "95%"
  }
}
```

> When the flood stage is reached and an index is set to `read_only_allow_delete`, the block must be manually removed after freeing disk space:

```json
PUT /my-index/_settings
{
  "index.blocks.read_only_allow_delete": null
}
```

---

### Shard Rebalancing

After node additions or removals, the master rebalances shards to maintain an even distribution.

```yaml
# Control rebalancing behavior
cluster.routing.rebalance.enable: all
# Options: all | primaries | replicas | none
```

Rebalancing can be throttled to limit the impact on cluster performance:

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.node_concurrent_recoveries": 2,
    "cluster.routing.allocation.node_initial_primaries_recoveries": 4,
    "indices.recovery.max_bytes_per_sec": "40mb"
  }
}
```

| Setting | Purpose |
|---|---|
| `node_concurrent_recoveries` | Max concurrent shard recoveries per node |
| `node_initial_primaries_recoveries` | Max concurrent primary recoveries after restart |
| `indices.recovery.max_bytes_per_sec` | Throttle recovery network throughput |

[Inference] Recovery throttle settings involve a tradeoff between recovery speed and impact on ongoing indexing and search performance. Optimal values depend on available network bandwidth and node hardware. Behavior may vary.

---

### Shard Allocation Awareness

**Allocation awareness** distributes shards across failure domains — preventing all copies of a shard from landing in the same rack, availability zone, or data center.

#### Configuration

**Step 1 — Tag nodes with an attribute:**

```yaml
# On nodes in zone A
node.attr.zone: zone-a

# On nodes in zone B
node.attr.zone: zone-b
```

**Step 2 — Enable awareness:**

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes": "zone"
  }
}
```

Elasticsearch will now distribute shard copies across zones. A primary and its replica will not share a zone if nodes in multiple zones are available.

#### Forced Awareness

Forced awareness ensures shards are allocated only if all specified attribute values are present — preventing over-allocation to one zone if another zone is temporarily unavailable:

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes": "zone",
    "cluster.routing.allocation.awareness.force.zone.values": "zone-a,zone-b"
  }
}
```

[Inference] Forced awareness can result in unassigned shards if not enough nodes are present in all required zones. This tradeoff should be evaluated against availability requirements. Behavior depends on cluster topology.

---

### Shard Allocation Filtering

Shards can be included or excluded from specific nodes using **allocation filters** based on node attributes.

```json
PUT /my-index/_settings
{
  "index.routing.allocation.include.zone": "zone-a",
  "index.routing.allocation.exclude.size": "small"
}
```

Cluster-level filters apply to all indices:

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.exclude._name": "node-3"
  }
}
```

This is the standard way to drain a node of its shards before decommissioning.

---

### Monitoring Shards

#### List All Shards

```bash
GET /_cat/shards?v
```

**Example output:**

```
index     shard prirep state   docs  store ip        node
my-index  0     p      STARTED  823  4.2mb 10.0.0.1  node-1
my-index  0     r      STARTED  823  4.2mb 10.0.0.2  node-2
my-index  1     p      STARTED  791  4.0mb 10.0.0.2  node-2
my-index  1     r      STARTED  791  4.0mb 10.0.0.3  node-3
```

| Column | Meaning |
|---|---|
| `prirep` | `p` = primary, `r` = replica |
| `state` | `STARTED`, `INITIALIZING`, `RELOCATING`, `UNASSIGNED` |

#### Unassigned Shards

```bash
GET /_cat/shards?h=index,shard,prirep,state,unassigned.reason&s=state
```

#### Shard Allocation Explain

When a shard is unassigned, this API explains why:

```bash
GET /_cluster/allocation/explain
{
  "index": "my-index",
  "shard": 0,
  "primary": false
}
```

This is the primary diagnostic tool for unassigned shards. It returns a human-readable explanation of allocation decisions and blockers.

---

### Segments and the Lucene Layer

Each shard is composed of one or more **Lucene segments**. A segment is an immutable unit of index data written when a shard is refreshed.

- New documents are written to an **in-memory buffer**
- A **refresh** (default every 1 second) flushes the buffer to a new segment, making documents searchable
- Segments are **immutable** — updates and deletes create new segments or mark documents as deleted, not modify existing ones
- A **merge** process periodically combines smaller segments into larger ones, reclaiming space from deleted documents

```json
PUT /my-index/_settings
{
  "index.refresh_interval": "5s"
}
```

Disabling refresh during bulk indexing:

```json
PUT /my-index/_settings
{
  "index.refresh_interval": "-1"
}
```

Restore after bulk load:

```json
PUT /my-index/_settings
{
  "index.refresh_interval": "1s"
}
```

#### Force Merge

The force merge API reduces the number of segments in a shard. It is most useful on **read-only indices** (e.g., after ILM rollover) to reduce segment overhead:

```bash
POST /my-index/_forcemerge?max_num_segments=1
```

> Force merge is resource-intensive and should not be run on actively written indices. On read-only indices, merging to 1 segment per shard can significantly improve search performance. [Inference] Performance impact of force merge depends on shard size and available I/O. Behavior is not guaranteed across all environments.

---

### Common Shard-Related Problems

| Symptom | Likely Cause | Resolution |
|---|---|---|
| Cluster health `yellow` | Replica shards unassigned | Add more nodes; or set `number_of_replicas: 0` for single-node dev |
| Cluster health `red` | Primary shards unassigned | Check allocation explain API; investigate node availability |
| Index `read_only_allow_delete` | Disk flood stage reached | Free disk space; remove the read-only block |
| Shard imbalance across nodes | Custom routing or allocation filters | Review routing values and filter configuration |
| Slow bulk indexing | Replicas active during load | Temporarily set `number_of_replicas: 0` during load |
| High heap usage | Too many shards per node | Reduce shard count; increase heap; add nodes |
| Large shard recovery time after failure | Shards are too large | Aim for smaller shard sizes within the 10–50 GB range |
| `max_shards_per_node` exceeded | Too many shards for the cluster | Reduce shard count; increase `cluster.max_shards_per_node` with caution |

---

### Summary — Key Numbers and Defaults

| Parameter | Default | Notes |
|---|---|---|
| `number_of_shards` | 1 (7.0+) | Set at index creation; immutable afterward |
| `number_of_replicas` | 1 | Mutable at any time |
| Recommended shard size | 10–50 GB | Guideline; not enforced |
| Max shards per node | 1000 | Configurable via `cluster.max_shards_per_node` |
| Shards per GB heap guideline | ≤20 | Widely cited heuristic; not enforced |
| Disk low watermark | 85% | No new shards allocated above this |
| Disk high watermark | 90% | Shards relocated away above this |
| Disk flood stage | 95% | Index set to read-only above this |
| Default refresh interval | 1 second | Controls NRT search visibility |

---

**Conclusion**

Shards are the unit of parallelism, distribution, and recovery in Elasticsearch. Primary shards define how data is partitioned; replica shards provide redundancy and read throughput. The immutability of primary shard count makes correct initial sizing important — though the Split, Shrink, and Reindex APIs provide remediation paths. Replica count is flexible and can be tuned for the operational context, including temporarily removing replicas during bulk loads. Shard sizing, allocation awareness, disk watermarks, and the allocation explain API together form the toolkit for maintaining a well-distributed, healthy cluster across its operational lifetime.

**Next Steps** — index lifecycle management, mappings and field types, and the write and search paths build directly on the shard and replica mechanics established here.