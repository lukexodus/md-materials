## Scroll API

### Overview

The Scroll API is a mechanism for retrieving large numbers of documents from Elasticsearch in batches, beyond the constraints of standard `from`/`size` pagination. It works by creating a snapshot of the index state at the time the scroll is initialized and maintaining a search context on the server that preserves that snapshot across multiple retrieval requests.

Unlike `from`/`size`, the Scroll API is not designed for interactive, user-facing pagination. It is intended for bulk operations—exporting large datasets, reindexing, feeding data processing pipelines, or any scenario requiring sequential iteration over a complete or large partial result set.

**Important**: Elasticsearch documentation formally designates the Scroll API as a legacy feature. For new implementations requiring deep pagination or full dataset iteration, `search_after` combined with the Point-in-Time API is the recommended approach. The Scroll API is covered here for completeness, as it remains in active use in existing systems and continues to appear in operational contexts.

### How the Scroll API Works

When a scroll search is initiated:

1. Elasticsearch executes the query against the index and creates a frozen snapshot of the matching result set
2. A scroll context is opened on each relevant shard, preserving the segment state at that moment
3. A `_scroll_id` is returned to the client as a cursor
4. The client repeatedly calls the Scroll API with that `_scroll_id` to retrieve successive batches of documents
5. Each scroll call returns a new `_scroll_id` (which may or may not differ from the previous one)
6. When no more documents remain, `hits.hits` is empty
7. The client explicitly closes the scroll context to release server resources

The snapshot ensures that changes to the index after the scroll is opened—new documents, updates, deletions—are not reflected in scroll results. This makes results consistent across batches but also means scroll results are not real-time.

### Initiating a Scroll

A scroll is initiated with a standard search request that includes the `scroll` query parameter specifying the keep-alive duration:

```json
POST /articles/_search?scroll=5m
{
  "size": 1000,
  "query": {
    "match_all": {}
  },
  "sort": ["_doc"]
}
```

**Key Points**:
- `scroll=5m` defines how long the scroll context remains open between requests, not the total session duration
- `size` defines how many documents to return per batch
- `sort: ["_doc"]` sorts by internal Lucene document order—the most efficient sort for scrolling since it requires no sorting overhead. Use this whenever document order does not matter
- `from` is ignored and must not be used with scroll requests

**Output**:

```json
{
  "_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAABWAWbHZuVEhKdlRTZXFuWFp2dE1xdzNRdw==",
  "_shards": { "total": 5, "successful": 5, "failed": 0 },
  "hits": {
    "total": { "value": 54231, "relation": "eq" },
    "hits": [
      { "_id": "doc-001", "_source": { "..." } },
      "...",
      { "_id": "doc-1000", "_source": { "..." } }
    ]
  }
}
```

The first response returns the first batch of documents. Store the `_scroll_id` for subsequent requests.

### Retrieving Subsequent Batches

Use the `_scroll_id` from the previous response to retrieve the next batch. Scroll continuation requests are sent to the `/_search/scroll` endpoint, not to the index:

```json
POST /_search/scroll
{
  "scroll": "5m",
  "scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAABWAWbHZuVEhKdlRTZXFuWFp2dE1xdzNRdw=="
}
```

**Output**:

```json
{
  "_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAABWAWbHZuVEhKdlRTZXFuWFp2dE1xdzNRdw==",
  "hits": {
    "hits": [
      { "_id": "doc-1001", "_source": { "..." } },
      "...",
      { "_id": "doc-2000", "_source": { "..." } }
    ]
  }
}
```

**Key Points**:
- Each scroll call refreshes the keep-alive timer by the duration specified in the `scroll` parameter
- The `_scroll_id` in the response may differ from the one sent in the request. Always use the most recently returned `_scroll_id` for the next call
- The query and `size` cannot be changed mid-scroll. They are fixed when the scroll is initialized
- Continue calling `/_search/scroll` until `hits.hits` returns an empty array

### Detecting End of Results

The scroll is exhausted when `hits.hits` is empty:

```json
{
  "_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gB...",
  "hits": {
    "total": { "value": 54231, "relation": "eq" },
    "hits": []
  }
}
```

At this point, all matching documents have been retrieved. The scroll context should be closed immediately.

### Closing a Scroll Context

Always close scroll contexts explicitly when done. Each open scroll context holds Lucene segments open on every relevant shard, preventing merges and consuming file handles and heap memory:

```json
DELETE /_search/scroll
{
  "scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAABWAWbHZuVEhKdlRTZXFuWFp2dE1xdzNRdw=="
}
```

**Output**:

```json
{
  "succeeded": true,
  "num_freed": 5
}
```

`num_freed` indicates the number of shard-level scroll contexts released.

#### Closing All Scroll Contexts

To close all open scroll contexts cluster-wide (useful during cleanup or recovery):

```json
DELETE /_search/scroll/_all
```

Use this with caution in production environments, as it terminates all active scroll sessions across all clients.

### sort: ["_doc"] Optimization

The `_doc` sort value instructs Elasticsearch to return documents in their internal Lucene segment order, bypassing relevance scoring and sort processing entirely. This is the most efficient scroll configuration when document order is irrelevant:

```json
POST /articles/_search?scroll=5m
{
  "size": 500,
  "query": {
    "term": { "status": "published" }
  },
  "sort": ["_doc"],
  "_source": ["title", "author", "body"]
}
```

[Inference] Using `_doc` sort can substantially reduce scroll initialization time and per-batch latency compared to relevance scoring or field-based sorting, particularly on large indices. Actual performance gains depend on index size, shard count, and query complexity.

### Scroll with Queries and Filters

Scroll works with any query type. Complex queries are fully supported:

```json
POST /articles/_search?scroll=10m
{
  "size": 500,
  "query": {
    "bool": {
      "must": [
        { "match": { "body": "Elasticsearch" } }
      ],
      "filter": [
        { "term": { "status": "published" } },
        { "range": {
            "published_date": {
              "gte": "2023-01-01",
              "lte": "2024-12-31"
            }
          }
        }
      ]
    }
  },
  "sort": ["_doc"],
  "_source": ["title", "author", "published_date"]
}
```

The query is executed once at scroll initialization. The snapshot captures only documents matching the query at that moment.

### Scroll with Aggregations

Aggregations can be included in the initial scroll request:

```json
POST /articles/_search?scroll=5m
{
  "size": 100,
  "query": { "match_all": {} },
  "sort": ["_doc"],
  "aggs": {
    "by_category": {
      "terms": { "field": "category.keyword" }
    }
  }
}
```

**Key Points**:
- Aggregations are computed only on the first scroll response, not on subsequent batches
- The aggregation result reflects the full matching document set, not just the first batch
- Aggregation results do not change across scroll batches—subsequent calls return empty `aggregations`
- [Inference] If you need aggregation results from a scroll, extract them from the first response only

### Managing Scroll Keep-Alive

The `scroll` keep-alive parameter specifies how long Elasticsearch waits for the next scroll request before expiring the context. It resets on each successful scroll call.

#### Choosing a keep-alive Value

- Too short: Context expires between batches, causing a `search_context_missing_exception`
- Too long: Holds segments open unnecessarily, consuming resources

[Inference] For most batch processing scenarios, keep-alive values between 1 and 10 minutes are appropriate. Choose a value that comfortably exceeds your expected processing time per batch, including any downstream processing latency.

#### Extending keep-alive Mid-Session

If processing a batch takes longer than expected, you can extend the keep-alive without retrieving the next batch:

```json
POST /_search/scroll
{
  "scroll": "10m",
  "scroll_id": "DXF1ZXJ5QW5kRmV0Y2gB..."
}
```

Sending this with a longer `scroll` duration refreshes the timer without advancing to the next batch if a new `scroll_id` is not expected. However, in practice this also retrieves the next batch—there is no dedicated keep-alive extension endpoint separate from the retrieval operation. [Inference] In latency-sensitive pipelines, set the initial keep-alive generously rather than attempting mid-session extensions.

### Handling Expired Scroll Contexts

If a scroll context expires before the next request:

```json
{
  "error": {
    "type": "search_context_missing_exception",
    "reason": "No search context found for id [DXF1ZXJ5QW5kRmV0Y2gB...]"
  },
  "status": 404
}
```

The session cannot be resumed. The scroll must be restarted from the beginning. Application code should handle this exception explicitly, either by restarting the session or by logging and alerting on the failure.

### Sliced Scroll for Parallel Processing

For large indices, scroll throughput can be improved by dividing the scroll into multiple independent slices processed in parallel. Each slice covers a non-overlapping subset of the total document set:

```json
POST /articles/_search?scroll=5m
{
  "slice": {
    "id": 0,
    "max": 4
  },
  "size": 500,
  "query": { "match_all": {} },
  "sort": ["_doc"]
}
```

Run this request with `id: 0`, `id: 1`, `id: 2`, and `id: 3` simultaneously (all with `max: 4`). Each produces an independent scroll context covering one quarter of the documents. Together they cover the full dataset with no overlaps or gaps.

**Key Points**:
- `max` defines the total number of slices. Each value of `id` from `0` to `max - 1` is an independent scroll
- Each slice has its own `_scroll_id` and must be closed independently when complete
- [Inference] Setting `max` to a multiple of the number of primary shards tends to distribute slices evenly. Setting `max` far beyond the shard count may produce diminishing returns or uneven slice sizes, though actual behavior depends on document distribution
- Sliced scroll is most beneficial for CPU-bound or I/O-bound export pipelines where parallelism reduces total wall-clock time

#### Parallel Sliced Scroll Pattern

```
Slice 0: POST /articles/_search?scroll=5m { "slice": { "id": 0, "max": 4 }, ... }
Slice 1: POST /articles/_search?scroll=5m { "slice": { "id": 1, "max": 4 }, ... }
Slice 2: POST /articles/_search?scroll=5m { "slice": { "id": 2, "max": 4 }, ... }
Slice 3: POST /articles/_search?scroll=5m { "slice": { "id": 3, "max": 4 }, ... }

Process each slice concurrently:
  While hits.hits not empty:
    Process batch
    POST /_search/scroll { scroll_id: slice_scroll_id, scroll: "5m" }

Close each slice independently:
  DELETE /_search/scroll { scroll_id: slice_0_scroll_id }
  DELETE /_search/scroll { scroll_id: slice_1_scroll_id }
  ...
```

### Scroll API vs. search_after + PIT

| Feature | Scroll API | search_after + PIT |
|---------|------------|-------------------|
| Status | Legacy | Recommended |
| Statefulness | Stateful (server-side context) | Stateless |
| Result consistency | Yes (frozen snapshot) | Yes (with PIT) |
| Real-time data | No | Yes |
| Parallel processing | Yes (sliced scroll) | Possible (multiple PITs) |
| Resource overhead | High (scroll contexts) | Lower (PIT segments) |
| Random page access | No | No |
| Cursor mechanism | Scroll ID | Sort values |
| Expiry model | Server-side context | Lightweight PIT |
| Recommended for | Legacy systems | All new implementations |

The primary technical distinction is that scroll contexts are heavier server-side state than PIT contexts, and scroll results are never real-time. `search_after` + PIT achieves the same consistency guarantees with lower overhead and real-time visibility into index changes that occur after PIT creation (which scroll never provides).

### Monitoring Open Scroll Contexts

Open scroll contexts are visible in the Nodes Stats API:

```json
GET /_nodes/stats/indices/search
```

Relevant fields in the response:

```json
{
  "nodes": {
    "node-id": {
      "indices": {
        "search": {
          "open_contexts": 12,
          "query_total": 45231,
          "scroll_total": 8,
          "scroll_current": 3,
          "scroll_time_in_millis": 124500
        }
      }
    }
  }
}
```

- `scroll_current`: Number of currently open scroll contexts on the node
- `scroll_total`: Total scroll operations since node start
- `open_contexts`: Total open search contexts including scrolls

[Inference] A steadily increasing `scroll_current` over time is a signal that scroll contexts are not being closed properly. This can eventually cause cluster instability through segment accumulation, file handle exhaustion, or heap pressure, though the specific threshold depends on cluster resources and configuration.

### Resource Considerations

#### Segment Retention

Each open scroll context holds the Lucene segments that were active at scroll initialization open for the duration of the context. This prevents the merge process from consolidating or garbage-collecting those segments.

In write-heavy indices, this causes segment count to grow during active scroll sessions, potentially degrading search performance for other queries against the same index. [Inference] The degree of impact depends on write volume, the number of simultaneously open scroll contexts, and the configured merge policy.

#### Heap Consumption

Scroll contexts consume heap on data nodes. The per-context overhead depends on the query complexity, the number of matching shards, and the size of internal data structures maintained for the context.

#### File Handle Limits

Each scroll context holds file handles open on each shard. On large clusters with many shards and simultaneously open scroll contexts, this can approach operating system file handle limits. [Inference] Monitoring open file handles alongside `scroll_current` is advisable in environments with heavy scroll usage.

### Common Use Cases

#### Full Index Export

```json
POST /articles/_search?scroll=10m
{
  "size": 1000,
  "query": { "match_all": {} },
  "sort": ["_doc"],
  "_source": true
}
```

Iterating with `_doc` sort and full `_source` retrieves all documents in the index as efficiently as scroll allows.

#### Filtered Data Pipeline

```json
POST /logs/_search?scroll=5m
{
  "size": 500,
  "query": {
    "bool": {
      "filter": [
        { "term": { "level": "error" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "sort": ["_doc"]
}
```

Only error-level logs from the past 7 days are included in the scroll snapshot.

#### Reindexing Source Data

While the `_reindex` API handles reindexing natively, scroll is sometimes used in custom reindexing pipelines that require transformation logic not available in the standard reindex API.

### Limitations and Considerations

- **Legacy status**: Elasticsearch recommends `search_after` + PIT for all new deep pagination implementations. Scroll remains supported but is not under active feature development
- **Not real-time**: The snapshot taken at scroll initialization does not reflect subsequent index changes. Documents indexed, updated, or deleted after scroll creation are invisible to that scroll session
- **No random access**: Scroll is strictly sequential. There is no mechanism to skip ahead or revisit earlier batches without restarting
- **Server-side state**: Unlike `search_after`, scroll requires the server to maintain context between requests. This state is a resource liability if contexts are not managed carefully
- **Cannot change query mid-scroll**: The query, size, and source filtering are fixed at initialization. A new scroll must be opened to change any of these
- **Sliced scroll coordination is client-side**: Elasticsearch does not coordinate slices—the client is responsible for managing multiple scroll contexts and ensuring all slices complete
- **Behavior may vary**: Resource consumption, expiry behavior, and performance characteristics depend on Elasticsearch version, cluster configuration, shard count, and index write activity

### Best Practices

- **Prefer search_after + PIT for new implementations**: Use Scroll only when working with existing systems that already depend on it or when migrating legacy pipelines
- **Always close scroll contexts explicitly**: Build closure into all code paths including error handlers and finally blocks
- **Use `sort: ["_doc"]` when order is irrelevant**: Avoid relevance scoring and field sorting overhead for pure data export
- **Set keep-alive conservatively**: Choose the shortest value that covers your per-batch processing time with a reasonable safety margin
- **Monitor `scroll_current`**: Alert on unexpectedly high or growing scroll context counts as an early signal of resource leaks
- **Use sliced scroll for large exports**: Parallelize across slices sized to your shard count for maximum throughput
- **Process batches promptly**: Do not hold scroll contexts open while performing slow downstream operations; process each batch and call the next scroll as quickly as possible
- **Handle `search_context_missing_exception` explicitly**: Design pipelines to detect and respond to expired contexts rather than propagating errors silently