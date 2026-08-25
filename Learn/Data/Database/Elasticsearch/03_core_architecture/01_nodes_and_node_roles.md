Nodes and node roles
## Nodes and Node Roles

---

### Overview

A node is a single running instance of Elasticsearch. Every node belongs to exactly one cluster, holds a subset of the cluster's data, and participates in one or more cluster functions determined by its assigned **roles**. Understanding node roles is fundamental to designing clusters that are stable, performant, and operationally maintainable at scale.

---

### What a Node Is

When Elasticsearch starts, it:

- Joins or forms a cluster based on `cluster.name` and discovery configuration
- Assumes one or more roles as defined by `node.roles` in `elasticsearch.yml`
- Receives and stores shards allocated to it by the master node
- Participates in indexing, search, and cluster management operations according to its roles

Each node maintains a copy of the **cluster state** — a shared data structure describing the cluster's indices, mappings, settings, shard locations, and node membership.

---

### Node Roles — Introduction

Node roles are assigned explicitly via the `node.roles` setting in `elasticsearch.yml`:

```yaml
node.roles: [ master, data, ingest ]
```

If `node.roles` is omitted entirely, the node assumes a **default set of roles** that includes master eligibility, data, ingest, and others depending on the version.

[Inference] The exact set of default roles assigned when `node.roles` is omitted may vary by Elasticsearch version. Explicit role assignment is recommended for any non-trivial deployment.

A node may hold **multiple roles simultaneously**. In small clusters and development environments, a single node commonly holds all roles. In large production clusters, roles are separated across dedicated node pools for stability and performance isolation.

---

### Complete List of Node Roles (Elasticsearch 8.x)

| Role | `node.roles` Value | Primary Responsibility |
|---|---|---|
| Master-eligible | `master` | Cluster management and state |
| Data | `data` | General data storage and search |
| Data Content | `data_content` | Persistent, non-time-series data |
| Data Hot | `data_hot` | Active time-series data (ILM hot tier) |
| Data Warm | `data_warm` | Less-active time-series data (ILM warm tier) |
| Data Cold | `data_cold` | Infrequently accessed data (ILM cold tier) |
| Data Frozen | `data_frozen` | Rarely accessed data on searchable snapshots |
| Ingest | `ingest` | Pre-indexing document transformation |
| Coordinating only | *(no roles)* | Request routing and result merging |
| Remote cluster client | `remote_cluster_client` | Cross-cluster search and replication |
| Machine learning | `ml` | Machine learning job execution |
| Transform | `transform` | Scheduled transform jobs |
| Voting-only | `voting_only` | Participates in master elections without being eligible to become master |

---

### Master-Eligible Nodes

#### Role Declaration

```yaml
node.roles: [ master ]
```

#### Responsibilities

The **elected master** node is responsible for:

- Maintaining and publishing the **cluster state** to all nodes
- Creating, updating, and deleting indices
- Allocating and reallocating shards across data nodes
- Tracking which nodes are members of the cluster
- Coordinating cluster-level operations (snapshot, reindex, ILM transitions)

Only one node is the **active master** at any time. Master-eligible nodes that are not the current master act as candidates for election if the current master becomes unavailable.

#### Master Election and Quorum

Elasticsearch uses a **Raft-based consensus algorithm** (introduced in 7.x, replacing Zen discovery) for master election. A quorum of master-eligible nodes must agree before a master is elected or any cluster state change is committed.

Quorum size:

```
quorum = floor(number_of_master_eligible_nodes / 2) + 1
```

| Master-Eligible Nodes | Quorum | Tolerated Failures |
|---|---|---|
| 1 | 1 | 0 |
| 2 | 2 | 0 |
| 3 | 2 | 1 |
| 5 | 3 | 2 |
| 7 | 4 | 3 |

> Two master-eligible nodes provide no fault tolerance — both must be reachable. Three is the minimum for any meaningful resilience.

#### Dedicated Master Nodes

In production clusters, master-eligible nodes are commonly **dedicated** — they hold no data and serve no search requests. This protects cluster stability from the resource pressure of indexing and search workloads.

```yaml
node.roles: [ master ]
```

A dedicated master node should have:
- Sufficient CPU and RAM for cluster state management (scales with index/shard count, not data volume)
- Low-latency network connectivity to other nodes
- Minimal other workloads on the host

[Inference] The resource requirements of a dedicated master node scale with cluster complexity (number of indices, shards, and nodes), not data volume. Exact requirements depend on cluster size and workload characteristics.

---

### Data Nodes

#### Role Declaration

```yaml
node.roles: [ data ]
```

#### Responsibilities

Data nodes:

- Store primary and replica shards
- Execute **indexing** operations — writing documents to local shards
- Execute **search and aggregation** queries against locally held shards
- Perform segment merges, deletions, and other Lucene-level maintenance

Data nodes are typically the most resource-intensive nodes in a cluster — they require substantial RAM (for heap and Lucene file system cache), fast storage (SSDs preferred), and sufficient CPU for concurrent search and indexing.

#### Data Tier Roles

Elasticsearch supports **data tiers** — specialized data node roles aligned with the Index Lifecycle Management (ILM) hot-warm-cold-frozen architecture.

##### `data_content`

```yaml
node.roles: [ data_content ]
```

For indices that are not time-series — application data, product catalogs, user records. Data remains on this tier indefinitely and is not subject to automatic tier migration.

##### `data_hot`

```yaml
node.roles: [ data_hot ]
```

The active write tier. Receives all new indexing for time-series data streams. Should use the fastest available storage. ILM rolls over indices from this tier when size or age thresholds are met.

##### `data_warm`

```yaml
node.roles: [ data_warm ]
```

For indices that are no longer actively written but are still queried regularly. Typically uses lower-cost storage than hot nodes. ILM moves indices here after rollover from hot.

##### `data_cold`

```yaml
node.roles: [ data_cold ]
```

For indices that are infrequently queried. Lower hardware requirements. Data is still fully present on disk (not mounted from snapshots).

##### `data_frozen`

```yaml
node.roles: [ data_frozen ]
```

For the coldest data, backed by **searchable snapshots** stored in object storage (e.g., S3, GCS). The frozen tier mounts snapshot data on demand rather than keeping it on local disk, minimizing storage costs for rarely accessed data.

[Inference] Searchable snapshots and the frozen tier require an appropriate Elastic license tier. Behavior and availability of frozen tier features depend on the license in use.

##### Using `data` vs Tier-Specific Roles

| Scenario | Recommended Role |
|---|---|
| Simple cluster, no ILM tiering | `data` |
| Hot-warm-cold ILM architecture | `data_hot`, `data_warm`, `data_cold` |
| Non-time-series application data | `data_content` |
| Maximum storage cost reduction | `data_frozen` |

> The generic `data` role includes all data sub-roles. A node with `node.roles: [ data ]` can hold shards from any tier. Explicit tier roles are used to constrain which shards a node accepts.

---

### Ingest Nodes

#### Role Declaration

```yaml
node.roles: [ ingest ]
```

#### Responsibilities

Ingest nodes execute **ingest pipelines** — sequences of processors that transform documents before they are written to an index.

Common pipeline processors include:

| Processor | Function |
|---|---|
| `grok` | Parse unstructured text using patterns |
| `dissect` | Extract fields from structured text |
| `set` | Add or overwrite a field value |
| `rename` | Rename a field |
| `remove` | Delete a field |
| `date` | Parse and convert date strings |
| `convert` | Change field data types |
| `gsub` | Apply regex substitution to a field |
| `script` | Execute a Painless script |
| `enrich` | Look up and embed data from an enrich index |

Ingest pipelines are specified at index time:

```bash
PUT /my-index/_doc/1?pipeline=my-pipeline
{
  "message": "192.168.1.1 - GET /index.html 200"
}
```

#### When to Use Dedicated Ingest Nodes

In clusters with high-throughput or computationally expensive ingest pipelines (e.g., heavy Grok parsing, script processors, enrichment), dedicated ingest nodes prevent pipeline processing from competing with indexing and search on data nodes.

```yaml
# Dedicated ingest node
node.roles: [ ingest ]
```

[Inference] For low-volume or simple pipelines, dedicated ingest nodes may add unnecessary operational complexity. The appropriate architecture depends on pipeline complexity and indexing throughput.

---

### Coordinating Nodes

#### Role Declaration

```yaml
# A coordinating-only node has no roles assigned
node.roles: []
```

#### Responsibilities

Every node in an Elasticsearch cluster acts as a **coordinating node** for the requests it receives — regardless of its other roles. When a client sends a search or indexing request to any node, that node coordinates the operation:

1. Determines which shards are relevant to the request
2. Forwards sub-requests to the appropriate shard-holding nodes
3. Collects and merges responses
4. Returns the final result to the client

A **coordinating-only node** (no roles assigned) performs only this function. It holds no data and is not master-eligible.

#### When to Use Coordinating-Only Nodes

In clusters handling large, fan-out search requests (many shards, large aggregations), coordinating-only nodes absorb the CPU and memory overhead of result merging — shielding data nodes from this load.

```yaml
node.roles: []
```

[Inference] Coordinating-only nodes add value primarily in high-query-volume clusters with expensive aggregations. In smaller clusters they add operational overhead without proportional benefit. Suitability depends on workload.

---

### Voting-Only Nodes

#### Role Declaration

```yaml
node.roles: [ master, voting_only ]
```

#### Responsibilities

A voting-only node participates in **master elections** — it votes in quorum decisions — but is **never eligible to become the active master** itself.

This role is used to achieve quorum with an odd number of master-eligible voters without adding a third full master node. A voting-only node can simultaneously hold the `data` role, making it a data node that also contributes to master election quorum.

**Example use case:**

A two-node cluster with one full master node and one voting-only data node achieves a three-voter quorum (the two nodes plus the tiebreaker behavior), allowing master election without requiring a third dedicated master node.

[Inference] The voting-only role interacts with quorum mechanics in ways that depend on cluster topology. Cluster design using this role should be validated carefully against the specific version's documentation.

---

### Remote Cluster Client Nodes

#### Role Declaration

```yaml
node.roles: [ remote_cluster_client ]
```

#### Responsibilities

Enables the node to act as a client for **cross-cluster search (CCS)** and **cross-cluster replication (CCR)** operations. Nodes with this role can connect to and query remote Elasticsearch clusters.

By default, all nodes are remote cluster clients. Explicitly assigning this role (and excluding it from other nodes) allows fine-grained control over which nodes handle cross-cluster traffic.

---

### Machine Learning Nodes

#### Role Declaration

```yaml
node.roles: [ ml ]
```

#### Responsibilities

ML nodes run **machine learning jobs**:

- Anomaly detection jobs
- Data frame analytics jobs
- Natural language processing (NLP) model deployments

ML jobs are computationally intensive. In production, dedicated ML nodes prevent job execution from affecting search and indexing performance on data nodes.

[Inference] Machine learning features require an appropriate Elastic subscription tier. Availability of specific ML capabilities depends on the license in use.

---

### Transform Nodes

#### Role Declaration

```yaml
node.roles: [ transform ]
```

#### Responsibilities

Transform nodes execute **transform jobs** — scheduled or continuous operations that aggregate and pivot index data into new summary indices. Transforms are commonly used to produce aggregated views of log or event data for dashboards or reporting.

---

### Node Role Combinations

#### Single-Node (Development)

```yaml
# All roles — default behavior when node.roles is omitted
# Equivalent explicit declaration:
node.roles: [ master, data, data_content, data_hot, data_warm, data_cold, data_frozen, ingest, remote_cluster_client, transform ]
```

A single node with all roles is the standard development configuration.

#### Small Production Cluster (3 Nodes, All-Purpose)

Each node holds all roles — a practical setup for small clusters that do not need role separation.

```yaml
node.roles: [ master, data, ingest ]
```

#### Medium Production Cluster (Dedicated Masters + Data)

```
3 dedicated master nodes   → node.roles: [ master ]
N data nodes               → node.roles: [ data, ingest ]
```

#### Large Production Cluster (Full Role Separation)

```
3 dedicated master nodes          → node.roles: [ master ]
N hot data nodes                  → node.roles: [ data_hot, data_content ]
N warm data nodes                 → node.roles: [ data_warm ]
N cold data nodes                 → node.roles: [ data_cold ]
2–3 ingest nodes                  → node.roles: [ ingest ]
2–3 coordinating-only nodes       → node.roles: []
2   ML nodes                      → node.roles: [ ml ]
```

[Inference] Specific node counts and role assignments depend heavily on workload characteristics, data volume, query patterns, and operational requirements. The above is a representative pattern, not a prescriptive recommendation.

---

### Viewing Node Roles in a Running Cluster

#### `_cat/nodes` API

```bash
GET /_cat/nodes?v&h=name,node.role,master,ip,heap.percent,ram.percent,cpu
```

**Example output:**

```
name    node.role                    master ip        heap.percent
node-1  cdfhilmrstw                  *      127.0.0.1           24
node-2  cdfhilmrstw                  -      127.0.0.1           19
node-3  cdfhilmrstw                  -      127.0.0.1           21
```

The `node.role` column displays abbreviated role codes:

| Code | Role |
|---|---|
| `m` | master-eligible |
| `d` | data |
| `i` | ingest |
| `c` | coordinating |
| `r` | remote cluster client |
| `l` | machine learning |
| `t` | transform |
| `v` | voting only |
| `h` | data_hot |
| `w` | data_warm |
| `s` | data_cold |
| `f` | data_frozen |

#### `_nodes` API (Detailed)

```bash
GET /_nodes?pretty
```

Returns full node information including roles, JVM details, OS stats, and transport addresses.

```bash
# Filter to a specific node
GET /_nodes/node-1?pretty

# Filter to role information only
GET /_nodes?filter_path=nodes.*.roles
```

---

### How the Master Node Uses Role Information

The master node uses role assignments to make **shard allocation decisions**:

- Primary and replica shards are allocated only to nodes with a data role (`data`, `data_hot`, `data_warm`, etc.)
- Indices with ILM tier preferences are allocated to nodes with the matching tier role
- Master-only and coordinating-only nodes never receive shard assignments

This means misconfigured roles — such as a node intended to hold data but missing a data role — will result in shards being unallocated, driving cluster health to `yellow` or `red`.

---

### Changing Node Roles

Node roles are set in `elasticsearch.yml` and take effect on the **next node restart**.

```yaml
# Before
node.roles: [ master, data, ingest ]

# After
node.roles: [ data, ingest ]
```

> When a node's roles change — particularly when removing the `data` role — any shards it held must be reallocated to other nodes before the restart, or cluster health will be affected. Use the shard allocation exclusion API before removing a data role from a live node:

```bash
PUT /_cluster/settings
{
  "transient": {
    "cluster.routing.allocation.exclude._name": "node-1"
  }
}
```

This instructs the master to move all shards off `node-1` before it is restarted or reconfigured.

[Inference] Shard reallocation timing depends on shard size, network throughput, and cluster load. The exclusion setting should be verified as complete (cluster health green, node holds no shards) before proceeding with role changes. Behavior may vary.

---

### Bootstrap Checks Related to Node Roles

Certain node roles trigger **bootstrap checks** at startup when `network.host` is set to a non-loopback address:

- Nodes with data roles trigger checks for `vm.max_map_count`, file descriptor limits, and memory lock
- Master-eligible nodes trigger checks for minimum master nodes configuration (in versions that still use this setting)

Failing bootstrap checks will prevent node startup with an explicit error message identifying the failed check.

---

### Summary — Role Reference

| Role | Data Storage | Search | Master Eligible | Ingest | Notes |
|---|---|---|---|---|---|
| `master` | No | No | Yes | No | Cluster management |
| `data` | Yes | Yes | No | No | General purpose data |
| `data_content` | Yes | Yes | No | No | Non-time-series data |
| `data_hot` | Yes | Yes | No | No | ILM hot tier |
| `data_warm` | Yes | Yes | No | No | ILM warm tier |
| `data_cold` | Yes | Yes | No | No | ILM cold tier |
| `data_frozen` | Yes (snapshot-backed) | Yes | No | No | ILM frozen tier |
| `ingest` | No | No | No | Yes | Pipeline processing |
| *(none)* | No | No | No | No | Coordinating only |
| `voting_only` | No | No | No (votes only) | No | Quorum without master eligibility |
| `remote_cluster_client` | No | No | No | No | Cross-cluster operations |
| `ml` | No | No | No | No | ML job execution |
| `transform` | No | No | No | No | Transform job execution |

---

**Conclusion**

Node roles are the mechanism by which Elasticsearch distributes responsibilities across a cluster. In small or development clusters, a single node or a uniform pool of nodes holding all roles is typical. As clusters grow, separating roles — particularly isolating dedicated master nodes — protects cluster stability and improves performance isolation. Understanding what each role does, how the master uses role information for shard allocation, and how to observe and modify roles on live nodes is essential for both cluster design and day-to-day operations.

**Next Steps** — cluster formation, shard allocation mechanics, and index lifecycle management build directly on the role architecture established here.