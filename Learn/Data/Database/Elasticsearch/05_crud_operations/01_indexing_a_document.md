## Indexing a Document

---

### What Does Indexing Mean?

In Elasticsearch, **indexing** refers to the process of storing a document in an index so that it becomes searchable. When a document is indexed, Elasticsearch parses the JSON, applies the field mappings, runs analyzers on text fields, builds inverted index entries, and stores the document in `_source`. All of this happens before the document becomes visible to search.

Indexing is distinct from storing — a field can be stored without being indexed (not searchable), and indexed without being stored in `_source` (searchable but not retrievable directly).

---

### Document Structure

Every document in Elasticsearch has a set of metadata fields alongside its user-defined content:

| Metadata Field | Description |
|---|---|
| `_index` | The index the document belongs to |
| `_id` | The unique identifier of the document within the index |
| `_version` | The version number, incremented on every write |
| `_seq_no` | Sequence number for optimistic concurrency control |
| `_primary_term` | Primary term for optimistic concurrency control |
| `_source` | The original JSON document as indexed |
| `_score` | Relevance score (present only in search results) |

---

### Indexing with an Explicit ID

Use `PUT` when you want to assign a specific document ID:

```json
PUT /employees/_doc/1
{
  "name":       "Ana Reyes",
  "department": "Engineering",
  "hire_date":  "2021-03-15",
  "salary":     95000,
  "active":     true
}
```

**Response:**

```json
{
  "_index":        "employees",
  "_id":           "1",
  "_version":      1,
  "result":        "created",
  "_shards": {
    "total":       2,
    "successful":  1,
    "failed":      0
  },
  "_seq_no":       0,
  "_primary_term": 1
}
```

- `result: created` — the document did not previously exist and was created
- `result: updated` — a document with this ID existed and was replaced

If a document with the same ID already exists, the entire document is replaced and `_version` is incremented.

---

### Indexing with an Auto-generated ID

Use `POST` when you want Elasticsearch to generate a unique ID automatically. Auto-generated IDs are URL-safe Base64-encoded UUIDs.

```json
POST /employees/_doc
{
  "name":       "Marco Cruz",
  "department": "Marketing",
  "hire_date":  "2022-07-01",
  "salary":     78000,
  "active":     true
}
```

**Response:**

```json
{
  "_index":   "employees",
  "_id":      "a1b2c3d4e5F6g7H8iJkL",
  "_version": 1,
  "result":   "created"
}
```

Auto-generated IDs are always treated as `create` operations — they never overwrite an existing document.

---

### create vs index Operation Type

The `op_type` parameter controls whether the operation should succeed only if the document does not already exist.

**Using `op_type=create` — fails if the document already exists:**

```json
PUT /employees/_doc/1?op_type=create
{
  "name": "Ana Reyes"
}
```

Shorthand using the `_create` endpoint:

```json
PUT /employees/_create/1
{
  "name": "Ana Reyes"
}
```

If document ID `1` already exists, this returns a `409 Conflict` error instead of silently overwriting it. This is useful when the application needs strict create semantics — for example, preventing duplicate records.

---

### Dynamic Index Creation

If the target index does not exist when a document is indexed, Elasticsearch creates it automatically using dynamic mapping — provided `action.auto_create_index` is enabled (it is by default).

```json
PUT /new_index/_doc/1
{
  "field_a": "hello",
  "field_b": 42
}
```

If `new_index` does not exist, it is created with a dynamically inferred mapping.

> [Inference] Relying on auto-created indices in production carries the same risks as unrestricted dynamic mapping — types may be inferred incorrectly, and the index may be created without the settings or mappings your use case requires. Explicit index creation or index templates are recommended for production workloads. Behavior may vary.

---

### Indexing Behavior When Mapping Exists

When a mapping already exists for the index:

- Fields defined in the mapping are indexed according to their configured type and analyzer
- Fields not in the mapping are handled according to the `dynamic` setting (`true`, `false`, `strict`, or `runtime`)
- A field whose value does not match its mapped type causes the indexing request to fail, unless `ignore_malformed` is enabled on that field

**Example — `ignore_malformed`:**

```json
PUT /employees
{
  "mappings": {
    "properties": {
      "salary": {
        "type":             "integer",
        "ignore_malformed": true
      }
    }
  }
}
```

A document with `"salary": "not-a-number"` will be indexed — the `salary` field will be excluded from the index but the rest of the document is stored normally.

---

### The `_source` Field

By default, the original JSON document is stored in `_source`. It is returned in search results and is required for update operations.

`_source` can be disabled to save storage:

```json
PUT /logs
{
  "mappings": {
    "_source": { "enabled": false }
  }
}
```

> [Inference] Disabling `_source` reduces storage but prevents document retrieval, updates via the `_update` API, and reindexing from the index. This trade-off is rarely worth the storage savings in most use cases. Behavior may vary.

`_source` filtering can include or exclude specific fields at index time:

```json
PUT /employees
{
  "mappings": {
    "_source": {
      "includes": ["name", "department", "hire_date"],
      "excludes": ["salary"]
    }
  }
}
```

Fields excluded from `_source` are still indexed and searchable if they are mapped — they simply do not appear in the stored source document.

---

### Routing

By default, Elasticsearch determines which shard a document is stored on using the formula:

```
shard = hash(_id) % number_of_primary_shards
```

Custom routing can be specified to control shard placement:

```json
PUT /employees/_doc/1?routing=engineering
{
  "name":       "Ana Reyes",
  "department": "Engineering"
}
```

When custom routing is used at index time, the same routing value must be specified on all subsequent get, update, and delete operations for that document — otherwise Elasticsearch looks on the wrong shard.

> [Inference] Inconsistent routing between index and retrieval operations may result in document not found responses even when the document exists. Custom routing requires discipline at the application level. Behavior may vary.

---

### Refresh Behavior

After a document is indexed, it is not immediately visible to search. Elasticsearch buffers writes and periodically refreshes the index (default: every 1 second), making buffered documents searchable.

The `refresh` parameter controls this behavior per request:

| Value | Behavior |
|---|---|
| `false` (default) | Document is indexed; refresh happens on the next scheduled interval |
| `true` | Index is refreshed immediately after the operation; document is instantly searchable |
| `wait_for` | Request waits until the next scheduled refresh before returning; does not force an immediate refresh |

```json
PUT /employees/_doc/1?refresh=true
{
  "name": "Ana Reyes"
}
```

> [Inference] Using `refresh=true` on every indexing request forces frequent segment creation and may significantly reduce indexing throughput at scale. It should be used only when immediate search visibility is a hard requirement. Behavior may vary.

---

### Optimistic Concurrency Control

Elasticsearch supports optimistic concurrency control using `if_seq_no` and `if_primary_term`. An indexing or update operation is only applied if the document's current sequence number and primary term match the supplied values.

**Workflow:**

1. Retrieve the document and note `_seq_no` and `_primary_term`
2. Submit the update with those values as preconditions

```json
PUT /employees/_doc/1?if_seq_no=3&if_primary_term=1
{
  "name":       "Ana Reyes",
  "department": "Platform Engineering",
  "salary":     100000
}
```

If another process has modified the document between the read and write, the `_seq_no` will have changed and Elasticsearch returns a `409 Conflict` error. The application can then re-read and retry.

This approach avoids the performance overhead of distributed locking while still preventing lost updates.

---

### Pipeline Processing at Index Time

An ingest pipeline can be applied to documents during indexing to transform, enrich, or filter them before they are stored.

```json
PUT /employees/_doc/1?pipeline=enrich_employee
{
  "name":       "Ana Reyes",
  "department": "Engineering"
}
```

The pipeline named `enrich_employee` must already exist. Pipelines can contain processors such as `set`, `rename`, `grok`, `date`, `convert`, `remove`, `script`, and others.

**Setting a default pipeline on the index:**

```json
PUT /employees/_settings
{
  "index.default_pipeline": "enrich_employee"
}
```

All documents indexed into `employees` will pass through `enrich_employee` automatically, without requiring the `pipeline` parameter on each request.

---

### Timeout Parameter

The `timeout` parameter specifies how long the primary shard must be available before the request times out. The default is `1m` (one minute).

```json
PUT /employees/_doc/1?timeout=5m
{
  "name": "Ana Reyes"
}
```

This does not set a wait time for replication — it controls how long Elasticsearch waits for the primary shard to be available to accept the write.

---

### Retrieving a Document After Indexing

Use the `GET` API to retrieve a document by ID:

```json
GET /employees/_doc/1
```

**Response:**

```json
{
  "_index":   "employees",
  "_id":      "1",
  "_version": 1,
  "_source": {
    "name":       "Ana Reyes",
    "department": "Engineering",
    "hire_date":  "2021-03-15",
    "salary":     95000,
    "active":     true
  }
}
```

To check document existence without retrieving content:

```json
HEAD /employees/_doc/1
```

Returns `200` if the document exists, `404` if it does not.

To retrieve only specific fields from `_source`:

```json
GET /employees/_doc/1?_source_includes=name,department
```

---

### Bulk Indexing

For high-throughput indexing, the `_bulk` API allows multiple operations in a single request, reducing per-request overhead.

```json
POST /_bulk
{ "index": { "_index": "employees", "_id": "2" } }
{ "name": "Lena Park", "department": "Finance", "salary": 82000 }
{ "index": { "_index": "employees", "_id": "3" } }
{ "name": "David Tan", "department": "Engineering", "salary": 91000 }
{ "create": { "_index": "employees", "_id": "4" } }
{ "name": "Sara Gomez", "department": "HR", "salary": 70000 }
```

Each operation is a pair of lines: an action metadata line followed by a source document line. The bulk API supports `index`, `create`, `update`, and `delete` actions in the same request.

> [Inference] Optimal bulk request size depends on document size, cluster configuration, and available heap. A commonly cited starting point is 5–15 MB per bulk request, but this should be tested and tuned for each specific workload. Behavior may vary.

---

### Indexing Internals (Overview)

Understanding what happens internally when a document is indexed clarifies refresh, flush, and durability behavior:

1. **Write to translog** — the operation is written to the transaction log on the primary shard for durability before acknowledgment
2. **Index into in-memory buffer** — the document is added to an in-memory indexing buffer
3. **Refresh** — on the next refresh cycle, the buffer is written to a new Lucene segment and becomes searchable; the translog is not yet cleared
4. **Flush** — periodically, buffered segments are flushed to disk and the translog is cleared; a Lucene commit point is written
5. **Merge** — background segment merging combines smaller segments into larger ones, improving search efficiency

> [Inference] The translog provides durability between flushes — if a node fails before a flush, documents can be replayed from the translog. The exact behavior of translog durability depends on `index.translog.durability` settings. Behavior may vary across configurations.

---

### Common Indexing Errors

| Error | Cause | Resolution |
|---|---|---|
| `mapper_parsing_exception` | Field value does not match the mapped type | Correct the value or enable `ignore_malformed` |
| `strict_dynamic_mapping_exception` | New field encountered with `dynamic: strict` | Add the field to the mapping or change `dynamic` setting |
| `version_conflict_engine_exception` | `if_seq_no` / `if_primary_term` precondition failed | Re-read the document and retry |
| `document_already_exists_exception` | `op_type=create` used on an existing document ID | Use `index` op_type or check for existence first |
| `cluster_block_exception` | Index is read-only (e.g., disk watermark reached) | Free disk space or adjust watermark settings |

---

### Best Practices

- **Use explicit IDs when documents have a natural unique key** (e.g., user ID, order number). Use auto-generated IDs for event streams and logs where no natural key exists.
- **Use `_create` endpoint or `op_type=create` when duplicate prevention is required.** Silent overwrites with `PUT` can mask data integrity issues.
- **Prefer bulk indexing for high-throughput workloads.** Individual index requests have higher per-document overhead than bulk operations.
- **Avoid `refresh=true` on individual requests in production.** Use `refresh=wait_for` when near-real-time visibility is required, or rely on the default refresh interval.
- **Define index templates and mappings before ingesting data.** Auto-created indices with dynamic mappings are difficult to correct retroactively.
- **Use optimistic concurrency control** (`if_seq_no`, `if_primary_term`) whenever multiple processes may write to the same document.
- **Use ingest pipelines for data normalization** rather than transforming data before it reaches Elasticsearch — pipelines keep transformation logic centralized and auditable.

---