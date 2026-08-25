## Circuit Breakers

### Overview

Circuit breakers in Elasticsearch are a memory-protection mechanism designed to prevent individual operations from causing a node to run out of heap memory and crash with an `OutOfMemoryError`. Rather than allowing a request to consume unbounded memory, a circuit breaker estimates the memory an operation will require, checks that estimate against a configured limit, and rejects the operation with a `CircuitBreakingException` if the limit would be exceeded. This trades a failed request for node stability, which is generally the safer outcome in a distributed cluster.

### Why Circuit Breakers Exist

Elasticsearch runs on the JVM, which has a fixed heap size. Certain operations — aggregations, sorting on large result sets, loading fielddata, parsing large requests — can consume large, sometimes unpredictable amounts of heap memory. Without a protective mechanism, a single expensive query could exhaust the heap, triggering long garbage collection pauses or an outright crash. A crashed node typically means unassigned shards, a period of degraded cluster health, and disruption to every other operation running against that node, not just the offending query. Circuit breakers exist to contain the damage to a single failed request instead.

### The Circuit Breaker Hierarchy

Elasticsearch does not use a single global limit. Instead, it maintains a **parent breaker** and several **child breakers**, each tracking memory usage for a specific subsystem.

- **Parent breaker** (`indices.breaker.total.limit`) — the overall ceiling. Default is 95% of heap (70% in older versions, but modern defaults are higher since child breakers are more precise). All child breaker usage counts toward this total.
- **Field data breaker** (`indices.breaker.fielddata.limit`) — guards memory used when loading fielddata into memory, typically for sorting, aggregating, or scripting on text fields. Default limit: 40% of heap.
- **Request breaker** (`indices.breaker.request.limit`) — guards memory needed to execute a single request, such as computing aggregation buckets. Default limit: 60% of heap.
- **In-flight requests breaker** (`network.breaker.inflight_requests.limit`) — guards memory consumed by the raw bytes of requests currently being processed, before they're deserialized. Default limit: 100% of heap.
- **Accounting breaker** (`indices.breaker.accounting.limit`) — guards memory used by structures that persist for the lifetime of a shard, such as Lucene segment metadata. Default limit: 100% of heap.
- **Script compilation breaker** — separate from memory; limits the *rate* of script compilations rather than memory (see below).

Each child breaker is checked independently, and the parent breaker aggregates their usage. An operation can be rejected either because its own child breaker is exceeded, or because total usage across all breakers exceeds the parent limit.

$$\text{Estimated Usage} + \text{Requested Bytes} > \text{Limit} \implies \text{CircuitBreakingException}$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 460" font-family="sans-serif">
<text x="390" y="30" text-anchor="middle" font-size="18" font-weight="bold">Circuit Breaker Hierarchy (svg_diagram)</text>
<rect x="260" y="55" width="260" height="60" rx="8" fill="#2b6cb0" />
<text x="390" y="80" text-anchor="middle" font-size="14" fill="white" font-weight="bold">Parent Breaker</text>
<text x="390" y="100" text-anchor="middle" font-size="12" fill="white">indices.breaker.total.limit</text>
<line x1="390" y1="115" x2="140" y2="180" stroke="#4a5568" stroke-width="2" />
<line x1="390" y1="115" x2="310" y2="180" stroke="#4a5568" stroke-width="2" />
<line x1="390" y1="115" x2="470" y2="180" stroke="#4a5568" stroke-width="2" />
<line x1="390" y1="115" x2="640" y2="180" stroke="#4a5568" stroke-width="2" />
<rect x="40" y="180" width="200" height="70" rx="8" fill="#3182ce" />
<text x="140" y="205" text-anchor="middle" font-size="13" fill="white" font-weight="bold">Field Data Breaker</text>
<text x="140" y="222" text-anchor="middle" font-size="11" fill="white">fielddata.limit</text>
<text x="140" y="238" text-anchor="middle" font-size="11" fill="white">default 40%</text>
<rect x="260" y="180" width="200" height="70" rx="8" fill="#3182ce" />
<text x="360" y="205" text-anchor="middle" font-size="13" fill="white" font-weight="bold">Request Breaker</text>
<text x="360" y="222" text-anchor="middle" font-size="11" fill="white">request.limit</text>
<text x="360" y="238" text-anchor="middle" font-size="11" fill="white">default 60%</text>
<rect x="480" y="180" width="200" height="70" rx="8" fill="#3182ce" />
<text x="580" y="205" text-anchor="middle" font-size="13" fill="white" font-weight="bold">In-Flight Requests</text>
<text x="580" y="222" text-anchor="middle" font-size="11" fill="white">inflight_requests.limit</text>
<text x="580" y="238" text-anchor="middle" font-size="11" fill="white">default 100%</text>
<rect x="540" y="270" width="200" height="70" rx="8" fill="#3182ce" />
<text x="640" y="295" text-anchor="middle" font-size="13" fill="white" font-weight="bold">Accounting Breaker</text>
<text x="640" y="312" text-anchor="middle" font-size="11" fill="white">accounting.limit</text>
<text x="640" y="328" text-anchor="middle" font-size="11" fill="white">default 100%</text>
<line x1="640" y1="115" x2="640" y2="270" stroke="#4a5568" stroke-width="2" />
<rect x="120" y="370" width="540" height="70" rx="8" fill="#c53030" />
<text x="390" y="398" text-anchor="middle" font-size="13" fill="white" font-weight="bold">If estimated usage + requested bytes &gt; limit</text>
<text x="390" y="418" text-anchor="middle" font-size="13" fill="white">CircuitBreakingException is thrown, request rejected</text>
</svg>

### How Estimation Works

Circuit breakers use **pre-flight estimation**, not post-hoc measurement. Before allocating memory for a structure (a fielddata cache entry, an aggregation bucket array, a deserialized request), Elasticsearch estimates the number of bytes required and adds that estimate to the breaker's running total. If the addition would push the total past the configured limit, the operation is rejected before the memory is actually allocated.

This is why circuit breakers can occasionally trip on operations that, in practice, would not have used as much memory as estimated — the estimation is deliberately conservative to avoid the more dangerous failure mode of underestimating and still hitting an OOM.

### Common Circuit Breaker Exceptions

**Example**

A poorly bounded aggregation on a high-cardinality field can trip the request breaker:

```json
POST /logs-*/_search
{
  "size": 0,
  "aggs": {
    "unique_users": {
      "terms": {
        "field": "user_id.keyword",
        "size": 500000
      }
    }
  }
}
```

If `user_id.keyword` has millions of unique values and 500,000 buckets are requested, Elasticsearch must estimate the memory needed to hold that many buckets before execution. If the estimate exceeds the request breaker's limit, the response looks like:

```json
{
  "error": {
    "type": "circuit_breaking_exception",
    "reason": "[parent] Data too large, data for [<agg_buckets>] would be [30923412345/28.8gb], which is larger than the limit of [30923411456/28.8gb]",
    "bytes_wanted": 30923412345,
    "bytes_limit": 30923411456,
    "durability": "TRANSIENT"
  },
  "status": 429
}
```

Key fields to read:

- `bytes_wanted` vs `bytes_limit` — how far over the threshold the estimate landed.
- `durability: TRANSIENT` — indicates the request can be retried once memory pressure eases, as opposed to `PERMANENT`, which signals a structural issue that retrying won't fix.

### Field Data Breaker in Practice

The field data breaker is one of the most frequently encountered in practice, because it guards a genuinely dangerous pattern: sorting, aggregating, or scripting on `text` fields without `fielddata` enabled correctly, or enabling fielddata on a high-cardinality text field.

```json
PUT /articles/_mapping
{
  "properties": {
    "title": {
      "type": "text",
      "fielddata": true
    }
  }
}
```

Enabling `fielddata: true` on a `text` field causes Elasticsearch to build an uninverted index in heap memory the first time that field is used for aggregation or sorting. On a large, high-cardinality field, this can consume enormous amounts of heap very quickly and is one of the most common causes of field data circuit breaker trips in production clusters. The standard remedy is to use a `keyword` sub-field instead:

```json
PUT /articles/_mapping
{
  "properties": {
    "title": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword",
          "ignore_above": 256
        }
      }
    }
  }
}
```

### Script Compilation Circuit Breaker

Distinct from the memory-based breakers above, the script compilation breaker limits the **rate** of script compilations rather than memory usage. Elasticsearch caches compiled scripts, but scripts with inline parameters that change on every request (rather than using params) can exhaust the compilation cache and trip this breaker.

Relevant setting:

```yaml
script.max_compilations_rate: 150/5m
```

**Example** of a script pattern that avoids tripping this breaker, by parameterizing values instead of inlining them:

```json
POST /sales/_update_by_query
{
  "script": {
    "source": "ctx._source.price *= params.factor",
    "params": {
      "factor": 1.1
    }
  }
}
```

Using `params.factor` instead of hardcoding `1.1` directly in the source string means the script text itself doesn't change between requests, so it can be served from the compiled script cache rather than triggering a new compilation each time.

### Monitoring Circuit Breaker State

The `_nodes/stats` API exposes current breaker usage per node:

```json
GET /_nodes/stats/breaker
```

Response excerpt:

```json
{
  "nodes": {
    "abc123": {
      "breakers": {
        "request": {
          "limit_size_in_bytes": 6440251392,
          "limit_size": "6gb",
          "estimated_size_in_bytes": 1024,
          "estimated_size": "1kb",
          "overhead": 1.0,
          "tripped": 0
        },
        "fielddata": {
          "limit_size_in_bytes": 4293500928,
          "limit_size": "4gb",
          "estimated_size_in_bytes": 0,
          "estimated_size": "0b",
          "overhead": 1.03,
          "tripped": 3
        }
      }
    }
  }
}
```

**Key Points**

- `tripped` is a cumulative counter of how many times that breaker has rejected an operation since node startup. A non-zero and climbing value indicates ongoing memory pressure worth investigating.
- `overhead` is a multiplier applied to raw estimates to account for JVM object overhead; it's a constant per breaker type, not an indicator of health.
- Sustained high `estimated_size_in_bytes` relative to `limit_size_in_bytes` across polling intervals suggests the cluster is operating close to its ceiling even without visible trips yet.

Monitoring tools like Kibana's Stack Monitoring or Elastic's own cluster health dashboards typically chart the `tripped` counters over time, since a sudden spike often correlates with a specific query pattern, a bulk indexing spike, or a misbehaving aggregation being deployed.

### Tuning Circuit Breaker Limits

Circuit breaker limits can be adjusted dynamically via the cluster settings API:

```json
PUT /_cluster/settings
{
  "persistent": {
    "indices.breaker.total.limit": "85%",
    "indices.breaker.request.limit": "50%",
    "indices.breaker.fielddata.limit": "30%"
  }
}
```

[Inference] Lowering these limits trades off request success rate against safety margin — a lower limit rejects more borderline operations but leaves more headroom before an actual OOM, while raising them permits heavier operations to succeed but narrows that safety margin. The appropriate values depend heavily on the specific workload's query patterns, node heap size, and how much of that heap other subsystems (segment memory, mappings, coordinating node buffers) already consume, so there's no universal "correct" percentage.

### Circuit Breakers vs. Other Memory Protections

It's worth distinguishing circuit breakers from other memory-related mechanisms they're sometimes confused with:

- **Circuit breakers** — reject operations *before* memory is allocated, based on estimation. Operate at the request/operation level.
- **JVM heap size / `-Xmx`** — the hard ceiling on total heap available to the node process itself; circuit breakers are tuned as percentages of this value.
- **Indexing buffer limits** (`indices.memory.index_buffer_size`) — govern how much heap is allotted to in-memory Lucene segments before a flush, a separate concern from query-time memory.
- **Field data cache eviction** — once fielddata is loaded and the *cache* (not the breaker) reaches its configured size, older entries are evicted using an LRU policy; this is a cache management mechanism, not a rejection mechanism.

### Best Practices

- Prefer `keyword` fields (or multi-fields) over enabling `fielddata` on `text` fields wherever aggregation or sorting is needed.
- Bound aggregation `size` parameters deliberately rather than requesting very large bucket counts.
- Use `params` in scripts instead of inlining variable values, to avoid recompilation and the associated script compilation breaker pressure.
- Monitor `tripped` counters via `_nodes/stats/breaker` as part of routine cluster health checks, not only when a problem is already visible to users.
- Treat a `TRANSIENT` circuit breaking exception as retryable after backing off, but treat `PERMANENT` as a signal to change the request or mapping, since retrying will fail again.
- Avoid raising breaker limits as a first response to trips; investigate the query or mapping pattern causing the pressure first, since raising limits reduces the safety margin against actual `OutOfMemoryError`s.

### Related Topics

- Performance Tuning — Indexing Buffer and Refresh Interval
- Performance Tuning — JVM Heap Sizing and Garbage Collection
- Mapping — `keyword` vs `text` Fields and Multi-Fields
- Aggregations — Bucket Size and `terms` Aggregation Cardinality Control
- Scripting — Painless Script Compilation and Caching
- Monitoring — Cluster Health and Node Stats APIs
- Performance Tuning — Fielddata Cache and Eviction