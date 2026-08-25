## Data Streams

---

### What Are Data Streams?

A data stream is an abstraction over a sequence of time-series indices that are managed, rotated, and queried through a single named endpoint. Rather than manually creating, naming, and aliasing indices as data grows over time, a data stream handles index lifecycle automatically — new backing indices are created as rollover conditions are met, and the data stream name remains stable as the entry point for both writes and reads.

Data streams are designed specifically for append-only, time-ordered data: logs, metrics, traces, events, and similar workloads where documents represent moments in time and are rarely or never updated after indexing.

---

### Core Concepts

#### Backing Indices

A data stream is backed by one or more hidden auto-generated indices. These are the physical indices where documents are stored. They follow a naming convention:

```
.ds-<data-stream-name>-<yyyy.MM.dd>-<generation>
```

**Example:**

```
.ds-logs-app-2024.11.01-000001
.ds-logs-app-2024.11.15-000002
.ds-logs-app-2024.12.01-000003
```

Each backing index is hidden — it does not appear in normal index listings unless explicitly requested.

#### Write Index

At any given time, exactly one backing index is the **write index** — the target for all new documents indexed into the data stream. All other backing indices are read-only. When a rollover occurs, a new backing index becomes the write index and the previous one becomes read-only.

#### @timestamp Requirement

Every document indexed into a data stream must contain a `@timestamp` field mapped as `date` or `date_nanos`. This is a strict requirement — documents without `@timestamp` are rejected.

---

### Prerequisites: Index Template

A data stream cannot be created without a matching composable index template that includes a `data_stream` block. The template defines the mappings and settings for all backing indices.

```json
PUT /_index_template/logs_app_template
{
  "index_patterns": ["logs-app-*"],
  "priority":       200,
  "data_stream":    {},
  "template": {
    "settings": {
      "number_of_shards":       1,
      "number_of_replicas":     1,
      "index.refresh_interval": "15s"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date"    },
        "service":    { "type": "keyword" },
        "level":      { "type": "keyword" },
        "message":    { "type": "text"    },
        "host":       { "type": "keyword" }
      }
    }
  }
}
```

The `data_stream: {}` block is what signals to Elasticsearch that indices created from this template should be managed as data stream backing indices rather than standalone indices.

---

### Creating a Data Stream

Once a matching index template exists, the data stream is created either explicitly or implicitly.

**Explicit creation:**

```json
PUT /_data_stream/logs-app-prod
```

**Implicit creation:**

Indexing a document to a name that matches the template pattern and does not yet exist as an index automatically creates the data stream:

```json
POST /logs-app-prod/_doc
{
  "@timestamp": "2024-11-01T10:00:00Z",
  "service":    "auth-service",
  "level":      "ERROR",
  "message":    "Failed login attempt",
  "host":       "web-01"
}
```

---

### Indexing Documents

Documents are indexed using `POST` — not `PUT` with an explicit ID — because data streams are append-only and document IDs are auto-generated.

```json
POST /logs-app-prod/_doc
{
  "@timestamp": "2024-11-01T10:05:00Z",
  "service":    "payment-service",
  "level":      "INFO",
  "message":    "Transaction completed",
  "host":       "api-02"
}
```

**Bulk indexing:**

```json
POST /logs-app-prod/_bulk
{ "create": {} }
{ "@timestamp": "2024-11-01T10:06:00Z", "service": "auth-service", "level": "INFO", "message": "Login successful", "host": "web-01" }
{ "create": {} }
{ "@timestamp": "2024-11-01T10:07:00Z", "service": "payment-service", "level": "WARN", "message": "Slow response detected", "host": "api-02" }
```

Note: The bulk action for data streams must be `create`, not `index`. Using `index` in a bulk request against a data stream will be rejected.

---

### Searching a Data Stream

Search requests against a data stream automatically span all backing indices:

```json
GET /logs-app-prod/_search
{
  "query": {
    "bool": {
      "must": [
        { "term":  { "level": "ERROR" } },
        { "range": { "@timestamp": { "gte": "now-1d", "lte": "now" } } }
      ]
    }
  },
  "sort": [
    { "@timestamp": { "order": "desc" } }
  ]
}
```

Elasticsearch uses the `@timestamp` values in the query to determine which backing indices are likely to contain matching documents, skipping irrelevant ones.

> [Inference] The efficiency of backing index skipping depends on the time range in the query and how data is distributed across backing indices. Queries without time range filters scan all backing indices. Behavior may vary.

---

### Rollover

Rollover creates a new backing index and promotes it to the write index. The previous write index becomes read-only.

#### Manual Rollover

```json
POST /logs-app-prod/_rollover
```

#### Conditional Rollover

Rollover conditions can be specified — the rollover is only performed if at least one condition is met:

```json
POST /logs-app-prod/_rollover
{
  "conditions": {
    "max_age":    "7d",
    "max_docs":   10000000,
    "max_size":   "50gb",
    "max_primary_shard_size": "30gb"
  }
}
```

| Condition | Triggers rollover when |
|---|---|
| `max_age` | The write index has existed for the specified duration |
| `max_docs` | The write index contains at least the specified number of documents |
| `max_size` | The total size of the write index reaches the threshold |
| `max_primary_shard_size` | The largest primary shard reaches the threshold |

In practice, manual rollover is rarely used in production. Rollover is typically automated via Index Lifecycle Management (ILM).

---

### Index Lifecycle Management Integration

Data streams integrate directly with ILM. An ILM policy is attached via the index template's settings and automates rollover, shrinking, freezing, and deletion of backing indices as they age.

**Define an ILM policy:**

```json
PUT /_ilm/policy/logs_policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age":  "1d",
            "max_size": "50gb"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "shrink": { "number_of_shards": 1 },
          "forcemerge": { "max_num_segments": 1 }
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

**Reference the ILM policy in the index template:**

```json
PUT /_index_template/logs_app_template
{
  "index_patterns": ["logs-app-*"],
  "priority":       200,
  "data_stream":    {},
  "template": {
    "settings": {
      "index.lifecycle.name": "logs_policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date"    },
        "service":    { "type": "keyword" },
        "level":      { "type": "keyword" },
        "message":    { "type": "text"    }
      }
    }
  }
}
```

With this configuration, backing indices roll over daily or at 50 GB, move to warm tier after 7 days, and are deleted after 30 days — with no manual intervention.

---

### Updating Documents in a Data Stream

Data streams are designed for append-only workloads. Updates and deletes are supported but are intentionally constrained.

#### Updating a Document

Updates require specifying both the document ID and the backing index that contains it. They cannot be performed through the data stream name alone without a query.

```json
POST /logs-app-prod/_update_by_query
{
  "query": {
    "term": { "_id": "abc123" }
  },
  "script": {
    "source": "ctx._source.level = 'RESOLVED'"
  }
}
```

#### Deleting a Document

```json
POST /logs-app-prod/_delete_by_query
{
  "query": {
    "term": { "_id": "abc123" }
  }
}
```

Direct `DELETE /logs-app-prod/_doc/<id>` requires knowing the specific backing index:

```json
DELETE /.ds-logs-app-prod-2024.11.01-000001/_doc/abc123
```

> [Inference] Frequent updates and deletes on a data stream may degrade performance and are contrary to the append-only design intent. For workloads with significant mutation requirements, a standard index may be more appropriate. Behavior may vary.

---

### Mapping Updates on a Data Stream

Mapping changes are applied to the data stream's index template. They affect new backing indices created after the change, and can be applied to existing backing indices explicitly.

**Update the index template mapping:**

```json
PUT /_index_template/logs_app_template
{
  "index_patterns": ["logs-app-*"],
  "priority":       200,
  "data_stream":    {},
  "template": {
    "mappings": {
      "properties": {
        "@timestamp":  { "type": "date"    },
        "service":     { "type": "keyword" },
        "level":       { "type": "keyword" },
        "message":     { "type": "text"    },
        "duration_ms": { "type": "long"    }
      }
    }
  }
}
```

**Apply the mapping change to all existing backing indices:**

```json
PUT /logs-app-prod/_mapping
{
  "properties": {
    "duration_ms": { "type": "long" }
  }
}
```

When issued against the data stream name, the mapping update propagates to all current backing indices.

---

### Inspecting a Data Stream

**Get data stream details:**

```json
GET /_data_stream/logs-app-prod
```

**Output (abbreviated):**

```json
{
  "data_streams": [
    {
      "name":             "logs-app-prod",
      "timestamp_field":  { "name": "@timestamp" },
      "indices": [
        { "index_name": ".ds-logs-app-prod-2024.11.01-000001", "index_uuid": "..." },
        { "index_name": ".ds-logs-app-prod-2024.11.15-000002", "index_uuid": "..." }
      ],
      "generation":       2,
      "status":           "GREEN",
      "template":         "logs_app_template",
      "ilm_policy":       "logs_policy"
    }
  ]
}
```

**List all data streams:**

```json
GET /_data_stream
```

**Get data stream statistics:**

```json
GET /_data_stream/logs-app-prod/_stats
```

---

### Deleting a Data Stream

Deleting a data stream removes the data stream itself and all of its backing indices:

```json
DELETE /_data_stream/logs-app-prod
```

Individual backing indices cannot be deleted directly while the data stream exists — they must be managed through ILM or rollover, not manual deletion.

---

### Data Stream Aliases

Data streams support aliases similarly to standard index aliases. A data stream alias can point to one or more data streams.

```json
POST /_aliases
{
  "actions": [
    { "add": { "index": "logs-app-prod",    "alias": "logs_all" } },
    { "add": { "index": "logs-app-staging", "alias": "logs_all" } }
  ]
}
```

A write data stream can be designated within an alias:

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index":          "logs-app-prod",
        "alias":          "logs_write",
        "is_write_index": true
      }
    }
  ]
}
```

---

### Reindex Into a Data Stream

Existing data can be migrated into a data stream using the `_reindex` API:

```json
POST /_reindex
{
  "source": { "index": "legacy-logs-2024" },
  "dest":   {
    "index":   "logs-app-prod",
    "op_type": "create"
  }
}
```

`op_type: create` is required when the destination is a data stream. Documents in the source index must have a valid `@timestamp` field.

---

### Modifying Backing Indices Directly

In some operational scenarios — such as applying a specific setting to a single backing index — you can reference a backing index directly by its generated name.

**Retrieve the list of backing indices:**

```json
GET /_data_stream/logs-app-prod
```

**Apply a setting to a specific backing index:**

```json
PUT /.ds-logs-app-prod-2024.11.01-000001/_settings
{
  "index.number_of_replicas": 0
}
```

> [Inference] Directly modifying backing indices bypasses the data stream abstraction. Changes applied this way may be inconsistent with the index template and may not persist across rollovers. Use with caution in production. Behavior may vary.

---

### Data Stream vs Regular Index with Alias

| Factor | Data Stream | Index + Alias |
|---|---|---|
| Automatic rollover via ILM | Yes — native integration | Yes — but requires more configuration |
| `@timestamp` requirement | Mandatory | Optional |
| Append-only optimization | Yes | No |
| Write index management | Automatic | Manual |
| Backing index naming | Auto-generated | Manual |
| Updates and deletes | Supported but constrained | Fully supported |
| Mapping propagation to all indices | Single API call | Must update each index individually |
| Designed for time-series workloads | Yes | General purpose |

---

### Best Practices

- **Use data streams for all time-series, append-only workloads.** Logs, metrics, traces, and events are natural fits. General-purpose data with frequent updates is not.
- **Always define a matching index template with an ILM policy before creating a data stream.** Creating a data stream without ILM produces unbounded backing index growth.
- **Include `@timestamp` in all documents.** Missing or malformed timestamp fields cause indexing failures.
- **Use `create` as the bulk operation type, not `index`.** The distinction matters and using `index` against a data stream produces errors.
- **Apply mapping changes through both the index template and the `_mapping` API on the data stream** to ensure consistency between existing and future backing indices.
- **Do not manually delete backing indices.** Let ILM manage the lifecycle. Manual deletion can corrupt the data stream's generation sequence.
- **Monitor data stream statistics regularly** using `_stats` and `_data_stream` APIs to track backing index count, size distribution, and ILM phase progression.
- **Use data stream aliases to unify multiple data streams** for cross-service or cross-environment queries without exposing individual stream names to client applications.

---