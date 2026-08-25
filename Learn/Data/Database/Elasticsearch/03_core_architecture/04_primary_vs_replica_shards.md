## Primary vs Replica Shards

### Overview

Sharding is the mechanism by which Elasticsearch distributes data across nodes in a cluster. Every index in Elasticsearch is divided into one or more **shards** — each shard being a self-contained, fully functional Lucene index. Shards come in two types:

- **Primary shards** — hold the authoritative copy of the data
- **Replica shards** — hold copies of primary shards for redundancy and read scalability

Understanding how primary and replica shards work, interact, and are configured is foundational to designing, operating, and troubleshooting Elasticsearch clusters effectively.

---

### What a Shard Is

A shard is an instance of **Apache Lucene** running inside an Elasticsearch node. It is the actual unit of storage and search. From Lucene's perspective, each shard is an independent index composed of one or more **segments** — immutable files written to disk during indexing.

From Elasticsearch's perspective, shards are the unit of:

- **Distribution** — shards are spread across nodes
- **Replication** — replica shards copy primary shards
- **Parallelism** — search queries execute concurrently across shards
- **Recovery** — failed nodes are recovered at the shard level

An Elasticsearch index is a logical namespace that maps to one or more physical shards:

```
Index: "logs-2024-01"
├── Primary Shard 0  →  Node A
├── Primary Shard 1  →  Node B
├── Primary Shard 2  →  Node C
├── Replica Shard 0  →  Node B  (copy of Primary 0)
├── Replica Shard 1  →  Node C  (copy of Primary 1)
└── Replica Shard 2  →  Node A  (copy of Primary 2)
```

---

### Primary Shards

#### Definition

A **primary shard** holds the original, authoritative copy of a subset of an index's documents. All indexing operations (create, update, delete) are first written to the primary shard and then replicated to its replica shards.

#### Routing Documents to Primary Shards

When a document is indexed, Elasticsearch determines which primary shard it belongs to using a routing formula:

```
shard = hash(_routing) % number_of_primary_shards
```

By default, `_routing` is the document's `_id`. This produces a deterministic assignment — the same document always maps to the same shard.

**Example:**

```json
PUT /products/_doc/42
{
  "name": "Wireless Keyboard",
  "price": 49.99
}
```

Elasticsearch hashes the document ID `42`, applies modulo against the number of primary shards, and writes the document to the resulting shard on whichever node hosts that shard.

#### Custom Routing

The routing value can be overridden:

```json
PUT /products/_doc/42?routing=electronics
{
  "name": "Wireless Keyboard",
  "price": 49.99
}
```

Custom routing is useful for co-locating related documents on the same shard, which can [Inference] improve query performance for queries scoped to that routing value — though the benefit depends on query patterns and data distribution.

> When using custom routing, searches must also specify the same routing value to target the correct shard, or use `_search` across all shards. Inconsistent routing can lead to missing results.

#### Why the Number of Primary Shards Is Fixed at Index Creation

The routing formula uses `number_of_primary_shards` as the divisor. If this number changes after documents are indexed, existing documents would map to different shards — making them unreachable without a full reindex.

For this reason, **the number of primary shards cannot be changed after index creation** without reindexing.

```json
PUT /products
{
  "settings": {
    "number_of_shards": 3,      ← fixed at creation
    "number_of_replicas": 1     ← can be changed later
  }
}
```

> The exception is the **Split API** and **Shrink API**, which create a new index with a different shard count from an existing one — but these are explicit reindexing operations, not in-place changes.

#### Default Primary Shard Count

- **Elasticsearch 7.0+** — default is **1 primary shard** per index
- **Elasticsearch prior to 7.0** — default was **5 primary shards** per index

The change to 1 shard default reflects that over-sharding is a common operational problem. Starting with 1 shard and scaling via the Split API is the recommended approach when future shard count requirements are uncertain.

---

### Replica Shards

#### Definition

A **replica shard** is a copy of a primary shard. It serves two purposes:

- **High availability** — if the node hosting a primary shard fails, a replica on another node is promoted to primary
- **Read scalability** — search queries can be served by either primary or replica shards, distributing read load

#### Replica Placement Rules

Elasticsearch enforces one critical placement rule:

> **A replica shard is never placed on the same node as its primary shard.**

This rule exists to ensure that a single node failure does not simultaneously lose both a primary shard and its replica. ECK and Elasticsearch enforce this automatically — no manual configuration is needed.

Additionally, replicas of the same shard are placed on different nodes from each other when possible.

#### Number of Replicas

Unlike primary shards, **the number of replica shards can be changed at any time** without reindexing:

```json
PUT /products/_settings
{
  "number_of_replicas": 2
}
```

Elasticsearch immediately begins creating or removing replica shards to match the new setting.

#### Replica Behavior in a Single-Node Cluster

In a single-node cluster, there is no other node to place replicas on. Replica shards remain **unassigned**, and the cluster reports `yellow` health — not `green`:

```json
{
  "status": "yellow",
  "unassigned_shards": 3
}
```

This is expected and not an error in a development environment. In production, a `yellow` cluster indicates reduced redundancy and should be investigated.

To avoid `yellow` status in a single-node development cluster:

```json
PUT /products/_settings
{
  "number_of_replicas": 0
}
```

---

### Replication Process

#### Write Path

When a document is written to Elasticsearch:

1. The request reaches a **coordinating node** (any node can act as coordinator).
2. The coordinator routes the request to the node hosting the **primary shard** for that document.
3. The primary shard validates and indexes the document locally.
4. The primary shard **forwards the operation** to all in-sync replica shards in parallel.
5. Once all in-sync replicas acknowledge the write, the primary responds to the coordinator.
6. The coordinator responds to the client.

```
Client → Coordinating Node → Primary Shard
                                   ↓ (parallel)
                            Replica Shard A
                            Replica Shard B
```

#### In-Sync Replica Set

Elasticsearch maintains an **in-sync replica set (ISR)** — the set of replica shards that are confirmed to be up to date with the primary. Only replicas in the ISR receive write operations and must acknowledge them before the write is considered complete.

If a replica falls behind (e.g., due to a slow or unresponsive node), it is **removed from the ISR**. The primary continues operating with the remaining in-sync replicas. The lagging replica must sync before being re-added to the ISR.

#### `wait_for_active_shards`

The indexing API's `wait_for_active_shards` parameter controls how many shard copies must acknowledge a write before the client receives a success response:

```json
PUT /products/_doc/42?wait_for_active_shards=2
{
  "name": "Wireless Keyboard"
}
```

|Value|Meaning|
|---|---|
|`1` (default)|Only the primary must acknowledge|
|`2`|Primary + 1 replica must acknowledge|
|`all`|All active shard copies must acknowledge|

> Higher `wait_for_active_shards` values increase write durability guarantees at the cost of write latency. The default of `1` means a write is confirmed as soon as the primary acknowledges — before replicas have confirmed. This means data acknowledged by the primary could [Inference] be lost if the primary fails before replication completes, though Elasticsearch's recovery mechanisms reduce this risk.

---

### Read Path

#### Search

Search requests are broadcast to all shards of the target index (or a subset, using routing). For each shard, Elasticsearch can route the request to **either the primary or any in-sync replica**. The selection uses **adaptive replica selection** (default since Elasticsearch 7.x), which favors shards on nodes with lower response times and queue depths.

```
Client → Coordinating Node
              ↓ (scatter to all shards)
         Primary 0   Replica 1   Replica 2
              ↓ (gather and rank results)
         Coordinating Node → Client
```

#### Get by ID

Direct document retrieval by `_id` (the `GET /index/_doc/id` API) uses a **preference for the primary shard** by default, but can be directed to replicas for read scalability:

```json
GET /products/_doc/42?preference=_replica
```

#### Read-Your-Writes Consistency

Because replicas are updated asynchronously after the primary acknowledges a write, a read immediately after a write may not reflect the latest data if the read is served by a replica that has not yet processed the write. This is a standard eventual consistency characteristic of distributed systems.

To mitigate this, use the `?preference=_primary` parameter on reads that require strict consistency — though this concentrates read load on primaries. [Inference]

---

### Shard Allocation

#### How Elasticsearch Assigns Shards to Nodes

The **shard allocation** process is managed by the master node. It uses a set of rules and heuristics to determine where each shard should be placed:

- **Replica exclusion rule** — primary and its replicas cannot share a node
- **Disk watermarks** — shards are not allocated to nodes approaching disk capacity
- **Allocation filters** — custom rules using node attributes (e.g., `_tier_preference`, custom tags)
- **Rebalancing** — shards are moved to maintain an even distribution across nodes

#### Allocation Settings

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}
```

|Value|Behavior|
|---|---|
|`all`|All shard types can be allocated (default)|
|`primaries`|Only primary shards can be allocated|
|`new_primaries`|Only new primary shards can be allocated|
|`none`|No shard allocation|

Temporarily setting `none` is a common operational pattern during rolling restarts to prevent unnecessary shard movements:

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}
```

#### Shard Allocation Awareness

Allocation awareness instructs Elasticsearch to distribute shards across failure domains such as availability zones or racks:

```yaml
# elasticsearch.yml
cluster.routing.allocation.awareness.attributes: zone
node.attr.zone: us-east-1a
```

With awareness configured, Elasticsearch attempts to place primary and replica shards in different zones, so that a zone failure does not take down both copies of any shard.

**Forced awareness** (stricter):

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.force.zone.values": ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}
```

Forced awareness prevents replicas from being placed in the same zone even if it means leaving them unassigned temporarily. [Inference] This avoids concentrating too many shards in a single zone during partial failures, though the trade-off is potential `yellow` cluster status during zone-level disruptions.

---

### Shard Sizing

#### Why Shard Size Matters

Each shard has overhead: JVM heap usage, file handles, and coordination cost. Both **too many small shards** and **too few large shards** cause problems.

|Problem|Cause|Symptom|
|---|---|---|
|**Over-sharding**|Too many shards relative to data volume|High heap usage, slow cluster state updates, poor query performance|
|**Under-sharding**|Too few shards for data volume|Single shards become bottlenecks, loss of parallelism|

#### Recommended Shard Size

Elastic's general guidance (from official documentation):

- Target **10–50 GB per shard** for most workloads
- For time-series data (logs, metrics), **20–40 GB** is a commonly cited target range

> [Inference] These are starting points, not universal rules. Optimal shard size depends on document size, query patterns, hardware, and retention policies. Workload-specific benchmarking is more reliable than generic guidelines.

#### Shard Count Planning

A rough formula for estimating primary shard count:

```
number_of_primary_shards = ceil(expected_index_size_GB / target_shard_size_GB)
```

**Example:**

```
Expected index size: 300 GB
Target shard size:   30 GB
Primary shards:      ceil(300 / 30) = 10
```

With 1 replica:

```
Total shard copies = 10 primaries + 10 replicas = 20 shards
```

These 20 shards would be distributed across the available data nodes.

#### Shards per Node

A commonly referenced guideline from Elastic:

> Keep the number of shards per GB of heap memory below **20**.

For a node with 32 GB heap:

```
Maximum shards per node ≈ 32 × 20 = 640 shards
```

> [Unverified] This guideline is frequently cited but actual capacity depends heavily on shard size, query complexity, and workload. Use it as a starting point for capacity planning, not a hard ceiling.

---

### Cluster Health and Shard States

#### Cluster Health Colors

|Color|Meaning|
|---|---|
|`green`|All primary and replica shards are assigned and active|
|`yellow`|All primary shards are active; one or more replica shards are unassigned|
|`red`|One or more primary shards are unassigned (data loss or unavailability)|

#### Individual Shard States

|State|Meaning|
|---|---|
|`STARTED`|Shard is active and serving requests|
|`INITIALIZING`|Shard is being created or recovering|
|`RELOCATING`|Shard is being moved to another node|
|`UNASSIGNED`|Shard has not been assigned to any node|

#### Checking Shard Allocation

```json
GET /_cat/shards?v&h=index,shard,prirep,state,node,unassigned.reason
```

**Example output:**

```
index        shard prirep state      node       unassigned.reason
products     0     p      STARTED    node-1
products     0     r      STARTED    node-2
products     1     p      STARTED    node-2
products     1     r      UNASSIGNED            NODE_LEFT
```

#### Diagnosing Unassigned Shards

```json
GET /_cluster/allocation/explain
```

This API returns a detailed explanation of why a specific shard cannot be assigned, including which nodes were considered and why each was rejected:

```json
{
  "index": "products",
  "shard": 1,
  "primary": false,
  "explanation": "cannot allocate because a previous copy of the primary shard existed but can no longer be found on the nodes in the cluster",
  "node_allocation_decisions": [...]
}
```

---

### Primary Shard Failover

#### Sequence of Events on Node Failure

1. A node hosting a primary shard becomes unreachable.
2. The master node detects the failure (after `discovery.cluster_formation_warning_timeout` elapses — default 10 seconds).
3. The master promotes an **in-sync replica shard** on another node to become the new primary.
4. The cluster updates its routing table.
5. If the failed node's replicas were the only copies, those shards become unassigned (cluster goes `yellow` or `red`).
6. If the failed node later rejoins, its shards are compared against the current primary and either synced or discarded.

#### Sequence Numbers and Checkpoint Mechanism

Elasticsearch tracks replication state using:

- **Sequence numbers** — assigned to every indexing operation on a primary shard
- **Local checkpoint** — the highest sequence number for which all operations on the shard have been processed
- **Global checkpoint** — the highest sequence number for which all in-sync replicas have confirmed processing

When a failed node rejoins, its shard's local checkpoint is compared to the current primary's global checkpoint to determine what operations need to be replayed for the shard to catch up — avoiding a full shard copy when only recent operations are missing.

---

### Controlling Shard Behavior

#### Forcing a Shard Reroute

Manually move a shard to a specific node:

```json
POST /_cluster/reroute
{
  "commands": [
    {
      "move": {
        "index": "products",
        "shard": 0,
        "from_node": "node-1",
        "to_node": "node-3"
      }
    }
  ]
}
```

Force-allocate an unassigned replica:

```json
POST /_cluster/reroute
{
  "commands": [
    {
      "allocate_replica": {
        "index": "products",
        "shard": 1,
        "node": "node-2"
      }
    }
  ]
}
```

> Force-allocating a primary (`allocate_stale_primary` or `allocate_empty_primary`) can result in data loss if the most recent copy of the shard is not selected. Use with caution and only when the implications are understood.

#### Excluding a Node from Allocation

To drain a node before decommissioning:

```json
PUT /_cluster/settings
{
  "transient": {
    "cluster.routing.allocation.exclude._name": "node-3"
  }
}
```

Elasticsearch moves all shards off `node-3` before the node is shut down, preventing data loss.

---

### Index Templates and Shard Defaults

Shard settings are typically defined in **index templates** rather than set per-index, ensuring consistent shard configuration across indices:

```json
PUT /_index_template/logs-template
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 2,
      "number_of_replicas": 1
    }
  }
}
```

For data streams, shard settings are defined in the component template applied to the backing indices.

---

### Split and Shrink APIs

Since primary shard count cannot be changed in place, Elasticsearch provides two APIs for resizing:

#### Split API

Creates a new index with **more** primary shards from an existing index. The number of target shards must be a multiple of the source shard count.

```json
POST /products/_split/products-v2
{
  "settings": {
    "number_of_shards": 6    ← must be a multiple of current (e.g., 2 → 4, 6)
  }
}
```

Prerequisites:

- The source index must be set to **read-only** before splitting
- All primary shards must be active

#### Shrink API

Creates a new index with **fewer** primary shards. All primary shards of the source index must first be relocated to a single node.

```json
PUT /products/_settings
{
  "settings": {
    "index.routing.allocation.require._name": "node-1",
    "index.blocks.write": true
  }
}

POST /products/_shrink/products-small
{
  "settings": {
    "number_of_shards": 1
  }
}
```

---

### Summary: Primary vs Replica Shards

|Dimension|Primary Shard|Replica Shard|
|---|---|---|
|**Purpose**|Authoritative data storage|Redundancy and read scalability|
|**Write operations**|Received first; forwarded to replicas|Received from primary only|
|**Read operations**|Serves search and get requests|Serves search and get requests|
|**Placement**|Any eligible data node|Never on same node as its primary|
|**Count**|Fixed at index creation|Changeable at any time|
|**Failover**|Promoted from replica on failure|New replica assigned after primary recovers|
|**Default count**|1 (Elasticsearch 7.0+)|1|
|**Cluster health impact**|Unassigned primary → `red`|Unassigned replica → `yellow`|

---

**Conclusion**

Primary and replica shards form the backbone of Elasticsearch's distributed storage model. Primaries provide the authoritative data copy and process all writes; replicas provide redundancy and distribute read load. The interplay between them — routing, replication, in-sync sets, failover promotion, and allocation awareness — determines both the reliability and the performance characteristics of an Elasticsearch cluster. Correct shard sizing and count planning, combined with allocation awareness across failure domains, are among the most impactful architectural decisions when deploying Elasticsearch at scale.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===