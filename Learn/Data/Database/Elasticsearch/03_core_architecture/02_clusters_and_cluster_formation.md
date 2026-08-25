## Clusters and Cluster Formation

---

### Overview

A cluster is a collection of one or more Elasticsearch nodes that collectively hold all indexed data and provide coordinated search and indexing capability across it. Cluster formation is the process by which individual nodes discover each other, elect a master, and establish a shared operational state. Understanding how clusters form, how they maintain coherence, and how they recover from failure is foundational to operating Elasticsearch reliably.

---

### What a Cluster Is

An Elasticsearch cluster is defined by:

- A shared **`cluster.name`** — nodes only join clusters whose name matches their own
- A single **elected master node** — responsible for cluster state management at any given time
- A shared **cluster state** — a data structure replicated to all nodes describing every aspect of the cluster's configuration and topology
- A set of **indices and shards** distributed across the cluster's data nodes

Every node in a cluster maintains a local copy of the cluster state and is informed of state changes by the master node.

---

### Cluster State

The **cluster state** is the authoritative description of the cluster at a point in time. It is maintained by the master node and published to all other nodes whenever it changes.

The cluster state contains:

|Component|Description|
|---|---|
|Nodes|All current member nodes and their metadata|
|Index metadata|Mappings, settings, and aliases for every index|
|Routing table|Which shards are assigned to which nodes|
|Templates|Index templates and component templates|
|ILM policies|Index lifecycle management policies|
|Snapshots|In-progress and registered snapshot repositories|
|Cluster settings|Persistent and transient cluster-level settings|

The cluster state is **not** a log of events — it is a snapshot of current configuration. It can grow large in clusters with many indices, shards, or complex mappings.

#### Viewing Cluster State

```bash
GET /_cluster/state?pretty
```

Filter to specific sections:

```bash
# Only routing table and metadata
GET /_cluster/state/routing_table,metadata?pretty

# Only nodes
GET /_cluster/state/nodes?pretty
```

> The full cluster state response can be very large in active clusters. Filtering to relevant sections is preferred in production.

---

### Cluster Formation — Step by Step

Cluster formation is the process by which nodes discover each other, elect a master, and begin operating as a unit. It occurs at initial startup and after cluster-wide restarts.

#### Step 1 — Node Startup and Transport Bind

Each node starts, loads its configuration, and binds to its **transport port** (default `9300`). The transport layer is used exclusively for inter-node communication — client access uses the HTTP layer on port `9200`.

#### Step 2 — Seed Host Contact

Each node contacts the addresses listed in `discovery.seed_hosts`. These are the initial entry points for cluster discovery.

```yaml
discovery.seed_hosts:
  - 10.0.0.1:9300
  - 10.0.0.2:9300
  - 10.0.0.3:9300
```

Seed hosts can be specified as:

- IP addresses with port: `10.0.0.1:9300`
- Hostnames with port: `es-node-1.example.com:9300`
- IP addresses without port (default transport port assumed): `10.0.0.1`

The seed hosts do not need to include all nodes in the cluster — only enough to bootstrap initial discovery. Once connected, nodes learn about other cluster members from those they have already contacted.

#### Step 3 — Peer Discovery

Through seed host contact, each node builds a view of which master-eligible nodes are reachable. This process is iterative — nodes contacted during discovery may introduce additional nodes.

#### Step 4 — Master Election

Once a quorum of master-eligible nodes have found each other, they conduct a **master election** using Elasticsearch's Raft-based consensus mechanism (introduced in 7.0 as part of the new cluster coordination layer).

The elected master is the node that receives votes from a quorum of master-eligible nodes:

```
quorum = floor(n / 2) + 1
```

Where `n` is the total number of master-eligible nodes in the cluster.

A node votes for itself and other candidates based on the recency and completeness of their cluster state knowledge.

#### Step 5 — Cluster Bootstrapping (First Formation Only)

On the **very first formation** of a cluster — before any cluster state exists — `cluster.initial_master_nodes` is required to identify which master-eligible nodes are part of the initial quorum.

```yaml
cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3
```

This setting prevents a **split-brain** scenario during initial bootstrap by requiring explicit acknowledgment of which nodes constitute the starting quorum.

> `cluster.initial_master_nodes` is a **one-time bootstrap setting**. It must be removed from all nodes' configuration after the cluster has formed for the first time. On subsequent restarts, the cluster recovers from its persisted state — it does not re-bootstrap.

[Inference] Leaving `cluster.initial_master_nodes` in the configuration after initial bootstrap may cause unexpected behavior during restarts in some versions. The exact impact depends on the Elasticsearch version. Verify against the target version's documentation.

#### Step 6 — Cluster State Publication

The elected master publishes the initial cluster state to all nodes. Each node acknowledges receipt. The master waits for acknowledgment from a quorum before considering the publication committed.

#### Step 7 — Shard Allocation

With the cluster state established, the master begins **shard allocation** — assigning primary shards and replica shards to eligible data nodes according to allocation rules and node roles.

#### Step 8 — Cluster Becomes Operational

Once primary shards are assigned and available, the cluster accepts indexing and search requests. Cluster health transitions from `red` toward `yellow` (primaries assigned, replicas unassigned) and then `green` (all shards assigned).

---

### Discovery Configuration

#### `discovery.seed_hosts`

Lists the initial contact points for node discovery. These addresses are contacted at startup to find other cluster members.

```yaml
discovery.seed_hosts:
  - 10.0.0.1
  - 10.0.0.2:9300
  - es-node-3.internal:9300
```

For dynamic environments where node addresses change (e.g., cloud deployments, Kubernetes), Elasticsearch supports **discovery plugins** that resolve addresses dynamically:

- `discovery-ec2` — AWS EC2 tag-based discovery
- `discovery-gce` — Google Compute Engine instance group discovery
- `discovery-azure-classic` — Azure instance discovery
- `discovery-file` — file-based dynamic unicast discovery

[Inference] Discovery plugin availability and configuration details vary by version and may require separate installation. Verify plugin compatibility with the target Elasticsearch version.

#### `discovery.type: single-node`

Disables peer discovery entirely. The node forms a cluster with itself and does not seek other members. Bootstrap checks related to cluster formation are also bypassed.

```yaml
discovery.type: single-node
```

This setting is appropriate only for single-node development instances. It should never be used on a node intended to join a multi-node cluster.

#### `cluster.initial_master_nodes`

Used exclusively for first-time cluster bootstrap:

```yaml
cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3
```

Values must match the `node.name` of the corresponding master-eligible nodes exactly. After the cluster has bootstrapped, this setting must be removed.

---

### The Elected Master's Responsibilities

The elected master node is solely responsible for:

- **Cluster state changes** — only the master may modify and publish a new cluster state
- **Index management** — creating, updating, and deleting indices
- **Shard allocation** — deciding which shards go to which nodes
- **Node join and leave processing** — updating cluster membership
- **Snapshot coordination** — orchestrating snapshot operations
- **ILM execution** — triggering index lifecycle policy actions

The master does **not** handle client search or indexing requests directly (unless it also holds a data role). All cluster state modifications are serialized through the master to prevent conflicts.

---

### Cluster State Publication Protocol

When the master makes a change to the cluster state, it follows a two-phase publication protocol:

#### Phase 1 — Publish

The master sends the new cluster state (or a diff) to all nodes. Each node applies the state to its local copy and sends an acknowledgment.

#### Phase 2 — Commit

Once the master receives acknowledgments from a **quorum** of master-eligible nodes, it sends a commit message. All nodes finalize the state change.

This protocol ensures that cluster state changes are durable across a quorum of master-eligible nodes before being committed — preventing data loss if the master fails mid-publication.

[Inference] The behavior of in-flight cluster state publications during master failure depends on which phase the publication was in at the time of failure. Recovery behavior is handled by the Raft consensus layer and may not be immediately visible to operators.

---

### Master Election in Detail

#### Candidates and Voting

When no master is present — at startup or after master failure — master-eligible nodes conduct an election:

1. Each node identifies reachable master-eligible peers
2. Nodes exchange **pre-vote requests** to establish whether a quorum is reachable
3. A node that receives pre-vote responses from a quorum starts a full election
4. The node sends **vote requests** to peers, proposing itself as master
5. Peers grant their vote based on the candidate's cluster state recency
6. A node that receives votes from a quorum becomes the new master

#### Election Timing

Elections are time-bounded. If no master is elected within the configured timeout, the process restarts.

Relevant setting:

```yaml
# Time to wait for a master to be elected before retrying
discovery.election.initial_timeout: 100ms
```

[Inference] Election timing settings interact with network latency and cluster size. Default values are suitable for most deployments; tuning is rarely needed except in high-latency environments. Behavior may vary.

#### What Triggers a New Election

- The current master node stops or becomes unreachable
- Network partition separates the master from a quorum of master-eligible nodes
- The master is removed from the cluster via the voting configuration exclusions API

---

### Split-Brain and Quorum Protection

**Split-brain** occurs when two isolated groups of nodes each elect their own master and diverge independently. This leads to data inconsistency and is one of the most serious failure modes in a distributed system.

Elasticsearch's quorum requirement directly prevents split-brain:

- A master can only be elected if a **quorum** of master-eligible nodes agrees
- In a network partition, at most one partition can contain a quorum
- The partition without a quorum cannot elect a master and stops accepting cluster state changes

**Example — 3 master-eligible nodes, partition into groups of 2 and 1:**

```
Group A: node-1, node-2  → quorum of 2 (out of 3) → can elect master ✓
Group B: node-3          → only 1 node → cannot form quorum → no master ✗
```

Group B stops serving write requests that require cluster state changes. Group A continues operating. When the partition heals, node-3 rejoins Group A's master.

**Example — 2 master-eligible nodes, partition into two groups of 1:**

```
Group A: node-1  → 1 out of 2 → below quorum → no master ✗
Group B: node-2  → 1 out of 2 → below quorum → no master ✗
```

Neither partition can elect a master. The cluster becomes unavailable for writes. This demonstrates why two master-eligible nodes provide no fault tolerance.

---

### Cluster Health

Cluster health summarizes the state of shard allocation across the cluster.

```bash
GET /_cluster/health?pretty
```

**Example response:**

```json
{
  "cluster_name": "production-cluster",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 5,
  "number_of_data_nodes": 3,
  "active_primary_shards": 24,
  "active_shards": 48,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100.0
}
```

#### Health Status Definitions

|Status|Meaning|Impact|
|---|---|---|
|`green`|All primary and replica shards assigned and active|Full operation|
|`yellow`|All primaries assigned; one or more replicas unassigned|Full read/write; reduced redundancy|
|`red`|One or more primary shards unassigned|Partial data unavailability; some reads/writes fail|

#### Health Per Index

```bash
GET /_cluster/health/my-index?pretty
```

#### Waiting for a Health Status

```bash
# Block until cluster is green or timeout
GET /_cluster/health?wait_for_status=green&timeout=30s
```

Useful in automation and deployment scripts to pause until the cluster reaches a desired state.

---

### Cluster Settings

Cluster-level settings are applied across all nodes and managed through the cluster settings API — not through `elasticsearch.yml`.

```bash
GET /_cluster/settings?pretty
```

Settings are divided into two persistence categories:

|Type|Persistence|Use Case|
|---|---|---|
|`persistent`|Survives cluster restart|Long-term configuration changes|
|`transient`|Lost on full cluster restart|Temporary changes, testing|

> As of Elasticsearch 7.7, transient settings are deprecated in favor of persistent settings for most use cases. [Unverified: exact deprecation timeline across versions; verify against target version documentation.]

**Example — updating a cluster setting:**

```bash
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}
```

**Example — removing a setting (resetting to default):**

```bash
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
```

#### Setting Precedence

```
1. Transient cluster settings
2. Persistent cluster settings
3. elasticsearch.yml
4. Default values
```

---

### Node Join and Leave

#### Node Joining the Cluster

When a new node starts and contacts seed hosts:

1. It establishes a transport connection to reachable nodes
2. It sends a **join request** to the current master
3. The master validates the request (cluster name, version compatibility)
4. The master publishes an updated cluster state that includes the new node
5. The new node receives the cluster state and becomes a cluster member
6. The master may allocate shards to the new node

#### Node Leaving the Cluster

**Graceful shutdown:**

When a node is stopped cleanly (e.g., `systemctl stop elasticsearch`), it sends a leave notification to the master. The master immediately updates the cluster state and begins reallocating that node's shards.

**Ungraceful departure (failure):**

When a node stops without notification — due to crash, network failure, or hardware issue — the master detects the absence through **fault detection**.

---

### Fault Detection

The master continuously monitors all other nodes via **follower checks**. Each data/ingest/coordinating node monitors the master via **leader checks**.

#### Relevant Settings

```yaml
# How often the master pings follower nodes
cluster.fault_detection.follower_check.interval: 1s

# Timeout for each follower check
cluster.fault_detection.follower_check.timeout: 10s

# Number of consecutive failures before a node is removed
cluster.fault_detection.follower_check.retry_count: 3

# How often nodes check the master (leader check)
cluster.fault_detection.leader_check.interval: 1s

# Timeout for each leader check
cluster.fault_detection.leader_check.timeout: 10s

# Number of consecutive failures before re-election is triggered
cluster.fault_detection.leader_check.retry_count: 3
```

[Inference] Default fault detection values are designed for typical LAN environments. In high-latency or unstable network conditions, these values may need adjustment. Tuning fault detection timing involves tradeoffs between detection speed and false positives. Behavior is not guaranteed to be identical across all network environments.

After the retry threshold is exceeded, the master removes the unresponsive node from the cluster state and begins reallocating its shards.

---

### Delayed Shard Allocation

When a node leaves unexpectedly, Elasticsearch does not immediately start reallocating its shards. A **delay** is applied to avoid expensive shard reallocation when a node is expected to return shortly (e.g., after a brief network interruption or a restart).

Default delay: `1m` (one minute)

```yaml
# Index-level setting
index.unassigned.node_left.delayed_timeout: 1m
```

Override for a specific index:

```bash
PUT /my-index/_settings
{
  "index.unassigned.node_left.delayed_timeout": "5m"
}
```

Override cluster-wide for all indices:

```bash
PUT /_all/_settings
{
  "index.unassigned.node_left.delayed_timeout": "5m"
}
```

If the node returns within the delay window, its shards are reassigned to it immediately without reallocation — avoiding unnecessary data movement.

---

### Full Cluster Restart

A **full cluster restart** occurs when all nodes in the cluster are stopped and restarted simultaneously — for example, during a cluster-wide upgrade or maintenance.

During recovery from a full restart:

1. Nodes start and begin discovery
2. Master election proceeds normally
3. The master reads the cluster state from its local persistent storage
4. The master begins **gateway recovery** — recovering index metadata and shard allocation from disk
5. Data nodes load their shard data from local storage
6. Cluster health progresses from `red` → `yellow` → `green` as shards become available

#### Gateway Settings

```yaml
# Minimum number of data nodes that must join before recovery begins
gateway.recover_after_data_nodes: 2

# Wait up to this long for the required number of nodes
gateway.recover_after_time: 5m

# Expected number of data nodes in the cluster
gateway.expected_data_nodes: 3
```

These settings prevent the master from starting shard recovery too early — before enough nodes have joined to provide a complete view of the cluster's data.

[Inference] Gateway settings are most relevant for clusters where a full restart is common. For rolling restarts (one node at a time), these settings are less critical. Behavior depends on cluster topology and version.

---

### Rolling Restart

A **rolling restart** restarts one node at a time while the cluster continues to operate. This is the standard approach for applying configuration changes, upgrades, or host maintenance without downtime.

#### Procedure

**Step 1 — Disable shard allocation (optional but recommended)**

Prevents the master from reallocating shards away from the node being restarted:

```bash
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
```

**Step 2 — Perform a synced flush (Elasticsearch 7.x and earlier)**

```bash
POST /_flush/synced
```

In Elasticsearch 8.x, synced flush is no longer needed — shards use sequence numbers for faster recovery.

**Step 3 — Stop the node**

```bash
sudo systemctl stop elasticsearch
```

**Step 4 — Perform maintenance, then restart**

```bash
sudo systemctl start elasticsearch
```

**Step 5 — Wait for the node to rejoin and shards to recover**

```bash
GET /_cluster/health?wait_for_status=yellow&timeout=60s
```

**Step 6 — Re-enable shard allocation**

```bash
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
```

**Step 7 — Wait for green, then repeat for the next node**

```bash
GET /_cluster/health?wait_for_status=green&timeout=120s
```

[Inference] Rolling restart procedures may vary depending on the type of change being applied (configuration, version upgrade, OS maintenance). Version upgrades have additional requirements around upgrade order and compatibility. Always consult the version-specific upgrade documentation.

---

### Cluster UUID

Every cluster is assigned a **cluster UUID** at formation. This UUID persists across restarts and is stored in the cluster state.

```bash
GET /?pretty
```

**Response includes:**

```json
{
  "cluster_name": "production-cluster",
  "cluster_uuid": "abc123xyz..."
}
```

The cluster UUID is used internally for snapshot compatibility and cross-cluster operations. It should not change for the lifetime of a cluster.

---

### Voting Configuration

Elasticsearch 7.x introduced **voting configuration** — an explicit record of which master-eligible nodes participate in elections. This replaces the older `minimum_master_nodes` setting.

The voting configuration is maintained automatically by the master as nodes join and leave. It can be manually adjusted using the voting configuration exclusions API — for example, when decommissioning a master-eligible node.

```bash
# Exclude a node from voting (e.g., before decommissioning)
POST /_cluster/voting_config_exclusions?node_names=node-3

# Clear voting exclusions (after decommissioning is complete)
DELETE /_cluster/voting_config_exclusions
```

[Inference] Voting configuration exclusions interact with quorum size. Excluding a node reduces the effective quorum requirement, which may be necessary when permanently removing a master-eligible node. Incorrect use can reduce fault tolerance. Consult version-specific documentation for the full procedure.

---

### Useful Cluster APIs — Quick Reference

|API|Purpose|
|---|---|
|`GET /_cluster/health`|Overall cluster health and shard counts|
|`GET /_cluster/state`|Full cluster state|
|`GET /_cluster/settings`|Current persistent and transient settings|
|`PUT /_cluster/settings`|Update cluster settings|
|`GET /_cluster/stats`|Aggregate stats across all nodes|
|`GET /_cluster/pending_tasks`|Pending master-level operations|
|`GET /_cat/nodes?v`|Node list with roles and resource usage|
|`GET /_cat/master?v`|Current elected master|
|`GET /_nodes`|Detailed node information|
|`GET /_nodes/stats`|Node-level resource and operation statistics|
|`POST /_cluster/reroute`|Manually trigger shard reallocation|

---

### Common Cluster Formation Problems

|Symptom|Likely Cause|Resolution|
|---|---|---|
|Nodes do not discover each other|`discovery.seed_hosts` missing or incorrect|Verify addresses and port reachability|
|No master elected|`cluster.initial_master_nodes` missing on first boot|Add correct node names for bootstrap|
|Cluster splits into two independent clusters|`cluster.name` mismatch between nodes|Ensure all nodes share the same `cluster.name`|
|Master keeps changing (flapping)|Network instability or fault detection timeouts too low|Investigate network; adjust `fault_detection` timeouts|
|Cluster stuck in `red` after restart|Not enough nodes joined before gateway recovery started|Adjust `gateway.recover_after_data_nodes`|
|New node never joins|Firewall blocking transport port `9300`|Verify firewall rules on both source and target nodes|
|`cluster.initial_master_nodes` causes issues on restart|Setting left in config after initial bootstrap|Remove the setting after first successful cluster formation|
|Master election loops indefinitely|All master-eligible nodes unreachable from each other|Investigate network partitions; verify transport connectivity|

---

**Conclusion**

Cluster formation in Elasticsearch is a carefully orchestrated process — from seed host discovery through peer identification, master election, cluster state publication, and shard allocation. The quorum requirement is the central mechanism that prevents split-brain and maintains consistency across node failures and network partitions. Understanding the distinction between bootstrap configuration (`cluster.initial_master_nodes`) and steady-state operation, the role of fault detection and delayed allocation, and the procedures for graceful restarts and node decommissioning provides the operational foundation for maintaining a healthy Elasticsearch cluster at any scale.

**Next Steps** — shard allocation mechanics, index lifecycle management, and cluster monitoring build directly on the formation and state management concepts established here.

===END_SYLLABOT_RESPONSE_9e12b32d29ec484f===