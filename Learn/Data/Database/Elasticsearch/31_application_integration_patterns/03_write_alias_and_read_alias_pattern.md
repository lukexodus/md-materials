## Write Alias and Read Alias Pattern

### Overview

The write/read alias pattern separates the alias applications use for indexing new documents from the alias (or aliases) used for querying. Although a single alias can serve both roles, explicitly splitting them gives finer control over blue-green reindexing, zero-downtime mapping changes, gradual rollout of new index generations, and controlled exposure of data subsets to different consumers.

This pattern is closely related to the rollover pattern but addresses a distinct problem: rollover manages *how many* indices exist over time, while write/read alias separation manages *which* indices are exposed to *which* operation type (write vs. read) and to *which* consumers.

### Core Concepts

**Write alias**: Points to exactly one concrete index at any given time, flagged with `"is_write_index": true`. All indexing requests against this alias land in that single index.

**Read alias**: Points to one or more concrete indices, none of which need the `is_write_index` flag. Queries against this alias search across every index it resolves to.

**Filtered alias**: A read alias variant that applies a query filter, restricting which documents within the underlying indices are visible through that alias — useful for multi-tenant scoping or exposing a subset of fields/documents to specific consumers.

Unlike rollover, which is inherently about a single evolving alias, this pattern is often used to manage a **transition between two entirely different index structures** — such as a mapping change requiring reindexing, or migrating from one sharding strategy to another.

### Basic Setup

**Single index behind separate write and read aliases**

```json
PUT /products-v1
{
  "aliases": {
    "products-write": {
      "is_write_index": true
    },
    "products-read": {}
  }
}
```

Applications that index new documents target `products-write`; applications that query target `products-read`. At this stage both resolve to the same physical index, but the separation is already in place structurally.

### Why Separate Them Even When Pointing to the Same Index

- **Decoupling intent**: Code that writes and code that reads express their purpose through the alias name itself, making index topology changes safer to reason about
- **Independent migration**: The write alias can be repointed to a new index the moment reindexing starts, while the read alias continues serving the old index until the new one is verified and caught up
- **Access control**: In deployments using field- or document-level security, a read-only alias can carry a role restriction that a write alias should not

### Blue-Green Reindex Using Both Aliases

This is the primary practical application of the pattern — performing a mapping change or reindex with zero application-visible downtime.

**Step 1 — Current state**

```json
GET /_alias/products-write
```

Both `products-write` and `products-read` point to `products-v1`.

**Step 2 — Create the new index with corrected mappings**

```json
PUT /products-v2
{
  "mappings": {
    "properties": {
      "price": { "type": "scaled_float", "scaling_factor": 100 }
    }
  }
}
```

**Step 3 — Reindex existing data into the new index**

```json
POST /_reindex
{
  "source": { "index": "products-v1" },
  "dest": { "index": "products-v2" }
}
```

**Step 4 — Atomically switch both aliases**

```json
POST /_aliases
{
  "actions": [
    { "remove": { "index": "products-v1", "alias": "products-write" } },
    { "add": { "index": "products-v2", "alias": "products-write", "is_write_index": true } },
    { "remove": { "index": "products-v1", "alias": "products-read" } },
    { "add": { "index": "products-v2", "alias": "products-read" } }
  ]
}
```

The `_aliases` endpoint applies all actions atomically — consumers never observe a state where the alias points to nothing or to both indices ambiguously mid-switch.

**Key Points**

- Splitting the switch into two phases (write cutover first, brief delta reindex, then read cutover) allows catching any documents written to `products-v1` between step 3 and step 4, avoiding data loss during migration
- Old index (`products-v1`) is typically kept for a rollback window before deletion
- This pattern predates and is more manually-controlled than using the Reindex API's built-in slicing or ILM's own migration tooling, but remains widely used for its explicitness

### Multi-Index Read Alias

A read alias is not limited to one index; it can span several, which is useful when consumers should query across historical and current data simultaneously without needing rollover semantics:

```json
POST /_aliases
{
  "actions": [
    { "add": { "index": "products-v1", "alias": "products-read" } },
    { "add": { "index": "products-v2", "alias": "products-read" } }
  ]
}
```

Both indices are searched when `products-read` is queried, while `products-write` still points only to `products-v2`.

### Filtered Read Aliases

Read aliases can apply a filter, restricting visible documents without duplicating data or requiring separate indices per tenant:

```json
PUT /orders/_alias/orders-region-eu
{
  "filter": {
    "term": {
      "region": "eu"
    }
  }
}
```

Queries against `orders-region-eu` only ever see documents where `region` equals `eu`, even though the underlying index contains all regions. Combined with security roles that restrict an API key or user to a filtered alias, this becomes a lightweight multi-tenancy mechanism [Inference — effective enforcement of this as a security boundary depends on correctly restricting direct access to the underlying concrete index via role definitions, not solely on the filtered alias existing].

### Combining with Rollover

Write/read separation composes naturally with rollover. In the standard rollover setup, the same alias name commonly serves both roles (`is_write_index: true` marks the current generation, while the alias overall spans all generations for reads). But nothing prevents using genuinely distinct alias names:

```json
PUT /logs-app-000001
{
  "aliases": {
    "logs-app-write": {
      "is_write_index": true
    },
    "logs-app-read": {}
  }
}
```

On each rollover, only `logs-app-write` needs its `is_write_index` flag moved to the new backing index; `logs-app-read` simply needs the new index added to its set (which the `_rollover` API can do automatically if configured with matching alias names, or manually via `_aliases` if using genuinely separate names).

### Write/Read Alias Topology

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 380">
<text x="380" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Write Alias / Read Alias Topology (svg_diagram)</text>
<rect x="300" y="60" width="160" height="55" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
<text x="380" y="92" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Application</text>
<rect x="80" y="160" width="180" height="55" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="170" y="192" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">products-write</text>
<rect x="500" y="160" width="180" height="55" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
<text x="590" y="192" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">products-read</text>
<rect x="120" y="280" width="150" height="55" rx="6" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" />
<text x="195" y="312" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">products-v2</text>
<rect x="460" y="280" width="150" height="55" rx="6" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" stroke-dasharray="4,3" />
<text x="535" y="305" text-anchor="middle" font-size="11" fill="#555">products-v1</text>
<text x="535" y="320" text-anchor="middle" font-size="10" fill="#999">(rollback window)</text>
<line x1="340" y1="115" x2="200" y2="160" stroke="#888" stroke-width="1.5" marker-end="url(#arrow2)" />
<line x1="420" y1="115" x2="560" y2="160" stroke="#888" stroke-width="1.5" marker-end="url(#arrow2)" />
<line x1="195" y1="215" x2="195" y2="280" stroke="#888" stroke-width="1.5" marker-end="url(#arrow2)" />
<line x1="560" y1="215" x2="220" y2="280" stroke="#888" stroke-width="1.5" marker-end="url(#arrow2)" />
<line x1="620" y1="215" x2="560" y2="280" stroke="#888" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arrow2)" />

<text x="380" y="360" text-anchor="middle" font-size="11" fill="#777">Writes target v2 only; reads span v2 (and optionally v1 during transition)</text>

</svg>

### Common Pitfalls

- **Assuming a single alias name handles both roles safely by default**: An alias with more than one index and no `is_write_index` set anywhere causes writes against it to fail once ambiguity exists; conversely, an alias with `is_write_index` on an old index left behind after migration silently routes new writes to stale data.
- **Non-atomic manual switching**: Removing and re-adding aliases as separate API calls (rather than a single `_aliases` request with multiple actions) introduces a window where the alias temporarily resolves to nothing or to the wrong index.
- **Forgetting the delta reindex**: Documents written between the start of a bulk reindex and the alias cutover are missed unless a second, narrower reindex (e.g. filtered by timestamp) captures the gap before or during cutover.
- **Filtered alias treated as a hard security boundary alone**: A filtered read alias restricts what a query *returns*, but does not by itself prevent access to the underlying concrete index if a client has broader index-level permissions; it must be paired with role-based access control for genuine isolation.

### Conclusion

Separating write and read aliases turns index topology changes — mapping fixes, reindex migrations, tenant-scoped views — into operations that are invisible to application code, since the alias names themselves never change even as the concrete indices behind them do. This pattern is foundational to zero-downtime reindexing workflows and composes cleanly with both rollover and filtered aliasing for more advanced access-control scenarios.

**Related Topics**

- Reindex API: slicing, throttling, and script-based transforms during reindex
- Zero-downtime mapping changes and field type migrations
- Filtered aliases for multi-tenancy and role-based document-level security
- Index Lifecycle Management (ILM) and its interaction with custom alias naming
- `_aliases` API atomic action batching
- Alias-based blue-green deployment strategies beyond Elasticsearch (general pattern parallels)