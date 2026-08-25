## Async Search API

### Overview

The async search API allows a search request to be submitted and continue executing in the background on the cluster, with the client polling for results rather than holding an HTTP connection open until completion. This is designed for searches that may run longer than typical client or proxy timeout windows — most commonly, aggregations over very large datasets or long time ranges. It is invoked via `_async_search` instead of the standard `_search` endpoint.

**Key Points**

- Async search returns a `id` immediately (unless the search finishes fast enough to return synchronously first) that is used to poll for updated results.
- Partial results are available while the search is still running, not just after completion — the response includes an `is_partial` flag indicating this.
- Results are retained server-side for a configurable duration after completion, allowing a client to retrieve them later without re-running the search, up to the point they expire or are explicitly deleted.

### Submitting an Async Search

**Example**

```json
POST /logs-*/_async_search
{
  "size": 0,
  "query": {
    "range": {
      "@timestamp": { "gte": "now-1y", "lte": "now" }
    }
  },
  "aggs": {
    "requests_per_day": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "day"
      }
    }
  }
}
```

**Output (search still running)**

```json
{
  "id": "FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMVYzN...",
  "is_partial": true,
  "is_running": true,
  "start_time_in_millis": 1719400000000,
  "expiration_time_in_millis": 1719400605000,
  "response": {
    "took": 1200,
    "timed_out": false,
    "_shards": {
      "total": 20,
      "successful": 12,
      "skipped": 0,
      "failed": 0
    },
    "hits": { "total": { "value": 0, "relation": "eq" }, "hits": [] },
    "aggregations": {
      "requests_per_day": { "buckets": [ ] }
    }
  }
}
```

`_shards.successful` versus `_shards.total` indicates how many shards have reported in so far; `aggregations` reflects only the data from shards that have completed, meaning early polls can return real but incomplete aggregation results.

### Key Request Parameters

- **`wait_for_completion_timeout`**: how long to block synchronously before falling back to returning an async `id` for polling. If the search completes within this window, the full final response is returned immediately with no need to poll. Default is `1s`.
- **`keep_alive`**: how long the search and its results are retained on the cluster after starting, extendable on each poll. Default is `5d` [Unverified — default retention values are configuration-dependent and should be confirmed against the specific cluster version in use].
- **`keep_on_completion`**: if `true`, results are retained (subject to `keep_alive`) even after the search finishes, so they remain retrievable via a later `GET`. If `false`, results may only be available while actively running or briefly after.

**Example — tuning both parameters**

```json
POST /logs-*/_async_search?wait_for_completion_timeout=2s&keep_alive=1d&keep_on_completion=true
{
  "size": 0,
  "aggs": {
    "requests_per_day": {
      "date_histogram": { "field": "@timestamp", "calendar_interval": "day" }
    }
  }
}
```

### Polling for Results

**Example**

```json
GET /_async_search/FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMVYzN...
```

The response has the same shape as the initial submission response, with `is_partial` and `is_running` updated to reflect current state. Once `is_running` is `false`, the `response` field contains the complete, final result set.

===MERMAID_DIAGRAM===

sequenceDiagram

participant Client

participant Cluster

Client->>Cluster: POST _async_search

Cluster-->>Client: id + partial response (if still running)

loop Poll until complete

Client->>Cluster: GET _async_search/{id}

Cluster-->>Client: updated partial/final response

end

Client->>Cluster: DELETE _async_search/{id}

Cluster-->>Client: acknowledgment

### Managing Stored Async Searches

- **`GET /_async_search/status/{id}`**: retrieves only the status (completion state, shard counts) without the full result payload — useful for lightweight polling when the result body itself is large and not yet needed.
- **`DELETE /_async_search/{id}`**: explicitly removes stored results before their `keep_alive` expiration, and additionally cancels the underlying search if it is still running — freeing cluster resources without waiting for natural expiry.
- Expired results are cleaned up automatically once `keep_alive` elapses, so explicit deletion is an optimization rather than a strict requirement, but is good practice when a client knows results are no longer needed.

### When to Use Async Search

- **Large aggregations over long time ranges**: the primary intended use case — e.g., a full-year `date_histogram` over a high-volume `logs-*` index pattern that may take tens of seconds to minutes to fully execute across all shards.
- **Avoiding client/proxy timeout limits**: HTTP clients, load balancers, or API gateways often enforce request timeouts (commonly 30s–60s) well below how long a genuinely large aggregation might take; async search sidesteps this by returning an id immediately rather than holding the connection.
- **Dashboards showing progressive results**: a UI can display partial aggregation buckets as they arrive and update as more shards complete, rather than showing a blank loading state until the entire query finishes.

[Inference] Async search is generally not intended as a replacement for typical low-latency search-box queries, since its polling model and background execution introduce overhead and complexity unnecessary for requests that complete in well under a second — but the exact latency threshold at which async search becomes worthwhile depends on client architecture and acceptable timeout budgets, not a fixed number.

### Async Search vs. Point in Time (PIT) and Scroll

| Aspect | Async Search | Scroll / PIT + `search_after` |
| --- | --- | --- |
| Primary purpose | Long-running single query (often aggregations) | Paginating through large result sets |
| Result delivery | Single (possibly partial, then final) result set | Sequential pages of hits |
| Typical use case | Dashboard aggregations, reporting | Bulk export, deep pagination |
| Resource retention | Result cached under an `id` for `keep_alive` | Search context (scroll) or PIT kept open across requests |

These solve different problems: async search is about **not blocking on a single expensive request**, while scroll/PIT with `search_after` is about **retrieving many pages of results** beyond what `from`/`size` pagination supports efficiently. They are not interchangeable and are sometimes used together — an async search with `size` set to return actual hits, though this is less common than its use for aggregation-only queries.

### Resource and Cluster Considerations

- Running async searches consume cluster resources (memory for cached results, ongoing shard-level computation) for their entire `keep_alive` duration, so setting `keep_alive` no longer than actually needed avoids unnecessary resource retention across many concurrent async searches.
- [Speculation] In clusters with a high volume of concurrent async searches, overly generous default `keep_alive` values combined with `keep_on_completion: true` could accumulate retained result sets faster than they're cleaned up — this is a plausible operational concern worth monitoring for, though actual impact depends on query volume, result size, and cluster capacity in a given deployment, and is not a universally documented failure mode.
- Async search does not bypass normal query execution cost — it changes how results are *delivered* to the client, not how expensive the underlying search is to run on the cluster. Aggregations that are expensive as a synchronous `_search` are equally expensive as an async search; only the client-facing waiting model differs.

### Related Topics

- Point in Time (PIT) API and `search_after` for deep pagination
- Scroll API and its deprecation trajectory relative to PIT
- Aggregation performance tuning for large time-range queries
- `_tasks` API for monitoring and cancelling long-running cluster operations generally
- Circuit breakers and memory considerations for large aggregation buckets
- Kibana's use of async search under the hood for dashboard queries