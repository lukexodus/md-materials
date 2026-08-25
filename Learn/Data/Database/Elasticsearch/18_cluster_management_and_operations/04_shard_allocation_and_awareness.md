## Shard Allocation and Awareness

### Overview

Shard allocation is the process by which Elasticsearch decides which nodes host which shards — both primary shards and their replicas. Allocation awareness extends this with rules that make the allocator conscious of physical or logical infrastructure boundaries (racks, availability zones, data centers), so that replicas are distributed in a way that improves resilience against the failure of a single zone or rack.

### The Allocator

Shard allocation is managed by the master node, which continuously evaluates cluster state and moves shards according to a set of deciders — modular rules that each vote to allow, deny, or stay neutral on a proposed allocation. Common built-in deciders include:

- **SameShardAllocationDecider** — prevents a primary and its replica from being placed on the same node
- **DiskThresholdDecider** — blocks allocation to nodes exceeding configured disk watermarks
- **AwarenessAllocationDecider** — enforces attribute-based distribution rules (see below)
- **FilterAllocationDecider** — enforces include/exclude/require filters set via cluster or index settings
- **ShardsLimitAllocationDecider** — enforces `index.routing.allocation.total_shards_per_node` and similar caps

If any decider votes to deny, the allocation does not proceed, and Elasticsearch attempts other candidate nodes.

### Allocation Awareness

Allocation awareness uses node attributes — arbitrary key-value tags assigned to each node — to inform the allocator about physical topology. A common pattern is a `zone` attribute:

```yaml
# elasticsearch.yml on a node in zone "zone-a"
node.attr.zone: zone-a
```

The cluster is then configured to be aware of this attribute:

```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes": "zone"
  }
}
```

With this setting alone, Elasticsearch prefers to place a primary's replicas in a different zone than the primary itself, when possible — but it isn't a hard guarantee; if a zone lacks capacity, replicas can still fall back into a zone that already holds a copy.

**Forced Awareness**

To make zone-balanced allocation a hard requirement rather than a soft preference, forced awareness specifies the full set of expected zone values:

```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes": "zone",
    "cluster.routing.allocation.awareness.force.zone.values": "zone-a,zone-b"
  }
}
```

With forced awareness configured, Elasticsearch will not allocate a replica shard if doing so would leave zones unevenly represented in a way that violates the forced distribution — in a two-zone setup, this typically means a replica is left unassigned rather than being placed in the same zone as the primary if the other zone lacks room.

### Allocation Filtering

Separate from awareness, allocation filtering explicitly includes or excludes nodes based on attributes, without any concept of balancing. This is commonly used for hot-warm-cold architectures, where indices are pinned to a tier:

```
PUT logs-2026.08/_settings
{
  "index.routing.allocation.require.data": "hot"
}
```

- `require` — node must match all specified attributes
- `include` — node must match at least one of the specified attributes
- `exclude` — node must not match the specified attributes

This is the mechanism ILM's `allocate` action uses under the hood when migrating an index from the hot tier to the warm or cold tier.

### Shard Allocation Filtering vs. Awareness

| Aspect | Awareness | Allocation Filtering |
|---|---|---|
| Purpose | Spread replicas across failure domains | Pin indices/shards to specific nodes |
| Balancing behavior | Automatic, balances across attribute values | No automatic balancing — explicit include/exclude/require |
| Typical use case | Multi-AZ resilience | Hot-warm-cold tiering, dedicated node roles |
| Failure mode if unmet | Replica left unassigned (if forced) | Shard left unassigned if no node matches |

### Diagram: Awareness-Based Replica Placement

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 320" font-family="Helvetica, Arial, sans-serif">
  <text x="450" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Zone-Aware Shard Placement (svg_diagram)</text>

  
  <rect x="60" y="60" width="330" height="220" rx="10" fill="#eef6ff" stroke="#2980b9" stroke-width="1.5" />
  <text x="225" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#1f618d">zone-a</text>

  <rect x="90" y="105" width="120" height="60" rx="6" fill="#dceefb" stroke="#2980b9" />
  <text x="150" y="130" text-anchor="middle" font-size="12" fill="#1f618d">Node A1</text>
  <text x="150" y="148" text-anchor="middle" font-size="12" font-weight="bold" fill="#c0392b">P0</text>

  <rect x="230" y="105" width="120" height="60" rx="6" fill="#dceefb" stroke="#2980b9" />
  <text x="290" y="130" text-anchor="middle" font-size="12" fill="#1f618d">Node A2</text>
  <text x="290" y="148" text-anchor="middle" font-size="12" fill="#555">R1</text>

  <rect x="90" y="185" width="120" height="60" rx="6" fill="#dceefb" stroke="#2980b9" />
  <text x="150" y="210" text-anchor="middle" font-size="12" fill="#1f618d">Node A3</text>
  <text x="150" y="228" text-anchor="middle" font-size="12" fill="#555">R0</text>

  
  <rect x="500" y="60" width="330" height="220" rx="10" fill="#fdf3e7" stroke="#d4a017" stroke-width="1.5" />
  <text x="665" y="85" text-anchor="middle" font-size="14" font-weight="bold" fill="#a67c00">zone-b</text>

  <rect x="530" y="105" width="120" height="60" rx="6" fill="#fff3d6" stroke="#d4a017" />
  <text x="590" y="130" text-anchor="middle" font-size="12" fill="#a67c00">Node B1</text>
  <text x="590" y="148" text-anchor="middle" font-size="12" font-weight="bold" fill="#c0392b">P1</text>

  <rect x="670" y="105" width="120" height="60" rx="6" fill="#fff3d6" stroke="#d4a017" />
  <text x="730" y="130" text-anchor="middle" font-size="12" fill="#a67c00">Node B2</text>
  <text x="730" y="148" text-anchor="middle" font-size="12" fill="#555">R0</text>

  <rect x="530" y="185" width="120" height="60" rx="6" fill="#fff3d6" stroke="#d4a017" />
  <text x="590" y="210" text-anchor="middle" font-size="12" fill="#a67c00">Node B3</text>
  <text x="590" y="228" text-anchor="middle" font-size="12" fill="#555">R1</text>

  <text x="450" y="300" text-anchor="middle" font-size="11" fill="#666">P0/P1 = primaries; R0/R1 = corresponding replicas placed in the opposite zone</text>
</svg>

### Practical Notes

- Node attributes are set per-node in `elasticsearch.yml` (or via `-E` startup flags) and are immutable while the node is running; changing them requires a node restart.
- Awareness attributes are not limited to `zone`; multi-dimensional awareness (e.g., `rack_id` and `zone` simultaneously) is supported by supplying a comma-separated attribute list.
- The `cluster.routing.allocation.total_shards_per_node` setting can interact with awareness and filtering — an overly restrictive cap can cause shards to remain unassigned even when awareness/filtering rules would otherwise be satisfiable.
- Shard allocation decisions can be inspected directly using `GET _cluster/allocation/explain`, which reports which deciders voted against a given shard and why.

[Inference] In practice, teams running multi-AZ deployments on cloud infrastructure generally map the `zone` attribute directly to the cloud provider's availability zone identifier, since this aligns Elasticsearch's replica-spreading logic with the underlying infrastructure's actual failure domains — though the specific attribute-to-AZ mapping strategy can vary depending on deployment tooling (e.g., ECK, Terraform modules, manual provisioning).

### Common Pitfalls

- Enabling awareness without forced awareness and assuming replicas are guaranteed to be zone-separated — the soft preference can be overridden by capacity constraints.
- Forgetting to update `cluster.routing.allocation.awareness.force.zone.values` when adding a new zone, causing the allocator to be unaware the new zone exists as a valid target.
- Using allocation filtering (`require`/`include`/`exclude`) as a substitute for awareness in a resilience context — filtering has no inherent balancing behavior and will happily place all replicas in a single matching zone if that's where capacity is available.
- Setting conflicting `require` filters at the index and cluster level, leading to consistently unassigned shards that are difficult to diagnose without `_cluster/allocation/explain`.
- Not accounting for awareness when scaling down a zone — forced awareness can leave shards unassigned if a zone temporarily has no eligible nodes.

**Related Topics**
- Cluster Allocation Explain API
- Disk-Based Shard Allocation (Watermarks)
- Hot-Warm-Cold Architecture
- Index Lifecycle Management (ILM)
- Cluster Settings API (persistent vs. transient)