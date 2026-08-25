## Pagination Strategies for Production

### Overview

Elasticsearch offers several distinct mechanisms for paginating through search results, each with different tradeoffs around depth, consistency, and resource cost. Choosing the wrong strategy for a given access pattern is a common source of production performance problems — particularly the naive use of deep `from`/`size` pagination against large result sets.

### From/Size Pagination

The simplest approach: `from` specifies an offset, `size` specifies how many results to return.

```
GET my-index/_search
{
  "from": 40,
  "size": 20,
  "query": { "match_all": {} }
}
```

**How it works internally:** each shard must compute and sort `from + size` results, then the coordinating node merges and re-sorts across all shards before discarding everything before the `from` offset. This means the cost grows with the offset itself, not just the page size.

**Limitations:**

- Deep pagination is expensive — retrieving page 1000 at size 20 requires each shard to internally handle roughly 20,000 sorted results before discarding most of them.
- There is a hard default limit (`index.max_result_window`, default 10,000) on `from + size`; exceeding it without adjusting the setting raises an error.
- Not suitable for exporting large result sets or infinite-scroll-style deep browsing.

**Best suited for:** shallow, user-facing pagination (typical search UI "page 1, 2, 3..." patterns) where users rarely navigate beyond the first several pages.

### Search After

`search_after` avoids the offset cost entirely by using the sort values of the last document from the previous page as a cursor for the next request.

```
GET my-index/_search
{
  "size": 20,
  "query": { "match_all": {} },
  "sort": [
    { "@timestamp": "asc" },
    { "_id": "asc" }
  ],
  "search_after": [1692000000000, "doc-id-12345"]
}
```

**Key characteristics:**

- Requires a **consistent, unique sort order** — typically achieved by adding a tiebreaker field (often `_id` or another unique field) after the primary sort field, since ties on the primary sort field alone can cause documents to be skipped or duplicated across pages.
- Each request is independent and stateless — no server-side resources are held between requests, unlike scroll.
- Performance does not degrade with page depth, since each request only needs to find documents after the given sort values, not skip and discard `from` documents.
- Cannot jump to an arbitrary page (e.g., "go to page 50" directly) — it only supports sequential forward pagination from a known cursor.

**Best suited for:** deep pagination, especially in automated/programmatic contexts, exports, or infinite-scroll UIs that only move forward sequentially.

### Point in Time (PIT) + Search After

`search_after` alone provides consistent cursoring but does not guarantee a stable view of the data if documents are being indexed, updated, or deleted concurrently. **Point in Time (PIT)** addresses this by creating a lightweight, time-bounded snapshot-like view of the index state to search against consistently across multiple requests.

```
POST my-index/_pit?keep_alive=5m
```

This returns a `pit_id`, subsequently included in search requests instead of specifying the index directly:

```
GET _search
{
  "size": 20,
  "query": { "match_all": {} },
  "pit": {
    "id": "<pit_id>",
    "keep_alive": "5m"
  },
  "sort": [
    { "@timestamp": "asc" },
    { "_id": "asc" }
  ],
  "search_after": [1692000000000, "doc-id-12345"]
}
```

The `keep_alive` parameter is refreshed with each request and determines how long Elasticsearch retains the resources needed to serve the consistent view; PITs must be explicitly closed (`DELETE _pit`) when no longer needed to free those resources promptly, though they will also expire automatically after `keep_alive` elapses without renewal.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 260">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Pagination Strategy Comparison (svg_diagram)</text>

  <rect x="30" y="55" width="220" height="160" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="140" y="78" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">from/size</text>
  <text x="140" y="100" text-anchor="middle" font-size="10" fill="#555">Cost grows with depth</text>
  <text x="140" y="118" text-anchor="middle" font-size="10" fill="#555">Max 10,000 window</text>
  <text x="140" y="136" text-anchor="middle" font-size="10" fill="#555">Jump to any page</text>
  <text x="140" y="154" text-anchor="middle" font-size="10" fill="#555">No consistency guarantee</text>
  <text x="140" y="180" text-anchor="middle" font-size="10" fill="#0a7a2f">Shallow UI paging</text>

  <rect x="290" y="55" width="220" height="160" rx="6" fill="#fff8e1" stroke="#f9a825" stroke-width="1.5" />
  <text x="400" y="78" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">search_after</text>
  <text x="400" y="100" text-anchor="middle" font-size="10" fill="#555">Constant cost per page</text>
  <text x="400" y="118" text-anchor="middle" font-size="10" fill="#555">No depth limit</text>
  <text x="400" y="136" text-anchor="middle" font-size="10" fill="#555">Forward-only, sequential</text>
  <text x="400" y="154" text-anchor="middle" font-size="10" fill="#555">No snapshot consistency</text>
  <text x="400" y="180" text-anchor="middle" font-size="10" fill="#0a7a2f">Deep sequential paging</text>

  <rect x="550" y="55" width="220" height="160" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="660" y="78" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">PIT + search_after</text>
  <text x="660" y="100" text-anchor="middle" font-size="10" fill="#555">Constant cost per page</text>
  <text x="660" y="118" text-anchor="middle" font-size="10" fill="#555">No depth limit</text>
  <text x="660" y="136" text-anchor="middle" font-size="10" fill="#555">Forward-only, sequential</text>
  <text x="660" y="154" text-anchor="middle" font-size="10" fill="#555">Consistent snapshot view</text>
  <text x="660" y="180" text-anchor="middle" font-size="10" fill="#0a7a2f">Exports, consistent scans</text>
</svg>

### Scroll API (Legacy Pattern)

The `scroll` API predates `search_after`/PIT and served a similar purpose — maintaining server-side search context across a sequence of requests to page through a large result set.

- A scroll context is created on the first request with a `scroll` keep-alive parameter, returning a `scroll_id` used for subsequent requests.
- Scroll is explicitly discouraged by Elastic for general deep pagination use cases in favor of `search_after`/PIT, as scroll holds resources open server-side for its duration and does not adapt well to indices undergoing frequent changes.
- Scroll's primary remaining recommended use case is **full-index snapshot-style reindexing or export operations** where a fixed view of the data at a point in time is genuinely desired and the operation completes in a bounded time frame. [Inference: exact current-version guidance on scroll's recommended use has narrowed over successive releases — confirm against the documentation for the specific version in use, as some sources describe it as effectively deprecated in favor of PIT.]

### Choosing a Strategy

| Requirement | Recommended approach |
|---|---|
| Shallow, user-facing paging (first few pages) | `from`/`size` |
| Deep, sequential pagination (any depth) | `search_after` |
| Deep pagination requiring a consistent snapshot | PIT + `search_after` |
| Full index export/reindex, bounded duration | Scroll (legacy) or PIT + `search_after` |
| Random access to an arbitrary page number | `from`/`size` only — no other strategy supports true random access |

### Practical Implementation Considerations

- **Tiebreaker fields are mandatory for correctness** with `search_after` — using a non-unique sort field alone risks documents being skipped or duplicated when ties exist, especially on fields like `@timestamp` where multiple documents can share the same millisecond.
- **`index.max_result_window`** can be raised for `from`/`size`, but doing so does not resolve the underlying performance cost — it only removes the safety limit, and raising it significantly is generally discouraged rather than treated as a real fix for deep pagination needs.
- **PIT resource cost** — an open PIT keeps index segments from being merged away even if they would otherwise be cleaned up, which has a resource cost on the cluster proportional to how long the PIT remains open and how much the index changes during that window. Closing PITs promptly after use is a meaningful operational practice, not just tidiness.
- **Client library support** — official Elasticsearch clients generally provide helper methods for `search_after` and PIT usage, reducing the boilerplate of manually tracking and passing cursor values. [Inference: exact client API surface varies by language and client version.]

### Key Points

- `from`/`size` is simple but expensive at depth and capped by `index.max_result_window`.
- `search_after` provides constant-cost, forward-only deep pagination but requires a unique sort tiebreaker.
- PIT combined with `search_after` adds a consistent point-in-time view, at the cost of holding cluster resources open until closed or expired.
- Scroll is a legacy mechanism, now generally superseded by PIT + `search_after` for most use cases.
- No mechanism other than `from`/`size` supports true random access to an arbitrary page.

### Related Topics

- Sort tiebreakers and consistent ordering with `search_after`
- `index.max_result_window` and its performance implications
- Point in Time (PIT) API and resource management
- Scroll API and its narrowing recommended use cases
- Reindexing large datasets efficiently
- Search performance tuning for deep result sets