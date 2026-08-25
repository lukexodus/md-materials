## Index Aliases

---

### What Are Index Aliases?

An index alias is a secondary name that points to one or more indices. From the perspective of a client application, an alias behaves identically to a real index — it accepts search requests, indexing requests, and most other operations. The underlying index or indices are abstracted away behind the alias name.

Aliases serve several purposes: decoupling application code from physical index names, enabling zero-downtime reindexing, routing queries across multiple indices, and applying persistent filters to a subset of documents within an index.

---

### Types of Aliases

Elasticsearch supports two alias management APIs:

- **Index aliases** (`_alias` / `_aliases` API) — aliases on standard indices
- **Data stream aliases** — aliases that point to data streams; covered separately in data stream documentation

This topic covers index aliases.

---

### Creating an Alias

#### At Index Creation Time

Aliases can be defined in the index creation request:

```json
PUT /logs-2024-01
{
  "aliases": {
    "logs_current": {},
    "logs_all":     {}
  }
}
```

#### After Index Creation — Single Alias

```json
PUT /logs-2024-01/_alias/logs_current
```

#### After Index Creation — Using the `_aliases` Action API

The `_aliases` API accepts an `actions` array, allowing multiple alias operations to be performed atomically in a single request.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "logs-2024-01",
        "alias": "logs_current"
      }
    }
  ]
}
```

---

### Alias Pointing to Multiple Indices

An alias can reference more than one index simultaneously. Search requests against the alias are distributed across all referenced indices.

```json
POST /_aliases
{
  "actions": [
    { "add": { "index": "logs-2024-01", "alias": "logs_all" } },
    { "add": { "index": "logs-2024-02", "alias": "logs_all" } },
    { "add": { "index": "logs-2024-03", "alias": "logs_all" } }
  ]
}
```

```json
GET /logs_all/_search
{
  "query": { "match_all": {} }
}
```

This query searches across all three indices transparently. Wildcard index patterns (`logs-2024-*`) can also be used in alias definitions.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "logs-2024-*",
        "alias": "logs_all"
      }
    }
  ]
}
```

---

### Write Index

When an alias points to multiple indices, indexing requests to that alias are ambiguous — Elasticsearch does not know which physical index should receive the document. To resolve this, one index in the alias can be designated as the **write index**.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "logs-2024-01",
        "alias": "logs_current",
        "is_write_index": false
      }
    },
    {
      "add": {
        "index": "logs-2024-02",
        "alias": "logs_current",
        "is_write_index": true
      }
    }
  ]
}
```

- Read requests (searches) against `logs_current` span both indices
- Write requests (indexing) go exclusively to `logs-2024-02`

Only one write index per alias is permitted at a time.

> [Inference] Attempting to index into an alias that points to multiple indices without a designated write index will result in an error. Behavior may vary across versions.

---

### Atomic Alias Switching (Zero-Downtime Reindexing)

One of the most practical uses of aliases is performing index switches with no downtime. The `_aliases` actions API executes all operations atomically — the old index is removed and the new index is added in a single operation with no gap.

**Pattern:**

```json
POST /_aliases
{
  "actions": [
    { "remove": { "index": "logs-v1", "alias": "logs_active" } },
    { "add":    { "index": "logs-v2", "alias": "logs_active" } }
  ]
}
```

At no point is `logs_active` without a backing index. Applications pointing to `logs_active` continue operating without interruption or reconfiguration.

This pattern is standard for:

- Reindexing after mapping changes
- Promoting a newly built index to production
- Rolling back to a previous index if a problem is detected

---

### Filtered Aliases

A filtered alias applies a persistent query filter to all operations routed through it. Documents not matching the filter are invisible to clients using the alias — they are not returned in search results and cannot be updated or deleted via the alias.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "logs-2024-01",
        "alias": "logs_errors",
        "filter": {
          "term": { "level": "ERROR" }
        }
      }
    }
  ]
}
```

Any search against `logs_errors` implicitly includes `{ "term": { "level": "ERROR" } }` — no additional query clause is required from the client.

**Multiple filtered aliases on the same index:**

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "events",
        "alias": "events_purchase",
        "filter": { "term": { "event_type": "purchase" } }
      }
    },
    {
      "add": {
        "index": "events",
        "alias": "events_refund",
        "filter": { "term": { "event_type": "refund" } }
      }
    },
    {
      "add": {
        "index": "events",
        "alias": "events_all"
      }
    }
  ]
}
```

The same physical index is exposed through three aliases, each presenting a different logical view of the data.

> [Inference] Filtered aliases depend on the filter field being indexed correctly. If the filter field is not mapped or not indexed, the filter may behave unexpectedly. Behavior may vary.

---

### Routing in Aliases

Aliases can specify a `routing` value that is applied to all index and search operations going through the alias. This forces operations to a specific shard, which can improve performance for data that is naturally partitioned by a known value.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index":          "orders",
        "alias":          "orders_region_apac",
        "filter":         { "term": { "region": "apac" } },
        "routing":        "apac",
        "index_routing":  "apac",
        "search_routing": "apac"
      }
    }
  ]
}
```

| Parameter | Applies To |
|---|---|
| `routing` | Both indexing and search |
| `index_routing` | Indexing only |
| `search_routing` | Search only (comma-separated for multiple shards) |

`search_routing` accepts multiple values separated by commas, allowing searches to span a defined subset of shards:

```json
"search_routing": "apac,emea"
```

> [Inference] Alias-level routing interacts with shard allocation and custom routing on individual documents. Conflicting routing values between the alias and the document may produce unexpected shard targeting. Behavior may vary.

---

### Removing an Alias

**Remove a single alias:**

```json
DELETE /logs-2024-01/_alias/logs_current
```

**Remove via the actions API:**

```json
POST /_aliases
{
  "actions": [
    {
      "remove": {
        "index": "logs-2024-01",
        "alias": "logs_current"
      }
    }
  ]
}
```

**Remove all aliases from an index:**

```json
POST /_aliases
{
  "actions": [
    {
      "remove": {
        "index": "logs-2024-01",
        "alias": "*"
      }
    }
  ]
}
```

---

### Removing an Index via an Alias

An alias itself cannot be deleted by deleting the index it points to — the index must be deleted directly. Deleting the index removes all its aliases automatically.

```json
DELETE /logs-2024-01
```

This removes the index and all aliases associated with it.

---

### Retrieving Alias Information

**Get all aliases on a specific index:**

```json
GET /logs-2024-01/_alias
```

**Get a specific alias:**

```json
GET /logs-2024-01/_alias/logs_current
```

**Get all indices associated with a specific alias:**

```json
GET /_alias/logs_current
```

**List all aliases in the cluster:**

```json
GET /_alias
```

**Compact view via cat API:**

```json
GET /_cat/aliases?v
```

---

### Aliases in Index Templates

Aliases defined in index templates are automatically applied to every new index created from that template:

```json
PUT /_index_template/logs_template
{
  "index_patterns": ["logs-*"],
  "priority": 100,
  "template": {
    "aliases": {
      "logs_all": {},
      "logs_search": {}
    }
  }
}
```

Every index matching `logs-*` will automatically have `logs_all` and `logs_search` added as aliases at creation time.

---

### is_hidden Parameter

Aliases can be marked as hidden, which causes them to be excluded from wildcard operations and the `_alias` listing by default.

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index":     "internal-metrics",
        "alias":     ".internal_alias",
        "is_hidden": true
      }
    }
  ]
}
```

Hidden aliases are typically used by Elasticsearch internal features and system indices. They are accessible when referenced explicitly by name.

---

### Alias Existence Check

To check whether an alias exists without retrieving its full definition:

```json
HEAD /_alias/logs_current
```

Returns HTTP `200` if the alias exists, `404` if it does not. Useful for conditional logic in automation scripts.

---

### Comparison: Alias vs Index Pattern in Queries

| Factor | Alias | Index Pattern (wildcard) |
|---|---|---|
| Abstraction layer | Yes — application decoupled from index names | No — index names exposed |
| Atomic switching | Yes | No |
| Filtered view support | Yes | No |
| Routing support | Yes | No |
| Write index designation | Yes | No |
| Template-driven creation | Yes | N/A |
| Operational flexibility | Higher | Lower |

---

### Common Patterns

#### Rolling Index Pattern

A new index is created each day or month. The alias always points to the most recent index for writes, while a separate alias spans all indices for reads.

```json
// Write alias — updated daily
POST /_aliases
{
  "actions": [
    { "remove": { "index": "logs-2024-01-31", "alias": "logs_write" } },
    { "add":    { "index": "logs-2024-02-01", "alias": "logs_write", "is_write_index": true } }
  ]
}
```

#### Reindex and Promote Pattern

```json
// Step 1 — reindex from old to new
POST /_reindex
{
  "source": { "index": "products-v1" },
  "dest":   { "index": "products-v2" }
}

// Step 2 — atomic alias switch
POST /_aliases
{
  "actions": [
    { "remove": { "index": "products-v1", "alias": "products" } },
    { "add":    { "index": "products-v2", "alias": "products" } }
  ]
}
```

#### Multi-tenant Data Isolation Pattern

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index":  "shared_events",
        "alias":  "events_tenant_a",
        "filter": { "term": { "tenant_id": "tenant_a" } }
      }
    },
    {
      "add": {
        "index":  "shared_events",
        "alias":  "events_tenant_b",
        "filter": { "term": { "tenant_id": "tenant_b" } }
      }
    }
  ]
}
```

Each tenant's application queries its own alias and sees only its own data from a shared physical index.

---

### Best Practices

- **Always access indices through aliases in application code.** Direct index name references in application queries couple the application to the physical index structure and complicate maintenance.
- **Use atomic alias switching for all index promotions and reindexing operations.** The `_aliases` actions API makes zero-downtime transitions straightforward.
- **Designate a write index explicitly** when an alias spans multiple indices and indexing operations are expected through that alias.
- **Use filtered aliases for multi-tenant or role-based data access** rather than maintaining separate indices per tenant when the data volume does not justify physical separation.
- **Document alias-to-index relationships.** As the number of aliases and indices grows, undocumented alias structures become difficult to reason about during incidents.
- **Audit aliases periodically.** Aliases pointing to deleted or retired indices, or aliases created for temporary purposes and never removed, accumulate over time and add confusion to cluster state.
- **Avoid overlapping filtered aliases on write paths without careful routing design.** A filtered alias that also serves as a write index may cause documents that do not match the filter to be indexed but invisible through that alias.

---