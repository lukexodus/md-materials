## Creating and Managing Data Streams

### Overview

Managing a data stream in practice involves setting up the supporting index template, controlling rollover behavior, handling updates and deletes at the backing-index level, monitoring stream health, and eventually retiring or migrating the stream. This topic covers the operational lifecycle beyond the conceptual model.

### Prerequisites: Index Template Setup

A data stream cannot be created until a composable index template exists that matches its name pattern and declares `data_stream`. Component templates are commonly used to separate mappings and settings into reusable pieces.

**Component template for mappings**

```json
PUT /_component_template/logs-mappings
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "message": { "type": "text" },
        "log.level": { "type": "keyword" },
        "service.name": { "type": "keyword" }
      }
    }
  }
}
```

**Component template for settings**

```json
PUT /_component_template/logs-settings
{
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "logs-ilm-policy"
    }
  }
}
```

**Composable index template referencing both**

```json
PUT /_index_template/logs-app-template
{
  "index_patterns": ["logs-app-*"],
  "data_stream": {},
  "composed_of": ["logs-mappings", "logs-settings"],
  "priority": 200
}
```

The `priority` field matters when multiple templates could match the same index pattern — the highest-priority matching template wins.

### Explicit Creation vs. Auto-Creation

A data stream can be created explicitly:

```json
PUT /_data_stream/logs-app-prod
```

Or it is created implicitly the first time a document is indexed against a matching name, provided a matching template with `data_stream: {}` exists:

```json
POST /logs-app-prod/_doc
{
  "@timestamp": "2026-08-25T09:00:00Z",
  "message": "Service starting",
  "log.level": "info",
  "service.name": "checkout-api"
}
```

Auto-creation is the common path in production ingestion pipelines (e.g., via Elastic Agent, Logstash, or application code), since it avoids requiring a separate provisioning step per stream name.

### Bulk Indexing into a Data Stream

Bulk requests work the same way as with regular indices, but each action must use `create` (not `index`), consistent with the append-only model.

```json
POST /logs-app-prod/_bulk
{ "create": {} }
{ "@timestamp": "2026-08-25T09:01:00Z", "message": "Request handled", "log.level": "info" }
{ "create": {} }
{ "@timestamp": "2026-08-25T09:01:05Z", "message": "Cache miss", "log.level": "debug" }
```

Using `"index": {}` instead of `"create": {}` against a data stream typically fails, since `index` semantics imply potential overwrite-by-ID, which conflicts with the append-only contract [Unverified — exact rejection behavior/error code should be confirmed against the deployed version].

### Manual Rollover

Rollover can be forced at any time, independent of ILM conditions, which is useful when a mapping change needs to take effect immediately in a new generation.

```json
POST /logs-app-prod/_rollover/
```

Rollover can also be issued with explicit conditions checked against the current write index before rolling over:

```json
POST /logs-app-prod/_rollover/
{
  "conditions": {
    "max_age": "7d",
    "max_docs": 50000000,
    "max_primary_shard_size": "50gb"
  }
}
```

If none of the specified conditions are met, no rollover occurs and the response indicates `"rolled_over": false`.

### Updating and Deleting Documents

Because updates and deletes by ID are not supported directly against the data stream name, they must target the specific backing index containing the document.

**Step 1 — Find the backing index containing the document**

```json
POST /logs-app-prod/_search
{
  "query": {
    "match": { "_id": "abc123" }
  }
}
```

The `_index` field in the hit reveals the actual backing index (e.g., `.ds-logs-app-prod-000002`).

**Step 2 — Update/delete against that backing index directly**

```json
POST /.ds-logs-app-prod-000002/_update/abc123
{
  "doc": {
    "log.level": "warn"
  }
}
```

For bulk update/delete operations affecting many documents matching a query (common for redaction or correction tasks), `_update_by_query` and `_delete_by_query` can be run against the data stream name itself, since these operate by query rather than by direct ID targeting.

```json
POST /logs-app-prod/_update_by_query
{
  "query": {
    "term": { "service.name": "checkout-api" }
  },
  "script": {
    "source": "ctx._source['log.level'] = 'warn'"
  }
}
```

### Reindexing a Data Stream

Reindexing is used to fix mapping issues across historical backing indices or to migrate data into a new data stream entirely. The `_reindex` API supports data streams as both source and destination.

```json
POST /_reindex
{
  "source": {
    "index": "logs-app-prod"
  },
  "dest": {
    "index": "logs-app-prod-v2",
    "op_type": "create"
  }
}
```

`"op_type": "create"` is required when the destination is a data stream, again due to append-only semantics.

### Monitoring Data Stream Health

The data stream stats and health APIs provide operational visibility.

```json
GET /_data_stream/logs-app-prod/_stats
```

```json
GET /_health_report/data_stream
```

Key things typically monitored:

- Number of backing indices (generations) and their sizes
- Whether rollover is keeping pace with ingestion volume (a write index growing far past its intended size threshold suggests ILM/rollover misconfiguration)
- Whether ILM is stuck in a phase (e.g., failed shrink or force merge action)
- Storage distribution across hot/warm/cold tiers if ILM tiering is configured

### Modifying Mappings on an Existing Data Stream

Since existing backing indices are immutable in their mapping structure for practical purposes, mapping changes are applied by:

1. Updating the index template (component template or composable template) with the new mapping
2. Triggering a rollover so the new write index picks up the updated mapping
3. Optionally reindexing historical backing indices if the new field needs to be queryable/populated retroactively across old data

```json
PUT /_component_template/logs-mappings
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "message": { "type": "text" },
        "log.level": { "type": "keyword" },
        "service.name": { "type": "keyword" },
        "trace.id": { "type": "keyword" }
      }
    }
  }
}
```

```json
POST /logs-app-prod/_rollover/
```

### Deleting a Data Stream

```json
DELETE /_data_stream/logs-app-prod
```

This removes the data stream and all of its backing indices in one operation. For selective retention (keeping recent data, discarding old), ILM/data stream lifecycle retention settings are the standard mechanism rather than manual deletion.

### Common Management Pitfalls

- Forgetting `"create": {}` semantics in bulk requests, causing indexing failures against the data stream
- Attempting direct `_update`/`_delete` by ID against the data stream name rather than the resolved backing index
- Mapping conflicts introduced by relying on dynamic mapping instead of an explicit template, leading to inconsistent field types across generations
- Not aligning `priority` values across index templates, causing an unintended template to match and misconfigure a new data stream
- Neglecting to monitor rollover cadence, resulting in an oversized write index that degrades search/indexing performance

### Diagram: Data Stream Management Workflow

```mermaid
flowchart TD
    A[Define component templates: mappings + settings] --> B[Define composable index template with data_stream: {}]
    B --> C{Data stream exists?}
    C -->|No| D[Explicit PUT _data_stream OR auto-create on first doc]
    C -->|Yes| E[Continue ingesting via create/bulk]
    D --> E
    E --> F{Rollover condition met?}
    F -->|Yes, automatic via ILM| G[New backing index created]
    F -->|Manual trigger needed| H[POST _rollover]
    H --> G
    F -->|No| E
    G --> E
    E --> I{Update/delete needed?}
    I -->|By ID| J[Resolve backing index, target directly]
    I -->|By query| K[_update_by_query / _delete_by_query on stream name]
    I -->|No| L[Monitor via _stats / _health_report]
    L --> M{Retention expired?}
    M -->|Yes| N[ILM/data stream lifecycle deletes old backing index]
    M -->|No| E
```

**Related Topics**

- Index Lifecycle Management (ILM) policy phases and actions
- Component templates vs. composable index templates
- `_update_by_query` and `_delete_by_query` performance considerations
- Reindex API options (`op_type`, slicing, remote reindex)
- Data stream health report API and alerting on it
- Time series data streams (TSDS) and downsampling