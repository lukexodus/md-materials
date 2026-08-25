## Query DSL – Field Collapsing

### Overview

Field collapsing (also called result collapsing or grouping) deduplicates search results by a specified field value, returning only the top-ranked document per unique value of that field. It is applied after scoring and sorting, reducing the visible result set to one representative document per group while still reporting the total number of distinct groups.

It is used when multiple documents share a common grouping attribute — such as thread ID, product ID, author, or domain — and only the most relevant document per group should surface in results.

---

### Basic Syntax

```json
GET /articles/_search
{
  "query": {
    "match": { "body": "elasticsearch performance" }
  },
  "collapse": {
    "field": "author_id"
  },
  "sort": [
    { "_score": { "order": "desc" } }
  ],
  "from": 0,
  "size": 10
}
```

This returns at most one document per unique `author_id` — the highest-scoring document for each author. Up to 10 distinct authors appear in the result.

---

### Requirements on the Collapse Field

The field used for collapsing must be:

- Mapped as `keyword`, a numeric type, or `date`.
- Have **`doc_values` enabled** (the default for these types).
- Be a **single-value field** per document — collapsing on multi-value fields is not supported.

[Inference] Attempting to collapse on a `text` field or a field with `doc_values: false` will produce an error. Multi-value fields may produce undefined collapse behavior. Verify field mapping before using as a collapse key.

---

### How Collapsing Works

Collapsing is a **post-search** operation:

1. Elasticsearch executes the query and scores all matching documents normally.
2. Results are sorted per the `sort` parameter (or by `_score` if not specified).
3. Collapsing is applied to the sorted result set — for each unique value of the collapse field, only the first document (highest priority per sort) is retained.
4. The collapsed result set is returned.

**Key point:** Collapsing does not affect `total.value` in the hits metadata — it reports the total number of matching documents before collapsing, not the number of distinct groups returned.

---

### `total` Hits Behavior

```json
"hits": {
  "total": { "value": 847, "relation": "eq" },
  "hits": [ ... ]
}
```

`total.value` here is 847 — the number of documents matching the query before collapsing. The number of results returned may be far fewer (one per unique collapse field value, up to `size`).

[Inference] There is no built-in way to retrieve the total count of distinct collapse field values directly from a `collapse` query without using a `cardinality` aggregation alongside it. Behavior may vary.

#### Getting distinct group count via aggregation

```json
{
  "query": { "match": { "body": "elasticsearch" } },
  "collapse": { "field": "author_id" },
  "aggs": {
    "distinct_authors": {
      "cardinality": { "field": "author_id" }
    }
  }
}
```

The `cardinality` aggregation returns the approximate count of distinct `author_id` values across all matched documents.

---

### Inner Hits: Expanding Collapsed Groups

The `inner_hits` parameter retrieves additional documents from within each collapsed group — exposing runners-up alongside the top result.

```json
{
  "query": {
    "match": { "body": "indexing strategies" }
  },
  "collapse": {
    "field": "thread_id",
    "inner_hits": {
      "name": "latest_posts",
      "size": 3,
      "sort": [{ "publish_date": "desc" }]
    }
  }
}
```

Each collapsed result includes an `inner_hits.latest_posts` array containing up to 3 additional documents from the same `thread_id` group, sorted by date descending.

#### `inner_hits` parameters

| Parameter | Description |
|---|---|
| `name` | Required. Identifier for the inner hits block in the response. |
| `size` | Number of inner hits to return per group. Default: `3`. |
| `sort` | Sort order for inner hits. Independent of the outer sort. |
| `_source` | Control source fields returned in inner hits. |
| `highlight` | Apply highlighting to inner hits. |
| `explain` | Include score explanation in inner hits. |
| `from` | Offset into the inner hits (for inner pagination). |

---

### Multiple `inner_hits` per Collapse

Multiple inner hit configurations can be specified for the same collapse field, each with a different name and sort:

```json
{
  "collapse": {
    "field": "product_id",
    "inner_hits": [
      {
        "name": "most_recent",
        "size": 1,
        "sort": [{ "date": "desc" }]
      },
      {
        "name": "highest_rated",
        "size": 1,
        "sort": [{ "rating": "desc" }]
      }
    ]
  }
}
```

Each group (unique `product_id`) returns two inner hit blocks — the most recent document and the highest-rated document.

---

### Collapse and Pagination

Collapsing integrates with `from` / `size` pagination. The `size` parameter controls the number of collapsed groups per page, and `from` offsets into the collapsed result set.

```json
{
  "collapse": { "field": "author_id" },
  "from": 20,
  "size": 10
}
```

Returns collapsed groups 21–30 (the third page of 10 groups per page).

[Inference] Because collapsing is applied after the full query executes, deep pagination with `from` on collapsed results has the same performance characteristics as standard deep pagination — Elasticsearch must score and sort all matching documents before applying the offset. For large datasets, `search_after` is preferable.

---

### Collapse with `search_after`

`search_after` cursor pagination works with collapsing. The `sort` values from the last document on the current page are passed as `search_after` on the next request:

```json
{
  "collapse": { "field": "author_id" },
  "sort": [
    { "_score": "desc" },
    { "author_id": "asc" }
  ],
  "search_after": [3.7281, "author-99"],
  "size": 10
}
```

**Key point:** Include the collapse field itself as a tiebreaker in the sort to produce a stable, well-defined cursor. Without a unique or near-unique tiebreaker, cursor stability across pages is not guaranteed.

---

### Collapse on Numeric and Date Fields

Collapsing is not limited to keyword fields:

```json
{
  "collapse": { "field": "category_id" },
  "sort": [{ "popularity": "desc" }]
}
```

```json
{
  "collapse": { "field": "event_date" },
  "sort": [{ "attendee_count": "desc" }]
}
```

Numeric and date fields with doc values enabled are valid collapse keys. Each unique value defines a group.

---

### Collapse on Nested Fields

Collapsing on a field inside a `nested` object requires the `nested` context parameter, analogous to nested sorting:

```json
{
  "collapse": {
    "field": "variants.sku",
    "inner_hits": {
      "name": "top_variant",
      "size": 1,
      "sort": [{ "variants.price": "asc" }]
    }
  }
}
```

[Inference] Collapsing on nested fields has additional constraints that vary by Elasticsearch version. Verify support and behavior against your specific version before using in production.

---

### Interaction with Aggregations

Aggregations run on the **full matched document set**, before collapsing. They are not affected by the collapse operation.

```json
{
  "query": { "match": { "body": "search relevance" } },
  "collapse": { "field": "author_id" },
  "aggs": {
    "by_category": {
      "terms": { "field": "category" }
    }
  }
}
```

The `by_category` aggregation counts documents across all matches, not just the collapsed representatives. This is intentional — aggregations provide analytics over the full dataset while the collapsed hits provide a deduplicated view.

---

### Interaction with Highlighting

Highlighting applies to the collapsed top document per group. Inner hits can independently carry their own highlighting:

```json
{
  "query": { "match": { "body": "shard allocation" } },
  "collapse": {
    "field": "thread_id",
    "inner_hits": {
      "name": "thread_posts",
      "size": 2,
      "highlight": {
        "fields": { "body": {} }
      }
    }
  },
  "highlight": {
    "fields": { "body": {} }
  }
}
```

The outer hit and each inner hit carry independent highlight fragments.

---

### Collapse vs Alternatives

| Approach | Mechanism | Use Case |
|---|---|---|
| `collapse` | Post-search deduplication by field | One result per group; full-text ranking preserved |
| `terms` aggregation | Group and count by field value | Analytics; counts per group; not a ranked result list |
| `top_hits` aggregation | Top documents per bucket | Similar to collapse + inner_hits; aggregation context |
| Deduplication at application layer | Filter results after retrieval | Flexible but wasteful; fetches more than needed |

**Key point:** `collapse` is the appropriate mechanism when the goal is a ranked, paginated list of results deduplicated by a field. `terms` + `top_hits` is more appropriate when the primary need is analytics or when the grouping structure itself is the output.

---

### Limitations

| Limitation | Detail |
|---|---|
| Collapse field must have doc values | `text` fields and fields with `doc_values: false` are not supported |
| Single-value fields only | Multi-value collapse fields are not supported |
| `total` reflects pre-collapse count | Does not report the number of distinct groups |
| Aggregations unaffected by collapse | Run on full match set; cannot be scoped to collapsed results |
| No cross-group ranking guarantee | Only the top document per group is guaranteed; group ordering is by that document's sort value |
| Deep pagination cost | `from`-based deep pagination is expensive; use `search_after` |
| Nested collapse support | [Inference] Limited; behavior varies by version |

---

### Summary

| Aspect | Detail |
|---|---|
| Purpose | Return one representative document per unique field value |
| Collapse field types | `keyword`, numeric, `date`; must have doc values |
| Post-search operation | Applied after scoring and sorting |
| Top document selection | Determined by the active `sort` clause |
| Inner hits | Expose additional group members per collapsed result |
| Multiple inner hits | Supported; each with independent name and sort |
| `total` hits | Reflects pre-collapse match count |
| Aggregations | Run on full match set; unaffected by collapse |
| Pagination | Supports `from`/`size` and `search_after` |
| Group count | Use `cardinality` aggregation alongside collapse |
| Not suitable for | Pure analytics grouping (use `terms` aggregation instead) |