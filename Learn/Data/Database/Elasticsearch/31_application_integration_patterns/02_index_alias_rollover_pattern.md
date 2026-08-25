## Index Alias Rollover Pattern

### Overview

The rollover pattern is a technique for managing time-series or continuously-growing data by writing to a single alias while Elasticsearch periodically creates new backing indices behind that alias once defined conditions are met. Instead of one index growing indefinitely, data is split across multiple appropriately-sized indices while applications continue writing to a stable, unchanging alias name.

This pattern underlies most log, metrics, and event-ingestion architectures in Elasticsearch, and forms the foundation of Data Streams, which are effectively a managed abstraction over this same alias-rollover mechanism.

### Why Rollover Exists

A single index that grows without bound eventually causes problems:

- Shard sizes become unwieldy, degrading indexing and query performance
- Merges become more expensive as segment sizes grow
- Restoring, reindexing, or deleting old data (e.g. for retention) requires expensive document-level operations instead of cheap index deletion
- Mapping changes become harder to reason about across a mixed-age dataset

Rollover solves this by keeping each backing index within a target size, document count, or age, and by making retention a matter of deleting whole indices rather than querying and deleting individual documents.

### Core Concepts

**Write alias**: An alias with `"is_write_index": true` pointing to exactly one index — the one currently receiving writes. Applications index documents against the alias, not the concrete index name.

**Read alias (optional)**: A separate alias, or the same alias without the write flag restriction, used for queries across all backing indices. In practice, a single alias is often used for both reading and writing, with the write index distinguished by the `is_write_index` flag.

**Backing/generation index**: A concrete index following a naming convention with a sequence number, typically `<name>-000001`, `<name>-000002`, and so on. Elasticsearch increments this suffix automatically on rollover if the naming pattern ends in digits.

**Rollover conditions**: Thresholds — such as max age, max size, max document count, or max primary shard size — that, when met, trigger creation of a new backing index and reassignment of the write alias to it.

### Manual Setup

**Step 1 — Create the initial index with an alias**

```json
PUT /logs-app-000001
{
  "aliases": {
    "logs-app": {
      "is_write_index": true
    }
  }
}
```

**Step 2 — Index documents against the alias**

```json
POST /logs-app/_doc
{
  "message": "user login succeeded",
  "@timestamp": "2026-08-25T10:00:00Z"
}
```

The application never references `logs-app-000001` directly; it only knows about `logs-app`.

**Step 3 — Trigger rollover**

```json
POST /logs-app/_rollover
{
  "conditions": {
    "max_age": "7d",
    "max_docs": 50000000,
    "max_primary_shard_size": "50gb"
  }
}
```

If any one condition is met, Elasticsearch:

1. Creates a new index, `logs-app-000002`
2. Removes `is_write_index: true` from `logs-app-000001`
3. Sets `is_write_index: true` on `logs-app-000002`

Conditions are evaluated as OR, not AND — meeting any single condition is sufficient to trigger rollover.

**Key Points**

- Rollover is not automatic on its own; calling `_rollover` manually only rolls over if conditions are satisfied, otherwise it is a no-op
- Automation requires either Index Lifecycle Management (ILM) or an external scheduler (e.g., a cron job hitting `_rollover`)
- The index name must end in a number for auto-incrementing (`-000001` convention), or `_rollover` requires an explicit target index name via the request body

### Automating with ILM

Manually polling and calling `_rollover` is fragile. Index Lifecycle Management automates this by attaching a policy to the write index that periodically checks rollover conditions and lifecycle phase transitions (hot → warm → cold → frozen → delete).

```json
PUT _ilm/policy/logs-app-policy
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
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

The index template then references this policy and the write alias:

```json
PUT _index_template/logs-app-template
{
  "index_patterns": ["logs-app-*"],
  "template": {
    "settings": {
      "index.lifecycle.name": "logs-app-policy",
      "index.lifecycle.rollover_alias": "logs-app"
    }
  }
}
```

With this in place, ILM checks rollover conditions in the background (by default, roughly every 10 minutes, though this interval [Unverified — configurable via `indices.lifecycle.poll_interval`, worth confirming against the running cluster version] can be tuned) and performs the rollover, phase transitions, and eventual deletion without manual intervention.

### Relationship to Data Streams

Data streams formalize this exact pattern. Rather than the user manually managing the alias and `is_write_index` flags, a data stream:

- Automatically creates and names backing indices using a hidden, internally-managed naming scheme (`.ds-<stream>-<generation>`)
- Exposes a single logical name for both reads and writes
- Requires an index template with `"data_stream": {}` defined, rather than manual alias bootstrapping

Data streams are generally preferred for new time-series use cases because they remove the bootstrapping boilerplate above and prevent common misconfigurations (e.g., forgetting `is_write_index`, or accidentally writing to a non-write backing index). The manual alias-rollover pattern remains relevant for understanding what happens underneath data streams, for non-time-series use cases needing rollover-like behavior, or for clusters on versions predating mature data stream support.

### Querying Across Generations

Because the alias spans all backing indices (write and non-write), search queries against the alias transparently query all generations:

```json
GET /logs-app/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "now-1d/d"
      }
    }
  }
}
```

This works identically whether there is one backing index or fifty, since the alias resolves to the full set at query time.

### Rollover Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
<text x="380" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Index Alias Rollover Flow (svg_diagram)</text>
<rect x="40" y="70" width="180" height="70" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
<text x="130" y="98" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">logs-app-000001</text>
<text x="130" y="118" text-anchor="middle" font-size="11" fill="#555">is_write_index: true</text>
<rect x="290" y="70" width="180" height="70" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="380" y="98" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">_rollover API</text>
<text x="380" y="118" text-anchor="middle" font-size="11" fill="#555">conditions checked</text>
<rect x="540" y="70" width="180" height="70" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
<text x="630" y="98" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">logs-app-000002</text>
<text x="630" y="118" text-anchor="middle" font-size="11" fill="#555">is_write_index: true</text>
<line x1="220" y1="105" x2="285" y2="105" stroke="#888" stroke-width="1.5" marker-end="url(#arrow1)" />
<line x1="470" y1="105" x2="535" y2="105" stroke="#888" stroke-width="1.5" marker-end="url(#arrow1)" />
<rect x="40" y="190" width="680" height="60" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
<text x="380" y="215" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">alias: logs-app</text>
<text x="380" y="235" text-anchor="middle" font-size="11" fill="#555">points to ALL backing indices for reads; only current generation for writes</text>
<line x1="130" y1="140" x2="130" y2="190" stroke="#888" stroke-width="1.2" stroke-dasharray="4,3" />
<line x1="630" y1="140" x2="630" y2="190" stroke="#888" stroke-width="1.2" stroke-dasharray="4,3" />

<text x="380" y="290" text-anchor="middle" font-size="11" fill="#777">After rollover: write_index flag moves; both indices remain searchable via the alias</text>

</svg>

### Common Pitfalls

- **Writing directly to a backing index**: If an application indexes against `logs-app-000001` by name instead of the `logs-app` alias, documents may land in a non-write-flagged index or bypass rollover logic entirely, since only the alias's designated write index accepts unconditioned writes cleanly across rollovers.
- **Non-numeric or malformed index suffixes**: Rollover's auto-increment relies on a parseable numeric suffix (e.g. `-000001`); deviating from this requires manually specifying the new index name on every rollover call.
- **Forgetting `is_write_index`**: Without it, an alias pointing to multiple indices with ambiguous write eligibility causes indexing requests to fail once more than one index is aliased.
- **Orphaned old indices**: Rollover alone does not delete old backing indices — it only stops writing to them. Retention/deletion must be handled separately (via ILM's delete phase, Curator, or manual cleanup), or storage grows unbounded despite rollover being "in place."

### Conclusion

The index alias rollover pattern decouples the logical name applications use from the physical indices Elasticsearch manages underneath, enabling bounded index sizes, cheap retention via whole-index deletion, and uninterrupted application-side write targeting. While data streams now provide a managed wrapper around this same mechanism for most time-series workloads, understanding the raw alias-and-rollover primitives remains essential for debugging, custom retention logic, and non-standard use cases.

**Related Topics**

- Data Streams and their internal backing index management
- Index Lifecycle Management (ILM) phases: hot, warm, cold, frozen, delete
- Shrink and Force Merge actions during warm/cold phase transitions
- Snapshot lifecycle management (SLM) integration with ILM
- Index templates and composable template precedence
- Reindexing strategies for backfilling or correcting rolled-over data