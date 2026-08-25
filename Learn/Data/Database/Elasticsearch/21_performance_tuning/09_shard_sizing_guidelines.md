## Shard Sizing Guidelines

### Overview

Shard sizing is one of the highest-leverage decisions in an Elasticsearch deployment. Too many small shards waste cluster overhead; too few large shards slow recovery, rebalancing, and can strain heap. There is no universal "correct" number — sizing depends on data volume, query patterns, hardware, and operational requirements — but a set of well-established guidelines constrains the reasonable range.

### Why Shard Count and Size Matter

Every shard is a separate Lucene index, and each carries fixed overhead: file handles, memory for segment metadata, thread pool resources, and cluster state entries that every node must track. A cluster with thousands of tiny shards spends disproportionate resources on overhead rather than useful work. Conversely, a small number of very large shards makes recovery after a node failure slow, complicates rebalancing, and can concentrate too much of a query's work onto too few threads.

### The General Size Target

**Key Points**
- A commonly cited target is roughly 10–50 GB per shard, though this range is a starting heuristic, not a hard rule.
- [Inference] Search-heavy use cases often trend toward the smaller end of that range for faster query latency and finer-grained parallelism, while log/time-series use cases often trend toward the larger end to reduce shard count and overhead.
- Shards larger than 50 GB are not inherently broken but recovery time, rebalancing time, and the impact of losing a node all scale with shard size, so very large shards increase operational risk.
- Shards far below 1 GB (a few MB, or empty) indicate the sharding strategy is too fine-grained for the actual data volume.

### The 20-Shards-Per-GB-of-Heap Rule of Thumb

A frequently cited heap-based guideline: keep the total shard count on a node to roughly 20 shards or fewer per GB of heap allocated to that node.

$$\text{max\_shards\_per\_node} \approx 20 \times \text{heap\_GB}$$

For example, a node with 30 GB of heap would target roughly 600 shards or fewer. [Unverified] This ratio is a heuristic published as general guidance rather than a hard limit enforced by Elasticsearch itself, and the safe number varies with mapping complexity, segment count, and query load, so it should be treated as a starting point for capacity planning rather than a precise ceiling.

### Primary and Replica Shard Count

**Key Points**
- The number of primary shards for an index is fixed at creation time (via `index.number_of_shards`) and cannot be changed without reindexing or using the split/shrink APIs.
- Replica count (`index.number_of_replicas`) can be changed dynamically at any time.
- Over-sharding "for future growth" is a common mistake — since primary shard count is hard to change, it's tempting to set it high up front, but this locks in overhead that may never be needed. The split API mitigates this risk for indices that turn out to need more shards.

```json
PUT my-index
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}
```

### Sizing for Time-Series / Log Data (ILM-Managed Indices)

**Key Points**
- Time-series workloads (logs, metrics) typically use rolling indices managed by Index Lifecycle Management (ILM), where a new index is created on a schedule or size/age threshold via rollover.
- The rollover API lets shard sizing target actual data volume rather than a calendar guess, since the index rolls over when it hits a size, document count, or age condition rather than at a fixed time boundary regardless of actual ingest volume.

```json
PUT _ilm/policy/logs-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_primary_shard_size": "50gb",
            "max_age": "7d"
          }
        }
      }
    }
  }
}
```

- `max_primary_shard_size` targets the per-shard size guideline directly, rolling over before any single primary shard grows past the threshold.
- `max_age` provides a time-based backstop so low-volume indices still roll over periodically, keeping index and shard counts manageable even during quiet periods.

### Single-Shard Indices for Small Datasets

For indices that will never grow large — reference data, lookup tables, small configuration indices — a single primary shard is often sufficient. Splitting small datasets across multiple shards adds coordination overhead (scatter-gather across shards, per-shard aggregation merging) without a corresponding performance benefit, since there isn't enough data for parallelism to pay off.

### Relationship Between Shard Count and Search Performance

**Key Points**
- A search request against an index is distributed to a copy of every shard (primary or replica) and the results are merged (scatter-gather), so more shards mean more parallel units of work, up to the point where per-shard overhead and network/merge cost dominate.
- Too many shards on a small dataset means each shard holds too little data to justify the coordination overhead of querying it.
- Too few shards on a large dataset means each shard becomes a serial bottleneck, since a single shard is searched by a single thread per query.
- [Inference] The ideal shard count for search latency is generally the smallest count that still lets each shard's data and query concurrency needs be handled by the available node resources, though the specific optimum depends on node CPU, data volume, and query complexity, and is typically found empirically through benchmarking rather than calculated in advance.

### Diagram: How Shard Count Affects Search Fan-Out

<svg width="100%" viewBox="0 0 680 340" role="img"><title>Search fan-out across shards (svg_diagram)</title><desc>A coordinating node fans a search request out to multiple shards in parallel, then merges the per-shard results back into a single response.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="250" y="30" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="50" text-anchor="middle" dominant-baseline="central">Coordinating node</text>
<text class="ts" x="340" y="70" text-anchor="middle" dominant-baseline="central">Receives search request</text>
</g>

<line x1="300" y1="86" x2="120" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="330" y1="86" x2="280" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="350" y1="86" x2="400" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="380" y1="86" x2="560" y2="150" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="40" y="150" width="160" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="120" y="172" text-anchor="middle" dominant-baseline="central">Shard 0</text>
</g>
<g class="node c-teal">
<rect x="200" y="150" width="160" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="280" y="172" text-anchor="middle" dominant-baseline="central">Shard 1</text>
</g>
<g class="node c-teal">
<rect x="360" y="150" width="80" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="400" y="172" text-anchor="middle" dominant-baseline="central">Shard 2</text>
</g>
<g class="node c-teal">
<rect x="480" y="150" width="160" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="560" y="172" text-anchor="middle" dominant-baseline="central">Shard 3</text>
</g>

<line x1="120" y1="194" x2="300" y2="250" class="arr" marker-end="url(#arrow)" />
<line x1="280" y1="194" x2="325" y2="250" class="arr" marker-end="url(#arrow)" />
<line x1="400" y1="194" x2="355" y2="250" class="arr" marker-end="url(#arrow)" />
<line x1="560" y1="194" x2="380" y2="250" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="250" y="250" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="270" text-anchor="middle" dominant-baseline="central">Merge results</text>
<text class="ts" x="340" y="290" text-anchor="middle" dominant-baseline="central">Sort, dedupe, return</text>
</g>
</svg>

### Practical Sizing Checklist

- Measure actual document size and expected daily/monthly ingest volume before setting shard counts, rather than guessing.
- Prefer fewer, larger shards within the 10–50 GB guideline over many small shards, especially for indices that don't benefit from extra parallelism.
- Use rollover with `max_primary_shard_size` for time-series data instead of manually calculating shard counts per index.
- Monitor `_cat/shards` and `_cat/allocation` regularly to catch shard imbalance or oversized shards before they become operational problems.
- Keep total shard count per node within the heap-based rule of thumb, adjusting downward if nodes show heap pressure at the calculated ceiling.
- Use the shrink API to reduce shard count on indices that turn out to be over-sharded, and the split API to increase shard count on indices that turn out to be under-sharded.

### Related Topics

- **Rollover and Index Lifecycle Management (ILM)** phases in depth (hot, warm, cold, frozen, delete)
- **The shrink and split APIs** — mechanics, requirements, and constraints
- **Cluster state size and its relationship to total shard count** across all indices
- **Segment merging and the effect of merge policy on effective shard size over time**
- **Searchable snapshots and frozen tier storage** as an alternative to keeping all shards fully allocated on hot nodes
- **Data streams** as the modern abstraction layered over rollover-managed backing indices