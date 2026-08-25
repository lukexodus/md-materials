## Hot-Warm-Cold Architecture

### Overview

Hot-warm-cold architecture is a data tiering pattern for time-series workloads in which indices move through progressively cheaper, lower-performance hardware tiers as they age and are queried less frequently. It combines node role assignment, shard allocation filtering, and (typically) ILM automation to route indices to the appropriate tier over their lifetime, aligning infrastructure cost with actual access patterns.

### The Tiers

- **Hot** — actively written and frequently queried; runs on the fastest, most expensive hardware (typically local SSD/NVMe storage, higher CPU/memory)
- **Warm** — no longer written to, but still queried with some regularity; runs on less performant, often larger and cheaper storage
- **Cold** — rarely queried; optimized for minimal storage cost, frequently backed by searchable snapshots rather than fully replicated local shard copies
- **Frozen** (an extension of this model) — data that is almost never queried, kept accessible primarily for compliance/retention, using searchable snapshots with minimal local caching

Not every deployment uses all tiers; a two-tier hot-warm setup is common for moderate retention needs, while regulated industries with long retention requirements more often use the full hot-warm-cold-frozen progression.

### Node Role Assignment

Each node is assigned to a tier via its data role:

```yaml
# Hot tier node
node.roles: [ data_hot, data_content ]

# Warm tier node
node.roles: [ data_warm ]

# Cold tier node
node.roles: [ data_cold ]

# Frozen tier node
node.roles: [ data_frozen ]
```

These are distinct from the generic `data` role — using tier-specific roles allows Elasticsearch's built-in **data tier allocation** feature to automatically route indices to the correct tier based on ILM phase, without requiring manually written allocation filters for every index.

### Automatic Data Tier Allocation

When index tier-based roles are used, Elasticsearch automatically applies allocation preferences based on the `_tier_preference` index setting, which ILM manages as an index moves through phases:

```
GET logs-2026.08/_settings?filter_path=**.index.routing.allocation.include._tier_preference
```

This largely removes the need for manually specified `index.routing.allocation.require.data: warm`-style settings (the older, manually managed pattern using generic `data` attributes), though that manual pattern remains valid and is still seen in older or hand-rolled deployments.

### Tier Progression Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 300" font-family="Helvetica, Arial, sans-serif">
  <text x="450" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Hot-Warm-Cold-Frozen Tier Progression (svg_diagram)</text>

  <rect x="30" y="70" width="190" height="110" rx="8" fill="#fde2e1" stroke="#c0392b" stroke-width="1.5" />
  <text x="125" y="100" text-anchor="middle" font-size="14" font-weight="bold" fill="#c0392b">Hot</text>
  <text x="125" y="122" text-anchor="middle" font-size="11" fill="#333">SSD/NVMe</text>
  <text x="125" y="140" text-anchor="middle" font-size="11" fill="#333">write + query</text>
  <text x="125" y="158" text-anchor="middle" font-size="11" fill="#333">highest cost</text>

  <rect x="250" y="70" width="190" height="110" rx="8" fill="#fff3d6" stroke="#d4a017" stroke-width="1.5" />
  <text x="345" y="100" text-anchor="middle" font-size="14" font-weight="bold" fill="#a67c00">Warm</text>
  <text x="345" y="122" text-anchor="middle" font-size="11" fill="#333">read-only</text>
  <text x="345" y="140" text-anchor="middle" font-size="11" fill="#333">queried occasionally</text>
  <text x="345" y="158" text-anchor="middle" font-size="11" fill="#333">shrink, forcemerge</text>

  <rect x="470" y="70" width="190" height="110" rx="8" fill="#dceefb" stroke="#2980b9" stroke-width="1.5" />
  <text x="565" y="100" text-anchor="middle" font-size="14" font-weight="bold" fill="#1f618d">Cold</text>
  <text x="565" y="122" text-anchor="middle" font-size="11" fill="#333">searchable snapshot</text>
  <text x="565" y="140" text-anchor="middle" font-size="11" fill="#333">rarely queried</text>
  <text x="565" y="158" text-anchor="middle" font-size="11" fill="#333">low storage cost</text>

  <rect x="690" y="70" width="190" height="110" rx="8" fill="#e6e6e6" stroke="#555" stroke-width="1.5" />
  <text x="785" y="100" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Frozen</text>
  <text x="785" y="122" text-anchor="middle" font-size="11" fill="#333">fully snapshot-backed</text>
  <text x="785" y="140" text-anchor="middle" font-size="11" fill="#333">minimal local cache</text>
  <text x="785" y="158" text-anchor="middle" font-size="11" fill="#333">lowest cost</text>

  <line x1="220" y1="125" x2="248" y2="125" stroke="#555" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="440" y1="125" x2="468" y2="125" stroke="#555" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="660" y1="125" x2="688" y2="125" stroke="#555" stroke-width="2" marker-end="url(#arrow2)" />

  <text x="450" y="220" text-anchor="middle" font-size="11" fill="#666">ILM drives transitions between tiers based on index age since rollover</text>
</svg>

### ILM Integration

Hot-warm-cold is almost always implemented in combination with ILM, since manually moving hundreds or thousands of time-series indices between tiers on a schedule isn't practical. A typical ILM policy references each phase, and Elasticsearch translates that phase into a `_tier_preference` setting automatically:

```json
{
  "policy": {
    "phases": {
      "hot": {
        "actions": { "rollover": { "max_age": "1d" }, "set_priority": { "priority": 100 } }
      },
      "warm": {
        "min_age": "7d",
        "actions": { "shrink": { "number_of_shards": 1 }, "forcemerge": { "max_num_segments": 1 } }
      },
      "cold": {
        "min_age": "30d",
        "actions": { "searchable_snapshot": { "snapshot_repository": "cold_repo" } }
      },
      "frozen": {
        "min_age": "90d",
        "actions": { "searchable_snapshot": { "snapshot_repository": "frozen_repo" } }
      },
      "delete": {
        "min_age": "365d",
        "actions": { "delete": {} }
      }
    }
  }
}
```

### Why Tiering Reduces Cost

The underlying rationale is that most time-series data access is heavily skewed toward recency — recent logs and metrics are queried far more often than data from months prior. Provisioning every node with hot-tier-grade hardware to hold data that's rarely accessed wastes resources; tiering allows the expensive, high-performance capacity to be sized only for the actively hot portion of the dataset, with cheaper storage handling the much larger but less frequently accessed remainder.

[Inference] The specific cost savings from a given hot-warm-cold configuration depend heavily on data volume, retention requirements, query patterns, and the underlying cloud or on-premises infrastructure pricing — general guidance describes the pattern's rationale, but actual sizing and cost modeling requires benchmarking a specific dataset and workload rather than relying on general figures.

### Practical Notes

- Data tier roles (`data_hot`, `data_warm`, `data_cold`, `data_frozen`) can be combined with `data_content` on the same node for smaller clusters where dedicated tier separation isn't justified, though this reduces the resource isolation benefit tiering is meant to provide.
- Searchable snapshots (used heavily in the cold and frozen tiers) require a configured snapshot repository and shift most of the storage cost to object storage (e.g., S3-compatible storage) rather than attached node disks.
- The `_tier_preference` setting supports fallback — an index preferring `data_warm` will fall back to `data_hot` if no warm nodes are available, rather than failing to allocate outright.
- Migrating an existing manually-tiered cluster (using generic `data` role plus custom attributes) to the built-in data tier roles is a distinct migration effort and isn't automatic.

### Common Pitfalls

- Under-provisioning warm or cold tier nodes relative to the volume of data that will eventually migrate there, since the tiers accumulate all historical data still within the retention period, not just the most recent slice.
- Skipping `forcemerge` before moving to warm/cold, leaving indices with many small segments that waste storage and slow down the eventual searchable snapshot creation.
- Assuming cold tier means "unavailable" — cold-tier searchable snapshot–backed indices remain queryable, just with different latency and resource-usage characteristics than hot-tier local shards.
- Not aligning ILM `min_age` thresholds with actual query patterns, causing data to move to a slower tier while it's still being queried frequently, or conversely staying on expensive hot hardware long after query volume has dropped.
- Mixing generic `data` role nodes with tier-specific role nodes without understanding the resulting allocation behavior, leading to unpredictable placement.

**Related Topics**
- Index Lifecycle Management (ILM)
- Shard Allocation and Awareness
- Searchable Snapshots
- Snapshot and Restore
- Cluster Settings (Transient vs. Persistent)