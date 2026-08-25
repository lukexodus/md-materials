## Query DSL – Filter Caching

### Overview

Filter caching is Elasticsearch's mechanism for storing the results of filter context clauses so they can be reused across queries without re-evaluation. The cache stores results as **bitsets** — compact data structures where each bit corresponds to a document in a segment, indicating whether that document matches the filter.

When a cached filter is reused, Elasticsearch performs a bitset lookup rather than re-executing the filter logic, significantly reducing query latency for recurring conditions.

---

### Cache Location and Scope

The filter cache is maintained at the **node level**, per **Lucene segment**. Each segment in each shard has its own cached bitsets.

Key properties:

- Cache is **not shared across nodes** — each node maintains its own filter cache.
- Cache is **per segment** — a filter cached against one segment is not applicable to another segment, even on the same shard.
- Cache is **not shared across indices** — filter results for one index do not apply to another.
- When a segment is **merged** (Lucene segment merging), its cached bitsets are invalidated and must be rebuilt if the filter is encountered again.

[Inference] Because the cache is per-segment, indices with many small segments (under-merged) may see reduced cache efficiency. Forcing a merge to reduce segment count can improve filter cache hit rates, though merging has its own cost. Behavior may vary.

---

### What Gets Cached

Not every filter clause is cached automatically. Elasticsearch applies internal heuristics to decide whether a clause is worth caching.

#### Factors that influence caching eligibility

| Factor | Detail |
|---|---|
| **Segment size** | Only segments above a minimum size threshold are considered for caching. Small segments (typically under 10,000 documents) are generally not cached because the cost of cache management may exceed the benefit. |
| **Query frequency** | A clause must be used a minimum number of times before Elasticsearch caches it. Rarely used filters are not cached. |
| **Clause type** | Some clause types are always cached when in filter context; others are never cached or use alternative mechanisms. |
| **Cost of evaluation** | [Inference] Clauses that are cheap to evaluate may not be cached because re-evaluation is faster than a cache lookup. Behavior may vary. |

#### Clause types and caching behavior

| Clause type | Caching behavior |
|---|---|
| `term` | Eligible; typically cached after repeated use |
| `terms` | Eligible |
| `range` (numeric/date) | Eligible |
| `exists` | Eligible |
| `match_all` | Eligible |
| `ids` | Eligible |
| `geo_bounding_box` | Eligible |
| `prefix` | Eligible but [Inference] may be less cache-efficient due to high cardinality |
| `wildcard` | Eligible but expensive to compute; [Inference] caching benefit depends on reuse frequency |
| `script` | Generally not cached; [Inference] script execution is considered non-deterministic from the cache's perspective |
| `match` (in filter context) | Analyzed at runtime; [Inference] less likely to benefit from caching compared to `term` |
| `now` in `range` | **Not cached** — `now` is a moving value; results would be immediately stale |

---

### The `now` Exception

A `range` filter using `now` is explicitly excluded from caching because its result changes every millisecond:

```json
{
  "query": {
    "bool": {
      "filter": {
        "range": {
          "published_at": {
            "gte": "now-7d/d",
            "lt": "now/d"
          }
        }
      }
    }
  }
}
```

This filter will **not** be cached.

To make a date range filter cacheable, use absolute dates:

```json
{
  "query": {
    "bool": {
      "filter": {
        "range": {
          "published_at": {
            "gte": "2024-01-01",
            "lt": "2024-02-01"
          }
        }
      }
    }
  }
}
```

[Inference] Date math with rounding (e.g., `now/d`) is more cache-friendly than raw `now` because the rounded value is stable within a day, but Elasticsearch still treats these as non-cacheable in most cases. Verify behavior against your specific version.

---

### Bitset Structure

When a filter clause is cached, Elasticsearch stores its result as a **Roaring Bitset** — a compressed bitmap where each bit represents one document in a Lucene segment.

- A set bit (`1`) means the document matches the filter.
- An unset bit (`0`) means it does not.

Roaring Bitsets use a hybrid encoding that switches between dense arrays and sparse representations depending on data distribution, keeping memory usage low while allowing fast bitwise operations (AND, OR, NOT) for combining multiple filters.

[Inference] The memory footprint of a cached bitset depends on the number of documents in the segment and the selectivity of the filter. A filter matching nearly all documents and a filter matching very few documents both produce compact representations under Roaring Bitset encoding. Behavior and memory usage may vary.

---

### Combining Cached Filters

When multiple filter clauses appear in a `bool` query's `filter` array, their cached bitsets are combined using bitwise operations:

```json
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "status": "published" } },
        { "range": { "views": { "gte": 1000 } } },
        { "term": { "category": "engineering" } }
      ]
    }
  }
}
```

Each clause has its own cached bitset. The intersection (bitwise AND) is computed at query time to produce the final matching document set. This operation is very fast even for large indices.

---

### Cache Memory Management

The filter cache is bounded in size. Elasticsearch uses an **LRU (Least Recently Used)** eviction policy — when the cache reaches its memory limit, the least recently accessed entries are evicted to make room for new ones.

#### Configuring cache size

Controlled by the static node setting `indices.queries.cache.size`:

```yaml
indices.queries.cache.size: 10%
```

- Value can be a percentage of heap (e.g., `10%`) or an absolute byte value (e.g., `512mb`).
- Default is `10%` of the JVM heap.
- This is a **static setting** — it requires a node restart to take effect.

[Inference] Increasing cache size improves hit rates for workloads with many recurring filters but reduces heap available for other operations (indexing buffers, field data cache, etc.). Tuning requires profiling actual workload behavior. Behavior and trade-offs may vary.

---

### Enabling and Disabling Cache Per Query

The filter cache can be controlled per query clause using the `_cache` meta-parameter, though this is an advanced and rarely needed override:

```json
{
  "query": {
    "bool": {
      "filter": {
        "term": {
          "status": {
            "value": "published",
            "_cache": false
          }
        }
      }
    }
  }
}
```

Setting `_cache: false` prevents Elasticsearch from caching that specific clause even if it would otherwise qualify.

[Inference] This override is not commonly needed. Elasticsearch's automatic heuristics are generally appropriate. Explicitly disabling caching may be useful when a filter is known to be used only once or when its result would be stale immediately. Behavior of the `_cache` parameter may vary across versions; verify against current documentation.

---

### Per-Index Cache Enablement

The filter cache can be disabled entirely for a specific index using an index-level setting:

```json
PUT /my-index/_settings
{
  "index.queries.cache.enabled": false
}
```

Default is `true`. Disabling is [Inference] primarily useful for indices that are write-heavy or where query patterns are entirely non-repeating, such that caching provides no benefit and only consumes memory.

---

### Monitoring Filter Cache

#### Node-level stats

```json
GET /_nodes/stats/indices/query_cache
```

Key fields in the response:

| Field | Description |
|---|---|
| `query_cache.memory_size_in_bytes` | Current cache memory used |
| `query_cache.total_count` | Total number of cache lookups |
| `query_cache.hit_count` | Number of cache hits |
| `query_cache.miss_count` | Number of cache misses |
| `query_cache.evictions` | Number of entries evicted due to memory pressure |
| `query_cache.cache_count` | Number of cached entries currently held |

#### Index-level stats

```json
GET /my-index/_stats/query_cache
```

Returns the same fields scoped to a specific index.

#### Hit rate calculation

$$\text{Hit Rate} = \frac{\text{hit\_count}}{\text{hit\_count} + \text{miss\_count}}$$

[Inference] A low hit rate suggests either filters are not recurring frequently enough to benefit from caching, or the cache is undersized and evicting entries before they can be reused. Behavior depends on workload patterns.

---

### Segment Merging and Cache Invalidation

Lucene periodically merges smaller segments into larger ones. When a segment is merged:

- All cached bitsets for that segment are **invalidated**.
- If the same filter is encountered again after merging, it must be re-evaluated against the new merged segment and re-cached.

This means filter cache warm-up may be needed after a merge or after index recovery.

[Inference] Indices undergoing frequent merges (e.g., due to high write throughput) may see reduced filter cache effectiveness because cached entries are regularly invalidated. Behavior depends on merge policy configuration and write patterns.

---

### Interaction with Shard Routing and Replicas

- Each **shard replica** (primary and replicas) maintains its own independent filter cache on the node where it resides.
- A filter cached on the primary shard is not automatically available on replica shards.
- [Inference] If queries are distributed across replicas, the same filter may need to be cached independently on each replica node before consistent cache hits are achieved across the cluster. Behavior depends on routing configuration.

---

### Practical Guidelines

**Maximize caching benefit:**

- Use `filter` context for all binary, structured conditions (`term`, `range`, `exists`).
- Prefer absolute date values over `now` in range filters when caching is desired.
- Reuse the same filter clause structure consistently — slight structural variations may be treated as distinct cache entries.
- Avoid `script` filters in hot query paths if caching is important.

**Avoid cache pollution:**

- Do not place high-cardinality, highly variable conditions in filter context if they will not repeat across queries (e.g., per-user filters with unique values each time).
- [Inference] Per-user or per-session filters with unique values on every request may occupy cache memory without ever being reused, causing eviction of more reusable entries. Behavior depends on cache size and eviction pressure.

**Monitor and tune:**

- Track `hit_count` vs `miss_count` via `_nodes/stats`.
- If evictions are high, consider increasing `indices.queries.cache.size`.
- If hit rate is low despite high query volume, investigate whether filters are structurally consistent across requests.

---

### Summary

| Aspect | Detail |
|---|---|
| Cache type | Node-level, per-segment Roaring Bitset |
| What is cached | Filter context clause results (binary match/no-match) |
| Caching decision | Automatic heuristics (segment size, clause frequency, clause type) |
| Not cached | `now`-based ranges, `script` filters, query context clauses |
| Eviction policy | LRU |
| Default cache size | 10% of JVM heap |
| Cache size setting | `indices.queries.cache.size` (static, node-level) |
| Invalidated by | Segment merges, index deletions |
| Monitoring | `GET /_nodes/stats/indices/query_cache` |
| Disable per index | `index.queries.cache.enabled: false` |