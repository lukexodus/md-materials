## Write Path and Read Path

### Overview

Every operation in Elasticsearch follows a well-defined path through the cluster. The write path governs how data is durably ingested and replicated across shards. The read path governs how queries and document retrievals are executed and results assembled. Understanding both paths is foundational for reasoning about consistency guarantees, latency characteristics, failure behavior, and performance tuning.

**Key Points:**
- Both paths begin at a coordinating node, which may be any node in the cluster
- Write operations target primary shards first, then replicate to replicas
- Read operations can be served by any shard copy — primary or replica
- The two paths have different consistency and latency profiles

---

### The Write Path

#### Coordinating Node Role

Every write request — whether an index, update, bulk, or delete — is received by a coordinating node. The coordinating node is not a special node type; any data node or dedicated coordinating node can fulfill this role for a given request. The coordinating node is responsible for:

- Parsing and validating the request
- Computing the target shard using the routing formula
- Forwarding the request to the node hosting the primary shard
- Waiting for acknowledgment from the primary and replicas
- Returning the response to the client

The coordinating node does not write any data itself.

#### Full Write Path

```
Client
  ↓
Coordinating Node
├── Computes routing: shard_num = hash(_routing) % num_primary_shards
├── Identifies node hosting primary shard N
  ↓
Primary Shard Node
├── Validates the document and mapping
├── Writes to in-memory indexing buffer
├── Writes to translog (fsync depending on durability setting)
├── Forwards write request to all in-sync replica shards in parallel
  ↓
Replica Shard Nodes (parallel)
├── Each replica writes to its own buffer and translog
├── Each replica acknowledges to primary
  ↓
Primary Shard Node
├── Receives acknowledgments from all in-sync replicas
├── Acknowledges to coordinating node
  ↓
Coordinating Node
  ↓
Client ← Response returned
```

#### In-Sync Replica Set

Elasticsearch maintains an in-sync replica set (ISR) — the set of shard copies that are confirmed to be up to date with the primary. Only replicas in the ISR receive forwarded writes. If a replica falls behind or becomes unavailable, it is removed from the ISR by the master node.

**[Inference]** A replica removed from the ISR must resync with the primary before rejoining it. During this period, the primary continues serving writes with fewer in-sync copies, which may affect fault tolerance depending on configuration.

#### Primary Term and Sequence Numbers

Elasticsearch uses two mechanisms to track write ordering and detect stale shard copies:

**Primary Term:**
- A monotonically increasing integer assigned to each primary shard
- Incremented every time a new primary is elected (e.g., after a failure)
- Included in every write operation to identify which primary issued it

**Sequence Number:**
- A per-shard monotonically increasing counter assigned to every indexing operation
- Combined with the primary term, uniquely identifies every operation on a shard
- Used for replica resynchronization and optimistic concurrency control

**Operation Identifier Format:**

```
_primary_term: 3
_seq_no: 10482
```

These values are returned in index and get responses and can be used for optimistic concurrency control:

```json
PUT /my-index/_doc/user-4821?if_primary_term=3&if_seq_no=10482
{
  "status": "updated"
}
```

If the document has been modified since the values were read, the operation is rejected with a `409 Conflict` response.

#### Translog

The transaction log (translog) provides durability for operations that have been acknowledged but not yet committed to a Lucene segment on disk.

**Translog Write Behavior:**

```
Document Indexed
      ↓
Written to in-memory indexing buffer  ←── not yet searchable
      ↓
Written to translog                   ←── durable (by default)
      ↓
[Refresh interval elapsed]
      ↓
Segment flushed to disk               ←── now searchable
      ↓
[Flush threshold reached]
      ↓
Lucene commit issued                  ←── segment durably committed
      ↓
Translog truncated
```

**Durability Setting:**

```json
PUT /my-index/_settings
{
  "index.translog.durability": "request"
}
```

| Value | Behavior |
|---|---|
| `request` (default) | Translog fsynced to disk on every acknowledged request |
| `async` | Translog fsynced periodically (interval: `index.translog.sync_interval`, default 5s) |

**[Inference]** Setting `durability: async` may improve indexing throughput by reducing fsync overhead, but introduces a window during which acknowledged writes could be lost on node failure. Actual throughput gain and risk window depend on hardware and workload.

#### Indexing Buffer and Refresh

The in-memory indexing buffer accumulates incoming documents before they are flushed to a Lucene segment. The buffer is shared across all shards on a node, governed by `indices.memory.index_buffer_size` (default: 10% of JVM heap).

**Refresh Mechanics:**

- Refresh converts the in-memory buffer into a new, searchable Lucene segment
- Default refresh interval: `1s` (configurable via `index.refresh_interval`)
- A refresh does not fsync the segment; data is searchable but not yet durably committed
- Refresh can be triggered manually via the `_refresh` API

**Optimizing for Bulk Indexing:**

```json
PUT /my-index/_settings
{
  "index.refresh_interval": "-1",
  "index.number_of_replicas": 0
}
```

Disabling refresh and replicas during bulk ingestion reduces overhead significantly. After ingestion completes:

```json
POST /my-index/_refresh

PUT /my-index/_settings
{
  "index.refresh_interval": "1s",
  "index.number_of_replicas": 1
}
```

**[Inference]** Temporarily setting `number_of_replicas: 0` during bulk indexing removes replication overhead but leaves data unprotected until replicas are re-enabled and fully synced. Behavior may vary depending on cluster size and available resources.

#### Update and Delete Operations

Updates and deletes follow the same write path but interact with Lucene's immutable segment model in specific ways.

**Update:**
1. Primary shard fetches the current document version
2. Applies the update script or partial document merge
3. Indexes the new version as a new document
4. Marks the old document version as deleted in the segment deletion bitmap
5. Replicates the full updated document (not a delta) to replicas

**Delete:**
1. Primary shard marks the document as deleted in the segment deletion bitmap
2. Document is not physically removed until a segment merge reclaims the space
3. Delete operation is replicated to all in-sync replicas

**[Inference]** High update or delete rates increase the proportion of soft-deleted documents in segments, increasing storage consumption until merges reclaim space. Monitoring the deleted document ratio via `_stats` may indicate when force merges would be beneficial.

#### Bulk API Write Path

The Bulk API batches multiple write operations into a single request, reducing per-request overhead. The coordinating node disaggregates the bulk request by routing each operation to its target shard, then forwards per-shard sub-batches in parallel.

**Example:**

```json
POST /_bulk
{ "index": { "_index": "my-index", "_id": "1" } }
{ "message": "first document" }
{ "index": { "_index": "my-index", "_id": "2" } }
{ "message": "second document" }
{ "delete": { "_index": "my-index", "_id": "3" } }
```

**Output:**

```json
{
  "took": 12,
  "errors": false,
  "items": [
    { "index": { "_id": "1", "result": "created", "status": 201 } },
    { "index": { "_id": "2", "result": "created", "status": 201 } },
    { "delete": { "_id": "3", "result": "deleted", "status": 200 } }
  ]
}
```

Individual item failures within a bulk request do not cause the entire request to fail. The `errors` field indicates whether any item-level failures occurred.

---

### The Read Path

#### Two Types of Read Operations

Elasticsearch has two distinct read operation types with different execution models:

| Operation Type | Description | Shard Targeting |
|---|---|---|
| **Document GET** | Retrieve a specific document by `_id` | Single shard (exact routing) |
| **Search Query** | Execute a query across documents | All shards or routing-targeted subset |

#### Document GET Path

A GET request for a specific document ID follows a direct, single-shard path.

```
Client GET Request (_id: "user-4821")
        ↓
Coordinating Node
├── Computes routing: shard_num = hash("user-4821") % num_primary_shards
├── Identifies all copies of shard N (primary + replicas)
├── Selects one copy using round-robin or adaptive replica selection
        ↓
Selected Shard Copy (primary or replica)
├── Locates document by _id in the segment files
├── Retrieves stored fields (_source)
        ↓
Coordinating Node
        ↓
Client ← Document returned
```

**Real-Time GET:**

By default, GET requests are real-time. If a document has been indexed but not yet refreshed into a searchable segment, Elasticsearch checks the translog to retrieve the most recent version.

```json
GET /my-index/_doc/user-4821?realtime=false
```

Setting `realtime=false` disables translog lookup; the GET returns only documents visible in committed segments.

**Example GET Response:**

```json
{
  "_index": "my-index",
  "_id": "user-4821",
  "_version": 3,
  "_seq_no": 10482,
  "_primary_term": 3,
  "found": true,
  "_source": {
    "user_id": "4821",
    "status": "active"
  }
}
```

#### Adaptive Replica Selection

When multiple shard copies are available (primary + replicas), Elasticsearch uses Adaptive Replica Selection (ARS) to choose the copy most likely to respond fastest. ARS considers:

- Queue depth on the target node
- Response time of recent requests to that node
- Service time of shard-level operations

**[Inference]** ARS may improve average query latency by avoiding overloaded nodes, but its effectiveness depends on the degree of load imbalance across shard copies. In uniformly loaded clusters, the benefit over simple round-robin may be modest.

ARS is enabled by default and can be disabled:

```json
PUT /_cluster/settings
{
  "persistent": {
    "cluster.routing.use_adaptive_replica_selection": false
  }
}
```

#### Search Query Path — Query Then Fetch

Search queries follow a two-phase execution model called Query Then Fetch.

**Phase 1 — Query Phase:**

```
Client Search Request
        ↓
Coordinating Node
├── Identifies target shards (all, or routing-targeted subset)
├── Broadcasts query to one copy of each target shard in parallel
        ↓
Each Shard (parallel execution)
├── Executes query locally against its segments
├── Returns: top N doc_ids + scores (not full documents)
        ↓
Coordinating Node
├── Collects results from all shards
├── Merges and globally ranks all doc_ids by score
├── Selects final top N results
```

**Phase 2 — Fetch Phase:**

```
Coordinating Node
├── Identifies which shards hold the final top N documents
├── Issues fetch requests to those shards
        ↓
Target Shards
├── Retrieve full _source for requested doc_ids
├── Return documents to coordinating node
        ↓
Coordinating Node
├── Assembles final response
        ↓
Client ← Search response returned
```

**Why Two Phases:**

Fetching full document source for every candidate result from every shard would be wasteful. The query phase retrieves only lightweight identifiers and scores, enabling the coordinating node to globally rank results before fetching only the documents that appear in the final result set.

#### Deep Pagination and the Query Phase Cost

The query phase has an important implication for deep pagination. When fetching page N with page size K, each shard must return its top `(N × K)` results to the coordinating node, which then globally ranks them and discards all but the final K.

**Example — Page 100, Page Size 10:**

```
Each shard returns: top 1,000 results
Coordinating node receives: 1,000 × num_shards results
Globally ranks and returns: top 10 results
```

**[Inference]** Deep pagination on large indices with many shards can generate significant coordinating node memory pressure and query latency. The `search_after` parameter or Point in Time (PIT) API are generally more appropriate for deep or cursor-based pagination.

#### The Fetch Phase and _source

During the fetch phase, shards retrieve the `_source` field from stored fields. Applications can control what is returned:

**Source Filtering:**

```json
GET /my-index/_search
{
  "_source": ["user_id", "status"],
  "query": {
    "match": { "message": "error" }
  }
}
```

**Disabling Source Retrieval:**

```json
GET /my-index/_search
{
  "_source": false,
  "query": {
    "match": { "message": "error" }
  }
}
```

Disabling `_source` skips the fetch phase for source content, reducing I/O. This is useful when only aggregation results are needed and document content is not required.

#### Scroll API and Point in Time

For retrieving large result sets without deep pagination overhead, Elasticsearch provides the Scroll API and Point in Time (PIT).

**Point in Time (PIT):**

A PIT captures a consistent view of the index state at a specific moment. Combined with `search_after`, it enables efficient cursor-based pagination:

```json
POST /my-index/_pit?keep_alive=1m
```

**Output:**

```json
{
  "id": "46ToAwMDaWR5BXV1aWQy..."
}
```

```json
GET /_search
{
  "size": 10,
  "query": { "match_all": {} },
  "pit": {
    "id": "46ToAwMDaWR5BXV1aWQy...",
    "keep_alive": "1m"
  },
  "sort": [{ "@timestamp": "asc" }],
  "search_after": ["2024-01-15T10:23:00Z"]
}
```

**[Inference]** PIT-based pagination maintains a consistent index snapshot across pages, preventing issues caused by concurrent writes changing result ordering between page requests. The snapshot consumes cluster resources until explicitly deleted or the `keep_alive` expires.

#### Aggregation Execution on the Read Path

Aggregations execute during the query phase, alongside query matching. Each shard computes partial aggregation results locally, then returns them to the coordinating node, which merges partial results into the final aggregation response.

```
Each Shard
├── Executes query → identifies matching documents
├── Computes partial aggregation over matching docs
└── Returns: top doc_ids + scores + partial agg results

Coordinating Node
├── Merges partial aggregations from all shards
└── Returns: final search hits + merged aggregation results
```

**[Inference]** Aggregations over high-cardinality fields (e.g., `terms` aggregation with many unique values) require each shard to return a large number of partial buckets. The coordinating node must merge all of them, which can be memory-intensive. The `shard_size` parameter controls how many buckets each shard returns, trading accuracy for resource efficiency.

#### Consistency on the Read Path

Elasticsearch does not guarantee strong read-after-write consistency by default across all read paths.

| Operation | Consistency Behavior |
|---|---|
| Real-time GET | Reads from translog; reflects latest write immediately |
| Search query | Reads from segments; reflects only refreshed writes |
| GET with `realtime=false` | Reads from segments only; same as search |

A document indexed at `t=0` is visible to GET requests immediately (via translog) but may not appear in search results until the next refresh at approximately `t=1s`.

**[Inference]** Applications requiring search visibility immediately after write should call `_refresh` explicitly or set `refresh=true` on the index request, though the latter adds latency to the write operation and should be used sparingly.

---

### Write Path and Read Path Interaction

The two paths interact at the segment level. A write that has not yet been refreshed is invisible to search but visible to real-time GET. A force merge that reduces segment count improves read path performance by reducing the number of per-segment operations during query execution.

**Summary Comparison:**

| Dimension | Write Path | Read Path |
|---|---|---|
| Entry point | Coordinating node | Coordinating node |
| Shard targeting | Primary shard only | Any shard copy |
| Replication | Primary → in-sync replicas | Not applicable |
| Durability mechanism | Translog + Lucene flush | Not applicable |
| Consistency | Sequential per document | Near-real-time (search) / real-time (GET) |
| Parallelism | Per-shard bulk sub-batches | All target shards simultaneously |
| Failure handling | Primary term + seq_no tracking | Retry on alternate shard copy |

### Practical Implications

**Write Performance:**
- Increase `refresh_interval` to reduce segment creation frequency during heavy ingestion
- Use the Bulk API to amortize per-request overhead across many operations
- Monitor translog size and flush frequency to detect I/O bottlenecks
- Consider `async` translog durability only when data loss risk is acceptable

**Read Performance:**
- Use routing to target searches to specific shards and reduce fanout
- Avoid deep pagination; prefer `search_after` with PIT for large result set traversal
- Disable `_source` retrieval when only aggregation results are needed
- Monitor coordinating node memory when running aggregations over high-cardinality fields

**Consistency Requirements:**
- Use real-time GET when immediate post-write visibility is required
- Use explicit refresh sparingly for use cases requiring immediate search visibility
- Design applications to tolerate the default near-real-time search window where possible

**Conclusion:**

The write path and read path represent the two fundamental operational flows in Elasticsearch. The write path prioritizes durability and consistency through the translog, primary-first replication, and sequence number tracking. The read path prioritizes performance through shard-level parallelism, adaptive replica selection, and the two-phase query-then-fetch model. A thorough understanding of both paths — and how they interact at the segment and cluster level — is essential for designing systems that are performant, consistent, and resilient under real operational conditions.