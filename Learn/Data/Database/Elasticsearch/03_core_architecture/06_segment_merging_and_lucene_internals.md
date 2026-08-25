Segment merging and Lucene internals
## Segment Merging and Lucene Internals

### How Elasticsearch Relates to Lucene

Elasticsearch is built on top of Apache Lucene, a high-performance full-text search library. Each Elasticsearch shard is a self-contained Lucene index. Understanding Lucene's internal structure is essential for reasoning about indexing performance, search efficiency, and resource consumption.

**Key Points:**
- One Elasticsearch index = one or more shards
- One Elasticsearch shard = one Lucene index
- One Lucene index = one or more segments
- Segments are the fundamental unit of Lucene storage

### Lucene Segments

A segment is an immutable, self-contained unit of storage within a Lucene index. When documents are indexed, they are first written to an in-memory buffer. When the buffer is flushed — either due to size thresholds or explicit refresh calls — a new segment is written to disk.

**Segment Immutability:**

Once written, a segment is never modified. This immutability has important consequences:

- Updates are implemented as a delete of the old document plus an index of the new document
- Deletes are recorded in a separate deletion bitmap, not by physically removing data
- Deleted documents remain in segments until a merge reclaims their space
- Immutability enables safe concurrent reads without locking

**Segment Contents:**

Each segment contains the following components:

```
Segment
├── Inverted Index         → term → postings list mapping
├── Stored Fields          → original document field values
├── Doc Values             → columnar field data for sorting/aggregations
├── Points / BKD Trees     → numeric and geo-spatial data structures
├── Norms                  → field-length normalization factors
├── Term Vectors           → per-document term frequency info
└── Deletion Bitmap        → records which docs are considered deleted
```

### The Inverted Index

The inverted index is the core data structure enabling full-text search. Rather than mapping documents to terms, it maps terms to the documents that contain them.

**Structure:**

```
Term        → Document IDs (Postings List)
───────────────────────────────────────────
"error"     → [doc1, doc3, doc7, doc12]
"timeout"   → [doc3, doc5, doc7]
"warning"   → [doc2, doc4, doc9]
```

Each entry in the postings list may also store:
- Term frequency (how often the term appears in the document)
- Position information (where in the document the term appears)
- Offset data (character start/end positions for highlighting)

**[Inference]** Query performance on very large segments can be affected by postings list length, particularly for high-frequency terms.

### BKD Trees for Numeric and Geo Data

Lucene uses Block K-D (BKD) trees to index numeric fields and geo-spatial data. Unlike inverted indexes optimized for text, BKD trees support efficient range queries and nearest-neighbor lookups on multidimensional data.

**Characteristics:**
- Balanced tree structure partitions multidimensional space
- Optimized for range queries (e.g., `price >= 10 AND price <= 100`)
- Supports geo-distance and geo-bounding-box queries
- Stored in a block-oriented format optimized for disk access

**[Inference]** Range queries on numeric fields typically perform more efficiently through BKD trees than through inverted indexes, though actual behavior may vary depending on data distribution and query shape.

### Doc Values

Doc values are an on-disk, column-oriented data structure used for sorting, aggregations, and scripting. While the inverted index maps terms to documents (row-oriented for search), doc values map documents to field values (column-oriented for retrieval).

**When Doc Values Are Used:**
- Sorting results by a field value
- Aggregations (terms, histograms, metrics)
- Scripted field access during query execution

**Data Layout:**

```
Doc ID   |  "price" field
─────────────────────────
0        |  29.99
1        |  14.50
2        |  99.00
3        |  5.75
```

**[Inference]** Disabling doc values for fields that are never sorted or aggregated may reduce disk usage and improve indexing throughput, though this limits future query flexibility.

### In-Memory Buffer and Refresh

New documents first land in an in-memory buffer. Periodically — or when the buffer reaches its size limit — Lucene flushes the buffer to a new segment on disk.

**Refresh Process:**

```
Document Written
      ↓
In-Memory Buffer (not yet searchable)
      ↓
  [Refresh Triggered]
      ↓
New Segment Written to Disk (now searchable)
```

The default refresh interval in Elasticsearch is 1 second. After a refresh, documents in the new segment become visible to searches. However, the segment is not yet fsync'd to disk, meaning data could be lost if the node fails before a translog flush.

**Important Distinction:**
- **Refresh** = segment visible to search (near real-time)
- **Flush** = translog written to disk, segment durably persisted

### The Translog

The translog (transaction log) provides durability between Lucene flushes. Every indexing operation is written to the translog before being acknowledged. If a node crashes, uncommitted segments can be recovered by replaying translog entries.

**Translog Behavior:**
- Writes occur synchronously by default before acknowledgment
- Translog is truncated after a successful Lucene flush
- Flush is triggered by translog size threshold (512MB by default) or time interval (30 minutes by default)
- `index.translog.durability` controls sync behavior

**[Inference]** Setting `index.translog.durability` to `async` may improve indexing throughput but introduces a window of potential data loss on node failure. Behavior may vary depending on workload and hardware.

### Segment Merging

Because each refresh produces a new segment, a shard can accumulate many small segments over time. Lucene periodically merges segments to maintain efficiency. Merging combines multiple small segments into fewer, larger ones.

**Why Merging Is Necessary:**

| Problem with Many Small Segments | Merge Solution |
|---|---|
| Each search must query all segments separately | Fewer segments = fewer per-search operations |
| Deleted documents occupy space | Merges physically remove deleted documents |
| High file descriptor usage | Fewer segments = fewer open files |
| Degraded cache efficiency | Larger segments use caches more effectively |
| Increased OS-level file system overhead | Reduced file count lowers OS pressure |

**Merge Process:**

```
Before Merge:
[seg1: 500 docs] [seg2: 300 docs] [seg3: 200 docs] [seg4: 150 docs]

Merge Triggered:
└─ Segments combined into new segment
└─ Deleted documents physically removed
└─ New merged segment written to disk

After Merge:
[seg5: 1,100 docs (net of deletions)]

Old segments deleted after merge completes.
```

### Merge Policy

Lucene controls when and how merges occur through a merge policy. Elasticsearch uses Lucene's `TieredMergePolicy` by default.

**TieredMergePolicy Logic:**

The policy groups segments into tiers by size and triggers merges when the number of segments within a tier exceeds a configurable threshold. Key parameters include:

- `index.merge.policy.max_merge_at_once`: Maximum segments merged in a single operation (default: 10)
- `index.merge.policy.segments_per_tier`: Target number of segments per tier (default: 10)
- `index.merge.policy.max_merged_segment`: Maximum size of a single merged segment (default: 5GB)
- `index.merge.policy.floor_segment`: Minimum segment size threshold before a segment is eligible for merging (default: 2MB)

**[Inference]** Tuning `segments_per_tier` lower may reduce query latency by maintaining fewer segments, but at the cost of increased merge I/O. Actual impact depends on workload characteristics.

### Force Merge

Force merge is an explicit API call that instructs Elasticsearch to reduce the number of segments in a shard to a specified maximum, regardless of the standard merge policy.

**Use Cases:**
- Finalizing read-only indices (warm/cold phase optimization)
- Reducing segment count before transition to frozen phase
- Reclaiming disk space from accumulated deleted documents
- Pre-production performance optimization

**Example API Call:**

```json
POST /my-index-000001/_forcemerge?max_num_segments=1
```

**Output:**

```json
{
  "_shards": {
    "total": 2,
    "successful": 2,
    "failed": 0
  }
}
```

**Important Warnings:**
- Force merge is resource-intensive and can significantly impact cluster performance
- Never run force merge on actively written indices — new segments will continue to be created, making the operation counterproductive
- A merge to `max_num_segments=1` produces a single large segment per shard, which is optimal only for completely static indices
- Behavior and timing may vary significantly depending on shard size and available I/O

### Merge Throttling

To prevent merges from consuming excessive I/O and degrading search or indexing performance, Elasticsearch throttles merge operations by default.

**Throttle Configuration:**

```json
PUT /_cluster/settings
{
  "persistent": {
    "indices.store.throttle.max_bytes_per_sec": "200mb"
  }
}
```

**[Inference]** During bulk indexing operations or ILM-driven force merges, temporarily raising the throttle limit may reduce the time taken to complete merges, though this increases resource pressure on affected nodes.

### Segment Visibility and the Near-Real-Time (NRT) Model

Elasticsearch's near-real-time search is a direct consequence of Lucene's segment architecture. A newly written segment becomes searchable only after a refresh. This means there is a window — up to the refresh interval — during which indexed documents are not yet visible to search.

**NRT Timeline:**

```
t=0.00s  Document indexed
t=0.00s  Written to translog and in-memory buffer
t=1.00s  Refresh triggered — new segment created
t=1.00s  Document becomes searchable
```

**Controlling Refresh Behavior:**

```json
PUT /my-index/_settings
{
  "index.refresh_interval": "5s"
}
```

Setting `refresh_interval` to `-1` disables automatic refreshes, which can significantly improve bulk indexing throughput. A manual refresh should be called after bulk operations complete.

**Example:**

```json
POST /my-index/_refresh
```

### Segment Merging and ILM Integration

Within the index lifecycle, segment merging plays an important role during phase transitions. Force merging is a common action applied in the warm phase to optimize read-heavy indices.

**Typical ILM Merge Strategy:**

```
Hot Phase:
└── Allow natural TieredMergePolicy merging during active writes

Warm Phase:
└── Force merge to max_num_segments=1
└── Optimizes segment structure for read performance
└── Reclaims space from accumulated deletes

Cold / Frozen Phase:
└── No further merging; index structure fixed
└── Searchable snapshots serve queries from repository
```

### Monitoring Segment Health

Elasticsearch exposes segment-level statistics through the `_cat/segments` and `_stats` APIs.

**Example — Segment Stats:**

```json
GET /my-index/_stats/segments
```

**Output (abbreviated):**

```json
{
  "_all": {
    "primaries": {
      "segments": {
        "count": 12,
        "memory_in_bytes": 45312,
        "terms_memory_in_bytes": 23040,
        "stored_fields_memory_in_bytes": 10240,
        "doc_values_memory_in_bytes": 8192,
        "index_writer_memory_in_bytes": 3840,
        "version_map_memory_in_bytes": 0
      }
    }
  }
}
```

**Key Metrics to Watch:**

- **`count`**: Total number of segments; high counts may indicate insufficient merging
- **`memory_in_bytes`**: Memory consumed by segment metadata and caches
- **`index_writer_memory_in_bytes`**: Memory used by the in-memory indexing buffer
- **`version_map_memory_in_bytes`**: Memory used to track document versions for updates; high values may indicate heavy update workloads

### Practical Recommendations

**For Write-Heavy Indices:**
- Increase `refresh_interval` to reduce segment creation frequency
- Allow `TieredMergePolicy` to handle merging automatically
- Monitor merge queue depth and I/O utilization
- Avoid force merges during active ingestion

**For Read-Heavy or Static Indices:**
- Force merge to a single segment per shard
- Apply force merge during off-peak hours or as an ILM warm phase action
- Verify deletion ratios before forcing merges to estimate space reclamation

**For High-Update Workloads:**
- Monitor `version_map_memory_in_bytes` as a proxy for update pressure
- Understand that each update generates a delete marker plus a new document
- Periodic merges reclaim space from accumulated soft-deleted documents

**Conclusion:**

Lucene's segment architecture underpins every aspect of Elasticsearch's indexing and search behavior. Segments are immutable by design, enabling safe concurrency at the cost of periodic merging overhead. The merge process — whether managed automatically by `TieredMergePolicy` or triggered explicitly via force merge — is central to maintaining search efficiency, reclaiming storage, and managing cluster resource consumption. A clear understanding of segment lifecycle, from buffer flush through merge and eventual deletion, is foundational for tuning and operating Elasticsearch effectively.