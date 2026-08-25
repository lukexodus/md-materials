## Pagination (from/size)

### Overview

Pagination in Elasticsearch controls which subset of matching documents is returned in a search response. The `from` and `size` parameters are the primary and most straightforward pagination mechanism, functioning similarly to SQL's `OFFSET` and `LIMIT` clauses. They allow you to retrieve results in pages, returning a defined number of documents starting from a specified offset within the ranked result set.

While simple to use, `from`/`size` pagination has meaningful architectural constraints at scale. Understanding both its mechanics and its limitations is essential for building reliable search experiences.

### Basic Syntax

```json
GET /articles/_search
{
  "from": 0,
  "size": 10,
  "query": {
    "match": { "title": "Elasticsearch" }
  }
}
```

- `from`: Zero-based offset of the first document to return. Default is `0`
- `size`: Number of documents to return. Default is `10`

**Output**:

```json
{
  "hits": {
    "total": {
      "value": 10000,
      "relation": "eq"
    },
    "hits": [
      { "_id": "doc-001", "_score": 9.21, "_source": { "..." } },
      { "_id": "doc-002", "_score": 8.74, "_source": { "..." } }
    ]
  }
}
```

**Key Points**:
- `hits.total.value` reports the total number of matching documents, not the number returned
- `hits.total.relation` indicates whether the count is exact (`eq`) or a lower bound (`gte`)—relevant when the total exceeds the `track_total_hits` threshold
- `hits.hits` contains the actual returned documents for this page

### How from/size Works Internally

Understanding the internal mechanics helps explain the limitations.

When Elasticsearch executes a paginated query across multiple shards:

1. Each shard independently ranks its local documents and returns the top `from + size` results to the coordinating node
2. The coordinating node merges results from all shards—up to `(from + size) × number_of_shards` documents in total
3. The coordinating node globally re-ranks the merged set and discards the first `from` documents
4. The remaining `size` documents are returned to the client

**Example**: A query with `from: 900, size: 10` across 5 shards causes each shard to return up to 910 documents to the coordinating node. The coordinating node processes up to 4,550 documents to produce 10 final results.

This behavior has direct implications for memory usage, CPU load, and response time as `from` increases.

### Page Navigation

To move through pages, increment `from` by `size` on each request:

| Page | from | size |
|------|------|------|
| 1 | 0 | 10 |
| 2 | 10 | 10 |
| 3 | 20 | 10 |
| N | (N-1) × size | size |

```json
GET /articles/_search
{
  "from": 20,
  "size": 10,
  "query": {
    "match": { "title": "sharding" }
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" }
  ]
}
```

**Key Point**: Including an explicit `sort` is strongly recommended for paginated queries. Without a deterministic sort, documents with identical scores may appear in different orders across requests, causing items to be skipped or duplicated between pages. Adding a tiebreaker field (such as `_id` or a unique timestamp) ensures stable ordering.

### Controlling Total Hit Count

By default, Elasticsearch counts total hits accurately only up to 10,000 documents and returns `relation: gte` beyond that threshold. You can override this with `track_total_hits`:

#### Exact Count Up to a Threshold

```json
GET /articles/_search
{
  "from": 0,
  "size": 10,
  "track_total_hits": 50000,
  "query": {
    "match": { "body": "distributed systems" }
  }
}
```

#### Always Count Exactly

```json
GET /articles/_search
{
  "from": 0,
  "size": 10,
  "track_total_hits": true,
  "query": {
    "match_all": {}
  }
}
```

**Output** with exact count:

```json
{
  "hits": {
    "total": {
      "value": 142389,
      "relation": "eq"
    }
  }
}
```

**Key Points**:
- `track_total_hits: true` forces an exact count regardless of result set size but adds computational cost
- `track_total_hits: false` disables counting entirely, improving performance when total count is irrelevant
- For UI pagination showing "Page X of Y", you need an accurate total—use `true` or a sufficiently high threshold

### The index.max_result_window Limit

Elasticsearch enforces a hard upper limit on `from + size` through the `index.max_result_window` setting. The default is `10,000`.

Attempting to paginate beyond this limit:

```json
GET /articles/_search
{
  "from": 9995,
  "size": 10
}
```

**Output**:

```json
{
  "error": {
    "type": "illegal_argument_exception",
    "reason": "Result window is too large, from + size must be less than or equal to: [10000] but was [10005]."
  }
}
```

#### Increasing the Limit

You can raise this limit per index:

```json
PUT /articles/_settings
{
  "index": {
    "max_result_window": 50000
  }
}
```

**Key Points**:
- Increasing `max_result_window` allows deeper pagination but increases memory pressure on the coordinating node proportionally
- This is a mitigation, not a solution—for deep pagination requirements, `search_after` or scroll are more appropriate
- The default of 10,000 exists deliberately to protect cluster stability

### Combining from/size with Sorting

Stable, deterministic sorting is essential for correct pagination. Without it, the same document may appear on multiple pages or be skipped entirely if scores are tied and ordering is non-deterministic.

#### Recommended Sort Pattern

```json
GET /articles/_search
{
  "from": 0,
  "size": 10,
  "query": {
    "match": { "title": "Elasticsearch" }
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_id": "asc" }
  ]
}
```

Adding `_id` as a final tiebreaker guarantees uniqueness since `_id` values are always distinct. This pattern is considered best practice for any paginated search.

#### Sorting Without Relevance

When relevance is not required—for example, browsing sorted by date:

```json
GET /articles/_search
{
  "from": 30,
  "size": 10,
  "query": {
    "term": { "status": "published" }
  },
  "sort": [
    { "published_date": "desc" },
    { "_id": "asc" }
  ]
}
```

Omitting `_score` from the sort when relevance is unused also avoids unnecessary score computation.

### from/size with Aggregations

Aggregations are not affected by `from` and `size`. These parameters control only the returned hits, not aggregation buckets:

```json
GET /articles/_search
{
  "from": 0,
  "size": 0,
  "query": {
    "match": { "body": "indexing" }
  },
  "aggs": {
    "by_category": {
      "terms": { "field": "category.keyword" }
    }
  }
}
```

Setting `size: 0` returns no hits but executes the aggregation across all matching documents. This is the standard pattern when you only need aggregation results.

### Performance Characteristics

#### Shallow Pagination (Low from Values)

For `from` values well below `max_result_window`, `from`/`size` performs well. The coordinating node handles a manageable number of documents, memory overhead is low, and response times are fast.

#### Deep Pagination (High from Values)

As `from` increases, performance degrades:

- Each shard must score and return more documents
- The coordinating node must process and sort a larger merged set
- Memory consumption on the coordinating node grows proportionally
- Response times increase, sometimes significantly

[Inference] For most user-facing search applications, users rarely navigate beyond the first few pages. If your use case requires deep pagination regularly, this is a signal to consider `search_after` rather than increasing `max_result_window`.

#### Size and Heap Pressure

Large `size` values return more documents per request, each with full `_source` content. [Inference] Requesting `size: 10000` with large documents may cause significant heap pressure on the coordinating node and increased network payload. Source filtering and appropriate `size` values help mitigate this.

### Comparing Pagination Mechanisms

Elasticsearch provides three pagination mechanisms, each suited to different scenarios:

| Feature | from/size | search_after | Scroll API |
|---------|-----------|--------------|------------|
| Use case | Shallow, user-facing pagination | Deep, sequential pagination | Large data export |
| Stateless | Yes | Yes | No (scroll context) |
| Random page access | Yes | No (sequential only) | No (sequential only) |
| Deep pagination | Poor | Good | Good |
| Real-time results | Yes | Yes | No (point-in-time snapshot) |
| Resource overhead | High at depth | Low | High (open contexts) |
| Max result window limit | Yes | No | No |
| Recommended for production | Shallow pages only | Deep sequential navigation | Bulk export only |

### When to Use from/size

`from`/`size` is appropriate when:

- Users navigate through a small number of pages (typically fewer than 10–20 pages)
- Random page access is required (jumping to page 50 directly)
- Total result count needs to be displayed to the user
- The result set is small and `from + size` stays well below `max_result_window`

`from`/`size` is not appropriate when:

- Paginating through thousands of results (use `search_after`)
- Exporting large datasets (use Scroll API or `search_after` with point-in-time)
- Deep pagination is a routine operation

### Practical Example: Building a Paginated Search Endpoint

A common pattern for a paginated search API:

```json
GET /articles/_search
{
  "from": 20,
  "size": 10,
  "track_total_hits": true,
  "_source": ["title", "author", "published_date", "summary"],
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "Elasticsearch" } }
      ],
      "filter": [
        { "term": { "status": "published" } },
        { "range": { "published_date": { "gte": "2023-01-01" } } }
      ]
    }
  },
  "sort": [
    { "_score": "desc" },
    { "published_date": "desc" },
    { "_id": "asc" }
  ]
}
```

**Output**:

```json
{
  "hits": {
    "total": { "value": 847, "relation": "eq" },
    "hits": [
      {
        "_id": "doc-021",
        "_score": 6.431,
        "_source": {
          "title": "Elasticsearch Cluster Management",
          "author": "Jane Smith",
          "published_date": "2024-01-10",
          "summary": "An overview of managing Elasticsearch clusters..."
        }
      }
    ]
  }
}
```

This pattern combines:
- Source filtering to reduce payload
- `track_total_hits` for displaying total result count to the user
- A deterministic sort with a unique tiebreaker
- Filter context for non-scoring criteria to improve performance

### Limitations and Considerations

- **`from + size` ceiling**: The default `max_result_window` of 10,000 prevents deep pagination without configuration changes
- **Increasing overhead with depth**: Memory and CPU cost grow as `from` increases, regardless of how many documents are ultimately returned
- **No cursor or session state**: Each `from`/`size` request is independent. If documents are added, updated, or deleted between page requests, the result set shifts and pages may be inconsistent
- **Score instability**: Without a deterministic tiebreaker sort, documents with identical scores may shuffle between pages as the index changes
- **Not suitable for exports**: Iterating through an entire index using `from`/`size` in a loop is inefficient and unreliable; use the Scroll API or `search_after` with point-in-time for this purpose
- **Behavior may vary**: Memory consumption and performance characteristics depend on shard count, document size, hardware, and Elasticsearch version

### Best Practices

- **Always include a tiebreaker in sort**: Use `_id` or another unique field as the final sort criterion to guarantee stable page ordering
- **Keep `from` values small**: Design UIs that discourage deep pagination; consider showing "load more" instead of arbitrary page jumping for large result sets
- **Use source filtering**: Combine `from`/`size` with `_source` filtering to minimize response payload
- **Set `track_total_hits` deliberately**: Use `true` when you need accurate counts for display; use `false` when counts are irrelevant to save computation
- **Do not raise `max_result_window` as a reflex**: Increasing the limit trades cluster stability for convenience; evaluate `search_after` first for deep pagination needs
- **Use filter context for non-scoring criteria**: Wrap filters in `filter` clauses within a `bool` query to avoid unnecessary score computation on fields not contributing to relevance