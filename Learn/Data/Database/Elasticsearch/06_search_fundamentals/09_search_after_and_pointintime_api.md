## Search After and Point-in-Time API

### Overview

`search_after` is a stateless deep pagination mechanism that uses the sort values of the last retrieved document as a cursor to fetch the next page of results. Unlike `from`/`size`, it does not accumulate documents from the beginning of the result set on each request—it resumes from a known position, making it efficient regardless of pagination depth.

The Point-in-Time (PIT) API is a closely related feature that creates a lightweight, stable snapshot of an index's state at a specific moment. When combined with `search_after`, PIT ensures that paginated results remain consistent across requests even as the underlying index changes between pages.

Together, `search_after` and PIT form the recommended approach for deep pagination and result set iteration in modern Elasticsearch deployments.

### Why from/size Fails at Depth

As established in the preceding topic, `from`/`size` requires each shard to return `from + size` documents to the coordinating node on every request. At page 500 with a page size of 10, each shard returns 5,010 documents. This grows linearly with depth, consuming increasing memory and CPU regardless of how many documents are ultimately returned.

`search_after` eliminates this accumulation. Instead of telling Elasticsearch to skip the first N documents, it tells Elasticsearch to start after a specific document identified by its sort values. Each shard only needs to find and return documents that sort after the cursor position—a bounded, efficient operation at any depth.

### How search_after Works

`search_after` requires a sort definition. The sort values of the last document on the current page become the cursor for the next page request.

#### Step 1: First Page Request

```json
GET /articles/_search
{
  "size": 10,
  "query": {
    "match": { "body": "distributed systems" }
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_id": "asc" }
  ]
}
```

**Output** (abbreviated):

```json
{
  "hits": {
    "hits": [
      {
        "_id": "doc-001",
        "_score": 9.21,
        "sort": [9.21, "2024-03-15T00:00:00.000Z", "doc-001"]
      },
      {
        "_id": "doc-002",
        "_score": 8.74,
        "sort": [8.74, "2024-02-28T00:00:00.000Z", "doc-002"]
      },
      "...",
      {
        "_id": "doc-010",
        "_score": 7.12,
        "sort": [7.12, "2023-11-04T00:00:00.000Z", "doc-010"]
      }
    ]
  }
}
```

**Key Points**:
- Each hit includes a `sort` array containing its sort values in the same order as the `sort` definition
- The `sort` array of the last document on the page becomes the cursor for the next request
- `from` must be `0` or omitted when using `search_after`—combining `search_after` with `from > 0` is not supported

#### Step 2: Subsequent Page Request

Use the `sort` values from the last document of the previous page as the `search_after` value:

```json
GET /articles/_search
{
  "size": 10,
  "query": {
    "match": { "body": "distributed systems" }
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_id": "asc" }
  ],
  "search_after": [7.12, "2023-11-04T00:00:00.000Z", "doc-010"]
}
```

Elasticsearch returns the 10 documents that sort immediately after the cursor position. Repeat this process for each subsequent page by extracting the `sort` array from the last hit.

#### Step 3: Detecting the Last Page

The last page is reached when the response returns fewer documents than `size`, or returns an empty `hits.hits` array:

```json
{
  "hits": {
    "hits": []
  }
}
```

### The Tiebreaker Requirement

`search_after` requires a sort that uniquely identifies each document. Without a unique tiebreaker, two documents with identical sort values create an ambiguous cursor—Elasticsearch cannot determine which document to start after.

The `_id` field is the standard tiebreaker:

```json
"sort": [
  { "published_date": "desc" },
  { "_id": "asc" }
]
```

Since `_id` is unique per document, no two documents share the same combination of sort values, ensuring the cursor is unambiguous.

[Inference] Omitting a unique tiebreaker in `search_after` pagination may produce correct results in many cases, but documents with identical non-unique sort values may be skipped or duplicated at page boundaries. The behavior may vary depending on shard distribution and document ordering within shards.

### Point-in-Time API

#### The Problem Without PIT

Without PIT, `search_after` pagination faces a consistency problem. Between page requests, the index can change:

- New documents are indexed and may sort into earlier positions in the result set
- Existing documents may be updated or deleted, shifting sort positions
- Segment merges may reorganize internal document ordering

These changes cause the result set to shift between requests, leading to documents being skipped or appearing twice across pages—even with a perfectly constructed `search_after` cursor.

#### What PIT Does

A Point-in-Time creates a stable, frozen view of the index state at the moment the PIT is opened. All subsequent search requests using that PIT ID operate against the same snapshot, regardless of changes made to the index after the PIT was opened.

PIT is lightweight—it does not copy index data. It holds open the relevant Lucene index segments, preventing them from being merged or garbage-collected while the PIT remains active.

#### Opening a Point-in-Time

```json
POST /articles/_pit?keep_alive=5m
```

**Output**:

```json
{
  "id": "46ToAwMDaWR5BXV1aWQyKwZub2RlXzMFaW5kZXgBBnNoYXJkMAAAAAAAAAABFmxGMENQa..."
}
```

**Key Points**:
- `keep_alive` specifies how long the PIT remains open between requests. It is refreshed on each search request using the PIT
- The PIT ID is a long opaque string—store it and pass it with each `search_after` request
- A PIT is opened against one or more indices. Changes to those indices after PIT creation are not visible through that PIT
- PITs consume resources on the cluster (open file handles, segment retention). Always close them when done

#### Using PIT with search_after

When using PIT, the search request omits the index name—the PIT ID implicitly identifies the target:

```json
GET /_search
{
  "size": 10,
  "query": {
    "match": { "body": "distributed systems" }
  },
  "pit": {
    "id": "46ToAwMDaWR5BXV1aWQyKwZub2RlXzMFaW5kZXgBBnNoYXJkMAAAAAAAAAABFmxGMENQa...",
    "keep_alive": "5m"
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_id": "asc" }
  ]
}
```

**Output** (abbreviated):

```json
{
  "pit_id": "46ToAwMDaWR5BXV1aWQyKwZub2RlXzMFaW5kZXgBBnNoYXJkMAAAAAAAAAABFmxGMENQa..._updated",
  "hits": {
    "hits": [
      {
        "_id": "doc-001",
        "_score": 9.21,
        "sort": [9.21, "2024-03-15T00:00:00.000Z", "doc-001"]
      },
      "...",
      {
        "_id": "doc-010",
        "_score": 7.12,
        "sort": [7.12, "2023-11-04T00:00:00.000Z", "doc-010"]
      }
    ]
  }
}
```

**Key Points**:
- The response includes an updated `pit_id`. PIT IDs can change between requests due to shard routing updates. Always use the most recently returned `pit_id` for subsequent requests, not the original
- `keep_alive` in the `pit` object refreshes the expiry timer on each request
- When PIT is used, `_shard_doc` becomes available as a sort field—a guaranteed unique, stable internal document identifier that is preferred over `_id` as a tiebreaker

#### Preferred Tiebreaker with PIT

When using PIT, `_shard_doc` is the recommended tiebreaker instead of `_id`:

```json
"sort": [
  { "_score": "desc" },
  { "published_date": "desc" },
  { "_shard_doc": "asc" }
]
```

`_shard_doc` is a synthetic field representing the internal Lucene document ID combined with the shard ID. It is unique within a PIT context and more efficient than sorting on `_id`, which requires loading `_id` values from the field data cache.

#### Subsequent Pages with PIT

```json
GET /_search
{
  "size": 10,
  "query": {
    "match": { "body": "distributed systems" }
  },
  "pit": {
    "id": "46ToAwMDaWR5BXV1aWQyKwZub2RlXzMFaW5kZXgBBnNoYXJkMAAAAAAAAAABFmxGMENQa..._updated",
    "keep_alive": "5m"
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_shard_doc": "asc" }
  ],
  "search_after": [7.12, "2023-11-04T00:00:00.000Z", 1234567]
}
```

Repeat this pattern—extracting `sort` from the last hit and the updated `pit_id` from the response—until `hits.hits` is empty.

### Closing a Point-in-Time

Always explicitly close a PIT when pagination is complete. Open PITs hold Lucene segments open, preventing merges and consuming file handles and heap:

```json
DELETE /_pit
{
  "id": "46ToAwMDaWR5BXV1aWQyKwZub2RlXzMFaW5kZXgBBnNoYXJkMAAAAAAAAAABFmxGMENQa..."
}
```

**Output**:

```json
{
  "succeeded": true,
  "num_freed": 3
}
```

`num_freed` indicates how many shard-level PIT contexts were released. PITs also expire automatically when `keep_alive` elapses without a refresh, but relying on expiry rather than explicit closure is poor practice and may hold resources unnecessarily.

### Complete Pagination Workflow

A complete `search_after` + PIT iteration pattern:

```
1. Open PIT
   POST /articles/_pit?keep_alive=5m
   → Store pit_id

2. First page request
   GET /_search
   { pit: { id: pit_id, keep_alive: "5m" },
     size: 10, query: {...}, sort: [...] }
   → Store updated pit_id from response
   → Store sort values from last hit

3. Subsequent pages
   GET /_search
   { pit: { id: updated_pit_id, keep_alive: "5m" },
     size: 10, query: {...}, sort: [...],
     search_after: [last_sort_values] }
   → Update pit_id from response
   → Update search_after from last hit
   → Repeat until hits.hits is empty

4. Close PIT
   DELETE /_pit
   { id: final_pit_id }
```

### search_after Without PIT

`search_after` can be used without PIT for scenarios where result consistency across pages is acceptable or not required:

```json
GET /articles/_search
{
  "size": 10,
  "query": { "match_all": {} },
  "sort": [
    { "published_date": "desc" },
    { "_id": "asc" }
  ],
  "search_after": ["2023-11-04T00:00:00.000Z", "doc-010"]
}
```

Without PIT, the search executes against the current live state of the index on each request. This is acceptable for:

- Read-heavy indices with infrequent writes
- Use cases where occasional inconsistency between pages is tolerable
- Scenarios where opening and managing PITs adds unwanted complexity

[Inference] For most production use cases involving pagination over changing data, PIT is the safer and more correct approach. Without PIT, the degree of inconsistency depends on how frequently the index changes during the pagination session.

### Listing and Managing Open PITs

Elasticsearch does not provide a native API to list all open PITs. [Inference] Monitoring open PITs is typically done through the Nodes Stats API, which exposes search context counts, or through cluster monitoring tools. This makes disciplined PIT lifecycle management—always closing PITs explicitly in application code—particularly important.

You can check the number of open search contexts (which includes PITs) via:

```json
GET /_nodes/stats/indices/search
```

Look for `open_contexts` in the response. A growing number of open contexts over time may indicate PITs are not being closed properly.

### Cross-Index PIT

A PIT can be opened against multiple indices or an index alias:

```json
POST /articles,logs/_pit?keep_alive=5m
```

Or against an alias:

```json
POST /content-alias/_pit?keep_alive=5m
```

When opened against an alias, the PIT captures the concrete indices the alias resolved to at the time of creation. If the alias is later updated to point to different indices, the PIT continues to operate against the original indices it was opened on.

### Comparing search_after, Scroll, and from/size

| Feature | from/size | search_after + PIT | Scroll API |
|---------|-----------|-------------------|------------|
| Stateless | Yes | Yes | No |
| Deep pagination | Poor | Excellent | Good |
| Result consistency | No | Yes (with PIT) | Yes (snapshot) |
| Random page access | Yes | No | No |
| Real-time data | Yes | Yes (with PIT) | No |
| Resource overhead | High at depth | Low | High (open scroll contexts) |
| Recommended for | Shallow UI pagination | Deep pagination, exports | Legacy bulk exports only |
| Cursor mechanism | Numeric offset | Sort values | Scroll ID |
| Tiebreaker required | Recommended | Required | Not applicable |

The Scroll API was the predecessor to `search_after` + PIT for deep pagination. It is now considered a legacy approach. Elasticsearch documentation recommends `search_after` with PIT for all new deep pagination and data export use cases.

### Performance Characteristics

#### Coordinating Node Overhead

Because `search_after` resumes from a cursor position, each shard only needs to return `size` documents to the coordinating node rather than `from + size`. The coordinating node merges a fixed number of documents per page regardless of pagination depth, keeping memory overhead constant.

#### Segment Retention

Open PITs prevent Lucene segments from being merged for the duration of the PIT's lifetime. In write-heavy indices, this may cause segment count to grow during active PIT sessions, potentially affecting search performance. [Inference] Short `keep_alive` values and prompt PIT closure reduce this risk, though the actual impact depends on write volume, merge policy configuration, and PIT session duration.

#### keep_alive Tuning

The `keep_alive` value should be long enough to cover the expected time between page requests, but no longer:

- Too short: PIT expires mid-session, causing errors on the next request
- Too long: Unnecessary segment retention and resource consumption

[Inference] For interactive user-facing pagination, `keep_alive` values of 1–5 minutes are typically sufficient. For automated batch processing, values should reflect the actual processing time per page plus a safety margin.

### Error Handling

#### Expired PIT

If a PIT expires before the next request:

```json
{
  "error": {
    "type": "search_context_missing_exception",
    "reason": "No search context found for id [46ToAwMD...]"
  }
}
```

The pagination session must be restarted from the beginning. Application code should handle this exception and re-open a PIT if the session needs to resume.

#### Invalid search_after Values

If `search_after` values do not match the types expected by the sort definition, Elasticsearch returns a parsing error. Ensure sort values extracted from the response are passed back without type conversion.

### Limitations and Considerations

- **Sequential only**: `search_after` does not support random page access. You cannot jump to page 50 without iterating through pages 1–49. For random access, `from`/`size` remains the only option
- **No backwards navigation**: Moving to a previous page requires re-running from the first page or maintaining a history of cursor values in the client
- **PIT ID mutability**: PIT IDs change between requests. Caching or reusing a stale PIT ID causes request failures
- **PIT resource cost**: Each open PIT holds Lucene segments open. Dozens or hundreds of simultaneous open PITs may impact cluster stability depending on available resources
- **Requires stable sort**: Without a unique tiebreaker, cursor behavior at page boundaries may produce inconsistent results
- **keep_alive is not a session timeout**: `keep_alive` measures idle time between requests, not total session duration. As long as requests continue within the keep_alive window, the PIT remains active
- **Behavior may vary**: PIT behavior, particularly around segment retention and resource consumption, depends on Elasticsearch version, index configuration, and cluster load

### Best Practices

- **Always use PIT for data consistency**: Pair `search_after` with PIT whenever paginating over data that may change between requests
- **Always close PITs explicitly**: Build PIT closure into application logic, including error and exception paths, to prevent resource leaks
- **Use `_shard_doc` as tiebreaker with PIT**: Prefer `_shard_doc` over `_id` for efficiency when PIT is active
- **Use `_id` as tiebreaker without PIT**: When PIT is not in use, `_id` remains the correct unique tiebreaker
- **Refresh `pit_id` on every request**: Always use the `pit_id` from the most recent response, not the original
- **Set `keep_alive` conservatively**: Choose the shortest value that reliably covers your inter-request latency
- **Handle expiry gracefully**: Implement retry logic that reopens a PIT and restarts pagination from the beginning if a `search_context_missing_exception` is encountered
- **Do not use Scroll for new implementations**: Prefer `search_after` + PIT over Scroll for all new deep pagination and export use cases